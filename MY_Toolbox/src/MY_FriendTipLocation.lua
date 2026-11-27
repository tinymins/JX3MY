--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 好友界面显示所有好友位置
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_FriendTipLocation'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_FriendTipLocation'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
X.RegisterRestriction('MY_FriendTipLocation', { ['*'] = false })
X.RegisterRestriction('MY_FriendTipLocation.LV2', { ['*'] = true })
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_FriendTipLocation', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_FriendTipLocation'],
			_L['Enable'],
		}),
		szRestriction = 'MY_FriendTipLocation',
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
})
local D = {}

function D.Hook()
	local frame = Station.Lookup('Normal/FriendTip')
	if not frame then
		return
	end
	local me = X.GetClientPlayer()
	if not me then
		return
	end
	local txtName = frame:Lookup('', 'Text_Name')
	local txtTitle = frame:Lookup('Wnd_Friend', 'Text_WhereT')
	local txtLocation = frame:Lookup('Wnd_Friend', 'Text_Where')
	if not (txtName and txtTitle and txtLocation) then
		return
	end
	if not txtLocation.__MY_SetText then
		txtLocation.__MY_SetText = txtLocation.SetText
		txtLocation.SetText = function(_, szText)
			local tFellowship = txtName and X.GetFellowshipInfo(txtName:GetText())
			local tFei = tFellowship and X.GetFellowshipEntryInfo(tFellowship.xID)
			if tFei and ((X.IsFellowshipTwoWay(tFellowship.xID) and tFellowship.nAttraction >= 200) or not X.IsRestricted('MY_FriendTipLocation.LV2')) then
				szText = Table_GetMapName(X.GetFellowshipMapID(tFellowship.xID))
				if (me.nCamp == CAMP.EVIL and tFei.nCamp == CAMP.GOOD)
				or (me.nCamp == CAMP.GOOD and tFei.nCamp == CAMP.EVIL) then
					szText = szText .. _L['(Different camp)']
				end
			end
			txtLocation:__MY_SetText(szText)
		end
	end
end

function D.Unhook()
	X.UI.CloseFrame('FriendTip')
end

function D.CheckEnable()
	if D.bReady and O.bEnable and not X.IsRestricted('MY_FriendTipLocation') then
		D.Hook()
		X.RegisterFrameCreate('FriendTip', 'MY_FriendTipLocation', D.Hook)
	else
		D.Unhook()
		X.RegisterFrameCreate('FriendTip', 'MY_FriendTipLocation', false)
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	if not X.IsRestricted('MY_FriendTipLocation') then
		nX = nX + ui:Append('WndCheckBox', {
			x = nX, y = nY,
			text = _L['Show all friend tip location'],
			checked = MY_FriendTipLocation.bEnable,
			onCheck = function(bChecked)
				MY_FriendTipLocation.bEnable = bChecked
			end,
		}):AutoWidth():Width() + 5
	end
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_FriendTipLocation',
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
			triggers = {
				bEnable = D.CheckEnable,
			},
			root = O,
		},
	},
}
MY_FriendTipLocation = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_FriendTipLocation', function()
	D.bReady = true
	D.CheckEnable()
end)
X.RegisterReload('MY_FriendTipLocation', D.Unhook)
X.RegisterEvent('MY_RESTRICTION', 'MY_FriendTipLocation', function()
	if arg0 and arg0 ~= 'MY_FriendTipLocation' then
		return
	end
	D.CheckEnable()
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
