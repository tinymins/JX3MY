--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 背包新物品
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_BagEx/MY_BagEx_BagNewItem'
local PLUGIN_NAME = 'MY_BagEx'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_BagEx_BagNewItem'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.1') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------

local O = X.CreateUserSettingsModule(MODULE_NAME, _L['General'], {
	bNewToBottom = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_BagEx'],
		szDescription = X.MakeCaption({
			_L['Bag new item'],
			_L['Put new bag item to bottom'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bAvoidLock = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_BagEx'],
		szDescription = X.MakeCaption({
			_L['Bag new item'],
			_L['Avoid locked bag box'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bIgnoreNewStackItem = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_BagEx'],
		szDescription = X.MakeCaption({
			_L['Bag new item'],
			_L['Ignore exist item'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}
local INVENTORY_CACHE = {}
local BAG_ITEM_CACHE = {}
local EQUIP_ITEM_CACHE = {}
local NEW_ITEM_FLAG_TIME = {}
local EXCHANGE_BOX_TIME = {}

function D.ShowNewItemFlag(dwBox, dwX)
	local frame = Station.Lookup('Normal/BigBagPanel')
	if not frame then
		return
	end
	for _, szPath in ipairs({
		'Handle_Bag_Compact/Mode_' .. dwBox .. '_' .. dwX .. '/' .. dwBox .. '_' .. dwX,
		'Handle_Bag_Normal/Handle_Bag' .. dwBox .. '/Handle_Bag_Content' .. dwBox .. '/Mode_' .. dwX .. '/' .. dwBox .. '_' .. dwX
	}) do
		local box = frame:Lookup('', szPath)
		if box then
			box:SetObjectInUse(true)
		end
	end
end

function D.CreateBagItemCache()
	BAG_ITEM_CACHE = {}
	X.IterInventoryItem(X.CONSTANT.INVENTORY_TYPE.PACKAGE, function(kItem, dwBox, dwX)
		if kItem then
			INVENTORY_CACHE[dwBox .. '_' .. dwX] = {
				szKey = X.GetItemKey(kItem),
				nStackNum = (kItem.bCanStack and kItem.nStackNum or 1),
			}
			BAG_ITEM_CACHE[kItem.dwID] = kItem.bCanStack and kItem.nStackNum or 1
		end
	end)
	EQUIP_ITEM_CACHE = {}
	X.IterInventoryItem(X.CONSTANT.INVENTORY_TYPE.EQUIP, function(kItem, dwBox, dwX)
		if kItem then
			EQUIP_ITEM_CACHE[kItem.dwID] = kItem.bCanStack and kItem.nStackNum or 1
		end
	end)
end

function D.OnBagItemUpdate(dwBox, dwX)
	-- Only process items in regular package boxes, skip special packages (e.g., NEARLY_DYING_PACKAGE)
	local aPackageBoxList = X.GetInventoryBoxList(X.CONSTANT.INVENTORY_TYPE.PACKAGE)
	local bInPackage = false
	for _, dwIterBox in ipairs(aPackageBoxList) do
		if dwIterBox == dwBox then
			bInPackage = true
			break
		end
	end
	if not bInPackage then
		D.CreateBagItemCache() -- still refresh cache to keep it in sync
		return
	end
	local me = X.GetClientPlayer()
	local kItem = X.GetInventoryItem(me, dwBox, dwX)
	if kItem then
		local szItemKey = X.GetItemKey(kItem)
		local nStackNum = kItem.bCanStack and kItem.nStackNum or 1
		local tInventoryItemInfo = INVENTORY_CACHE[dwBox .. '_' .. dwX]
		local bNewItem = (not BAG_ITEM_CACHE[kItem.dwID]) and (not tInventoryItemInfo or tInventoryItemInfo.szKey ~= szItemKey)
		local bFromEquip = EQUIP_ITEM_CACHE[kItem.dwID]
		local bNewStack = (BAG_ITEM_CACHE[kItem.dwID] and BAG_ITEM_CACHE[kItem.dwID] ~= nStackNum)
			or (tInventoryItemInfo and tInventoryItemInfo.szItemKey == szItemKey and tInventoryItemInfo.nStackNum ~= nStackNum)
		if (not bNewItem and (not bNewStack or O.bIgnoreNewStackItem)) or bFromEquip then
			local bNewFlag = NEW_ITEM_FLAG_TIME[kItem.dwID] and NEW_ITEM_FLAG_TIME[kItem.dwID] > GetCurrentTime()
			if bNewFlag or bNewStack or bFromEquip then
				D.ShowNewItemFlag(dwBox, dwX)
			end
		elseif O.bNewToBottom then
			local dwExcBox, dwExcX
			for _, dwIterBox in ipairs(X.GetInventoryBoxList(X.CONSTANT.INVENTORY_TYPE.PACKAGE)) do
				for dwIterX = 0, X.GetInventoryBoxSize(dwIterBox) - 1 do
					if (
						(
							not X.GetInventoryItem(me, dwIterBox, dwIterX)
							and ((EXCHANGE_BOX_TIME[dwIterBox .. ',' .. dwIterX] or 0) < GetCurrentTime())
						)
						or (dwIterBox == dwBox and dwIterX == dwX)
					)
					and (
						not MY_BagEx_Bag.IsItemBoxLocked(dwIterBox, dwIterX)
						or not O.bAvoidLock
					) then
						dwExcBox, dwExcX = dwIterBox, dwIterX
					end
				end
			end
			if dwExcBox and dwExcX and (dwExcBox ~= dwBox or dwExcX ~= dwX) then
				EXCHANGE_BOX_TIME[dwExcBox .. ',' .. dwExcX] = GetCurrentTime() + 1 -- 保证一秒内不同时交换两个物品到同一个格子导致失败
				NEW_ITEM_FLAG_TIME[kItem.dwID] = GetCurrentTime() + 5 -- 五秒内始终认为该物品为新物品
				--[[#DEBUG BEGIN]]
				X.OutputDebugMessage('MY_BagEx_BagNewItem', 'ExchangeItem: ' .. dwBox .. ',' .. dwX .. ' <-> ' .. dwExcBox .. ',' .. dwExcX, X.DEBUG_LEVEL.LOG)
				--[[#DEBUG END]]
				X.ExchangeInventoryItem(dwBox, dwX, dwExcBox, dwExcX)
			else
				--[[#DEBUG BEGIN]]
				X.OutputDebugMessage('MY_BagEx_BagNewItem', 'NotExchangeItem: ' .. dwBox .. ',' .. dwX, X.DEBUG_LEVEL.LOG)
				--[[#DEBUG END]]
				D.ShowNewItemFlag(dwBox, dwX)
			end
		end
	end
	D.CreateBagItemCache()
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 200,
		text = _L['Put new bag item to bottom'],
		checked = O.bNewToBottom,
		onCheck = function(bChecked)
			O.bNewToBottom = bChecked
		end,
	}):AutoWidth():Width() + 5
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 200,
		text = _L['Avoid locked bag box'],
		checked = O.bAvoidLock,
		onCheck = function(bChecked)
			O.bAvoidLock = bChecked
		end,
	}):AutoWidth():Width() + 5
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 200,
		text = _L['Ignore exist item'],
		checked = O.bIgnoreNewStackItem,
		onCheck = function(bChecked)
			O.bIgnoreNewStackItem = bChecked
		end,
	}):AutoWidth():Width() + 5
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_BagEx_BagNewItem',
	exports = {
		{
			fields = {
				OnPanelActivePartial = D.OnPanelActivePartial,
			},
		},
	},
}
MY_BagEx_BagNewItem = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterEvent('BAG_ITEM_UPDATE', 'MY_BagEx_BagNewItem', function()
	local dwBox, dwX, bNew = arg0, arg1, arg2
	D.OnBagItemUpdate(dwBox, dwX)
end)

X.RegisterInit('MY_BagEx_BagNewItem', function()
	D.CreateBagItemCache()
end)

X.RegisterFrameDestroy('BigBagPanel', 'MY_BagEx_BagNewItem', function()
	NEW_ITEM_FLAG_TIME = {}
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
