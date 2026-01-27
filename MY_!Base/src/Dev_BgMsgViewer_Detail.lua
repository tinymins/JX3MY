--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 背景通讯详情查看器
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) Boilerplate
local X = Boilerplate
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/Dev_BgMsgViewer_Detail')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. '/lang/Dev/')
--------------------------------------------------------------------------------

local FRAME_NAME = X.NSFormatString('{$NS}_BgMsgViewer_Detail')
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

-- 生成详情文本（用于复制和TextEditor）
function D.GetDetailText(rec)
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
function D.Open(rec)
	if not rec then
		return
	end
	-- 关闭已有窗口
	D.Close()
	-- 保存当前记录
	O.rec = rec
	-- 创建窗体
	local ui = X.UI.CreateFrame(FRAME_NAME, {
		w = 600,
		h = 600,
		text = X.PACKET_INFO.NAME .. g_tStrings.STR_CONNECT .. _L['BgMsgDetail'],
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
						local szText = D.GetDetailText(O.rec)
						SetDataToClip(szText)
						X.OutputAnnounceMessage(_L['Detail has been copied to clipboard'])
					end,
				},
				{
					szOption = _L['Open in TextEditor'],
					fnAction = function()
						X.UI.OpenTextEditor(D.GetDetailText(O.rec), {
							title = 'BgMsg Detail - ' .. tostring(O.rec.szMsgID),
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
	nY = D.AppendFormRow(ui, nY, _L['Time:'], X.FormatTime(rec.nTime, '%yyyy-%MM-%dd %hh:%mm:%ss'))
	nY = D.AppendFormRow(ui, nY, _L['Direction:'], tostring(rec.szDirection or 'IN'))
	nY = D.AppendFormRow(ui, nY, _L['MsgID:'], tostring(rec.szMsgID))
	nY = D.AppendFormRow(ui, nY, _L['MsgUUID:'], tostring(rec.szMsgUUID))
	nY = D.AppendFormRow(ui, nY, _L['Channel:'], D.GetChannelName(rec.nChannel) .. ' (' .. tostring(rec.nChannel) .. ')')
	if rec.szTarget then
		nY = D.AppendFormRow(ui, nY, _L['Target:'], tostring(rec.szTarget))
	end
	nY = D.AppendFormRow(ui, nY, _L['Sender:'], tostring(rec.szName) .. ' (' .. tostring(rec.dwID) .. ')')
	nY = D.AppendFormRow(ui, nY, _L['IsSelf:'], tostring(rec.bSelf))
	nY = D.AppendFormRow(ui, nY, _L['SegCount:'], tostring(rec.nSegCount))
	nY = D.AppendFormRow(ui, nY, _L['SegIndex:'], tostring(rec.nSegIndex))
	nY = D.AppendFormRow(ui, nY, _L['Complete:'], tostring(rec.bComplete))
	-- 分隔线
	nY = nY + 10
	ui:Append('Text', {
		x = PADDING, y = nY, w = nW - PADDING * 2, h = ROW_HEIGHT,
		text = _L['Decoded Data:'],
		font = 162,
		alignHorizontal = 'center',
		alignVertical = 'center',
	})
	nY = nY + ROW_HEIGHT
	-- 数据预览区域
	local szData = ''
	if rec.oData ~= nil then
		szData = X.EncodeLUAData(rec.oData, '  ')
	else
		szData = _L['(Not yet decoded or decode failed)']
	end
	O.nEditBoxY = nY -- 保存 EditBox 的 Y 位置，用于 OnResize
	ui:Append('WndEditBox', {
		name = 'WndEditBox_Data',
		x = PADDING, y = nY,
		w = nW - PADDING * 2,
		h = nH - nY - PADDING,
		multiline = true,
		text = szData,
	})
end

function D.OnResize()
	local frame = Station.Lookup('Normal/' .. FRAME_NAME)
	if not frame then
		return
	end
	local ui = X.UI(frame)
	local nW, nH = ui:ContainerSize()
	ui:Fetch('WndEditBox_Data'):Size(nW - PADDING * 2, nH - O.nEditBoxY - PADDING)
end

function D.Close()
	X.UI.CloseFrame(FRAME_NAME)
	O.rec = nil
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
