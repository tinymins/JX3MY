--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 自动对话（for 台服）
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_AutoDialogue'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
X.RegisterRestriction('MY_AutoDialogue', { ['*'] = true, intl = false })
--------------------------------------------------------------------------
local DIALOGUE
local CURRENT_WINDOW
local CURRENT_CONTENTS

local O = X.CreateUserSettingsModule('MY_AutoDialogue', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoDialogue'],
			_L['Enable'],
		}),
		szRestriction = 'MY_AutoDialogue',
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bEchoOn = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoDialogue'],
			_L['Echo when autochat'],
		}),
		szRestriction = 'MY_AutoDialogue',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bAutoClose = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoDialogue'],
			_L['Close after auto chat'],
		}),
		szRestriction = 'MY_AutoDialogue',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bEnableShift = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoDialogue'],
			_L['Disable when shift key pressed'],
		}),
		szRestriction = 'MY_AutoDialogue',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bAutoSelectSg = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoDialogue'],
			_L['Auto chat when only one selection'],
		}),
		szRestriction = 'MY_AutoDialogue',
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bAutoSelectSp = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoDialogue'],
			_L['Auto chat when only one space selection'],
		}),
		szRestriction = 'MY_AutoDialogue',
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bSkipQuestTalk = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoDialogue'],
			_L['Skip quest talk'],
		}),
		szRestriction = 'MY_AutoDialogue',
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
})
local D = {}

---------------------------------------------------------------------------
-- 数据存储
---------------------------------------------------------------------------
function D.LoadData()
	DIALOGUE = X.LoadLUAData({'config/auto_dialogue.jx3dat', X.PATH_TYPE.GLOBAL})
		or X.LoadLUAData(X.PACKET_INFO.ROOT .. 'MY_Toolbox/data/auto_dialogue/{$lang}.jx3dat')
		or {}
end

function D.SaveData()
	if not DIALOGUE then
		return
	end
	X.SaveLUAData({'config/auto_dialogue.jx3dat', X.PATH_TYPE.GLOBAL}, DIALOGUE)
end

function D.EnableDialogueData(szMap, szName, szContext, szKey)
	X.Set(DIALOGUE, {szMap, szName, szContext, szKey}, 1)
	D.SaveData()
	D.AutoDialogue()
end

function D.DisableDialogueData(szMap, szName, szContext, szKey)
	if X.Get(DIALOGUE, {szMap, szName, szContext, szKey}) then
		X.Set(DIALOGUE, {szMap, szName, szContext, szKey}, 0)
	end
	D.SaveData()
end

function D.RemoveDialogueData(szMap, szName, szContext, szKey)
	if X.Get(DIALOGUE, {szMap, szName, szContext, szKey}) then
		X.Set(DIALOGUE, {szMap, szName, szContext, szKey}, nil)
	end
	if X.IsEmpty(X.Get(DIALOGUE, {szMap, szName, szContext})) then
		X.Set(DIALOGUE, {szMap, szName, szContext}, nil)
	end
	if X.IsEmpty(X.Get(DIALOGUE, {szMap, szName})) then
		X.Set(DIALOGUE, {szMap, szName}, nil)
	end
	if X.IsEmpty(X.Get(DIALOGUE, {szMap})) then
		X.Set(DIALOGUE, {szMap}, nil)
	end
	D.SaveData()
end

---------------------------------------------------------------------------
-- 自动对话核心逻辑
---------------------------------------------------------------------------
do
-- 将服务器返回的对话Info解析为内容和交互选项
function D.DecodeDialogInfo(aInfo, dwTarType, dwTarID)
	local szName, szMap = _L['Common'], _L['Common']
	if dwTarID ~= X.GetClientPlayerID() then
		szName = X.GetTargetName(dwTarType, dwTarID, { eShowID = 'never' }) or _L['Common']
		if dwTarType ~= TARGET.ITEM then
			szMap = Table_GetMapName(X.GetClientPlayer().GetMapID())
		end
	end
	local dialog = { szMap = szMap, szName = szName, szContext = '', aOptions = {} }
	-- 分析交互选项和文字内容
	for _, v in ipairs(aInfo) do
		if v.name == '$'  -- 选项
		or v.name == 'W' then  -- 需要确认的选项
			local szImage, nImageFrame
			if v.name == 'T' then
				for iconid in string.gmatch(v.context, '%$ (%d+)') do
					szImage = 'fromiconid'
					nImageFrame = iconid
				end
			end
			table.insert(dialog.aOptions, { dwID = tonumber(v.attribute.id) or 0, szContext = v.context })
		elseif v.name == 'T' then -- 图片
			local szImage, nImageFrame
			for iconid in string.gmatch(v.context, '%$ (%d+)') do
				szImage = 'fromiconid'
				nImageFrame = iconid
			end
			table.insert(dialog.aOptions, { dwID = tonumber(v.attribute.id) or 0, szContext = v.context, szImage = szImage, nImageFrame = nImageFrame })
		elseif v.name == 'M' then -- 商店
			table.insert(dialog.aOptions, { szContext = v.context })
		elseif v.name == 'Q' then -- 任务对话
			local dwQuestId = tonumber(v.attribute.questid)
			local tQuestInfo = Table_GetQuestStringInfo(dwQuestId)
			if tQuestInfo then
				local eQuestState, nLevel = GetQuestState(dwQuestId, dwTarType, dwTarID)
				if eQuestState == QUEST_STATE_YELLOW_QUESTION
				or eQuestState == QUEST_STATE_BLUE_QUESTION
				or eQuestState == QUEST_STATE_HIDE
				or eQuestState == QUEST_STATE_YELLOW_EXCLAMATION
				or eQuestState == QUEST_STATE_BLUE_EXCLAMATION
				or eQuestState == QUEST_STATE_WHITE_QUESTION
				or eQuestState == QUEST_STATE_DUN_DIA then
					table.insert(dialog.aOptions, { szContext = tQuestInfo.szName })
				end
			end
		elseif v.name == 'F' then -- 字体
			dialog.szContext = dialog.szContext .. v.attribute.text
		elseif v.name == 'text' then -- 文本
			dialog.szContext = dialog.szContext .. v.context
		elseif v.name == 'MT' then -- 交通
			table.insert(dialog.aOptions, { szContext = v.context })
		elseif v.name == 'U' then -- 跨地图交通
			table.insert(dialog.aOptions, { szContext = v.context })
		end
	end
	return dialog
end

function D.ProcessDialogInfo(frame, aInfo, dwTarType, dwTarID, dwIndex)
	local dialog = D.DecodeDialogInfo(aInfo, dwTarType, dwTarID)
	if not (dialog.szMap and dialog.szName and dwIndex and aInfo) then
		return
	end
	local option, nRepeat
	local tChat = X.Get(DIALOGUE, {dialog.szMap, dialog.szName, dialog.szContext})
	if tChat then
		for i, p in ipairs(dialog.aOptions) do
			if p.dwID and tChat[p.szContext] and tChat[p.szContext] > 0 then
				option = p
				nRepeat = tChat[p.szContext]
				break
			end
		end
	end
	if not X.IsInDungeonMap() then
		if not option and O.bAutoSelectSp and #dialog.aOptions == 1 and dialog.aOptions[1].szContext == '' then
			option = dialog.aOptions[1]
			nRepeat = 1
		end
		if not option and O.bAutoSelectSg and #dialog.aOptions == 1 then
			option = dialog.aOptions[1]
			nRepeat = 1
		end
	end
	if option and option.dwID then
		if O.bAutoClose then
			frame:Hide()
			Station.Show()
			rlcmd('dialogue with npc 0')
		end
		for i = 1, nRepeat do
			X.GetClientPlayer().WindowSelect(dwIndex, option.dwID)
		end
		if O.bEchoOn then
			X.OutputSystemMessage(_L('Conversation with [%s]: %s', dialog.szName, dialog.szContext:gsub('%s', '')))
			if option.szContext and option.szContext ~= '' then
				X.OutputSystemMessage(_L('Conversation with [%s] auto chose: %s', dialog.szName, option.szContext))
			end
		end
		--[[#DEBUG BEGIN]]
		X.OutputDebugMessage('AUTO_CHAT', 'WindowSelect ' .. dwIndex .. ',' .. option.dwID .. 'x' .. nRepeat, X.DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		return true
	end
end

function D.AutoDialogue()
	-- Output(CURRENT_CONTENTS, CURRENT_WINDOW)
	if not DIALOGUE then
		D.LoadData()
	end
	if O.bEnableShift and IsShiftKeyDown() then
		X.OutputSystemMessage(_L['Auto interact disabled due to SHIFT key pressed.'])
		return
	end
	local frame = Station.Lookup('Normal/DialoguePanel')
	if frame and frame:IsVisible() then
		return D.ProcessDialogInfo(frame, frame.aInfo, frame.dwTargetType, frame.dwTargetId, frame.dwIndex)
	end
	local frame = Station.Lookup('Lowest2/PlotDialoguePanel')
	if frame and frame:IsVisible() then
		return D.ProcessDialogInfo(frame, frame.aInfo, frame.dwTargetType, frame.dwTargetId, frame.dwIndex)
	end
end

local function onOpenWindow()
	CURRENT_WINDOW = arg0
	CURRENT_CONTENTS = arg1
	if not O.bEnable or X.IsRestricted('MY_AutoDialogue') then
		return
	end
	X.DelayCall('MY_AutoDialogue__AutoDialogue', D.AutoDialogue)
end
X.RegisterEvent('OPEN_WINDOW', 'MY_AutoDialogue', onOpenWindow)
end

---------------------------------------------------------------------------
-- 精简任务对话核心逻辑
---------------------------------------------------------------------------
do
local function UnhookSkipQuestTalk()
	local frame = Station.Lookup('Lowest2/QuestAcceptPanel')
	if not frame or not frame.__SkipQuestHackEl then
		return 0
	end
	frame.__SkipQuestEl = nil
	frame.__SkipQuestHackEl:Destroy()
	frame.__SkipQuestHackEl = nil
end
X.RegisterReload('MY_AutoDialogue#SkipQuestTalk', UnhookSkipQuestTalk)

local function HookSkipQuestTalk()
	local frame = Station.Lookup('Lowest2/QuestAcceptPanel')
	if not frame then
		return 0
	end
	if O.bSkipQuestTalk then
		if not frame.__SkipQuestHackEl then
			local w, h = Station.GetClientSize()
			frame.__SkipQuestEl = frame:Lookup('Btn_Skip')
			frame.__SkipQuestHackEl = X.UI(frame):Append('WndWindow', {
				name = 'Btn_Skip',
				x = 0, y = 0, w = w, h = h,
			}):Raw()
		end
		if frame.dwShowIndex == 1 and X.IsTable(frame.tQuestRpg) then
			local nCount = 2
			while frame.tQuestRpg['szText' .. nCount] and frame.tQuestRpg[nCount] ~= '' do
				nCount = nCount + 1
			end
			frame.dwShowIndex = nCount - 1
		end
		frame.__SkipQuestHackEl:SetVisible(frame.__SkipQuestEl:IsVisible() and frame.tQuestRpg and frame.tQuestRpg.szText2 and frame.tQuestRpg.szText2 ~= '')
	else
		UnhookSkipQuestTalk()
	end
end

local function onInit()
	X.BreatheCall('MY_AutoDialogue#SkipQuestTalk', HookSkipQuestTalk)
end
X.RegisterInit('MY_AutoDialogue#SkipQuestTalk', onInit)

local function onFrameCreate()
	X.BreatheCall('MY_AutoDialogue#SkipQuestTalk', HookSkipQuestTalk)
end
X.RegisterFrameCreate('QuestAcceptPanel', 'MY_AutoDialogue#SkipQuestTalk', onFrameCreate)
end

---------------------------------------------------------------------------
-- 设置按钮入口
---------------------------------------------------------------------------
function D.GetDialogueMenu(aInfo, dwTargetType, dwTargetID, dwIndex)
	if not aInfo then
		return
	end
	local dialog = D.DecodeDialogInfo(aInfo, dwTargetType, dwTargetID)
	if not dialog.szName or not dialog.szMap then
		return
	end
	-- 显示标题
	local szCaption = dialog.szName
	if dialog.szContext ~= '' then
		szCaption = szCaption .. '(' .. X.StringSubW(dialog.szContext:gsub('%s', ''), 1, 8)
		if X.StringLenW(dialog.szContext) > 8 then
			szCaption = szCaption .. '...'
		end
		szCaption = szCaption .. ')'
	end
	if IsCtrlKeyDown() then
		szCaption = '(' .. dwIndex .. ') ' .. szCaption
	end
	-- 计算选项列表
	local tOption, aOption = {}, {}
	for i, option in ipairs(dialog.aOptions) do -- 面板上的对话
		if option.dwID then
			table.insert(aOption, option)
			tOption[option.szContext] = true
		end
	end
	local aList = X.Get(DIALOGUE, {dialog.szMap, dialog.szName, dialog.szContext}) -- 保存的自动对话
	if aList then
		for szContext, nCount in pairs(aList) do
			if not tOption[szContext] then
				table.insert(aOption, { szContext = szContext })
				tOption[szContext] = true
			end
		end
	end
	-- 数据转菜单项
	local menu = {{ szOption = szCaption, bDisable = true }, { bDevide = true }}
	for _, option in ipairs(aOption) do
		local szCaption = option.szContext
		if IsCtrlKeyDown() and option.dwID then
			szCaption = '(' .. option.dwID .. ') ' .. szCaption
		end
		local menuSub = { szOption = szCaption, r = 255, g = 255, b = 255 }
		local nRepeat = X.Get(DIALOGUE, {dialog.szMap, dialog.szName, dialog.szContext, option.szContext})
		if nRepeat then
			menuSub.szIcon = 'ui/Image/UICommon/Feedanimials.UITex'
			menuSub.nFrame = 86
			menuSub.nMouseOverFrame = 87
			menuSub.szLayer = 'ICON_RIGHT'
			menuSub.fnClickIcon = function()
				D.RemoveDialogueData(dialog.szMap, dialog.szName, dialog.szContext, option.szContext)
				X.UI.ClosePopupMenu()
			end
		end
		if nRepeat and nRepeat > 0 then
			menuSub.r, menuSub.g, menuSub.b = 255, 0, 255
			menuSub.fnAction = function()
				D.DisableDialogueData(dialog.szMap, dialog.szName, dialog.szContext, option.szContext)
				X.UI.ClosePopupMenu()
			end
		else
			menuSub.r, menuSub.g, menuSub.b = 255, 255, 255
			menuSub.fnAction = function()
				D.EnableDialogueData(dialog.szMap, dialog.szName, dialog.szContext, option.szContext)
				X.UI.ClosePopupMenu()
			end
		end
		if option.szImage then
			menuSub.szIcon = option.szImage
			menuSub.nFrame = option.nImageFrame
			menuSub.szLayer = 'ICON_RIGHT'
		end
		table.insert(menu, menuSub)
	end
	return menu
end

do
local ENTRY_LIST = {
	{
		name = 'DialoguePanel', root = 'Normal/DialoguePanel', x = 53, y = 4,
		keys = { info = 'aInfo', tartype = 'dwTargetType', tarid = 'dwTargetId', winidx = 'dwIndex'},
	},
	{
		name = 'PlotDialoguePanel', root = 'Lowest2/PlotDialoguePanel',
		ref = 'WndScroll_Options', point = 'TOPRIGHT', x = -50, y = 10, plot = true,
		keys = { info = 'aInfo', tartype = 'dwTargetType', tarid = 'dwTargetId', winidx = 'dwIndex'},
	},
	{
		name = 'QuestAcceptPanel', root = 'Lowest2/QuestAcceptPanel',
		ref = 'Btn_Accept', point = 'TOPRIGHT', x = -30, y = 10, plot = true,
		keys = { info = 'aInfo', tartype = 'dwTargetType', tarid = 'dwTargetID', winidx = 'dwIndex'},
	},
}
function D.CreateEntry()
	if X.IsRestricted('MY_AutoDialogue') then
		return
	end
	for _, p in ipairs(ENTRY_LIST) do
		local frame = Station.Lookup(p.root)
		if frame and (not p.el or not p.el:IsValid()) then
			local wnd = frame
			if p.path then
				wnd = frame:Lookup(p.path)
			end
			p.el = X.UI(wnd):Append('WndButton', {
				name = 'WndButton_AutoChat',
				text = _L['Autochat'],
				tip = {
					render = _L['Left click to config autochat.\nRight click to edit global config.'],
					position = X.UI.TIP_POSITION.TOP_BOTTOM,
				},
				menuLClick = function()
					return D.GetDialogueMenu(frame[p.keys.info], frame[p.keys.tartype], frame[p.keys.tarid], frame[p.keys.winidx])
				end,
				menuRClick = D.GetConfigMenu,
			}):Raw()
		end
	end
	D.UpdateEntryPos()
end
for _, p in ipairs(ENTRY_LIST) do
	X.RegisterFrameCreate(p.name, 'MY_AutoDialogue#ENTRY', D.CreateEntry)
end
X.RegisterInit('MY_AutoDialogue', D.CreateEntry)

function D.UpdateEntryPos()
	if X.IsRestricted('MY_AutoDialogue') then
		return
	end
	for _, p in ipairs(ENTRY_LIST) do
		local frame = Station.Lookup(p.root)
		if frame and p.el and p.el:IsValid() then
			local wnd = frame
			if p.path then
				wnd = frame:Lookup(p.path)
			end
			local ref = frame
			if p.ref then
				ref = frame:Lookup(p.ref)
			end
			local x = p.x + (ref:GetAbsX() - frame:GetAbsX())
			local y = p.y + (ref:GetAbsY() - frame:GetAbsY())
			local point = p.point or 'TOPLEFT'
			if point:find('RIGHT') then
				x = x + ref:GetW()
			end
			if point:find('BOTTOM') then
				y = y + ref:GetH()
			end
			p.el:SetRelPos(x, y)
		end
	end
end
X.RegisterEvent('UI_SCALED', 'MY_AutoDialogue#ENTRY', D.UpdateEntryPos)

function D.RemoveEntry()
	for i, p in ipairs(ENTRY_LIST) do
		if p.el and p.el:IsValid() then
			p.el:Destroy()
		end
		p.el = nil
	end
end
X.RegisterReload('MY_AutoDialogue#ENTRY', D.RemoveEntry)

local function onOpenWindow()
	if X.IsRestricted('MY_AutoDialogue') then
		return
	end
	D.CreateEntry()
end
X.RegisterEvent('OPEN_WINDOW', 'MY_AutoDialogue#ENTRY', onOpenWindow)

X.RegisterEvent('MY_RESTRICTION', 'MY_AutoDialogue#ENTRY', function()
	if arg0 and arg0 ~= 'MY_AutoDialogue' then
		return
	end
	if X.IsRestricted('MY_AutoDialogue') then
		D.RemoveEntry()
	else
		D.CreateEntry()
	end
end)
end

---------------------------------------------------------------------------
-- 头像设置菜单
---------------------------------------------------------------------------
function D.GetConfigMenu()
	return {
		szOption = _L['Autochat'], {
			szOption = _L['Enable'],
			bCheck = true, bChecked = O.bEnable,
			fnAction = function()
				O.bEnable = not O.bEnable
			end
		}, {
			szOption = _L['Echo when autochat'],
			bCheck = true, bChecked = O.bEchoOn,
			fnAction = function()
				O.bEchoOn = not O.bEchoOn
			end
		}, {
			szOption = _L['Auto chat when only one selection'],
			bCheck = true, bChecked = O.bAutoSelectSg,
			fnAction = function()
				O.bAutoSelectSg = not O.bAutoSelectSg
			end
		}, {
			szOption = _L['Auto chat when only one space selection'],
			bCheck = true, bChecked = O.bAutoSelectSp,
			fnAction = function()
				O.bAutoSelectSp = not O.bAutoSelectSp
			end
		}, {
			szOption = _L['Disable when shift key pressed'],
			bCheck = true, bChecked = O.bEnableShift,
			fnAction = function()
				O.bEnableShift = not O.bEnableShift
			end
		}, {
			szOption = _L['Close after auto chat'],
			bCheck = true, bChecked = O.bAutoClose,
			fnAction = function()
				O.bAutoClose = not O.bAutoClose
			end
		}, {
			szOption = _L['Skip quest talk'],
			bCheck = true, bChecked = O.bSkipQuestTalk,
			fnAction = function()
				O.bSkipQuestTalk = not O.bSkipQuestTalk
			end
		},
	}
end

X.RegisterAddonMenu('MY_AutoDialogue', function()
	if X.IsRestricted('MY_AutoDialogue') then
		return
	end
	return D.GetConfigMenu()
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
