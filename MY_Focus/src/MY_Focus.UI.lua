--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 焦点列表
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Focus/MY_Focus.UI'
local PLUGIN_NAME = 'MY_Focus'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Focus'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.0') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------
local INI_PATH = X.PACKET_INFO.ROOT .. 'MY_Focus/ui/MY_Focus.ini'
local D = {
	GetDisplayList     = MY_Focus.GetDisplayList    ,
	IsShielded         = MY_Focus.IsShielded        ,
	SortFocus          = MY_Focus.SortFocus         ,
	RescanNearby       = MY_Focus.RescanNearby      ,
	RemoveFocusID      = MY_Focus.RemoveFocusID     ,
	OnObjectEnterScene = MY_Focus.OnObjectEnterScene,
	OnObjectLeaveScene = MY_Focus.OnObjectLeaveScene,
}
local TEMP_TARGET_TYPE, TEMP_TARGET_ID
local l_dwLockType, l_dwLockID, l_lockInDisplay

function D.AdjustScaleRatio(frame, hList)
	local hTotal = frame:Lookup('', '')
	local hList = hTotal:Lookup('Handle_List')
	for i = 0, hList:GetItemCount() - 1 do
		local hItem = hList:Lookup(i)
		-- 导航保持比例
		local hL = hItem:Lookup('Handle_L')
		local nDeltaX = hL:GetH() / 70 * 50 - hL:GetW()
		local fScaleL = 1 + nDeltaX / hL:GetW()
		hL:Scale(fScaleL, 1)
		local hR = hItem:Lookup('Handle_R')
		local fScaleR = (hItem:GetW() - hL:GetW()) / hR:GetW()
		hR:Scale(fScaleR, 1)
		hR:SetRelX(hL:GetW())
		hItem:FormatAllItemPos()
		-- 图标保持比例
		local hInfoList = hItem:Lookup('Handle_R/Handle_InfoList')
		for i = 0, hInfoList:GetItemCount() - 1 do
			local hInfo = hInfoList:Lookup(i)
			hInfo:Scale(hInfo:GetH() / hInfo:GetW(), 1)
		end
		hInfoList:FormatAllItemPos()
		-- 字体大小
		X.UI(hItem):Find('.Text'):FontScale(frame.fScaleY)
	end
	local nW, nH = hTotal:Lookup('Image_Title'):GetSize()
	hTotal:Lookup('Text_Title'):SetRelX(nH * 1.1)
	local btnSetting = frame:Lookup('Btn_Setting')
	btnSetting:SetRelX(nH * 0.2)
	btnSetting:Scale(btnSetting:GetH() / btnSetting:GetW(), 1)
	local btnClose = frame:Lookup('Btn_Close')
	btnClose:SetRelX(nW - nH)
	btnClose:Scale(btnClose:GetH() / btnClose:GetW(), 1)
	local chkMinimize = frame:Lookup('CheckBox_Minimize')
	chkMinimize:Scale(chkMinimize:GetH() / chkMinimize:GetW(), 1)
	chkMinimize:SetRelX(btnClose:GetRelX() - chkMinimize:GetW() - nH * 0.1)
	hTotal:FormatAllItemPos()
end

function D.Scale(frame)
	if frame.fScaleX and frame.fScaleY then
		frame:Scale(1 / frame.fScaleX, 1 / frame.fScaleY)
	end
	frame.fScaleX = MY_Focus.fScaleX
	frame.fScaleY = MY_Focus.fScaleY
	frame:Scale(frame.fScaleX, frame.fScaleY)
	X.UI(frame):Find('.Text'):FontScale(frame.fScaleY)
	D.AdjustScaleRatio(frame)
end

function D.CreateList(frame)
	local hList = frame:Lookup('', 'Handle_List')
	hList:Clear()
	for i = 1, MY_Focus.nMaxDisplay do
		local hItem = hList:AppendItemFromIni(INI_PATH, 'Handle_Info')
		if frame.fScaleX and frame.fScaleY then
			hItem:Scale(frame.fScaleX, frame.fScaleY)
		end
		if X.UI.IS_GLASSMORPHISM then
			hItem:Lookup('Handle_L/Handle_Compass/Image_Player'):SetSize(35, 35)
			-- hItem:Lookup('Handle_L/Handle_Compass/Image_Player'):SetRelPos(2.5, -0.8)
			local fScaleX = frame.fScaleX or 1
			local fScaleY = frame.fScaleY or 1
			hItem:Lookup('Handle_L/Handle_Compass/Image_Player'):SetRelPos(2.5 * fScaleX, -0.8 * fScaleY)
			hItem:FormatAllItemPos()
		end
		hItem:Hide()
	end
	hList:FormatAllItemPos()
	D.AdjustScaleRatio(frame)
end

function D.Open()
	X.UI.OpenFrame(INI_PATH, 'MY_FocusUI')
end

function D.Close()
	local hFrame = D.GetFrame()
	if hFrame then
		X.UI.CloseFrame(hFrame)
	end
end

function D.GetFrame(szWnd, szItem)
	if szWnd then
		if szItem then
			return Station.Lookup('Normal/MY_FocusUI/' .. szWnd, szItem)
		else
			return Station.Lookup('Normal/MY_FocusUI/' .. szWnd)
		end
	else
		return Station.Lookup('Normal/MY_FocusUI')
	end
end

-- 自适应调整界面大小
function D.AutosizeUI(frame)
	local nHeight = 0
	local hList = frame:Lookup('', 'Handle_List')
	for i = 0, hList:GetItemCount() - 1 do
		local hItem = hList:Lookup(i)
		if hItem:IsVisible() then
			nHeight = nHeight + hItem:GetH()
		end
	end
	hList:SetH(nHeight)
	hList:SetVisible(not MY_Focus.bMinimize)
	frame:SetVisible(nHeight > 0 or not MY_Focus.bAutoHide)
	frame:SetH((MY_Focus.bMinimize and 0 or nHeight) + frame:Lookup('', 'Image_Title'):GetH())
end

-- 绘制指定的焦点Handle
function D.UpdateItem(hItem, p)
	local dwType, dwID = p.dwType, p.dwID
	local szVia, tRule = p.szVia, p.tRule
	local bDeletable = p.bDeletable
	local KObject = X.GetTargetHandle(dwType, dwID)
	local tMemberInfo = X.GetTeamMemberInfo(dwID)
	local szName = tRule and X.ReplaceSensitiveWord(tRule.szDisplay)
	if not szName or szName == '' then
		szName = X.GetTargetName(dwType, dwID)
	end
	local player = X.GetClientPlayer()
	if not KObject then
		return
	end
	hItem.dwType = dwType
	hItem.dwID = dwID
	hItem.szVia = szVia
	hItem.bDeletable = bDeletable

	---------- 左侧 ----------
	-- 小图标列表
	local hInfoList = hItem:Lookup('Handle_R/Handle_InfoList')
	-- 锁定
	hInfoList:Lookup('Handle_Lock'):Hide()
	if dwType == l_dwLockType and dwID == l_dwLockID then
		l_lockInDisplay = true
		hInfoList:Lookup('Handle_Lock'):Show()
	end
	-- 心法
	hInfoList:Lookup('Handle_Kungfu'):Hide()
	if dwType == TARGET.PLAYER then
		if tMemberInfo and tMemberInfo.dwActualKungfuID then
			hItem:Lookup('Handle_L/Handle_KungfuName/Text_Kungfu'):SetText(X.GetKungfuName(tMemberInfo.dwActualKungfuID))
			hInfoList:Lookup('Handle_Kungfu'):Show()
			hInfoList:Lookup('Handle_Kungfu/Image_Kungfu'):FromIconID(Table_GetSkillIconID(tMemberInfo.dwActualKungfuID, 1))
		else
			local kungfu = KObject.GetKungfuMount()
			if kungfu then
				hItem:Lookup('Handle_L/Handle_KungfuName/Text_Kungfu'):SetText(X.GetKungfuName(kungfu.dwSkillID))
				hInfoList:Lookup('Handle_Kungfu'):Show()
				hInfoList:Lookup('Handle_Kungfu/Image_Kungfu'):FromIconID(Table_GetSkillIconID(kungfu.dwSkillID, 1))
			else
				hItem:Lookup('Handle_L/Handle_KungfuName/Text_Kungfu'):SetText(g_tStrings.tForceTitle[KObject.dwForceID])
				hInfoList:Lookup('Handle_Kungfu'):Show()
				hInfoList:Lookup('Handle_Kungfu/Image_Kungfu'):FromUITex(GetForceImage(KObject.dwForceID))
			end
		end
	else
		hItem:Lookup('Handle_L/Handle_KungfuName/Text_Kungfu'):SetText('')
	end
	-- 阵营
	hInfoList:Lookup('Handle_Camp'):Hide()
	if dwType == TARGET.PLAYER then
		local szCampImg, nCampFrame = X.GetCampImage(KObject.nCamp, KObject.bCampFlag)
		if szCampImg then
			hInfoList:Lookup('Handle_Camp'):Show()
			hInfoList:Lookup('Handle_Camp/Image_Camp'):FromUITex(szCampImg, nCampFrame)
		end
	end
	-- 标记
	hInfoList:Lookup('Handle_Mark'):Hide()
	local KTeam = GetClientTeam()
	if KTeam and X.IsClientPlayerInParty() and (dwType == TARGET.NPC or dwType == TARGET.PLAYER) then
		local tMark = KTeam.GetTeamMark()
		if tMark then
			local nMarkID = tMark[dwID]
			if nMarkID then
				hInfoList:Lookup('Handle_Mark'):Show()
				hInfoList:Lookup('Handle_Mark/Image_Mark'):FromUITex(PARTY_MARK_ICON_PATH, PARTY_MARK_ICON_FRAME_LIST[nMarkID])
			end
		end
	end
	-- 角色备注
	hInfoList:Lookup('Handle_MY_PlayerRemark'):SetVisible(szVia == _L['MY_PlayerRemark'])
	hInfoList:FormatAllItemPos()

	-- 目标距离
	local nDistance = 0
	if player then
		nDistance = math.floor(X.GetCharacterDistance(player, KObject, MY_Focus.szDistanceType) * 10) / 10
	end
	hItem:Lookup('Handle_L/Handle_Compass/Compass_Distance'):SetText(nDistance)
	hItem:Lookup('Handle_L/Handle_School/School_Distance'):SetText(nDistance)
	-- 自身面向
	if player then
		hItem:Lookup('Handle_L/Handle_Compass/Image_Player'):Show()
		hItem:Lookup('Handle_L/Handle_Compass/Image_Player'):SetRotate( - player.nFaceDirection / 128 * math.pi)
	end
	-- 左侧主要部分
	if MY_Focus.bDisplayKungfuIcon and dwType == TARGET.PLAYER then
		hItem:Lookup('Handle_L/Handle_Compass'):Hide()
		hItem:Lookup('Handle_L/Handle_School'):Show()
		-- 心法图标
		if tMemberInfo and tMemberInfo.dwActualKungfuID then
			hItem:Lookup('Handle_L/Handle_School/Image_School'):FromIconID(Table_GetSkillIconID(tMemberInfo.dwActualKungfuID, 1))
		else
			local kungfu = KObject.GetKungfuMount()
			if kungfu then
				hItem:Lookup('Handle_L/Handle_School/Image_School'):FromIconID(Table_GetSkillIconID(kungfu.dwSkillID, 1))
			else
				hItem:Lookup('Handle_L/Handle_School/Image_School'):FromUITex(GetForceImage(KObject.dwForceID))
			end
		end
	else
		hItem:Lookup('Handle_L/Handle_School'):Hide()
		hItem:Lookup('Handle_L/Handle_Compass'):Show()
		-- 相对位置
		hItem:Lookup('Handle_L/Handle_Compass/Image_PointRed'):Hide()
		hItem:Lookup('Handle_L/Handle_Compass/Image_PointGreen'):Hide()
		if player and nDistance > 0 then
			local h
			if (dwType == TARGET.NPC or dwType == TARGET.PLAYER) and X.IsCharacterRelationEnemy(X.GetClientPlayerID(), dwID) then
				h = hItem:Lookup('Handle_L/Handle_Compass/Image_PointRed')
			else
				h = hItem:Lookup('Handle_L/Handle_Compass/Image_PointGreen')
			end
			h:Show()
			local nRotate = 0
			-- 特判角度
			if player.nX == KObject.nX then
				if player.nY > KObject.nY then
					nRotate = math.pi / 2
				else
					nRotate = - math.pi / 2
				end
			else
				nRotate = math.atan((player.nY - KObject.nY) / (player.nX - KObject.nX))
			end
			if nRotate < 0 then
				nRotate = nRotate + math.pi
			end
			if KObject.nY < player.nY then
				nRotate = math.pi + nRotate
			end
			local nRadius = 13.5
			h:SetRelPos((nRadius + nRadius * math.cos(nRotate) + 2) * MY_Focus.fScaleY, (nRadius - 3 - 13.5 * math.sin(nRotate)) * MY_Focus.fScaleY)
			h:GetParent():FormatAllItemPos()
		end
	end
	---------- 右侧 ----------
	-- 名字
	hItem:Lookup('Handle_R/Handle_LMN/Text_Name'):SetText(szName or KObject.dwID)
	-- 血量
	if dwType == TARGET.DOODAD then
		hItem:Lookup('Handle_R/Handle_LMN/Image_Health'):SetPercentage(1)
		hItem:Lookup('Handle_R/Handle_LMN/Text_Health'):SetText('')
		hItem:Lookup('Handle_R/Handle_LMN/Image_Mana'):SetPercentage(1)
		hItem:Lookup('Handle_R/Handle_LMN/Text_Mana'):SetText('')
	else
		local fCurrentLife, fMaxLife = X.GetCharacterLife(tMemberInfo or KObject)
		local nCurrentMana, nMaxMana = tMemberInfo and tMemberInfo.nCurrentMana or KObject.nCurrentMana, tMemberInfo and tMemberInfo.nMaxMana or KObject.nMaxMana
		local szLife = X.FormatNumberDot(fCurrentLife, 1)
		if fMaxLife > 0 then
			local nPercent = math.floor(fCurrentLife / fMaxLife * 100)
			if nPercent > 100 then
				nPercent = 100
			end
			szLife = szLife .. '(' .. nPercent .. '%)'
			hItem:Lookup('Handle_R/Handle_LMN/Image_Health'):SetPercentage(fCurrentLife / fMaxLife)
			hItem:Lookup('Handle_R/Handle_LMN/Text_Health'):SetText(szLife)
		end
		if nMaxMana > 0 then
			hItem:Lookup('Handle_R/Handle_LMN/Image_Mana'):SetPercentage(nCurrentMana / nMaxMana)
			hItem:Lookup('Handle_R/Handle_LMN/Text_Mana'):SetText(X.FormatNumberDot(nCurrentMana, 1) .. '/' .. X.FormatNumberDot(nMaxMana, 1))
		end
	end
	-- 读条
	if dwType ~= TARGET.DOODAD then
		local nType, dwSkillID, dwSkillLevel, fProgress = X.GetCharacterOTActionState(KObject)
		if (nType == X.CONSTANT.CHARACTER_OTACTION_TYPE.ACTION_SKILL_PREPARE
			or nType == X.CONSTANT.CHARACTER_OTACTION_TYPE.ACTION_SKILL_CHANNEL
			or nType == X.CONSTANT.CHARACTER_OTACTION_TYPE.ANCIENT_ACTION_PREPARE)
		and dwSkillID and dwSkillLevel then
			hItem:Lookup('Handle_R/Handle_Progress/Image_Progress'):SetPercentage(fProgress or 0)
			hItem:Lookup('Handle_R/Handle_Progress/Text_Progress'):SetText(X.GetSkillName(dwSkillID, dwSkillLevel) or '')
		else
			hItem:Lookup('Handle_R/Handle_Progress/Image_Progress'):SetPercentage(0)
			hItem:Lookup('Handle_R/Handle_Progress/Text_Progress'):SetText('')
		end
	end
	-- 目标的目标
	if MY_Focus.bShowTarget and dwType ~= TARGET.DOODAD then
		local tp, id = KObject.GetTarget()
		local tar = X.GetTargetHandle(tp, id)
		if tar then
			hItem:Lookup('Handle_R/Handle_Progress/Text_Target'):SetText(X.GetTargetName(tp, id))
		else
			hItem:Lookup('Handle_R/Handle_Progress/Text_Target'):SetText('')
		end
	end
	-- 精耐
	local nSpirit, nMaxSpirit = X.GetCharacterSpirit(KObject)
	local nEndurance, nMaxEndurance = X.GetCharacterEndurance(KObject)
	if nSpirit and nMaxSpirit and nEndurance and nMaxEndurance then
		hItem:Lookup('Handle_SpiritEndurance/Handle_SpiritEndurance_Taichi/Animate_SpiritEndurance_Taichi_SpiritBar'):SetAnimateType(ANIMATE.BOTTOM_TOP)
		hItem:Lookup('Handle_SpiritEndurance/Handle_SpiritEndurance_Taichi/Animate_SpiritEndurance_Taichi_SpiritBar'):SetPercentage(nSpirit / nMaxSpirit)
		hItem:Lookup('Handle_SpiritEndurance/Handle_SpiritEndurance_Taichi/Animate_SpiritEndurance_Taichi_EnduranceBar'):SetAnimateType(ANIMATE.BOTTOM_TOP)
		hItem:Lookup('Handle_SpiritEndurance/Handle_SpiritEndurance_Taichi/Animate_SpiritEndurance_Taichi_EnduranceBar'):SetPercentage(nEndurance / nMaxEndurance)
		hItem:Lookup('Handle_SpiritEndurance/Handle_SpiritEndurance_Number/Handle_SpiritNum/Text_Spirit_Num'):SetText(nSpirit)
		hItem:Lookup('Handle_SpiritEndurance/Handle_SpiritEndurance_Number/Handle_EnduranceNum/Text_Endurance_Num'):SetText(nEndurance)
		hItem:Lookup('Handle_SpiritEndurance'):Show()
	else
		hItem:Lookup('Handle_SpiritEndurance'):Hide()
	end
	-- 选中状态
	hItem:Lookup('Image_Select'):Hide()
	if player then
		local dwTargetType, dwTargetID = player.GetTarget()
		if dwTargetType == dwType and dwTargetID == dwID then
			hItem:Lookup('Image_Select'):Show()
		end
	end
	hItem:FormatAllItemPos()
end

-- 更新列表
local NAVIGATOR_CACHE = {}
function D.UpdateList(frame)
	l_lockInDisplay = false
	local nCount = 0
	local tKeep = {}
	local hList = frame:Lookup('', 'Handle_List')
	local aList = D.GetDisplayList()
	for i = 1, hList:GetItemCount() do
		local p = aList[i]
		local hItem = hList:Lookup(i - 1)
		if p then
			if not hItem:IsVisible() then
				hItem:Show()
			end
			D.UpdateItem(hItem, p)
			if MY_Focus.bEnableSceneNavi and Navigator_SetID then
				local szKey = 'MY_FOCUS.' .. p.dwType .. '_' .. p.dwID
				local szText = p.tRule and p.tRule.szDisplay ~= '' and X.ReplaceSensitiveWord(p.tRule.szDisplay) or p.szName
				if NAVIGATOR_CACHE[szKey] ~= szText then
					Navigator_SetID(szKey, p.dwType, p.dwID, szText)
				end
				tKeep[szKey] = szText
			end
			nCount = nCount + 1
		elseif hItem:IsVisible() then
			hItem:Hide()
		end
	end
	if frame.nCount ~= nCount then
		D.AutosizeUI(frame)
		frame.nCount = nCount
	end
	if Navigator_Remove then
		for szKey, _ in pairs(NAVIGATOR_CACHE) do
			if not tKeep[szKey] then
				Navigator_Remove(szKey)
			end
		end
	end
	NAVIGATOR_CACHE = tKeep
end

-- ########################################################################## --
--                                     #                 #         #          --
--                           # # # # # # # # # # #       #   #     #          --
--   # #     # # # # # # #       #     #     #         #     #     #          --
--     #     #       #           # # # # # # #         #     # # # # # # #    --
--     #     #       #                 #             # #   #       #          --
--     #     #       #         # # # # # # # # #       #           #          --
--     #     #       #                 #       #       #           #          --
--     #     #       #       # # # # # # # # # # #     #   # # # # # # # #    --
--     #     #       #                 #       #       #           #          --
--       # #     # # # # #     # # # # # # # # #       #           #          --
--                                     #               #           #          --
--                                   # #               #           #          --
-- ########################################################################## --
-- 周期重绘
function D.OnFrameBreathe()
	if not D.IsShielded() then
		if l_dwLockType and l_dwLockID and l_lockInDisplay then
			local me = X.GetClientPlayer()
			local dwType, dwID = X.GetCharacterTarget(me)
			if dwType ~= l_dwLockType or dwID ~= l_dwLockID then
				X.SetClientPlayerTarget(l_dwLockType, l_dwLockID)
			end
		end
		if MY_Focus.bSortByDistance then
			D.SortFocus()
		end
	end
	D.UpdateList(this)
end

function D.OnFrameCreate()
	this:RegisterEvent('PARTY_SET_MARK')
	this:RegisterEvent('UI_SCALED')
	this:RegisterEvent('PLAYER_ENTER_SCENE')
	this:RegisterEvent('NPC_ENTER_SCENE')
	this:RegisterEvent('DOODAD_ENTER_SCENE')
	this:RegisterEvent('PLAYER_LEAVE_SCENE')
	this:RegisterEvent('NPC_LEAVE_SCENE')
	this:RegisterEvent('DOODAD_LEAVE_SCENE')
	this:RegisterEvent('MY_SET_IMPORTANT_NPC')
	this:RegisterEvent('MY_FOCUS_LOCK_UPDATE')
	this:RegisterEvent('MY_FOCUS_SCALE_UPDATE')
	this:RegisterEvent('MY_FOCUS_MAX_DISPLAY_UPDATE')
	this:RegisterEvent('MY_FOCUS_AUTO_HIDE_UPDATE')
	this:RegisterEvent('MY_FOCUS_MINIMIZE_UPDATE')
	this:Lookup('', 'Text_Title'):SetText(_L['Focus list'])

	D.Scale(this)
	D.CreateList(this)
	D.OnEvent('UI_SCALED')
	D.RescanNearby()
end

function D.OnFrameDestroy()
	if Navigator_Remove then
		for szKey, _ in pairs(NAVIGATOR_CACHE) do
			Navigator_Remove(szKey)
		end
		NAVIGATOR_CACHE = {}
	end
end

function D.OnEvent(event)
	if event == 'PARTY_SET_MARK' then
		D.UpdateList(this)
	elseif event == 'UI_SCALED' then
		X.UI(this):Anchor(MY_Focus.anchor)
	elseif event == 'PLAYER_ENTER_SCENE' then
		D.OnObjectEnterScene(TARGET.PLAYER, arg0)
	elseif event == 'NPC_ENTER_SCENE' then
		D.OnObjectEnterScene(TARGET.NPC, arg0)
	elseif event == 'DOODAD_ENTER_SCENE' then
		D.OnObjectEnterScene(TARGET.DOODAD, arg0)
	elseif event == 'PLAYER_LEAVE_SCENE' then
		D.OnObjectLeaveScene(TARGET.PLAYER, arg0)
	elseif event == 'NPC_LEAVE_SCENE' then
		D.OnObjectLeaveScene(TARGET.NPC, arg0)
	elseif event == 'DOODAD_LEAVE_SCENE' then
		D.OnObjectLeaveScene(TARGET.DOODAD, arg0)
	elseif event == 'MY_SET_IMPORTANT_NPC' then
		D.RescanNearby()
	elseif event == 'MY_FOCUS_LOCK_UPDATE' then
		D.UpdateList(this)
	elseif event == 'MY_FOCUS_SCALE_UPDATE' then
		D.Scale(this)
	elseif event == 'MY_FOCUS_MAX_DISPLAY_UPDATE' then
		D.CreateList(this)
	elseif event == 'MY_FOCUS_AUTO_HIDE_UPDATE' then
		D.AutosizeUI(this)
	elseif event == 'MY_FOCUS_MINIMIZE_UPDATE' then
		D.AutosizeUI(this)
	end
end

function D.OnFrameDragEnd()
	this:CorrectPos()
	MY_Focus.anchor = X.UI(this):Anchor('TOPRIGHT')
end

function D.OnFrameDragSetPosEnd()
	this:CorrectPos()
end

function D.OnItemMouseEnter()
	local name = this:GetName()
	if name == 'Handle_Info' then
		this:Lookup('Image_Hover'):Show()
		if MY_Focus.bHealHelper then
			local me = X.GetClientPlayer()
			TEMP_TARGET_TYPE, TEMP_TARGET_ID = X.GetCharacterTarget(me)
			X.SetClientPlayerTarget(this.dwType, this.dwID)
		end
		D.OnItemRefreshTip()
	end
end

function D.OnItemRefreshTip()
	local name = this:GetName()
	if name == 'Handle_Info' then
		local Rect
		if not MY_Focus.bShowTipRB then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			Rect = { x, y, w, h }
		end
		X.OutputObjectTip(Rect, this.dwType, this.dwID, GetFormatText(_L['Via:'] .. this.szVia .. '\n', 82))
	end
end

function D.OnItemMouseLeave()
	local name = this:GetName()
	if name == 'Handle_Info' then
		if this:Lookup('Image_Hover') then
			if MY_Focus.bHealHelper and TEMP_TARGET_TYPE and TEMP_TARGET_ID then
				X.SetClientPlayerTarget(TEMP_TARGET_TYPE, TEMP_TARGET_ID)
				TEMP_TARGET_TYPE, TEMP_TARGET_ID = nil
			end
			this:Lookup('Image_Hover'):Hide()
		end
	end
end

function D.OnItemLButtonClick()
	local name = this:GetName()
	if name == 'Handle_Info' then
		if MY_Focus.bHealHelper then
			TEMP_TARGET_TYPE, TEMP_TARGET_ID = nil
		end
		X.SetClientPlayerTarget(this.dwType, this.dwID)
	end
end

function D.OnItemRButtonClick()
	local name = this:GetName()
	if name == 'Handle_Info' then
		local dwType, dwID = this.dwType, this.dwID
		local t = X.InsertPlayerContextMenu({}, this:Lookup('Handle_R/Handle_LMN/Text_Name'):GetText(), dwID)
		if this.bDeletable then
			table.insert(t, 1, {
				szOption = _L['Delete focus'],
				fnAction = function()
					if l_dwLockType == dwType and l_dwLockID == dwID then
						l_dwLockType = nil
						l_dwLockID = nil
					end
					D.RemoveFocusID(dwType, dwID)
				end,
			})
		else
			table.insert(t, 1, {
				szOption = _L['Option'],
				fnAction = function()
					X.Panel.Show()
					X.Panel.Focus()
					X.Panel.SwitchTab('MY_Focus')
				end,
			})
		end
		table.insert(t, {
			szOption = _L['Copy information'],
			fnAction = function()
				local aText = {
					'Type: ' .. dwType,
					'ID: ' .. dwID,
				}
				local obj = X.GetTargetHandle(dwType, dwID)
				if obj then
					table.insert(aText, 'Name: ' .. X.GetTargetName(dwType, dwID))
					table.insert(aText, 'TemplateID: ' .. obj.dwTemplateID)
					table.insert(aText, 'Pos: ' .. '[' .. X.GetMapID() .. '] ' .. obj.nX .. ', ' .. obj.nY .. ', ' .. obj.nZ)
				end
				X.UI.OpenTextEditor((table.concat(aText, '\n')))
			end,
		})
		local bLock = dwType == l_dwLockType and dwID == l_dwLockID
		table.insert(t, {
			szOption = bLock and _L['Unlock focus'] or _L['Lock focus'],
			fnAction = function()
				if bLock then
					l_dwLockID = nil
					l_dwLockType = nil
				else
					l_dwLockID = dwID
					l_dwLockType = dwType
					X.SetClientPlayerTarget(dwType, dwID)
				end
				FireUIEvent('MY_FOCUS_LOCK_UPDATE')
			end,
		})
		PopupMenu(t)
	end
end

function D.OnLButtonClick()
	local name = this:GetName()
	if name == 'Btn_Setting' then
		X.Panel.Show()
		X.Panel.Focus()
		X.Panel.SwitchTab('MY_Focus')
	elseif name == 'Btn_Close' then
		D.Close()
	end
end

function D.OnCheckBoxCheck()
	local name = this:GetName()
	if name == 'CheckBox_Minimize' then
		MY_Focus.bMinimize = true
		FireUIEvent('MY_FOCUS_MINIMIZE_UPDATE')
	end
end

function D.OnCheckBoxUncheck()
	local name = this:GetName()
	if name == 'CheckBox_Minimize' then
		MY_Focus.bMinimize = false
		FireUIEvent('MY_FOCUS_MINIMIZE_UPDATE')
	end
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_FocusUI',
	exports = {
		{
			preset = 'UIEvent',
			fields = {
				'Open',
				'Close',
			},
			root = D,
		},
	},
}
MY_FocusUI = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_FocusUI', function()
	if MY_Focus.IsEnabled() then
		D.Open()
	else
		D.Close()
	end
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
