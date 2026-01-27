--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 背景通讯查看器
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) MY
local X = MY
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
local MAX_STORAGE_HISTORY = 200

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
	-- 只保留最新的 MAX_STORAGE_HISTORY 条记录
	local aHistory = O.aHistory
	if #aHistory > MAX_STORAGE_HISTORY then
		local aStorageHistory = {}
		for i = #aHistory - MAX_STORAGE_HISTORY + 1, #aHistory do
			table.insert(aStorageHistory, aHistory[i])
		end
		aHistory = aStorageHistory
	end
	X.SaveLUAData(STORAGE_FILE, {
		bRecording = O.bRecording,
		aHistory = aHistory,
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
	local uiTable = X.UI(frame):Fetch('WndTable_History')
	if not uiTable:Raw() then
		return
	end
	local aDataSource = {}
	for i, rec in ipairs(O.aHistory) do
		local szPreview = ''
		if rec.oData ~= nil then
			szPreview = X.EncodeLUAData(rec.oData)
			if #szPreview > 100 then
				szPreview = szPreview:sub(1, 100) .. '...'
			end
		end
		table.insert(aDataSource, {
			nIndex = i,
			szTime = X.FormatTime(rec.nTime, '%hh:%mm:%ss'),
			szDirection = rec.szDirection or 'IN',
			bComplete = rec.bComplete,
			szChannel = D.GetChannelName(rec.nChannel),
			szMsgID = rec.szMsgID,
			szName = rec.szName,
			szPreview = szPreview,
			bSelf = rec.bSelf,
			rec = rec,
		})
	end
	uiTable:DataSource(aDataSource)
end

-- 显示详情
function D.ShowDetail(rec)
	if not rec then
		return
	end
	local szDetailName = X.NSFormatString('{$NS}_BgMsgViewer_Detail')
	if _G[szDetailName] and _G[szDetailName].Open then
		_G[szDetailName].Open(rec)
	end
end

-- 打开界面
function D.Open()
	if D.IsOpened() then
		D.Close()
		return
	end
	local ui = X.UI.CreateFrame(FRAME_NAME, {
		w = 1200,
		h = 700,
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
			D.UpdateEnableState()
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
			_G[X.NSFormatString('{$NS}_BgMsgSegmentViewer')].Open()
		end,
	})
	nX = nX + 130
	ui:Append('WndButton', {
		name = 'WndButton_Sender',
		x = nX, y = 50, w = 120, h = 25,
		text = _L['BgMsg Sender'],
		onClick = function()
			_G[X.NSFormatString('{$NS}_BgMsgSender')].Open()
		end,
	})
	-- 帮助按钮（右对齐）
	ui:Append('WndButton', {
		name = 'WndButton_Help',
		x = nW - 30, y = 50, w = 20, h = 20,
		buttonStyle = 'QUESTION',
		tip = {
			render = GetFormatText(_L['Blue: Outbound message'], 162, 128, 200, 255) .. GetFormatText('\n')
				.. GetFormatText(_L['Green: Inbound message from self'], 162, 128, 255, 128) .. GetFormatText('\n')
				.. GetFormatText(_L['Yellow: Incomplete message'], 162, 255, 255, 128) .. GetFormatText('\n')
				.. GetFormatText(_L['White: Inbound message from others'], 162, 255, 255, 255),
			rich = true,
			position = X.UI.TIP_POSITION.TOP_BOTTOM,
		},
	})
	-- 表格
	ui:Append('WndTable', {
		name = 'WndTable_History',
		x = 10, y = 85,
		w = nW - 20,
		h = nH - 95,
		onRowLClick = function(rec, nIndex)
			D.ShowDetail(rec.rec)
		end,
		onRowRClick = function(rec, nIndex)
			if not rec or not rec.rec then
				return
			end
			local r = rec.rec
			local menu = {
				{
					szOption = _L['Replay'],
					fnAction = function()
						local szData = ''
						if r.oData ~= nil then
							szData = X.EncodeLUAData(r.oData, '  ')
						end
						-- 处理频道和目标
						local nChannel = type(r.nChannel) == 'number' and r.nChannel or PLAYER_TALK_CHANNEL.WHISPER
						local szTarget = r.szTarget or ''
						-- 如果是密聊且目标为空，用发送者名字作为目标（回复）
						if X.IsEmpty(szTarget) and nChannel == PLAYER_TALK_CHANNEL.WHISPER then
							szTarget = r.szName or ''
						end
						-- 如果原始频道是字符串（密聊目标名），也用它作为目标
						if type(r.nChannel) == 'string' then
							szTarget = r.nChannel
						end
						_G[X.NSFormatString('{$NS}_BgMsgSender')].Open({
							nChannel = nChannel,
							szTarget = szTarget,
							szMsgID = r.szMsgID or '',
							szData = szData,
						})
					end,
				},
				{
					szOption = _L['View Detail'],
					fnAction = function()
						D.ShowDetail(r)
					end,
				},
			}
			PopupMenu(menu)
		end,
		columns = {
			{
				key = 'szTime',
				title = _L['Time'],
				alignHorizontal = 'center',
				width = 80,
				render = function(value, record)
					local r, g, b = D.GetRecordColor(record)
					return GetFormatText(value, 162, r, g, b)
				end,
			},
			{
				key = 'szDirection',
				title = _L['Dir'],
				alignHorizontal = 'center',
				width = 60,
				render = function(value, record)
					local r, g, b = D.GetRecordColor(record)
					return GetFormatText(value, 162, r, g, b)
				end,
			},
			{
				key = 'bComplete',
				title = _L['Status'],
				alignHorizontal = 'center',
				width = 60,
				render = function(value, record)
					local r, g, b = D.GetRecordColor(record)
					local szStatus = value and 'OK' or '..'
					return GetFormatText(szStatus, 162, r, g, b)
				end,
			},
			{
				key = 'szChannel',
				title = _L['Channel'],
				alignHorizontal = 'center',
				width = 100,
				render = function(value, record)
					local r, g, b = D.GetRecordColor(record)
					return GetFormatText(value, 162, r, g, b)
				end,
			},
			{
				key = 'szName',
				title = _L['Sender'],
				alignHorizontal = 'left',
				width = 120,
				render = function(value, record)
					local r, g, b = D.GetRecordColor(record)
					return GetFormatText(' ' .. tostring(value), 162, r, g, b)
				end,
			},
			{
				key = 'szMsgID',
				title = _L['MsgID'],
				alignHorizontal = 'left',
				width = 200,
				overflow = 'hidden',
				render = function(value, record)
					local r, g, b = D.GetRecordColor(record)
					return GetFormatText(' ' .. tostring(value), 162, r, g, b)
				end,
			},
			{
				key = 'szPreview',
				title = _L['Preview'],
				alignHorizontal = 'left',
				minWidth = 200,
				render = function(value, record)
					local r, g, b = D.GetRecordColor(record)
					return GetFormatText(' ' .. tostring(value), 162, r, g, b)
				end,
			},
		},
		dataSource = {},
	})
	D.RefreshList()
	D.UpdateEnableState()
end

-- 更新组件启用状态
function D.UpdateEnableState()
	local frame = Station.Lookup('Normal/' .. FRAME_NAME)
	if not frame then
		return
	end
	local ui = X.UI(frame)
	local bEnable = O.bRecording
	ui:Fetch('WndButton_Clear'):Enable(bEnable)
	ui:Fetch('WndButton_Segment'):Enable(bEnable)
	ui:Fetch('WndButton_Sender'):Enable(bEnable)
	ui:Fetch('WndTable_History'):Enable(bEnable)
end

-- 获取记录颜色
function D.GetRecordColor(record)
	if record.szDirection == 'OUT' then
		return 128, 200, 255
	elseif record.bSelf then
		return 128, 255, 128
	elseif not record.bComplete then
		return 255, 255, 128
	end
	return 255, 255, 255
end

function D.OnResize()
	local frame = Station.Lookup('Normal/' .. FRAME_NAME)
	if not frame then
		return
	end
	local ui = X.UI(frame)
	local nW, nH = ui:ContainerSize()
	ui:Fetch('WndTable_History'):Size(nW - 20, nH - 95)
	ui:Fetch('WndButton_Help'):Pos(nW - 30, 50)
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
