--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 聊天泡泡
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Chat/MY_TeamBalloon'
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_TeamBalloon'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.3') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------
local INI_PATH = X.PACKET_INFO.ROOT .. 'MY_Chat/ui/MY_TeamBalloon.ini'
local DISPLAY_TIME = 5000
local ANIMATE_SHOW_TIME = 500
local ANIMATE_HIDE_TIME = 500

local O = X.CreateUserSettingsModule(MODULE_NAME, _L['Chat'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_TeamBalloon'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}

local function AppendBalloon(hFrame, dwID, szMsg)
	if MY_ChatEmotion and MY_ChatEmotion.Render then
		szMsg = MY_ChatEmotion.Render(szMsg)
	end
	if MY_Farbnamen then
		szMsg = MY_Farbnamen.Render(szMsg)
	end
	local hTotal = hFrame:Lookup('', '')
	local hBalloon = hTotal:Lookup('Balloon_' .. dwID)
	if not hBalloon then
		hBalloon = hTotal:AppendItemFromIni(INI_PATH, 'Handle_Balloon', 'Balloon_' .. dwID)
		hBalloon.dwID = dwID
	end
	hBalloon.nTime = GetTime()
	local hContent = hBalloon:Lookup('Handle_Content')
	hContent:Show()
	hContent:Clear()
	hContent:SetSize(300, 131)
	hContent:AppendItemFromString(szMsg)
	hContent:FormatAllItemPos()
	hContent:SetSizeByAllItemSize()

	-- Adjust balloon size
	local w, h = hContent:GetSize()
	w, h = w + 20, h + 20
	local image1 = hBalloon:Lookup('Image_Bg1')
	image1:SetSize(w, h)
	local image2 = hBalloon:Lookup('Image_Bg2')
	image2:SetRelPos(math.min(w - 16 - 8, 32), h - 4)
	hBalloon:SetSize(10000, 10000)
	hBalloon:FormatAllItemPos()
	hBalloon:SetSizeByAllItemSize()

	-- Show balloon
	local hWnd = Station.Lookup('Normal/Teammate')
	local hContent = hBalloon:Lookup('Handle_Content')
	local x, y, w, h, _
	if hWnd and hWnd:IsVisible() then
		local hTotal = hWnd:Lookup('', '')
		local nCount = hTotal:GetItemCount()
		for i = 0, nCount - 1 do
			local hI = hTotal:Lookup(i)
			if hI.dwID == dwID then
				w, h = hContent:GetSize()
				x, y = hI:GetAbsPos()
				x, y = x + 205, y - h - 2
			end
		end
	elseif MY_CataclysmParty and MY_CataclysmParty.GetMemberHandle then
		local hTotal = MY_CataclysmParty.GetMemberHandle(dwID)
		if hTotal then
			_, h = hContent:GetSize()
			w, _ = hTotal:GetSize()
			x, y = hTotal:GetAbsPos()
			x, y = x + w, y - h - 2
		end
	end
	if x and y then
		hBalloon:SetRelPos(x, y)
		hBalloon:SetAbsPos(x, y)
	end
	hBalloon:SetAlpha(0)
	hFrame:BringToTop()
end


local function OnSay(hFrame, szMsg, dwID, nChannel)
	local player = X.GetClientPlayer()
	if player and player.dwID ~= dwID and (
		nChannel == PLAYER_TALK_CHANNEL.TEAM or
		nChannel == PLAYER_TALK_CHANNEL.RAID
	) and player.IsInParty() then
		local hTeam = GetClientTeam()
		if not hTeam then return end
		if hTeam.nGroupNum > 1 then
			return
		end
		local hGroup = hTeam.GetGroupInfo(0)
		for k, v in pairs(hGroup.MemberList) do
			if v == dwID then
				AppendBalloon(hFrame, dwID, szMsg, false)
			end
		end
	end
end

function D.OnFrameCreate()
	this:RegisterEvent('PLAYER_SAY')
end

function D.OnEvent(event)
	if event == 'PLAYER_SAY' then
		OnSay(this, arg0, arg1, arg2)
	end
end

function D.OnFrameBreathe()
	local hTotal = this:Lookup('', '')
	for i = 0, hTotal:GetItemCount() - 1 do
		local hBalloon = hTotal:Lookup(i)
		if hBalloon and hBalloon.nTime then
			local nTick = GetTime() - hBalloon.nTime
			if nTick <= ANIMATE_SHOW_TIME then
				hBalloon:SetAlpha(nTick / ANIMATE_SHOW_TIME * 255)
			elseif nTick >= ANIMATE_SHOW_TIME + DISPLAY_TIME + ANIMATE_HIDE_TIME then
				hTotal:RemoveItem(hBalloon)
			elseif nTick >= ANIMATE_SHOW_TIME + DISPLAY_TIME then
				hBalloon:SetAlpha((1 - (nTick - ANIMATE_SHOW_TIME - DISPLAY_TIME) / ANIMATE_HIDE_TIME) * 255)
			end
		end
	end
end

function D.Apply()
	local bEnable = O.bEnable
	if bEnable then
		X.UI.OpenFrame(INI_PATH, 'MY_TeamBalloon')
	else
		X.UI.CloseFrame('MY_TeamBalloon')
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	nX = nPaddingX
	ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 250,
		text = _L['team balloon'],
		checked = O.bEnable,
		onCheck = function(bChecked)
			O.bEnable = bChecked
			D.Apply()
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
	name = 'MY_TeamBalloon',
	exports = {
		{
			root = D,
			preset = 'UIEvent',
		},
		{
			fields = {
				OnPanelActivePartial = D.OnPanelActivePartial,
			},
		},
	},
}
MY_TeamBalloon = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_TeamBalloon', function()
	D.Apply()
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
