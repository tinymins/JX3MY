--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 团队面板小队界面
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Cataclysm/MY_CataclysmParty'
local PLUGIN_NAME = 'MY_Cataclysm'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Cataclysm'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.0') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
X.RegisterRestriction('MY_Cataclysm.CHANGGE_SHADOW', { ['*'] = true, intl = false })
X.RegisterRestriction('MY_Cataclysm.Seize', { ['*'] = true })
--------------------------------------------------------------------------------
local D = {}
-----------------------------------------------
-- 重构 @ 2015 赶时间 很多东西写的很粗略
-----------------------------------------------
local Station, SetTarget = Station, SetTarget
local Target_GetTargetData = Target_GetTargetData
local MY_GetBuff, MY_GetEndTime = X.GetBuff, X.GetEndTime
local CFG                    = MY_Cataclysm.CFG
local CTM_BG_COLOR_MODE      = MY_Cataclysm.BG_COLOR_MODE
-- global STR cache
local COINSHOP_SOURCE_NULL   = g_tStrings.COINSHOP_SOURCE_NULL
local STR_FRIEND_NOT_ON_LINE = g_tStrings.STR_FRIEND_NOT_ON_LINE
local FIGHT_DEATH            = g_tStrings.FIGHT_DEATH
-- STATE cache
local MOVE_STATE_ON_STAND    = MOVE_STATE.ON_STAND
local MOVE_STATE_ON_DEATH    = MOVE_STATE.ON_DEATH
-- local value
local CTM_ALPHA_STEP         = 15    -- 240 / CTM_ALPHA_STEP
local CTM_GROUP_COUNT        = 5 - 1 -- 防止以后开个什么40人本 估计不太可能 就和剑三这还得好几年
local CTM_MEMBER_COUNT       = 5
local CTM_DRAG               = false
local CTM_DRAG_ID
local CTM_CLICK_DISMISS
local CTM_TARGET  -- 注意这个是UI逻辑选中目标 不一定是真实的当前目标
local CTM_TTARGET -- 注意这个是UI逻辑目标选中的目标 不一定是真实的当前目标
local CTM_CACHE              = setmetatable({}, { __mode = 'v' })
local CTM_LIFE_CACHE         = {} -- 当前帧队友血量缓存
local CTM_BUFF_TIME          = {} -- 附近目标 BUFF 刷新时间戳
local CTM_BUFF_RULE          = {} -- 附近记录到的需要显示的BUFF规则缓存
local CTM_BOSS_CACHE         = {} -- 附近的首领缓存
local CTM_BOSS_FOCUS_BUFF    = {} -- 附近记录到的首领点名BUFF缓存
local CTM_ATTENTION_BUFF     = {} -- 附近记录到的需要显示蒙版的BUFF缓存
local CTM_ATTENTION_STACK    = {} -- 蒙版BUFF栈（取第一个也就是最新入栈的作为显示颜色）
local CTM_CAUTION_BUFF       = {} -- 附近记录到的警告BUFF缓存
local CTM_SCREEN_HEAD        = {} -- 头顶倒计时缓存
local CTM_BOSS_TARGET        = {} -- 首领目标缓存
local CTM_BOSS_FOCUSED_STATE = {} -- 被首领点名的状态缓存
local CTM_NPC_THREAT_TARGET  = {} -- 首领一仇缓存
local CTM_PLAYER_SKILL_CD    = {} -- 队友招式调息状态显示
local CTM_TEMP_TARGET_TYPE, CTM_TEMP_TARGET_ID
local CHANGGE_REAL_SHADOW_TPLID = 46140 -- 清绝歌影 的主体影子
local CHANGGE_REAL_SHADOW_CACHE = {}
do
local function onNpcEnterScene()
	local me = X.GetClientPlayer()
	local npc = X.GetNpc(arg0)
	if X.IsBoss(me.GetMapID(), npc.dwTemplateID) then
		CTM_BOSS_CACHE[npc.dwID] = npc
	end
	if npc.dwTemplateID == CHANGGE_REAL_SHADOW_TPLID then
		if not (IsEnemy(X.GetClientPlayerID(), arg0) and X.IsRestricted('MY_Cataclysm.CHANGGE_SHADOW')) then
			local dwType, dwID = X.GetCharacterTarget(me)
			if dwType == TARGET.PLAYER and dwID == npc.dwEmployer then
				X.SetClientPlayerTarget(TARGET.NPC, arg0)
			end
		end
		CHANGGE_REAL_SHADOW_CACHE[npc.dwEmployer] = arg0
		CHANGGE_REAL_SHADOW_CACHE[arg0] = npc.dwEmployer
	end
end
X.RegisterEvent('NPC_ENTER_SCENE', 'MY_Cataclysm', onNpcEnterScene)

local function onNpcLeaveScene()
	local me = X.GetClientPlayer()
	local npc = X.GetNpc(arg0)
	if CHANGGE_REAL_SHADOW_CACHE[arg0] then
		if not (IsEnemy(X.GetClientPlayerID(), arg0) and X.IsRestricted('MY_Cataclysm.CHANGGE_SHADOW')) then
			local dwType, dwID = X.GetCharacterTarget(me)
			if dwType == TARGET.NPC and dwID == arg0 then
				X.SetClientPlayerTarget(TARGET.PLAYER, npc.dwEmployer)
			end
		end
		CHANGGE_REAL_SHADOW_CACHE[CHANGGE_REAL_SHADOW_CACHE[arg0]] = nil
		CHANGGE_REAL_SHADOW_CACHE[arg0] = nil
	end
	CTM_BOSS_CACHE[npc.dwID] = nil
end
X.RegisterEvent('NPC_LEAVE_SCENE', 'MY_Cataclysm', onNpcLeaveScene)
end

X.RegisterEvent('BUFF_UPDATE', 'MY_Cataclysm', function()
	-- local owner, bdelete, index, cancancel, id  , stacknum, endframe, binit, level, srcid, isvalid, leftframe
	--     = arg0 , arg1   , arg2 , arg3     , arg4, arg5    , arg6    , arg7 , arg8 , arg9 , arg10  , arg11
	if arg1 then
		return
	end
	if not CTM_BUFF_TIME[arg0] then
		CTM_BUFF_TIME[arg0] = {}
	end
	CTM_BUFF_TIME[arg0][arg4] = GetTime()
end)

do
local function onBossSet()
	CTM_BOSS_CACHE = {}
	local dwMapID = X.GetClientPlayer().GetMapID()
	for _, npc in ipairs(X.GetNearNpc()) do
		if X.IsBoss(dwMapID, npc.dwTemplateID) then
			CTM_BOSS_CACHE[npc.dwID] = npc
		end
	end
end
X.RegisterEvent('MY_SET_BOSS', 'MY_Cataclysm', onBossSet)
end

local function SetTarget(dwType, dwID)
	if CHANGGE_REAL_SHADOW_CACHE[dwID] then
		dwType, dwID = TARGET.NPC, CHANGGE_REAL_SHADOW_CACHE[dwID]
	end
	X.SetClientPlayerTarget(dwType, dwID)
end

local function CanTarget(dwID)
	if CHANGGE_REAL_SHADOW_CACHE[dwID] then
		dwID = CHANGGE_REAL_SHADOW_CACHE[dwID]
	end
	if X.IsPlayer(dwID) then
		return X.GetPlayer(dwID)
	else
		return X.GetNpc(dwID)
	end
end

-- Package func
local HIDE_FORCE = {
	[7]  = true,
	[8]  = true,
	[10] = true,
	[21] = true,
}
local function IsPlayerManaHide(dwForceID, dwMountType)
	if dwMountType then
		if dwMountType == X.CONSTANT.KUNGFU_MOUNT_TYPE.CANG_JIAN or           --藏剑
			dwMountType == X.CONSTANT.KUNGFU_MOUNT_TYPE.TANG_MEN or           --唐门
			dwMountType == X.CONSTANT.KUNGFU_MOUNT_TYPE.MING_JIAO or          --明教
			dwMountType == X.CONSTANT.KUNGFU_MOUNT_TYPE.CANG_YUN then         --苍云
			return true
		else
			return false
		end
	else
		return HIDE_FORCE[dwForceID]
	end
end

-- 官方这代码太垃圾到处报错 = =|| 加个pcall了只能 mmp
local _GVoiceBase_IsMemberForbid = X.GVoiceBase_IsMemberForbid
local function GVoiceBase_IsMemberForbid(...)
	local status, res = X.Call(_GVoiceBase_IsMemberForbid, ...)
	return status and res
end

local _GVoiceBase_IsMemberSaying = X.GVoiceBase_IsMemberSaying
local function GVoiceBase_IsMemberSaying(...)
	local status, res = X.Call(_GVoiceBase_IsMemberSaying, ...)
	return status and res
end

local function OpenRaidDragPanel(dwMemberID)
	local hTeam = GetClientTeam()
	local tMemberInfo = X.GetTeamMemberInfo(dwMemberID)
	if not tMemberInfo then
		return
	end
	local hFrame = X.UI.OpenFrame('RaidDragPanel')

	local nX, nY = Cursor.GetPos()
	hFrame:SetAbsPos(nX, nY)
	hFrame:StartMoving()

	hFrame.dwID = dwMemberID
	local hMember = hFrame:Lookup('', '')

	local szPath, nFrame = GetForceImage(tMemberInfo.dwForceID)
	hMember:Lookup('Image_Force'):FromUITex(szPath, nFrame)

	local txtName = hMember:Lookup('Text_Name')
	txtName:SetText(tMemberInfo.szName)

	local hImageLife = hMember:Lookup('Image_Health')
	local hImageMana = hMember:Lookup('Image_Mana')
	if tMemberInfo.bOnline then
		local fCurrentLife, fMaxLife = X.GetCharacterLife(tMemberInfo)
		if fMaxLife > 0 then
			hImageLife:SetPercentage(fCurrentLife / fMaxLife)
		end
		if tMemberInfo.nMaxMana > 0 and tMemberInfo.nMaxMana ~= 1 then
			hImageMana:SetPercentage(tMemberInfo.nCurrentMana / tMemberInfo.nMaxMana)
		end
	else
		hImageLife:SetPercentage(0)
		hImageMana:SetPercentage(0)
	end
	hMember:Show()
	hFrame:BringToTop()
	hFrame:Scale(CFG.fScaleX, CFG.fScaleY)
end

local function CloseRaidDragPanel()
	local hFrame = Station.Lookup('Normal/RaidDragPanel')
	if hFrame then
		hFrame:EndMoving()
		X.UI.CloseFrame(hFrame)
	end
end

local function InsertChangeGroupMenu(tMenu, dwMemberID)
	local hTeam = GetClientTeam()
	local tSubMenu = { szOption = g_tStrings.STR_RAID_MENU_CHANG_GROUP }

	local nCurGroupID = hTeam.GetMemberGroupIndex(dwMemberID)
	for i = 0, hTeam.nGroupNum - 1 do
		if i ~= nCurGroupID then
			local tGroupInfo = hTeam.GetGroupInfo(i)
			if tGroupInfo and tGroupInfo.MemberList then
				local tSubSubMenu =
				{
					szOption = g_tStrings.STR_NUMBER[i + 1],
					bDisable = (#tGroupInfo.MemberList >= CTM_MEMBER_COUNT),
					fnAction = function() GetClientTeam().ChangeMemberGroup(dwMemberID, i, 0) end,
					fnAutoClose = function() return true end,
				}
				table.insert(tSubMenu, tSubSubMenu)
			end
		end
	end
	if #tSubMenu > 0 then
		table.insert(tMenu, tSubMenu)
	end
end

-- 有各个版本之间的文本差异，所以做到翻译中
local CTM_KUNGFU_TEXT = X.CONSTANT.KUNGFU_TYPE_LABEL_ABBR

-- CODE --
local CTM = {}

MY_CataclysmParty_Base = class()

function MY_CataclysmParty_Base.OnFrameCreate()
	this:Lookup('', 'Handle_BG/Shadow_BG'):SetAlpha(CFG.nAlpha)
	this:RegisterEvent('MY_CATACLYSM_SET_VISIBLE')
	this:RegisterEvent('MY_CATACLYSM_SET_FOLD')
	this:RegisterEvent('MY_CATACLYSM_SET_ALPHA')
	this:SetVisible(MY_Cataclysm.bVisible and not MY_Cataclysm.bFold)
end

function MY_CataclysmParty_Base.OnEvent(szEvent)
	if szEvent == 'MY_CATACLYSM_SET_VISIBLE' or szEvent == 'MY_CATACLYSM_SET_FOLD' then
		this:SetVisible(MY_Cataclysm.bVisible and not MY_Cataclysm.bFold)
	elseif szEvent == 'MY_CATACLYSM_SET_ALPHA' then
		this:Lookup('', 'Handle_BG/Shadow_BG'):SetAlpha(CFG.nAlpha)
	end
end

function MY_CataclysmParty_Base.OnLButtonDown()
	CTM:BringToTop()
end

function MY_CataclysmParty_Base.OnRButtonDown()
	CTM:BringToTop()
end

function MY_CataclysmParty_Base.OnItemLButtonDrag()
	local dwID = (this.bBuff and this:GetParent():GetParent().dwID) or (this.bRole and this.dwID)
	if not dwID then
		return
	end
	local team = GetClientTeam()
	local me = X.GetClientPlayer()
	if (IsAltKeyDown() or CFG.bEditMode) and me.IsInRaid() and X.IsClientPlayerTeamLeader() then
		CTM_DRAG = true
		CTM_DRAG_ID = dwID
		CTM_CLICK_DISMISS = true
		CTM:DrawAllParty()
		CTM:AutoLinkAllPanel()
		CTM:BringToTop()
		OpenRaidDragPanel(dwID)
	end
end

-- DragEnd bug fix
function MY_CataclysmParty_Base.OnItemLButtonUp()
	X.DelayCall(50, function()
		if CTM_DRAG then
			CTM_DRAG, CTM_DRAG_ID = false, nil
			CTM:CloseParty()
			CTM:ReloadParty()
			CloseRaidDragPanel()
		end
	end)
end

function MY_CataclysmParty_Base.OnItemLButtonDragEnd()
	local dwID = (this.bBuff and this:GetParent():GetParent().dwID) or (this.bRole and this.dwID)
	if CTM_DRAG and dwID ~= CTM_DRAG_ID then
		local team = GetClientTeam()
		local nGroup = (this.bBuff and this:GetParent():GetParent().nGroup) or this.nGroup
		team.ChangeMemberGroup(CTM_DRAG_ID, nGroup, dwID or 0)
		CTM_DRAG, CTM_DRAG_ID = false, nil
		CloseRaidDragPanel()
		CTM:CloseParty()
		CTM:ReloadParty()
	end
end

function D.SetTargetTeammate(dwID, info)
	if X.IsInPubgMap() and X.GetClientPlayer().nMoveState == MOVE_STATE.ON_DEATH then
		BattleField_MatchPlayer(dwID)
	elseif info.bOnline and CanTarget(dwID) then -- 有待考证
		if CFG.bTempTargetEnable then
			X.DelayCall('MY_Cataclysm_TempTarget', false)
			CTM_TEMP_TARGET_TYPE, CTM_TEMP_TARGET_ID = nil
		end
		SetTarget(TARGET.PLAYER, dwID)
	end
end

function MY_CataclysmParty_Base.OnItemLButtonDown()
	local dwID = (this.bBuff and this:GetParent():GetParent().dwID) or (this.bRole and this.dwID)
	if not dwID then
		return
	end
	local info = CTM:GetMemberInfo(dwID)
	if not info then
		return
	end
	if not IsCtrlKeyDown() and not IsAltKeyDown() then
		D.SetTargetTeammate(dwID, info)
	end
	CTM_CLICK_DISMISS = false
end

function MY_CataclysmParty_Base.OnItemLButtonClick()
	if CTM_CLICK_DISMISS then
		return
	end
	local dwID = (this.bBuff and this:GetParent():GetParent().dwID) or (this.bRole and this.dwID)
	if not dwID then
		return
	end
	local info = CTM:GetMemberInfo(dwID)
	if not info then
		return
	end
	local me = X.GetClientPlayer()
	if not me then
		return
	end
	if IsAltKeyDown() then
		if this.bBuff and CFG.bBuffAltPublish then
			X.SendChat(
				PLAYER_TALK_CHANNEL.RAID,
				_L(
					'[%s] got buff [%s]x%d, remaining %ds.',
					info.szName,
					X.GetBuffName(this.dwID, this.nLevel),
					this.nStackNum or 1,
					MY_GetEndTime(this.nEndFrame)
				)
			)
		elseif this.bRole and CFG.bAltView and (CFG.bAltViewInFight or not me.bFightState) then
			if IsCtrlKeyDown() then
				if MY_CharInfo and MY_CharInfo.ViewCharInfoToPlayer then
					MY_CharInfo.ViewCharInfoToPlayer(dwID)
				end
			else
				X.ViewOtherPlayerByID(dwID)
			end
		else
			D.SetTargetTeammate(dwID, info)
		end
	elseif IsCtrlKeyDown() then
		X.EditBox_AppendLinkPlayer(info.szName)
	end
end

do

local function OnItemRefreshTip()
	local bTip = not CFG.bHideTipInFight or not X.IsFighting()
	if not bTip then
		return
	end
	local Rect
	if not CFG.bShowTipAtRightBottom then
		local nX, nY = this:GetRoot():GetAbsPos()
		local nW, nH = this:GetRoot():GetSize()
		Rect = { nX, nY + 5, nW, nH }
	end
	if this.bBuff then
		X.OutputBuffTip(Rect, this.dwID, this.nLevel, MY_GetEndTime(this.nEndFrame), GetFormatText(this.szVia, 82))
	elseif this.bRole then
		X.OutputTeamMemberTip(Rect, this.dwID)
	end
end
MY_CataclysmParty_Base.OnItemRefreshTip = OnItemRefreshTip

function MY_CataclysmParty_Base.OnItemMouseEnter()
	if CTM_DRAG and this:Lookup('Image_Slot') and this:Lookup('Image_Slot'):IsValid() then
		this:Lookup('Image_Slot'):Show()
	end
	local name = this:GetName()
	local bTip = not CFG.bHideTipInFight or not X.IsFighting()
	if name == 'Handle_Platform' then
		if bTip then
			local nX, nY = this:GetAbsPos()
			local nW, nH = this:GetSize()
			local szTip = GetFormatText(_L['Wujie online'], 101)
			OutputTip(szTip, 400, { nX, nY, nW, nH })
		end
	end
	OnItemRefreshTip()
	local dwID = (this.bBuff and this:GetParent():GetParent().dwID) or (this.bRole and this.dwID)
	local info = dwID ~= CTM_TEMP_TARGET_ID and CTM:GetMemberInfo(dwID) or nil
	if info and info.bOnline and CanTarget(dwID) and CFG.bTempTargetEnable then
		X.DelayCall('MY_Cataclysm_TempTarget', false)
		local function fnAction()
			if not CTM_TEMP_TARGET_TYPE then
				local me = X.GetClientPlayer()
				CTM_TEMP_TARGET_TYPE, CTM_TEMP_TARGET_ID = X.GetCharacterTarget(me)
			end
			SetTarget(TARGET.PLAYER, dwID)
		end
		if CFG.nTempTargetDelay == 0 then
			fnAction()
		else
			X.DelayCall('MY_Cataclysm_TempTarget', CFG.nTempTargetDelay, fnAction)
		end
	end
end
end

do
local function ResumeTempTarget()
	SetTarget(CTM_TEMP_TARGET_TYPE, CTM_TEMP_TARGET_ID)
	CTM_TEMP_TARGET_TYPE, CTM_TEMP_TARGET_ID = nil
end
function MY_CataclysmParty_Base.OnItemMouseLeave(dst)
	if CTM_DRAG and this:Lookup('Image_Slot') and this:Lookup('Image_Slot'):IsValid() then
		this:Lookup('Image_Slot'):Hide()
	end
	HideTip()
	local dwID
	if this.bRole then
		dwID = this.dwID
	elseif this.bBuff then
		dwID = this:GetParent():GetParent().dwID
	end
	if dst then
		local dwDstID
		if dst.bRole then
			dwDstID = dst.dwID
		elseif dst.bBuff then
			dwDstID = dst:GetParent():GetParent().dwID
		end
		if dwDstID == dwID then
			return
		end
	end
	if not dwID then
		return
	end
	if CFG.bTempTargetEnable then
		X.DelayCall('MY_Cataclysm_TempTarget', false)
		if CTM_TEMP_TARGET_TYPE then
			X.DelayCall('MY_Cataclysm_TempTarget', ResumeTempTarget) -- 延迟到下一帧 因为可能当前帧临时选中另外一个玩家 那么不需要切回目标
		end
	end
end
end

function MY_CataclysmParty_Base.OnItemRButtonClick()
	if not this.dwID then
		return
	end
	local dwID = this.dwID
	local menu = {}
	local me = X.GetClientPlayer()
	local info = CTM:GetMemberInfo(dwID)
	local szPath, nFrame = GetForceImage(info.dwForceID)
	table.insert(menu, {
		szOption = info.szName,
		szLayer = 'ICON_RIGHT',
		rgb = { X.GetForceColor(info.dwForceID, 'foreground') },
		szIcon = szPath,
		nFrame = nFrame
	})
	if X.IsClientPlayerTeamLeader() and me.IsInRaid() then
		table.insert(menu, { bDevide = true })
		InsertChangeGroupMenu(menu, dwID)
	end
	local info = CTM:GetMemberInfo(dwID)
	if dwID ~= me.dwID then
		if X.IsClientPlayerTeamLeader() then
			table.insert(menu, { bDevide = true })
		end
		InsertTeammateMenu(menu, dwID)
		local t = {}
		InsertTargetMenu(t, dwID)
		for _, v in ipairs(t) do
			if v.szOption == g_tStrings.LOOKUP_INFO or v.szOption == g_tStrings.STR_LOOKUP_MORE then
				for _, vv in ipairs(v) do
					if vv.szOption == g_tStrings.LOOKUP_NEW_TANLENT then -- 奇穴
						table.insert(menu, vv)
						break
					end
				end
			end
			if v.szOption == g_tStrings.STR_MAKE_TRADDING then -- 交易
				table.insert(menu, v)
			end
		end
		table.insert(menu, { szOption = g_tStrings.STR_LOOKUP, bDisable = not info.bOnline, fnAction = function()
			X.ViewOtherPlayerByID(dwID)
		end })
		if MY_CharInfo and MY_CharInfo.ViewCharInfoToPlayer then
			table.insert(menu, {
				szOption = g_tStrings.STR_LOOK .. g_tStrings.STR_EQUIP_ATTR, bDisable = not info.bOnline, fnAction = function()
					MY_CharInfo.ViewCharInfoToPlayer(dwID)
				end
			})
		end
		local extra = {}
		if MY_Focus then
			for _, v in ipairs(MY_Focus.GetTargetMenu(TARGET.PLAYER, dwID)) do
				table.insert(extra, v)
			end
		end
		if #extra > 0 then
			table.insert(menu, X.CONSTANT.MENU_DIVIDER)
			for _, v in ipairs(extra) do
				table.insert(menu, v)
			end
		end
	else
		table.insert(menu, { bDevide = true })
		InsertPlayerMenu(menu, dwID)
		if X.IsClientPlayerTeamLeader() then
			table.insert(menu, { bDevide = true })
			table.insert(menu, {
				szOption = _L['Take back all permissions'],
				rgb = { 255, 255, 0 },
				fnAction = function()
					local team = GetClientTeam()
					team.SetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK, X.GetClientPlayerID())
					team.SetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE, X.GetClientPlayerID())
				end,
			})
		elseif not X.IsRestricted('MY_Cataclysm.Seize') then
			table.insert(menu, { bDevide = true })
			table.insert(menu, {
				szOption = _L['Take back permissions'],
				rgb = { 255, 255, 0 },
				{
					szOption = _L['Take back all permissions'],
					rgb = { 255, 255, 0 },
					fnAction = function()
						if X.IsSafeLocked(SAFE_LOCK_EFFECT_TYPE.TALK) then
							return X.Alert('TALK_LOCK', _L['Please unlock talk lock first.'])
						end
						X.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_ABOUT', {'TeamAuth'})
					end,
				},
				{
					szOption = _L['Take back leader permission'],
					rgb = { 255, 255, 0 },
					fnAction = function()
						if X.IsSafeLocked(SAFE_LOCK_EFFECT_TYPE.TALK) then
							return X.Alert('TALK_LOCK', _L['Please unlock talk lock first.'])
						end
						X.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_ABOUT', {'TeamLeader'})
					end,
				},
				{
					szOption = _L['Take back mark permission'],
					rgb = { 255, 255, 0 },
					fnAction = function()
						if X.IsSafeLocked(SAFE_LOCK_EFFECT_TYPE.TALK) then
							return X.Alert('TALK_LOCK', _L['Please unlock talk lock first.'])
						end
						X.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_ABOUT', {'TeamMark'})
					end,
				},
				{
					szOption = _L['Take back distribute permission'],
					rgb = { 255, 255, 0 },
					fnAction = function()
						if X.IsSafeLocked(SAFE_LOCK_EFFECT_TYPE.TALK) then
							return X.Alert('TALK_LOCK', _L['Please unlock talk lock first.'])
						end
						X.SendBgMsg(PLAYER_TALK_CHANNEL.RAID, 'MY_ABOUT', {'TeamDistribute'})
					end,
				}
			})
		end
	end
	if #menu > 0 then
		PopupMenu(menu)
	end
end

function CTM:GetPartyFrame(nIndex) -- 获得组队面板
	return Station.Lookup('Normal/MY_CataclysmParty_' .. nIndex)
end

function CTM:BringToTop()
	MY_CataclysmMain.GetFrame():BringToTop()
	for i = 0, CTM_GROUP_COUNT do
		if self:GetPartyFrame(i) then
			self:GetPartyFrame(i):BringToTop()
		end
	end
end

function CTM:GetMemberHandle(nGroup, nIndex)
	local frame = self:GetPartyFrame(nGroup)
	if frame then
		return frame:Lookup('', 'Handle_Cols/Handle_Roles'):Lookup(nIndex)
	end
end

-- 创建面板
function CTM:CreatePanel(nIndex)
	local me = X.GetClientPlayer()
	local frame = self:GetPartyFrame(nIndex)
	if not frame then
		frame = X.UI.OpenFrame(
			X.PACKET_INFO.ROOT .. 'MY_Cataclysm/ui/MY_CataclysmParty.' .. CFG.eFrameStyle .. '.ini',
			'MY_CataclysmParty_' .. nIndex
		)
		frame:Scale(CFG.fScaleX, CFG.fScaleY)
		frame:SetVisible(MY_Cataclysm.bVisible and not MY_Cataclysm.bFold)
	end
	self:AutoLinkAllPanel()
	self:RefreshGroupText()
end

-- 刷新团队组编号
function CTM:RefreshGroupText()
	local team = GetClientTeam()
	local me = X.GetClientPlayer()
	for i = 0, team.nGroupNum - 1 do
		local frame = self:GetPartyFrame(i)
		if frame then
			local txtGroup, szGroup = frame:Lookup('', 'Handle_Cols/Handle_Title/Text_Title')
			if me.IsInRaid() then
				if CFG.eFrameStyle == 'CATACLYSM' then
					txtGroup:SetFontScheme(7)
				end
				local tGroup = team.GetGroupInfo(i)
				if tGroup and tGroup.MemberList then
					for k, v in ipairs(tGroup.MemberList) do
						if v == X.GetClientPlayerID() then
							-- txtGroup:SetFontScheme(2)
							txtGroup:SetFontColor(255, 128, 0) -- 自己所在的小队 黄色
							break
						end
					end
				end
				szGroup = CFG.eFrameStyle == 'CATACLYSM' and g_tStrings.STR_NUMBER[i + 1] or tostring(i + 1)
			else
				szGroup = g_tStrings.STR_TEAM
			end
			txtGroup:SetText(szGroup)
		end
	end
end
 -- 连接所有面板
function CTM:AutoLinkAllPanel()
	local frameMain = MY_CataclysmMain.GetFrame()
	local nX, nY = frameMain:GetRelPos()
	nY = nY + 24
	local nShownCount = 0
	local tPosnSize = {}
	-- { nX = nX, nY = nY, nW = 0, nH = 0 }
	for i = 0, CTM_GROUP_COUNT do
		local hPartyPanel = self:GetPartyFrame(i)
		if hPartyPanel then
			local nW, nH = hPartyPanel:GetSize()

			if nShownCount < CFG.nAutoLinkMode then
				tPosnSize[nShownCount] = { nX = nX + (128 * CFG.fScaleX * nShownCount), nY = nY, nW = nW, nH = nH }
			else
				local nUpperIndex = math.min(nShownCount - CFG.nAutoLinkMode, CFG.nAutoLinkMode - 1)
				local tPS = tPosnSize[nUpperIndex] or {nH = 235 * CFG.fScaleY}
				tPosnSize[nShownCount] = {
					nX = nX + (128 * CFG.fScaleX * (nShownCount - CFG.nAutoLinkMode)),
					nY = nY + tPosnSize[nUpperIndex].nH,
					nW = nW,
					nH = nH
				}
			end
			local _nX, _nY = hPartyPanel:GetRelPos()
			if _nX ~= tPosnSize[nShownCount].nX or _nY ~= tPosnSize[nShownCount].nY then
				hPartyPanel:SetRelPos(tPosnSize[nShownCount].nX, tPosnSize[nShownCount].nY)
			end
			nShownCount = nShownCount + 1
		end
	end
end

function CTM:GetMemberInfo(dwID)
	local team = GetClientTeam()
	if not team then
		return
	end
	return X.GetTeamMemberInfo(dwID)
end

function CTM:GetTeamInfo()
	local team = GetClientTeam()
	return {
		[TEAM_AUTHORITY_TYPE.LEADER]     = team.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER),
		[TEAM_AUTHORITY_TYPE.MARK]       = team.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK),
		[TEAM_AUTHORITY_TYPE.DISTRIBUTE] = team.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE),
	}
end

local function HideTarget()
	if CTM_TARGET
	and CTM_CACHE[CTM_TARGET]
	and CTM_CACHE[CTM_TARGET]:IsValid()
	and CTM_CACHE[CTM_TARGET]:Lookup('Image_Selected')
	and CTM_CACHE[CTM_TARGET]:Lookup('Image_Selected'):IsValid() then
		CTM_CACHE[CTM_TARGET]:Lookup('Image_Selected'):Hide()
	end
end

function CTM:RefreshTarget(dwOldID, nOldType, dwNewID, nNewType)
	if nOldType == TARGET.NPC and CHANGGE_REAL_SHADOW_CACHE[dwOldID] then
		nOldType, dwOldID = TARGET.PLAYER, CHANGGE_REAL_SHADOW_CACHE[dwOldID]
	end
	if nNewType == TARGET.NPC and CHANGGE_REAL_SHADOW_CACHE[dwNewID] then
		nNewType, dwNewID = TARGET.PLAYER, CHANGGE_REAL_SHADOW_CACHE[dwNewID]
	end
	if dwOldID == CTM_TARGET then
		HideTarget()
	end
	if nNewType == TARGET.PLAYER
	and CTM_CACHE[dwNewID]
	and CTM_CACHE[dwNewID]:IsValid()
	and CTM_CACHE[dwNewID]:Lookup('Image_Selected')
	and CTM_CACHE[dwNewID]:Lookup('Image_Selected'):IsValid() then
		CTM_CACHE[dwNewID]:Lookup('Image_Selected'):Show()
	end
	CTM_TARGET = dwNewID
end

do
local function HideTTarget()
	if CTM_TTARGET
	and CTM_CACHE[CTM_TTARGET]
	and CTM_CACHE[CTM_TTARGET]:IsValid()
	and CTM_CACHE[CTM_TTARGET]:Lookup('Handle_TargetTarget')
	and CTM_CACHE[CTM_TTARGET]:Lookup('Handle_TargetTarget'):IsValid() then
		CTM_CACHE[CTM_TTARGET]:Lookup('Handle_TargetTarget'):Hide()
	end
end
function CTM:RefreshTTarget()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and GetLogicFrameCount() % 16 ~= 0 then
		return
	end
	if CFG.bShowTargetTargetAni then
		local dwType, dwID = Target_GetTargetData()
		if dwID then
			local KObject = X.GetTargetHandle(dwType, dwID)
			if KObject then
				local dwTarType, dwTarID = KObject.GetTarget()
				if dwTarType == TARGET.NPC and CHANGGE_REAL_SHADOW_CACHE[dwTarID] then
					dwTarType, dwTarID = TARGET.PLAYER, CHANGGE_REAL_SHADOW_CACHE[dwTarID]
				end
				if dwTarID ~= CTM_TTARGET then
					HideTTarget()
				end
				if dwTarID and dwTarID ~= 0 and dwTarType == TARGET.PLAYER
				and CTM_CACHE[dwTarID]
				and CTM_CACHE[dwTarID]:IsValid()
				and CTM_CACHE[dwTarID]:Lookup('Handle_TargetTarget')
				and CTM_CACHE[dwTarID]:Lookup('Handle_TargetTarget'):IsValid() then
					CTM_CACHE[dwTarID]:Lookup('Handle_TargetTarget'):Show()
				end
				CTM_TTARGET = dwTarID
				return
			end
		end
	end
	HideTTarget()
end
end

do
local function HideBossTarget(dwTarID)
	if CTM_CACHE[dwTarID]
	and CTM_CACHE[dwTarID]:IsValid()
	and CTM_CACHE[dwTarID]:Lookup('Image_Threat')
	and CTM_CACHE[dwTarID]:Lookup('Image_Threat'):IsValid() then
		CTM_CACHE[dwTarID]:Lookup('Image_Threat'):Hide()
	end
end
function CTM:RefreshBossTarget()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and GetLogicFrameCount() % 16 ~= 0 then
		return
	end
	local tKeep = {}
	if CFG.bShowBossTarget then
		for dwNpcID, npc in pairs(CTM_BOSS_CACHE) do
			local dwTarID = (X.IsCharacterRelationEnemy(X.GetClientPlayerID(), dwNpcID) and npc.bFightState)
				and (CTM_NPC_THREAT_TARGET[dwNpcID] or select(2, npc.GetTarget()))
				or nil
			if dwTarID then
				if dwTarID ~= CTM_BOSS_TARGET[dwNpcID] then
					HideBossTarget(CTM_BOSS_TARGET[dwNpcID])
					if CTM_CACHE[dwTarID]
					and CTM_CACHE[dwTarID]:IsValid()
					and CTM_CACHE[dwTarID]:Lookup('Image_Threat')
					and CTM_CACHE[dwTarID]:Lookup('Image_Threat'):IsValid() then
						CTM_CACHE[dwTarID]:Lookup('Image_Threat'):Show()
					end
					CTM_BOSS_TARGET[dwNpcID] = dwTarID
				end
				tKeep[dwTarID] = true
			end
		end
	end
	for dwNpcID, dwTarID in pairs(CTM_BOSS_TARGET) do
		if not tKeep[dwTarID] then
			HideBossTarget(dwTarID)
			CTM_BOSS_TARGET[dwNpcID] = nil
		end
	end
end
end

function CTM:RefreshThreat(dwNpcID, tList)
	local dwTarID, nMaxThreat = 0, -1
	for dwID, nThreat in pairs(tList) do
		if nThreat > nMaxThreat then
			dwTarID, nMaxThreat = dwID, nThreat
		end
	end
	CTM_NPC_THREAT_TARGET[dwNpcID] = dwTarID
	self:RefreshBossTarget()
end

function CTM:RefreshAttention()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and GetLogicFrameCount() % 16 ~= 0 then
		return
	end
	if CFG.bShowAttention then
		local team, me = GetClientTeam(), X.GetClientPlayer()
		local tKeep = {}
		for _, dwTarID in ipairs(team.GetTeamMemberList()) do
			local p = X.GetPlayer(dwTarID)
			if CTM_CACHE[dwTarID] and CTM_CACHE[dwTarID]:IsValid() then
				if p and not X.IsEmpty(CTM_ATTENTION_STACK[dwTarID]) then
					local data = CTM_ATTENTION_STACK[dwTarID][1]
					local r, g, b = X.HumanColor2RGB(data.colAttention or data.col)
					CTM_CACHE[dwTarID]:Lookup('Shadow_Attention'):SetColorRGB(r, g, b)
					CTM_CACHE[dwTarID]:Lookup('Shadow_Attention'):Show()
				else
					CTM_CACHE[dwTarID]:Lookup('Shadow_Attention'):Hide()
				end
			end
			tKeep[dwTarID] = p and true or false
		end
		for dwTarID, _ in pairs(CTM_ATTENTION_BUFF) do
			if not tKeep[dwTarID] then
				CTM_ATTENTION_BUFF[dwTarID] = nil
				CTM_ATTENTION_STACK[dwTarID] = nil
			end
		end
	else
		for dwTarID, _ in pairs(CTM_ATTENTION_BUFF) do
			if CTM_CACHE[dwTarID] and CTM_CACHE[dwTarID]:IsValid() then
				CTM_CACHE[dwTarID]:Lookup('Shadow_Attention'):Hide()
			end
		end
	end
	-- Output(CTM_ATTENTION_BUFF, CTM_ATTENTION_STACK)
end

function CTM:RefreshCaution()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and GetLogicFrameCount() % 16 ~= 0 then
		return
	end
	if CFG.bShowCaution or CFG.bShowBossFocus then
		local team, me = GetClientTeam(), X.GetClientPlayer()
		local tKeep = {}
		for _, dwTarID in ipairs(team.GetTeamMemberList()) do
			local p = X.GetPlayer(dwTarID)
			if CTM_CACHE[dwTarID] and CTM_CACHE[dwTarID]:IsValid() then
				CTM_CACHE[dwTarID]:Lookup('Handle_Caution'):SetVisible(
					p and (
						(CFG.bShowCaution and not X.IsEmpty(CTM_CAUTION_BUFF[dwTarID]))
						or (CFG.bShowBossFocus and CTM_BOSS_FOCUSED_STATE[dwTarID])
					)
				)
			end
			tKeep[dwTarID] = p and true or false
		end
		if CFG.bShowCaution then
			for dwTarID, _ in pairs(CTM_CAUTION_BUFF) do
				if not tKeep[dwTarID] then
					CTM_CAUTION_BUFF[dwTarID] = nil
				end
			end
		end
		if CFG.bShowBossFocus then
			for dwTarID, _ in pairs(CTM_BOSS_FOCUSED_STATE) do
				if not tKeep[dwTarID] then
					CTM_BOSS_FOCUSED_STATE[dwTarID] = nil
				end
			end
		end
	else
		for dwTarID, _ in pairs(CTM_CAUTION_BUFF) do
			if CTM_CACHE[dwTarID] and CTM_CACHE[dwTarID]:IsValid() then
				CTM_CACHE[dwTarID]:Lookup('Handle_Caution'):Hide()
			end
		end
		for dwTarID, _ in pairs(CTM_BOSS_FOCUSED_STATE) do
			if CTM_CACHE[dwTarID] and CTM_CACHE[dwTarID]:IsValid() then
				CTM_CACHE[dwTarID]:Lookup('Handle_Caution'):Hide()
			end
		end
	end
	-- Output(CTM_CAUTION_BUFF, CTM_BOSS_FOCUSED_STATE)
end

function CTM:RefreshMark()
	local team = GetClientTeam()
	local tPartyMark = team.GetTeamMark()
	if not tPartyMark then return end
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() then
			if tPartyMark[k] then
				local nMarkID, nIconFrame = tPartyMark[k], 0
				if nMarkID and PARTY_MARK_ICON_FRAME_LIST[nMarkID] then
					-- assert(nMarkID > 0 and nMarkID <= #PARTY_MARK_ICON_FRAME_LIST)
					nIconFrame = PARTY_MARK_ICON_FRAME_LIST[nMarkID]
				end
				v:Lookup('Image_MarkImage'):FromUITex(PARTY_MARK_ICON_PATH, nIconFrame)
				v:Lookup('Image_MarkImage'):Show()
				local fScale = (CFG.fScaleY + CFG.fScaleX) / 2
				v:Lookup('Image_MarkImage'):SetSize(24 * fScale, 24 * fScale)
			else
				v:Lookup('Image_MarkImage'):Hide()
			end
		end
	end
end

-- 由于SFX的缩放独立于UI缩放 所以需要单独计算
-- 我们准备三个Handle 一个允许缩放 一个禁止缩放 SFX初始为1倍缩放 结构为 允许缩放Handle/禁止缩放Handle/SFX
--    允许缩放的那个Handle初始大小是你想要得到的最终显示大小 初始位置亦为你想要显示的最终位置
--    禁止缩放的那个Handle初始大小应该等于SFX模型缩放比为1时在屏幕上的矩形区域大小 初始位置为刚好覆盖SFX
--    SFX初始中心应当为最终想要的中心点
-- 计算方法是 每次计算允许缩放的Handle与禁止缩放的Handle的比例差即可得知SFX当前理应当缩放和平移数值
function CTM:RefreshSFX()
	local hDest--[[, hScale]], hFixed
	local fSfxX, fSfxY -- SFX当前状态下对比初始时正确的缩放比
	-- local fUIX, fUIY -- UI当前状态下对应1.0的缩放比
	local fUIScale = Station.GetUIScale()
	for dwID, h in pairs(CTM_CACHE) do
		if h:IsValid() then
			for _, szID in ipairs({ 'TargetTarget', 'Caution' }) do
				hDest = h:Lookup('Handle_' .. szID)
				-- hScale = hDest:Lookup('Handle_' .. szID .. '_Scale')
				hFixed = hDest:Lookup('Handle_' .. szID .. '_Fixed')
				-- fUIX, fUIY = hScale:GetW() / hFixed:GetW(), hScale:GetH() / hFixed:GetH()
				fSfxX, fSfxY = hDest:GetW() / hFixed:GetW(), hDest:GetH() / hFixed:GetH()
				hDest:Lookup('SFX_' .. szID):SetModelScale(fSfxX / fUIScale, fSfxY / fUIScale, fSfxX / fUIScale)
			end
		end
	end
end

function CTM:RefreshGVoice()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE then
		return
	end
	local team = GetClientTeam()
	local sayingInfo = X.GVoiceBase_GetSaying()
	local bInRoom = X.GVoiceBase_GetMicState() ~= X.CONSTANT.MIC_STATE.CLOSE_NOT_IN_ROOM
	for dwID, h in pairs(CTM_CACHE) do
		if h:IsValid() then
			local fScale = math.min(CFG.fScaleY, CFG.fScaleX)
			local hSpeaker = h:Lookup('Handle_Speaker')
			if bInRoom and GVoiceBase_IsMemberForbid(dwID) then
				hSpeaker:Show()
				hSpeaker:SetRelX(h:GetW() - hSpeaker:GetW())
				hSpeaker:SetAbsX(h:GetAbsX() + h:GetW() - 30 * fScale)
				hSpeaker:Lookup('Shadow_SpeakerBg'):SetSize(30 * fScale, 22 * fScale)
				hSpeaker:Lookup('Handle_ForbidSpeaker'):Show()
				hSpeaker:Lookup('Animate_SpeakerEffect'):Hide()
				hSpeaker:Lookup('Handle_ForbidSpeaker/Image_Speaker'):SetSize(11 * fScale, 16 * fScale)
				hSpeaker:Lookup('Handle_ForbidSpeaker/Image_ForbidSpeaker'):SetSize(16 * fScale, 16 * fScale)
			elseif bInRoom and GVoiceBase_IsMemberSaying(dwID, sayingInfo) then
				hSpeaker:Show()
				hSpeaker:SetRelX(h:GetW() - hSpeaker:GetW())
				hSpeaker:SetAbsX(h:GetAbsX() + h:GetW() - 30 * fScale)
				hSpeaker:Lookup('Shadow_SpeakerBg'):SetSize(30 * fScale, 22 * fScale)
				hSpeaker:Lookup('Handle_ForbidSpeaker'):Hide()
				hSpeaker:Lookup('Animate_SpeakerEffect'):Show()
				hSpeaker:Lookup('Animate_SpeakerEffect'):SetSize(32 * fScale, 24 * fScale)
			else
				hSpeaker:Hide()
			end
		end
	end
end

function CTM:CallRefreshImages(dwID, ...)
	if type(dwID) == 'number' then
		local info = self:GetMemberInfo(dwID)
		local handle = CTM_CACHE[dwID]
		if info and handle and handle:IsValid() then
			self:RefreshImages(handle, dwID, info, ...)
		end
	else
		for k, v in pairs(CTM_CACHE) do
			if v:IsValid() then
				local info = self:GetMemberInfo(k)
				self:RefreshImages(v, k, info, ...)
			end
		end
	end
end

function CTM:RefreshLive(h, dwID, info)
	if not info then
		return
	end
	local hImageLive = h:Lookup('Image_Live')
	local hImageBroadcast = h:Lookup('Image_Broadcast')
	if hImageLive and hImageBroadcast then
		local bStreamer = OBDungeon_IsPlayerStreamer(info.szGlobalID) or false
		local bVoiceBroadcast = OBDungeon_IsPlayerVoiceBroadcast(dwID) or false
		hImageLive:SetVisible(bStreamer and not bVoiceBroadcast)
		hImageBroadcast:SetVisible(bStreamer and bVoiceBroadcast)
	end
end

function CTM:RefreshLiveByMemberID(dwID)
	local h = CTM_CACHE[dwID]
	if h and h:IsValid() then
		self:RefreshLive(h, dwID, self:GetMemberInfo(dwID))
	end
end

function CTM:RefreshLiveAll()
	for dwID, h in pairs(CTM_CACHE) do
		if h:IsValid() then
			self:RefreshLive(h, dwID, self:GetMemberInfo(dwID))
		end
	end
end

function CTM:KungFuSwitch(dwID)
	local handle = CTM_CACHE[dwID]
	if handle and handle:IsValid() then
		if X.GetPlayer(dwID) then
			local key = 'MY_CATACLYSM_KUNGFU_' .. dwID
			local img = handle:Lookup('Image_Icon')
			X.BreatheCall(key, function()
				local player = X.GetPlayer(dwID)
				if player and img and img:IsValid() then
					local nType, dwSkillID, dwSkillLevel, fCastPercent = X.GetCharacterOTActionState(player)
					if (nType == X.CONSTANT.CHARACTER_OTACTION_TYPE.ACTION_SKILL_PREPARE
					or nType == X.CONSTANT.CHARACTER_OTACTION_TYPE.ANCIENT_ACTION_PREPARE) and fCastPercent then
						local alpha = 255 * (math.abs((fCastPercent * 300) % 32 - 7) + 4) / 12
						if alpha <= 255 then
							img:SetAlpha(alpha)
						end
						return
					else
						img:SetAlpha(255)
					end
				end
				X.BreatheCall(key, false)
			end)
		end
	end
end

-- 刷新图标和名字之类的信息
function CTM:RefreshImages(h, dwID, info, tSetting, bIcon, bFormationLeader, bLayout)
	-- assert(info)
	if not info then return end
	-- 刷新团队权限标记
	if type(tSetting) ~= 'nil' then
		local fnAction = function(t)
			local hTotal = {
				[TEAM_AUTHORITY_TYPE.LEADER]     = h:Lookup('Handle_Icons/Image_Leader'),
				[TEAM_AUTHORITY_TYPE.MARK]       = h:Lookup('Handle_Icons/Image_Marker'),
				[TEAM_AUTHORITY_TYPE.DISTRIBUTE] = h:Lookup('Handle_Icons/Image_Looter'),
			}
			for k, v in pairs(hTotal) do
				if t[k] == dwID then
					v:Show()
					local fScale = (CFG.fScaleY + CFG.fScaleX) / 2
					v:SetSize(14 * fScale, 14 * fScale)
				else
					v:Hide()
				end
			end
		end

		if type(tSetting) == 'table' then -- 根据表的内容刷新标记队长等信息
			fnAction(tSetting)
		elseif type(tSetting) == 'boolean' and tSetting then
			fnAction(self:GetTeamInfo())
		end
	end
	-- 刷新阵眼
	if type(bFormationLeader) == 'boolean' then
		if bFormationLeader then
			local fScale = (CFG.fScaleY + CFG.fScaleX) / 2
			h:Lookup('Handle_Icons/Image_Matrix'):SetSize(14 * fScale, 14 * fScale)
			h:Lookup('Handle_Icons/Image_Matrix'):Show()
		else
			h:Lookup('Handle_Icons/Image_Matrix'):Hide()
		end
	end
	-- 刷新内功
	if bIcon then -- 刷新icon
		local img, bVisible = h:Lookup('Image_Icon'), true
		if CFG.nShowIcon ~= 4 then
			if CFG.nShowIcon == 2 and info.dwActualKungfuID == 0 then
				img:FromUITex('ui/image/TargetPanel/Target.UITex', 21)
			elseif CFG.nShowIcon == 2 then
				local _, nIconID = X.GetSkillName(info.dwActualKungfuID, 1)
				if nIconID == 1435 then nIconID = 889 end
				img:FromIconID(nIconID)
			elseif CFG.nShowIcon == 1 then
				img:FromUITex(GetForceImage(info.dwForceID))
			elseif CFG.nShowIcon == 3 then
				local szCampImg, nCampFrame = X.GetCampImage(info.nCamp, false)
				if szCampImg then
					img:FromUITex(szCampImg, nCampFrame)
				else
					bVisible = false
				end
			end
			local fScale = (CFG.fScaleY + CFG.fScaleX) / 2
			if fScale * 0.9 > 1 then
				fScale = fScale * 0.9
			end
			img:SetSize(28 * fScale, 28 * fScale)
		else -- 不再由icon控制 转交给textname
			bVisible = false
		end
		img:SetVisible(bVisible)
		bLayout = true
	end
	-- 刷新平台
	h:Lookup('Handle_Platform'):SetVisible(X.IsMobileClient(info.nClientVersionType))
	-- 刷新名字
	if bLayout then
		local txtName = h:Lookup('Text_Name')
		local txtLife = h:Lookup('Text_Life')
		local txtDeath = h:Lookup('Text_Death')
		local txtOffLine = h:Lookup('Text_OffLine')
		local txtSchool = h:Lookup('Text_School_Name')
		local r, g, b = 255, 255, 255
		if CFG.nColoredName == 1 then
			r, g, b = X.GetForceColor(info.dwForceID, 'foreground')
		elseif CFG.nColoredName == 0 then
			r, b, b = 255, 255, 255
		elseif CFG.nColoredName == 2 then
			r, g, b = X.GetCampColor(info.nCamp, 'foreground')
		end
		local szName = X.ExtractPlayerOriginName(info.szName)
		if MY_ChatMosaics and MY_ChatMosaics.MosaicsString then
			szName = MY_ChatMosaics.MosaicsString(szName)
		end
		txtName:SetText(szName)
		txtName:SetVAlign(CFG.nNameVAlignment)
		txtName:SetHAlign(CFG.nNameHAlignment)
		txtName:SetFontScheme(CFG.nNameFont)
		txtName:SetFontColor(r, g, b)
		txtName:SetFontScale(CFG.fNameFontScale)
		txtLife:SetVAlign(CFG.nHPVAlignment)
		txtLife:SetHAlign(CFG.nHPHAlignment)
		txtDeath:SetVAlign(CFG.nHPVAlignment)
		txtDeath:SetHAlign(CFG.nHPHAlignment)
		txtOffLine:SetVAlign(CFG.nHPVAlignment)
		txtOffLine:SetHAlign(CFG.nHPHAlignment)
		local fScale, nRelX = (CFG.fScaleY + CFG.fScaleX) / 2
		if fScale * 0.9 > 1 then
			fScale = fScale * 0.9
		end
		if CFG.nShowIcon == 4 then
			local r, g, b = X.GetForceColor(info.dwForceID, 'foreground')
			txtSchool:SetText(CTM_KUNGFU_TEXT[info.dwActualKungfuID])
			txtSchool:SetFontScheme(CFG.nNameFont)
			txtSchool:SetFontColor(r, g, b)
			txtSchool:SetFontScale(fScale)
			txtSchool:AutoSize()
			txtSchool:Show()
			nRelX = txtSchool:GetRelX() + txtSchool:GetW() + 5
		else
			local img = h:Lookup('Image_Icon')
			txtSchool:Hide()
			nRelX = img:GetRelX() + img:GetW()
		end
		-- 刷新名字血量位置
		local nMargin = CFG.eFrameStyle == 'OFFICIAL' and 7 or 5
		for _, szItemName in ipairs({'Text_Name', 'Text_Life', 'Text_Death', 'Text_OffLine'}) do
			local txt = h:Lookup(szItemName)
			local nVAlign = txt:GetVAlign()
			local nHAlign = txt:GetHAlign()
			if nVAlign == ALIGNMENT.TOP
			and (nHAlign == ALIGNMENT.LEFT or nHAlign == ALIGNMENT.RIGHT) then
				txt:SetRelX(nRelX)
				txt:SetAbsX(h:GetAbsX() + nRelX)
				txt:SetW(h:GetW() - nRelX - nMargin)
			else
				txt:SetRelX(nMargin)
				txt:SetAbsX(h:GetAbsX() + nMargin)
				txt:SetW(h:GetW() - nMargin * 2)
			end
		end
		-- 刷新BUFF位置
		if CFG.bBuffAboveMana then
			local hMana = h:Lookup('Handle_Mana')
			local hBoxes = h:Lookup('Handle_Buff_Boxes')
			hBoxes:SetRelPos(hMana:GetRelX() - 1, hMana:GetRelY() - hBoxes:GetH() + hMana:GetH() / 2)
			hBoxes:SetAbsPos(hMana:GetAbsX() - 1, hMana:GetAbsY() - hBoxes:GetH() + hMana:GetH() / 2)
		end
		--刷新直播
		self:RefreshLive(h, dwID, info)
	end
end

function CTM:DrawAllParty()
	for i = 0, CTM_GROUP_COUNT do
		if not self:GetPartyFrame(i) then
			self:CreatePanel(i)
			self:DrawParty(i)
		else
			self:FormatFrame(self:GetPartyFrame(i), CTM_MEMBER_COUNT)
		end
	end
end

function CTM:CloseParty(nIndex)
	if nIndex then
		if self:GetPartyFrame(nIndex) then
			X.UI.CloseFrame(self:GetPartyFrame(nIndex))
		end
	else
		for i = 0, CTM_GROUP_COUNT do
			if self:GetPartyFrame(i) then
				X.UI.CloseFrame(self:GetPartyFrame(i))
			end
		end
	end
end

function CTM:ReloadParty()
	local team = GetClientTeam()
	for i = 0, team.nGroupNum - 1 do
		local tGroup = team.GetGroupInfo(i)
		if tGroup then
			if #tGroup.MemberList == 0 then
				self:CloseParty(i)
			else
				self:CreatePanel(i)
				self:DrawParty(i)
			end
		end
	end
	self:AutoLinkAllPanel()
	self:RefreshMark()
	self:RefreshDistance()
	self:RefreshFormation()
	self:RefreshPlayerSkillCD()
	CTM_LIFE_CACHE = {}
end

-- 哎 事件太蛋疼 就这样吧
function CTM:RefreshFormation()
	local team = GetClientTeam()
	for i = 0, team.nGroupNum - 1 do
		local tGroup = team.GetGroupInfo(i)
		if tGroup and tGroup.dwFormationLeader and #tGroup.MemberList > 0 then
			local dwFormationLeader = tGroup.dwFormationLeader
			for k, v in ipairs(tGroup.MemberList) do
				local info = self:GetMemberInfo(v)
				if CTM_CACHE[v] and CTM_CACHE[v]:IsValid() then
					self:RefreshImages(CTM_CACHE[v], v, info, false, false, dwFormationLeader == v)
				end
			end
		end
	end
end

-- 绘制面板
function CTM:DrawParty(nIndex)
	local team = GetClientTeam()
	local tGroup = team.GetGroupInfo(nIndex)
	local frame = self:GetPartyFrame(nIndex)
	local handle = frame:Lookup('', 'Handle_Cols/Handle_Roles')
	local tSetting = self:GetTeamInfo()
	local hMember = MY_CataclysmMain.GetFrame().hMember
	handle:Clear()
	for i = 1, CTM_MEMBER_COUNT do
		local dwID = tGroup.MemberList[i]
		local h = handle:AppendItemFromData(hMember, i)
		if dwID then
			h.bRole = true
			h.dwID = dwID
			CTM_CACHE[dwID] = h
			local info = self:GetMemberInfo(dwID)
			h:Lookup('Image_MemberBg'):Show()
			self:RefreshImages(h, dwID, info, tSetting, true, dwID == tGroup.dwFormationLeader, true)
		end
		h.nGroup = nIndex
		self:Scale(CFG.fScaleX, CFG.fScaleY, h)
	end
	handle:FormatAllItemPos()
	frame.nMemberCount = #tGroup.MemberList
	-- 先缩放后画
	self:FormatFrame(frame, #tGroup.MemberList)
	self:RefreshDistance() -- 立即刷新一次
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() and v.nGroup == nIndex then
			self:CallDrawHPMP(k, true)
		end
	end
	CTM_LIFE_CACHE = {}
	-- 刷新
	CTM_TARGET = nil
	CTM_TTARGET = nil
	local dwType, dwID = Target_GetTargetData()
	self:RefreshTarget(dwID, dwType, dwID, dwType)
	self:RefreshTTarget()
	self:RefreshPlayerSkillCD()
end

function CTM:Scale(fX, fY, frame)
	if frame then
		frame:Scale(fX, fY)
	else
		for i = 0, CTM_GROUP_COUNT do
			if self:GetPartyFrame(i) then
				self:GetPartyFrame(i):Scale(fX, fY)
				self:FormatFrame(self:GetPartyFrame(i))
			end
		end
	end
	self:AutoLinkAllPanel()
	self:CallRefreshImages(true, true, true, nil, true) -- 缩放其他图标
	self:RefreshSFX() -- 缩放特效
	self:RefreshFormation() -- 缩放阵眼
	self:RefreshMark() -- 缩放标记
	self:RefreshGVoice() -- 缩放语音
end

function CTM:FormatFrame(frame, nMemberCount)
	local fX, fY = CFG.fScaleX, CFG.fScaleY
	local height, nGroupHeight = (CFG.fScaleY - 1) * 18, 0
	local h = frame:Lookup('', '')
	local nRolesH = 0
	if CTM_DRAG or CFG.bShowAllGrid then
		nMemberCount = CTM_MEMBER_COUNT
		local handle = h:Lookup('Handle_Cols/Handle_Roles')
		for i = 0, handle:GetItemCount() - 1 do
			local h = handle:Lookup(i)
			if not h.dwID then
				if CTM_DRAG then
					h:Lookup('Image_SlotBg'):Show()
				end
				h:Lookup('Image_MemberBg'):Show()
			end
			nRolesH = nRolesH + h:GetH()
		end
		handle:SetH(nRolesH)
	else
		nMemberCount = frame.nMemberCount or CTM_MEMBER_COUNT
		local handle = h:Lookup('Handle_Cols/Handle_Roles')
		for i = 0, handle:GetItemCount() - 1 do
			local h = handle:Lookup(i)
			if h.dwID then
				nRolesH = nRolesH + h:GetH()
			end
			h:Lookup('Image_SlotBg'):Hide()
			h:Lookup('Image_MemberBg'):SetVisible(not not h.dwID)
		end
		handle:SetH(nRolesH)
	end
	if not CFG.bShowGroupNumber then
		nGroupHeight = 23
	end
	frame:SetSize(128 * fX, 25 * fY + nRolesH - height - nGroupHeight)
	h:Lookup('Handle_BG/Shadow_BG'):SetSize(120 * fX, nRolesH + 20 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG/Image_BG_L'):SetSize(18 * fX, nRolesH + nMemberCount * 3 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG/Image_BG_R'):SetSize(18 * fX, nRolesH + nMemberCount * 3 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG/Image_BG_BL'):SetRelPos(0, nRolesH + 11 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG/Image_BG_T'):SetSize(110 * fX, 18 * fY)
	h:Lookup('Handle_BG/Image_BG_B'):SetSize(110 * fX, 18 * fY)
	h:Lookup('Handle_BG/Image_BG_B'):SetRelPos(14 * fX, nRolesH + 11 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG/Image_BG_BR'):SetRelPos(112 * fX, nRolesH + 11 * fY - height - nGroupHeight)
	h:Lookup('Handle_BG'):FormatAllItemPos()
	h:Lookup('Handle_Cols/Handle_Title'):SetVisible(CFG.bShowGroupNumber)
	h:Lookup('Handle_Cols/Handle_Title'):SetH(23)
	h:Lookup('Handle_Cols/Handle_Title/Text_Title'):SetH(23)
	h:Lookup('Handle_Cols/Handle_Title/Image_TitleBg'):SetH(23)
	h:Lookup('Handle_Cols'):FormatAllItemPos()
end

-- 注册buff
function CTM:RecBuff(dwMemberID, tRule)
	local szKey = ('%d,%d,%s%d'):format(
		tRule.dwID, tRule.nLevel,
		tRule.szStackOp or '',
		tRule.nStackNum or 0
	)
	CTM_BUFF_RULE[szKey] = setmetatable({ szKey = szKey }, { __index = tRule })
end

function CTM:ClearBuff(dwMemberID)
	local team = GetClientTeam()
	for k, v in ipairs(team.GetTeamMemberList()) do
		if CTM_CACHE[v] and CTM_CACHE[v]:IsValid() then
			CTM_CACHE[v]:Lookup('Handle_Buff_Boxes'):Clear()
		end
		if CTM_CAUTION_BUFF[v] then
			CTM_CAUTION_BUFF[v] = nil
		end
		if CTM_ATTENTION_BUFF[v] then
			for _, p in pairs(CTM_ATTENTION_BUFF[v]) do
				for i, rec in X.ipairs_r(CTM_ATTENTION_STACK[v]) do
					if rec == p then
						table.remove(CTM_ATTENTION_STACK[v], i)
						break
					end
				end
			end
			CTM_ATTENTION_BUFF[v] = nil
		end
		if CTM_CAUTION_BUFF[v] then
			CTM_CAUTION_BUFF[v] = nil
		end
		if CTM_SCREEN_HEAD[v] then
			CTM_SCREEN_HEAD[v] = nil
		end
	end
	CTM_BUFF_RULE = {}
end

function D.UpdateCharaterBuffBox(hItem, tBuff, tRule)
	local nEndFrame, nStackNum = tBuff.nEndFrame, tBuff.nStackNum
	-- 描边
	local r, g, b, a
	if tRule.colBorder or tRule.col then
		r, g, b, a = X.HumanColor2RGB(tRule.colBorder or tRule.col)
	end
	if tRule.colBorder or tRule.col then
		local hSha, sha = hItem:Lookup('Handle_RbgBorders')
		for i = 0, hSha:GetItemCount() - 1 do
			sha = hSha:Lookup(i)
			sha:SetAlpha(a or tRule.nColAlpha or 192)
			sha:SetColorRGB(r or 255, g or 255, b or 0)
		end
		hItem:Lookup('Handle_RbgBorders'):Show()
		hItem:Lookup('Handle_InnerBorders'):Show()
	else
		hItem:Lookup('Handle_RbgBorders'):Hide()
		hItem:Lookup('Handle_InnerBorders'):Hide()
	end
	-- 文字大小
	local r, g, b, a
	if tRule.colReminder or tRule.col then
		r, g, b, a = X.HumanColor2RGB(tRule.colReminder or tRule.col)
	end
	local szName, icon = X.GetBuffName(tRule.dwID, tRule.nLevelEx or tBuff.nLevel)
	if tRule.nIcon and tonumber(tRule.nIcon) then
		icon = tRule.nIcon
	end
	hItem.szName = szName
	local box = hItem:Lookup('Box')
	box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, tRule.dwID, tRule.nLevelEx)
	box:SetObjectIcon(icon)
	box:SetObjectStaring(CFG.bStaring)
	local txtStackNum = hItem:Lookup('Text_StackNum')
	txtStackNum:SetFontColor(255, 255, 255)
	local txtReminder = hItem:Lookup('Text_Reminder')
	txtReminder:SetText(tRule.szReminder)
	txtReminder:SetVisible(CFG.bShowBuffReminder)
	txtReminder:SetFontColor(r or 255, g or 255, b or 255)

	-- revise
	-- update data
	hItem.dwID = tBuff.dwID
	hItem.nLevel = tBuff.nLevel
	hItem.nEndFrame = nEndFrame
	hItem.nStackNum = nStackNum
	hItem.szVia = tRule.szVia
	-- buff time
	local txtTime = hItem:Lookup('Text_Time')
	if CFG.bShowBuffTime then
		local nTime, r, g, b = MY_GetEndTime(nEndFrame)
		if nTime <= 5 then
			if nTime >= 0 then
				r, g, b = 255, 0, 0
			end
		elseif nTime <= 30 then
			r, g, b = 255, 255, 0
		end
		if r and g and b then
			txtTime:SetText(math.floor(nTime) .. '"')
			txtTime:SetFontColor(r, g, b)
		else
			txtTime:SetText('')
		end
	end
	txtTime:SetVisible(CFG.bShowBuffTime)
	-- buff stack number
	local txtStackNum = hItem:Lookup('Text_StackNum')
	if CFG.bShowBuffNum and nStackNum > 1 then
		txtStackNum:SetText(nStackNum)
	else
		txtStackNum:SetText('')
	end
	txtStackNum:SetVisible(CFG.bShowBuffNum)
end

-- BUFF => 数据表，排序根据优先级、作用域刷新作用严格程度
local function RuleSorter(a, b)
	-- 全局优先级
	if a.nPriority == b.nPriority then
		-- 作用域优先级
		if (a.szStackOp == '') == (b.szStackOp == '') then
			-- 来源优先级
			if a.nViaPriority == b.nViaPriority then
				return false
			end
			if not a.nViaPriority then
				return false
			end
			if not b.nViaPriority then
				return true
			end
			return a.nViaPriority < b.nViaPriority
		end
		if a.szStackOp == '' then
			return false
		end
		if b.szStackOp == '' then
			return true
		end
		return false
	end
	if not a.nPriority then
		return false
	end
	if not b.nPriority then
		return true
	end
	return a.nPriority < b.nPriority
end
local function DispSorter(a, b)
	if a.nPriority == b.nPriority then
		local nTimeA = CTM_BUFF_TIME[a.dwCharID] and CTM_BUFF_TIME[a.dwCharID][a.tBuff.dwID]
		local nTimeB = CTM_BUFF_TIME[b.dwCharID] and CTM_BUFF_TIME[b.dwCharID][b.tBuff.dwID]
		if nTimeA == nTimeB then
			return false
		end
		if not nTimeA then
			return true
		end
		if not nTimeB then
			return false
		end
		return nTimeA < nTimeB
	end
	if not a.nPriority then
		return false
	end
	if not b.nPriority then
		return true
	end
	return a.nPriority < b.nPriority
end
function D.UpdateCharaterBuff(p, handle, tKeep)
	if X.IsInCompetitionMap() and X.IsClientPlayerMountMobileKungfu() then
		return
	end
	local dwCharID = p.dwID
	local me = X.GetClientPlayer()
	-- 气劲数据归并
	local tDisp = {}
	for _, tRule in pairs(CTM_BUFF_RULE) do
		local buff = (not tRule.bOnlyMe or p.dwID == me.dwID)
			and MY_GetBuff(p, tRule.dwID, tRule.nLevel, tRule.bOnlyMine and me.dwID)
			or nil
		if buff then
			if buff.nStackNum and tRule.nStackNum
			and not X.JudgeOperator(tRule.szStackOp or '>=', buff.nStackNum, tRule.nStackNum) then
				buff = nil
			end
			if buff then
				tKeep[tRule.szKey] = true
				-- 加入 BUFF 组，准备后续排序渲染
				if not tDisp[buff.szKey] then
					tDisp[buff.szKey] = {
						tBuff = buff,
						aRule = {},
					}
				end
				table.insert(tDisp[buff.szKey].aRule, tRule)
			end
		end
	end
	-- 气劲数据排序
	local aDisp = {}
	local tRuleKey = {}
	for _, tItem in pairs(tDisp) do
		table.sort(tItem.aRule, RuleSorter)
		local tRule = tItem.aRule[1]
		local nPriority = tRule.nPriority
		if not nPriority then
			if tRule.bCaution then
				nPriority = 0
			elseif tRule.bAttention then
				nPriority = 1
			end
		end
		table.insert(aDisp, {
			dwCharID = dwCharID,
			tBuff = tItem.tBuff,
			tRule = tRule,
			nPriority = nPriority,
		})
		tRuleKey[tRule.szKey] = true
	end
	table.sort(aDisp, DispSorter)
	-- 气劲渲染
	for i = 1, CFG.nMaxShowBuff do
		local hItem = handle:Lookup(i - 1)
		local tItem = aDisp[i]
		if tItem then
			if not hItem then
				hItem = handle:AppendItemFromData(MY_CataclysmMain.GetFrame().hBuff)
				local fScale = 1
				if CFG.bAutoBuffSize then
					if CFG.fScaleY > 1 then
						fScale = CFG.fScaleY
					end
					fScale = fScale * 0.8 -- INI画大了不好调 这里调整下吧
				else
					fScale = CFG.fBuffScale
				end
				local fFontScale = fScale * 0.9 / (1 + Font.GetOffset() * 0.07)
				hItem:Scale(fScale, fScale)
				local txtTime = hItem:Lookup('Text_Time')
				txtTime:SetFontScale(fFontScale * (hItem:GetH() / txtTime:GetH()) * 0.6)
				local txtStackNum = hItem:Lookup('Text_StackNum')
				txtStackNum:SetFontScale(fFontScale * (hItem:GetH() / txtStackNum:GetH()) * 0.55)
				local txtReminder = hItem:Lookup('Text_Reminder')
				txtReminder:SetFontScale(fFontScale * (hItem:GetH() / txtReminder:GetH()) * 0.6)
				hItem.bBuff = true
			end
			hItem:Show()
			D.UpdateCharaterBuffBox(hItem, tItem.tBuff, tItem.tRule)
		elseif hItem then
			hItem:Hide()
		end
	end
	handle:FormatAllItemPos()
	-- 渲染当前提醒
	for _, tItem in ipairs(aDisp) do
		local tRule = tItem.tRule
		local tBuff = tItem.tBuff
		-- update attention
		if tRule.bAttention then
			if not CTM_ATTENTION_BUFF[dwCharID] then
				CTM_ATTENTION_BUFF[dwCharID] = {}
			end
			if not CTM_ATTENTION_STACK[dwCharID] then
				CTM_ATTENTION_STACK[dwCharID] = {}
			end
			if not CTM_ATTENTION_BUFF[dwCharID][tRule.szKey] then
				local rec = {
					col = tRule.colAttention or tRule.col or 'yellow',
				}
				CTM_ATTENTION_BUFF[dwCharID][tRule.szKey] = rec
				table.insert(CTM_ATTENTION_STACK[dwCharID], 1, rec)
			end
		end
		-- update caution
		if tRule.bCaution then
			if not CTM_CAUTION_BUFF[dwCharID] then
				CTM_CAUTION_BUFF[dwCharID] = {}
			end
			CTM_CAUTION_BUFF[dwCharID][tRule.szKey] = true
		end
		-- update screen head
		if tRule.bScreenHead then
			if not CTM_SCREEN_HEAD[dwCharID] then
				CTM_SCREEN_HEAD[dwCharID] = {}
			end
			if not CTM_SCREEN_HEAD[dwCharID][tRule.szKey] then
				local szCountdownKey = 'MY_CATACLYSM_' .. tBuff.dwID .. '_' .. tRule.szKey
				FireUIEvent('MY_LIFEBAR_COUNTDOWN', dwCharID, 'BUFF', szCountdownKey, {
					dwBuffID = tBuff.dwID,
					szText = tBuff.szName,
					nLogicFrame = tBuff.nEndFrame,
					col = tRule.colScreenHead or tRule.col,
					nPriority = tItem.nPriority,
				})
				CTM_SCREEN_HEAD[dwCharID][tRule.szKey] = szCountdownKey
			end
		end
	end
	-- 移除消失的提醒
	if CTM_ATTENTION_BUFF[dwCharID] then
		for szRuleKey, rec in pairs(CTM_ATTENTION_BUFF[dwCharID]) do
			if not tRuleKey[szRuleKey] then
				for i, vv in X.ipairs_r(CTM_ATTENTION_STACK[dwCharID]) do
					if vv == rec then
						table.remove(CTM_ATTENTION_STACK[dwCharID], i)
						break
					end
				end
				CTM_ATTENTION_BUFF[dwCharID][szRuleKey] = nil
			end
		end
	end
	if CTM_CAUTION_BUFF[dwCharID] then
		for szRuleKey, _ in pairs(CTM_CAUTION_BUFF[dwCharID]) do
			if not tRuleKey[szRuleKey] then
				CTM_CAUTION_BUFF[dwCharID][szRuleKey] = nil
			end
		end
	end
	if CTM_SCREEN_HEAD[dwCharID] then
		for szRuleKey, _ in pairs(CTM_SCREEN_HEAD[dwCharID]) do
			if not tRuleKey[szRuleKey] then
				FireUIEvent(
					'MY_LIFEBAR_COUNTDOWN',
					dwCharID,
					'BUFF',
					CTM_SCREEN_HEAD[dwCharID][szRuleKey],
					false
				)
				CTM_SCREEN_HEAD[dwCharID][szRuleKey] = nil
			end
		end
	end
end

function CTM:RefreshBuff()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and GetLogicFrameCount() % 8 ~= 0 then
		return
	end
	local team = GetClientTeam()
	local tKeep = {}
	for k, v in ipairs(team.GetTeamMemberList()) do
		local p = X.GetPlayer(v)
		local handle = CTM_CACHE[v] and CTM_CACHE[v]:IsValid() and CTM_CACHE[v]:Lookup('Handle_Buff_Boxes')
		if handle then
			if p then
				D.UpdateCharaterBuff(p, handle, tKeep)
			else
				handle:Clear()
			end
		end
	end
	for k, v in pairs(CTM_BUFF_RULE) do
		if not tKeep[k] then
			CTM_BUFF_RULE[k] = nil
		end
	end
	-- print(CTM_BUFF_CACHE)
end

function CTM:RecBossFocusBuff(dwMemberID, data)
	CTM_BOSS_FOCUS_BUFF[data.dwID .. '#' .. data.nLevel] = data
end

function CTM:RefreshBossFocus()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and GetLogicFrameCount() % 16 ~= 0 then
		return
	end
	local team, me = GetClientTeam(), X.GetClientPlayer()
	for k, v in ipairs(team.GetTeamMemberList()) do
		if CTM_CACHE[v] and CTM_CACHE[v]:IsValid() then
			local p, bFocus = X.GetPlayer(v), nil
			if p then
				for _, data in pairs(CTM_BOSS_FOCUS_BUFF) do
					local buff = MY_GetBuff(p, data.dwID, data.nLevel)
					if buff and buff.nStackNum >= data.nStackNum then
						bFocus = true
						break
					end
				end
			end
			CTM_BOSS_FOCUSED_STATE[v] = bFocus
		end
	end
	self:RefreshCaution()
end

function CTM:RefreshDistance()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and GetLogicFrameCount() % 8 ~= 0 then
		return
	end
	local me = X.GetClientPlayer()
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() then
			local p = X.GetPlayer(k) -- info.nPoX 刷新太慢了 对于治疗来说 这个太重要了
			if p then
				local nDistance = MY.GetCharacterDistance(me, p) -- 只计算平面 --??
				if CFG.bEnableDistance then
					local find
					for kk, vv in ipairs(CFG.tDistanceLevel) do
						if nDistance <= vv then
							if v.nDistanceLevel ~= kk then
								v.nDistanceLevel = kk
								self:CallDrawHPMP(k, true)
							end
							find = true
							break
						end
					end
					-- 如果上面都不匹配的话 默认认为出了同步范围 feedback 桥之于水
					if not find and v.nDistanceLevel then
						v.nDistanceLevel = nil
						self:CallDrawHPMP(k, true)
					end
				else
					v.nDistance = 0
					v.nDistanceLevel = 1
				end
				if CFG.bShowDistance then
					v:Lookup('Text_Distance'):SetText(string.format('%.1f', nDistance))
					v:Lookup('Text_Distance'):SetFontColor(255, math.max(0, 255 - nDistance * 8), math.max(0, 255 - nDistance * 8))
				else
					v:Lookup('Text_Distance'):SetText('')
				end
			else
				if CFG.bShowDistance then
					v:Lookup('Text_Distance'):SetText('')
				end
				if v.nDistance or v.nDistanceLevel then
					v.nDistance = nil
					v.nDistanceLevel = nil
					self:CallDrawHPMP(k, true)
				end
			end
		end
	end
end

function CTM:RecPlayerSkillCD(dwMemberID, dwSkillID, nSkillLevel, nEndFrame)
	if not CTM_PLAYER_SKILL_CD[dwMemberID] then
		CTM_PLAYER_SKILL_CD[dwMemberID] = {}
	end
	CTM_PLAYER_SKILL_CD[dwMemberID] = {
		dwSkillID = dwSkillID,
		nSkillLevel = nSkillLevel,
		nEndFrame = nEndFrame,
	}
end

function CTM:RefreshPlayerSkillCD()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and GetLogicFrameCount() % 16 ~= 0 then
		return
	end
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() then
			local rec = CFG.bEnableImportantSkill and CTM_PLAYER_SKILL_CD[k]
			if rec then
				local nLeft = math.ceil(math.max(0, rec.nEndFrame - GetLogicFrameCount()) / GLOBAL.GAME_FPS)
				if nLeft > 0 then
					v:Lookup('Handle_SkillCD/Box_SkillCD'):Hide()
					v:Lookup('Handle_SkillCD/Text_SkillCD'):Show()
					v:Lookup('Handle_SkillCD/Text_SkillCD'):SetText(nLeft > 60 and (math.ceil(nLeft / 60) .. '\'') or (nLeft .. '"'))
				else
					v:Lookup('Handle_SkillCD/Text_SkillCD'):Hide()
					v:Lookup('Handle_SkillCD/Box_SkillCD'):Show()
					v:Lookup('Handle_SkillCD/Box_SkillCD'):SetObjectIcon(Table_GetSkillIconID(rec.dwSkillID, rec.nSkillLevel))
				end
				v:Lookup('Handle_SkillCD'):Show()
			else
				v:Lookup('Handle_SkillCD'):Hide()
			end
		end
	end
end

-- 血量 / 内力
function CTM:CallDrawHPMP(dwID, ...)
	if type(dwID) == 'number' then
		local info = self:GetMemberInfo(dwID)
		local handle = CTM_CACHE[dwID]
		if info and handle and handle:IsValid() then
			self:DrawHPMP(handle, dwID, info, ...)
		end
	else
		for k, v in pairs(CTM_CACHE) do
			if v:IsValid() then
				local info = self:GetMemberInfo(k)
				if info then
					self:DrawHPMP(v, k, info, ...)
				end
			end
		end
	end
end

-- 缩放对动态构建的UI不会缩放 所以需要后处理
function CTM:DrawHPMP(h, dwID, info, bRefresh)
	if not info then return end
	local bSha = CFG.nBGColorMode ~= CTM_BG_COLOR_MODE.OFFICIAL
	local hLife = h:Lookup('Handle_Life')
	local hMana = h:Lookup('Handle_Mana')
	local Lsha = hLife:Lookup('Shadow_Life')
	local Limg = hLife:Lookup('Image_Life')
	local Ledg = hLife:Lookup('Image_LifeLine')
	local Msha = hMana:Lookup('Shadow_Mana')
	local Mimg = hMana:Lookup('Image_Mana')
	local player, npc, dwMountType
	if CHANGGE_REAL_SHADOW_CACHE[dwID] then
		npc = X.GetNpc(CHANGGE_REAL_SHADOW_CACHE[dwID])
	end
	if CFG.bFasterHP then
		player = X.GetPlayer(dwID)
	end
	-- 气血计算 因为sync 必须拿出来单独算
	local obj = npc or player
	local fLifePercentage
	local fCurrentLife, fMaxLife = X.GetCharacterLife(obj)
	if not fCurrentLife or fCurrentLife < - 1000
	or fMaxLife == 1 or fCurrentLife == 1
	or fCurrentLife == 255 or fMaxLife == 255 then -- obj sync err fix
		fCurrentLife, fMaxLife = X.GetCharacterLife(info)
	end
	fMaxLife     = math.max(1, fMaxLife)
	fCurrentLife = math.max(0, fCurrentLife)
	fLifePercentage = fMaxLife ~= 0 and (fCurrentLife / fMaxLife)
	if not fLifePercentage or fLifePercentage < 0 or fLifePercentage > 1 then
		fLifePercentage = 1
	end
	Lsha:SetVisible(bSha)
	Msha:SetVisible(bSha)
	Limg:SetVisible(not bSha)
	Ledg:SetVisible(not bSha)
	Mimg:SetVisible(not bSha)

	local bDeathFlag = info.bDeathFlag
	-- 有待验证
	if player then
		if player.GetKungfuMount() then
			dwMountType = player.GetKungfuMount().dwMountType
		end
		if player.nMoveState == MOVE_STATE_ON_STAND then
			if info.bDeathFlag then
				bDeathFlag = true
			end
		else
			bDeathFlag = player.nMoveState == MOVE_STATE_ON_DEATH
		end
	end
	-- 透明度
	local nAlpha = 255
	if CFG.nBGColorMode ~= CTM_BG_COLOR_MODE.BY_DISTANCE then
		if h.nDistanceLevel then
			nAlpha = CFG.tDistanceAlpha[h.nDistanceLevel]
		elseif info.bOnline then
			nAlpha = CFG.tOtherAlpha[3]
		else
			nAlpha = CFG.tOtherAlpha[2]
		end
	else
		nAlpha = 255
	end
	-- 内力
	if not bDeathFlag then
		local nPercentage, nManaShow = 1, 1
		local mana = h:Lookup('Text_Mana')
		if not IsPlayerManaHide(info.dwForceID, dwMountType) then -- 内力不需要那么准
			nPercentage = info.nMaxMana ~= 0 and (info.nCurrentMana / info.nMaxMana)
			nManaShow = info.nCurrentMana
			if not CFG.nShowMP then
				mana:SetText('')
			else
				mana:SetText(nManaShow)
			end
			mana:SetFontScheme(CFG.nManaFont)
			mana:SetFontScale(CFG.fManaFontScale)
		end
		if not nPercentage or nPercentage < 0 or nPercentage > 1 then
			nPercentage = 1
		end
		if bSha then
			local r, g, b = unpack(CFG.tManaColor)
			if not info.bOnline then
				r, g, b = unpack(CFG.tOtherCol[2]) -- 不在线就灰色了
			end
			self:DrawShadow(Msha, hMana:GetW() * nPercentage, Msha:GetH(), r, g, b, nAlpha, CFG.bManaGradient)
			Msha:Show()
		else
			if info.bOnline then
				Mimg:ToNormal()
			else
				Mimg:ToGray()
			end
			Mimg:Show()
			Mimg:SetAlpha(nAlpha)
			Mimg:SetPercentage(nPercentage)
		end
	else
		Mimg:Hide()
	end
	-- 掉血警告 必须早于血条绘制
	if CFG.bHPHitAlert then
		local lifeFade = hLife:Lookup('Shadow_Life_Fade')
		if CTM_LIFE_CACHE[dwID] and CTM_LIFE_CACHE[dwID] > fLifePercentage then
			local nAlpha, nW, nH = lifeFade:GetAlpha(), 0, 0
			if nAlpha == 0 then
				if bSha then
					nW, nH = Lsha:GetSize()
				else
					nW, nH = Limg:GetSize()
				end
				lifeFade:SetSize(nW * CTM_LIFE_CACHE[dwID], nH)
			end
			lifeFade:SetAlpha(240)
			lifeFade:Show()

			local key = 'MY_CATACLYSM_HIT_' .. dwID
			X.BreatheCall(key, false)
			X.BreatheCall(key, function()
				if lifeFade:IsValid() then
					local nFadeAlpha = math.max(lifeFade:GetAlpha() - CTM_ALPHA_STEP, 0)
					lifeFade:SetAlpha(nFadeAlpha)
					if nFadeAlpha <= 0 then
						X.BreatheCall(key, false)
					end
				else
					X.BreatheCall(key, false)
				end
			end)
		end
	else
		hLife:Lookup('Shadow_Life_Fade'):Hide()
	end
	-- 缓存
	if not CFG.bFasterHP or bRefresh or (CFG.bFasterHP and CTM_LIFE_CACHE[dwID] ~= fLifePercentage) then
		if bSha then
			-- 颜色计算
			local nNewW = hLife:GetW() * fLifePercentage
			local r, g, b = unpack(CFG.tOtherCol[2]) -- 不在线就灰色了
			if info.bOnline then
				if CFG.nBGColorMode == CTM_BG_COLOR_MODE.BY_DISTANCE then
					if player or X.GetPlayer(dwID) then
						if h.nDistanceLevel then
							r, g, b = unpack(CFG.tDistanceCol[h.nDistanceLevel])
						else
							r, g, b = unpack(CFG.tOtherCol[3])
						end
					else
						r, g, b = unpack(CFG.tOtherCol[3]) -- 在线使用白色
					end
				elseif CFG.nBGColorMode == CTM_BG_COLOR_MODE.SAME_COLOR then
					r, g, b = unpack(CFG.tDistanceCol[1]) -- 使用用户配色1
				elseif CFG.nBGColorMode == CTM_BG_COLOR_MODE.BY_FORCE then
					r, g, b = X.GetForceColor(info.dwForceID, 'background')
				end
			end
			self:DrawShadow(Lsha, nNewW, Lsha:GetH(), r, g, b, nAlpha, CFG.bLifeGradient)
			Lsha:Show()
		else
			local nRelX = Limg:GetRelX() + Limg:GetW() * fLifePercentage - Ledg:GetW()
			Ledg:Show()
			Ledg:SetAlpha(nAlpha)
			Ledg:SetRelX(nRelX)
			Ledg:SetAbsX(hLife:GetAbsX() + nRelX)
			if info.bOnline then
				Limg:ToNormal()
			else
				Limg:ToGray()
			end
			Limg:Show()
			Limg:SetAlpha(nAlpha)
			Limg:SetPercentage(fLifePercentage)
		end

		if not CTM_LIFE_CACHE[dwID] then
			CTM_LIFE_CACHE[dwID] = 0
		else
			CTM_LIFE_CACHE[dwID] = fLifePercentage
		end
		-- 数值绘制
		local life = h:Lookup('Text_Life')
		local nFontAlpha = math.min(nAlpha * 0.4 + 255 * 0.6, 255)
		if not info.bOnline then
			nFontAlpha = nFontAlpha * 0.8
		end
		life:SetAlpha(nAlpha == 0 and 0 or nFontAlpha)
		life:SetFontScheme(CFG.nLifeFont)
		life:SetFontScale(CFG.fLifeFontScale)
		h:Lookup('Text_Name'):SetAlpha(nFontAlpha)

		if not bDeathFlag and info.bOnline then
			life:SetFontColor(255, 255, 255)
			if CFG.nHPShownMode2 == 0 then
				life:SetText('')
			else
				local fnAction = function(val, max)
					if CFG.nHPShownNumMode == 1 then
						if val > 9999 then
							val = (CFG.bShowHPDecimal and '%.1fw' or '%dw'):format(val / 10000)
						end
					elseif CFG.nHPShownNumMode == 2 then
						val = (CFG.bShowHPDecimal and '%.1f%%' or '%d%%'):format(val / max * 100)
					end
					return val
				end
				if CFG.nHPShownMode2 == 2 then
					life:SetText(fnAction(fCurrentLife, fMaxLife))
				elseif CFG.nHPShownMode2 == 1 then
					local nShownLife = fMaxLife - fCurrentLife
					if nShownLife > 0 then
						life:SetText('-' .. fnAction(nShownLife, fMaxLife))
					else
						life:SetText('')
					end
				end
			end
		elseif not info.bOnline then
			life:SetText('')
		elseif bDeathFlag then
			life:SetText('')
		else
			life:SetFontColor(128, 128, 128)
			life:SetText(COINSHOP_SOURCE_NULL)
		end
		-- if info.dwActualKungfuID == 0 then -- 没有同步成功时显示的内容
			-- life:SetText('sync ...')
		-- end
		h:Lookup('Text_Death'):SetVisible(bDeathFlag)
		h:Lookup('Text_OffLine'):SetVisible(not info.bOnline)
		h:Lookup('Text_Death'):SetFontScale(CFG.fLifeFontScale)
		h:Lookup('Text_OffLine'):SetFontScale(CFG.fLifeFontScale)
		h:Lookup('Image_PlayerBg'):SetVisible(info.bOnline)
	end
end

-- 重绘溅射助手
function CTM:RefreshSputtering()
	if X.ENVIRONMENT.RUNTIME_OPTIMIZE and GetLogicFrameCount() % 16 ~= 0 then
		return
	end
	local team = GetClientTeam()
	if CFG.bShowSputtering then
		for nGroup = 0, team.nGroupNum - 1 do
			local tGroupInfo = team.GetGroupInfo(nGroup)
			local nMaxCount, tCount = 1, {}
			for _, dwID in pairs(tGroupInfo.MemberList) do
				local info, nCount = team.GetMemberInfo(dwID), 0
				local player = X.GetPlayer(dwID)
				if player and not info.bDeathFlag and info.bOnline then
					for _, dwID2 in pairs(tGroupInfo.MemberList) do
						local info2 = team.GetMemberInfo(dwID2)
						local player2 = X.GetPlayer(dwID2)
						if player2 and not info2.bDeathFlag and info2.bOnline
						and X.GetCharacterDistance(player, player2, 'gwwean') <= CFG.nSputteringDistance then
							nCount = nCount + 1
						end
					end
					if nCount > nMaxCount then
						nMaxCount = nCount
					end
				end
				tCount[dwID] = nCount
			end
			for _, dwID in pairs(tGroupInfo.MemberList) do
				local handle = CTM_CACHE[dwID]
				if handle and handle:IsValid() then
					handle:Lookup('Handle_Sputtering'):SetVisible(tCount[dwID] == nMaxCount)
					handle:Lookup('Handle_Sputtering/Text_Sputtering'):SetAlpha(CFG.nSputteringFontAlpha)
					handle:Lookup('Handle_Sputtering/Text_Sputtering'):SetText(nMaxCount)
					handle:Lookup('Handle_Sputtering/Text_Sputtering'):SetFontColor(unpack(CFG.tSputteringFontColor))
					handle:Lookup('Handle_Sputtering/Shadow_Sputtering'):SetAlpha(CFG.nSputteringShadowAlpha)
					handle:Lookup('Handle_Sputtering/Shadow_Sputtering'):SetColorRGB(unpack(CFG.tSputteringShadowColor))
				end
			end
		end
	else
		for nGroup = 0, team.nGroupNum - 1 do
			local tGroupInfo = team.GetGroupInfo(nGroup)
			for _, dwID in pairs(tGroupInfo.MemberList) do
				local handle = CTM_CACHE[dwID]
				if handle and handle:IsValid() then
					handle:Lookup('Handle_Sputtering'):Hide()
				end
			end
		end
	end
end

function CTM:DrawShadow(sha, x, y, r, g, b, a, bGradient) -- 重绘三角扇
	sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
	sha:ClearTriangleFanPoint()
	if bGradient then
		sha:AppendTriangleFanPoint(0, 0, 64, 64, 64, a)
		sha:AppendTriangleFanPoint(x, 0, 64, 64, 64, a)
		sha:AppendTriangleFanPoint(x, y, r, g, b, a)
		sha:AppendTriangleFanPoint(0, y, r, g, b, a)
	else
		sha:AppendTriangleFanPoint(0, 0, r, g, b, a)
		sha:AppendTriangleFanPoint(x, 0, r, g, b, a)
		sha:AppendTriangleFanPoint(x, y, r, g, b, a)
		sha:AppendTriangleFanPoint(0, y, r, g, b, a)
	end
end

do
local VOTE_OPTIONS = {
	['raid_ready'] = { awaitPath = 'Image_ReadyCover', rejectPath = 'Image_NotReady', resolvePath = 'Animate_Ready', timeoutAlert = 5000 },
	['wage_agree'] = { awaitPath = 'Handle_TeamVoteWait', rejectPath = 'Handle_TeamVoteReject', timeout = 30000 },
}
function CTM:StartTeamVote(eType)
	local opt = VOTE_OPTIONS[eType]
	if not opt then
		return
	end
	self:ClearTeamVote(eType)
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() then
			local info = self:GetMemberInfo(k)
			local bAwait = info.bOnline
			if k == X.GetClientPlayerID() then
				if eType == 'raid_ready' then
					bAwait = false
				elseif eType == 'wage_agree' then
					bAwait = not X.IsClientPlayerTeamDistributor()
				end
			end
			if bAwait then
				v:Lookup(opt.awaitPath):Show()
			end
		end
	end
	if opt.timeoutAlert then
		X.DelayCall(opt.timeoutAlert, function()
			for k, v in pairs(CTM_CACHE) do
				if v:IsValid() then
					if v:Lookup(opt.awaitPath):IsVisible() or v:Lookup(opt.rejectPath):IsVisible() then
						X.Confirm(g_tStrings.STR_RAID_READY_CONFIRM_RESET .. '?', function()
							self:ClearTeamVote(eType)
						end)
						break
					end
				end
			end
		end)
	end
	if opt.timeout then
		X.DelayCall(opt.timeout, function()
			self:ClearTeamVote(eType)
		end)
	end
end

function CTM:ChangeTeamVoteState(eType, dwID, status)
	local opt = VOTE_OPTIONS[eType]
	if not opt then
		return
	end
	local handle = CTM_CACHE[dwID]
	if handle and handle:IsValid() then
		handle:Lookup(opt.awaitPath):Hide()
		if status == 'resolve' and opt.resolvePath then
			local key = 'MY_CATACLYSM_READY_' .. eType .. '_' .. dwID
			local hResolve = handle:Lookup(opt.resolvePath)
			hResolve:Show()
			hResolve:SetAlpha(240)
			X.BreatheCall(key, function()
				if not X.IsElement(handle) then
					X.BreatheCall(key, false)
					return
				end
				local hResolve = handle:Lookup(opt.resolvePath)
				if not X.IsElement(hResolve) then
					X.BreatheCall(key, false)
					return
				end
				local nAlpha = math.max(hResolve:GetAlpha() - 15, 0)
				hResolve:SetAlpha(nAlpha)
				if nAlpha <= 0 then
					X.BreatheCall(key, false)
				end
			end)
		elseif status == 'reject' then
			handle:Lookup(opt.rejectPath):Show()
		end
	end
end

function CTM:ClearTeamVote(eType)
	local opt = VOTE_OPTIONS[eType]
	if not opt then
		return
	end
	for k, v in pairs(CTM_CACHE) do
		if v:IsValid() then
			for _, k in ipairs({ 'resolvePath', 'rejectPath', 'awaitPath' }) do
				if opt[k] and v:Lookup(opt[k]) then
					v:Lookup(opt[k]):Hide()
				end
			end
		end
	end
end
end

function CTM:CallEffect(dwTargetID, nDelay)
	if CTM_CACHE[dwTargetID] and CTM_CACHE[dwTargetID]:IsValid() then
		X.DelayCall('MY_Cataclysm_' .. dwTargetID, nDelay, function()
			if CTM_CACHE[dwTargetID] and CTM_CACHE[dwTargetID]:IsValid() then
				CTM_CACHE[dwTargetID]:Lookup('Image_Effect'):Hide()
			end
		end)
		CTM_CACHE[dwTargetID]:Lookup('Image_Effect'):Show()
	end
end

local function GetMemberHandle(dwID)
	local handle = CTM_CACHE[dwID]
	if handle and handle:IsValid() then
		return handle
	end
end

local ui = {
	GetMemberHandle = GetMemberHandle,
}
MY_CataclysmParty = setmetatable(ui, { __index = CTM, __newindex = function() end, __metatable = true })

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
