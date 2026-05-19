--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 团队面板主界面
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Cataclysm/MY_CataclysmMain'
local PLUGIN_NAME = 'MY_Cataclysm'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Cataclysm'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.0') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
X.RegisterRestriction('MY_CataclysmMain__OfficialBuff', { ['*'] = true })
--------------------------------------------------------------------------------
local MY_IsVisibleBuff, MY_GetBuffName = X.IsVisibleBuff,  X.GetBuffName
local D = {}
local INI_ROOT = X.PACKET_INFO.ROOT .. 'MY_Cataclysm/ui/'
local CFG = MY_Cataclysm.CFG
local CTM_CONFIG_DEFAULT = X.LoadLUAData(X.PACKET_INFO.ROOT .. 'MY_Cataclysm/config/default/{$lang}.jx3dat')
local CTM_CONFIG_OFFICIAL = X.LoadLUAData(X.PACKET_INFO.ROOT .. 'MY_Cataclysm/config/official/{$lang}.jx3dat')
local CTM_CONFIG_CATACLYSM = X.LoadLUAData(X.PACKET_INFO.ROOT .. 'MY_Cataclysm/config/cataclysm/{$lang}.jx3dat')

local TEAM_VOTE_REQUEST = {}
local BUFF_LIST = {}
local GKP_RECORD_TOTAL = 0
local CTM_CAPTION = ''
local CTM_BUFF_TEAMMON = {}
local CTM_BUFF_OFFICIAL = {}
local DEBUG = false

do
-- TODO: 不是需要基础排序 而是需要作用域限定加权，当作用域一致时，用户>DBM>官方
local function InsertBuffListCache(aBuffList, szVia, nViaPriority)
	for _, tab in ipairs(aBuffList) do
		local id = tab.dwID or tab.szName
		if id then
			for iid, aList in pairs(BUFF_LIST) do
				if iid == id or (tab.szName and type(iid) == 'number' and Table_GetBuffName(iid, 1) == tab.szName) then
					for i, p in X.ipairs_r(aList) do
						if (not tab.nLevel or p.nLevel == tab.nLevel)
						and (not tab.szStackOp or p.szStackOp == tab.szStackOp)
						and (not tab.nStackNum or p.nStackNum == tab.nStackNum)
						and (not tab.bOnlyMe or p.bOnlyMe == tab.bOnlyMe)
						and (not tab.bOnlyMine or p.bOnlyMine == tab.bOnlyMine) then
							table.remove(aList, i)
						end
					end
					if #aList == 0 then
						BUFF_LIST[iid] = nil
					end
				end
			end
			if not tab.bDelete then
				if not BUFF_LIST[id] then
					BUFF_LIST[id] = {}
				end
				table.insert(BUFF_LIST[id], 1, setmetatable({ szVia = szVia, nViaPriority = nViaPriority }, { __index = tab }))
			end
		end
	end
end
function D.UpdateBuffListCache()
	BUFF_LIST = {}
	if CFG.bBuffDataOfficial and CTM_BUFF_OFFICIAL then
		InsertBuffListCache(CTM_BUFF_OFFICIAL, _L['From official raid buff data'], 2)
	end
	if CFG.bBuffDataTeamMon and CTM_BUFF_TEAMMON then
		InsertBuffListCache(CTM_BUFF_TEAMMON, _L['From MY_TeamMon data'], 1)
	end
	if CFG.aBuffList and not X.IsRestricted('MY_Cataclysm_BuffMonitor') then
		InsertBuffListCache(CFG.aBuffList, _L['From custom data'], 0)
	end
	if CFG.bBuffPushToOfficial then
		local aBuff = {}
		for _, dwID in pairs(BUFF_LIST) do
			if X.IsNumber(dwID) then
				table.insert(aBuff, dwID)
			end
		end
		Raid_MonitorBuffs(aBuff)
	end
	FireUIEvent('MY_CATACLYSM_BUFF_LIST_CACHE_UPDATE')
end
end

do
local function UpdateTeamMonData()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE then
		return
	end
	if MY_TeamMon and MY_TeamMon.IterTable and MY_TeamMon.GetTable then
		local aBuff = {}
		for _, szType in ipairs({'BUFF', 'DEBUFF'}) do
			for _, data in MY_TeamMon.IterTable(MY_TeamMon.GetTable(szType), 0, true, true) do
				if data.aCataclysmBuff then
					for _, v in ipairs(data.aCataclysmBuff) do
						v = X.Clone(v)
						v.dwID = data.dwID
						if data.bCheckLevel then
							v.nLevel = data.nLevel
						end
						v.nIcon = data.nIcon
						table.insert(aBuff, v)
					end
				end
			end
		end
		CTM_BUFF_TEAMMON = aBuff
		D.UpdateBuffListCache()
	end
end
local function onTeamMonUpdate()
	if arg0 and not arg0['BUFF'] and not arg0['DEBUFF'] then
		return
	end
	UpdateTeamMonData()
end
X.RegisterEvent('MY_TEAM_MON_DATA_RELOAD', 'MY_CataclysmMain', onTeamMonUpdate)
end

do
local function UpdateOfficialBuff()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE then
		return
	end
	local dwMapID = X.GetMapID(true)
	local szMapID = tostring(dwMapID)
	local dwMountKungfuID = UI_GetPlayerMountKungfuID()
	local aBuff = {}
	local RaidPanelBuff = X.GetGameTable('RaidPanelBuff')
	if not RaidPanelBuff or not X.IsRestricted('MY_CataclysmMain__OfficialBuff') then
		local szPath = X.FormatPath({'userdata\\cataclysm\\official_buff.tab', X.PATH_TYPE.GLOBAL})
		local tTitle = {
			{ f = 'i', t = 'dwBuffID' },
			{ f = 'i', t = 'nBuffLevel' },
			{ f = 's', t = 'szMapID' },
			{ f = 'i', t = 'dwMountKungfuID' },
			{ f = 's', t = 'szStackOperator' },
			{ f = 'i', t = 'nStackNum' },
			{ f = 'b', t = 'bOnlyMine' },
			{ f = 'b', t = 'bOnlyMyself' },
			{ f = 'i', t = 'nIconID' },
			{ f = 'b', t = 'bAttention' },
			{ f = 's', t = 'szAttentionColor' },
			{ f = 'b', t = 'bCaution' },
			{ f = 'b', t = 'bScreenHead' },
			{ f = 's', t = 'szScreenHeadColor' },
			{ f = 'i', t = 'nPriority' },
			{ f = 's', t = 'szReminder' },
			{ f = 's', t = 'szReminderColor' },
			{ f = 's', t = 'szBorderColor' },
		}
		RaidPanelBuff = KG_Table.Load(szPath, tTitle, FILE_OPEN_MODE.NORMAL) or RaidPanelBuff
	end
	if RaidPanelBuff then
		local nCount = RaidPanelBuff:GetRowCount()
		for i = 2, nCount do
			local tLine = RaidPanelBuff:GetRow(i)
			if (not tLine.dwMapID or tLine.dwMapID == dwMapID or tLine.dwMapID == 0)
			and (not tLine.szMapID or X.Contains(X.SplitString(tLine.szMapID, ';'), szMapID))
			and (not tLine.dwMountKungfuID or tLine.dwMountKungfuID == 0 or X.IsSameKungfu(tLine.dwMountKungfuID, dwMountKungfuID)) then
				local v = {
					dwID = tLine.dwBuffID,
					nLevel = X.IIf(tLine.nBuffLevel > 0, tLine.nBuffLevel, nil),
					szStackOp = X.IIf(
						tLine.szStackOperator == '',
						X.IIf(tLine.nStackNum == 0, nil, '>='),
						tLine.szStackOperator
					),
					nStackNum = X.IIf(tLine.szStackOperator == '' and tLine.nStackNum == 0, nil, tLine.nStackNum),
					bOnlyMine = tLine.bOnlyMine,
					bOnlyMe = tLine.bOnlyMyself,
					nIconID = X.IIf(tLine.nIconID == 0, nil, tLine.nIconID),
					bAttention = tLine.bAttention,
					colAttention = X.IIf(tLine.szAttentionColor == '', nil, tLine.szAttentionColor),
					bCaution = tLine.bCaution,
					bScreenHead = tLine.bScreenHead,
					colScreenHead = X.IIf(tLine.szScreenHeadColor == '', nil, tLine.szScreenHeadColor),
					nPriority = tLine.nPriority,
					szReminder = tLine.szReminder,
					colReminder = X.IIf(tLine.szReminderColor == '', nil, tLine.szReminderColor),
					colBorder = X.IIf(tLine.szBorderColor == '', nil, tLine.szBorderColor),
				}
				table.insert(aBuff, v)
			end
		end
	end
	local NewRaidBuff = X.GetGameTable('NewRaidBuff')
	if NewRaidBuff then
		local nCount = NewRaidBuff:GetRowCount()
		for i = 2, nCount do
			local tLine = NewRaidBuff:GetRow(i)
			if tLine.dwMountKungfuID == 0 or X.IsSameKungfu(tLine.dwMountKungfuID,  dwMountKungfuID) then
				local v = {
					dwID = tLine.dwBuffID,
					nLevel = nil,
					szStackOp = nil,
					nStackNum = nil,
					bOnlyMine = tLine.bOnlyMyself,
					bOnlyMe = nil,
					nIconID = Table_GetBuffIconID(tLine.dwBuffID, tLine.nBuffLevel)
						or Table_GetBuffIconID(tLine.dwBuffID)
						or 13,
					bAttention = nil,
					colAttention = nil,
					bCaution = nil,
					bScreenHead = nil,
					colScreenHead = nil,
					nPriority = nil,
					szReminder = nil,
					colReminder = nil,
					colBorder = nil,
				}
				table.insert(aBuff, v)
			end
		end
	end
	CTM_BUFF_OFFICIAL = aBuff
	D.UpdateBuffListCache()
end
X.RegisterEvent('MY_RESTRICTION', 'MY_CataclysmMain__OfficialBuff', function()
	if arg0 and arg0 ~= 'MY_CataclysmMain__OfficialBuff' then
		return
	end
	UpdateOfficialBuff()
end)
X.RegisterInit('MY_CataclysmMain__OfficialBuff', UpdateOfficialBuff)
X.RegisterKungfuMount('MY_CataclysmMain__OfficialBuff', UpdateOfficialBuff)
end

function D.SetConfig(Config, bKeepBuff)
	if bKeepBuff then
		Config.aBuffList = nil
	end
	-- update version
	if Config.tBuffList then
		Config.aBuffList = {}
		for k, v in pairs(Config.tBuffList) do
			v.dwID = tonumber(k)
			if not v.dwID then
				v.szName = k
			end
			table.insert(Config.aBuffList, v)
		end
		Config.tBuffList = nil
	end
	-- options fixed
	if Config.eCss == 'OFFICIAL' then
		for k, v in pairs(CTM_CONFIG_OFFICIAL) do
			if type(Config[k]) == 'nil' then
				Config[k] = v
			end
		end
	elseif Config.eCss == 'CATACLYSM' then
		for k, v in pairs(CTM_CONFIG_CATACLYSM) do
			if type(Config[k]) == 'nil' then
				Config[k] = v
			end
		end
	else
		for k, v in pairs(CTM_CONFIG_DEFAULT) do
			if type(Config[k]) == 'nil' then
				Config[k] = v
			end
		end
	end
	-- Config.bFasterHP = false
	for k, v in pairs(Config) do
		X.Call(X.Set, CFG, {k}, v)
	end
	D.UpdateBuffListCache()
	D.ReloadCataclysmPanel()
end

function D.LoadAncientConfigure(szConfigName)
	local xData = X.LoadLUAData({'config/cataclysm/' .. szConfigName .. '.jx3dat', X.PATH_TYPE.GLOBAL})
	if X.IsTable(xData) then
		D.SetConfig(xData)
	end
end

function D.GetFrame()
	return Station.Lookup('Normal/MY_CataclysmMain')
end

local CTM_LOOT_MODE = X.KvpToObject({
	{PARTY_LOOT_MODE.FREE_FOR_ALL, {'ui/Image/TargetPanel/Target.UITex'   , 60}},
	{PARTY_LOOT_MODE.DISTRIBUTE  , {'ui/Image/UICommon/CommonPanel2.UITex', 92}},
	{PARTY_LOOT_MODE.GROUP_LOOT  , {'ui/Image/UICommon/LoginCommon.UITex' , 29}},
	{PARTY_LOOT_MODE.BIDDING     , {'ui/Image/UICommon/GoldTeam.UITex'    ,  6}},
})
local CTM_LOOT_QUALITY = {
	[0] = 2399,
	[1] = 2396,
	[2] = 2401,
	[3] = 2397,
	[4] = 2402,
	[5] = 2400,
}

function D.InsertForceCountMenu(tMenu)
	local tForceList = {}
	local hTeam = GetClientTeam()
	local nCount = 0
	for nGroupID = 0, hTeam.nGroupNum - 1 do
		local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
		for _, dwMemberID in ipairs(tGroupInfo.MemberList) do
			local tMemberInfo = hTeam.GetMemberInfo(dwMemberID)
			if not tForceList[tMemberInfo.dwForceID] then
				tForceList[tMemberInfo.dwForceID] = 0
			end
			tForceList[tMemberInfo.dwForceID] = tForceList[tMemberInfo.dwForceID] + 1
		end
		nCount = nCount + #tGroupInfo.MemberList
	end
	local tSubMenu = { szOption = g_tStrings.STR_RAID_MENU_FORCE_COUNT ..
		FormatString(g_tStrings.STR_ALL_PARENTHESES, nCount)
	}
	for dwForceID, nCount in pairs(tForceList) do
		local szPath, nFrame = GetForceImage(dwForceID)
		table.insert(tSubMenu, {
			szOption = g_tStrings.tForceTitle[dwForceID] .. '   ' .. nCount,
			rgb = { X.GetForceColor(dwForceID) },
			szIcon = szPath,
			nFrame = nFrame,
			szLayer = 'ICON_LEFT'
		})
	end
	table.insert(tMenu, tSubMenu)
end

function D.InsertDistributeMenu(tMenu)
	local aDistributeMenu = {}
	InsertDistributeMenu(aDistributeMenu, not X.IsClientPlayerTeamDistributor())
	for _, menu in ipairs(aDistributeMenu) do
		if menu.szOption == g_tStrings.STR_LOOT_LEVEL then
			table.insert(menu, 1, {
				bDisable = not X.IsClientPlayerTeamDistributor(),
				szOption = g_tStrings.STR_WHITE,
				nFont = 79, rgb = {GetItemFontColorByQuality(1)},
				bMCheck = true, bChecked = GetClientTeam().nRollQuality == 1,
				fnAction = function() GetClientTeam().SetTeamRollQuality(1) end,
			})
			table.insert(menu, 1, {
				bDisable = not X.IsClientPlayerTeamDistributor(),
				szOption = g_tStrings.STR_GRAY,
				nFont = 79, rgb = {GetItemFontColorByQuality(0)},
				bMCheck = true, bChecked = GetClientTeam().nRollQuality == 0,
				fnAction = function() GetClientTeam().SetTeamRollQuality(0) end,
			})
		end
		table.insert(tMenu, menu)
	end
end

function D.GetTeammateFrame()
	return Station.Lookup('Normal/Teammate')
end

function D.RaidPanel_Switch(bOpen)
	local frame = Station.Lookup('Normal/RaidPanel_Main')
	if bOpen then
		if not frame then
			OpenRaidPanel()
		end
	else
		if frame then
			-- 有一点问题 会被加呼吸 根据判断
			if not D.GetTeammateFrame() then
				X.UI.OpenFrame('Teammate')
			end
			CloseRaidPanel()
			X.UI.CloseFrame('Teammate')
		end
	end
end

function D.TeammatePanel_Switch(bOpen)
	local hFrame = D.GetTeammateFrame()
	if hFrame then
		if bOpen then
			hFrame:Show()
		else
			hFrame:Hide()
		end
	end
end

function D.GetGroupTotal()
	local me, team = X.GetClientPlayer(), GetClientTeam()
	local nGroup = 0
	if me.IsInRaid() then
		for i = 0, team.nGroupNum - 1 do
			local tGroup = team.GetGroupInfo(i)
			if #tGroup.MemberList > 0 then
				nGroup = nGroup + 1
			end
		end
	else
		nGroup = 1
	end
	return nGroup
end

function D.UpdatePrepareBarPos()
	local frame = D.GetFrame()
	if not frame then
		return
	end
	local hTotal = frame:Lookup('', '')
	local hPrepare = hTotal:Lookup('Handle_Prepare')
	if MY_Cataclysm.bFold or D.GetGroupTotal() < 3 then
		hPrepare:SetRelPos(0, -18)
	else
		local wrapper = frame:Lookup('WndContainer_Wrapper')
		local container = wrapper:Lookup('WndContainer_Main')
		hPrepare:SetRelPos(wrapper:GetRelX() + container:GetW(), 3)
	end
	hTotal:FormatAllItemPos()
end

function D.SetFrameCaption(szText)
	local frame = D.GetFrame()
	if szText then
		CTM_CAPTION = szText
	end
	if frame then
		frame:Lookup('', 'Handle_BG/Text_Caption'):SetText(CTM_CAPTION)
	end
end

function D.SetFrameSize(bEnter)
	local frame = D.GetFrame()
	if frame then
		local nGroup = D.GetGroupTotal()
		local nGroupEx = nGroup
		if CFG.nAutoLinkMode ~= 5 then
			nGroupEx = 1
		end
		local wrapper = frame:Lookup('WndContainer_Wrapper')
		local container = wrapper:Lookup('WndContainer_Main')
		local nItemW = frame:Lookup('', 'Handle_ListW'):GetW() * CFG.fScaleX
		local nMinW = wrapper:GetRelX() + container:GetW()
		local nDragW = math.max(nItemW * nGroupEx, nMinW + 30)
		local nDragH = select(2, frame:GetSize())
		frame:SetW(nDragW)
		frame:SetDragArea(0, 0, nDragW, nDragH)
		local nBgW, nWrapperW = math.max(nItemW * nGroupEx, nMinW + 5), container:GetW()
		if not bEnter then
			nBgW = math.min(nItemW * nGroupEx, nMinW + 5)
			nWrapperW = nBgW - wrapper:GetRelX() - 5
		end
		local nBgSW = frame:Lookup('', 'Handle_BG/Image_Title_BG'):GetW()
		local nWrapperSW = wrapper:GetW()
		local nSTick = bEnter
			and GetTime()
			or GetTime() + 1500
		local nDuring = bEnter
			and 100
			or 200
		local bContinue, nTick, fPer
		X.RenderCall('MY_CataclysmMain_WAni', function()
			bContinue = false
			if X.IsElement(wrapper) then
				nTick = GetTime()
				if nTick < nSTick then
					return
				end
				bContinue = nTick - nSTick < nDuring
				fPer = bContinue
					and ((nTick - nSTick) / nDuring)
					or 1
				wrapper:SetW((nWrapperW - nWrapperSW) * fPer + nWrapperSW)
				frame:Lookup('', 'Handle_BG/Image_Title_BG'):SetW((nBgW - nBgSW) * fPer + nBgSW)
			end
			if not bContinue then
				D.UpdatePrepareBarPos()
				return 0
			end
		end)
	end
end

function D.CreateControlBar()
	local team         = GetClientTeam()
	local nLootMode    = team.nLootMode
	local nRollQuality = team.nRollQuality
	local frame        = D.GetFrame()
	local container    = frame:Lookup('WndContainer_Wrapper/WndContainer_Main')
	local szIniFile    = INI_ROOT .. 'MY_CataclysmMain_Button.ini'
	container:Clear()
	-- 团队工具 团队告示
	if X.IsClientPlayerInParty() then
		container:AppendContentFromIni(szIniFile, 'Wnd_TeamTools')
		container:AppendContentFromIni(szIniFile, 'Wnd_TeamNotice')
	end
	-- 团队监控
	container:AppendContentFromIni(szIniFile, 'Wnd_TeamMon_Subscribe')
	-- 分配模式
	local hLootMode = container:AppendContentFromIni(szIniFile, 'WndButton_LootMode')
	if CTM_LOOT_MODE[nLootMode] then
		hLootMode:Lookup('', 'Image_LootMode'):FromUITex(unpack(CTM_LOOT_MODE[nLootMode]))
	end
	if nLootMode == PARTY_LOOT_MODE.DISTRIBUTE
	or (nLootMode == PARTY_LOOT_MODE.BIDDING and OpenGoldTeam) then
		container:AppendContentFromIni(szIniFile, 'WndButton_LootQuality')
			:Lookup('', 'Image_LootQuality'):FromIconID(CTM_LOOT_QUALITY[nRollQuality])
		container:AppendContentFromIni(szIniFile, 'WndButton_GKP')
	end
	-- 世界标记
	if X.IsClientPlayerTeamLeader() then
		container:AppendContentFromIni(szIniFile, 'WndButton_WorldMark')
	end
	-- 召请玩家
	if X.IsClientPlayerTeamLeader() and EnvokeAllTeammates then
		container:AppendContentFromIni(szIniFile, 'Wnd_EnvokeAllTeammates')
	end
	-- 倒计时
	if X.IsClientPlayerTeamLeader() and MY_TeamCountdown then
		container:AppendContentFromIni(szIniFile, 'Wnd_TeamCountdown')
	end
	-- 语音按钮
	if X.GVoiceBase_IsOpen() then
		local nSpeakerState = X.GVoiceBase_GetSpeakerState()
		container:AppendContentFromIni(szIniFile, 'Wnd_Speaker')
			:Lookup('WndButton_Speaker').nSpeakerState = nSpeakerState
		container:Lookup('Wnd_Speaker/WndButton_Speaker', 'Image_Normal')
			:SetVisible(nSpeakerState == X.CONSTANT.SPEAKER_STATE.OPEN)
		container:Lookup('Wnd_Speaker/WndButton_Speaker', 'Image_Close_Speaker')
			:SetVisible(nSpeakerState == X.CONSTANT.SPEAKER_STATE.CLOSE)
		local nMicState = X.GVoiceBase_GetMicState()
		container:AppendContentFromIni(szIniFile, 'Wnd_Microphone')
			:Lookup('WndButton_Microphone').nMicState = nMicState
		container:Lookup('Wnd_Microphone/WndButton_Microphone', 'Animate_Input_Mic')
			:SetVisible(nMicState == X.CONSTANT.MIC_STATE.FREE)
		container:Lookup('Wnd_Microphone/WndButton_Microphone', 'Image_UnInsert_Mic')
			:SetVisible(nMicState == X.CONSTANT.MIC_STATE.NOT_AVIAL)
		container:Lookup('Wnd_Microphone/WndButton_Microphone', 'Image_Close_Mic')
			:SetVisible(nMicState == X.CONSTANT.MIC_STATE.CLOSE_NOT_IN_ROOM or nMicState == X.CONSTANT.MIC_STATE.CLOSE_IN_ROOM)
		local hMicFree = container:Lookup('Wnd_Microphone/WndButton_Microphone', 'Handle_Free_Mic')
		local hMicHotKey = container:Lookup('Wnd_Microphone/WndButton_Microphone', 'Handle_HotKey')
		hMicFree:SetVisible(nMicState == X.CONSTANT.MIC_STATE.FREE)
		hMicHotKey:SetVisible(nMicState == X.CONSTANT.MIC_STATE.KEY)
		-- 自动调整语音按钮宽度
		local nMicWidth = hMicFree:GetRelX()
		if nMicState == X.CONSTANT.MIC_STATE.FREE then
			nMicWidth = nMicWidth + hMicFree:GetW()
		elseif nMicState == X.CONSTANT.MIC_STATE.KEY then
			nMicWidth = hMicHotKey:GetRelX() + hMicHotKey:GetW()
		end
		container:Lookup('Wnd_Microphone'):SetW(nMicWidth)
	end
	-- 最小化
	container:AppendContentFromIni(szIniFile, 'Wnd_Fold')
		:Lookup('CheckBox_Fold'):Check(MY_Cataclysm.bFold, WNDEVENT_FIRETYPE.PREVENT)
	-- 自动计算宽度
	local nW, wnd = 0, nil
	for i = 0, container:GetAllContentCount() - 1 do
		wnd = container:LookupContent(i)
		wnd:SetRelX(nW)
		nW = nW + wnd:GetW()
	end
	container:SetW(nW)
	container:FormatAllContentPos()
	D.SetFrameSize(false)
	D.SetFrameCaption()
end

-- 创建中间层数据 常用的
function D.CreateItemData()
	local frame = D.GetFrame()
	if not frame then
		return
	end
	for _, p in ipairs({
		{'hMember', 'MY_CataclysmParty_Item.' .. CFG.eFrameStyle .. '.ini', 'Handle_RoleDummy'},
		{'hBuff', 'MY_CataclysmParty_Item.' .. CFG.eFrameStyle .. '.ini', 'Handle_Buff'},
	}) do
		if frame[p[1]] then
			frame:RemoveItemData(frame[p[1]])
		end
		frame[p[1]] = frame:CreateItemData(INI_ROOT .. p[2], p[3]) or frame[p[1]] -- 兼容当前KGUI错误代码
	end
end

function D.OpenCataclysmPanel()
	if not D.GetFrame() then
		if CFG.eCss == '' then
			D.ConfirmRestoreConfig()
		end
		X.UI.OpenFrame(INI_ROOT .. 'MY_CataclysmMain.ini', 'MY_CataclysmMain')
	end
end

function D.CloseCataclysmPanel()
	if D.GetFrame() then
		X.UI.CloseFrame(D.GetFrame())
		MY_CataclysmParty:CloseParty()
		MY_Cataclysm.bFold = false
	end
end

function D.CheckCataclysmEnable()
	local me = X.GetClientPlayer()
	if not MY_Cataclysm.bEnable then
		D.CloseCataclysmPanel()
		return false
	end
	if CFG.bShowInRaid and not me.IsInRaid() then
		D.CloseCataclysmPanel()
		return false
	end
	if not me.IsInParty() then
		D.CloseCataclysmPanel()
		return false
	end
	D.OpenCataclysmPanel()
	return true
end

function D.ReloadCataclysmPanel()
	if D.GetFrame() then
		D.CreateItemData()
		D.CreateControlBar()
		MY_CataclysmParty:CloseParty()
		MY_CataclysmParty:ReloadParty()
	end
end

function D.UpdateAnchor(frame)
	local a = CFG.tAnchor
	if not X.IsEmpty(a) then
		frame:SetPoint(a.s, 0, 0, a.r, a.x, a.y)
	else
		frame:SetPoint('LEFTCENTER', 0, 0, 'LEFTCENTER', 100, -200)
	end
end

function D.OnWageStart()
	MY_CataclysmParty:StartTeamVote('wage_agree')
	local nTime = GetCurrentTime()
	local function fnAction()
		D.SetFrameCaption(_L('Wage await %ds...', 30 - (GetCurrentTime() - nTime)))
	end
	fnAction()
	X.BreatheCall('MY_Cataclysm_Wage', 1000, fnAction)
end

function D.OnWageFinish()
	MY_CataclysmParty:ClearTeamVote('wage_agree')
	D.SetFrameCaption('')
	X.BreatheCall('MY_Cataclysm_Wage', false)
end

-------------------------------------------------
-- 界面创建 事件注册
-------------------------------------------------
function D.OnFrameCreate()
	if CFG.bFasterHP then
		this:RegisterEvent('RENDER_FRAME_UPDATE')
	end
	this:RegisterEvent('PARTY_SYNC_MEMBER_DATA')
	this:RegisterEvent('PARTY_ADD_MEMBER')
	this:RegisterEvent('PARTY_DISBAND')
	this:RegisterEvent('PARTY_DELETE_MEMBER')
	this:RegisterEvent('PARTY_UPDATE_MEMBER_INFO')
	this:RegisterEvent('PARTY_UPDATE_MEMBER_LMR')
	this:RegisterEvent('PARTY_LEVEL_UP_RAID')
	this:RegisterEvent('PARTY_SET_MEMBER_ONLINE_FLAG')
	this:RegisterEvent('PLAYER_STATE_UPDATE')
	this:RegisterEvent('UPDATE_PLAYER_SCHOOL_ID')
	-- this:RegisterEvent('RIAD_READY_CONFIRM_RECEIVE_QUESTION')
	this:RegisterEvent('RIAD_READY_CONFIRM_RECEIVE_ANSWER')
	this:RegisterEvent('UI_SCALED')
	this:RegisterEvent('PARTY_SET_MARK')
	this:RegisterEvent('TEAM_AUTHORITY_CHANGED')
	this:RegisterEvent('TEAM_CHANGE_MEMBER_GROUP')
	this:RegisterEvent('PARTY_SET_FORMATION_LEADER')
	this:RegisterEvent('PARTY_LOOT_MODE_CHANGED')
	this:RegisterEvent('PARTY_ROLL_QUALITY_CHANGED')
	this:RegisterEvent('LOADING_END')
	this:RegisterEvent('TARGET_CHANGE')
	this:RegisterEvent('CHARACTER_THREAT_RANKLIST')
	this:RegisterEvent('BUFF_UPDATE')
	this:RegisterEvent('ON_DUNGEON_OB_STREAMER_LIST_UPDATE')
	this:RegisterEvent('PLAYER_ENTER_SCENE')
	this:RegisterEvent('MY_CATACLYSM_BUFF_LIST_CACHE_UPDATE')
	this:RegisterEvent('MY_CATACLYSM_SET_VISIBLE')
	this:RegisterEvent('MY_CATACLYSM_SET_FOLD')
	-- 拍团部分 arg0 0=T人 1=分工资
	this:RegisterEvent('TEAM_VOTE_REQUEST')
	-- arg0 回应状态 arg1 dwID arg2 同意=1 反对=0
	this:RegisterEvent('TEAM_VOTE_RESPOND')
	this:RegisterEvent('TEAM_INCOMEMONEY_CHANGE_NOTIFY')
	this:RegisterEvent('SYS_MSG')
	this:RegisterEvent('MY_RAID_REC_BUFF')
	this:RegisterEvent('GKP_RECORD_TOTAL')
	this:RegisterEvent('GVOICE_MIC_STATE_CHANGED')
	this:RegisterEvent('GVOICE_SPEAKER_STATE_CHANGED')
	this:RegisterEvent('ON_MY_MOSAICS_RESET')
	this:RegisterEvent('ON_TEAMSWICTH_FRAMEDRAG')
	this:RegisterEvent('TEAM_SWICTH_ROOM')
	if X.GetClientPlayer() then
		D.UpdateAnchor(this)
		MY_CataclysmParty:AutoLinkAllPanel()
	end
	D.SetFrameSize()
	D.SetFrameCaption()
	D.CreateItemData()
	D.CreateControlBar()
	this:EnableDrag(CFG.bDrag)
	this:SetVisible(MY_Cataclysm.bVisible)
end

-------------------------------------------------
-- 拖动窗体 OnFrameDrag
-------------------------------------------------

function D.OnFrameDragSetPosEnd()
	D.UpdateOfficialTeamSwitchPanel(true)
	MY_CataclysmParty:AutoLinkAllPanel()
end

function D.OnFrameDragEnd()
	this:CorrectPos()
	CFG.tAnchor = GetFrameAnchor(this, 'TOPLEFT')
	MY_CataclysmParty:AutoLinkAllPanel() -- fix screen pos
end

-------------------------------------------------
-- 事件处理
-------------------------------------------------
do
local function RecBuffWithTabs(tabs, dwOwnerID, dwBuffID, dwSrcID)
	if not tabs then
		return
	end
	for _, tab in ipairs(tabs) do
		if not tab.bOnlyMine or dwSrcID == X.GetClientPlayerID() then
			MY_CataclysmParty:RecBuff(dwOwnerID, setmetatable({
				dwID      = dwBuffID,
				nLevel    = tab.nLevel or 0,
				bOnlyMine = tab.bOnlyMine or tab.bOnlySelf or tab.bSelf,
			}, { __index = tab }))
		end
	end
end
local function OnBuffUpdate(dwOwnerID, dwID, nLevel, nStackNum, dwSrcID)
	if X.IsBossFocusBuff(dwID, nLevel, nStackNum) then
		MY_CataclysmParty:RecBossFocusBuff(dwOwnerID, {
			dwID      = dwID     ,
			nLevel    = nLevel   ,
			nStackNum = nStackNum,
		})
	end
	if MY_IsVisibleBuff(dwID, nLevel) and not X.IsRestricted('MY_Cataclysm_BuffMonitor') then
		local szName = MY_GetBuffName(dwID, nLevel)
		RecBuffWithTabs(BUFF_LIST[dwID], dwOwnerID, dwID, dwSrcID)
		RecBuffWithTabs(BUFF_LIST[szName], dwOwnerID, dwID, dwSrcID)
	end
end
function D.OnEvent(szEvent)
	if szEvent == 'RENDER_FRAME_UPDATE' then
		MY_CataclysmParty:CallDrawHPMP(true)
	elseif szEvent == 'SYS_MSG' then
		if arg0 == 'UI_OME_SKILL_CAST_LOG' and arg2 == 13165 then
			MY_CataclysmParty:KungFuSwitch(arg1)
		end
		if CFG.bShowEffect then
			if arg0 == 'UI_OME_SKILL_EFFECT_LOG'
			and arg5 == 6252
			and arg9[SKILL_RESULT_TYPE.THERAPY]
			and (arg1 == X.GetControlPlayerID() or UI_GetPlayerMountKungfuID() ~= 10176) then
				MY_CataclysmParty:CallEffect(arg2, 500)
			end
		end
	elseif szEvent == 'PARTY_SYNC_MEMBER_DATA' then
		MY_CataclysmParty:CallRefreshImages(arg1, true, true, nil, true)
		MY_CataclysmParty:CallDrawHPMP(arg1, true)
	elseif szEvent == 'PARTY_ADD_MEMBER' then
		if MY_CataclysmParty:GetPartyFrame(arg2) then
			MY_CataclysmParty:DrawParty(arg2)
		else
			MY_CataclysmParty:CreatePanel(arg2)
			MY_CataclysmParty:DrawParty(arg2)
			D.SetFrameSize()
		end
		if CFG.nAutoLinkMode ~= 5 then
			MY_CataclysmParty:AutoLinkAllPanel()
		end
		D.UpdatePrepareBarPos()
	elseif szEvent == 'PARTY_DELETE_MEMBER' then
		local me = X.GetClientPlayer()
		if me.dwID == arg1 then
			D.OnWageFinish()
			D.CloseCataclysmPanel()
		else
			local team = GetClientTeam()
			local tGroup = team.GetGroupInfo(arg3)
			if #tGroup.MemberList == 0 then
				MY_CataclysmParty:CloseParty(arg3)
				MY_CataclysmParty:AutoLinkAllPanel()
			else
				MY_CataclysmParty:DrawParty(arg3)
			end
			if CFG.nAutoLinkMode ~= 5 then
				MY_CataclysmParty:AutoLinkAllPanel()
			end
		end
		D.SetFrameSize()
		D.UpdatePrepareBarPos()
	elseif szEvent == 'PARTY_DISBAND' then
		D.OnWageFinish()
		D.CloseCataclysmPanel()
	elseif szEvent == 'PARTY_UPDATE_MEMBER_LMR' then
		MY_CataclysmParty:CallDrawHPMP(arg1, true)
	elseif szEvent == 'PARTY_UPDATE_MEMBER_INFO' then
		MY_CataclysmParty:CallRefreshImages(arg1, false, true, nil, true)
		MY_CataclysmParty:CallDrawHPMP(arg1, true)
	elseif szEvent == 'UPDATE_PLAYER_SCHOOL_ID' then
		if X.IsTeammate(arg0) then
			MY_CataclysmParty:CallRefreshImages(arg0, false, true)
		end
	elseif szEvent == 'PLAYER_STATE_UPDATE' then
		if X.IsTeammate(arg0) then
			MY_CataclysmParty:CallDrawHPMP(arg0, true)
		end
	elseif szEvent == 'PARTY_SET_MEMBER_ONLINE_FLAG' then
		MY_CataclysmParty:CallDrawHPMP(arg1, true)
	elseif szEvent == 'TEAM_AUTHORITY_CHANGED' then
		MY_CataclysmParty:CallRefreshImages(arg2, true)
		MY_CataclysmParty:CallRefreshImages(arg3, true)
		D.CreateControlBar()
	elseif szEvent == 'PARTY_SET_FORMATION_LEADER' then
		MY_CataclysmParty:RefreshFormation()
	elseif szEvent == 'PARTY_SET_MARK' then
		MY_CataclysmParty:RefreshMark()
	elseif szEvent == 'TEAM_VOTE_REQUEST' then
		-- arg0 nVoteType
		-- arg1 nArg0
		-- arg2 nArg1
		if arg0 == 1 then
			D.OnWageStart()
		end
	elseif szEvent == 'TEAM_VOTE_RESPOND' then
		-- arg0 nVoteType
		-- arg1 dwAnswerID
		-- arg2 bYes
		-- arg3 nArg0
		-- arg4 nArg1
		if arg0 == 1 then
			MY_CataclysmParty:ChangeTeamVoteState('wage_agree', arg1, arg2 == 1 and 'resolve' or 'reject')
		end
	elseif szEvent == 'TEAM_INCOMEMONEY_CHANGE_NOTIFY' then
		local nTotalRaidMoney = GetClientTeam().nInComeMoney
		if nTotalRaidMoney and nTotalRaidMoney == 0 then
			D.OnWageFinish()
		end
	-- elseif szEvent == 'RIAD_READY_CONFIRM_RECEIVE_QUESTION' then
	elseif szEvent == 'RIAD_READY_CONFIRM_RECEIVE_ANSWER' then
		MY_CataclysmParty:ChangeTeamVoteState('raid_ready', arg0, arg1 == 1 and 'resolve' or 'reject')
	elseif szEvent == 'TEAM_CHANGE_MEMBER_GROUP' then
		local me = X.GetClientPlayer()
		local team = GetClientTeam()
		local tSrcGropu = team.GetGroupInfo(arg1)
		-- SrcGroup
		if #tSrcGropu.MemberList == 0 then
			MY_CataclysmParty:CloseParty(arg1)
			MY_CataclysmParty:AutoLinkAllPanel()
		else
			MY_CataclysmParty:DrawParty(arg1)
		end
		-- DstGroup
		if not MY_CataclysmParty:GetPartyFrame(arg2) then
			MY_CataclysmParty:CreatePanel(arg2)
		end
		MY_CataclysmParty:DrawParty(arg2)
		MY_CataclysmParty:RefreshGroupText()
		MY_CataclysmParty:RefreshMark()
		if CFG.nAutoLinkMode ~= 5 then
			MY_CataclysmParty:AutoLinkAllPanel()
		end
		D.SetFrameSize()
	elseif szEvent == 'PARTY_LEVEL_UP_RAID' then
		MY_CataclysmParty:RefreshGroupText()
	elseif szEvent == 'PARTY_LOOT_MODE_CHANGED' then
		D.CreateControlBar()
	elseif szEvent == 'PARTY_ROLL_QUALITY_CHANGED' then
		D.CreateControlBar()
	elseif szEvent == 'TARGET_CHANGE' then
		-- oldid， oldtype, newid, newtype
		MY_CataclysmParty:RefreshTarget(arg0, arg1, arg2, arg3)
	elseif szEvent == 'CHARACTER_THREAT_RANKLIST' then
		MY_CataclysmParty:RefreshThreat(arg0, arg1)
	elseif szEvent == 'MY_RAID_REC_BUFF' then
		MY_CataclysmParty:RecBuff(arg0, arg1)
	elseif szEvent == 'BUFF_UPDATE' then
		-- local owner, bdelete, index, cancancel, id  , stacknum, endframe, binit, level, srcid, isvalid, leftframe
		--     = arg0 , arg1   , arg2 , arg3     , arg4, arg5    , arg6    , arg7 , arg8 , arg9 , arg10  , arg11
		if arg4 == 33842 then
			MY_CataclysmParty:RefreshLiveByMemberID(arg0)
		end
		if arg1 then
			return
		end
		OnBuffUpdate(arg0, arg4, arg8, arg5, arg9)
	elseif szEvent == 'ON_DUNGEON_OB_STREAMER_LIST_UPDATE' then
		MY_CataclysmParty:RefreshLiveAll()
	elseif szEvent == 'PLAYER_ENTER_SCENE' then
		if X.ENVIRONMENT.RUNTIME_OPTIMIZE then
			return
		end
		local me = X.GetClientPlayer()
		if not me then
			return
		end
		local dwID = arg0
		if not me.IsPlayerInMyParty(dwID) then
			return
		end
		local function update()
			local tar = X.GetPlayer(dwID)
			if not tar then
				return
			end
			local aList = X.GetBuffList(tar)
			if X.count_c(aList) == 0 then
				return X.DelayCall(update, 75)
			end
			for _, buff in X.ipairs_c(aList) do
				OnBuffUpdate(dwID, buff.dwID, buff.nLevel, buff.nStackNum, buff.dwSkillSrcID)
			end
		end
		X.DelayCall(update, 75)
	elseif szEvent == 'MY_CATACLYSM_BUFF_LIST_CACHE_UPDATE' then
		local team = GetClientTeam()
		if not team then
			return
		end
		MY_CataclysmParty:ClearBuff()
		for _, dwID in ipairs(team.GetTeamMemberList()) do
			local tar = X.GetPlayer(dwID)
			if tar then
				for _, buff in X.ipairs_c(X.GetBuffList(tar)) do
					OnBuffUpdate(dwID, buff.dwID, buff.nLevel, buff.nStackNum, buff.dwSkillSrcID)
				end
			end
		end
	elseif szEvent == 'MY_CATACLYSM_SET_VISIBLE' then
		this:SetVisible(MY_Cataclysm.bVisible)
	elseif szEvent == 'MY_CATACLYSM_SET_FOLD' then
		D.UpdatePrepareBarPos()
	elseif szEvent == 'GKP_RECORD_TOTAL' then
		GKP_RECORD_TOTAL = arg0
	elseif szEvent == 'GVOICE_MIC_STATE_CHANGED' then
		D.CreateControlBar()
	elseif szEvent == 'GVOICE_SPEAKER_STATE_CHANGED' then
		D.CreateControlBar()
	elseif szEvent == 'ON_MY_MOSAICS_RESET' then
		D.ReloadCataclysmPanel()
	elseif szEvent == 'ON_TEAMSWICTH_FRAMEDRAG' then
		D.UpdateOfficialTeamSwitchPanel()
	elseif szEvent == 'TEAM_SWICTH_ROOM' then
		D.UpdateOfficialTeamSwitchPanel()
	elseif szEvent == 'UI_SCALED' then
		D.UpdateAnchor(this)
		MY_CataclysmParty:RefreshSFX()
		MY_CataclysmParty:AutoLinkAllPanel()
	elseif szEvent == 'LOADING_END' then -- 勿删
		D.OnWageFinish()
		D.ReloadCataclysmPanel()
		D.RaidPanel_Switch(DEBUG)
		D.TeammatePanel_Switch(false)
		D.SetFrameSize()
		D.SetFrameCaption()
	end
end

do
local i = 1
function D.FrameBuffRefreshCall()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE then
		return
	end
	local team = GetClientTeam()
	if not team then
		return
	end
	local aList = team.GetTeamMemberList()
	local nCount = #aList
	if i > nCount then
		i = 1
	end
	local tar = X.GetPlayer(aList[i])
	if tar then
		for _, buff in X.ipairs_c(X.GetBuffList(tar)) do
			OnBuffUpdate(tar.dwID, buff.dwID, buff.nLevel, buff.nStackNum, buff.dwSkillSrcID)
		end
	end
	i = i + 1
end
end

function D.UpdateOfficialTeamSwitchPanel(bFollowCataclysm)
	local frame = D.GetFrame()
	if not frame then
		return
	end
	local bVisible = X.GetCurrentTeamSwitchType() == 'TEAM'
	local frmSwitch = Station.Lookup('Normal/TeamSwitchBtn')
	if bVisible and frmSwitch then
		if bFollowCataclysm then
			if TeamSwitchBtn_SetAbsPos then
				local nX, nY = frame:GetRelPos()
				TeamSwitchBtn_SetAbsPos(nX, nY)
			end
		else
			local nX, nY = frmSwitch:GetRelPos()
			nX = nX + frmSwitch:GetW()
			if nX ~= frame:GetRelX() or nY ~= frame:GetRelY() then
				frame:SetRelPos(nX, nY)
				MY_CataclysmParty:AutoLinkAllPanel()
			end
		end
	end
	if MY_Cataclysm.bVisible ~= bVisible then
		MY_Cataclysm.bVisible = bVisible
	end
end

function D.UpdateOTAction(frame)
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and GetLogicFrameCount() % 4 ~= 0 then
		return
	end
	local me = X.GetClientPlayer()
	if not me then
		return
	end
	local KOTTarget
	for _, npc in ipairs(X.GetNearBoss()) do
		if not KOTTarget or not KOTTarget.bFightState then
			KOTTarget = npc
		end
	end
	if not KOTTarget then
		local dwType, dwID = me.GetTarget()
		if dwType == TARGET.NPC then
			KOTTarget = X.GetNpc(dwID)
		elseif dwType == TARGET.PLAYER then
			local tar = X.GetPlayer(dwID)
			local dwType, dwID = tar.GetTarget()
			if dwType == TARGET.NPC then
				KOTTarget = X.GetNpc(dwID)
			end
		end
	end
	local hPrepare = frame:Lookup('', 'Handle_Prepare')
	if KOTTarget then
		local nType, dwSkillID, dwSkillLevel, fProgress = X.GetCharacterOTActionState(KOTTarget)
		if nType ~= X.CONSTANT.CHARACTER_OTACTION_TYPE.ACTION_IDLE and fProgress and dwSkillID and dwSkillID ~= 0 and dwSkillLevel then
			hPrepare:Lookup('Text_Prepare'):SetText(X.GetSkillName(dwSkillID, dwSkillLevel) or '')
			hPrepare:Lookup('Image_Prepare'):SetPercentage(fProgress)
			hPrepare:SetAlpha(255)
			frame.nOTEndTime = GetTime()
			return
		end
	end
	hPrepare:SetAlpha(math.max(0, (1 - (GetTime() - (frame.nOTEndTime or 0)) / 2000) * 255))
end

function D.OnFrameBreathe()
	local me = X.GetClientPlayer()
	if not me then
		return
	end
	D.UpdateOTAction(this)
	if not CFG.bFasterHP and GetLogicFrameCount() % CFG.nDrawInterval ~= 0 then
		return
	end
	MY_CataclysmParty:RefreshDistance()
	MY_CataclysmParty:RefreshBuff()
	MY_CataclysmParty:RefreshAttention()
	MY_CataclysmParty:RefreshCaution()
	MY_CataclysmParty:RefreshTTarget()
	MY_CataclysmParty:RefreshBossTarget()
	MY_CataclysmParty:RefreshBossFocus()
	MY_CataclysmParty:RefreshSputtering()
	MY_CataclysmParty:RefreshPlayerSkillCD()
	-- kill System Panel
	D.RaidPanel_Switch(DEBUG)
	D.TeammatePanel_Switch(false)
	D.FrameBuffRefreshCall()
	-- 官方代码太容易报错 放最后
	if not this.nBreatheTime or GetTime() - this.nBreatheTime >= 300 then -- 语音最短刷新间隔300ms
		MY_CataclysmParty:RefreshGVoice()
		this.nBreatheTime = GetTime()
	end
	X.GVoiceBase_CheckMicState()
end
end

function D.OnLButtonClick()
	local szName = this:GetName()
	if szName == 'Btn_Option' then
		local me = X.GetClientPlayer()
		local menu = {}
		if me.IsInRaid() then
			-- 团队就位
			table.insert(menu, {
				szOption = g_tStrings.STR_RAID_MENU_READY_CONFIRM,
				{
					szOption = g_tStrings.STR_RAID_READY_CONFIRM_START,
					bDisable = not X.IsClientPlayerTeamLeader(),
					fnAction = function()
						Send_RaidReadyConfirm()
						MY_CataclysmParty:StartTeamVote('raid_ready')
					end,
				},
				{
					szOption = g_tStrings.STR_RAID_READY_CONFIRM_RESET,
					fnAction = function() MY_CataclysmParty:ClearTeamVote('raid_ready') end,
				}
			})
			table.insert(menu, { bDevide = true })
		end
		-- 分配
		D.InsertDistributeMenu(menu, not X.IsClientPlayerTeamDistributor())
		if MY_TeamCountdown then
			table.insert(menu, { szOption = _L['Open team countdown'], fnAction = function()
				MY_TeamCountdown.Open()
			end })
		end
		table.insert(menu, { bDevide = true })
		if me.IsInRaid() then
			-- 编辑模式
			table.insert(menu, { szOption = string.gsub(g_tStrings.STR_RAID_MENU_RAID_EDIT, 'Ctrl', 'Alt'), bDisable = not X.IsClientPlayerTeamLeader() or not me.IsInRaid(), bCheck = true, bChecked = CFG.bEditMode, fnAction = function()
				CFG.bEditMode = not CFG.bEditMode
				X.UI.ClosePopupMenu()
			end })
			-- 人数统计
			table.insert(menu, { bDevide = true })
			D.InsertForceCountMenu(menu)
			-- 团队快照上传
			if X.IsClientPlayerTeamLeader() and X.IsTable(MY_JBTeamSnapshot) and X.IsFunction(MY_JBTeamSnapshot.CreateSnapshot) then
				table.insert(menu, {
					szOption = _L['Upload team snapshot'],
					fnAction = function()
						MY_JBTeamSnapshot.CreateSnapshot()
					end,
				})
			end
			table.insert(menu, { bDevide = true })
		end
		table.insert(menu, { szOption = _L['Interface settings'], rgb = { 255, 255, 0 }, fnAction = function()
			X.Panel.Show()
			X.Panel.Focus()
			X.Panel.SwitchTab('MY_Cataclysm')
		end })
		if X.IsDebugging() then
			table.insert(menu, { bDevide = true })
			table.insert(menu, { szOption = 'DEBUG', bCheck = true, bChecked = DEBUG, fnAction = function()
				DEBUG = not DEBUG
			end	})
		end
		local nX, nY = Cursor.GetPos(true)
		menu.x, menu.y = nX, nY
		PopupMenu(menu)
	elseif szName == 'WndButton_WorldMark' then
		if IsCtrlKeyDown() and MY_YunWorldMark then
			MY_YunWorldMark.OpenPanel()
			return
		end
		local me  = X.GetClientPlayer()
		local dwMapID = me.GetMapID()
		local nMapType = select(2, GetMapParams(dwMapID))
		if not nMapType or nMapType ~= MAP_TYPE.DUNGEON then
			OutputMessage('MSG_ANNOUNCE_RED', g_tStrings.STR_WORLD_MARK)
			return
		end
		Wnd.ToggleWindow('WorldMark')
	elseif szName == 'WndButton_GKP' then
		local team = GetClientTeam()
		local nLootMode = team.nLootMode
		if nLootMode == PARTY_LOOT_MODE.BIDDING then
			return OpenGoldTeam()
		end
		if not MY_GKP_MI then
			return X.Alert(_L['Please install and load GKP addon first.'])
		end
		return MY_GKP_MI.TogglePanel()
	elseif szName == 'Wnd_TeamTools' then
		if not MY_TeamTools then
			return X.Alert(_L['Please install and load MY_TeamTools addon first.'])
		end
		MY_TeamTools.Toggle()
	elseif szName == 'Wnd_TeamNotice' then
		if not MY_TeamNotice then
			return X.Alert(_L['Please install and load MY_TeamNotice addon first.'])
		end
		MY_TeamNotice.OpenFrame()
	elseif szName == 'Wnd_TeamMon_Subscribe' then
		if not MY_TeamMon then
			return X.Alert(_L['Please install and load MY_TeamMon addon first.'])
		end
		MY_TeamMon_Subscribe.OpenPanel()
	elseif szName == 'WndButton_LootMode' or szName == 'WndButton_LootQuality' then
		if X.IsClientPlayerTeamDistributor() then
			local menu = {}
			if szName == 'WndButton_LootMode' then
				D.InsertDistributeMenu(menu, not X.IsClientPlayerTeamDistributor())
				PopupMenu(menu[1])
			elseif szName == 'WndButton_LootQuality' then
				D.InsertDistributeMenu(menu, not X.IsClientPlayerTeamDistributor())
				PopupMenu(menu[2])
			end
		else
			return X.OutputSystemMessage(_L['You are not the distrubutor.'])
		end
	elseif szName == 'WndButton_EnvokeAllTeammates' then
		EnvokeAllTeammates()
	elseif szName == 'Wnd_TeamCountdown' then
		MY_TeamCountdown.Open()
	elseif szName == 'WndButton_Speaker' then
		X.GVoiceBase_SwitchSpeakerState()
	elseif szName == 'WndButton_Microphone' then
		X.GVoiceBase_SwitchMicState()
	end
end

function D.OnLButtonDown()
	MY_CataclysmParty:BringToTop()
end

function D.OnRButtonDown()
	MY_CataclysmParty:BringToTop()
end

function D.OnCheckBoxCheck()
	local name = this:GetName()
	if name == 'CheckBox_Fold' then
		MY_Cataclysm.bFold = true
	end
end

function D.OnCheckBoxUncheck()
	local name = this:GetName()
	if name == 'CheckBox_Fold' then
		MY_Cataclysm.bFold = false
	end
end

local SPEAKER_TIP = {
	[X.CONSTANT.SPEAKER_STATE.OPEN ] = g_tStrings.GVOICE_SPEAKER_OPEN_TIP,
	[X.CONSTANT.SPEAKER_STATE.CLOSE] = g_tStrings.GVOICE_SPEAKER_CLOSE_TIP,
}
local MIC_TIP = setmetatable({
	[X.CONSTANT.MIC_STATE.NOT_AVIAL        ] = g_tStrings.GVOICE_MIC_UNAVIAL_STATE_TIP,
	[X.CONSTANT.MIC_STATE.CLOSE_NOT_IN_ROOM] = g_tStrings.GVOICE_MIC_JOIN_STATE_TIP,
	[X.CONSTANT.MIC_STATE.CLOSE_IN_ROOM    ] = g_tStrings.GVOICE_MIC_KEY_STATE_TIP,
	[X.CONSTANT.MIC_STATE.FREE             ] = g_tStrings.GVOICE_MIC_CLOSE_STATE_TIP,
}, {
	__index = function(t, k)
		if k == X.CONSTANT.MIC_STATE.KEY then
			if X.GetHotKey('TOGGLE_GVOCIE_SAY') then
				return (g_tStrings.GVOICE_MIC_FREE_STATE_TIP
					:format(X.GetHotKeyDisplay('TOGGLE_GVOCIE_SAY')))
			else
				return g_tStrings.GVOICE_MIC_FREE_STATE_TIP2
			end
		end
	end,
})

function D.OnMouseEnter()
	local name = this:GetName()
	if name == 'WndButton_GKP'
	or name == 'WndButton_LootMode'
	or name == 'WndButton_LootQuality'
	or name == 'Wnd_TeamTools'
	or name == 'Wnd_TeamNotice'
	or name == 'Wnd_TeamMon_Subscribe'
	or name == 'Wnd_TeamCountdown' then
		this:SetAlpha(255)
	end
	if name == 'WndButton_GKP' then
		X.OutputTip(this, _L['MY_GKP'])
	elseif name == 'Wnd_TeamTools' then
		X.OutputTip(this, _L['MY_TeamTools'])
	elseif name == 'Wnd_TeamNotice' then
		X.OutputTip(this, _L['MY_TeamNotice'])
	elseif name == 'Wnd_TeamMon_Subscribe' then
		X.OutputTip(this, _L['MY_TeamMon_Subscribe'])
	elseif name == 'WndButton_EnvokeAllTeammates' then
		X.OutputTip(this, _L['EnvokeAllTeammates'])
	elseif name == 'Wnd_TeamCountdown' then
		X.OutputTip(this, _L['TeamCountdown'])
	elseif name == 'WndButton_Speaker' then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(GetFormatText(SPEAKER_TIP[this.nSpeakerState]), 400, { x, y, w, h }, ALW.TOP_BOTTOM)
	elseif name == 'WndButton_Microphone' then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputTip(GetFormatText(MIC_TIP[this.nMicState]), 400, { x, y, w, h }, ALW.TOP_BOTTOM)
	end
	D.SetFrameSize(true)
end

function D.OnMouseLeave()
	local name = this:GetName()
	if name == 'WndButton_GKP'
	or name == 'WndButton_LootMode'
	or name == 'WndButton_LootQuality'
	or name == 'Wnd_TeamTools'
	or name == 'Wnd_TeamNotice'
	or name == 'Wnd_TeamMon_Subscribe'
	or name == 'Wnd_TeamCountdown' then
		this:SetAlpha(220)
		X.HideTip()
	end
	if not IsKeyDown('LButton') then
		D.SetFrameSize()
	end
	HideTip()
end

function D.CheckEnableTeamPanel()
	if D.CheckCataclysmEnable() then
		D.ReloadCataclysmPanel()
	end
	if not MY_Cataclysm.bEnable then
		local me = X.GetClientPlayer()
		if me.IsInRaid() then
			FireUIEvent('MY_CATACLYSM_PANEL_RAID', true)
		elseif me.IsInParty() then
			FireUIEvent('MY_CATACLYSM_PANEL_TEAMMATE', true)
		end
	end
end

function D.ToggleTeamPanel()
	MY_Cataclysm.bEnable = not MY_Cataclysm.bEnable
	D.CheckEnableTeamPanel()
end

function D.ConfirmRestoreConfig()
	MessageBox({
		szName = 'MY_Cataclysm_Restore_Default',
		szAlignment = 'CENTER',
		szMessage = _L['Please choose your favorite raid style.\nYou can rechoose in setting panel.'],
		{
			szOption = _L['Official style'],
			fnAction = function()
				D.SetConfig(X.Clone(CTM_CONFIG_OFFICIAL), true)
				D.CheckEnableTeamPanel()
				X.Panel.SwitchTab('MY_Cataclysm', true)
			end,
		},
		{
			szOption = _L['Cataclysm style'],
			fnAction = function()
				D.SetConfig(X.Clone(CTM_CONFIG_CATACLYSM), true)
				D.CheckEnableTeamPanel()
				X.Panel.SwitchTab('MY_Cataclysm', true)
			end,
		},
		{
			szOption = _L['Keep current'],
			fnAction = function()
				if CFG.eCss == '' then
					CFG.eCss = 'DEFAULT'
				end
			end,
		},
	})
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_Cataclysm',
	exports = {
		{
			preset = 'UIEvent',
			fields = {
				'GetFrame',
				'OpenCataclysmPanel',
				'CloseCataclysmPanel',
				'LoadAncientConfigure',
				'SetFrameSize',
				'UpdateBuffListCache',
				'CheckEnableTeamPanel',
				'ToggleTeamPanel',
				'CheckCataclysmEnable',
				'ReloadCataclysmPanel',
				'ConfirmRestoreConfig',
			},
			root = D,
		},
	},
}
MY_CataclysmMain = X.CreateModule(settings)
end

X.RegisterEvent('MY_CATACLYSM_PANEL_TEAMMATE', function()
	D.TeammatePanel_Switch(arg0)
end)
X.RegisterEvent('MY_CATACLYSM_PANEL_RAID', function()
	D.RaidPanel_Switch(arg0)
end)

-- 关于界面打开和刷新面板的时机
-- 1) 普通情况下 组队会触发[PARTY_UPDATE_BASE_INFO]打开+刷新
-- 2) 进入名剑大会/战场的情况下 不会触发[PARTY_UPDATE_BASE_INFO]事件
--    需要利用外面注册的[LOADING_END]来打开+刷新
-- 3) 如果在名剑大会/战场掉线重上的情况下 需要使用外面注册的[LOADING_END]来打开面板
--    然后在UI上注册的[LOADING_END]的来刷新界面，否则获取不到团队成员，只能获取到有几个队
--    UI的[LOADING_END]晚大约30m，然后就能获取到团队成员了??????
-- 4) 从名剑大会/战场回到原服使用外面注册的[LOADING_END]来打开+刷新
-- 5) 普通掉线/过地图使用外面注册的[LOADING_END]打开+刷新，避免过地图时候团队变动没有收到事件的情况。
-- 6) 综上所述的各式各样的奇葩情况 可以做如下的调整
--    利用外面的注册的[LOADING_END]来打开
--    利用UI注册的[LOADING_END]来刷新
--    避免多次重复刷新面板浪费开销
-- 7) 新增 PARTY_RESET 事件，官方从名剑大会出来时候补发这个事件

X.RegisterEvent('PARTY_UPDATE_BASE_INFO', function()
	X.WithClientPlayer(function(me)
		D.CheckCataclysmEnable()
		D.ReloadCataclysmPanel()
	end)
	PlaySound(SOUND.UI_SOUND, g_sound.Gift)
end)

X.RegisterEvent('PARTY_LEVEL_UP_RAID', function()
	X.WithClientPlayer(function(me)
		D.CheckCataclysmEnable()
		D.ReloadCataclysmPanel()
	end)
end)

X.RegisterEvent('PARTY_RESET', function()
	X.WithClientPlayer(function(me)
		D.CheckCataclysmEnable()
		D.ReloadCataclysmPanel()
	end)
end)

X.RegisterEvent('ON_PLUGIN_TEAM_NOTICE', function()
	local tData, dwPlayerID = arg0, arg1
	if not tData[1] or not tData[1].dwSubType or tData[1].dwSubType ~= PLUGIN_TEAM.SKILL_NOTICE then
		return
	end
	local tSkillInfo = string.split(tData[1].szText, '|')
	if not tSkillInfo or X.IsEmpty(tSkillInfo) then
		return
	end
	local nEndFrame = tonumber(tSkillInfo[1])
	local dwSkillID = tonumber(tSkillInfo[2])
	local nSkillLevel = tonumber(tSkillInfo[3])
	if not nEndFrame or not dwSkillID or not nSkillLevel then
		return
	end
	MY_CataclysmParty:RecPlayerSkillCD(dwPlayerID, dwSkillID, nSkillLevel, nEndFrame)
end)

X.RegisterUserSettingsInit(function()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and CFG.nDrawInterval == 4 then
		CFG.nDrawInterval = 16
	end
	X.WithClientPlayer(function(me)
		D.CheckCataclysmEnable()
		D.UpdateBuffListCache()
		D.ReloadCataclysmPanel()
	end)
end)

X.RegisterEvent('LOADING_END', function()
	X.WithClientPlayer(function(me)
		D.CheckCataclysmEnable()
	end)
end)

X.RegisterAddonMenu(function()
	return { szOption = _L['Cataclysm Team Panel'], bCheck = true, bChecked = MY_Cataclysm.bEnable, fnAction = D.ToggleTeamPanel }
end)

X.RegisterTutorial({
	szKey = 'MY_Cataclysm',
	szMessage = _L['Would you like to use MY cataclysm?'],
	fnRequire = function() return not MY_Cataclysm.bEnable end,
	{
		szOption = _L['Use'],
		bDefault = true,
		fnAction = function()
			MY_Cataclysm.bEnable = true
			D.CheckEnableTeamPanel()
			X.Panel.RedrawTab('MY_Cataclysm')
		end,
	},
	{
		szOption = _L['Not use'],
		fnAction = function()
			MY_Cataclysm.bEnable = false
			D.CheckEnableTeamPanel()
			X.Panel.RedrawTab('MY_Cataclysm')
		end,
	},
})

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
