--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 背景通讯分片详情查看器
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) Boilerplate
local X = Boilerplate
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/Dev_BgMsgSegmentViewer_Detail')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. '/lang/Dev/')
--------------------------------------------------------------------------------

local FRAME_NAME = X.NSFormatString('{$NS}_BgMsgSegmentViewer_Detail')
local LABEL_WIDTH = 100
local VALUE_WIDTH = 450
local ROW_HEIGHT = 25
local PADDING = 10

local O = {}
local D = {}

-- 获取频道名称
function D.GetChannelName(nChannel)
	local szMsgType = X.CONSTANT.PLAYER_TALK_CHANNEL_TO_MSG_TYPE[nChannel]
	return szMsgType and g_tStrings.tChannelName[szMsgType] or tostring(nChannel)
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

-- 生成详情文本（用于复制和TextEditor）
function D.GetDetailText(tSeg)
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
	return table.concat(aLines, '\n')
end

-- 添加表单行
function D.AppendFormRow(ui, nY, szLabel, szValue)
	ui:Append('Text', {
		x = PADDING, y = nY, w = LABEL_WIDTH, h = ROW_HEIGHT,
		text = szLabel,
		font = 162,
		alignHorizontal = 'right',
		alignVertical = 'center',
	})
	ui:Append('Text', {
		x = PADDING + LABEL_WIDTH + 5, y = nY, w = VALUE_WIDTH, h = ROW_HEIGHT,
		text = szValue,
		font = 162,
		alignHorizontal = 'left',
		alignVertical = 'center',
	})
	return nY + ROW_HEIGHT
end

-- 打开界面
function D.Open(tSeg)
	if not tSeg then
		return
	end
	-- 关闭已有窗口
	D.Close()
	-- 保存当前记录
	O.tSeg = tSeg
	-- 创建窗体
	local ui = X.UI.CreateFrame(FRAME_NAME, {
		w = 600,
		h = 600,
		text = X.PACKET_INFO.NAME .. g_tStrings.STR_CONNECT .. _L['BgMsgSegmentDetail'],
		anchor = { s = 'CENTER', r = 'CENTER', x = 0, y = 0 },
		close = true,
		esc = true,
		resize = true,
		minimize = false,
		onSizeChange = function()
			D.OnResize()
		end,
		onSettingsClick = function()
			local menu = {
				{
					szOption = _L['Copy to clipboard'],
					fnAction = function()
						local szText = D.GetDetailText(O.tSeg)
						SetDataToClip(szText)
						X.OutputAnnounceMessage(_L['Detail has been copied to clipboard'])
					end,
				},
				{
					szOption = _L['Open in TextEditor'],
					fnAction = function()
						X.UI.OpenTextEditor(D.GetDetailText(O.tSeg), {
							title = 'Segment Detail - ' .. tostring(O.tSeg.szMsgID),
							w = 600,
							h = 500,
						})
					end,
				},
			}
			PopupMenu(menu)
		end,
	})
	local nW, nH = ui:ContainerSize()
	local nY = 50
	-- 基本信息
	nY = D.AppendFormRow(ui, nY, _L['Time:'], X.FormatTime(tSeg.nTime, '%yyyy-%MM-%dd %hh:%mm:%ss'))
	nY = D.AppendFormRow(ui, nY, _L['MsgID:'], tostring(tSeg.szMsgID))
	nY = D.AppendFormRow(ui, nY, _L['MsgUUID:'], tostring(tSeg.szMsgUUID))
	nY = D.AppendFormRow(ui, nY, _L['Channel:'], D.GetChannelName(tSeg.nChannel) .. ' (' .. tostring(tSeg.nChannel) .. ')')
	nY = D.AppendFormRow(ui, nY, _L['Sender:'], tostring(tSeg.szName) .. ' (' .. tostring(tSeg.dwID) .. ')')
	nY = D.AppendFormRow(ui, nY, _L['SegCount:'], tostring(tSeg.nSegCount))
	nY = D.AppendFormRow(ui, nY, _L['Received:'], tostring(D.GetReceivedCount(tSeg)))
	nY = D.AppendFormRow(ui, nY, _L['Complete:'], tostring(D.IsComplete(tSeg)))
	-- 分隔线
	nY = nY + 10
	ui:Append('Text', {
		x = PADDING, y = nY, w = nW - PADDING * 2, h = ROW_HEIGHT,
		text = _L['Segments:'],
		font = 162,
		alignHorizontal = 'center',
		alignVertical = 'center',
	})
	nY = nY + ROW_HEIGHT
	-- 分片预览区域
	local aSegLines = {}
	for i = 1, tSeg.nSegCount do
		local part = tSeg.aParts[i]
		if part then
			table.insert(aSegLines, string.format('[%d] Received at %s', i, X.FormatTime(part.nTime, '%hh:%mm:%ss')))
			table.insert(aSegLines, '    ' .. tostring(part.szPart))
		else
			table.insert(aSegLines, string.format('[%d] (Missing)', i))
		end
	end
	local szSegData = table.concat(aSegLines, '\n')
	O.nEditBoxY = nY -- 保存 EditBox 的 Y 位置，用于 OnResize
	ui:Append('WndEditBox', {
		name = 'WndEditBox_Segments',
		x = PADDING, y = nY,
		w = nW - PADDING * 2,
		h = nH - nY - PADDING,
		multiline = true,
		text = szSegData,
		enable = false,
	})
end

function D.OnResize()
	local frame = Station.Lookup('Normal/' .. FRAME_NAME)
	if not frame then
		return
	end
	local ui = X.UI(frame)
	local nW, nH = ui:ContainerSize()
	ui:Fetch('WndEditBox_Segments'):Size(nW - PADDING * 2, nH - O.nEditBoxY - PADDING)
end

function D.Close()
	X.UI.CloseFrame(FRAME_NAME)
	O.tSeg = nil
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
