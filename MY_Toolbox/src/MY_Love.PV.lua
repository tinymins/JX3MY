--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 剑侠情缘设置界面
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_Love.PV'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Love'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------

local D = {
	FormatLoverString = MY_Love.FormatLoverString,
	GetPlayerInfo = MY_Love.GetPlayerInfo,
	RequestOtherLover = MY_Love.RequestOtherLover,
	GetOtherLover = MY_Love.GetOtherLover,
}
local O = {
	tActiveLove = {},
	tName2ID = {},
}

function D.CanSeeLovePage(dwPlayerID, szPlayerName)
	if MY_Love.IsShielded() then
		return false
	end
	if X.IS_CLASSIC and IsRemotePlayer(dwPlayerID) then
		return false
	end
	return true
end

-- 请求别人情缘数据
function D.PvRequestOtherLover(frame)
	local nX, nY = frame:GetAbsPos()
	local nW, nH = frame:GetSize()
	local pageset = frame:Lookup('Page_Main')
	return D.RequestOtherLover(pageset.dwPlayerID, nX + nW / 2, nY + nH / 3, function() return not Station.Lookup('Normal/PlayerView/Page_Main') end)
end

-- 更新情缘面板信息
function D.UpdatePage()
	local p = Station.Lookup('Normal/PlayerView/Page_Main/Page_Love')
	if not p then
		return
	end
	local tar = D.GetPlayerInfo(p:GetParent().dwPlayerID)
	if not tar then
		return p:GetRoot():Hide()
	end
	local h, t = p:Lookup('', ''), D.GetOtherLover(tar.szName)
	local bNoData, xID, szName, dwAvatar, szSign, dwForceID, nRoleType, nLoverType, nLoverTime, szLoverTitle = not t
	if t then
		xID = t.xID
		szName = t.szName
		dwAvatar = t.dwAvatar
		szSign = t.szSign
		dwForceID = t.dwForceID
		nRoleType = t.nRoleType
		nLoverType = t.nLoverType
		nLoverTime = t.nLoverTime
		szLoverTitle = t.szLoverTitle
	end
	h:Lookup('Text_LTitle'):SetText(_L('%s\'s lover', tar.szName))
	-- lover
	local txt = h:Lookup('Text_Lover')
	if bNoData then
		txt:SetText(_L['...Unknown...'])
	else
		txt:SetText(szName or _L['...Loading...'])
	end
	txt.szPlayer = szName
	-- lover title
	local ttl = h:Lookup('Text_LoverTitle')
	if bNoData or X.IsEmpty(szLoverTitle) then
		ttl:SetText('')
	else
		ttl:SetFontColor(255, 128, 255)
		ttl:SetText('<' .. szLoverTitle .. '>')
	end
	-- lover info
	local inf = h:Lookup('Text_LoverInfo')
	if nLoverType and nLoverTime and nLoverTime > 0 then
		inf:SetText(D.FormatLoverString('{$type}   {$time}', { nLoverType = nLoverType, nLoverTime = nLoverTime }))
	else
		inf:SetText('')
	end
	-- avatar
	local szFile, nFrame, bAnimate = X.GetPlayerAvatar(dwForceID, nRoleType, dwAvatar)
	local img, ani = h:Lookup('Image_Lover'), h:Lookup('Animate_Lover')
	if xID == 0 or xID == '0' or X.IsEmpty(szFile) then
		img:Hide()
		ani:Hide()
		txt:SetRelPos(42, 92)
		txt:SetSize(300, 25)
		txt:SetHAlign(1)
	else
		if bAnimate then
			ani:SetAnimate(szFile, nFrame)
			--ani:SetAnimateType(ANIMATE.FLIP_HORIZONTAL)
			ani:Show()
			img:Hide()
		else
			if nFrame < 0 then
				img:FromTextureFile(szFile)
			else
				img:FromUITex(szFile, nFrame)
			end
			if nFrame == -2 then
				img:SetImageType(IMAGE.NORMAL)
			else
				img:SetImageType(IMAGE.FLIP_HORIZONTAL)
			end
			ani:Hide()
			img:Show()
		end
		if bNoData or X.IsEmpty(szLoverTitle) then
			txt:SetRelPos(130, 92)
			inf:SetRelPos(130, 115)
		else
			txt:SetRelPos(130, 82)
			ttl:SetRelPos(130, 105)
			inf:SetRelPos(130, 128)
		end
		txt:SetSize(200, 25)
		txt:SetHAlign(0)
	end
	ani.szPlayer = szName
	img.szPlayer = szName
	-- sign title
	h:Lookup('Text_SignTTL'):SetText(bNoData and '' or _L('%s\'s Love signature:', tar.szName))
	-- sign
	if bNoData then
		szSign = _L['No peer lover data yet, you must request first.']
	elseif not szSign then
		szSign = _L['If it is always loading, the target may not install plugin or turn on quiet mode, strongly recommend to query after team up.']
	elseif szSign == '' then
		szSign = _L['This guy is very lazy, nothing left!']
	end
	h:Lookup('Text_Sign'):SetText(szSign)
	-- btn
	local txt = p:Lookup('Btn_LoveYou'):Lookup('', 'Text_LoveYou')
	if bNoData then
		txt:SetText(_L['Request lover data'])
	elseif tar.nGender == 2 then
		txt:SetText(_L['Strike up her'])
	else
		txt:SetText(_L['Strike up him'])
	end
	h:FormatAllItemPos()
end
X.RegisterEvent('MY_LOVE_OTHER_UPDATE', D.UpdatePage)

function D.GetPlayerViewTargetBaseInfo()
	local mPage = Station.Lookup('Normal/PlayerView/Page_Main')
	local txtName = mPage and mPage:Lookup('Page_Battle', 'Text_PlayerName')
	if not txtName then
		txtName = Station.Lookup('Normal/PersonalCard_ShowData/Wnd_Card/Wnd_Information', 'Handle_Player/Text_Name')
	end
	if not txtName then
		return
	end
	local szName = txtName:GetText()
	local dwID = O.tName2ID[szName]
	local hWnd = Station.Lookup('Normal/PersonalCard_ShowData/Wnd_Card')
	if hWnd and hWnd.szGlobalID then
		local kTarget = MY_Love.GetNearbyPlayerByXID(hWnd.szGlobalID)
		if kTarget then
			szName = kTarget.szName
			dwID = O.tName2ID[szName] or dwID
		end
		local tFellowship = X.GetFellowshipInfo(hWnd.szGlobalID)
		local tFei = tFellowship and X.GetFellowshipEntryInfo(tFellowship.xID)
		if tFei then
			szName = tFei.szName
			dwID = O.tName2ID[szName] or dwID
		end
	end
	return dwID, szName
end

-- 查看别人装备、情缘
function D.HookPlayerViewPanel()
	local mPage = Station.Lookup('Normal/PlayerView/Page_Main')
	local dwID, szName = D.GetPlayerViewTargetBaseInfo()
	if not dwID or not szName then
		return
	end
	-- 常驻时钟监听角色名刷新 防止过快获取错误信息
	X.BreatheCall('MY_Love__PV__HookPlayerViewPanel', function()
		local dwCurrentID, szCurrentName = D.GetPlayerViewTargetBaseInfo()
		if dwCurrentID and szCurrentName then
			if dwCurrentID ~= dwID or szCurrentName ~= szName then
				D.HookPlayerViewPanel()
			end
			return
		end
		X.BreatheCall('MY_Love__PV__HookPlayerViewPanel', false)
	end, 200)
	local bHook = MY_Love.bHookPlayerView and dwID and D.CanSeeLovePage(dwID, szName)
	-- attach page
	if bHook then
		if not mPage.bMYLoved then
			local frame = X.UI.OpenFrame(PLUGIN_ROOT .. '\\ui\\MY_Love.ini', 'MY_Love_TempFrame')
			local pageset = frame:Lookup('Page_Main')
			local checkbox = pageset:Lookup('CheckBox_Love')
			local page = pageset:Lookup('Page_Love')
			-- 计算checkbox的X值
			local chk = mPage:GetFirstChild()
			local aX, nW, nY = {}, 78, 510
			while chk do
				if chk:GetType() == 'WndCheckBox' then
					table.insert(aX, chk:GetRelX())
					nW = chk:GetW()
					nY = chk:GetRelY()
				end
				chk = chk:GetNext()
			end
			table.sort(aX, function(a, b) return b < a end)
			local nX = #aX > 1 and (aX[1] - aX[2] + aX[1]) or 270
			checkbox:ChangeRelation(mPage, true, true)
			page:ChangeRelation(mPage, true, true)
			X.UI.CloseFrame(frame)
			checkbox:SetRelPos(nX, nY)
			checkbox:SetW(nW)
			checkbox:Lookup('', 'Text_LoveCaptical'):SetW(nW)
			if X.UI.IS_GLASSMORPHISM then
				page:SetH(500)
				page:Lookup('', 'Handle_ClassicBg'):Hide()
				page:Lookup('', 'Image_LIcon'):Hide()
				page:Lookup('', 'Text_LTitle'):SetRelY(3)
				X.UI.AdaptComponentAppearance(page:Lookup('Btn_LoveYou'))
			end
			-- 计算page的X值
			local nX = 0
			local hPageBattle = mPage:Lookup('Wnd_PageBattle', '')
			if hPageBattle then
				nX = hPageBattle:GetRelX()
			end
			page:SetRelPos(nX, 0)
			mPage:AddPage(page, checkbox)
			checkbox:Show()
			mPage.bMYLoved = true
			-- events
			mPage.OnActivePage = function()
				if this:GetActivePage():GetName() == 'Page_Love' then
					D.UpdatePage()
					D.PvRequestOtherLover(this:GetRoot())
				end
				PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
				return X.UI.FormatUIEventMask(true, true)
			end
			page:Lookup('Btn_LoveYou').OnLButtonClick = function()
				local mp = this:GetParent():GetParent()
				if D.GetOtherLover(mp.szPlayerName) then
					local tar = D.GetPlayerInfo(mp.dwPlayerID)
					if tar then
						X.SendChat(tar.szName, MY_Love.szJabber)
					end
				else
					D.PvRequestOtherLover(this:GetRoot())
				end
			end
			page:Lookup('Btn_LoveYou').OnRButtonClick = function()
				local mp = this:GetParent():GetParent()
				local tar = D.GetPlayerInfo(mp.dwPlayerID)
				if tar then
					local m0, me = {}, X.GetClientPlayer()
					InsertInviteTeamMenu(m0, tar.szName)
					if me.IsInParty() and me.dwID == GetClientTeam().GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) then
						InsertMarkMenu(m0, tar.dwID)
					end
					if me.IsInParty() and me.IsPlayerInMyParty(tar.dwID) then
						InsertTeammateLeaderMenu(m0, tar.dwID)
					end
					if #m0 > 0 then
						table.insert(m0, { bDevide = true })
					end
					InsertPlayerCommonMenu(m0, tar.dwID, tar.szName)
					PopupMenu(m0)
				end
			end
			page:Lookup('', 'Image_Lover').OnItemRButtonDown = function()
				if this.szPlayer then
					local m0 = {}
					InsertPlayerCommonMenu(m0, 0, this.szPlayer)
					PopupMenu(m0)
				end
			end
			page:Lookup('', 'Text_Lover').OnItemRButtonDown = page:Lookup('', 'Image_Lover').OnItemRButtonDown
			page:Lookup('', 'Animate_Lover').OnItemRButtonDown = page:Lookup('', 'Image_Lover').OnItemRButtonDown
			page:Lookup('', 'Text_LTitle'):SetText(_L['Lover'])
			page:Lookup('', 'Text_SignTTL'):SetText(_L['Love signature:'])
			page:Lookup('', 'Text_Lover'):SetFontColor(255, 128, 255)
			checkbox:Lookup('', 'Text_LoveCaptical'):SetText(_L['Lover'])
		end
		-- update page
		mPage.dwPlayerID = dwID
		mPage.szPlayerName = szName
		-- active page
		if O.tActiveLove[dwID] then
			O.tActiveLove[dwID] = nil
			mPage:ActivePage('Page_Love')
		end
	elseif not bHook and mPage.bMYLoved then
		local frame = X.UI.OpenFrame(PLUGIN_ROOT .. '\\ui\\MY_Love.ini', 'MY_Love')
		local pageset = frame:Lookup('Page_Main')
		local checkbox = mPage:Lookup('CheckBox_Love')
		local page = mPage:Lookup('Page_Love')
		pageset:AddPage(page, checkbox)
		checkbox:ChangeRelation(pageset, true, true)
		page:ChangeRelation(pageset, true, true)
		X.UI.CloseFrame(frame)
		mPage.dwPlayerID = nil
		mPage.szPlayerName = nil
		mPage.bMYLoved = nil
	end
end

function D.CheckHookPlayerViewPanel()
	D.HookPlayerViewPanel()
	X.DelayCall(500, D.HookPlayerViewPanel)
	X.DelayCall(1000, D.HookPlayerViewPanel)
	X.DelayCall(2000, D.HookPlayerViewPanel)
end

function D.OnPeekOtherPlayer()
	local nResult, dwPlayerID = arg0, arg1
	if nResult ~= 1 then
		return
	end
	local tar = X.GetPlayer(dwPlayerID)
	if not tar then
		return
	end
	if not D.CanSeeLovePage(dwPlayerID, tar.szName) then
		return
	end
	if X.IS_REMAKE then
		local szGlobalID = tar.GetGlobalID()
		local tFei = X.GetFellowshipEntryInfo(szGlobalID)
		if tFei then
			O.tName2ID[tFei.szName] = dwPlayerID
		else
			O.tName2ID[tar.szName] = dwPlayerID
		end
	else
		O.tName2ID[tar.szName] = dwPlayerID
	end
	D.CheckHookPlayerViewPanel()
end
X.RegisterEvent('PEEK_OTHER_PLAYER', 'MY_Love__PV', D.OnPeekOtherPlayer)
X.RegisterFrameCreate('PlayerView', 'MY_Love__PV', D.CheckHookPlayerViewPanel)
X.RegisterFrameCreate('PersonalCard_ShowData', 'MY_Love__PV', D.CheckHookPlayerViewPanel)

X.RegisterEvent('PLAYER_LEAVE_SCENE', function()
	if arg0 == UI_GetClientPlayerID() then
		O.tName2ID = {}
	end
end)

function D.OnActiveLoveChange()
	O.tActiveLove[arg0] = arg1 and true or nil
end
X.RegisterEvent('MY_LOVE_PV_ACTIVE_CHANGE', D.OnActiveLoveChange)

function D.OnPVHookChange()
	D.CheckHookPlayerViewPanel()
end
X.RegisterEvent('MY_LOVE_PV_HOOK', D.OnPVHookChange)

-- view other lover by dwID
function D.PeekOther(dwID)
	MY_Love.bHookPlayerView = true
	O.tActiveLove[dwID] = true
	X.ViewOtherPlayerByID(dwID)
end

-- add target menu
do
local function onMenu(dwTarType, dwTarID)
	if MY_Love.IsShielded() then
		return
	end
	if dwTarType ~= TARGET.PLAYER or dwTarID == X.GetClientPlayerID() or IsRemotePlayer(dwTarID) then
		return
	end
	return {{
		szOption = _L['View love info'],
		fnAction = function() D.PeekOther(dwTarID) end
	}}
end
X.RegisterTargetAddonMenu('MY_Love', onMenu)
end

-- close player view when reload
X.RegisterReload('MY_Love', function() X.UI.CloseFrame('PlayerView') end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
