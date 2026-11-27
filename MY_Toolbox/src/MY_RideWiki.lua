--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 宠物百科
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_RideWiki'
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

local O = X.CreateUserSettingsModule('MY_RideWiki', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_RideWiki'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	nW = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_RideWiki'],
			_L['UI Width'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 850,
	},
	nH = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_RideWiki'],
			_L['UI Height'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 610,
	},
})
local D = {}

function D.OnWebSizeChange()
	if X.UI(this):FrameVisualState() == X.UI.FRAME_VISUAL_STATE.NORMAL then
		O.nW, O.nH = this:GetSize()
	end
end

function D.Open(dwTabType, dwTabIndex)
	local item = GetItemInfo(dwTabType, dwTabIndex)
	if not item then
		return
	end
	local szURL = MY_RSS.PAGE_BASE_URL .. '/ride/' .. dwTabType .. '/' .. dwTabIndex .. '?'
		.. X.EncodeQuerystring(X.ConvertToUTF8({
			l = X.ENVIRONMENT.GAME_LANG,
			L = X.ENVIRONMENT.GAME_EDITION,
			player = X.GetClientPlayerName(),
		}))
	local szKey = 'RideWiki_' .. dwTabType .. '_' .. dwTabIndex
	local szTitle = item.szName
	szKey = X.UI.OpenBrowser(szURL, {
		key = szKey,
		title = szTitle,
		w = O.nW, h = O.nH,
		readonly = true,
	})
	X.UI(X.UI.LookupBrowser(szKey)):Size(D.OnWebSizeChange)
end

function D.HookPlayerViewFrame(frame)
	----------------
	-- 怀旧版
	----------------

	----------------
	-- 重制版
	----------------
	local box = frame:Lookup('Page_Main/Page_Ride', 'Box_RideBox')
	if box then
		local function OnRideItemLButtonClick()
			if O.bEnable and not IsCtrlKeyDown() and not IsAltKeyDown() then
				local _, _, dwBox, dwBoxIndex, dwPlayerID = this:GetObject()
				local tar = X.GetPlayer(dwPlayerID)
				if tar then
					local item = X.GetInventoryItem(tar, dwBox, dwBoxIndex)
					if item then
						D.Open(item.dwTabType, item.dwIndex)
					end
				end
				return
			end
			return X.UI.FormatUIEventMask(false, true)
		end
		X.SetMemberFunctionHook(
			box,
			'OnItemLButtonClick',
			'MY_RideWiki',
			OnRideItemLButtonClick,
			{ bAfterOrigin = true, bPassReturn = true, bHookReturn = true })
		box:RegisterEvent(ITEM_EVENT.LBUTTONCLICK)
	end
end

X.RegisterInit('MY_RideWiki', function()
	local frame = Station.Lookup('Normal/PlayerView')
	if not frame then
		return
	end
	D.HookPlayerViewFrame(frame)
end)

X.RegisterFrameCreate('PlayerView', 'MY_RideWiki', function(name, frame)
	D.HookPlayerViewFrame(frame)
end)

function D.HookHorsePanel(frame)
	----------------
	-- 怀旧版
	----------------

	----------------
	-- 重制版
	----------------
	local hList = frame:Lookup('PageSet_All/Page_Horse/WndScroll_Horse', '')
	if hList then
		local function OnRideItemLButtonClick()
			if O.bEnable and not IsCtrlKeyDown() and not IsAltKeyDown() then
				local _, _, dwBox, dwBoxIndex = this:GetObject()
				local tar = X.GetClientPlayer()
				if tar then
					local item = X.GetInventoryItem(tar, dwBox, dwBoxIndex)
					if item then
						D.Open(item.dwTabType, item.dwIndex)
					end
				end
				return
			end
			return X.UI.FormatUIEventMask(false, true)
		end
		X.UI.HookHandleAppend(hList, function(_, hItem)
			local box = hItem:Lookup('Box_Horse')
			if box then
				X.SetMemberFunctionHook(
					box,
					'OnItemLButtonClick',
					'MY_RideWiki',
					OnRideItemLButtonClick,
					{ bAfterOrigin = true, bPassReturn = true, bHookReturn = true })
				box:RegisterEvent(ITEM_EVENT.LBUTTONCLICK)
			end
		end)
	end

	local hList = frame:Lookup('PageSet_All/Page_Qiqu/WndScroll_Qiqu', '')
	if hList then
		local function OnRideItemLButtonClick()
			if O.bEnable and not IsCtrlKeyDown() and not IsAltKeyDown() then
				local _, _, dwBox, dwBoxIndex = this:GetObject()
				local tar = X.GetClientPlayer()
				if tar then
					local item = X.GetInventoryItem(tar, dwBox, dwBoxIndex)
					if item then
						D.Open(item.dwTabType, item.dwIndex)
					end
				end
				return
			end
			return X.UI.FormatUIEventMask(false, true)
		end
		X.UI.HookHandleAppend(hList, function(_, hItem)
			local box = hItem:Lookup('Box_Qiqu')
			if box then
				X.SetMemberFunctionHook(
					box,
					'OnItemLButtonClick',
					'MY_RideWiki',
					OnRideItemLButtonClick,
					{ bAfterOrigin = true, bPassReturn = true, bHookReturn = true })
				box:RegisterEvent(ITEM_EVENT.LBUTTONCLICK)
			end
		end)
	end
end

X.RegisterInit('MY_RideWiki', function()
	local frame = Station.Lookup('Normal/HorsePanel')
	if not frame then
		return
	end
	D.HookHorsePanel(frame)
end)

X.RegisterFrameCreate('HorsePanel', 'MY_RideWiki', function(name, frame)
	D.HookHorsePanel(frame)
end)

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Ride wiki'],
		tip = {
			render = _L['Click icon on ride panel to view ride wiki'],
			position = X.UI.TIP_POSITION.BOTTOM_TOP,
		},
		checked = MY_RideWiki.bEnable,
		onCheck = function(bChecked)
			MY_RideWiki.bEnable = bChecked
		end,
	}):Width() + 5
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_RideWiki',
	exports = {
		{
			fields = {
				'Open',
				'OnPanelActivePartial',
			},
			root = D,
		},
		{
			fields = {
				'bEnable',
				'nW',
				'nH',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bEnable',
				'nW',
				'nH',
			},
			root = O,
		},
	},
}
MY_RideWiki = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
