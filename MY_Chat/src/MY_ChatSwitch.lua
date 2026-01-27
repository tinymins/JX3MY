--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 聊天频道切换
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Chat/MY_ChatSwitch'
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_ChatSwitch'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.3') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------
local O = X.CreateUserSettingsModule(MODULE_NAME, _L['Chat'], {
	bDisplayPanel = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_ChatSwitch'],
			_L['display panel'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	anchor = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_ChatSwitch'],
			_L['UI Anchor'],
		}),
		xSchema = X.Schema.FrameAnchor,
		xDefaultValue = { x = 10, y = -60, s = 'BOTTOMLEFT', r = 'BOTTOMLEFT' },
	},
	bLockPostion = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_ChatSwitch'],
			_L['lock postion'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	tChennalVisible = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_ChatSwitch'],
			_L['channel setting'],
		}),
		xSchema = X.Schema.Map(X.Schema.String, X.Schema.Boolean),
		xDefaultValue = {},
	},
	aWhisper = {
		ePathType = X.PATH_TYPE.ROLE,
		bUserData = true,
		xSchema = X.Schema.Collection(
			X.Schema.Tuple(
				X.Schema.String, -- szName
				X.Schema.Collection( -- aHistory
					X.Schema.OneOf(
						X.Schema.String, -- szMsg
						X.Schema.Tuple(X.Schema.String, X.Schema.Number) -- szMsg, nTime
					)
				)
			)
		),
		xDefaultValue = {},
	},
	szAway = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_ChatSwitch'],
			_L['away message'],
		}),
		xSchema = X.Schema.String,
		xDefaultValue = '',
	},
	szBusy = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_ChatSwitch'],
			_L['busy message'],
		}),
		xSchema = X.Schema.String,
		xDefaultValue = '',
	},
	tChannelCount = {
		ePathType = X.PATH_TYPE.ROLE,
		bUserData = true,
		xSchema = X.Schema.Record({
			szDate = X.Schema.String,
			tCount = X.Schema.Map(X.Schema.Number, X.Schema.Number),
		}),
		xDefaultValue = {
			szDate = '',
			tCount = {},
		},
	},
	bAutoSwitchBfChannel = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_ChatSwitch'],
			_L['Auto switch talk channel when into battle field'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}

local INI_PATH = X.PACKET_INFO.ROOT .. 'MY_Chat/ui/MY_ChatSwitch.ini'
local CD_REFRESH_OFFSET = 7 * 60 * 60 -- 7点更新CD

local function UpdateChannelDailyLimit(hRadio, bPlus)
	local me = X.GetClientPlayer()
	local shaCount = hRadio and hRadio.shaCount
	if not (me and shaCount) then
		return
	end

	local dwPercent = 1
	local info = hRadio.info
	local nChannel = info.channel
	if nChannel then
		local szDate = X.FormatTime(GetCurrentTime() - CD_REFRESH_OFFSET, '%yyyy%MM%dd')
		local tChannelCount = D.tChannelCount
		if tChannelCount.szDate ~= szDate then
			tChannelCount = {
				szDate = szDate,
				tCount = {},
			}
			D.tChannelCount = tChannelCount
			D.bChannelCountChanged = true
		end
		local nDailyCount = (tChannelCount.tCount[nChannel] or 0) + (bPlus and 1 or 0)
		if nDailyCount ~= tChannelCount.tCount[nChannel] then
			tChannelCount.tCount[nChannel] = nDailyCount
			D.bChannelCountChanged = true
		end
		local nDailyLimit = X.GetChatChannelDailyLimit(me.nLevel, nChannel)
		if nDailyLimit then
			if nDailyLimit > 0 then
				dwPercent = (nDailyLimit - nDailyCount) / nDailyLimit
				hRadio.szTip = GetFormatText(_L('Today: %d\nDaily limit: %d', nDailyCount, nDailyLimit), nil, 255, 255, 0)
			else
				hRadio.szTip = GetFormatText(_L('Today: %d\nDaily limit: no limitation', nDailyCount), nil, 255, 255, 0)
			end
		end
	end
	X.UI(shaCount):DrawCircle(nil, nil, nil, info.color[1], info.color[2], info.color[3], 100, math.pi / 2, math.pi * 2 * dwPercent)
end

local CHANNEL_LIST = {
	{ -- 说
		id = 'nearby',
		title = _L['SAY'],
		channel = PLAYER_TALK_CHANNEL.NEARBY,
		cd = 0,
		color = {255, 255, 255},
	},
	{ -- 地
		id = 'sence',
		title = _L['MAP'],
		channel = PLAYER_TALK_CHANNEL.SENCE,
		cd = 10,
		color = {255, 126, 126},
	},
	{ -- 世
		id = 'world',
		title = _L['WORLD'],
		channel = PLAYER_TALK_CHANNEL.WORLD,
		cd = 60,
		color = {252, 204, 204},
	},
	{ -- 队
		id = 'team',
		title = _L['PARTY'],
		channel = PLAYER_TALK_CHANNEL.TEAM,
		cd = 0,
		color = {140, 178, 253},
	},
	{ -- 团
		id = 'raid',
		title = _L['TEAM'],
		channel = PLAYER_TALK_CHANNEL.RAID,
		cd = 0,
		color = { 73, 168, 241},
	},
	{ -- 房
		id = 'room',
		title = _L['ROOM'],
		channel = PLAYER_TALK_CHANNEL.ROOM,
		cd = 0,
		color = { 73, 168, 241},
	},
	{ -- 战
		id = 'battle_field',
		title = _L['BATTLE'],
		channel = PLAYER_TALK_CHANNEL.BATTLE_FIELD,
		cd = 0,
		color = {255, 126, 126},
	},
	{ -- 帮
		id = 'tong',
		title = _L['FACTION'],
		channel = PLAYER_TALK_CHANNEL.TONG,
		cd = 0,
		color = {  0, 200,  72},
	},
	{ -- 派
		id = 'force',
		title = _L['SCHOOL'],
		channel = PLAYER_TALK_CHANNEL.FORCE,
		cd = 20,
		color = {  0, 255, 255},
	},
	{ -- 阵
		id = 'camp',
		title = _L['CAMP'],
		channel = PLAYER_TALK_CHANNEL.CAMP,
		cd = 30,
		color = {155, 230,  58},
	},
	{ -- 友
		id = 'friends',
		title = _L['FRIEND'],
		channel = PLAYER_TALK_CHANNEL.FRIENDS,
		cd = 10,
		color = {241, 114, 183},
	},
	{ -- 盟
		id = 'tong_alliance',
		title = _L['ALLIANCE'],
		channel = PLAYER_TALK_CHANNEL.TONG_ALLIANCE,
		cd = 0,
		color = {178, 240, 164},
	},
	{ -- 密
		id = 'whisper',
		title = _L['WHISPER'],
		channel = PLAYER_TALK_CHANNEL.WHISPER,
		cd = 0,
		onClick = function()
			if IsCtrlKeyDown() then
				GetUserInput(_L['Please input whisper name'], function(szName)
					if szName == '' then
						return
					end
					X.SwitchChatChannel(szName)
					X.DelayCall(X.FocusChatInput)
				end, nil, nil, nil, '')
			else
				local t = {}
				for i, whisper in ipairs(D.aWhisper) do
					local info = MY_Farbnamen and MY_Farbnamen.Get(whisper[1])
					table.insert(t, {
						szOption = whisper[1],
						rgb = info and info.rgb or {202, 126, 255},
						fnAction = function()
							X.SwitchChatChannel(whisper[1])
							X.DelayCall(X.FocusChatInput)
						end,
						szIcon = 'ui/Image/UICommon/CommonPanel2.UITex',
						nFrame = 49,
						nMouseOverFrame = 51,
						nIconWidth = 17,
						nIconHeight = 17,
						szLayer = 'ICON_RIGHTMOST',
						fnClickIcon = function()
							for i = #D.aWhisper, 1, -1 do
								if D.aWhisper[i][1] == whisper[1] then
									table.remove(D.aWhisper, i)
									X.UI.ClosePopupMenu()
								end
							end
							O.aWhisper = D.aWhisper
							D.bWhisperChanged = false
						end,
						fnMouseEnter = function()
							local t = {}
							local today = X.FormatTime(GetCurrentTime(), '%yyyy%MM%dd')
							local r, g, b = GetMsgFontColor('MSG_WHISPER')
							for _, v in ipairs(whisper[2]) do
								if X.IsString(v) then
									table.insert(t, v)
								elseif X.IsTable(v) and X.IsString(v[1]) then
									if today == X.FormatTime(v[2], '%yyyy%MM%dd') then
										table.insert(t, X.GetChatTimeXML(v[2], {r = r, g = g, b = b, s = '[%hh:%mm:%ss]'}) .. v[1])
									else
										table.insert(t, X.GetChatTimeXML(v[2], {r = r, g = g, b = b, s = '[%M.%dd.%hh:%mm:%ss]'}) .. v[1])
									end
								end
							end
							local szMsg = table.concat(t, '')
							if MY_ChatEmotion and MY_ChatEmotion.Render then
								szMsg = MY_ChatEmotion.Render(szMsg)
							end
							if MY_Farbnamen then
								szMsg = MY_Farbnamen.Render(szMsg)
							end
							OutputTip(szMsg, 600, {this:GetAbsX(), this:GetAbsY(), this:GetW(), this:GetH()}, ALW.RIGHT_LEFT)
						end,
					})
				end
				local x, y = this:GetAbsPos()
				t.x = x
				t.y = y - #D.aWhisper * 24 - 24 - 20 - 8
				if #t > 0 then
					table.insert(t, 1, X.CONSTANT.MENU_DIVIDER)
					table.insert(t, 1, {
						szOption = g_tStrings.CHANNEL_WHISPER_SIGN,
						rgb = {202, 126, 255},
						fnAction = function()
							X.SwitchChatChannel(PLAYER_TALK_CHANNEL.WHISPER)
							X.DelayCall(X.FocusChatInput)
						end,
					})
					PopupMenu(t)
				else
					X.SwitchChatChannel(PLAYER_TALK_CHANNEL.WHISPER)
				end
			end
			this:Check(false)
		end,
		color = {202, 126, 255},
	},
	{ -- 清
		id = 'cls',
		title = _L['CLS'],
		onClick = function()
			local function Cls(bAll)
				for _, k in X.pairs_c(X.CONSTANT.CHAT_PANEL_INDEX_LIST) do
					local hFrame = X.GetChatPanel(k)
					if hFrame then
						local h = hFrame:Lookup('Wnd_Message', 'Handle_Message')
						local hCheck = hFrame:Lookup('CheckBox_Title')
						if h and (bAll or (hCheck and hCheck:IsCheckBoxChecked())) then
							h:Clear()
							h:FormatAllItemPos()
						end
					end
				end
			end
			if IsCtrlKeyDown() then
				Cls()
			elseif IsAltKeyDown() then
				MessageBox({
					szName = 'CLS_CHATPANEL_ALL',
					szMessage = _L['Are you sure you want to clear all message panel?'], {
						szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function()
							Cls(true)
						end
					}, { szOption = g_tStrings.STR_HOTKEY_CANCEL },
				})
			else
				MessageBox({
					szName = 'CLS_CHATPANEL',
					szMessage = _L['Are you sure you want to clear current message panel?\nPress CTRL when click can clear without alert.\nPress ALT when click can clear all window.'], {
						szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function()
							Cls()
						end
					}, { szOption = g_tStrings.STR_HOTKEY_CANCEL },
				})
			end
			X.UI(this):Check(false)
		end,
		color = {255, 0, 0},
	},
	{ -- 离
		id = 'away',
		title = _L['AWAY'],
		onCheck = function()
			X.SwitchChatChannel('/afk')
			local edit = X.GetChatInput()
			if edit then
				edit:GetRoot():Show()
				if edit:GetText() == '' then
					edit:InsertText(
						X.IsEmpty(O.szAway)
							and g_tStrings.STR_AUTO_REPLAY_LEAVE
							or O.szAway
					)
					edit:SelectAll()
				end
				Station.SetFocusWindow(edit)
			end
		end,
		onUncheck = function()
			X.SwitchChatChannel('/cafk')
		end,
		tip = function()
			return X.IsEmpty(O.szAway)
				and g_tStrings.STR_AUTO_REPLAY_LEAVE
				or O.szAway
		end,
		color = {255, 255, 255},
	},
	{ -- 扰
		id = 'busy',
		title = _L['BUSY'],
		onCheck = function()
			X.SwitchChatChannel('/atr')
			local edit = X.GetChatInput()
			if edit then
				edit:GetRoot():Show()
				if edit:GetText() == '' then
					edit:InsertText(
						X.IsEmpty(O.szBusy)
							and g_tStrings.STR_AUTO_REPLAY_LEAVE
							or O.szBusy
					)
					edit:SelectAll()
				end
				Station.SetFocusWindow(edit)
			end
		end,
		onUncheck = function()
			X.SwitchChatChannel('/catr')
		end,
		tip = function()
			return X.IsEmpty(O.szBusy)
				and g_tStrings.STR_AUTO_REPLAY_LEAVE
				or O.szBusy
		end,
		color = {255, 255, 255},
	},
	{ -- 马
		id = 'mosaics',
		title = _L['MOSAICS'],
		onCheck = function()
			MY_ChatMosaics.bEnabled = true
		end,
		onUncheck = function()
			MY_ChatMosaics.bEnabled = false
		end,
		color = {255, 255, 255},
	},
}

local CHANNEL_CD_TIME = {}
for i, v in ipairs(CHANNEL_LIST) do
	if v.channel then
		CHANNEL_CD_TIME[v.channel] = v.cd
	end
end
local m_tChannelTime = {}

local function OnChannelCheck()
	X.SwitchChatChannel(this.info.channel)
	local edit = X.GetChatInput()
	if edit then
		edit:GetRoot():Show()
		Station.SetFocusWindow(edit)
	end
	this:Check(false)
end

function D.ApplyBattlefieldChannelSwitch()
	-- 名剑大会自动切换团队频道
	if O.bAutoSwitchBfChannel then
		X.RegisterEvent('LOADING_ENDING', 'MY_ChatSwitch__AutoSwitchBattlefieldChannel', function()
			local bIsBattleField = (X.GetClientPlayer().GetScene().nType == MAP_TYPE.BATTLE_FIELD)
			local nChannel, szName = EditBox_GetChannel()
			if bIsBattleField and (nChannel == PLAYER_TALK_CHANNEL.RAID or nChannel == PLAYER_TALK_CHANNEL.TEAM) then
				D.nJJCAutoSwitchChatChannel_OrgChannel = nChannel
				X.SwitchChatChannel(PLAYER_TALK_CHANNEL.BATTLE_FIELD)
			elseif not bIsBattleField and nChannel == PLAYER_TALK_CHANNEL.BATTLE_FIELD then
				X.SwitchChatChannel(D.nJJCAutoSwitchChatChannel_OrgChannel or PLAYER_TALK_CHANNEL.RAID)
			end
		end)
	else
		X.RegisterEvent('LOADING_ENDING', 'MY_ChatSwitch__AutoSwitchBattlefieldChannel')
	end
end

function D.OnFrameCreate()
	this.tRadios = {}
	this:RegisterEvent('UI_SCALED')
	this:RegisterEvent('PLAYER_SAY')
	this:RegisterEvent('LOADING_ENDING')
	this:EnableDrag(not O.bLockPostion)

	local nWidth, nHeight = 0, 0
	local container = this:Lookup('WndContainer_Radios')
	container:Clear()
	for i, v in ipairs(CHANNEL_LIST) do
		if O.tChennalVisible[v.id] ~= false then
			local wnd, chk, txtTitle, txtCooldown, shaCount
			if v.onClick then
				wnd = container:AppendContentFromIni(INI_PATH, 'Wnd_Channel')
				chk = wnd:Lookup('WndRadioChannel')
				txtTitle = chk:Lookup('', 'Text_Channel')
				txtCooldown = chk:Lookup('', 'Text_CD')
				shaCount = chk:Lookup('', 'Shadow_Count')
				chk.OnCheckBoxCheck = v.onClick
			elseif v.channel and X.CONSTANT.PLAYER_TALK_CHANNEL_HEADER[v.channel] then
				wnd = container:AppendContentFromIni(INI_PATH, 'Wnd_Channel')
				chk = wnd:Lookup('WndRadioChannel')
				txtTitle = chk:Lookup('', 'Text_Channel')
				txtCooldown = chk:Lookup('', 'Text_CD')
				shaCount = chk:Lookup('', 'Shadow_Count')
				chk.OnCheckBoxCheck = OnChannelCheck
			elseif v.onCheck or v.onUncheck then
				wnd = container:AppendContentFromIni(INI_PATH, 'Wnd_CheckBox')
				chk = wnd:Lookup('WndCheckBox')
				txtTitle = chk:Lookup('', 'Text_CheckBox')
				chk.OnCheckBoxCheck = v.onCheck
				chk.OnCheckBoxUncheck = v.onUncheck
			end
			if wnd and chk then
				wnd:SetRelX(nWidth)
				nWidth = nWidth + math.ceil(wnd:GetW())
				nHeight = math.max(nHeight, math.ceil(wnd:GetH()))
				chk.txtTitle = txtTitle
				chk.txtCooldown = txtCooldown
				chk.shaCount = shaCount
				if v.channel then
					this.tRadios[v.channel] = chk
				end
				if v.tip then
					X.UI(chk):Tip(v.tip, X.UI.TIP_POSITION.CENTER)
				end
				if txtTitle then
					txtTitle:SetText(v.title)
					txtTitle:SetFontScheme(197)
					txtTitle:SetFontColor(unpack(v.color or {255, 255, 255}))
				end
				if txtCooldown then
					txtCooldown:SetText('')
					txtCooldown:SetFontScheme(197)
					txtCooldown:SetFontColor(unpack(v.color or {255, 255, 255}))
				end
				if shaCount then
					X.UI(shaCount):DrawCircle(0, 0, 0)
				end
				chk.info = v
				UpdateChannelDailyLimit(chk)
			end
		end
	end
	container:SetSize(nWidth, nHeight)

	this:Lookup('', 'Image_Bar'):SetW(nWidth + 35)
	this:SetW(nWidth + 60)
	D.UpdateAnchor(this)
end

function D.OnEvent(event)
	if event == 'PLAYER_SAY' then
		local szContent, dwTalkerID, nChannel, szName, szMsg = arg0, arg1, arg2, arg3, arg9
		if not X.IsString(arg9) then
			szMsg = arg11
		elseif X.IsString(arg11) then
			szMsg = #arg9 > #arg11 and arg9 or arg11
		end
		if nChannel == PLAYER_TALK_CHANNEL.WHISPER then
			local t
			for i = #D.aWhisper, 1, -1 do
				if D.aWhisper[i][1] == szName then
					t = table.remove(D.aWhisper, i)
				end
			end
			while #D.aWhisper > 20 do
				table.remove(D.aWhisper, 1)
			end
			if not t then
				t = {szName, {}}
			end
			while #t[2] > 20 do
				table.remove(t[2], 1)
			end
			table.insert(t[2], {szMsg, GetCurrentTime()})
			table.insert(D.aWhisper, t)
			D.bWhisperChanged = true
		end
		if dwTalkerID ~= X.GetClientPlayerID() then
			return
		end
		local hRadio = this.tRadios[nChannel]
		if hRadio then
			UpdateChannelDailyLimit(hRadio, true)
			m_tChannelTime[nChannel] = GetCurrentTime()
		end
	elseif event == 'UI_SCALED' then
		D.UpdateAnchor(this)
	elseif event == 'LOADING_ENDING' then
		for nChannel, hRadio in pairs(this.tRadios) do
			UpdateChannelDailyLimit(hRadio)
		end
	end
end

function D.OnFrameBreathe()
	for nChannel, nTime in pairs(m_tChannelTime) do
		local nCooldown = (CHANNEL_CD_TIME[nChannel] or 0) - (GetCurrentTime() - nTime)
		if nCooldown <= 0 then
			m_tChannelTime[nChannel] = nil
		end

		local hCheck = this.tRadios[nChannel]
		local txtCooldown = hCheck and hCheck.txtCooldown
		if txtCooldown then
			txtCooldown:SetText(nCooldown > 0 and nCooldown or '')
		end
	end
end

function D.OnMouseEnter()
	if this.szTip then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(this.szTip, 450, {x, y, w, h}, ALW.RIGHT_LEFT_AND_BOTTOM_TOP)
	end
end

function D.OnMouseLeave()
	HideTip()
end

function D.OnLButtonClick()
	local name = this:GetName()
	if name == 'Btn_Option' then
		X.Panel.Show()
		X.Panel.Focus()
		X.Panel.SwitchTab('MY_ChatSwitch')
	end
end

function D.OnFrameDragEnd()
	this:CorrectPos()
	O.anchor = GetFrameAnchor(this)
end

function D.OnFrameDragSetPosEnd()
	this:CorrectPos()
end

function D.UpdateAnchor(this)
	local anchor = O.anchor
	this:SetPoint(anchor.s, 0, 0, anchor.r, anchor.x, anchor.y)
	this:CorrectPos()
end

local function OnChatSetAFK()
	if type(arg0) == 'table' then
		O.szAway = X.StringifyChatText(arg0)
	else
		O.szAway = arg0 and tostring(arg0) or ''
	end
end
X.RegisterEvent('ON_CHAT_SET_AFK', OnChatSetAFK)

local function OnChatSetATR()
	if type(arg0) == 'table' then
		O.szBusy = X.StringifyChatText(arg0):sub(4)
	else
		O.szBusy = arg0 and tostring(arg0) or ''
	end
end
X.RegisterEvent('ON_CHAT_SET_ATR', OnChatSetATR)

function D.ReInitUI()
	X.UI.CloseFrame('MY_ChatSwitch')
	if not O.bDisplayPanel then
		return
	end
	X.UI.OpenFrame(INI_PATH, 'MY_ChatSwitch')
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	nX = nPaddingX
	ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 250,
		text = _L['display panel'],
		checked = O.bDisplayPanel,
		onCheck = function(bChecked)
			O.bDisplayPanel = bChecked
			D.ReInitUI()
		end,
	})
	nY = nY + nLH

	nX = nX + 25

	ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 250,
		text = _L['lock postion'],
		checked = O.bLockPostion,
		onCheck = function(bChecked)
			O.bLockPostion = bChecked
			D.ReInitUI()
		end,
		autoEnable = function()
			return O.bDisplayPanel
		end,
	})
	nY = nY + nLH

	ui:Append('WndComboBox', {
		x = nX, y = nY, w = 150, h = 25,
		text = _L['channel setting'],
		menu = function()
			local t = {
				szOption = _L['channel setting'],
				fnDisable = function()
					return not O.bDisplayPanel
				end,
			}
			for i, v in ipairs(CHANNEL_LIST) do
				table.insert(t, {
					szOption = v.title, rgb = v.color,
					bCheck = true, bChecked = O.tChennalVisible[v.id] ~= false,
					fnAction = function()
						O.tChennalVisible[v.id] = not O.tChennalVisible[v.id]
						O.tChennalVisible = O.tChennalVisible
						D.ReInitUI()
					end,
				})
			end
			return t
		end,
		autoEnable = function()
			return O.bDisplayPanel
		end,
	})
	nY = nY + nLH

	nX = nPaddingX
	-- 名剑大会频道切换
	ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Auto switch talk channel when into battle field'],
		checked = O.bAutoSwitchBfChannel,
		onCheck = function(bChecked)
			O.bAutoSwitchBfChannel = bChecked
			D.ApplyBattlefieldChannelSwitch()
		end,
	})
	nY = nY + nLH

	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_ChatSwitch',
	exports = {
		{
			preset = 'UIEvent',
			fields = {
				'OnPanelActivePartial',
			},
			root = D,
		},
	},
}
MY_ChatSwitch = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_ChatSwitch__AutoSwitchBattlefieldChannel', function()
	D.aWhisper = O.aWhisper
	D.tChannelCount = O.tChannelCount
	D.ApplyBattlefieldChannelSwitch()
end)

X.RegisterUserSettingsRelease('MY_ChatSwitch__AutoSwitchBattlefieldChannel', function()
	if D.bWhisperChanged then
		O.aWhisper = D.aWhisper
	end
	if D.bChannelCountChanged then
		O.tChannelCount = D.tChannelCount
	end
end)

X.RegisterUserSettingsInit('MY_ChatSwitch__UI', D.ReInitUI)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
