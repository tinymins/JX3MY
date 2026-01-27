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
local MODULE_PATH = 'MY_Chat/MY_ChatBlock'
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_ChatBlock'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.0') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------
local TALK_CHANNEL_MSG_TYPE = {
	[PLAYER_TALK_CHANNEL.NEARBY       ] = 'MSG_NORMAL'        ,
	[PLAYER_TALK_CHANNEL.SENCE        ] = 'MSG_MAP'           ,
	[PLAYER_TALK_CHANNEL.WORLD        ] = 'MSG_WORLD'         ,
	[PLAYER_TALK_CHANNEL.TEAM         ] = 'MSG_PARTY'         ,
	[PLAYER_TALK_CHANNEL.RAID         ] = 'MSG_TEAM'          ,
	[PLAYER_TALK_CHANNEL.BATTLE_FIELD ] = 'MSG_BATTLE_FILED'  ,
	[PLAYER_TALK_CHANNEL.TONG         ] = 'MSG_GUILD'         ,
	[PLAYER_TALK_CHANNEL.FORCE        ] = 'MSG_SCHOOL'        ,
	[PLAYER_TALK_CHANNEL.CAMP         ] = 'MSG_CAMP'          ,
	[PLAYER_TALK_CHANNEL.WHISPER      ] = 'MSG_WHISPER'       ,
	[PLAYER_TALK_CHANNEL.FRIENDS      ] = 'MSG_FRIEND'        ,
	[PLAYER_TALK_CHANNEL.TONG_ALLIANCE] = 'MSG_GUILD_ALLIANCE',
	[PLAYER_TALK_CHANNEL.LOCAL_SYS    ] = 'MSG_SYS'           ,
}
local MSG_TYPE_TALK_CHANNEL = X.FlipObjectKV(TALK_CHANNEL_MSG_TYPE)

local DEFAULT_KW_CONFIG = {
	szKeyword = '',
	tMsgType = {
		['MSG_NORMAL'        ] = true,
		['MSG_MAP'           ] = true,
		['MSG_WORLD'         ] = true,
		['MSG_SCHOOL'        ] = true,
		['MSG_CAMP'          ] = true,
		['MSG_WHISPER'       ] = true,
	},
	bIgnoreAcquaintance = true,
	bIgnoreCase = true, bIgnoreEnEm = true, bIgnoreSpace = true,
}

local O = X.CreateUserSettingsModule('MY_ChatBlock', _L['Chat'], {
	bBlockWords = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatBlock'],
		szDescription = X.MakeCaption({
			_L['Enable state'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	aBlockWords = {
		ePathType = X.PATH_TYPE.GLOBAL,
		szLabel = _L['MY_ChatBlock'],
		szDescription = X.MakeCaption({
			_L['BlockWords'],
		}),
		xSchema = X.Schema.Collection(X.Schema.Record({
			uuid = X.Schema.Optional(X.Schema.String),
			szKeyword = X.Schema.String,
			tMsgType = X.Schema.Map(X.Schema.String, X.Schema.Boolean),
			bTeamBuilding = X.Schema.Optional(X.Schema.Boolean),
			bTongName = X.Schema.Optional(X.Schema.Boolean),
			bIgnoreAcquaintance = X.Schema.Boolean,
			bIgnoreCase = X.Schema.Boolean,
			bIgnoreEnEm = X.Schema.Boolean,
			bIgnoreSpace = X.Schema.Boolean,
		})),
		xDefaultValue = {},
	},
	tBlockHistory = {
		ePathType = X.PATH_TYPE.GLOBAL,
		szLabel = _L['MY_ChatBlock'],
		bDataSet = true,
		xSchema = X.Schema.Record({
			nCount = X.Schema.Number,
			aRecent = X.Schema.Collection(X.Schema.String),
		}),
		xDefaultValue = { nCount = 0, aRecent = {} },
		bPersistImmediatelyOnChange = false,
	},
})
local D = {}

function D.IsBlockMsg(szText, szMsgType, dwTalkerID)
	local bAcquaintance = dwTalkerID
		and (X.IsFellowship(dwTalkerID) or X.IsFoe(dwTalkerID) or X.IsTongMember(dwTalkerID))
		or false
	for _, bw in ipairs(D.aBlockWords) do
		if bw.tMsgType[szMsgType] and (not bAcquaintance or not bw.bIgnoreAcquaintance) then
			if X.StringSimpleMatch(szText, bw.szKeyword, not bw.bIgnoreCase, not bw.bIgnoreEnEm, bw.bIgnoreSpace) then
				return true, bw.uuid
			end
			if bw.bTongName and _G.MY_Farbnamen and _G.MY_Farbnamen.Get then
				local info = _G.MY_Farbnamen.Get(dwTalkerID)
				if info and info.szTongName == bw.szKeyword then
					return true, bw.uuid
				end
			end
		end
	end
	return false
end

function D.OnTalkFilter(nChannel, t, dwTalkerID, szName, bEcho, bOnlyShowBallon, bSecurity, bGMAccount, bCheater, dwTitleID, dwIdePetTemplateID)
	local szType = TALK_CHANNEL_MSG_TYPE[nChannel]
	if not szType then
		return
	end
	local szText = X.StringifyChatText(t)
	local bBlock, uuid = D.IsBlockMsg(szText, szType, dwTalkerID)
	if bBlock then
		if D.bReady and uuid then
			O.tBlockHistory[uuid].nCount = O.tBlockHistory[uuid].nCount + 1
			if #O.tBlockHistory[uuid].aRecent >= 10 then
				table.remove(O.tBlockHistory[uuid].aRecent, 1)
			end
			local szMsgType = TALK_CHANNEL_MSG_TYPE[nChannel]
			local nFont = szMsgType and GetMsgFont(szMsgType)
			local r, g, b = GetMsgFontColor(nFont, true)
			table.insert(
				O.tBlockHistory[uuid].aRecent,
				X.GetChatTimeXML(GetCurrentTime(), {
					r = r, g = g, b = b, f = nFont,
					s = '[%yyyy/%MM/%dd][%hh:%mm:%ss]',
				}) .. X.XmlifyChatData(t, r, g, b, nFont)
			)
			O.tBlockHistory[uuid] = O.tBlockHistory[uuid]
		end
		return true
	end
end

function D.OnMsgFilter(szMsg, nFont, bRich, r, g, b, szType, dwTalkerID, szName)
	local bBlock, uuid = D.IsBlockMsg(bRich and GetPureText(szMsg) or szMsg, szType, dwTalkerID)
	if bBlock then
		if D.bReady and uuid then
			O.tBlockHistory[uuid].nCount = O.tBlockHistory[uuid].nCount + 1
			if #O.tBlockHistory[uuid].aRecent >= 10 then
				table.remove(O.tBlockHistory[uuid].aRecent, 1)
			end
			table.insert(
				O.tBlockHistory[uuid].aRecent,
				X.GetChatTimeXML(GetCurrentTime(), {
					r = r, g = g, b = b, f = nFont,
					s = '[%yyyy/%MM/%dd][%hh:%mm:%ss]',
				}) .. (bRich and szMsg or GetFormatText(szMsg, nFont, r, g, b))
			)
			O.tBlockHistory[uuid] = O.tBlockHistory[uuid]
		end
		return true
	end
end

function D.CheckEnable()
	UnRegisterTalkFilter(D.OnTalkFilter)
	UnRegisterMsgFilter(D.OnMsgFilter)
	if not D.bReady or not D.aBlockWords or not O.bBlockWords then
		return
	end
	local tChannel, tMsgType = {}, {}
	for _, bw in ipairs(D.aBlockWords) do
		for szType, bEnable in pairs(bw.tMsgType) do
			if bEnable then
				if MSG_TYPE_TALK_CHANNEL[szType] then
					tChannel[MSG_TYPE_TALK_CHANNEL[szType]] = true
				end
				tMsgType[szType] = true
			end
		end
	end
	local aChannel, aMsgType = {}, {}
	for k, _ in pairs(tChannel) do
		table.insert(aChannel, k)
	end
	for k, _ in pairs(tMsgType) do
		table.insert(aMsgType, k)
	end
	if not X.IsEmpty(aChannel) then
		RegisterTalkFilter(D.OnTalkFilter, aChannel)
	end
	if not X.IsEmpty(aMsgType) then
		RegisterMsgFilter(D.OnMsgFilter, aMsgType)
	end
end

function D.TeamBuildingGetText(res, edit)
	local szText = res[1]
	if D.bReady and D.aBlockWords and O.bBlockWords then
		local szFilter = ''
		for _, bw in ipairs(D.aBlockWords) do
			if bw.bTeamBuilding
			and not X.StringFindW(bw.szKeyword, ',')
			and not X.StringFindW(bw.szKeyword, ';')
			and not X.StringFindW(bw.szKeyword, '|')
			and not X.StringFindW(bw.szKeyword, '!') then
				if szFilter ~= '' then
					szFilter = szFilter .. ','
				end
				szFilter = szFilter .. '!' .. bw.szKeyword
			end
		end
		if szFilter ~= '' then
			local aText = X.SplitString(szText, ';')
			for i, v in ipairs(aText) do
				if v ~= '' then
					v = v .. ','
				end
				aText[i] = v .. szFilter
			end
			szText = table.concat(aText, ';')
		end
	end
	return szText
end

function D.OnTeamBuildingCreate(frame)
	local edit = frame:Lookup('PageSet_TeamBuild/Page_TeamFinding/Edit_TeamFind')
	local hList = frame:Lookup('PageSet_TeamBuild/Page_TeamFinding/WndScroll_TeamInfo', '')
	if not edit or not hList then
		return
	end
	edit:SetLimit(-1)
	HookTableFunc(edit, 'GetText', D.TeamBuildingGetText, { bAfterOrigin = true, bPassReturn = true, bHookReturn = true })
	HookTableFunc(hList, 'FormatAllItemPos', D.ApplyTeamBuildingFilters, { bAfterOrigin = false })
end

function D.ApplyTeamBuildingFilters()
	if not D.bReady or not D.aBlockWords or not O.bBlockWords then
		return
	end
	local hList = Station.Lookup('Normal/TeamBuilding/PageSet_TeamBuild/Page_TeamFinding/WndScroll_TeamInfo', '')
	if hList then
		for i = 0, hList:GetItemCount() - 1 do
			local hItem = hList:Lookup(i)
			local szText = hItem:Lookup('Text_Leader'):GetText() .. '\n' .. hItem:Lookup('Text_Desc'):GetText()
			local bVisible = true
			for _, bw in ipairs(D.aBlockWords) do
				if bw.bTeamBuilding
				and X.StringSimpleMatch(szText, bw.szKeyword, not bw.bIgnoreCase, not bw.bIgnoreEnEm, bw.bIgnoreSpace) then
					bVisible = false
					break
				end
			end
			hItem:SetVisible(bVisible)
		end
		hList:SetIgnoreInvisibleChild(true)
	end
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_ChatBlock',
	exports = {
		{
			fields = {
				'bBlockWords',
			},
			root = O,
		},
	},
}
MY_ChatBlock = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_ChatBlock', function()
	D.bReady = true
	D.aBlockWords = O.aBlockWords
	D.CheckEnable()
end)
X.RegisterUserSettingsRelease('MY_ChatBlock', function()
	D.bReady = false
	D.CheckEnable()
end)
X.RegisterFrameCreate('TeamBuilding', 'MY_ChatBlock', function(name, frame)
	D.OnTeamBuildingCreate(frame)
end)

--------------------------------------------------------------------------------
-- 面板注册
--------------------------------------------------------------------------------

local PS = {}
function PS.OnPanelActive(wnd)
	local ui = X.UI(wnd)
	local nW, nH = ui:Size()
	local nX, nY = 0, 0

	ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 70,
		text = _L['Enable'],
		checked = O.bBlockWords,
		onCheck = function(bCheck)
			O.bBlockWords = bCheck
			D.CheckEnable()
		end,
	})
	nX = nX + 70

	local edit = ui:Append('WndEditBox', {
		name = 'WndEditBox_Keyword',
		x = nX, y = nY, w = nW - 160 - nX, h = 25,
		placeholder = _L['Type keyword, right click list to config.'],
	})
	nX, nY = 0, nY + 30

	local aBlockWords = O.aBlockWords
	local function SeekBlockWord(uuid)
		for i = #aBlockWords, 1, -1 do
			if aBlockWords[i].uuid == uuid then
				return aBlockWords[i]
			end
		end
	end

	local function RemoveBlockWord(uuid)
		for i = #aBlockWords, 1, -1 do
			if aBlockWords[i].uuid == uuid then
				table.remove(aBlockWords, i)
			end
		end
	end

	local list = ui:Append('WndListBox', { x = nX, y = nY, w = nW, h = nH - 30 })
	local function ReloadBlockWords()
		O('reload', {'aBlockWords'})
		aBlockWords = O.aBlockWords

		local bSave = false
		for _, bw in ipairs(aBlockWords) do
			if not bw.uuid then
				bw.uuid = X.GetUUID()
				bSave = true
			end
		end
		if bSave then
			O.aBlockWords = aBlockWords
		end
		aBlockWords = O.aBlockWords

		D.aBlockWords = aBlockWords
		D.CheckEnable()

		local tSelected = {}
		for _, v in ipairs(list:ListBox('select', 'selected')) do
			if v.selected and v.id then
				tSelected[v.id] = true
			end
		end
		list:ListBox('clear')
		for _, bw in ipairs(aBlockWords) do
			list:ListBox('insert', {
				id = bw.uuid,
				text = bw.szKeyword,
				data = bw,
				selected = tSelected[bw.uuid],
			})
		end
	end
	ReloadBlockWords()

	local function SaveBlockWords()
		O.aBlockWords = aBlockWords
		ReloadBlockWords()
	end

	list:ListBox('onmenu', function(id, text, data)
		local menu = {}
		X.InsertMsgTypeMenu(menu, function(szMsgType)
			return {
				fnAction = function(szType)
					local bw = SeekBlockWord(id)
					if bw then
						if bw.tMsgType[szType] then
							bw.tMsgType[szType] = nil
						else
							bw.tMsgType[szType] = true
						end
						SaveBlockWords()
					end
				end,
				bChecked = data.tMsgType[szMsgType]
			}
		end)
		table.insert(menu, 1, X.CONSTANT.MENU_DIVIDER)
		table.insert(menu, 1, {
			szOption = _L['Edit'],
			fnAction = function()
				GetUserInput(_L['Please input keyword:'], function(szText)
					szText = X.TrimString(szText)
					if X.IsEmpty(szText) then
						return
					end
					local bw = SeekBlockWord(id)
					if bw then
						bw.szKeyword = szText
						SaveBlockWords()
					end
				end, nil, nil, nil, data.szKeyword)
			end,
		})
		table.insert(menu, {
			szOption = _L['Team building'],
			bCheck = true, bChecked = data.bTeamBuilding,
			fnAction = function()
				data.bTeamBuilding = not data.bTeamBuilding
				SaveBlockWords()
			end,
		})
		table.insert(menu, {
			szOption = _L['From tong name'],
			bCheck = true, bChecked = data.bTongName,
			fnAction = function()
				data.bTongName = not data.bTongName
				SaveBlockWords()
			end,
			fnMouseEnter = function()
				local nX, nY = this:GetAbsX(), this:GetAbsY()
				local nW, nH = this:GetW(), this:GetH()
				OutputTip(GetFormatText(_L['If talker\'s tong name equals with keyword, chat message will be blocked, only apply for target you\'ve met.'], nil, 255, 255, 0), 400, {nX, nY, nW, nH}, ALW.LEFT_RIGHT)
			end,
			fnMouseLeave = function()
				HideTip()
			end,
		})
		table.insert(menu, X.CONSTANT.MENU_DIVIDER)
		table.insert(menu, {
			szOption = _L['Ignore spaces'],
			bCheck = true, bChecked = data.bIgnoreSpace,
			fnAction = function()
				local bw = SeekBlockWord(id)
				if bw then
					bw.bIgnoreSpace = not bw.bIgnoreSpace
					SaveBlockWords()
				end
			end,
		})
		table.insert(menu, {
			szOption = _L['Ignore enem'],
			bCheck = true, bChecked = data.bIgnoreEnEm,
			fnAction = function()
				local bw = SeekBlockWord(id)
				if bw then
					bw.bIgnoreEnEm = not bw.bIgnoreEnEm
					SaveBlockWords()
				end
			end,
		})
		table.insert(menu, {
			szOption = _L['Ignore case'],
			bCheck = true, bChecked = data.bIgnoreCase,
			fnAction = function()
				local bw = SeekBlockWord(id)
				if bw then
					bw.bIgnoreCase = not bw.bIgnoreCase
					SaveBlockWords()
				end
			end,
		})
		table.insert(menu, {
			szOption = _L['Ignore acquaintance'],
			bCheck = true, bChecked = data.bIgnoreAcquaintance,
			fnAction = function()
				local bw = SeekBlockWord(id)
				if bw then
					bw.bIgnoreAcquaintance = not bw.bIgnoreAcquaintance
					SaveBlockWords()
				end
			end,
		})
		table.insert(menu, X.CONSTANT.MENU_DIVIDER)
		table.insert(menu, {
			szOption = _L['Delete'],
			fnAction = function()
				RemoveBlockWord(id)
				SaveBlockWords()
				X.UI.ClosePopupMenu()
			end,
		})
		menu.szOption = _L['Channels']
		return menu
	end):ListBox('onlclick', function(id, text, data, selected)
		edit:Text(text)
	end)
	:ListBox(
		'onhover',
		function(id, text, data, selected)
			local history = O.tBlockHistory[id]
			local aXml = {}
			if history.nCount > 0 then
				table.insert(aXml, X.GetFormatText(_L('Total %d messages blocked, recently blocked %d:', history.nCount, #history.aRecent), 162, 192, 192, 192))
				table.insert(aXml, X.CONSTANT.XML_LINE_BREAKER)
				table.insert(aXml, X.CONSTANT.XML_LINE_BREAKER)
			else
				table.insert(aXml, X.GetFormatText(_L('No messages blocked yet.'), 162, 192, 192, 192))
			end
			for _, v in ipairs(history.aRecent) do
				table.insert(aXml, v)
				if not X.GetPureText(v):find('\n', 1, true) then
					table.insert(aXml, X.CONSTANT.XML_LINE_BREAKER)
				end
			end
			X.OutputTip(X.UI(this):HoverItemRect(), table.concat(aXml, '\n'):gsub('\t', '  '), true, ALW.BOTTOM_TOP)
		end,
		function(id, text, data)
			HideTip()
		end
	)
	-- add
	ui:Append('WndButton', {
		x = nW - 160, y=  0, w = 80,
		text = _L['Add'],
		onClick = function()
			local szText = X.TrimString(edit:Text())
			if X.IsEmpty(szText) then
				return
			end
			O('reload', {'aBlockWords'})
			local bw = X.Clone(DEFAULT_KW_CONFIG)
			bw.uuid = X.GetUUID()
			bw.szKeyword = szText
			table.insert(aBlockWords, 1, bw)
			SaveBlockWords()
		end,
	})
	-- del
	ui:Append('WndButton', {
		x = nW - 80, y =  0, w = 80,
		text = _L['Delete'],
		onClick = function()
			O('reload', {'aBlockWords'})
			for _, v in ipairs(list:ListBox('select', 'selected')) do
				RemoveBlockWord(v.id)
			end
			SaveBlockWords()
		end,
	})
end
X.Panel.Register(_L['Chat'], 'MY_ChatBlock', _L['MY_ChatBlock'], 'UI/Image/Common/Money.UITex|243', PS)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
