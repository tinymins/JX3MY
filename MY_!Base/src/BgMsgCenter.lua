--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 背景通讯处理函数集成
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) MY
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/BgMsgCenter')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. 'lang/BgMsgCenter/')
--------------------------------------------------------------------------------

local D = {}

function D.GetReplyChannel(nChannel, szTalkerName)
	if nChannel == PLAYER_TALK_CHANNEL.WHISPER then
		return szTalkerName
	end
	return nChannel
end

function D.NeedReply(aRequestID, aRefreshID, dwID, szGlobalID, bNotChange)
	if not aRequestID then
		return true
	end
	for _, v in ipairs(aRequestID) do
		if v == dwID or v == szGlobalID then
			return true
		end
	end
	if bNotChange then
		return false
	end
	if not aRefreshID then
		return true
	end
	for _, v in ipairs(aRefreshID) do
		if v == dwID or v == szGlobalID then
			return true
		end
	end
	return false
end

-- 测试用（请求共享位置）
X.RegisterBgMsg('ASK_CURRENT_LOC', function(_, data, nChannel, dwTalkerID, szTalkerName, bSelf)
	if bSelf then
		return
	end
	MessageBox({
		szName = 'ASK_CURRENT_LOC' .. dwTalkerID,
		szMessage = _L('[%s] wants to get your location, would you like to share?', szTalkerName), {
			szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function()
				local me = X.GetClientPlayer()
				local nReplyChannel = D.GetReplyChannel(nChannel, szTalkerName)
				X.SendBgMsg(nReplyChannel, 'REPLY_CURRENT_LOC', { me.GetMapID(), me.nX, me.nY, me.nZ }, true)
			end
		}, { szOption = g_tStrings.STR_HOTKEY_CANCEL },
	})
end)

-- 测试用（查看版本信息）
X.RegisterBgMsg(X.NSFormatString('{$NS}_VERSION_CHECK'), function(_, oData, nChannel, dwTalkerID, szTalkerName, bSelf)
	if bSelf then
		return
	end
	local bSilent = oData[1]
	if not bSilent and X.IsClientPlayerInParty() then
		X.SendChat(PLAYER_TALK_CHANNEL.RAID, _L('I\'ve installed %s v%s', X.PACKET_INFO.NAME, X.PACKET_INFO.VERSION))
	end
	local nReplyChannel = D.GetReplyChannel(nChannel, szTalkerName)
	X.SendBgMsg(nReplyChannel, X.NSFormatString('{$NS}_VERSION_REPLY'), {X.PACKET_INFO.VERSION, X.PACKET_INFO.BUILD}, true)
end)

-- 测试用（调试工具）
X.RegisterBgMsg(X.NSFormatString('{$NS}_GFN_CHECK'), function(_, oData, nChannel, dwTalkerID, szTalkerName, bSelf)
	if bSelf or not X.IsTable(oData) or not X.IsString(oData[1]) or not X.IsString(oData[2]) then
		return
	end
	local res = oData[2]:find('return ')
		and {X.XpCall(X.DecodeLUAData(oData[2]), _G)}
		or {X.XpCall(X.Get(_G, oData[2]), select(3, X.Unpack(oData)))}
	X.SendBgMsg(szTalkerName, X.NSFormatString('{$NS}_GFN_REPLY'), {oData[1], res}, true)
end)

-- 进组查看属性
X.RegisterBgMsg('RL', function(_, data, nChannel, dwTalkerID, szTalkerName, bIsSelf)
	if not bIsSelf then
		local nReplyChannel = D.GetReplyChannel(nChannel, szTalkerName)
		if data[1] == 'ASK' then
			X.Confirm(_L('[%s] want to see your info, OK?', szTalkerName), function()
				local me = X.GetClientPlayer()
				local nGongZhan = X.GetBuff(me, 3219) and 1 or 0
				local bEx = X.IsAuthorPlayer(me.dwID) and 'Author' or 'Player'
				X.SendBgMsg(nReplyChannel, 'RL', {'Feedback', me.dwID, UI_GetPlayerMountKungfuID(), nGongZhan, bEx}, true)
			end)
		end
	end
end)

-- 查看完整属性
local CHAR_INFO_BLOCK_LIST = {}
X.RegisterBgMsg('CHAR_INFO', function(_, data, nChannel, dwTalkerID, szTalkerName, bIsSelf)
	if not bIsSelf and data[2] == X.GetClientPlayerID() then
		local nReplyChannel = X.IsTeammate(dwTalkerID)
			and PLAYER_TALK_CHANNEL.RAID
			or D.GetReplyChannel(nChannel, szTalkerName)
		if data[1] == 'ASK' then
			local bAcquaintance = X.IsTeammate(dwTalkerID) or X.IsFellowship(dwTalkerID) or X.IsAuthorPlayer(dwTalkerID, szTalkerName)
			local bDebug = data[3] == 'DEBUG' and bAcquaintance
			local bConfirm = not bAcquaintance and not bDebug
			local function fnResolve()
				--[[#DEBUG BEGIN]]
				X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'CHAR_INFO request from ' .. szTalkerName .. ' (' .. dwTalkerID .. ') accepted, sending info.', X.DEBUG_LEVEL.LOG)
				--[[#DEBUG END]]
				local aInfo = X.GetClientPlayerCharInfo()
				if not X.IsTeammate(dwTalkerID) and not bDebug then
					for _, v in ipairs(aInfo) do
						v.tip = nil
					end
				end
				X.SendBgMsg(nReplyChannel, 'CHAR_INFO', {'ACCEPT', dwTalkerID, aInfo}, true)
			end
			local function fnReject()
				X.SendBgMsg(nReplyChannel, 'CHAR_INFO', {'REFUSE', dwTalkerID}, true)
			end
			--[[#DEBUG BEGIN]]
			X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'CHAR_INFO request from ' .. szTalkerName .. ' (' .. dwTalkerID .. '), ' .. (bConfirm and 'confirm' or 'no confirm') .. ' required', X.DEBUG_LEVEL.LOG)
			--[[#DEBUG END]]
			if not CHAR_INFO_BLOCK_LIST[dwTalkerID] and (not _G.MY_CharInfo or _G.MY_CharInfo.bEnable or bDebug) then
				if bConfirm then
					X.PeekOtherPlayerByID(dwTalkerID, function (dwID, eState, kPlayer)
						if not kPlayer or kPlayer.nLevel ~= X.CONSTANT.MAX_PLAYER_LEVEL then
							--[[#DEBUG BEGIN]]
							X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'CHAR_INFO request from ' .. szTalkerName .. ' (' .. dwTalkerID .. ') rejected due to not max level.', X.DEBUG_LEVEL.LOG)
							--[[#DEBUG END]]
							return
						end
						X.MessageBox('MY_CharInfo', {
							szMessage = _L('[%s] wants to see your detailed character info, OK?', szTalkerName),
							{
								szOption = g_tStrings.STR_ACCEPT,
								fnAction = fnResolve,
							}, {
								szOption = g_tStrings.STR_REFUSE,
								fnAction = fnReject,
							},
							{
								szOption = _L('Block'),
								bCheck = true,
								fnAction = function()
									fnReject()
									CHAR_INFO_BLOCK_LIST[dwTalkerID] = true
								end,
							}
						})
					end)
				else
					fnResolve()
				end
			else
				fnReject()
			end
		elseif data[1] == 'REFUSE' and data[2] == X.GetClientPlayerID() then
			X.OutputSystemAnnounceMessage(_L('[%s] refused to share detailed character info with you.', szTalkerName))
		end
	end
end)

-- 搬运JH_ABOUT
X.RegisterBgMsg(X.NSFormatString('{$NS}_ABOUT'), function(_, data, nChannel, dwTalkerID, szTalkerName, bIsSelf)
	local nReplyChannel = D.GetReplyChannel(nChannel, szTalkerName)
	if data[1] == 'Author' then -- 版本检查 自用 可以绘制详细表格
		local me, szTong = X.GetClientPlayer(), ''
		if me.dwTongID > 0 then
			szTong = X.GetTongName(me.dwTongID) or 'Failed'
		end
		local szServer = select(2, GetUserServer())
		X.SendBgMsg(nReplyChannel, X.NSFormatString('{$NS}_ABOUT'), {'info',
			me.GetTotalEquipScore(),
			me.GetMapID(),
			szTong,
			me.nRoleType,
			X.PACKET_INFO.VERSION,
			szServer,
			X.GetBuff(me, 3219)
		}, true)
	elseif data[1] == 'TeamAuth' then -- 防止有人睡着 遇到了不止一次了
		local team = GetClientTeam()
		team.SetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER, dwTalkerID)
		team.SetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK, dwTalkerID)
		team.SetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE, dwTalkerID)
	elseif data[1] == 'TeamLeader' then
		GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER, dwTalkerID)
	elseif data[1] == 'TeamMark' then
		GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK, dwTalkerID)
	elseif data[1] == 'TeamDistribute' then
		GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE, dwTalkerID)
	elseif data[1] == 'RESTRICTION' then
		X.SetRestricted(data[2], data[3])
	elseif data[1] == 'DEBUG' then
		X.SetDebugging(data[2], data[3])
	end
end)

-- 切换地图
do
	local l_nSwitchMapID, l_nSwitchSubID
	local l_nEnteringMapID, l_nEnteringSubID, l_dwEnteringTime, l_dwEnteringSwitchTime

	-- 点击进入某地图（进入前）
	local function OnSwitchMap(dwMapID, dwSubID, aMapCopy, dwTime)
		if not X.IsClientPlayerInParty() then
			return
		end
		l_nEnteringMapID = dwMapID
		l_nEnteringSubID = dwSubID
		l_dwEnteringSwitchTime = dwTime
		--[[#DEBUG BEGIN]]
		local szDebug = 'Switch map: ' .. dwMapID
		if dwSubID then
			szDebug = szDebug .. '(' .. dwSubID .. ')'
		end
		if aMapCopy then
			szDebug = szDebug .. ' #' .. table.concat(aMapCopy, ',')
		end
		if dwTime then
			szDebug = szDebug .. ' @' .. dwTime
		end
		X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, szDebug, X.DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		X.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, X.NSFormatString('{$NS}_SWITCH_MAP'), {dwMapID, dwSubID, aMapCopy, dwTime}, true)
		X.SendBgMsg(PLAYER_TALK_CHANNEL.ROOM, X.NSFormatString('{$NS}_SWITCH_MAP'), {dwMapID, dwSubID, aMapCopy, dwTime}, true)
	end

	-- 成功进入某地图并加载完成（进入后）
	local function OnEnterMap(dwMapID, dwSubID, aMapCopy, dwTime, dwSwitchTime, nCopyIndex)
		if not X.IsClientPlayerInParty() then
			return
		end
		--[[#DEBUG BEGIN]]
		local szDebug = 'Enter map: ' .. dwMapID
		if dwSubID then
			szDebug = szDebug .. '(' .. dwSubID .. ')'
		end
		if aMapCopy then
			szDebug = szDebug .. ' #' .. table.concat(aMapCopy, ',')
		end
		if dwTime then
			szDebug = szDebug .. ' @' .. dwTime
		end
		if dwSwitchTime then
			szDebug = szDebug .. ' <- ' .. dwSwitchTime
		end
		X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, szDebug, X.DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		X.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, X.NSFormatString('{$NS}_ENTER_MAP'), {dwMapID, dwSubID, aMapCopy, dwTime, dwSwitchTime, nCopyIndex}, true)
		X.SendBgMsg(PLAYER_TALK_CHANNEL.ROOM, X.NSFormatString('{$NS}_ENTER_MAP'), {dwMapID, dwSubID, aMapCopy, dwTime, dwSwitchTime, nCopyIndex}, true)
	end

	local function OnCrossMapGoFB()
		local dwTime = GetCurrentTime()
		local dwMapID, dwID = this.tInfo.MapID, this.tInfo.ID
		-- 秘境可重置且是队长则会弹出重置提示框 走 crossmap_dungeon_reset 流程
		if X.IsDungeonResetable(dwMapID) and X.IsClientPlayerTeamLeader() then
			l_nSwitchMapID, l_nSwitchSubID = dwMapID, dwID
		else
			X.GetMapSaveCopy(dwMapID, function(aMapCopy)
				OnSwitchMap(dwMapID, dwID, aMapCopy, dwTime)
			end)
		end
		return X.UI.FormatUIEventMask(true, true)
	end

	local function OnFBAppendItemFromIni(hList)
		for i = 0, hList:GetItemCount() - 1 do
			local hItem = hList:Lookup(i)
			UnhookTableFunc(hItem, 'OnItemLButtonDBClick', OnCrossMapGoFB)
			HookTableFunc(hItem, 'OnItemLButtonDBClick', OnCrossMapGoFB, { bAfterOrigin = true, bHookReturn = true })
		end
	end

	X.RegisterFrameCreate('CrossMap', 'LIB#CD', function(name, frame)
		local hList = frame:Lookup('Wnd_CrossFB', 'Handle_DifficultyList')
		if hList then
			OnFBAppendItemFromIni(hList)
			HookTableFunc(hList, 'AppendItemFromIni', OnFBAppendItemFromIni, { bAfterOrigin = true })
		end
		local btn = frame:Lookup('Wnd_CrossFB/Btn_GoGoGo')
		if btn then
			HookTableFunc(btn, 'OnLButtonUp', OnCrossMapGoFB, { bAfterOrigin = true })
		end
		--[[#DEBUG BEGIN]]
		X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'Cross panel hooked.', X.DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
	end)

	X.RegisterEvent(X.NSFormatString('{$NS}_MESSAGE_BOX_ACTION'), 'LIB#CD', function()
		if arg0 ~= 'crossmap_dungeon_reset' then
			return
		end
		if arg1 == 'ACTION' and arg2 == g_tStrings.STR_HOTKEY_SURE and l_nSwitchMapID then
			OnSwitchMap(l_nSwitchMapID, l_nSwitchSubID, nil, GetCurrentTime())
		end
		l_nSwitchMapID, l_nSwitchSubID = nil, nil
	end)

	X.RegisterEvent('LOADING_ENDING', 'LIB#CD', function()
		l_dwEnteringTime = GetCurrentTime()
		local me = X.GetClientPlayer()
		local dwMapID = me.GetMapID()
		local nCopyIndex = me.GetScene().nCopyIndex
		X.GetMapSaveCopy(dwMapID, function(aMapCopy)
			local nSubID, dwSwitchTime
			if dwMapID == l_nEnteringMapID then
				nSubID, dwSwitchTime = l_nEnteringSubID, l_dwEnteringSwitchTime
			end
			OnEnterMap(dwMapID, nSubID, aMapCopy, l_dwEnteringTime, dwSwitchTime, nCopyIndex)
		end)
	end)

	X.RegisterBgMsg(X.NSFormatString('{$NS}_ENTER_MAP_REQ'), function(_, data, nChannel, dwTalkerID, szTalkerName, bSelf)
		if not l_dwEnteringTime then
			return
		end
		--[[#DEBUG BEGIN]]
		X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'Enter map request from ' .. szTalkerName, X.DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		local me = X.GetClientPlayer()
		local dwMapID = me.GetMapID()
		local nCopyIndex = me.GetScene().nCopyIndex
		X.GetMapSaveCopy(dwMapID, function(aMapCopy)
			local nSubID, dwSwitchTime
			if dwMapID == l_nEnteringMapID then
				nSubID, dwSwitchTime = l_nEnteringSubID, l_dwEnteringSwitchTime
			end
			OnEnterMap(dwMapID, nSubID, aMapCopy, l_dwEnteringTime, dwSwitchTime, nCopyIndex)
		end)
	end)
end

X.RegisterBgMsg(X.NSFormatString('{$NS}_OUTPUT_BUFF'), function(_, data, nChannel, dwTalkerID, szTalkerName, bSelf)
	local aRes = {}
	local me = X.GetClientPlayer()
	for _, buff in X.ipairs_c(X.GetBuffList(me)) do
		table.insert(aRes, X.CloneBuff(buff, {}))
	end
	X.Output(aRes)
end)


-- 角色 GlobalID
do
	local LAST_TIME = 0
	X.RegisterBgMsg(X.NSFormatString('{$NS}_GLOBAL_ID_REQUEST'), function(_, data, nChannel, dwTalkerID, szTalkerName, bSelf)
		if bSelf then
			--[[#DEBUG BEGIN]]
			X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'Global id request sent.', X.DEBUG_LEVEL.LOG)
			--[[#DEBUG END]]
			return
		end
		if LAST_TIME + 5 > GetCurrentTime() then
			return
		end
		local aRequestID, aRefreshID = data[1], data[2]
		local dwID = X.GetClientPlayerID()
		local szGlobalID = X.GetClientPlayerGlobalID()
		local bNotChange = not X.IsNil(LAST_TIME)
		local bResponse = D.NeedReply(aRequestID, aRefreshID, dwID, szGlobalID, bNotChange)
		--[[#DEBUG BEGIN]]
		X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'Global id request from ' .. szTalkerName
			.. ', will ' .. (bResponse and '' or 'not ') .. 'response.', X.DEBUG_LEVEL.PM_LOG)
		--[[#DEBUG END]]
		if bResponse then
			local nReplyChannel = D.GetReplyChannel(nChannel, szTalkerName)
			X.SendBgMsg(nReplyChannel, X.NSFormatString('{$NS}_GLOBAL_ID'), X.GetClientPlayerGlobalID(), true)
			LAST_TIME = GetCurrentTime()
		end
	end)
end
--------------------------------------------------------------------------------
--- 子插件自定义背景通讯
--------------------------------------------------------------------------------

-- 团队工具·团队秘境CD
do
	local LAST_TIME = {}
	X.RegisterBgMsg('MY_TEAM_TOOLS__MAP_CD_REQ', function(_, data, nChannel, dwTalkerID, szTalkerName, bSelf)
		if bSelf then
			--[[#DEBUG BEGIN]]
			X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'Team map copy id request sent.', X.DEBUG_LEVEL.LOG)
			--[[#DEBUG END]]
			return
		end
		local dwMapID, aRequestID, aRefreshID = data[1], data[2], data[3]
		local dwID = X.GetClientPlayerID()
		local szGlobalID = X.GetClientPlayerGlobalID()
		local bNotChange = not X.IsNil(LAST_TIME[dwMapID])
		local bResponse = D.NeedReply(aRequestID, aRefreshID, dwID, szGlobalID, bNotChange)
		--[[#DEBUG BEGIN]]
		X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'Team map copy id request from ' .. szTalkerName
			.. ', will ' .. (bResponse and '' or 'not ') .. 'response.', X.DEBUG_LEVEL.PM_LOG)
		--[[#DEBUG END]]
		if bResponse then
			local tProgress, aCopyID
			local function fnAction()
				if not tProgress or not aCopyID then
					return
				end
				local nReplyChannel = D.GetReplyChannel(nChannel, szTalkerName)
				X.SendBgMsg(nReplyChannel, 'MY_TEAM_TOOLS__MAP_CD_RES', {X.GetClientPlayerGlobalID(), dwMapID, aCopyID, tProgress}, true)
			end
			local bCDProgressMap = X.IsCDProgressMap(dwMapID)
			if bCDProgressMap then
				X.GetClientPlayerMapCDProgress(dwMapID, function(t)
					tProgress = t
					fnAction()
				end)
			else
				tProgress = {}
			end
			X.GetMapSaveCopy(function(tMapID)
				aCopyID = tMapID[dwMapID] or {}
				fnAction()
			end)
			LAST_TIME[dwMapID] = GetCurrentTime()
		end
	end)
	X.RegisterEvent('UPDATE_DUNGEON_ROLE_PROGRESS', function()
		local dwMapID, dwPlayerID = arg0, arg1
		if dwPlayerID == X.GetClientPlayerID() then
			LAST_TIME[dwMapID] = nil
		end
	end)
	X.RegisterEvent({
		'ON_RESET_MAP_RESPOND',
		'ON_APPLY_PLAYER_SAVED_COPY_RESPOND',
	}, function()
		LAST_TIME = {}
	end)
end

-- 团队工具·成就统计
do
	local LAST_ACHIEVE_TIME, LAST_COUNTER_TIME = {}, {}
	X.RegisterBgMsg('MY_TEAM_TOOLS__ACHIEVE_REQ', function(_, data, nChannel, dwTalkerID, szTalkerName, bSelf)
		if bSelf then
			--[[#DEBUG BEGIN]]
			X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'Team achievement request sent.', X.DEBUG_LEVEL.LOG)
			--[[#DEBUG END]]
			return
		end
		local aAchieveID, aCounterID, aRequestID, aRefreshID = data[1], data[2], data[3], data[4]
		local dwID = X.GetClientPlayerID()
		local szGlobalID = X.GetClientPlayerGlobalID()
		local bNotChange = true
		for _, vv in ipairs(aAchieveID) do
			if not LAST_ACHIEVE_TIME[vv] then
				bNotChange = false
			end
		end
		for _, vv in ipairs(aCounterID) do
			if not LAST_COUNTER_TIME[vv] then
				bNotChange = false
			end
		end
		local bResponse = D.NeedReply(aRequestID, aRefreshID, dwID, szGlobalID, bNotChange)
		--[[#DEBUG BEGIN]]
		X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'Achievement request from ' .. szTalkerName
			.. ', will ' .. (bResponse and '' or 'not ') .. 'response.', X.DEBUG_LEVEL.PM_LOG)
		--[[#DEBUG END]]
		if bResponse then
			local me = X.GetClientPlayer()
			local aAchieveRes, aCounterRes = {}, {}
			for _, dwAchieveID in ipairs(aAchieveID) do
				LAST_ACHIEVE_TIME[dwAchieveID] = GetCurrentTime()
				table.insert(aAchieveRes, {dwAchieveID, me.IsAchievementAcquired(dwAchieveID)})
			end
			for _, dwCounterID in ipairs(aCounterID) do
				LAST_COUNTER_TIME[dwCounterID] = GetCurrentTime()
				table.insert(aCounterRes, {dwCounterID, me.GetAchievementCount(dwCounterID)})
			end
			local nReplyChannel = D.GetReplyChannel(nChannel, szTalkerName)
			X.SendBgMsg(nReplyChannel, 'MY_TEAM_TOOLS__ACHIEVE_RES', {aAchieveRes, aCounterRes, X.GetClientPlayerGlobalID()}, true)
		end
	end)
	X.RegisterEvent({
		'NEW_ACHIEVEMENT',
		'SYNC_ACHIEVEMENT_DATA',
		'UPDATE_ACHIEVEMENT_POINT',
		'UPDATE_ACHIEVEMENT_COUNT',
	}, function()
		LAST_ACHIEVE_TIME, LAST_COUNTER_TIME = {}, {}
	end)
end

--------------------------------------------------------------------------------

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
