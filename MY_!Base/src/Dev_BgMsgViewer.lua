--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 背景通讯查看器
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) Boilerplate
local X = Boilerplate
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/Dev_BgMsgViewer')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. '/lang/Dev/')
--------------------------------------------------------------------------------

local FRAME_NAME = X.NSFormatString('{$NS}_BgMsgViewer')
local STORAGE_FILE = {'temporary/bgmsg_viewer.jx3dat', X.PATH_TYPE.ROLE}
local MAX_HISTORY = 1000

local O = {
	bRecording = false,
	aHistory = {},
}
local D = {}

-- 加载持久化数据
function D.LoadStorage()
	local data = X.LoadLUAData(STORAGE_FILE)
	if X.IsTable(data) then
		O.bRecording = data.bRecording or false
		O.aHistory = data.aHistory or {}
	end
end

-- 保存持久化数据
function D.SaveStorage()
	X.SaveLUAData(STORAGE_FILE, {
		bRecording = O.bRecording,
		aHistory = O.aHistory,
	})
end

-- 获取频道名称
function D.GetChannelName(nChannel)
	local szMsgType = X.CONSTANT.PLAYER_TALK_CHANNEL_TO_MSG_TYPE[nChannel]
	return szMsgType and g_tStrings.tChannelName[szMsgType] or tostring(nChannel)
end

-- 记录消息 (外部调用入口)
-- szDirection: 'IN' 入站, 'OUT' 出站
function D.RecordMessage(szMsgID, nChannel, dwID, szName, bSelf, aMsg, oData, nSegCount, szDirection)
	if not O.bRecording then
		return
	end
	local szMsgUUID = aMsg and aMsg[1] and aMsg[1].u or ''
	local nSegIndex = aMsg and aMsg[1] and aMsg[1].i or 0
	local szPart = aMsg and aMsg[2] or ''
	local rec = {
		szMsgID = szMsgID,
		nChannel = nChannel,
		dwID = dwID,
		szName = szName,
		bSelf = bSelf,
		szMsgUUID = szMsgUUID,
		nSegCount = nSegCount or 1,
		nSegIndex = nSegIndex,
		szPart = szPart,
		oData = oData,
		bComplete = oData ~= nil,
		nTime = GetCurrentTime(),
		szDirection = szDirection or 'IN',
		szTarget = type(nChannel) == 'string' and nChannel or nil,
	}
	table.insert(O.aHistory, rec)
	-- 限制最大记录数
	while #O.aHistory > MAX_HISTORY do
		table.remove(O.aHistory, 1)
	end
	-- 更新界面
	D.RefreshList()
end

-- 刷新列表
function D.RefreshList()
	local frame = Station.Lookup('Normal/' .. FRAME_NAME)
	if not frame then
		return
	end
	local uiList = X.UI(frame):Fetch('WndListBox_History')
	if not uiList:Raw() then
		return
	end
	uiList:ListBox('clear')
	for i, rec in ipairs(O.aHistory) do
		local szTime = X.FormatTime(rec.nTime, '%hh:%mm:%ss')
		local szChannel = D.GetChannelName(rec.nChannel)
		local szStatus = rec.bComplete and '[OK]' or '[..]'
		local szDir = rec.szDirection == 'OUT' and '[OUT]' or '[IN]'
		local szText = string.format('%s %s %s %s %s (%s)', szTime, szDir, szStatus, szChannel, rec.szMsgID, rec.szName)
		local r, g, b = 255, 255, 255
		if rec.szDirection == 'OUT' then
			r, g, b = 128, 200, 255
		elseif rec.bSelf then
			r, g, b = 128, 255, 128
		elseif not rec.bComplete then
			r, g, b = 255, 255, 128
		end
		uiList:ListBox('insert', {
			id = i,
			text = szText,
			data = rec,
			r = r, g = g, b = b,
		})
	end
end

-- 显示详情
function D.ShowDetail(rec)
	if not rec then
		return
	end
	local aLines = {}
	table.insert(aLines, '========== BgMsg Detail ==========')
	table.insert(aLines, 'Time: ' .. X.FormatTime(rec.nTime, '%yyyy-%MM-%dd %hh:%mm:%ss'))
	table.insert(aLines, 'Direction: ' .. tostring(rec.szDirection or 'IN'))
	table.insert(aLines, 'MsgID: ' .. tostring(rec.szMsgID))
	table.insert(aLines, 'MsgUUID: ' .. tostring(rec.szMsgUUID))
	table.insert(aLines, 'Channel: ' .. D.GetChannelName(rec.nChannel) .. ' (' .. tostring(rec.nChannel) .. ')')
	if rec.szTarget then
		table.insert(aLines, 'Target: ' .. tostring(rec.szTarget))
	end
	table.insert(aLines, 'Sender: ' .. tostring(rec.szName) .. ' (' .. tostring(rec.dwID) .. ')')
	table.insert(aLines, 'IsSelf: ' .. tostring(rec.bSelf))
	table.insert(aLines, 'SegCount: ' .. tostring(rec.nSegCount))
	table.insert(aLines, 'SegIndex: ' .. tostring(rec.nSegIndex))
	table.insert(aLines, 'Complete: ' .. tostring(rec.bComplete))
	table.insert(aLines, '')
	table.insert(aLines, '---------- Raw Part ----------')
	table.insert(aLines, tostring(rec.szPart))
	table.insert(aLines, '')
	table.insert(aLines, '---------- Decoded Data ----------')
	if rec.oData ~= nil then
		table.insert(aLines, X.EncodeLUAData(rec.oData, '  '))
	else
		table.insert(aLines, '(Not yet decoded or decode failed)')
	end
	X.UI.OpenTextEditor(table.concat(aLines, '\n'), {
		title = 'BgMsg Detail - ' .. tostring(rec.szMsgID),
		w = 600,
		h = 500,
	})
end

-- 打开界面
function D.Open()
	if D.IsOpened() then
		D.Close()
		return
	end
	local ui = X.UI.CreateFrame(FRAME_NAME, {
		w = 700,
		h = 500,
		text = X.PACKET_INFO.NAME .. g_tStrings.STR_CONNECT .. _L['BgMsgViewer'],
		anchor = { s = 'CENTER', r = 'CENTER', x = 0, y = 0 },
		close = true,
		esc = true,
		resize = true,
		minimize = true,
		onSizeChange = function()
			D.OnResize()
		end,
	})
	local nW, nH = ui:ContainerSize()
	-- 工具栏
	local nX = 10
	ui:Append('WndCheckBox', {
		name = 'WndCheckBox_Recording',
		x = nX, y = 50, w = 'auto',
		text = _L['Recording'],
		checked = O.bRecording,
		onCheck = function(bChecked)
			O.bRecording = bChecked
			D.SaveStorage()
		end,
	})
	nX = nX + 100
	ui:Append('WndButton', {
		name = 'WndButton_Clear',
		x = nX, y = 50, w = 80, h = 25,
		text = _L['Clear'],
		onClick = function()
			O.aHistory = {}
			D.RefreshList()
			D.SaveStorage()
		end,
	})
	nX = nX + 90
	ui:Append('WndButton', {
		name = 'WndButton_Segment',
		x = nX, y = 50, w = 120, h = 25,
		text = _L['Segment Viewer'],
		onClick = function()
			local szSegmentViewerName = X.NSFormatString('{$NS}_BgMsgSegmentViewer')
			if _G[szSegmentViewerName] and _G[szSegmentViewerName].Open then
				_G[szSegmentViewerName].Open()
			end
		end,
	})
	nX = nX + 130
	ui:Append('WndButton', {
		name = 'WndButton_Sender',
		x = nX, y = 50, w = 120, h = 25,
		text = _L['BgMsg Sender'],
		onClick = function()
			local szSenderName = X.NSFormatString('{$NS}_BgMsgSender')
			if _G[szSenderName] and _G[szSenderName].Open then
				_G[szSenderName].Open()
			end
		end,
	})
	-- 列表
	ui:Append('WndListBox', {
		name = 'WndListBox_History',
		x = 10, y = 85,
		w = nW - 20,
		h = nH - 95,
	})
	X.UI(ui:Raw()):Fetch('WndListBox_History'):ListBox('onlclick', function(id, text, data, selected)
		D.ShowDetail(data)
	end)
	D.RefreshList()
end

function D.OnResize()
	local frame = Station.Lookup('Normal/' .. FRAME_NAME)
	if not frame then
		return
	end
	local ui = X.UI(frame)
	local nW, nH = ui:ContainerSize()
	ui:Fetch('WndListBox_History'):Size(nW - 20, nH - 95)
end

function D.Close()
	X.UI.CloseFrame(FRAME_NAME)
end

function D.IsOpened()
	return Station.Lookup('Normal/' .. FRAME_NAME) ~= nil
end

function D.IsRecording()
	return O.bRecording
end

-- 初始化
X.RegisterInit(function()
	D.LoadStorage()
end)
X.RegisterFlush(function()
	D.SaveStorage()
end)

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
				'IsRecording',
				'RecordMessage',
			},
			root = D,
		},
	},
}
_G[FRAME_NAME] = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
