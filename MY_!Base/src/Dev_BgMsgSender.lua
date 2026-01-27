--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 背景通讯发送器
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) MY
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/Dev_BgMsgSender')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. '/lang/Dev/')
--------------------------------------------------------------------------------

local FRAME_NAME = X.NSFormatString('{$NS}_BgMsgSender')

local O = {
	nChannel = nil,
	szTarget = '',
	szMsgID = '',
	szData = '',
}
local D = {}

-- 获取频道名称
function D.GetChannelName(nChannel)
	local szMsgType = X.CONSTANT.PLAYER_TALK_CHANNEL_TO_MSG_TYPE[nChannel]
	return szMsgType and g_tStrings.tChannelName[szMsgType] or tostring(nChannel)
end

-- 获取可用频道列表
function D.GetChannelList()
	return {
		{ nChannel = PLAYER_TALK_CHANNEL.WHISPER, szName = D.GetChannelName(PLAYER_TALK_CHANNEL.WHISPER) or 'Whisper' },
		{ nChannel = PLAYER_TALK_CHANNEL.TEAM, szName = D.GetChannelName(PLAYER_TALK_CHANNEL.TEAM) or 'Team' },
		{ nChannel = PLAYER_TALK_CHANNEL.RAID, szName = D.GetChannelName(PLAYER_TALK_CHANNEL.RAID) or 'Raid' },
		{ nChannel = PLAYER_TALK_CHANNEL.BATTLE_FIELD, szName = D.GetChannelName(PLAYER_TALK_CHANNEL.BATTLE_FIELD) or 'BattleField' },
		{ nChannel = PLAYER_TALK_CHANNEL.TONG, szName = D.GetChannelName(PLAYER_TALK_CHANNEL.TONG) or 'Guild' },
	}
end

-- 发送消息
function D.SendMessage()
	local nChannel = O.nChannel
	local szTarget = O.szTarget
	local szMsgID = O.szMsgID
	local szData = O.szData
	if not nChannel then
		X.OutputSystemMessage(_L['Please select a channel first.'])
		return
	end
	if X.IsEmpty(szMsgID) then
		X.OutputSystemMessage(_L['Please input MsgID.'])
		return
	end
	local oData = nil
	if not X.IsEmpty(szData) then
		oData = X.DecodeLUAData(szData)
		if oData == nil and szData ~= 'nil' then
			X.OutputSystemMessage(_L['Data decode failed, please check Lua syntax.'])
			return
		end
	end
	-- 如果是密聊频道，使用目标名字作为频道
	local xChannel = nChannel
	if nChannel == PLAYER_TALK_CHANNEL.WHISPER then
		if X.IsEmpty(szTarget) then
			X.OutputSystemMessage(_L['Whisper channel requires target name.'])
			return
		end
		xChannel = szTarget
	end
	X.SendBgMsg(xChannel, szMsgID, oData)
	X.OutputSystemMessage(_L('BgMsg sent: %s', szMsgID))
end

-- 打开界面
-- tParams: { nChannel, szTarget, szMsgID, szData }
function D.Open(tParams)
	if D.IsOpened() then
		D.Close()
	end
	-- 如果有参数，预填充数据
	if X.IsTable(tParams) then
		if tParams.nChannel ~= nil then
			O.nChannel = tParams.nChannel
		end
		if tParams.szTarget ~= nil then
			O.szTarget = tParams.szTarget
		end
		if tParams.szMsgID ~= nil then
			O.szMsgID = tParams.szMsgID
		end
		if tParams.szData ~= nil then
			O.szData = tParams.szData
		end
	end
	local ui = X.UI.CreateFrame(FRAME_NAME, {
		w = 500,
		h = 400,
		text = X.PACKET_INFO.NAME .. g_tStrings.STR_CONNECT .. _L['BgMsgSender'],
		anchor = { s = 'CENTER', r = 'CENTER', x = 0, y = 0 },
		close = true,
		esc = true,
		resize = false,
		minimize = true,
	})
	local nW, nH = ui:ContainerSize()
	local nY = 50
	-- 频道选择
	ui:Append('Text', {
		x = 10, y = nY, w = 80, h = 25,
		text = _L['Channel:'],
	})
	ui:Append('WndComboBox', {
		name = 'WndComboBox_Channel',
		x = 90, y = nY, w = 200, h = 25,
		text = O.nChannel and D.GetChannelName(O.nChannel) or _L['Select channel'],
		menu = function()
			local menu = {}
			for _, v in ipairs(D.GetChannelList()) do
				table.insert(menu, {
					szOption = v.szName,
					fnAction = function()
						O.nChannel = v.nChannel
						X.UI(Station.Lookup('Normal/' .. FRAME_NAME)):Fetch('WndComboBox_Channel'):Text(v.szName)
						D.UpdateTargetVisibility()
						X.UI.ClosePopupMenu()
					end,
				})
			end
			return menu
		end,
	})
	nY = nY + 35
	-- 目标名字（仅密聊时启用）
	ui:Append('Text', {
		name = 'Text_Target',
		x = 10, y = nY, w = 80, h = 25,
		text = _L['Target:'],
	})
	ui:Append('WndEditBox', {
		name = 'WndEditBox_Target',
		x = 90, y = nY, w = 200, h = 25,
		text = O.szTarget,
		enable = O.nChannel == PLAYER_TALK_CHANNEL.WHISPER,
		onChange = function(szText)
			O.szTarget = szText
		end,
	})
	nY = nY + 35
	-- MsgID
	ui:Append('Text', {
		x = 10, y = nY, w = 80, h = 25,
		text = _L['MsgID:'],
	})
	ui:Append('WndEditBox', {
		name = 'WndEditBox_MsgID',
		x = 90, y = nY, w = 390, h = 25,
		text = O.szMsgID,
		onChange = function(szText)
			O.szMsgID = szText
		end,
	})
	nY = nY + 35
	-- Data
	ui:Append('Text', {
		x = 10, y = nY, w = 80, h = 25,
		text = _L['Data:'],
	})
	nY = nY + 30
	ui:Append('WndEditBox', {
		name = 'WndEditBox_Data',
		x = 10, y = nY, w = nW - 20, h = 180,
		multiline = true,
		text = O.szData,
		onChange = function(szText)
			O.szData = szText
		end,
	})
	nY = nY + 190
	-- 发送按钮
	ui:Append('WndButton', {
		name = 'WndButton_Send',
		x = (nW - 100) / 2, y = nY, w = 100, h = 30,
		text = _L['Send'],
		onClick = function()
			D.SendMessage()
		end,
	})
end

function D.UpdateTargetVisibility()
	local frame = Station.Lookup('Normal/' .. FRAME_NAME)
	if not frame then
		return
	end
	local ui = X.UI(frame)
	local bEnable = O.nChannel == PLAYER_TALK_CHANNEL.WHISPER
	ui:Fetch('Text_Target'):Alpha(bEnable and 255 or 128)
	ui:Fetch('WndEditBox_Target'):Enable(bEnable):Alpha(bEnable and 255 or 128)
end

function D.Close()
	X.UI.CloseFrame(FRAME_NAME)
end

function D.IsOpened()
	return Station.Lookup('Normal/' .. FRAME_NAME) ~= nil
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = FRAME_NAME,
	exports = {
		{
			preset = 'UIEvent',
			fields = {
				'Open',
				'Close',
				'IsOpened',
			},
			root = D,
		},
	},
}
_G[FRAME_NAME] = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
