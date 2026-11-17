--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 成就查询
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_AchievementWiki'
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

local O = X.CreateUserSettingsModule('MY_AchievementWiki', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AchievementWiki'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	nW = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AchievementWiki'],
			_L['UI Width'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 850,
	},
	nH = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AchievementWiki'],
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

function D.Open(dwAchievement)
	local achi = X.GetAchievement(dwAchievement)
	if not achi then
		return
	end
	local szURL = MY_RSS.PAGE_BASE_URL .. '/wiki/' .. dwAchievement .. '?'
		.. X.EncodeQuerystring(X.ConvertToUTF8({
			l = X.ENVIRONMENT.GAME_LANG,
			L = X.ENVIRONMENT.GAME_EDITION,
			player = X.GetClientPlayerName(),
		}))
	local szKey = 'AchievementWiki_' .. dwAchievement
	local szTitle = achi.szName .. ' - ' .. achi.szDesc
	szKey = X.UI.OpenBrowser(szURL, {
		key = szKey,
		title = szTitle,
		w = O.nW, h = O.nH,
		readonly = true,
	})
	X.UI(X.UI.LookupBrowser(szKey)):Size(D.OnWebSizeChange)
end

function D.OnAchieveItemMouseEnter()
	if O.bEnable then
		this:SetObjectMouseOver(true)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local xml = {}
		table.insert(xml, GetFormatText(_L['Click for achievement wiki'], 41))
		if IsCtrlKeyDown() then
			local h = this:GetParent()
			local t = {}
			for k, v in pairs(h) do
				if k ~= '___id' and k ~= '___type' then
					table.insert(t, k .. ': ' .. X.EncodeLUAData(v, '  '))
				end
			end
			table.insert(xml, GetFormatText('\n\n' .. g_tStrings.DEBUG_INFO_ITEM_TIP .. '\n', 102))
			table.insert(xml, GetFormatText(table.concat(t, '\n'), 102))
		end
		OutputTip(table.concat(xml), 300, { x, y, w, h })
	end
end

function D.OnAchieveItemMouseLeave()
	if O.bEnable then
		this:SetObjectMouseOver(false)
		HideTip()
	end
end

function D.OnAchieveItemLButtonClick()
	local name = this:GetName()
	if name == 'Box_AchiBox' and O.bEnable then
		D.Open(this:GetParent().dwAchievement)
	end
end

function D.OnAchieveAppendItem(res, hList)
	local hItem = res[1]
	if not hItem then
		return
	end
	local boxAchi = hItem:Lookup('Box_AchiBox') or hItem:Lookup('Box_AchiBoxShort')
	local txtName = hItem:Lookup('Text_AchiName')
	local txtDescribe = hItem:Lookup('Text_AchiDescribe')
	if not boxAchi or not txtName or not txtDescribe then
		return
	end
	boxAchi:RegisterEvent(ITEM_EVENT.LBUTTONCLICK)
	boxAchi:RegisterEvent(ITEM_EVENT.MOUSEENTERLEAVE)
	UnhookTableFunc(boxAchi, 'OnItemMouseEnter', D.OnAchieveItemMouseEnter)
	UnhookTableFunc(boxAchi, 'OnItemMouseLeave', D.OnAchieveItemMouseLeave)
	UnhookTableFunc(boxAchi, 'OnItemLButtonClick', D.OnAchieveItemLButtonClick)
	HookTableFunc(boxAchi, 'OnItemMouseEnter', D.OnAchieveItemMouseEnter)
	HookTableFunc(boxAchi, 'OnItemMouseLeave', D.OnAchieveItemMouseLeave)
	HookTableFunc(boxAchi, 'OnItemLButtonClick', D.OnAchieveItemLButtonClick)
end

function D.HookAchieveHandle(h)
	if not h then
		return
	end
	for i = 0, h:GetItemCount() - 1 do
		D.OnAchieveAppendItem({h:Lookup(i)}, h)
	end
	HookTableFunc(h, 'AppendItemFromData', D.OnAchieveAppendItem, { bAfterOrigin = true, bPassReturn = true })
end

function D.HookAchieveFrame(frame)
	D.HookAchieveHandle(frame:Lookup('PageSet_Achievement/Page_Achievement/WndScroll_AShow', ''))
	D.HookAchieveHandle(frame:Lookup('PageSet_Achievement/Page_TopRecord/WndScroll_TRShow', ''))
	D.HookAchieveHandle(frame:Lookup('PageSet_Achievement/Page_Summary/WndContainer_AchiPanel/PageSet_Achi/Page_Chi/PageSet_RecentAchi/Page_Scene', ''))
	D.HookAchieveHandle(frame:Lookup('PageSet_Achievement/Page_Summary/WndContainer_AchiPanel/PageSet_Achi/Page_Chi/PageSet_RecentAchi/Page_AlmostFinish', ''))
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Achievement wiki'],
		tip = {
			render = _L['Click icon on achievemnt panel to view achievement wiki'],
			position = X.UI.TIP_POSITION.BOTTOM_TOP,
		},
		checked = MY_AchievementWiki.bEnable,
		onCheck = function(bChecked)
			MY_AchievementWiki.bEnable = bChecked
		end,
	}):Width() + 5
	return nX, nY
end


--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_AchievementWiki',
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
MY_AchievementWiki = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterInit('MY_AchievementWiki', function()
	local frame = Station.Lookup('Normal/AchievementPanel')
	if not frame then
		return
	end
	D.HookAchieveFrame(frame)
end)

X.RegisterFrameCreate('AchievementPanel', 'MY_AchievementWiki', function(name, frame)
	D.HookAchieveFrame(frame)
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
