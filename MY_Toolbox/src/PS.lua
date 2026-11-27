--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 常用工具
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/PS'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------

do
local TARGET_TYPE, TARGET_ID
local function onHotKey()
	if TARGET_TYPE then
		X.SetClientPlayerTarget(TARGET_TYPE, TARGET_ID)
		TARGET_TYPE, TARGET_ID = nil
	else
		local me = X.GetClientPlayer()
		TARGET_TYPE, TARGET_ID = X.GetCharacterTarget(me)
		X.SetClientPlayerTarget(TARGET.PLAYER, X.GetClientPlayerID())
	end
end
X.RegisterHotKey('MY_AutoLoopMeAndTarget', _L['Loop target between me and target'], onHotKey)
end

local PS = { nPriority = 0 }
function PS.OnPanelActive(wnd)
	local ui = X.UI(wnd)
	local nPaddingX, nPaddingY = 25, 25
	local nW, nH = ui:Size()
	local nX, nY = nPaddingX, nPaddingY
	local nLH = 28

	-- 目标
	nX = nPaddingX
	nY = nY + ui:Append('Text', { x = nX, y = nY, h = 'auto', text = _L['Target'], color = {255, 255, 0} }):Height() + 5
	nX = nX + 10
	nX, nY = MY_FooterTip.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	-- 战斗
	nX = nPaddingX
	nY = nY + ui:Append('Text', { x = nX, y = nY, h = 'auto', text = _L['Battle'], color = {255, 255, 0} }):Height() + 5
	nX = nX + 10
	nX, nY = MY_VisualSkill.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_DynamicActionBarPos.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_ArenaHelper.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = nPaddingX + 10, nY + nLH
	nX, nY = MY_ShenxingHelper.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	-- 其他
	nX = nPaddingX
	nY = nY + ui:Append('Text', { x = nX, y = nY, h = 'auto', text = _L['Others'], color = {255, 255, 0} }):Height() + 5
	nX = nX + 10
	nX, nY = MY_AchievementWiki.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_PetWiki.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_QuestWiki.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_RideWiki.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_ItemWiki.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_ItemPrice.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_YunMacro.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	nX, nY = nPaddingX + 10, nY + nLH
	nX, nY = MY_AutoDiamond.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)

	nX, nY = nPaddingX + 10, nY + nLH
	nX, nY = MY_HideAnnounceBg.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = MY_FriendTipLocation.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	nX, nY = nPaddingX + 10, nY + nLH
	nX, nY = MY_Domesticate.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	nX, nY = MY_Memo.OnPanelActivePartial(ui, nPaddingX + 10, nPaddingY, nW, nH, nX, nY, nLH)

	nX, nY = MY_AutoSell.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	nX, nY = nPaddingX + 10, nY + nLH
	nX, nY = MY_DynamicItem.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)

	-- 右侧浮动
	MY_GongzhanCheck.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	MY_LockFrame.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
end
X.Panel.Register(_L['General'], 'MY_Toolbox', _L['MY_Toolbox'], 134, PS)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
