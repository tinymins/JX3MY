--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 游戏环境库
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) MY
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/lib/Game.KObject.Doodad')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. 'lang/lib/')
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 交互物件
--------------------------------------------------------------------------------

-- 打开一个拾取交互物件（当前帧重复调用仅打开一次防止庖丁）
function X.OpenDoodad(me, doodad)
	X.Throttle(X.NSFormatString('{$NS}#OpenDoodad') .. doodad.dwID, 375, function()
		--[[#DEBUG BEGIN]]
		X.OutputDebugMessage('Open Doodad ' .. doodad.dwID .. ' [' .. doodad.szName .. '] at ' .. GetLogicFrameCount() .. '.', X.DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		OpenDoodad(me, doodad)
	end)
end

-- 交互一个拾取交互物件（当前帧重复调用仅交互一次防止庖丁）
function X.InteractDoodad(dwID)
	X.Throttle(X.NSFormatString('{$NS}#InteractDoodad') .. dwID, 375, function()
		--[[#DEBUG BEGIN]]
		X.OutputDebugMessage('Open Doodad ' .. dwID .. ' at ' .. GetLogicFrameCount() .. '.', X.DEBUG_LEVEL.LOG)
		--[[#DEBUG END]]
		InteractDoodad(dwID)
	end)
end

-- 获取掉落拾取金钱数量
---@param dwDoodadID number @掉落拾取ID
---@return number @掉落拾取金钱数量
function X.GetDoodadLootMoney(dwDoodadID)
	if X.IS_REMAKE then
		local me = X.GetClientPlayer()
		local scene = me and me.GetScene()
		return scene and scene.GetLootMoney(dwDoodadID)
	else
		local me = X.GetClientPlayer()
		local scene = me and me.GetScene()
		return scene and scene.GetLootMoney(dwDoodadID)
	end
end

-- 获取掉落拾取物品数量
---@param dwDoodadID number @掉落拾取ID
---@return number @掉落拾取物品数量
function X.GetDoodadLootItemCount(dwDoodadID)
	if X.IS_REMAKE then
		local me = X.GetClientPlayer()
		local scene = me and me.GetScene()
		local tLoot = scene and scene.GetLootList(dwDoodadID)
		return tLoot and tLoot.nItemCount or nil
	else
		local me = X.GetClientPlayer()
		local scene = me and me.GetScene()
		local tLoot = scene and scene.GetLootList(dwDoodadID)
		return tLoot and tLoot.nItemCount or nil
	end
end

-- 获取掉落拾取物品
---@param dwDoodadID number @掉落拾取ID
---@return KItem,boolean,boolean,boolean @掉落拾取物品,是否需要Roll点,是否需要分配,是否需要拍卖
function X.GetDoodadLootItem(dwDoodadID, nIndex)
	if X.IS_REMAKE then
		local me = X.GetClientPlayer()
		local scene = me and me.GetScene()
		local tLoot = scene and scene.GetLootList(dwDoodadID)
		local it = tLoot and tLoot[nIndex - 1]
		if it then
			local bNeedRoll = it.LootType == X.CONSTANT.LOOT_ITEM_TYPE.NEED_ROLL
			local bDist = it.LootType == X.CONSTANT.LOOT_ITEM_TYPE.NEED_DISTRIBUTE
			local bBidding = it.LootType == X.CONSTANT.LOOT_ITEM_TYPE.NEED_BIDDING
			return it.Item, bNeedRoll, bDist, bBidding
		end
	else
		local me = X.GetClientPlayer()
		local scene = me and me.GetScene()
		local tLoot = scene and scene.GetLootList(dwDoodadID)
		local it = tLoot and tLoot[nIndex - 1]
		if it then
			local bNeedRoll = it.LootType == X.CONSTANT.LOOT_ITEM_TYPE.NEED_ROLL
			local bDist = it.LootType == X.CONSTANT.LOOT_ITEM_TYPE.NEED_DISTRIBUTE
			local bBidding = it.LootType == X.CONSTANT.LOOT_ITEM_TYPE.NEED_BIDDING
			return it.Item, bNeedRoll, bDist, bBidding
		end
	end
end

-- 分配掉落拾取物品
---@param dwDoodadID number @掉落拾取ID
---@param dwItemID number @掉落物品ID
---@param dwTargetPlayerID number @被分配者ID
function X.DistributeDoodadItem(dwDoodadID, dwItemID, dwTargetPlayerID)
	if X.IS_REMAKE then
		local me = X.GetClientPlayer()
		local scene = me and me.GetScene()
		if scene then
			scene.DistributeItem(dwDoodadID, dwItemID, dwTargetPlayerID)
		end
	else
		local me = X.GetClientPlayer()
		local scene = me and me.GetScene()
		if scene then
			scene.DistributeItem(dwDoodadID, dwItemID, dwTargetPlayerID)
		end
	end
end

-- 获取掉落可拾取玩家列表
---@param dwDoodadID number @掉落拾取ID
---@return number[] @可拾取玩家列表
function X.GetDoodadLooterList(dwDoodadID)
	if X.IS_REMAKE then
		local me = X.GetClientPlayer()
		local scene = me and me.GetScene()
		if scene then
			return scene.GetLooterList(dwDoodadID)
		end
	else
		local me = X.GetClientPlayer()
		local scene = me and me.GetScene()
		if scene then
			return scene.GetLooterList(dwDoodadID)
		end
	end
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
