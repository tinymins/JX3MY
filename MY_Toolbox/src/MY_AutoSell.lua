--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 自动售出物品
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_AutoSell'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.5') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_AutoSell', _L['General'], {
	bEnable = { -- 打开商店后自动售出总开关,
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoSell'],
			_L['Auto sell when open shop'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bSellGray = { -- 自动出售灰色物品,
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoSell'],
			_L['Sell grey items'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bSellWhiteBook = { -- 自动出售已读白书,
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoSell'],
			_L['Sell read white books'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bSellGreenBook = { -- 自动出售已读绿书,
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoSell'],
			_L['Sell read green books'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bSellBlueBook = { -- 自动出售已读蓝书,
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoSell'],
			_L['Sell read blue books'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	tSellItem = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoSell'],
			_L['Auto sell by name'],
		}),
		xSchema = X.Schema.Map(X.Schema.String, X.Schema.Boolean),
		xDefaultValue = {
			[X.GetItemInfoName(5, 2863)] = true, -- 银叶子
			[X.GetItemInfoName(5, 2864)] = true, -- 真银叶子
			[X.GetItemInfoName(5, 2865)] = true, -- 大片真银叶子
			[X.GetItemInfoName(5, 2866)] = true, -- 金粉末
			[X.GetItemInfoName(5, 2867)] = true, -- 金叶子
			[X.GetItemInfoName(5, 2868)] = true, -- 大片金叶子
			[X.GetItemInfoName(5, 11682)] = true, -- 金条
			[X.GetItemInfoName(5, 11683)] = true, -- 金块
			[X.GetItemInfoName(5, 11640)] = true, -- 金砖
			[X.GetItemInfoName(5, 17130)] = true, -- 银叶子·试炼之地
			[X.GetItemInfoName(5, 22974)] = true, -- 破碎的金玄玉
		},
	},
	tProtectItem = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoSell'],
			_L['Protect specified items'],
		}),
		xSchema = X.Schema.Map(X.Schema.String, X.Schema.Boolean),
		xDefaultValue = {
			[X.GetItemInfoName(5, 789)] = true, -- 真丝肚兜
			[X.GetItemInfoName(5, 797)] = true, -- 春宫图册
		},
	},
})
local D = {}

RegisterCustomData('MY_AutoSell.tSellItem')
RegisterCustomData('MY_AutoSell.tProtectItem')

function D.SellItem(nNpcID, nShopID, dwBox, dwX, nCount, szReason, szName, nUiId)
	if X.IS_CLASSIC then
		local shopinfo = GetShop(nShopID)
		if not shopinfo or shopinfo.dwNpcID == nil or shopinfo.dwNpcID ~= nNpcID then
			return
		end
	end
	local me = X.GetClientPlayer()
	local item = X.GetInventoryItem(me, dwBox, dwX)
	if not item or item.nUiId ~= nUiId then
		return
	end
	SellItem(nNpcID, nShopID, dwBox, dwX, nCount)
	X.OutputSystemMessage(_L('Auto sell %s item: %s.', szReason, szName))
end

-- 自动售出物品
function D.AutoSellItem(nNpcID, nShopID, bIgnoreGray)
	if X.IsSafeLocked(SAFE_LOCK_EFFECT_TYPE.EQUIP) then
		return
	end
	local me = X.GetClientPlayer()
	local aSell = {}
	for _, dwBox in ipairs(X.GetInventoryBoxList(X.CONSTANT.INVENTORY_TYPE.PACKAGE)) do
		for dwX = 0, X.GetInventoryBoxSize(dwBox) - 1 do
			local item = X.GetInventoryItem(me, dwBox, dwX)
			if item and item.bCanTrade then
				local bSell, szReason = false, ''
				local szName = X.GetItemName(item.dwID)
				if not O.tProtectItem[szName] then
					if item.nQuality == 0 and O.bSellGray and not bIgnoreGray then
						bSell = true
						szReason = _L['Gray item']
					end
					if not bSell and O.tSellItem[szName] then
						bSell = true
						szReason = _L['Specified']
					end
					if not bSell and item.nGenre == ITEM_GENRE.BOOK and me.IsBookMemorized(X.RecipeToSegmentID(item.nBookID)) then
						if O.bSellWhiteBook and item.nQuality == 1 then
							bSell = true
							szReason = _L['Read white book']
						elseif O.bSellGreenBook and item.nQuality == 2 then
							bSell = true
							szReason = _L['Read green book']
						elseif O.bSellBlueBook and item.nQuality == 3 then
							bSell = true
							szReason = _L['Read blue book']
						end
					end
				end
				if bSell then
					local nCount = 1
					if item.nGenre == ITEM_GENRE.EQUIPMENT and item.nSub == EQUIPMENT_SUB.ARROW then --远程武器
						nCount = item.nCurrentDurability
					elseif item.bCanStack then
						nCount = item.nStackNum
					end
					local r, g, b = GetItemFontColorByQuality(item.nQuality)
					local sell = {
						nNpcID = nNpcID, nShopID = nShopID, dwBox = dwBox, dwX = dwX, nCount = nCount,
						szReason = szReason, szName = szName, nUiId = item.nUiId, r = r, g = g, b = b,
					}
					table.insert(aSell, sell)
				end
			end
		end
	end
	table.sort(aSell, function(a, b)
		if a.szReason == b.szReason then
			return a.nUiId > b.nUiId
		end
		return a.szReason > b.szReason
	end)
	if #aSell > 0 then
		local aXML, szReason = {}
		table.insert(aXML, GetFormatText(_L['Confirm auto sell?']))
		table.insert(aXML, X.CONSTANT.XML_LINE_BREAKER)
		for _, v in ipairs(aSell) do
			if v.szReason ~= szReason then
				table.insert(aXML, X.CONSTANT.XML_LINE_BREAKER)
				table.insert(aXML, GetFormatText(v.szReason .. g_tStrings.STR_CHINESE_MAOHAO))
				szReason = v.szReason
			end
			table.insert(aXML, X.CONSTANT.XML_LINE_BREAKER)
			table.insert(aXML, GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE .. '['.. v.szName ..']', 166, v.r, v.g, v.b))
			table.insert(aXML, GetFormatText(' x' .. v.nCount))
		end
		table.insert(aXML, X.CONSTANT.XML_LINE_BREAKER)
		table.insert(aXML, X.CONSTANT.XML_LINE_BREAKER)
		table.insert(aXML, GetFormatText(_L['Some items may not be able to buy back once you sell it, and there is also a limit number rule by official, change auto sell rules in plugin if you want.']))
		local nW, nH = Station.GetClientSize()
		local tMsg = {
			x = nW / 2, y = nH / 3,
			szName = 'MY_AutoSell__Confirm',
			szMessage = table.concat(aXML),
			bRichText = true,
			szAlignment = 'CENTER',
			{
				szOption = g_tStrings.STR_HOTKEY_SURE,
				fnAction = function()
					for _, v in ipairs(aSell) do
						D.SellItem(v.nNpcID, v.nShopID, v.dwBox, v.dwX, v.nCount, v.szReason, v.szName, v.nUiId)
					end
				end,
			}, { szOption = g_tStrings.STR_HOTKEY_CANCEL },
		}
		MessageBox(tMsg)
	end
end

function D.CheckEnable()
	if O.bEnable then
		X.RegisterEvent('SHOP_OPENSHOP', 'MY_AutoSell', function()
			if X.IS_CLASSIC then
				local shopinfo = GetShop(arg0)
				if not shopinfo or shopinfo.dwNpcID == nil then
					return
				end
				-- Portable shops use NPC ID 0, which is valid for SellItem.
				local chk = Station.Lookup('Normal/ShopPanel/Wnd_Right/CheckBox_AutoSell')
				local bIgnoreGray = chk and chk:IsCheckBoxChecked() or false
				D.AutoSellItem(shopinfo.dwNpcID, arg0, bIgnoreGray)
			else
				local chk = Station.Lookup('Normal/ShopPanel/CheckBox_AutoSell')
				local bIgnoreGray = chk and chk:IsCheckBoxChecked() or false
				D.AutoSellItem(arg4, arg0, bIgnoreGray)
			end
		end)
	else
		X.RegisterEvent('SHOP_OPENSHOP', 'MY_AutoSell', false)
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Auto sell items'],
		checked = O.bEnable,
		onCheck = function(bChecked)
			O.bEnable = bChecked
			D.CheckEnable()
		end,
		tip = {
			render = _L['Auto sell when open shop'],
			position = X.UI.TIP_POSITION.TOP_BOTTOM,
		},
	}):Width() + 5

	-- 按类型出售
	nX = nX + ui:Append('WndComboBox', {
		x = nX, y = nY, w = 'auto', h = 24,
		text = _L['Auto sell by type'],
		menu = function()
			local m0 = {
				{
					szOption = _L['Sell grey items'],
					bCheck = true, bChecked = O.bSellGray,
					fnAction = function(d, b) O.bSellGray = b end,
				},
				{
					szOption = _L['Sell read white books'],
					bCheck = true, bChecked = O.bSellWhiteBook,
					fnAction = function(d, b) O.bSellWhiteBook = b end,
				},
				{
					szOption = _L['Sell read green books'], bCheck = true, bChecked = O.bSellGreenBook,
					fnAction = function(d, b) O.bSellGreenBook = b end,
				},
				{
					szOption = _L['Sell read blue books'], bCheck = true, bChecked = O.bSellBlueBook,
					fnAction = function(d, b) O.bSellBlueBook = b end,
				},
			}
			return m0
		end,
		autoEnable = function() return O.bEnable end,
	}):Width() + 5

	-- 按名称出售
	nX = nX + ui:Append('WndComboBox', {
		x = nX, y = nY, w = 'auto', h = 24,
		text = _L['Auto sell by name'],
		menu = function()
			local m1 = {
				{
					szOption = _L['* New *'],
					fnAction = function()
						GetUserInput(_L['Name of item'], function(szText)
							local szText = string.gsub(szText, '^%s*%[?(.-)%]?%s*$', '%1')
							if szText ~= '' then
								O.tSellItem[szText] = true
								O.tSellItem = O.tSellItem
							end
						end)
					end
				},
				{ bDevide = true },
			}
			local m2 = { bInline = true, nMaxHeight = 550 }
			for k, v in pairs(O.tSellItem) do
				table.insert(m2, {
					szOption = k, bCheck = true, bChecked = v, fnAction = function(d, b) O.tSellItem[k] = b end,
					{
						szOption = _L['Remove'],
						fnAction = function()
							O.tSellItem[k] = nil
							O.tSellItem = O.tSellItem
							for i, v in ipairs(m2) do
								if v.szOption == k then
									table.remove(m2, i)
									break
								end
							end
							return 0
						end,
					},
				})
			end
			table.insert(m1, m2)
			return m1
		end,
		autoEnable = function() return O.bEnable end,
	}):Width() + 5

	-- 保护不被出售的物品
	nX = nX + ui:Append('WndComboBox', {
		x = nX, y = nY, w = 'auto', h = 24,
		text = _L['Protect specified items'],
		menu = function()
			local m1 = {
				{
					szOption = _L['* New *'],
					fnAction = function()
						GetUserInput(_L['Name of item'], function(szText)
							local szText = string.gsub(szText, '^%s*%[?(.-)%]?%s*$', '%1')
							if szText ~= '' then
								O.tProtectItem[szText] = true
								O.tProtectItem = O.tProtectItem
							end
						end)
					end
				},
				{ bDevide = true },
			}
			local m2 = { bInline = true, nMaxHeight = 550 }
			for k, v in pairs(O.tProtectItem) do
				table.insert(m2, {
					szOption = k, bCheck = true, bChecked = v, fnAction = function(d, b) O.tProtectItem[k] = b end,
					{
						szOption = _L['Remove'],
						fnAction = function()
							O.tProtectItem[k] = nil
							O.tProtectItem = O.tProtectItem
							for i, v in ipairs(m2) do
								if v.szOption == k then
									table.remove(m2, i)
									break
								end
							end
							return 0
						end,
					},
				})
			end
			table.insert(m1, m2)
			return m1
		end,
		autoEnable = function() return O.bEnable end,
	}):Width() + 5

	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_AutoSell',
	exports = {
		{
			fields = {
				'tSellItem',
				'tProtectItem',
				'OnPanelActivePartial',
			},
			root = D,
		},
	},
	imports = {
		{
			fields = {
				'tSellItem',
				'tProtectItem',
			},
			root = D,
		},
	},
}
MY_AutoSell = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_AutoSell', function()
	for _, k in ipairs({'tSellItem', 'tProtectItem'}) do
		if D[k] then
			X.SafeCall(X.Set, O, k, D[k])
			D[k] = nil
		end
	end
	D.CheckEnable()
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
