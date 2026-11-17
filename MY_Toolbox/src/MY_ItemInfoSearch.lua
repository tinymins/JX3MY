local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_ItemInfoSearch'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_ItemInfoSearch'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
X.RegisterRestriction('MY_ItemInfoSearch', { ['*'] = false, exp = true })
--------------------------------------------------------------------------------
local CACHE = {}
local ITEM_TYPE_MAX, BOOK_SEGMENT_COUNT, SEARCH_STEP_COUNT
local SEARCH, RESULT, MAX_DISP = '', {}, 500
local D = {}

function D.Init()
	if not ITEM_TYPE_MAX then
		ITEM_TYPE_MAX = {}
		local dwTabType = 1
		while 1 do
			local nMaxL = 100      -- 折半查找左端数值
			local nMaxR = 3000     -- 折半查找右端数值
			local item = GetItemInfo(dwTabType, nMaxL)
			if item then
				if not ITEM_TYPE_MAX[dwTabType] then
					local bMaxL = GetItemInfo(dwTabType, nMaxL) -- 折半查找左端结果
					local bMaxR = GetItemInfo(dwTabType, nMaxR) -- 折半查找右端结果
					local nCount, nMaxCount = 0, 1000 -- 折半次数统计 1000次折半查找还没找到多半是BUG了 判断上限防止死循环
					while true do
						if nMaxL < 1 then
							--[[#DEBUG BEGIN]]
							X.OutputDebugMessage(_L['MY_ItemInfoSearch'], 'ERROR CALC ITEM_TYPE_MAX: ' .. dwTabType .. ' (TOO SMALL)', X.DEBUG_LEVEL.ERROR)
							--[[#DEBUG END]]
							break
						elseif bMaxL and bMaxR then
							nMaxR = nMaxR * 2
							bMaxR = GetItemInfo(dwTabType, nMaxR)
						elseif not bMaxL and not bMaxR then
							nMaxL = math.floor(nMaxL / 2)
							bMaxL = GetItemInfo(dwTabType, nMaxL)
						else
							if bMaxL and not bMaxR then
								if nMaxL + 1 == nMaxR then
									ITEM_TYPE_MAX[dwTabType] = nMaxL
									break
								else
									local nCur = math.floor(nMaxR - (nMaxR - nMaxL) / 2)
									local bCur = GetItemInfo(dwTabType, nCur)
									if bCur then
										nMaxL = nCur
									else
										nMaxR = nCur
									end
								end
							elseif not bMaxL and bMaxR then
								--[[#DEBUG BEGIN]]
								X.OutputDebugMessage(_L['MY_ItemInfoSearch'], 'ERROR CALC ITEM_TYPE_MAX: ' .. dwTabType .. ' (NOT EXIST)', X.DEBUG_LEVEL.ERROR)
								--[[#DEBUG END]]
								break
							end
						end
						if nCount >= nMaxCount then
							--[[#DEBUG BEGIN]]
							X.OutputDebugMessage(_L['MY_ItemInfoSearch'], 'ERROR CALC ITEM_TYPE_MAX: ' .. dwTabType .. ' (OVERFLOW)', X.DEBUG_LEVEL.ERROR)
							--[[#DEBUG END]]
							break
						end
						nCount = nCount + 1
					end
				end
			elseif dwTabType > 20 then
				break
			end
			dwTabType = dwTabType + 1
		end
		-- 总查找步数 用于进度条
		local BookSegment = X.GetGameTable('BookSegment', true)
		BOOK_SEGMENT_COUNT = BookSegment and BookSegment:GetRowCount() or 0
		SEARCH_STEP_COUNT = 0
		for _, nMaxIndex in pairs(ITEM_TYPE_MAX) do
			SEARCH_STEP_COUNT = SEARCH_STEP_COUNT + nMaxIndex
		end
		SEARCH_STEP_COUNT = SEARCH_STEP_COUNT + BOOK_SEGMENT_COUNT
	end
end

function D.StopSearch()
	X.BreatheCall('MY_ItemInfoSearch', false)
end

function D.DoRawSearch(szSearch, fnProgress, fnCallback)
	local aResult = {}
	if szSearch == '' then
		fnCallback(aResult)
		return
	end
	local dwID = tonumber(szSearch)
	-- 构建分段搜索步骤
	local dwTabType, dwIndex, nRound = next(ITEM_TYPE_MAX), 1, 0
	local function SearchStep()
		nRound = nRound + 1
		if dwTabType then
			local itemInfo = GetItemInfo(dwTabType, dwIndex)
			if itemInfo and (
				dwIndex == dwID
				or (itemInfo.nGenre ~= ITEM_GENRE.BOOK and X.StringFindW(X.GetItemNameByItemInfo(itemInfo), szSearch))
				or X.StringFindW(itemInfo.szName, szSearch)
			) then
				table.insert(aResult, {
					dwTabType = dwTabType,
					dwIndex = dwIndex,
					itemInfo = itemInfo,
				})
				if #aResult >= MAX_DISP then
					return true
				end
			end
			if dwIndex < ITEM_TYPE_MAX[dwTabType] then
				dwIndex = dwIndex + 1
			else
				dwTabType = next(ITEM_TYPE_MAX, dwTabType)
				dwIndex = 1
			end
		else
			local BookSegment = X.GetGameTable('BookSegment', true)
			local row = BookSegment and BookSegment:GetRow(dwIndex)
			local dwRecipeID = row and X.SegmentToRecipeID(row.dwBookID, row.dwSegmentID)
			if dwRecipeID and X.RecipeToSegmentID(dwRecipeID) then
				local itemInfo = GetItemInfo(5, row.dwBookItemIndex)
				if itemInfo and (
					dwID == itemInfo.dwID or dwID == dwRecipeID
					or dwID == row.dwBookID or dwID == row.dwSegmentID
					or X.StringFindW(X.GetItemNameByItemInfo(itemInfo, dwRecipeID), szSearch)
				) then
					table.insert(aResult, {
						dwTabType = 5,
						dwIndex = row.dwBookItemIndex,
						itemInfo = itemInfo,
						dwRecipeID = dwRecipeID,
					})
					if #aResult >= MAX_DISP then
						return true
					end
				end
			end
			if dwIndex < BOOK_SEGMENT_COUNT then
				dwIndex = dwIndex + 1
			else
				return true
			end
		end
	end
	local function SearchBreathe()
		local nTime = GetTime()
		while GetTime() - nTime < 50 do
			for _ = 1, 100 do
				if SearchStep() then
					fnCallback(aResult)
					D.StopSearch()
					return
				end
			end
			fnProgress(nRound / SEARCH_STEP_COUNT)
		end
	end
	X.BreatheCall('MY_ItemInfoSearch', SearchBreathe)
end

function D.Search(szSearch, fnProgress, fnCallback)
	-- 搜索缓存
	for _, v in ipairs(CACHE) do
		if v.szSearch == szSearch then
			fnCallback(v.aResult)
			return
		end
	end
	-- 计算结果
	D.DoRawSearch(szSearch, fnProgress, function(aResult)
		if #CACHE > 20 then
			table.remove(CACHE, 1)
		end
		table.insert(CACHE, { szSearch = szSearch, aResult = aResult })
		fnCallback(aResult)
	end)
end

local PS = { nPriority = 4, szRestriction = 'MY_ItemInfoSearch' }

function PS.OnPanelActive(wnd)
	local ui = X.UI(wnd)
	local nPaddingX, nPaddingY = 0, 0
	local nX, nY = nPaddingX, nPaddingY
	local nW, nH = ui:Size()

	local list, muProgress
	local function UpdateList()
		list:ListBox('clear')
		if X.IsEmpty(SEARCH) then
			for i, s in ipairs(_L['MY_ItemInfoSearch TIPS']) do
				list:ListBox('insert', { id = 'TIP' .. i, text = s, r = 255, g = 255, b = 0 })
			end
		else
			for _, item in ipairs(RESULT) do
				local opt = {
					id = item,
					text = ' [' .. X.GetItemNameByItemInfo(item.itemInfo, item.dwRecipeID) .. '] - ' .. item.itemInfo.szName,
					data = item,
				}
				opt.r, opt.g, opt.b = GetItemFontColorByQuality(item.itemInfo.nQuality, false)
				list:ListBox('insert', opt)
			end
			list:ListBox('insert', { id = 'count', text = _L('Max display count %d, current %d.', MAX_DISP, #RESULT), r = 100, g = 100, b = 100 })
		end
	end

	nY = nY + ui:Append('WndEditBox', {
		x = nX, y = nY, w = nW - nX, h = 25,
		text = SEARCH,
		placeholder = _L['Please input item name or item index number'],
		onChange = function(szSearch)
			X.DelayCall('MY_ItemInfoSearch', 200, function()
				D.Search(szSearch,
					function(fPer)
						muProgress:Width(nW * fPer)
					end,
					function(aResult)
						muProgress:Width(nW)
						SEARCH = szSearch
						RESULT = aResult
						UpdateList()
					end)
			end)
		end,
	}):Height()

	muProgress = ui:Append('Image', {
		name = 'Image_Progress',
		x = nX, y = nY,
		w = nW, h = 4,
		image = 'ui/Image/UICommon/RaidTotal.UITex|45',
	})
	nY = nY + 4

	list = ui:Append('WndListBox', {
		x = nX, y = nY, w = nW - nX, h = nH - nY,
		listBox = {
			{
				'onhover',
				function(id, text, data)
					if id == 'count' or (X.IsString(id) and id:sub(1, 3) == 'TIP') then
						return false
					end
					if IsCtrlKeyDown() and IsShiftKeyDown() then
						X.OutputTip(this, X.EncodeLUAData(data, '  '))
					elseif data and (data.itemInfo.nGenre ~= ITEM_GENRE.BOOK or data.dwRecipeID) then
						X.OutputItemInfoTip(data.dwTabType, data.dwIndex, data.dwRecipeID)
					else
						HideTip()
					end
				end,
				function(id, text, data)
					if id == 'count' then
						return false
					end
					HideTip()
				end
			},
			{
				'onlclick',
				function(id, text, data)
					if data then
						if IsCtrlKeyDown() then
							X.InsertChatInput('iteminfo', data.dwTabType, data.dwIndex, data.dwRecipeID)
						elseif IsAltKeyDown() then
							Addon_ExteriorViewByItemInfo(data.dwTabType, data.dwIndex)
						end
					end
					return false
				end
			},
			{
				'onrclick',
				function(id, text, data)
					return false
				end
			},
		},
	})

	D.Init()
	UpdateList()
end

function PS.OnPanelDeactive()
	D.StopSearch()
end

X.Panel.Register(_L['General'], 'MY_ItemInfoSearch', _L['MY_ItemInfoSearch'], 'ui/Image/UICommon/ActivePopularize2.UITex|30', PS)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
