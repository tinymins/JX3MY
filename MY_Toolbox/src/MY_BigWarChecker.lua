--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 大战没交
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_BigWarChecker'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_BigWarChecker', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_BigWarChecker'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}

local function IsBigWarFinishable(me)
	for _, aQuestInfo in ipairs(X.GetActivityQuest('DAILY_BIG_WAR')) do
		local info = me.GetQuestTraceInfo(aQuestInfo[1])
		if info then
			local finished = false
			if info.finish then
				finished = true
			elseif not X.IsEmpty(info.quest_state) then
				finished = true
				for _, state in ipairs(info.quest_state) do
					if state.need ~= state.have then
						finished = false
					end
				end
			end
			if finished then
				return true
			end
		end
	end
end

-- 大战没交
X.RegisterFrameCreate('ExitPanel', 'BIG_WAR_CHECK', function(name, frame)
	local me = X.GetClientPlayer()
	if me then
		local ui = X.UI(frame)
		if IsBigWarFinishable(me) then
			OutputWarningMessage('MSG_WARNING_RED', _L['Warning: Bigwar has been finished but not handed yet!'])
			PlaySound(SOUND.UI_SOUND, g_sound.CloseAuction)
			if ui:Children('#Text_MY_Tip'):Count() == 0 then
				ui:Append('Text', { name = 'Text_MY_Tip', y = ui:Height(), w = ui:Width(), color = {255, 255, 0}, font = 199, alignHorizontal = 1})
			end
			ui:Children('#Text_MY_Tip'):Text(_L['Warning: Bigwar has been finished but not handed yet!'])
			local nTick = GetTime()
			local el = ui:Children('#Text_MY_Tip')[1]
			local SCALE_ANIMATE_TIME, SHAKE_ANIMATE_TIME = 200, 200
			X.RenderCall(function()
				if not X.IsElement(el) then
					return 0
				end
				local nTime = GetTime() - nTick
				if nTime >= SCALE_ANIMATE_TIME then
					el:SetFontScale(1)
					ui:Children('#Text_MY_Tip'):Shake(10, 10, 10, SHAKE_ANIMATE_TIME)
					return 0
				end
				el:SetFontScale((1 - nTime / SCALE_ANIMATE_TIME) * 6 + 1)
			end)
		else
			ui:Children('#Text_MY_Tip'):Remove()
		end
	end
end)
X.RegisterFrameCreate('OptionPanel', 'BIG_WAR_CHECK', function(name, frame)
	local me = X.GetClientPlayer()
	if me then
		local ui = X.UI(frame)
		if IsBigWarFinishable(me) then
			if ui:Children('#Text_MY_Tip'):Count() == 0 then
				ui:Append('Text', { name = 'Text_MY_Tip', y = -20, w = ui:Width(), color = {255, 255, 0}, font = 199, alignHorizontal = 1})
			end
			ui:Children('#Text_MY_Tip')
				:Text(_L['Warning: Bigwar has been finished but not handed yet!'])
				:Shake(10, 10, 10, 1000)
		else
			ui:Children('#Text_MY_Tip'):Remove()
		end
	end
end)

local TASK_STATE = {
	ACCEPTABLE = 1,
	ACCEPTED = 2,
	FINISHABLE = 3,
	FINISHED = 4,
	UNACCEPTABLE = 5,
	UNKNOWN = 6,
}
local function GetTaskState(me, dwQuestID, dwNpcTemplateID)
	-- 获取身上任务状态 -1: 任务id非法 0: 任务不存在 1: 任务正在进行中 2: 任务完成但还没有交 3: 任务已完成
	local nState = me.GetQuestPhase(dwQuestID)
	if nState == 1 then
		return TASK_STATE.ACCEPTED
	end
	if nState == 2 then
		return TASK_STATE.FINISHABLE
	end
	if nState == 3 then
		return TASK_STATE.FINISHED
	end
	-- 获取任务状态
	if me.GetQuestState(dwQuestID) == QUEST_STATE.FINISHED then
		return TASK_STATE.FINISHED
	end
	-- 获取是否可接
	local eCanAccept = me.CanAcceptQuest(dwQuestID, dwNpcTemplateID)
	if eCanAccept == QUEST_RESULT.SUCCESS then
		return TASK_STATE.ACCEPTABLE
	end
	if eCanAccept == QUEST_RESULT.ALREADY_ACCEPTED then
		return TASK_STATE.ACCEPTED
	end
	if eCanAccept == QUEST_RESULT.FINISHED_MAX_COUNT then
		return TASK_STATE.FINISHED
	end
	-- local KQuestInfo = GetQuestInfo(dwQuestID)
	-- if KQuestInfo.bRepeat then -- 可重复任务没到达上限一定可接（有时候地图不对会误判不可接受）
	-- 	return TASK_STATE.ACCEPTABLE
	-- end
	-- if eCanAccept == QUEST_RESULT.FAILED then
	-- 	return TASK_STATE.UNACCEPTABLE
	-- end
	return TASK_STATE.UNKNOWN
end

X.RegisterEvent('LOADING_END', 'MY_BigWarChecker', function()
	if X.IS_REMAKE then
		return
	end
	local me = X.GetClientPlayer()
	local dwMapID = me.GetMapID()
	-- 分析大战本状态数据
	local aQuestInfo = {}
	for _, v in ipairs(X.GetActivityQuest('DAILY_BIG_WAR')) do
		local tMap = {}
		local szPos = Table_GetQuestPosInfo(v[1], 'quest_state', 1)
		local szMaps = szPos and szPos:match('N ([%d|]+),')
		if szMaps then
			for _, szMap in ipairs(X.SplitString(szMaps, '|')) do
				local dwMap = szMap and tonumber(szMap)
				if dwMap then
					tMap[dwMap] = true
				end
			end
		end
		table.insert(aQuestInfo, {
			dwQuestID = v[1],
			dwNpcTemplateID = v[2],
			tMap = tMap,
			eState = GetTaskState(me, v[1], v[2]),
		})
	end
	-- 分析一些不需要提示的情况
	for _, v in ipairs(aQuestInfo) do
		-- 如果完成了大战直接返回
		if v.eState == TASK_STATE.FINISHED or v.eState == TASK_STATE.FINISHABLE then
			return
		end
		-- 如果有可接的大战但是不在这个地图则返回
		if v.eState == TASK_STATE.ACCEPTABLE and not v.tMap[dwMapID] then
			return
		end
	end
	-- 否则如果没接当前地图大战就报警
	for _, v in ipairs(aQuestInfo) do
		if v.tMap[dwMapID] and v.eState ~= TASK_STATE.ACCEPTED and v.eState ~= TASK_STATE.FINISHED then
			local function fnAction()
				OutputWarningMessage('MSG_WARNING_RED', _L['This map is big war map and you did not accepted the quest, is that correct?'])
				PlaySound(SOUND.UI_SOUND, g_sound.CloseAuction)
			end
			X.DelayCall(10000, fnAction)
			fnAction()
			return
		end
	end
end)

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_BigWarChecker',
	exports = {
		{
			fields = {
				'OnPanelActivePartial',
			},
			root = D,
		},
		{
			fields = {
				'bEnable',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bEnable',
			},
			root = O,
		},
	},
}
MY_BigWarChecker = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
