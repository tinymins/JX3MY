--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 密码锁解锁提醒
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_MibaoHelper'
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

local O = X.CreateUserSettingsModule('MY_MibaoHelper', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_MibaoHelper'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}

function D.OnInit()
	-- 刚进游戏好像获取不到锁状态 20秒之后再说吧
	X.DelayCall('MY_LOCK_TIP_DELAY', 20000, function()
		if not X.IsPhoneLock() and X.GetClientPlayer() then -- 手机密保还提示个鸡
			local state, nResetTime = Lock_State()
			if state == 'PASSWORD_LOCK' then
				X.DelayCall('MY_LOCK_TIP', 100000, function()
					local state, nResetTime = Lock_State()
					if state == 'PASSWORD_LOCK' then
						local szGlobalID = X.GetClientPlayerGlobalID()
						local szText = szGlobalID and _L.LOCK_TIP[szGlobalID] or _L['You have been loged in for 2min, you can unlock bag locker now.']
						X.OutputSystemMessage(szText)
						OutputWarningMessage('MSG_REWARD_GREEN', szText, 10)
					end
				end)
			end
		end
	end)
end
X.RegisterInit('MY_MibaoHelper', D.OnInit)

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_MibaoHelper',
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
MY_MibaoHelper = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
