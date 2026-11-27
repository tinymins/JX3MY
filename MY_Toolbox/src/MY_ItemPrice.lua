--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 物品价格查询
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_ItemPrice'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
X.RegisterRestriction('MY_ItemPrice', { ['*'] = false })
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_ItemPrice', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_ItemPrice'],
			_L['Enable'],
		}),
		szRestriction = 'MY_ItemPrice',
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	nW = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_ItemPrice'],
			_L['UI Width'],
		}),
		szRestriction = 'MY_ItemPrice',
		xSchema = X.Schema.Number,
		xDefaultValue = 480,
	},
	nH = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_ItemPrice'],
			_L['UI Height'],
		}),
		szRestriction = 'MY_ItemPrice',
		xSchema = X.Schema.Number,
		xDefaultValue = 640,
	},
})
local D = {}

function D.OnWebSizeChange()
	if X.UI(this):FrameVisualState() == X.UI.FRAME_VISUAL_STATE.NORMAL then
		O.nW, O.nH = this:GetSize()
	end
end

function D.Open(dwTabType, dwTabIndex, nBookID)
	if nBookID < 0 then
		nBookID = nil
	end
	local szName = X.GetItemInfoName(dwTabType, dwTabIndex, nBookID)
	if not szName then
		return
	end
	local me = X.GetClientPlayer()
	local line = X.GetHLLineInfo({ dwMapID = me.GetMapID(), nCopyIndex = me.GetScene().nCopyIndex })
	local aPath = {dwTabType, dwTabIndex}
	if nBookID then
		table.insert(aPath, nBookID)
	end
	local szURL = MY_RSS.PAGE_BASE_URL .. '/item/' .. table.concat(aPath, '/') .. '/price?'
		.. X.EncodeQuerystring(X.ConvertToUTF8({
			l = X.ENVIRONMENT.GAME_LANG,
			L = X.ENVIRONMENT.GAME_EDITION,
			server = line and line.szCenterName or X.GetServerOriginName(),
			player = X.GetClientPlayerName(),
			item = szName,
		}))
	local szKey = 'ItemPrice_' .. table.concat(aPath, '_')
	local szTitle = szName
	szKey = X.UI.OpenBrowser(szURL, {
		key = szKey,
		title = szTitle,
		w = O.nW, h = O.nH,
		readonly = true,
	})
	X.UI(X.UI.LookupBrowser(szKey)):Size(D.OnWebSizeChange)
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	if not X.IsRestricted('MY_ItemPrice') then
		nX = nX + ui:Append('WndCheckBox', {
			x = nX, y = nY, w = 'auto',
			text = _L['Item price'],
			checked = MY_ItemPrice.bEnable,
			onCheck = function(bChecked)
				if bChecked then
					local ui = X.UI(this)
					X.Confirm(_L['Check this will show price entry in bag item menu, and will share price when search auction, are you sure?'], function()
						MY_ItemPrice.bEnable = bChecked
						ui:Check(true, WNDEVENT_FIRETYPE.PREVENT)
					end)
					ui:Check(false, WNDEVENT_FIRETYPE.PREVENT)
				else
					MY_ItemPrice.bEnable = bChecked
				end
			end,
			tip = {
				render = _L['Hold SHIFT and r-click bag box to show item price, share price when search auction.'],
				position = X.UI.TIP_POSITION.BOTTOM_TOP,
			},
		}):Width() + 5
	end
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_ItemPrice',
	exports = {
		{
			fields = {
				'Open',
				'OnPanelActivePartial',
			},
			root = D,
		},
		{
			fields = {
				'bEnable',
				'nW',
				'nH',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bEnable',
				'nW',
				'nH',
			},
			root = O,
		},
	},
}
MY_ItemPrice = X.CreateModule(settings)
end

Box_AppendAddonMenu({function(box)
	if not X.IsElement(box) or box:GetType() ~= 'Box' or not O.bEnable then
		return
	end
	local _, dwBox, dwX = box:GetObjectData()
	if not dwBox or not dwX then
		return
	end
	local item = X.GetInventoryItem(X.GetClientPlayer(), dwBox, dwX)
	if not item then
		return
	end
	local dwTabType = item.dwTabType
	local dwTabIndex = item.dwIndex
	local nBookID = item.nGenre == ITEM_GENRE.BOOK and item.nBookID or -1
	local menu = {}
	if not item.bBind then
		table.insert(menu, {
			szOption = _L['Lookup price'],
			fnAction = function() D.Open(dwTabType, dwTabIndex, nBookID) end,
		})
	elseif X.CONSTANT.FLOWERS_UIID[item.nUiId] then
		table.insert(menu, {
			szOption = _L['Lookup flower price'],
			fnAction = function() D.Open(dwTabType, dwTabIndex, nBookID) end,
		})
	end
	return menu
end})

local function GetItemKey(it)
	if it.nGenre == ITEM_GENRE.BOOK then
		return X.NumberBaseN(it.dwTabType, 32) .. '_'
			.. X.NumberBaseN(it.dwIndex, 32) .. '_'
			.. X.NumberBaseN(it.nBookID, 32)
	end
	return X.NumberBaseN(it.dwTabType, 32) .. '_' .. X.NumberBaseN(it.dwIndex, 32)
end
local PRICE_TYPE = X.KvpToObject({
	{ X.CONSTANT.AUCTION_ITEM_LIST_TYPE.NORMAL_LOOK_UP, 'n' },
	{ X.CONSTANT.AUCTION_ITEM_LIST_TYPE.PRICE_LOOK_UP , 'p' },
	{ X.CONSTANT.AUCTION_ITEM_LIST_TYPE.DETAIL_LOOK_UP, 'd' },
})
X.RegisterEvent('AUCTION_LOOKUP_RESPOND', function()
	if not O.bEnable then
		return
	end
	if arg0 ~= AUCTION_RESPOND_CODE.SUCCEED then
		return
	end
	local szPriceType = PRICE_TYPE[arg1]
	if szPriceType then
		-- 获取数据
		local AuctionClient = GetAuctionClient()
		local nInfoCount, aInfo = AuctionClient.GetLookupResult(arg1)
		local dwBaseID = math.huge
		local tItemGroup = {}
		-- AuctionClient.GetLookupResult
		--
		-- ## CLASSIC ##
		-- {
		-- 	BidderName = "",
		-- 	BuyItNowPrice = { nGold = 0, nSilver = 3, nCopper = 0 },
		-- 	CanBid = 1,
		-- 	CRC = -1544935104,
		-- 	ID = 11612492,
		-- 	Item = "KGItem:000001D4B0EC0BB0",
		-- 	LeftTime = 36277,
		-- 	Price = { nGold = 0, nSilver = 3, nCopper = 0 },
		-- 	SellerName = "白玉糖",
		-- }
		--
		-- ## REMAKE ##
		-- {
		-- 	CRC = 1459347857,
		-- 	ID = 741069789,
		-- 	Item = "KGItem:00000234A2D47170",
		-- 	LastDurationTime = 48,
		-- 	LeftTime = 1556,
		-- 	Price = { nGold = 0, nSilver = 1, nCopper = 0 },
		-- 	SellerName = "奶糖睡不醒",
		-- 	SellerNum = 14,
		-- 	StackNum = 4318,
		-- }
		for _, info in ipairs(aInfo) do
			local szKey = GetItemKey(info.Item)
			local nID = info.ID or 0
			if nID < 0 then
				nID = nID + 0xffffffff
			end
			local tPrice = info.BuyItNowPrice or info.Price
			local nPrice = tPrice.nGold * 10000 + tPrice.nSilver * 100 + tPrice.nCopper
			local nCount = info.StackNum or X.IIf(info.Item.bCanStack, info.Item.nStackNum, 1) or 1
			if not tItemGroup[szKey] then
				tItemGroup[szKey] = {}
			end
			table.insert(tItemGroup[szKey], {
				dwID = nID,
				nCount = nCount,
				nPrice = nPrice,
			})
			dwBaseID = math.min(dwBaseID, nID)
		end
		if X.IsHugeNumber(dwBaseID) then
			return
		end
		local aData = {}
		-- 重组数据
		for szKey, aItemInfo in pairs(tItemGroup) do
			-- 价格升序
			table.sort(aItemInfo, function(a, b)
				return a.nPrice < b.nPrice
			end)
			-- 价格序列化
			local aPrice = {}
			for i, v in ipairs(aItemInfo) do
				-- 压缩数据长度，仅第一个为32进制价格，后面的为与前一个的价格差
				if i == 1 then
					aPrice[i] = X.NumberBaseN(v.nPrice, 32)
				else
					aPrice[i] = X.NumberBaseN(v.nPrice - aItemInfo[i - 1].nPrice, 32)
				end
				aPrice[i] = aPrice[i] .. '_' .. X.NumberBaseN(v.nCount, 32) .. '_' .. X.NumberBaseN(v.dwID - dwBaseID, 32)
			end
			table.insert(aData, szKey .. '-' .. table.concat(aPrice, '-'))
		end
		local data = {
			l = X.ENVIRONMENT.GAME_LANG,
			L = X.ENVIRONMENT.GAME_EDITION,
			r = X.GetRegionOriginName(),
			s = X.GetServerOriginName(),
			t = GetCurrentTime(),
			d = table.concat(aData, '~'), -- Price data
			dt = szPriceType, -- Price type
			ib = X.NumberBaseN(dwBaseID, 32),
		}
		-- 延迟一帧 否则系统还没更新界面数据
		X.DelayCall(function()
			local bValid = false
			-- CLASSIC
			if not bValid then
				bValid = true
				local frame = Station.SearchFrame('AuctionPanel')
				-- 保证第一页
				local txtPage = frame and frame:Lookup('PageSet_Totle/Page_Business/Wnd_Result2', 'Text_Page')
				if not txtPage or txtPage:GetText():find('1-', nil, true) ~= 1 then
					bValid = false
				end
				-- 保证一口价升序
				local imgPriceUp = frame and frame:Lookup('PageSet_Totle/Page_Business/Wnd_Result2/CheckBox_Price', 'Image_PriceNameUp')
				if not imgPriceUp or not imgPriceUp:IsVisible() then
					bValid = false
				end
			end
			-- REMAKE
			if not bValid then
				bValid = true
				-- 总搜索页
				if szPriceType == 'n' then
					local frame = Station.SearchFrame('AuctionPanel')
					-- 保证第一页
					local txtPage = frame and frame:Lookup('TradingPage_Totle/Page_Business/Wnd_Result/Wnd_MN_Item/Edit_PageNumb')
					if not txtPage or txtPage:GetText() ~= '1' then
						bValid = false
					end
					-- 保证一口价升序
					local imgPriceUp = frame and frame:Lookup('TradingPage_Totle/Page_Business/Wnd_Result/CheckBox_LowestPrice', 'Image_LowestPriceUp')
					if not imgPriceUp or not imgPriceUp:IsVisible() then
						bValid = false
					end
				elseif szPriceType == 'p' then
					local frame = Station.SearchFrame('TradingPanels')
					-- 保证第一页
					local txtPage = frame and frame:Lookup('Wnd_subject/Wnd_List/Wnd_MN_Item', 'Text_MNumberItem')
					if not txtPage or txtPage:GetText():find('1/', nil, true) ~= 1 then
						bValid = false
					end
					-- 保证一口价升序
					local imgPriceUp = frame and frame:Lookup('Wnd_subject/Wnd_List/CheckBox_LowestPrice', 'Image_LowestPriceUp')
					if not imgPriceUp or not imgPriceUp:IsVisible() then
						bValid = false
					end
				elseif szPriceType == 'd' then
					local frame = Station.SearchFrame('TradingSellers')
					-- 保证第一页
					local txtPage = frame and frame:Lookup('Wnd_List/Wnd_MN_Item/Edit_PageNumb')
					if not txtPage or txtPage:GetText() ~= '1' then
						bValid = false
					end
					-- 保证一口价升序
					local imgPriceUp = frame and frame:Lookup('Wnd_List/CheckBox_LowestPrice', 'Image_LowestPriceUp')
					if not imgPriceUp or not imgPriceUp:IsVisible() then
						bValid = false
					end
				end
			end
			if not bValid then
				return
			end
			X.Ajax({ url = MY_RSS.PUSH_BASE_URL .. '/api/item/price', data = data, signature = X.SECRET['J3CX::ITEM_PRICE'] })
		end)
	end
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
