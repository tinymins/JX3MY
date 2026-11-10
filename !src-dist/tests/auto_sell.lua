-- Run from the repository root: lua !src-dist/tests/auto_sell.lua
-- Engine/UI mocks: this checks plugin behavior, not server transactions.
-- Optional first argument: client/ui/Script/addonapi.lua, to check the real export.
local source = 'MY_Toolbox/src/MY_AutoSell.lua'
local exportShopAPI
if arg[1] then
	local file = assert(io.open(arg[1], 'rb'))
	local clientSource = file:read('*a')
	file:close()
	local helper = assert(clientSource:match('(local function Export%b().-)local Export_GFun = Export'),
		'client export helper not found')
	local statement = clientSource:match('\n[ \t]*(Export%(tAddon, "GetShop", GetShop%))')
	assert(statement, 'GetShop is not exported to the addon environment')
	local chunk = assert(loadstring(helper .. '\nlocal tAddon = {}\n' .. statement))
	exportShopAPI = function(addonEnv, engineGetShop)
		local engineEnv = {
			GetShop = engineGetShop,
			SetAddonGlobal = function(key, value) addonEnv[key] = value end,
		}
		setfenv(chunk, engineEnv)()
		assert(addonEnv.GetShop == engineGetShop)
	end
end
local function item(overrides)
	local result = {
		dwID = 'gray', nUiId = 10, bCanTrade = true, nQuality = 0,
		nGenre = 0, bCanStack = true, nStackNum = 3,
	}
	for k, v in pairs(overrides or {}) do result[k] = v end
	return result
end

local function fixture(options)
	options = options or {}
	local state = {sales = {}, messages = {}, items = options.items or {item()}, lookups = 0}
	state.shop = {dwNpcID = options.npc or 42}
	local env = setmetatable({}, {__index = _G})
	local player = {IsBookMemorized = function() return options.readBook ~= false end}
	local lang = setmetatable({}, {
		__index = function(_, key) return key end,
		__call = function(_, format, ...) return string.format(format, ...) end,
	})
	local X = {
		IS_CLASSIC = options.classic ~= false,
		PACKET_INFO = {ROOT = ''}, PATH_TYPE = {ROLE = 1},
		CONSTANT = {INVENTORY_TYPE = {PACKAGE = 1}, XML_LINE_BREAKER = '\n'},
		Schema = {Map = function() end},
		LoadLangPack = function() return lang end,
		AssertVersion = function() return true end,
		ReportModuleLoading = function() end,
		MakeCaption = function() end,
		GetItemInfoName = function(_, id) return tostring(id) end,
		CreateUserSettingsModule = function(_, _, schema)
			state.settings = {}
			for key, value in pairs(schema) do state.settings[key] = value.xDefaultValue end
			state.settings.bEnable = options.enabled ~= false
			for key, value in pairs(options.settings or {}) do state.settings[key] = value end
			return state.settings
		end,
		CreateModule = function(settings) return settings.exports[1].root end,
		RegisterUserSettingsInit = function(_, callback) state.init = callback; callback() end,
		RegisterEvent = function(event, _, callback)
			assert(event == 'SHOP_OPENSHOP')
			state.callback = callback
		end,
		GetClientPlayer = function() return player end,
		IsSafeLocked = function() return options.locked end,
		GetInventoryBoxList = function() return {7} end,
		GetInventoryBoxSize = function() return #state.items end,
		GetInventoryItem = function(_, box, slot)
			assert(box == 7)
			return state.items[slot + 1]
		end,
		GetItemName = function(id) return id end,
		RecipeToSegmentID = function(id) return id end,
		OutputSystemMessage = function(text) table.insert(state.messages, text) end,
	}
	state.env = env
	env.MY = X
	env.RegisterCustomData = function() end
	env.SAFE_LOCK_EFFECT_TYPE = {EQUIP = 1}
	env.ITEM_GENRE = {BOOK = 1, EQUIPMENT = 2}
	env.EQUIPMENT_SUB = {ARROW = 3}
	local engineGetShop = function(id)
		assert(X.IS_CLASSIC, 'other clients must not call GetShop')
		assert(id == 124, 'shop ID changed')
		return state.shop
	end
	if exportShopAPI then
		exportShopAPI(env, engineGetShop)
	else
		env.GetShop = engineGetShop
	end
	env.Station = {
		GetClientSize = function() return 1920, 1080 end,
		Lookup = function(path)
			local expected = X.IS_CLASSIC and 'Normal/ShopPanel/Wnd_Right/CheckBox_AutoSell'
				or 'Normal/ShopPanel/CheckBox_AutoSell'
			assert(path == expected, 'wrong auto-sell checkbox path')
			state.lookups = state.lookups + 1
			if options.noCheckbox then return nil end
			return {IsCheckBoxChecked = function() return options.officialGray or false end}
		end,
	}
	env.GetItemFontColorByQuality = function() return 255, 255, 255 end
	env.GetFormatText = function(text) return text end
	env.g_tStrings = {
		STR_CHINESE_MAOHAO = ':', STR_TWO_CHINESE_SPACE = '  ',
		STR_HOTKEY_SURE = 'OK', STR_HOTKEY_CANCEL = 'Cancel',
	}
	env.MessageBox = function(message) state.message = message end
	env.SellItem = function(...) table.insert(state.sales, {...}) end
	setfenv(assert(loadfile(source)), env)()
	function state.open()
		env.arg0, env.arg1 = 124, 999
		if X.IS_CLASSIC then env.arg4 = nil else env.arg4 = 84 end
		if state.callback then state.callback() end
	end
	function state.confirm()
		if state.message then state.message[1].fnAction() end
	end
	return state
end

local count = 0
local function test(name, fn)
	fn()
	count = count + 1
	print('PASS ' .. name)
end
local function noSale(options, mutate)
	local state = fixture(options)
	if mutate then mutate(state) end
	state.open()
	assert(not state.message, 'unexpected sell confirmation')
	assert(#state.sales == 0)
	return state
end

for _, npc in ipairs({42, 0}) do
	test('NPC ID ' .. npc .. ' reaches SellItem after confirmation', function()
		local state = fixture({npc = npc})
		state.open()
		assert(state.message and #state.sales == 0)
		state.env.arg0, state.env.arg4 = -1, -1
		state.confirm()
		local sale = assert(state.sales[1])
		assert(#state.sales == 1 and sale[1] == npc and sale[2] == 124)
		assert(sale[3] == 7 and sale[4] == 0 and sale[5] == 3)
	end)
end
test('missing shop exits safely', function() noSale({}, function(s) s.shop = nil end) end)
test('missing NPC ID exits safely', function() noSale({}, function(s) s.shop = {} end) end)
test('disabled setting unregisters event', function()
	local state = noSale({enabled = false})
	assert(state.callback == false)
	state.settings.bEnable = true; state.init(); state.open()
	assert(state.message)
	state.settings.bEnable = false; state.init()
	assert(state.callback == false)
end)
test('safe lock blocks selling', function() noSale({locked = true}) end)
test('plugin gray setting is respected', function() noSale({settings = {bSellGray = false}}) end)
test('official gray setting suppresses gray rule', function() noSale({officialGray = true}) end)
test('missing checkbox does not prevent selling', function()
	local state = fixture({noCheckbox = true}); state.open(); state.confirm()
	assert(#state.sales == 1)
end)
test('classic does not require an exported ShopPanel global', function()
	local state = fixture()
	assert(state.env.ShopPanel == nil)
	state.open(); state.confirm()
	assert(#state.sales == 1 and state.lookups == 1)
end)
test('protected gray and named items are excluded', function()
	noSale({settings = {tSellItem = {gray = true}, tProtectItem = {gray = true}}})
end)
test('untradeable items are excluded', function()
	noSale({items = {item({bCanTrade = false})}, settings = {tSellItem = {gray = true}}})
end)
test('ordinary non-gray items are excluded', function() noSale({items = {item({nQuality = 2})}}) end)
test('named rule remains independent of gray settings', function()
	local state = fixture({officialGray = true, settings = {bSellGray = false, tSellItem = {gray = true}}})
	state.open(); state.confirm(); assert(#state.sales == 1)
end)
for quality, setting in ipairs({'bSellWhiteBook', 'bSellGreenBook', 'bSellBlueBook'}) do
	test('read book quality ' .. quality .. ' filtering and protection', function()
		local options = {items = {item({nGenre = 1, nQuality = quality, nBookID = 123})}, settings = {[setting] = true}}
		local state = fixture(options); state.open(); state.confirm(); assert(#state.sales == 1)
		options.readBook = false; noSale(options)
		options.readBook = true; options.settings[setting] = false; noSale(options)
		options.settings[setting] = true; options.settings.tProtectItem = {gray = true}; noSale(options)
	end)
end
test('arrow and non-stack counts are retained', function()
	local state = fixture({items = {
		item({nGenre = 2, nSub = 3, nCurrentDurability = 80, nUiId = 20}),
		item({bCanStack = false}),
	}})
	state.open(); state.confirm()
	assert(#state.sales == 2 and state.sales[1][5] == 80 and state.sales[2][5] == 1)
end)
for _, change in ipairs({'missing', 'different', 'noNPC', 'replacedItem', 'removedItem'}) do
	test('confirmation rejects ' .. change, function()
		local state = fixture(); state.open(); assert(state.message)
		if change == 'missing' then state.shop = nil
		elseif change == 'different' then state.shop.dwNpcID = 43
		elseif change == 'noNPC' then state.shop.dwNpcID = nil
		elseif change == 'replacedItem' then state.items[1] = item({nUiId = 999})
		else state.items[1] = nil end
		state.confirm(); assert(#state.sales == 0 and #state.messages == 0)
	end)
end
test('other clients retain arg4 and checkbox behavior', function()
	for _, noCheckbox in ipairs({false, true}) do
		local state = fixture({classic = false, noCheckbox = noCheckbox})
		state.open(); state.confirm()
		assert(#state.sales == 1 and state.sales[1][1] == 84 and state.lookups == 1)
	end
	noSale({classic = false, officialGray = true})
end)
print(string.format('%d tests passed (%s)', count, _VERSION))
