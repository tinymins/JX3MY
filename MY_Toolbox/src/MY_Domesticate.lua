--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 驯养饥饿报警
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_Domesticate'
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

local O = X.CreateUserSettingsModule('MY_Domesticate', _L['General'], {
	bAlert = {
		ePathType = X.PATH_TYPE.ROLE,
		eDefaultLocationOverride = X.CONSTANT.USER_SETTINGS_LOCATION_OVERRIDE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_Domesticate'],
			_L['Domesticate feed alert'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	nAlertNum = {
		ePathType = X.PATH_TYPE.ROLE,
		eDefaultLocationOverride = X.CONSTANT.USER_SETTINGS_LOCATION_OVERRIDE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_Domesticate'],
			_L['Alert when measure'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 100,
	},
	dwAutoFeedCubTabType = {
		ePathType = X.PATH_TYPE.ROLE,
		eDefaultLocationOverride = X.CONSTANT.USER_SETTINGS_LOCATION_OVERRIDE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_Domesticate'],
			_L['AutoFeedCubTabType'],
		}),
		xSchema = X.Schema.Optional(X.Schema.Number),
		xDefaultValue = nil,
	},
	dwAutoFeedCubTabIndex = {
		ePathType = X.PATH_TYPE.ROLE,
		eDefaultLocationOverride = X.CONSTANT.USER_SETTINGS_LOCATION_OVERRIDE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_Domesticate'],
			_L['AutoFeedCubTabIndex'],
		}),
		xSchema = X.Schema.Optional(X.Schema.Number),
		xDefaultValue = nil,
	},
	dwAutoFeedFoodTabType = {
		ePathType = X.PATH_TYPE.ROLE,
		eDefaultLocationOverride = X.CONSTANT.USER_SETTINGS_LOCATION_OVERRIDE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_Domesticate'],
			_L['AutoFeedFoodTabType'],
		}),
		xSchema = X.Schema.Optional(X.Schema.Number),
		xDefaultValue = nil,
	},
	dwAutoFeedFoodTabIndex = {
		ePathType = X.PATH_TYPE.ROLE,
		eDefaultLocationOverride = X.CONSTANT.USER_SETTINGS_LOCATION_OVERRIDE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_Domesticate'],
			_L['AutoFeedFoodTabIndex'],
		}),
		xSchema = X.Schema.Optional(X.Schema.Number),
		xDefaultValue = nil,
	},
	nAutoFeedFoodMeasure = {
		ePathType = X.PATH_TYPE.ROLE,
		eDefaultLocationOverride = X.CONSTANT.USER_SETTINGS_LOCATION_OVERRIDE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_Domesticate'],
			_L['AutoFeedFoodMeasure'],
		}),
		xSchema = X.Schema.Optional(X.Schema.Number),
		xDefaultValue = nil,
	},
})
local D = {}

function D.SetAutoFeed(dwAutoFeedCubTabType, dwAutoFeedCubTabIndex, dwAutoFeedFoodTabType, dwAutoFeedFoodTabIndex)
	local bValid
	if dwAutoFeedFoodTabType and dwAutoFeedFoodTabIndex then
		local food = GetItemInfo(dwAutoFeedFoodTabType, dwAutoFeedFoodTabIndex)
		if food then
			local szText = MY.GetPureText(GetItemInfoTip(X.ENVIRONMENT.CURRENT_ITEM_VERSION, dwAutoFeedFoodTabType, dwAutoFeedFoodTabIndex), 'LUA') or ''
			local szVal = szText:match(_L['measure (%d+) point'])
			local nAutoFeedFoodMeasure = szVal and tonumber(szVal)
			if nAutoFeedFoodMeasure then
				O.dwAutoFeedCubTabType = dwAutoFeedCubTabType
				O.dwAutoFeedCubTabIndex = dwAutoFeedCubTabIndex
				O.dwAutoFeedFoodTabType = dwAutoFeedFoodTabType
				O.dwAutoFeedFoodTabIndex = dwAutoFeedFoodTabIndex
				O.nAutoFeedFoodMeasure = nAutoFeedFoodMeasure
				bValid = true
			end
		end
	end
	if not bValid then
		O.dwAutoFeedCubTabType = nil
		O.dwAutoFeedCubTabIndex = nil
		O.dwAutoFeedFoodTabType = nil
		O.dwAutoFeedFoodTabIndex = nil
		O.nAutoFeedFoodMeasure = nil
	end
	D.CheckAutoFeedEnable()
end

function D.IsAutoFeedValid(me)
	if not O.dwAutoFeedCubTabType or not O.dwAutoFeedCubTabIndex
	or not O.dwAutoFeedFoodTabType or not O.dwAutoFeedFoodTabIndex
	or not O.nAutoFeedFoodMeasure then
		return false
	end
	local domesticate = me.GetDomesticate()
	if not domesticate
	or domesticate.dwCubTabType ~= O.dwAutoFeedCubTabType
	or domesticate.dwCubTabIndex ~= O.dwAutoFeedCubTabIndex
	or domesticate.nGrowthLevel == domesticate.nMaxGrowthLevel then
		return false
	end
	return true
end

function D.HookDomesticatePanel()
	local btn = Station.Lookup('Normal/DomesticatePanel/Wnd_Satiation/Btn_Feed')
	local box = Station.Lookup('Normal/DomesticatePanel/Wnd_Satiation', 'Box_Feed')
	if btn and box then
		btn.OnRButtonClick = function()
			local me = X.GetClientPlayer()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local menu = {
				x = x,
				y = y + h,
				nMinWidth = w,
				{
					szOption = _L['Auto feed'],
					bCheck = true, bChecked = D.IsAutoFeedValid(me),
					fnAction = function()
						if D.IsAutoFeedValid(me) then
							D.SetAutoFeed()
							X.OutputSystemAnnounceMessage(_L['Auto feed domesticate cancelled.'])
						else
							local domesticate = X.GetClientPlayer().GetDomesticate()
							local dwCubTabType, dwCubTabIndex = domesticate.dwCubTabType, domesticate.dwCubTabIndex
							local dwFoodTabType, dwFoodTabIndex = select(5, box:GetObjectData())
							if not domesticate then
								return
							end
							D.SetAutoFeed(dwCubTabType, dwCubTabIndex, dwFoodTabType, dwFoodTabIndex)

							local szFoodName = X.GetItemInfoName(dwFoodTabType, dwFoodTabIndex)
							local szDomesticateName = X.GetItemInfoName(dwCubTabType, dwCubTabIndex)
							if D.IsAutoFeedValid(me) then
								X.OutputSystemAnnounceMessage(_L('Set domesticate auto feed %s to %s succeed, will auto feed when hunger point reach %d.',
									szFoodName,
									szDomesticateName,
									O.nAutoFeedFoodMeasure))
							else
								X.OutputSystemAnnounceMessage(_L('Set domesticate auto feed %s to %s failed.', szFoodName, szDomesticateName))
							end
						end
					end,
				},
			}
			X.UI.PopupMenu(menu)
		end
	end
end

function D.UnHookDomesticatePanel()
	local btn = Station.Lookup('Normal/DomesticatePanel/Wnd_Satiation/Btn_Feed')
	if btn then
		btn.OnRButtonClick = nil
	end
end

function D.CheckAutoFeedEnable()
	if D.bReady then
		X.BreatheCall('MY_Domesticate__AutoFeed', 30000, function()
			local me = X.GetClientPlayer()
			if not me then
				return
			end
			if me.bFightState then
				return
			end
			if not D.IsAutoFeedValid(me) then
				return 0
			end
			local domesticate = me.GetDomesticate()
			if not domesticate or domesticate.dwCubTabType == 0 then
				return
			end
			if domesticate.nGrowthLevel >= domesticate.nMaxGrowthLevel then
				local szDomesticate = X.GetItemInfoName(domesticate.dwCubTabType, domesticate.dwCubTabIndex)
				X.OutputSystemAnnounceMessage(_L('Your domesticate %s is growth up!', szDomesticate))
				return
			end
			local nMeasure = domesticate.nMaxFullMeasure - domesticate.nFullMeasure
			local nRound = math.floor(nMeasure / O.nAutoFeedFoodMeasure)
			local bFeed = false
			if nRound == 0 and domesticate.nFullMeasure == 0 then
				nRound = 1
			end
			for _ = 1, nRound do
				X.IterInventoryItem(X.CONSTANT.INVENTORY_TYPE.PACKAGE, function(kItem, dwBox, dwX)
					if kItem.dwTabType == O.dwAutoFeedFoodTabType and kItem.dwIndex == O.dwAutoFeedFoodTabIndex then
						domesticate.Feed(dwBox, dwX)
						bFeed = true
						return 0
					end
				end)
			end
			if nRound > 0 and not bFeed then
				local szFood = X.GetItemInfoName(O.dwAutoFeedFoodTabType, O.dwAutoFeedFoodTabIndex)
				local szDomesticate = X.GetItemInfoName(O.dwAutoFeedCubTabType, O.dwAutoFeedCubTabIndex)
				X.OutputSystemAnnounceMessage(_L('No enough %s to feed %s!', szFood, szDomesticate))
			end
		end)
	else
		X.BreatheCall('MY_Domesticate__AutoFeed', false)
	end
end

function D.CheckAlertEnable()
	if D.bReady and O.bAlert then
		X.BreatheCall('MY_Domesticate__Alert', 60000, function()
			local me = X.GetClientPlayer()
			if not me then
				return
			end
			if me.bFightState then
				return
			end
			local domesticate = me.GetDomesticate()
			if not domesticate or domesticate.dwCubTabType == 0 then
				return
			end
			if domesticate.nGrowthLevel >= domesticate.nMaxGrowthLevel then
				local szDomesticate = X.GetItemInfoName(domesticate.dwCubTabType, domesticate.dwCubTabIndex)
				OutputWarningMessage('MSG_WARNING_YELLOW', _L('Your domesticate %s is growth up!', szDomesticate))
				PlaySound(SOUND.UI_SOUND, g_sound.CloseAuction)
				return
			end
			if O.nAlertNum == 0 then
				if domesticate.nFullMeasure == 0 and domesticate.nGrowthLevel < domesticate.nMaxGrowthLevel then
					local szDomesticate = X.GetItemInfoName(domesticate.dwCubTabType, domesticate.dwCubTabIndex)
					OutputWarningMessage('MSG_WARNING_YELLOW', _L('Your domesticate %s is hungery!', szDomesticate))
					PlaySound(SOUND.UI_SOUND, g_sound.CloseAuction)
				end
			else
				local nMeasure = domesticate.nMaxFullMeasure - domesticate.nFullMeasure
				if nMeasure >= O.nAlertNum and domesticate.nGrowthLevel < domesticate.nMaxGrowthLevel then
					local szDomesticate = X.GetItemInfoName(domesticate.dwCubTabType, domesticate.dwCubTabIndex)
					OutputWarningMessage('MSG_WARNING_YELLOW', _L('Your domesticate %s available measure is %d point!', szDomesticate, nMeasure))
					PlaySound(SOUND.UI_SOUND, g_sound.CloseAuction)
				end
			end
		end)
	else
		X.BreatheCall('MY_Domesticate__Alert', false)
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Domesticate feed alert'],
		checked = O.bAlert,
		onCheck = function(bChecked)
			MY_Domesticate.bAlert = bChecked
		end,
	}):Width() + 5
	ui:Append('WndSlider', {
		x = nX, y = nY, w = 130,
		value = O.nAlertNum,
		range = {0, 1000},
		sliderStyle = X.UI.SLIDER_STYLE.SHOW_VALUE,
		textFormatter = function(val)
			if val == 0 then
				return _L['Alert when measure is empty']
			end
			return _L('Alert when measure larger than %d', val)
		end,
		onChange = function(val)
			O.nAlertNum = val
		end,
		autoEnable = function() return MY_Domesticate.bAlert end,
	})
	nX = nPaddingX
	nY = nY + nLH
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_Domesticate',
	exports = {
		{
			fields = {
				'OnPanelActivePartial',
			},
			root = D,
		},
		{
			fields = {
				'bAlert',
				'nAlertNum',
				'dwAutoFeedCubTabType',
				'dwAutoFeedCubTabIndex',
				'dwAutoFeedFoodTabType',
				'dwAutoFeedFoodTabIndex',
				'nAutoFeedFoodMeasure',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bAlert',
				'nAlertNum',
				'dwAutoFeedCubTabType',
				'dwAutoFeedCubTabIndex',
				'dwAutoFeedFoodTabType',
				'dwAutoFeedFoodTabIndex',
				'nAutoFeedFoodMeasure',
			},
			triggers = {
				bAlert = D.CheckAlertEnable,
			},
			root = O,
		},
	},
}
MY_Domesticate = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_Domesticate', function()
	D.bReady = true
	D.CheckAutoFeedEnable()
	D.CheckAlertEnable()
end)
X.RegisterFrameCreate('DomesticatePanel', 'MY_Domesticate', D.HookDomesticatePanel)
X.RegisterReload('MY_Domesticate', D.UnHookDomesticatePanel)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
