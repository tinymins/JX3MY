--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 试炼之地九宫助手
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_LockFrame'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_LockFrame'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_LockFrame', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_LockFrame'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	tEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_LockFrame'],
			_L['Lock frame position list'],
		}),
		xSchema = X.Schema.Map(X.Schema.String, X.Schema.Boolean),
		xDefaultValue = {
			['JX_TargetList'] = true,
			['MY_FocusUI'] = true,
			['WhoSeeMe'] = true,
			['HatredPanel'] = true,
			['FightingStatistic'] = true,
			['MY_ThreatRank'] = true,
			['MY_Recount_UI'] = true,
			['LR_AS_FP'] = true,
			['QuestTraceList'] = true,
			['ChatPanel'] = true,
			['DynamicActionBar'] = true,
			['ExteriorAction'] = true,
			['MentorMessage'] = true,
			['JX_TeamCD'] = true,
			['JX_HeightMeter'] = true,
			['Matrix'] = true,
		},
	},
})
local D = {
	bTempDisable = false,
	tLockList = {
		'WhoSeeMe',
		'HatredPanel',
		'FightingStatistic',
		'QuestTraceList',
		'ChatPanel',
		'Matrix',
		'ExteriorAction',
		'MentorMessage',
		'DynamicActionBar',
		'JX_TeamCD',
		'JX_HeightMeter',
		'JX_TargetList',
		'MY_FocusUI',
		'MY_ThreatRank',
		'MY_Recount_UI',
	},
	tLockID = (function()
		local t = {
			['JX_TargetList'] = 'JX_TargetList', -- 剑心·焦点列表 [Normal/JX_TargetList]
			['MY_FocusUI'] = 'MY_FocusUI', -- 茗伊·焦点列表 [Normal/MY_FocusUI]
			['WhoSeeMe'] = 'WhoSeeMe', -- 谁在看我 [Normal/WhoSeeMe]
			['HatredPanel'] = 'HatredPanel', -- 仇恨列表 [Normal/HatredPanel]
			['FightingStatistic'] = 'FightingStatistic', -- 伤害统计 [Normal/FightingStatistic]
			['MY_ThreatRank'] = 'MY_ThreatRank', -- 茗伊·仇恨统计 [Normal/MY_ThreatRank]
			['MY_Recount_UI'] = 'MY_Recount_UI', -- 茗伊·伤害统计 [Normal/MY_Recount_UI]
			['QuestTraceList'] = 'QuestTraceList', -- 任务追踪 [Normal/QuestTraceList]
			['Matrix'] = 'Matrix', -- 阵法界面 [Normal/Matrix]
			['DynamicActionBar'] = 'DynamicActionBar', -- 动态技能栏 [Lowest1/DynamicActionBar]
			['ExteriorAction'] = 'ExteriorAction', -- 外装动作 [Normal/ExteriorAction]
			['MentorMessage'] = 'MentorMessage', -- 师徒提示 [Normal/MentorMessage]
			['JX_TeamCD'] = 'JX_TeamCD', -- 剑心·团队技能监控 [Normal/JX_TeamCD]
			['JX_HeightMeter'] = 'JX_HeightMeter', -- 剑心·高度标线 [Normal/JX_HeightMeter]
		}
		for _, k in X.pairs_c(X.CONSTANT.CHAT_PANEL_INDEX_LIST) do
			t['ChatPanel' .. k] = 'ChatPanel' .. k -- 聊天面板 [Lowest2/ChatPanel1]
		end
		return t
	end)(),
}

local HOOKED_UI = setmetatable({}, { __mode = 'k' })
local UI_DRAGABLE = setmetatable({}, { __mode = 'k' })
local function EnableDrag(frame, bEnable)
	UI_DRAGABLE[frame] = bEnable
end
local function IsDragable(frame)
	return UI_DRAGABLE[frame] or false
end
function D.LockFrame(frame)
	if not HOOKED_UI[frame] then
		HOOKED_UI[frame] = true
		UI_DRAGABLE[frame] = frame:IsDragable()
		frame:EnableDrag(false)
		HookTableFunc(frame, 'EnableDrag', EnableDrag, { bDisableOrigin = true })
		HookTableFunc(frame, 'IsDragable', IsDragable, { bDisableOrigin = true, bHookReturn = true })
	end
end
function D.UnlockFrame(frame)
	if HOOKED_UI[frame] then
		UnhookTableFunc(frame, 'EnableDrag', EnableDrag)
		UnhookTableFunc(frame, 'IsDragable', IsDragable)
		frame:EnableDrag(UI_DRAGABLE[frame])
		HOOKED_UI[frame] = nil
		UI_DRAGABLE[frame] = nil
	end
end

function D.IsFrameLock(frame)
	if not D.bReady or not O.bEnable or D.bTempDisable or not frame then
		return false
	end
	local szLock = D.tLockID[frame:GetName()]
	return szLock and O.tEnable[szLock] ~= false
end

function D.CheckFrame(frame)
	local bLock = D.IsFrameLock(frame)
	if bLock then
		D.LockFrame(frame)
	else
		D.UnlockFrame(frame)
	end
end

function D.CheckAllFrame()
	for _, szLayer in ipairs({'Lowest', 'Lowest1', 'Lowest2', 'Normal', 'Normal1', 'Normal2', 'Topmost', 'Topmost1', 'Topmost2'})do
		local frmIter = Station.Lookup(szLayer)
		if frmIter then
			frmIter = frmIter:GetFirstChild()
		end
		while frmIter do
			local bLock = D.IsFrameLock(frmIter)
			if bLock then
				D.LockFrame(frmIter)
			else
				D.UnlockFrame(frmIter)
			end
			frmIter = frmIter:GetNext()
		end
	end
	if D.bReady and O.bEnable then
		X.RegisterEvent('ON_FRAME_CREATE', 'MY_LockFrame', function()
			D.CheckFrame(arg0)
		end)
		X.RegisterSpecialKeyEvent('*', 'MY_LockFrame', function()
			if IsCtrlKeyDown() and (IsShiftKeyDown() or IsAltKeyDown()) then
				if not D.bTempDisable then
					X.OutputAnnounceMessage(_L['MY_LockFrame has been temporary disabled.'])
					D.bTempDisable = true
					D.CheckAllFrame()
				end
			else
				if D.bTempDisable then
					X.OutputAnnounceMessage(_L['MY_LockFrame has been enabled.'])
					D.bTempDisable = false
					D.CheckAllFrame()
				end
			end
		end)
	else
		X.RegisterEvent('ON_FRAME_CREATE', 'MY_LockFrame', false)
		X.RegisterSpecialKeyEvent('*', 'MY_LockFrame', false)
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	ui:Append('WndComboBox', {
		x = nW - 140, y = 65,
		text = _L['Lock frame position'],
		menu = function()
			local t = {
				{
					szOption = _L['Enable (press ctrl+alt to temp unlock)'],
					bCheck = true, bChecked = MY_LockFrame.bEnable,
					fnAction = function(_, b)
						MY_LockFrame.bEnable = b
						D.CheckAllFrame()
					end,
				}, X.CONSTANT.MENU_DIVIDER,
			}
			for _, k in ipairs(D.tLockList) do
				table.insert(t, {
					szOption = _L['LOCK_FRAME_' .. k],
					bCheck = true, bChecked = MY_LockFrame.tEnable[k] ~= false,
					fnAction = function(_, b)
						MY_LockFrame.tEnable[k] = b
						MY_LockFrame.tEnable = MY_LockFrame.tEnable
					end,
					fnDisable = function()
						return not MY_LockFrame.bEnable
					end,
				})
			end
			return t
		end,
	})
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_LockFrame',
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
				'tEnable',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bEnable',
				'tEnable',
			},
			triggers = {
				bEnable = D.CheckAllFrame,
				tEnable = D.CheckAllFrame,
			},
			root = O,
		},
	},
}
MY_LockFrame = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_LockFrame', function()
	D.bReady = true
	D.CheckAllFrame()
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
