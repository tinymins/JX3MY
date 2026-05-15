--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 插件命名空间初始化
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------

-- 游戏语言、游戏运营分支编码、游戏发行版编码、游戏版本号、游戏运行方式
local szVersion, szVersionLineName, szVersionEx = select(2, GetVersion())
-- 游戏语言
local _GAME_LANG_ = string.lower(szVersionLineName)
if _GAME_LANG_ == 'classic' then
	_GAME_LANG_ = 'zhcn'
end
-- 游戏运营分支编码
local _GAME_BRANCH_ = string.lower(szVersionLineName)
if _GAME_BRANCH_ == 'zhcn' then
	_GAME_BRANCH_ = 'remake'
elseif _GAME_BRANCH_ == 'zhtw' then
	_GAME_BRANCH_ = 'intl'
end
-- 游戏发行版编码
local _GAME_EDITION_ = string.lower(szVersionLineName .. '_' .. szVersionEx)
if szVersionEx == 'bvt' and szVersionLineName == 'classic' then
	_GAME_EDITION_ = string.lower(szVersionLineName .. '_yq')
end
-- 游戏版本号
local _GAME_VERSION_ = string.lower(szVersion)
-- 游戏运行方式，本地、云端
local _GAME_PROVIDER_ = 'local'
if SM_IsEnable then
	local status, res = pcall(SM_IsEnable)
	if status and res then
		_GAME_PROVIDER_ = 'remote'
	end
end
-- 游戏代码分支
local _GAME_API_BRANCH_ = _GAME_BRANCH_
if _GAME_API_BRANCH_ == 'intl' then
	_GAME_API_BRANCH_ = 'remake'
end

local DEBUG_LEVEL = {
	PM_LOG  = 0,
	LOG     = 1,
	WARNING = 2,
	ERROR   = 3,
	DEBUG   = 3,
	NONE    = 4,
}

local CODE_PAGE = {
	UTF8 = 65001,
	GBK = 936,
}

local IETF_BCP_47 = {
	zhcn = 'zh-CN',
	zhtw = 'zh-TW',
}

local _NAME_SPACE_            = 'MY'
local _BUILD_                 = '20260404'
local _VERSION_               = '29.0.8'
local _MENU_COLOR_            = {255, 165, 79}
local _INTERFACE_ROOT_        = 'Interface/'
local _ADDON_ROOT_            = _INTERFACE_ROOT_ .. _NAME_SPACE_ .. '/'
local _DATA_ROOT_             = (_GAME_PROVIDER_ == 'remote' and (GetUserDataFolder() .. '/' .. GetUserAccount() .. '/interface/') or _INTERFACE_ROOT_) .. _NAME_SPACE_ .. '#DATA/'
local _FRAMEWORK_ROOT_        = _ADDON_ROOT_ .. _NAME_SPACE_ .. '_!Base/'
local _UI_COMPONENT_ROOT_     = _FRAMEWORK_ROOT_ .. 'ui/components/'
local _LOGO_IMAGE_            = _FRAMEWORK_ROOT_ .. 'img/Logo.UITex'
local _LOGO_MAIN_FRAME_       = 0
local _LOGO_MENU_FRAME_       = 1
local _LOGO_MENU_HOVER_FRAME_ = 2
local _POSTER_IMAGE_LIST_     = {
	_ADDON_ROOT_ .. _NAME_SPACE_ .. '_Resource/img/Poster_2013.UITex',
	_ADDON_ROOT_ .. _NAME_SPACE_ .. '_Resource/img/Poster_2020.UITex',
	_ADDON_ROOT_ .. _NAME_SPACE_ .. '_Resource/img/Poster_2024_1.UITex',
	_ADDON_ROOT_ .. _NAME_SPACE_ .. '_Resource/img/Poster_2024_2.UITex',
	_ADDON_ROOT_ .. _NAME_SPACE_ .. '_Resource/img/Poster_2024_3.UITex',
}
local _DEBUG_LEVEL_           = DEBUG_LEVEL[LoadLUAData(_DATA_ROOT_ .. 'debug.level.jx3dat') or 'NONE'] or DEBUG_LEVEL.NONE
local _LOG_LEVEL_             = math.min(DEBUG_LEVEL[LoadLUAData(_DATA_ROOT_ .. 'log.level.jx3dat') or 'ERROR'] or DEBUG_LEVEL.ERROR, _DEBUG_LEVEL_)

---@class (partial) MY_UI
local UI = {}

-- 基础库命名空间
---@class (partial) MY
local X = {
	UI = UI,
	DEBUG_LEVEL = DEBUG_LEVEL,
	CODE_PAGE = CODE_PAGE,
	PATH_TYPE = {
		NORMAL = 0,
		DATA   = 1,
		ROLE   = 2,
		GLOBAL = 3,
		SERVER = 4,
	},
	PACKET_INFO = {
		NAME_SPACE            = _NAME_SPACE_           ,
		VERSION               = _VERSION_              ,
		BUILD                 = _BUILD_                ,
		MENU_COLOR            = _MENU_COLOR_           ,
		INTERFACE_ROOT        = _INTERFACE_ROOT_       ,
		ROOT                  = _ADDON_ROOT_           ,
		DATA_ROOT             = _DATA_ROOT_            ,
		FRAMEWORK_ROOT        = _FRAMEWORK_ROOT_       ,
		UI_COMPONENT_ROOT     = _UI_COMPONENT_ROOT_    ,
		LOGO_IMAGE            = _LOGO_IMAGE_           ,
		LOGO_MAIN_FRAME       = _LOGO_MAIN_FRAME_      ,
		LOGO_MENU_FRAME       = _LOGO_MENU_FRAME_      ,
		LOGO_MENU_HOVER_FRAME = _LOGO_MENU_HOVER_FRAME_,
		POSTER_IMAGE_LIST     = _POSTER_IMAGE_LIST_    ,
		DEBUG_LEVEL           = _DEBUG_LEVEL_          ,
		LOG_LEVEL             = _LOG_LEVEL_            ,
	},
	ENVIRONMENT = setmetatable({}, {
		__index = setmetatable({
			GAME_LANG = _GAME_LANG_,
			GAME_LOCALE = IETF_BCP_47[_GAME_LANG_] or 'en-US',
			GAME_BRANCH = _GAME_BRANCH_,
			GAME_EDITION = _GAME_EDITION_,
			GAME_VERSION = _GAME_VERSION_,
			GAME_PROVIDER = _GAME_PROVIDER_,
			GAME_API_BRANCH = _GAME_API_BRANCH_,
			SERVER_ADDRESS = select(7, GetUserServer()),
			SOUND_DRIVER = IsFileExist('bin64\\KG3DWwiseSoundX64.dll')
				and 'WWISE'
				or 'FMOD',
			CODE_PAGE = _GAME_BRANCH_ == 'intl'
				and CODE_PAGE.UTF8
				or CODE_PAGE.GBK,
			RUNTIME_OPTIMIZE = --[[#DEBUG BEGIN]](
				(IsDebugClient() or debug.traceback ~= nil)
					and _DEBUG_LEVEL_ == DEBUG_LEVEL.NONE
					and _LOG_LEVEL_ == DEBUG_LEVEL.NONE
					and not IsLocalFileExist(_ADDON_ROOT_ .. 'secret.jx3dat')
				) and not IsLocalFileExist(_DATA_ROOT_ .. 'no.runtime.optimize.jx3dat')
					and true
					or --[[#DEBUG END]]false,
		}, { __index = GLOBAL }),
		__newindex = function() end,
	}),
	SECRET = setmetatable({}, {
		__index = LoadLUAData(_ADDON_ROOT_ .. 'secret.jx3dat') or {},
		__newindex = function() end,
	}),
	SHARED_MEMORY = PLUGIN_SHARED_MEMORY,
}

X.IS_REMAKE = X.ENVIRONMENT.GAME_API_BRANCH == 'remake'
X.IS_CLASSIC = X.ENVIRONMENT.GAME_API_BRANCH == 'classic'
X.IS_LOCAL = X.ENVIRONMENT.GAME_PROVIDER == 'local'
X.IS_REMOTE = X.ENVIRONMENT.GAME_PROVIDER == 'remote'
X.IS_EXP = X.ENVIRONMENT.GAME_EDITION:sub(-4) == '_exp'
X.IS_WWISE = X.ENVIRONMENT.SOUND_DRIVER == 'WWISE'
X.IS_FMOD = X.ENVIRONMENT.SOUND_DRIVER == 'FMOD'
X.IS_UTF8 = X.ENVIRONMENT.CODE_PAGE == CODE_PAGE.UTF8
X.IS_GBK = X.ENVIRONMENT.CODE_PAGE == CODE_PAGE.GBK
X.IS_RUNTIME_OPTIMIZE = X.ENVIRONMENT.RUNTIME_OPTIMIZE

-- 共享内存
if type(X.SHARED_MEMORY) ~= 'table' then
	X.SHARED_MEMORY = {}
	PLUGIN_SHARED_MEMORY = X.SHARED_MEMORY
end

local NS_FORMAT_STRING_CACHE = {}

-- 格式化命名空间模板字符串
---@param s string @需要格式化的字符串
---@return string @格式化后的字符串
function X.NSFormatString(s)
	if not NS_FORMAT_STRING_CACHE[s] then
		NS_FORMAT_STRING_CACHE[s] = StringReplaceW(s, '{$NS}', _NAME_SPACE_)
	end
	return NS_FORMAT_STRING_CACHE[s]
end

-- 锁定命名空间
---@param ns table @需要锁定的命名空间
---@param szNSString string @需要锁定的命名空间的字符串描述名
---@param mt table @额外的命名空间元表
---@return table @命名空间锁定后读写代理对象
function X.NSLock(ns, szNSString, mt)
	local PROXY = {}
	for k, v in pairs(ns) do
		PROXY[k] = v
		ns[k] = nil
	end
	local t = {
		__metatable = true,
		__index = PROXY,
		__newindex = function() assert(false, 'DO NOT modify ' .. szNSString .. ' after initialized!!!') end,
		__tostring = function(t) return szNSString end,
	}
	if mt then
		for k, v in pairs(mt) do
			t[k] = v
		end
	end
	setmetatable(ns, t)
	return PROXY
end

-- 加载语言包
---@param szLangFolder string @语言包文件夹
---@return table<string, any> @语言包
function X.LoadLangPack(szLangFolder)
	local t0 = LoadLUAData(_FRAMEWORK_ROOT_ .. 'lang/default') or {}
	local t1 = LoadLUAData(_FRAMEWORK_ROOT_ .. 'lang/' .. _GAME_LANG_) or {}
	for k, v in pairs(t1) do
		t0[k] = v
	end
	if type(szLangFolder) == 'string' then
		szLangFolder = string.gsub(szLangFolder,'[/\\]+$','')
		local t2 = LoadLUAData(szLangFolder..'/default') or {}
		for k, v in pairs(t2) do
			t0[k] = v
		end
		local t3 = LoadLUAData(szLangFolder..'/' .. _GAME_LANG_) or {}
		for k, v in pairs(t3) do
			t0[k] = v
		end
	end
	setmetatable(t0, {
		__index = function(t, k) return k end,
		__call = function(t, k, ...) return string.format(t[k], ...) end,
	})
	return t0
end

local _L = X.LoadLangPack(_FRAMEWORK_ROOT_ .. 'lang/lib/')
local szHeader1 = GetFormatText(_L.PLUGIN_NAME .. ' ' .. _L['[Author]'], 8, 89, 224, 232)
local szHeader2 = GetFormatText(_L['[Fake author]'], 8, 255, 95, 159)
local szNameCN1 = string.char(0xDC, 0xF8, 0xD2, 0xC1)
local szNameCN2 = string.char(0xDC, 0xF8, 0xD2, 0xC1, 0xD2, 0xC1)
local szNameCN3 = string.char(0xD2, 0xC1, 0xDC, 0xF8)
local szNameCN4 = string.char(0xD2, 0xC1, 0xDC, 0xF8, 0xDC, 0xF8)
local szNameTW1 = string.char(0xE8, 0x8C, 0x97, 0xE4, 0xBC, 0x8A)
local szNameTW2 = string.char(0xE8, 0x8C, 0x97, 0xE4, 0xBC, 0x8A, 0xE4, 0xBC, 0x8A)

X.PACKET_INFO.NAME                = _L.PLUGIN_NAME
X.PACKET_INFO.SHORT_NAME          = _L.PLUGIN_SHORT_NAME
X.PACKET_INFO.AUTHOR              = _L.PLUGIN_AUTHOR
X.PACKET_INFO.AUTHOR_FEEDBACK     = _L.PLUGIN_AUTHOR_FEEDBACK
X.PACKET_INFO.AUTHOR_FEEDBACK_URL = _L.PLUGIN_AUTHOR_FEEDBACK_URL
X.PACKET_INFO.AUTHOR_SIGNATURE    = _L.PLUGIN_AUTHOR_SIGNATURE
X.PACKET_INFO.AUTHOR_ROLE_LIST    = {
	-- { szGlobalID = '0', szHeader = '' },
	-- { szName = '', dwID = 0, szHeader = '' },
	-- { szName = '', dwID = 0, szGlobalID = '0', szHeader = '' },
	-- 眉间雪
	{ szGlobalID = '4917930793088585480', dwID =     3848, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '4917930793088587692', dwID =     6060, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '4917930793091799002', dwID =  3217370, szName = szNameCN4, szHeader = szHeader1 },
	{ szGlobalID = '4845873199050654297', dwID =  3753904, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '4845873199050655898', dwID =  3755505, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '4953959590107545980', dwID =  5381616, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '4953959590107546219', dwID =  5381855, szName = szNameCN2, szHeader = szHeader1 },
	-- 山海相逢
	{ szGlobalID = '4863887597560136370', dwID =      690, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '4863887597560137528', dwID =     1848, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '4881901996069618081', dwID =  1613070, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '4881901996069618638', dwID =  1613627, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '4899916394579099691', dwID =  2335833, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '4899916394579099773', dwID =  2335915, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '4935945191598063966', dwID =  3254257, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '4935945191598064134', dwID =  3254425, szName = szNameCN2, szHeader = szHeader1 },
	-- 龙争虎斗
	{ szGlobalID = '378302368703873127' , dwID =  4751463, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '378302368704986888' , dwID =  5865224, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '378302368705443010' , dwID =  6321346, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '378302368705443033' , dwID =  6321369, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '378302368705443039' , dwID =  6321375, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '378302368729578857' , dwID = 30457193, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '378302368731640013' , dwID = 32518349, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '378302368732635380' , dwID = 33513716, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '378302368732910188' , dwID = 33788524, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '378302368733692724' , dwID = 34571060, szName = szNameCN1, szHeader = szHeader1 },
	-- 剑胆琴心
	{ szGlobalID = '972777519512290625' , dwID =   263489, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '972777519522485610' , dwID = 10458474, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	-- 斗转星移
	{ szGlobalID = '270215977646574895' , dwID =  4345135, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '270215977662693730' , dwID = 20463970, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '4431542033332598576', dwID = 20501066, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '4431542033332788264', dwID = 20690754, szName = szNameCN2, szHeader = szHeader1 },
	-- 乾坤一掷
	{ szGlobalID = '306244774665193949' , dwID =  4000221, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '306244774678344906' , dwID = 17151178, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '4647714815446365644', dwID = 22028859, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '4647714815446365650', dwID = 22028865, szName = szNameCN2, szHeader = szHeader1 },
	-- 绝代天骄
	{ szGlobalID = '810647932928415242' , dwID =  1725962, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '810647932929761745' , dwID =  3072465, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '810647932929767343' , dwID =  3078063, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '810647932930507327' , dwID =  3818047, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '162129586587094825' , dwID = 14533895, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '810647932948616306' , dwID = 21927026, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '810647932948971397' , dwID = 22282117, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '810647932954659351' , dwID = 27970071, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '810647932954621200' , dwID = 27931920, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	-- 梦江南
	{ szGlobalID = '432345564230575012' , dwID =  3007396, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '432345564256132428' , dwID = 28564812, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '342273571692775163' , dwID = 17796954, szName = szNameCN1, szHeader = szHeader1 },
	-- 幽月轮
	{ szGlobalID = '198158383608689108' , dwID =  4387284, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '198158383625370506' , dwID = 21068682, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '3945153273576625046', dwID = 21553085, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '3945153273576625053', dwID = 21553092, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	-- 长安城
	{ szGlobalID = '396316767212724712' , dwID =  4121064, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '396316767217116975' , dwID =  8513327, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '396316767221932296' , dwID = 13328648, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '396316767221932356' , dwID = 13328708, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '396316767221969620' , dwID = 13365972, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	-- 唯我独尊
	{ szGlobalID = '342273571684493800' , dwID =  4336104, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '2900318160027211566', dwID = 20870772, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	-- 蝶恋花
	{ szGlobalID = '216172782116345142' , dwID =  2561334, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '216172782116778584' , dwID =  2994776, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '216172782124917034' , dwID = 11133226, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '216172782124970802' , dwID = 11186994, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '216172782126564848' , dwID = 12781040, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '216172782126564851' , dwID = 12781043, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '216172782135452209' , dwID = 21668401, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '216172782136639174' , dwID = 22855366, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '216172782136822717' , dwID = 23038909, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '216172782136999278' , dwID = 23215470, szName = szNameCN1, szHeader = szHeader1 },
	-- 天鹅坪
	{ szGlobalID = '252201579136182161' , dwID =  3434385, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '252201579136967752' , dwID =  4219976, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '252201579145213206' , dwID = 12465430, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '2990390152574185432', dwID = 14964280, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '252201579154915656' , dwID = 22167880, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	-- 破阵子
	{ szGlobalID = '288230376154983398' , dwID =  3271654, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '288230376168682411' , dwID = 16970667, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	-- 飞龙在天
	{ szGlobalID = '234187180625901428' , dwID =  2635636, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '234187180631190792' , dwID =  7925000, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '234187180639172085' , dwID = 15906293, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '234187180639782941' , dwID = 16517149, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '234187180639916246' , dwID = 16650454, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '3710966092953340963', dwID = 22075830, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '3728980491462810295', dwID = 23598477, szName = szNameCN2, szHeader = szHeader1 },
	{ szGlobalID = '3710966092956267991', dwID = 25002858, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '2882303761517969694', dwID = 25747825, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '3855081281029320236', dwID = 26037104, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '3963167672086075586', dwID = 27419106, szName = szNameCN1, szHeader = szHeader1 },
	-- 国际服
	{ szGlobalID = '18014398509867167', dwID =    385183, szName = szNameTW2, szHeader = szHeader1 }, -- NameTW2
	{ szGlobalID = '18014398515510594', dwID =   6028610, szName = szNameTW2, szHeader = szHeader1 },
	{ szGlobalID = '18014398518050253', dwID =   8568269, szName = szNameTW1, szHeader = szHeader1 }, -- NameTW1
	-- 缘起稻香
	{ szGlobalID = '36028797018964996', dwID =      1028, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '54043195528446612', dwID =   1234873, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '90071992547410200', dwID =   1438152, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	{ szGlobalID = '72057594037928079', dwID =   1542205, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '36028797020576831', dwID =   1677727, szName = szNameCN2, szHeader = szHeader1 },
	-- 天宝盛世
	{ szGlobalID = '18014398509483243', dwID =      1259, szName = szNameCN1, szHeader = szHeader1 },
	{ szGlobalID = '18014398511806138', dwID =   2324154, szName = szNameCN1, szHeader = szHeader1 }, -- NameCN1
	{ szGlobalID = '18014398511806143', dwID =   2324159, szName = szNameCN2, szHeader = szHeader1 }, -- NameCN2
	-- 通配
	{ szName = szNameCN1, dwID = '*', szHeader = szHeader2 }, -- 简体
	{ szName = szNameCN2, dwID = '*', szHeader = szHeader2 }, -- 简体
	{ szName = szNameTW1, dwID = '*', szHeader = szHeader2 }, -- 繁体
	{ szName = szNameTW2, dwID = '*', szHeader = szHeader2 }, -- 繁体
}

-- 导出命名空间
---@class (partial) MY
MY = X

---@class (partial) MY_UI
MY_UI = UI
