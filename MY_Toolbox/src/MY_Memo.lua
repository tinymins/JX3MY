--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 随身便笺
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_Memo'
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
local ROLE_MEMO = {
	bEnable = false,
	nWidth = 200,
	nHeight = 200,
	szContent = '',
	nFont = 0,
	anchor = { s = 'TOPRIGHT', r = 'TOPRIGHT', x = -310, y = 135 },
}
local GLOBAL_MEMO = {
	bEnable = false,
	nWidth = 200,
	nHeight = 200,
	szContent = '',
	nFont = 0,
	anchor = { s = 'TOPRIGHT', r = 'TOPRIGHT', x = -310, y = 335 },
}
local D = {}

function D.Reload(bGlobal)
	local CFG_O = bGlobal and GLOBAL_MEMO or ROLE_MEMO
	local CFG = setmetatable({}, {
		__index = CFG_O,
		__newindex = function(t, k, v)
			CFG_O[k] = v
			X.DelayCall('MY_Memo_SaveConfig', D.SaveConfig)
		end,
	})
	local NAME = bGlobal and 'MY_MemoGlobal' or 'MY_MemoRole'
	local TITLE = bGlobal and _L['MY Memo (Global)'] or _L['MY Memo (Role)']
	X.UI('Normal/' .. NAME):Remove()
	if CFG.bEnable then
		X.UI.CreateFrame(NAME, {
			theme = X.UI.FRAME_THEME.SIMPLE, alpha = 140,
			maximize = true, minimize = true, resize = true,
			minWidth = 180, minHeight = 100,
			onSizeChange = function()
				local ui = X.UI(this)
				CFG.nWidth  = ui:Width()
				CFG.anchor  = ui:Anchor()
				CFG.nHeight = ui:Height()
				local nW, nH = ui:ContainerSize()
				ui:Children('#WndEditBox_Memo'):Size(nW, nH)
			end,
			onFrameVisualStateChange = function()
				local ui = X.UI(this)
				local nW, nH = ui:ContainerSize()
				ui:Children('#WndEditBox_Memo'):Size(nW, nH)
			end,
			w = CFG.nWidth, h = CFG.nHeight, text = TITLE,
			draggable = true, dragArea = {0, 0, CFG.nWidth, 30},
			anchor = CFG.anchor,
			events = {{ 'UI_SCALED', function() X.UI(this):Anchor(CFG.anchor) end }},
			uiEvents = {{ 'OnFrameDragEnd', function() CFG.anchor = X.UI('Normal/' .. NAME):Anchor() end }},
		}):Append('WndEditBox', {
			name = 'WndEditBox_Memo',
			x = 0, y = 0, w = CFG.nWidth, h = CFG.nHeight - 30,
			text = CFG.szContent, multiline = true,
			font = CFG.nFont,
			onChange = function(text) CFG.szContent = text end,
		})
	end
end

function D.LoadConfig()
	local CFG = X.LoadLUAData({'config/memo.jx3dat', X.PATH_TYPE.GLOBAL})
	if CFG then
		for k, v in pairs(CFG) do
			GLOBAL_MEMO[k] = v
		end
	end

	local CFG = X.LoadLUAData({'config/memo.jx3dat', X.PATH_TYPE.ROLE})
	if CFG then
		for k, v in pairs(CFG) do
			ROLE_MEMO[k] = v
		end
		ROLE_MEMO.bEnableGlobal = nil
		GLOBAL_MEMO.bEnable = CFG.bEnableGlobal
	end
end

function D.SaveConfig()
	local CFG = {}
	for k, v in pairs(ROLE_MEMO) do
		CFG[k] = v
	end
	CFG.bEnableGlobal = GLOBAL_MEMO.bEnable
	X.SaveLUAData({'config/memo.jx3dat', X.PATH_TYPE.ROLE}, CFG)

	local CFG = {}
	for k, v in pairs(GLOBAL_MEMO) do
		CFG[k] = v
	end
	CFG.bEnable = nil
	X.SaveLUAData({'config/memo.jx3dat', X.PATH_TYPE.GLOBAL}, CFG)
end

function D.IsEnable(bGlobal)
	if bGlobal then
		return GLOBAL_MEMO.bEnable
	end
	return ROLE_MEMO.bEnable
end

function D.Toggle(bGlobal, bEnable)
	(bGlobal and GLOBAL_MEMO or ROLE_MEMO).bEnable = bEnable
	D.SaveConfig()
	D.Reload(bGlobal)
end

function D.GetFont(bGlobal)
	if bGlobal then
		return GLOBAL_MEMO.nFont
	end
	return ROLE_MEMO.nFont
end

function D.SetFont(bGlobal, nFont)
	(bGlobal and GLOBAL_MEMO or ROLE_MEMO).nFont = nFont
	D.SaveConfig()
	D.Reload(bGlobal)
end

do
local function onInit()
	D.LoadConfig()
	D.Reload(true)
	D.Reload(false)
end
X.RegisterInit('MY_Memo', onInit)
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, h = 24,
		text = _L['Memo (Role)'],
		checked = D.IsEnable(false),
		onCheck = function(bChecked)
			D.Toggle(false, bChecked)
		end,
	}):AutoWidth():Width() + 5

	nX = nX + ui:Append('WndButton', {
		x = nX, y = nY, h = 24,
		text = _L['Font'],
		buttonStyle = 'FLAT',
		onClick = function()
			X.UI.OpenFontPicker(function(nFont)
				D.SetFont(false, nFont)
			end)
		end,
	}):AutoWidth():Width() + 5

	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, h = 24,
		text = _L['Memo (Global)'],
		checked = D.IsEnable(true),
		onCheck = function(bChecked)
			D.Toggle(true, bChecked)
		end,
	}):AutoWidth():Width() + 5

	nX = nX + ui:Append('WndButton', {
		x = nX, y = nY, h = 24,
		text = _L['Font'],
		buttonStyle = 'FLAT',
		onClick = function()
			X.UI.OpenFontPicker(function(nFont)
				D.SetFont(true, nFont)
			end)
		end,
	}):AutoWidth():Width() + 5
	nY = nY + nLH
	nX = nPaddingX
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_Memo',
	exports = {
		{
			fields = {
				OnPanelActivePartial = D.OnPanelActivePartial,
			},
		},
	},
}
MY_Memo = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
