--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 聊天监控 按关键字过滤获取聊天消息
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Chat/MY_ChatMonitor'
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_ChatMonitor'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.3') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------
--[[
	RECORD_LIST = {
		-- （数组部分）监控记录
		{
			html = 消息A的UI序列化值(szMsg) 消息源数据UI XML,
			hash = 消息A的HASH值 计算当前消息的哈希 用于过滤相同,
			text = 消息A的纯文本 计算当前消息的纯文字内容 用于匹配,
		}, ...
	}
	RECORD_HASH = {
		-- （哈希部分）记录数量
		[消息A的HASH值] = 相同的消息A捕获的数量, -- 当为0时删除改HASH
		...
	}
]]
local DATA_FILE = 'userdata/chatmonitor.jx3dat'
local CONFIG_FILE = 'config/chatmonitor.jx3dat'
local RECORD_LIST, RECORD_HASH = {}, {}
local DEFAULE_CHANNEL = {
	['MSG_NORMAL'] = true, ['MSG_CAMP' ] = true, ['MSG_WORLD' ] = true, ['MSG_MAP'     ] = true,
	['MSG_SCHOOL'] = true, ['MSG_GUILD'] = true, ['MSG_FRIEND'] = true, ['MSG_IDENTITY'] = true,
}
local O = X.CreateUserSettingsModule('MY_ChatMonitor', _L['Chat'], {
	aKeyword = {
		ePathType = X.PATH_TYPE.GLOBAL,
		szLabel = _L['MY_ChatMonitor'],
		szDescription = X.MakeCaption({
			_L['key words:'] .. _L['Click to config monitors'],
		}),
		xSchema = X.Schema.Collection(X.Schema.Record({
			szKeyword = X.Schema.String,
			bEnable = X.Schema.Boolean,
			bIsRegexp = X.Schema.Boolean,
			tChannel = X.Schema.Map(X.Schema.String, X.Schema.Boolean),
		})),
		xDefaultValue = {{
			szKeyword = _L.CHAT_MONITOR_KEYWORDS_SAMPLE,
			bEnable = true,
			bIsRegexp = false,
			tChannel = X.Clone(DEFAULE_CHANNEL),
		}},
	},
	bCapture = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMonitor'],
		szDescription = X.MakeCaption({
			_L['start'] .. '/' .. _L['stop'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	nMaxRecord = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMonitor'],
		szDescription = X.MakeCaption({
			_L['max record count'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 30,
	},
	bShowPreview = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMonitor'],
		szDescription = X.MakeCaption({
			_L['show message preview box'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bPlaySound = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMonitor'],
		szDescription = X.MakeCaption({
			_L['play new message alert sound'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bRedirectSysChannel = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMonitor'],
		szDescription = X.MakeCaption({
			_L['output to system channel'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bIgnoreSame = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMonitor'],
		szDescription = X.MakeCaption({
			_L['ignore same message'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	-- bRealtimeSave = {
	-- 	ePathType = X.PATH_TYPE.ROLE,
	-- 	szLabel = _L['MY_ChatMonitor'],
	-- 	xSchema = X.Schema.Boolean,
	-- 	xDefaultValue = false,
	-- },
	bDistinctServer = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMonitor'],
		szDescription = X.MakeCaption({
			_L['Distinct server'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	szTimestrap = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMonitor'],
		szDescription = X.MakeCaption({
			_L['timestrap format'],
		}),
		xSchema = X.Schema.String,
		xDefaultValue = '[%hh:%mm:%ss]',
	},
	anchor = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMonitor'],
		szDescription = X.MakeCaption({
			_L['UI Anchor'],
		}),
		xSchema = X.Schema.FrameAnchor,
		xDefaultValue = { x = -100, y = -150, s = 'BOTTOMRIGHT', r = 'BOTTOMRIGHT' },
	},
})
local D = {}

local l_uiBtn, l_uiBoard

function D.LoadConfig()
	local szPath = X.FormatPath({CONFIG_FILE, X.PATH_TYPE.GLOBAL})
	local aKeyword = X.LoadLUAData(szPath)
	if aKeyword then
		CPath.DelFile(szPath)
		-- 兼容保留
		for i, p in ipairs(aKeyword) do
			if X.IsString(p) then
				aKeyword[i] = {
					szKeyword = p,
					bEnable = true,
					bIsRegexp = false,
					tChannel = X.Clone(DEFAULE_CHANNEL),
				}
			end
		end
		O.aKeyword = aKeyword
	end
end

function D.SaveData()
	local TYPE = O.bDistinctServer
		and X.PATH_TYPE.SERVER or X.PATH_TYPE.ROLE
	X.SaveLUAData({DATA_FILE, TYPE}, {list = RECORD_LIST, hash = RECORD_HASH})
end

function D.LoadData()
	local data = O.bDistinctServer
		and (X.LoadLUAData({DATA_FILE, X.PATH_TYPE.SERVER}) or {})
		or (X.LoadLUAData({DATA_FILE, X.PATH_TYPE.ROLE}) or {})
	RECORD_LIST = data.list or {}
	RECORD_HASH = data.hash or {}
end

function D.GetHTML(rec)
	-- render link event
	local szMsg = X.RenderChatLink(rec.html)
	if MY_ChatEmotion and MY_ChatEmotion.Render then
		szMsg = MY_ChatEmotion.Render(szMsg)
	end
	if MY_Farbnamen and MY_Farbnamen.Render then
		szMsg = MY_Farbnamen.Render(szMsg)
	end
	szMsg = X.GetChatTimeXML(rec.time, {
		r = rec.r, g = rec.g, b = rec.b,
		f = rec.font, s = O.szTimestrap,
		richtext = szMsg,
	}) .. szMsg
	return szMsg
end

function D.OnNotifyCB()
	X.Panel.Show()
	X.Panel.Focus()
	X.Panel.SwitchTab('MY_ChatMonitor')
	X.DismissNotify('MY_ChatMonitor')
end

-- 插入聊天内容时监控聊天信息
function D.OnMsgArrive(szChannel, szMsg, nFont, bRich, r, g, b, dwTalkerID, szName)
	-- is enabled
	if not D.bReady or not O.bCapture then
		return
	end
	--------------------------------------------------------------------------------------
	-- 开始生成一条记录
	local rec = { text = '', hash = '', html = '' }
	-- 计算消息源数据UI
	if bRich then
		rec.html = szMsg
		-- 格式化消息
		local tMsgContent = X.ParseChatData(szMsg)
		-- 拼接消息
		if szChannel == 'MSG_SYS' then -- 系统消息
			for i, v in ipairs(tMsgContent) do
				rec.text = rec.text .. v.text
			end
			rec.hash = rec.text
		else -- 如果不是系统信息则在哈希中舍弃第一个名字之前的东西 类似“[阵营][浩气盟][茗伊]说：”
			-- STR_TALK_HEAD_WHISPER = '悄悄地说：',
			-- STR_TALK_HEAD_WHISPER_REPLY = '你悄悄地对',
			-- STR_TALK_HEAD_SAY = '说：',
			-- STR_TALK_HEAD_SAY1 = '：',
			-- STR_TALK_HEAD_SAY2 = '大声喊：',
			local bSkiped = false
			for i, v in ipairs(tMsgContent) do
				if (i < 4 and not bSkiped) and (
					v.text == g_tStrings.STR_TALK_HEAD_WHISPER or
					v.text == g_tStrings.STR_TALK_HEAD_SAY or
					v.text == g_tStrings.STR_TALK_HEAD_SAY1 or
					v.text == g_tStrings.STR_TALK_HEAD_SAY2
				) then
					bSkiped = true
					rec.hash = ''
				else
					rec.text = rec.text .. v.text
					rec.hash = rec.hash .. v.text
				end
			end
		end
	else
		rec.text = szMsg
		rec.hash = szMsg
		rec.html = GetFormatText(szMsg, nil, GetMsgFontColor('MSG_SYS'))
	end

	rec.fuzzy_text = rec.text
	local szChannelName = g_tStrings.tChannelName[szChannel]
	if szChannelName then
		rec.fuzzy_text = '[' .. szChannelName .. ']\t' .. rec.fuzzy_text
	end
	rec.fuzzy_text = StringLowerW(rec.fuzzy_text)

	rec.hash = string.gsub(rec.hash, '[\n%s]+', '')
	--------------------------------------------------------------------------------------
	-- 开始计算是否符合过滤器要求
	local bMatch = false
	for _, p in ipairs(O.aKeyword) do
		if p.bEnable and p.tChannel[szChannel] then
			if p.bIsRegexp then -- regexp
				if string.find(rec.text, p.szKeyword) then
					bMatch = true
					break
				end
			else -- normal
				if X.StringSimpleMatch(rec.text, p.szKeyword) then
					bMatch = true
					break
				end
			end
		end
	end
	if not bMatch then
		return
	end
	-- 验证消息哈希 如果存在则跳过该消息
	if O.bIgnoreSame and RECORD_HASH[rec.hash] then
		return
	end
	--------------------------------------------------------------------------------------
	-- 如果符合要求
	-- 开始渲染一条记录的UIXML字符串
	rec.r, rec.g, rec.b = r, g, b
	rec.font = nFont
	rec.time = GetCurrentTime()
	local html = D.GetHTML(rec)
	-- 如果设置重定向到系统消息则输出（输出时加个标记防止又被自己捕捉了死循环）
	if O.bRedirectSysChannel and szChannel ~= 'MSG_SYS' then
		OutputMessage('MSG_SYS', X.EncodeEchoMsgHeader(szChannel) .. szMsg, true)
	end
	-- 广播消息
	OutputMessage('MSG_MY_MONITOR', szMsg, true, nil, nil, dwTalkerID, szName)
	-- 更新UI
	if l_uiBoard then
		local nPos = l_uiBoard:Scroll()
		l_uiBoard:Append(html)
		if nPos == 100 or nPos == -1 then
			l_uiBoard:Scroll(100)
		end
	end
	X.CreateNotify({
		szKey = 'MY_ChatMonitor',
		szMsg = html,
		fnAction = D.OnNotifyCB,
		bPlaySound = O.bPlaySound,
		szSound = PLUGIN_ROOT .. '/audio/MsgArrive.ogg',
		bPopupPreview = O.bShowPreview,
	})
	--------------------------------------------------------------------------------------
	-- 开始处理记录的数据保存
	-- 更新缓存数组 哈希表
	table.insert(RECORD_LIST, rec)
	RECORD_HASH[rec.hash] = (RECORD_HASH[rec.hash] or 0) + 1
	-- 验证记录是否超过限制条数
	local nOverflowed = #RECORD_LIST - O.nMaxRecord
	if nOverflowed > 0 then
		-- 处理记录列表
		for i = nOverflowed, 1, -1 do
			local hash = RECORD_LIST[1].hash
			if hash and RECORD_HASH[hash] then
				RECORD_HASH[hash] = RECORD_HASH[hash] - 1
				if RECORD_HASH[hash] <= 0 then
					RECORD_HASH[hash] = nil
				end
			end
			if l_uiBoard then
				l_uiBoard:RemoveItemUntilNewLine()
			end
			table.remove(RECORD_LIST, 1)
		end
	end
	-- if O.bRealtimeSave then
	--     D.SaveData()
	-- end
end

function D.Init()
	D.bReady = true
	D.LoadConfig()
	D.LoadData()
	D.RegisterMsgMonitor()
	X.RegisterWwiseSound(PLUGIN_ROOT .. '/audio/MsgArrive.ogg', 'UserPluginAudio_MY_Base_Notify')
end

function D.Exit()
	D.SaveData()
end

function D.RegisterMsgMonitor()
	for _, szChannel in ipairs(D.aCurrentChannel or X.CONSTANT.EMPTY_TABLE) do
		X.RegisterMsgMonitor(szChannel, 'MY_ChatMonitor', false)
	end
	local aChannel = {}
	if D.bReady then
		local tChannel = {}
		for _, p in ipairs(O.aKeyword) do
			if p.bEnable then
				for szChannel, bCapture in pairs(p.tChannel) do
					if bCapture then
						tChannel[szChannel] = true
					end
				end
			end
		end
		for szChannel, _ in pairs(tChannel) do
			table.insert(aChannel, szChannel)
		end
		for _, szChannel in ipairs(aChannel) do
			X.RegisterMsgMonitor(szChannel, 'MY_ChatMonitor', D.OnMsgArrive)
		end
	end
	D.aCurrentChannel = aChannel
end

-------------------------------------------------------------------------------------------------------
-- 快捷键设置
-------------------------------------------------------------------------------------------------------
X.RegisterHotKey('MY_ChatMonitor_Hotkey', _L['MY_ChatMonitor'], function()
	if O.bCapture then
		if l_uiBtn then
			l_uiBtn:Text(_L['start'])
		end
		O.bCapture = false
	else
		if l_uiBtn then
			l_uiBtn:Text(_L['stop'])
		end
		O.bCapture = true
	end
end, nil)

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_ChatMonitor', D.Init)

X.RegisterUserSettingsRelease('MY_ChatMonitor', function()
	D.bReady = false
	D.RegisterMsgMonitor()
end)
X.RegisterExit('MY_ChatMonitor', D.Exit)

--------------------------------------------------------------------------------
-- 面板注册
--------------------------------------------------------------------------------

local PS = {}

function PS.OnPanelActive(wnd)
	local ui = X.UI(wnd)
	local nW, nH = ui:Size()

	ui:Append('Text', { x = 22, y = 15, w = 100, h = 25, text = _L['key words:'] })

	ui:Append('WndComboBox', {
		x = 80, y = 15, w = nW - 246, h = 25,
		text = _L['Click to config monitors'],
		menu = function()
			local aKeyword = O.aKeyword
			local menu = { bAlignWidth = true }
			for i, p in ipairs(aKeyword) do
				local m = {}
				X.InsertMsgTypeMenu(m, function(szMsgType)
					return {
						fnAction = function(szChannel)
							p.tChannel[szChannel] = not p.tChannel[szChannel]
							O.aKeyword = aKeyword
							D.RegisterMsgMonitor()
						end,
						bChecked = p.tChannel[szMsgType],
					}
				end)
				for _, mm in ipairs(m) do
					mm.fnDisable = function()
						return not p.bEnable
					end
				end
				table.insert(m, 1, X.CONSTANT.MENU_DIVIDER)
				table.insert(m, 1, {
					szOption = _L['Edit'],
					fnAction = function()
						GetUserInput(_L['Please input keyword:'], function(szText)
							szText = X.TrimString(szText)
							if X.IsEmpty(szText) then
								return
							end
							p.szKeyword = szText
							O.aKeyword = aKeyword
							D.RegisterMsgMonitor()
						end, nil, nil, nil, p.szKeyword)
					end,
				})
				table.insert(m, 1, X.CONSTANT.MENU_DIVIDER)
				table.insert(m, 1, {
					szOption = _L['Enable'],
					bCheck = true, bChecked = p.bEnable,
					fnAction = function()
						p.bEnable = not p.bEnable
						O.aKeyword = aKeyword
						D.RegisterMsgMonitor()
					end,
				})
				table.insert(m, X.CONSTANT.MENU_DIVIDER)
				table.insert(m, {
					szOption = _L['regular expression'],
					bCheck = true, bChecked = p.bIsRegexp,
					fnAction = function()
						if p.bIsRegexp or IsShiftKeyDown() then
							p.bIsRegexp = not p.bIsRegexp
							O.aKeyword = aKeyword
						else
							MessageBox({
								szName = 'MY_ChatMonitor_Regexp',
								szMessage = _L['Are you sure you want to turn on regex mode?\nRegex is something advanced, make sure you know what you are doing.\nHold shift key next time to skip this alert.'],
								{
									szOption = g_tStrings.STR_HOTKEY_SURE,
									fnAction = function()
										p.bIsRegexp = not p.bIsRegexp
										O.aKeyword = aKeyword
									end,
								},
								{ szOption = g_tStrings.STR_HOTKEY_CANCEL },
							})
						end
					end,
					fnDisable = function() return not p.bEnable end,
				})
				table.insert(m, X.CONSTANT.MENU_DIVIDER)
				table.insert(m, {
					szOption = _L['Delete'],
					fnAction = function()
						table.remove(aKeyword, i)
						O.aKeyword = aKeyword
						O.aKeyword = aKeyword
						D.RegisterMsgMonitor()
						X.UI.ClosePopupMenu()
					end,
				})
				m.szOption = p.szKeyword
				table.insert(menu, m)
			end
			if #menu > 0 then
				table.insert(menu, X.CONSTANT.MENU_DIVIDER)
			end
			table.insert(menu, {
				szOption = _L['Add'],
				fnAction = function()
					GetUserInput(_L['Please input keyword:'], function(szText)
						szText = X.TrimString(szText)
						if X.IsEmpty(szText) then
							return
						end
						table.insert(aKeyword, {
							szKeyword = szText,
							bEnable = true,
							bIsRegexp = false,
							tChannel = X.Clone(DEFAULE_CHANNEL),
						})
						O.aKeyword = aKeyword
						O.aKeyword = aKeyword
						D.RegisterMsgMonitor()
					end)
				end,
			})
			return menu
		end,
	})

	ui:Append('Image', {
		image = 'UI/Image/UICommon/Commonpanel2.UITex', imageFrame = 48,
		x = nW - 160, y = 18, w = 20, h = 20, alpha = 180,
		onHover = function(bIn) this:SetAlpha(bIn and 255 or 180) end,
		onClick = function()
			local szText = GetFormatText(_L['CHAT_MONITOR_TIP'], 162)
			local x, y = Cursor.GetPos()
			local w, h = this:GetSize()
			OutputTip(szText, 450, {x, y, w, h})
		end,
	})

	ui:Append('WndButton', {
		x = nW - 26, y = 15, w = 25, h = 25,
		buttonStyle = 'OPTION',
		menu = function()
			local t = {
				{
					szOption = _L['timestrap format'], {
						szOption = '[%hh:%mm:%ss]',
						fnAction = function()
							O.szTimestrap = '[%hh:%mm:%ss]'
						end,
						bCheck = true, bMCheck = true,
						bChecked = O.szTimestrap == '[%hh:%mm:%ss]'
					}, {
						szOption = '[%MM/%dd %hh:%mm:%ss]',
						fnAction = function()
							O.szTimestrap = '[%MM/%dd %hh:%mm:%ss]'
						end,
						bCheck = true, bMCheck = true,
						bChecked = O.szTimestrap == '[%MM/%dd %hh:%mm:%ss]'
					}, {
						szOption = _L['custom'],
						fnAction = function()
							GetUserInput(_L['custom timestrap (eg:[%yyyy/%MM/%dd_%hh:%mm:%ss])'], function(szText)
								O.szTimestrap = szText
							end, nil, nil, nil, O.szTimestrap)
						end,
					},
				},
				{
					szOption = _L['max record count'],
					fnAction = function()
						GetUserInputNumber(O.nMaxRecord, 1000, nil, function(val)
							O.nMaxRecord = val or O.nMaxRecord
						end, nil, function() return not X.Panel.IsVisible() end)
					end,
				},
				{
					szOption = _L['show message preview box'],
					fnAction = function()
						O.bShowPreview = not O.bShowPreview
					end,
					bCheck = true,
					bChecked = O.bShowPreview
				},
				{
					szOption = _L['play new message alert sound'],
					fnAction = function()
						O.bPlaySound = not O.bPlaySound
					end,
					bCheck = true,
					bChecked = O.bPlaySound
				},
				{
					szOption = _L['output to system channel'],
					fnAction = function()
						O.bRedirectSysChannel = not O.bRedirectSysChannel
					end,
					bCheck = true,
					bChecked = O.bRedirectSysChannel
				},
				{
					szOption = _L['ignore same message'],
					fnAction = function()
						O.bIgnoreSame = not O.bIgnoreSame
					end,
					bCheck = true,
					bChecked = O.bIgnoreSame
				}
			}
			if IsShiftKeyDown() then
				-- table.insert(t, {
				--     szOption = _L['Realtime save'],
				--     fnAction = function()
				--         O.bRealtimeSave = not O.bRealtimeSave
				--     end,
				--     bCheck = true,
				--     bChecked = O.bRealtimeSave
				-- })
				table.insert(t, {
					szOption = _L['Distinct server'],
					fnAction = function()
						O.bDistinctServer = not O.bDistinctServer
						D.LoadData()
						X.Panel.SwitchTab('MY_ChatMonitor', true)
					end,
					bCheck = true,
					bChecked = O.bDistinctServer
				})
			end
			return t
		end,
	})

	l_uiBtn = ui:Append('WndButton', {
		name = 'Button_ChatMonitor_Switcher',
		x = nW - 134, y = 15, w = 50, h = 25,
		buttonStyle = 'FLAT',
		text = (O.bCapture and _L['stop']) or _L['start'],
		onClick = function()
			if O.bCapture then
				X.UI(this):Text(_L['start'])
				O.bCapture = false
			else
				X.UI(this):Text(_L['stop'])
				O.bCapture = true
			end
		end,
	})

	ui:Append('WndButton', {
		x = nW - 79, y = 15, w = 50, h = 25,
		buttonStyle = 'FLAT',
		text = _L['clear'],
		onClick = function()
			RECORD_LIST = {}
			RECORD_HASH = {}
			l_uiBoard:Clear()
		end,
	})

	l_uiBoard = ui:Append('WndScrollHandleBox', {
		name = 'WndScrollHandleBox_TalkList',
		x = 20, y = 50, w = nW - 21, h = nH - 70, handleStyle = 3,
	})

	for i = 1, #RECORD_LIST, 1 do
		l_uiBoard:Append(D.GetHTML(RECORD_LIST[i]))
	end
	l_uiBoard:Scroll(100)
end

function PS.OnPanelDeactive()
	l_uiBtn = nil
	l_uiBoard = nil
end

X.Panel.Register(_L['Chat'], 'MY_ChatMonitor', _L['MY_ChatMonitor'], 'UI/Image/Minimap/Minimap.UITex|197', PS)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
