--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 聊天辅助
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Chat/MY_ChatEmotion'
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_ChatEmotion'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.3') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------
local O = X.CreateUserSettingsModule('MY_ChatEmotion', _L['Chat'], {
	bFixSize = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_ChatEmotion'],
			_L['Resize emotion'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	nSize = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_ChatEmotion'],
			_L['Emotion size'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 20,
	},
})
local D = {}

function D.Render(szMsg)
	if D.bReady and O.bFixSize then
		local aXMLNode = X.XMLDecode(szMsg)
		if aXMLNode then
			for _, node in ipairs(aXMLNode) do
				local szType = X.XMLGetNodeType(node)
				local szName = X.XMLGetNodeData(node, 'name')
				if (szType == 'animate' or szType == 'image')
				and szName and szName:sub(1, 8) == 'emotion_' then
					X.XMLSetNodeData(node, 'w', O.nSize)
					X.XMLSetNodeData(node, 'h', O.nSize)
					X.XMLSetNodeData(node, 'disablescale', 0)
				end
			end
			szMsg = X.XMLEncode(aXMLNode)
		end
	end
	return szMsg
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	nX = nPaddingX
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 250,
		text = _L['Resize emotion'],
		checked = O.bFixSize,
		onCheck = function(bChecked)
			O.bFixSize = bChecked
		end,
	}):AutoWidth():Width() + 5
	ui:Append('WndSlider', {
		x = nX, y = nY, w = 100, h = 25,
		value = O.nSize,
		range = {1, 300},
		sliderStyle = X.UI.SLIDER_STYLE.SHOW_VALUE,
		textFormatter = function(v) return _L('Size: %d', v) end,
		onChange = function(val)
			O.nSize = val
		end,
		autoEnable = function() return O.bFixSize end,
	})
	nY = nY + nLH

	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_ChatEmotion',
	exports = {
		{
			fields = {
				OnPanelActivePartial = D.OnPanelActivePartial,
				Render = D.Render,
			},
		},
	},
}
MY_ChatEmotion = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterInit('MY_ChatEmotion', function()
	X.HookChatPanel('BEFORE', 'MY_ChatEmotion', function(h, szMsg, ...)
		return D.Render(szMsg), ...
	end)
end)

X.RegisterUserSettingsInit('MY_ChatEmotion', function()
	D.bReady = true
end)

X.RegisterUserSettingsRelease('MY_ChatEmotion', function()
	D.bReady = false
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
