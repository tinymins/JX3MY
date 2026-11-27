--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 科举助手 (台服用)
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_ExamTip'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
X.RegisterRestriction('MY_ExamTip', { ['*'] = true, intl = false })
--------------------------------------------------------------------------
local LOCAL_DATA_CACHE -- 本地题库
local INPUT_DATA_CACHE = {} -- 玩家答题缓存
local REMOTE_DATA_CACHE = {} -- 从服务器获取到的数据缓存
local LAST_REMOTE_QUERY -- 最后一次网络查询的题目（防止重查）
local D = {}

local function DisplayMessage(szText)
	X.OutputSystemMessage(_L['Exam tip'], szText)
end

local function IsCurrentQuestion(szQues)
	local frame = Station.Lookup('Normal/ExaminationPanel')
	if not frame then
		return
	end
	return frame:Lookup('', 'Handle_ExamContents'):Lookup(0):GetText() == szQues
end

local function ResolveAnswer(szAnsw)
	local frame = Station.Lookup('Normal/ExaminationPanel')
	if not frame then
		return
	end
	for i = 1, 4 do
		frame:Lookup('Wnd_Type1/CheckBox_T1No' .. i, 'Text_T1No' .. i):SetFontColor(0, 0, 0)
	end
	if szAnsw then
		for i = 1, 4 do
			if frame:Lookup('Wnd_Type1/CheckBox_T1No' .. i, 'Text_T1No' .. i):GetText() == szAnsw then
				frame:Lookup('Wnd_Type1/CheckBox_T1No' .. i, 'Text_T1No' .. i):SetFontColor(255, 255, 0)
				frame:Lookup('Wnd_Type1/CheckBox_T1No' .. i):Check(true)
				return true
			end
		end
	end
	return false
end

local function QueryData(szQues)
	if LAST_REMOTE_QUERY == szQues then
		return
	end
	LAST_REMOTE_QUERY = szQues
	ResolveAnswer()
	DisplayMessage(_L['Querying, please wait...'])

	if not LOCAL_DATA_CACHE then
		LOCAL_DATA_CACHE = X.LoadLUAData({'config/examtip.jx3dat', X.PATH_TYPE.GLOBAL}, { passphrase = false })
			or X.LoadLUAData({'config/examtip.jx3dat', X.PATH_TYPE.GLOBAL})
			or {}
	end
	if LOCAL_DATA_CACHE[szQues] then
		for _, szAnsw in ipairs(LOCAL_DATA_CACHE[szQues]) do
			if ResolveAnswer(szAnsw) then
				return DisplayMessage(_L['Local exam data matched.'])
			end
		end
	end

	X.Ajax({
		url = MY_RSS.PULL_BASE_URL .. '/api/exam?'
			.. X.EncodeQuerystring(X.ConvertToUTF8({
				l = X.ENVIRONMENT.GAME_LANG,
				L = X.ENVIRONMENT.GAME_EDITION,
				search = szQues,
			})),
		success = function(html, status)
			local res = X.DecodeJSON(html)
			if not res then
				return
			end
			if X.IsTable(res.data) and #res.data > 0 then
				local qas = {}
				for _, rec in ipairs(res.data) do
					local question = X.Get(rec, {'title'})
					local options = X.Get(rec, {'options'})
					local answers = X.Get(rec, {'answers'})
					if X.IsString(question) and X.IsString(answers) then
						options = X.DecodeJSON(options or '')
						answers = X.DecodeJSON(answers or '')
						if X.IsTable(answers) and X.IsNumber(answers[1]) and X.IsTable(options) and X.IsString(options[answers[1] + 1]) then
							table.insert(qas, { question = question, answer = options[answers[1] + 1] })
						end
					end
				end

				for _, qa in ipairs(qas) do
					if IsCurrentQuestion(qa.question) and ResolveAnswer(qa.answer) then
						REMOTE_DATA_CACHE[qa.question] = qa.answer
						return
					end
				end

				local szText = _L['No result matched, here\'s similar answers:']
				for _, qa in ipairs(qas) do
					szText = szText .. '\n' .. _L('Question: %s\nAnswer: %s', qa.question, qa.answer)
				end
				DisplayMessage(szText)
			else
				if X.IsString(res.more) then
					DisplayMessage(_L['No result found, here\'s from open search engine:'] .. '\n' .. res.more)
				else
					DisplayMessage(_L['No result found.'])
				end
			end
		end,
		error = function(html, status, connected)
			DisplayMessage(_L['Loading failed.'])
		end,
		timeout = 10000,
	})
end

function D.SubmitData(tExamData, bAllRight)
	if X.IsDebugServer() or not MY_Serendipity.bEnable then
		return
	end
	local data = {}
	for szQues, aBody in pairs(tExamData) do
		if not REMOTE_DATA_CACHE[szQues] then
			table.insert(aBody, 1, szQues)
			table.insert(data, X.ConvertToUTF8(aBody))
		end
	end
	if #data == 0 then
		return
	end
	X.Ajax({
		url = MY_RSS.PUSH_BASE_URL .. '/api/exam/uploads',
		data = {
			l = X.ENVIRONMENT.GAME_LANG,
			L = X.ENVIRONMENT.GAME_EDITION,
			data = X.EncodeJSON(data),
			perfect = bAllRight and 1 or 0,
		},
		signature = X.SECRET['J3CX::EXAM_UPLOADS'],
		success = function(html, status)
			local res = X.DecodeJSON(html)
			if X.IsRestricted('MY_ExamTip') or not res then
				return
			end
			X.OutputSystemMessage(_L['Exam tip'], _L('%s record(s) commited, %s record(s) accepted!', res.received, res.accepted))
		end,
	})
end

function D.GatherDataFromPanel()
	local frame = Station.Lookup('Normal/ExaminationPanel')
	if not (frame and frame:IsVisible()) then
		return
	end
	local txtQues = frame:Lookup('', 'Handle_ExamContents'):Lookup(0)
	if not txtQues then
		return
	end
	local szQues, aBody = txtQues:GetText()
	-- 单选
	if not aBody then
		local wnd = frame:Lookup('Wnd_Type1')
		if wnd and wnd:IsVisible() then
			local aChoise, aChoosed = {}, {}
			for i = 1, 4 do
				local chk = wnd:Lookup('CheckBox_T1No' .. i)
				if chk and chk:IsVisible() then
					if chk:IsCheckBoxChecked() then
						table.insert(aChoosed, #aChoise)
					end
					table.insert(aChoise, chk:Lookup('', 'Text_T1No' .. i):GetText())
				end
			end
			aBody = { 1, aChoise, aChoosed }
		end
	end
	-- 多选
	if not aBody then
		local wnd = frame:Lookup('Wnd_Type2')
		if wnd and wnd:IsVisible() then
			local aChoise, aChoosed = {}, {}
			for i = 1, 4 do
				local chk = wnd:Lookup('CheckBox_T2No' .. i)
				if chk and chk:IsVisible() then
					if chk:IsCheckBoxChecked() then
						table.insert(aChoosed, #aChoise)
					end
					table.insert(aChoise, chk:Lookup('Text_T2No' .. i):GetText())
				end
			end
			aBody = { 2, aChoise, aChoosed }
		end
	end
	-- 问答题
	if not aBody then
		local wnd = frame:Lookup('Wnd_Type3')
		if wnd and wnd:IsVisible() then
			local edt = wnd:Lookup('Edit_Anwer')
			aBody = { 3, edt and edt:GetText() or '' }
		end
	end
	-- 看图单选
	if not aBody then
		local wnd = frame:Lookup('Wnd_Type4')
		if wnd and wnd:IsVisible() then
			local aChoise, aChoosed = {}, {}
			for i = 1, 4 do
				local chk = wnd:Lookup('CheckBox_T4No' .. i)
				if chk and chk:IsVisible() then
					if chk:IsCheckBoxChecked() then
						table.insert(aChoosed, #aChoise)
					end
					table.insert(aChoise, chk:Lookup('Text_T4No' .. i):GetText())
				end
			end
			aBody = { 4, aChoise, aChoosed }
		end
	end
	return szQues, aBody
end

do
local l_nExamPrintRemainSpace = 0
local function OnFrameBreathe()
	local szQues, aBody = D.GatherDataFromPanel()
	if not X.IsRestricted('MY_ExamTip') then
		QueryData(szQues)
	end
	if szQues and aBody then
		INPUT_DATA_CACHE[szQues] = aBody
	end
	l_nExamPrintRemainSpace = X.GetClientPlayer().GetExamPrintRemainSpace()
end

X.RegisterFrameCreate('ExaminationPanel', 'EXAM_TIP', function(name, frame)
	frame.OnFrameBreathe = OnFrameBreathe
end)

X.RegisterEvent('LOOT_ITEM', 'MY_EXAMTIP', function()
	if X.IsEmpty(INPUT_DATA_CACHE) then
		return
	end
	local item = GetItem(arg1)
	if item and item.nUiId == 65814 then
		local nBeforeExamPrintRemainSpace = l_nExamPrintRemainSpace
		local tExamData = X.Clone(INPUT_DATA_CACHE)
		INPUT_DATA_CACHE = {}
		X.DelayCall(2000, function()
			local bAllRight = nBeforeExamPrintRemainSpace - X.GetClientPlayer().GetExamPrintRemainSpace() == 100
			D.SubmitData(tExamData, bAllRight)
		end)
	end
end)
end

X.RegisterEvent('OPEN_WINDOW', 'MY_EXAMTIP', function()
	if X.IsEmpty(INPUT_DATA_CACHE) then
		return
	end
	if X.StringFindW(arg1, _L['<G>Congratulations you finished the exam, please visit Yangzhou next monday for result.']) then
		local tExamData = X.Clone(INPUT_DATA_CACHE)
		INPUT_DATA_CACHE = {}
		D.SubmitData(tExamData, false)
	end
end)

X.RegisterReload('MY_ExamTip', function()
	X.UI.CloseFrame('ExaminationPanel')
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
