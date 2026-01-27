--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 背景通讯分片查看器
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) Boilerplate
local X = Boilerplate
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/Dev_BgMsgSegmentViewer')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. '/lang/Dev/')
--------------------------------------------------------------------------------

local FRAME_NAME = X.NSFormatString('{$NS}_BgMsgSegmentViewer')

local O = {
	bFilterIncomplete = false, -- 仅显示未组装的
	tSegments = {}, -- { [szMsgUUID] = { szMsgID, nChannel, dwID, szName, nSegCount, aParts = { [nSegIndex] = { szPart, nTime } } } }
}
local D = {}

-- 获取频道名称
function D.GetChannelName(nChannel)
	local szMsgType = X.CONSTANT.PLAYER_TALK_CHANNEL_TO_MSG_TYPE[nChannel]
	return szMsgType and g_tStrings.tChannelName[szMsgType] or tostring(nChannel)
end

-- 记录分片 (外部调用入口)
function D.RecordSegment(szMsgID, szMsgUUID, nChannel, dwID, szName, nSegCount, nSegIndex, szPart)
	if not O.tSegments[szMsgUUID] then
		O.tSegments[szMsgUUID] = {
			szMsgID = szMsgID,
			szMsgUUID = szMsgUUID,
			nChannel = nChannel,
			dwID = dwID,
			szName = szName,
			nSegCount = nSegCount,
			nTime = GetCurrentTime(),
			aParts = {},
		}
	end
	O.tSegments[szMsgUUID].aParts[nSegIndex] = {
		szPart = szPart,
		nTime = GetCurrentTime(),
	}
	D.RefreshList()
end

-- 标记消息完成
function D.MarkComplete(szMsgUUID)
	if O.tSegments[szMsgUUID] then
		O.tSegments[szMsgUUID].bComplete = true
		D.RefreshList()
	end
end

-- 获取已接收分片数
function D.GetReceivedCount(tSeg)
	local nCount = 0
	for _, _ in pairs(tSeg.aParts) do
		nCount = nCount + 1
	end
	return nCount
end

-- 检查是否完整
function D.IsComplete(tSeg)
	return tSeg.bComplete or D.GetReceivedCount(tSeg) >= tSeg.nSegCount
end

-- 刷新列表
function D.RefreshList()
	local frame = Station.Lookup('Normal/' .. FRAME_NAME)
	if not frame then
		return
	end
	local uiList = X.UI(frame):Fetch('WndListBox_Segments')
	if not uiList:Raw() then
		return
	end
	uiList:ListBox('clear')
	for szMsgUUID, tSeg in pairs(O.tSegments) do
		local bComplete = D.IsComplete(tSeg)
		-- 过滤：仅显示未组装的
		if not O.bFilterIncomplete or not bComplete then
			local szTime = X.FormatTime(tSeg.nTime, '%hh:%mm:%ss')
			local szChannel = D.GetChannelName(tSeg.nChannel)
			local nRecv = D.GetReceivedCount(tSeg)
			local szStatus = bComplete and '[OK]' or string.format('[%d/%d]', nRecv, tSeg.nSegCount)
			local szText = string.format('%s %s %s %s (%s)', szTime, szStatus, szChannel, tSeg.szMsgID, tSeg.szName)
			local r, g, b = 255, 255, 255
			if bComplete then
				r, g, b = 128, 255, 128
			elseif nRecv < tSeg.nSegCount then
				r, g, b = 255, 255, 128
			end
			uiList:ListBox('insert', {
				id = szMsgUUID,
				text = szText,
				data = tSeg,
				r = r, g = g, b = b,
			})
		end
	end
end

-- 显示详情
function D.ShowDetail(tSeg)
	if not tSeg then
		return
	end
	local aLines = {}
	table.insert(aLines, '========== Segment Detail ==========')
	table.insert(aLines, 'Time: ' .. X.FormatTime(tSeg.nTime, '%yyyy-%MM-%dd %hh:%mm:%ss'))
	table.insert(aLines, 'MsgID: ' .. tostring(tSeg.szMsgID))
	table.insert(aLines, 'MsgUUID: ' .. tostring(tSeg.szMsgUUID))
	table.insert(aLines, 'Channel: ' .. D.GetChannelName(tSeg.nChannel) .. ' (' .. tostring(tSeg.nChannel) .. ')')
	table.insert(aLines, 'Sender: ' .. tostring(tSeg.szName) .. ' (' .. tostring(tSeg.dwID) .. ')')
	table.insert(aLines, 'SegCount: ' .. tostring(tSeg.nSegCount))
	table.insert(aLines, 'Received: ' .. tostring(D.GetReceivedCount(tSeg)))
	table.insert(aLines, 'Complete: ' .. tostring(D.IsComplete(tSeg)))
	table.insert(aLines, '')
	table.insert(aLines, '---------- Segments ----------')
	for i = 1, tSeg.nSegCount do
		local part = tSeg.aParts[i]
		if part then
			table.insert(aLines, string.format('[%d] Received at %s', i, X.FormatTime(part.nTime, '%hh:%mm:%ss')))
			table.insert(aLines, '    ' .. tostring(part.szPart))
		else
			table.insert(aLines, string.format('[%d] (Missing)', i))
		end
	end
	X.UI.OpenTextEditor(table.concat(aLines, '\n'), {
		title = 'Segment Detail - ' .. tostring(tSeg.szMsgID),
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
		text = X.PACKET_INFO.NAME .. g_tStrings.STR_CONNECT .. _L['BgMsgSegmentViewer'],
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
		name = 'WndCheckBox_FilterIncomplete',
		x = nX, y = 50, w = 'auto',
		text = _L['Show incomplete only'],
		checked = O.bFilterIncomplete,
		onCheck = function(bChecked)
			O.bFilterIncomplete = bChecked
			D.RefreshList()
		end,
	})
	nX = nX + 180
	ui:Append('WndButton', {
		name = 'WndButton_Clear',
		x = nX, y = 50, w = 80, h = 25,
		text = _L['Clear'],
		onClick = function()
			O.tSegments = {}
			D.RefreshList()
		end,
	})
	nX = nX + 90
	ui:Append('WndButton', {
		name = 'WndButton_ClearComplete',
		x = nX, y = 50, w = 120, h = 25,
		text = _L['Clear completed'],
		onClick = function()
			for szMsgUUID, tSeg in pairs(O.tSegments) do
				if D.IsComplete(tSeg) then
					O.tSegments[szMsgUUID] = nil
				end
			end
			D.RefreshList()
		end,
	})
	-- 列表
	ui:Append('WndListBox', {
		name = 'WndListBox_Segments',
		x = 10, y = 85,
		w = nW - 20,
		h = nH - 95,
	})
	X.UI(ui:Raw()):Fetch('WndListBox_Segments'):ListBox('onlclick', function(id, text, data, selected)
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
	ui:Fetch('WndListBox_Segments'):Size(nW - 20, nH - 95)
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
				'RecordSegment',
				'MarkComplete',
			},
			root = D,
		},
	},
}
_G[FRAME_NAME] = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
