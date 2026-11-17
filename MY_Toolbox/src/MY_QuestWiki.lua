--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 任务百科
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_QuestWiki'
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

local O = X.CreateUserSettingsModule('MY_QuestWiki', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_QuestWiki'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	nW = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_QuestWiki'],
			_L['UI Width'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 850,
	},
	nH = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_QuestWiki'],
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

function D.Open(dwQuest)
	local quest = Table_GetQuestStringInfo(dwQuest)
	if not quest then
		return
	end
	local szURL = MY_RSS.PAGE_BASE_URL .. '/quest/' .. dwQuest .. '?'
		.. X.EncodeQuerystring(X.ConvertToUTF8({
			l = X.ENVIRONMENT.GAME_LANG,
			L = X.ENVIRONMENT.GAME_EDITION,
			player = X.GetClientPlayerName(),
		}))
	local szKey = 'QuestWiki_' .. dwQuest
	local szTitle = quest.szName
	szKey = X.UI.OpenBrowser(szURL, {
		key = szKey,
		title = szTitle,
		w = O.nW, h = O.nH,
		readonly = true,
	})
	X.UI(X.UI.LookupBrowser(szKey)):Size(D.OnWebSizeChange)
end

function D.OnHookPointMouseEnter()
	this:SetFrame(37)
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	local xml = {}
	table.insert(xml, GetFormatText(_L['Click for quest wiki'], 41))
	if IsCtrlKeyDown() then
		local h = this:GetRoot()
		local t = {}
		for k, v in pairs(h) do
			if k ~= '___id' and k ~= '___type' and not X.IsFunction(v) then
				table.insert(t, k .. ': ' .. X.EncodeLUAData(v, '  '))
			end
		end
		table.insert(xml, GetFormatText('\n\n' .. g_tStrings.DEBUG_INFO_ITEM_TIP .. '\n', 102))
		table.insert(xml, GetFormatText(table.concat(t, '\n'), 102))
	end
	OutputTip(table.concat(xml), 300, { x, y, w, h })
end

function D.OnHookPointMouseLeave()
	this:SetFrame(36)
	HideTip()
end

function D.OnHookPointLButtonClick()
	local frame = this:GetRoot()
	D.Open(frame.dwQuest or frame.dwQuestID)
end

function D.GetQuestPanelHookPoint()
	local frame = Station.SearchFrame('QuestPanel')
	if not frame then
		return
	end
	local h = frame:Lookup('', 'Handle_TraceInfo')
	if not h then
		return
	end
	return h, h:Lookup('MY_QuestWiki'), frame:Lookup('Btn_Raider')
end

function D.HookQuestPanel()
	local h, img, btn = D.GetQuestPanelHookPoint()
	if not h or img then
		return
	end
	if btn then
		btn:SetRelX(569)
	end
	h:AppendItemFromString('<image>w=25 h=25 x=302 y=3 alpha=200 name="MY_QuestWiki" eventid=789 path="ui/Image/button/FrendNPartyButton.UITex" frame=36</image>')
	h:FormatAllItemPos()
	img = h:Lookup('MY_QuestWiki')
	img.OnItemMouseEnter = D.OnHookPointMouseEnter
	img.OnItemMouseLeave = D.OnHookPointMouseLeave
	img.OnItemLButtonClick = D.OnHookPointLButtonClick
end

function D.UnhookQuestPanel()
	local h, img, btn = D.GetQuestPanelHookPoint()
	if not h or not img then
		return
	end
	if btn then
		btn:SetRelX(604)
	end
	h:RemoveItem(img)
end

function D.GetNewQuestPanelHookPoint()
	local frame = Station.SearchFrame('NewQuestPanel')
	if not frame then
		return
	end
	local h = frame:Lookup('Wnd_Quest', 'Handle_TraceInfo')
	if not h then
		return
	end
	return h, h:Lookup('MY_QuestWiki')
end

function D.HookNewQuestPanel()
	local h, img = D.GetNewQuestPanelHookPoint()
	if not h or img then
		return
	end
	h:AppendItemFromString('<image>w=30 h=30 x=455 alpha=180 name="MY_QuestWiki" eventid=789 path="ui/Image/button/FrendNPartyButton.UITex" frame=36</image>')
	h:FormatAllItemPos()
	img = h:Lookup('MY_QuestWiki')
	img.OnItemMouseEnter = D.OnHookPointMouseEnter
	img.OnItemMouseLeave = D.OnHookPointMouseLeave
	img.OnItemLButtonClick = D.OnHookPointLButtonClick
end

function D.UnhookNewQuestPanel()
	local h, img = D.GetNewQuestPanelHookPoint()
	if not h or not img then
		return
	end
	h:RemoveItem(img)
end

function D.CheckHook()
	if O.bEnable then
		D.HookQuestPanel()
		D.HookNewQuestPanel()
	else
		D.UnhookQuestPanel()
		D.UnhookNewQuestPanel()
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Quest wiki'],
		tip = {
			render = _L['Click help icon on quest panel to view quest wiki'],
			position = X.UI.TIP_POSITION.BOTTOM_TOP,
		},
		checked = MY_QuestWiki.bEnable,
		onCheck = function(bChecked)
			MY_QuestWiki.bEnable = bChecked
		end,
	}):Width() + 5
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_QuestWiki',
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
			triggers = {
				bEnable = D.CheckHook,
			},
			root = O,
		},
	},
}
MY_QuestWiki = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterInit('MY_QuestWiki', function()
	D.CheckHook()
end)

X.RegisterReload('MY_QuestWiki', function()
	D.UnhookQuestPanel()
	D.UnhookNewQuestPanel()
end)

X.RegisterFrameCreate('QuestPanel', 'MY_QuestWiki', function(name, frame)
	D.CheckHook()
end)

X.RegisterFrameCreate('NewQuestPanel', 'MY_QuestWiki', function(name, frame)
	D.CheckHook()
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
