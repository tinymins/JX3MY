--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 战斗浮动文字
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_CombatText/MY_CombatText'
local PLUGIN_NAME = 'MY_CombatText'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_CombatText'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.0') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------
local SKILL_RESULT_TYPE = SKILL_RESULT_TYPE
local GetSkill, Random = GetSkill, Random
local Table_GetBuff, Table_GetBuffName, Table_GetSkillName, Table_BuffIsVisible = Table_GetBuff, Table_GetBuffName, Table_GetSkillName, Table_BuffIsVisible

-- 战斗浮动文字设计思路
--[[
	停留时间：使用（总帧数 * 每帧时间）来决定总停留时间，
	alpha：   使用帧数来决定fadein和fadeout。
	排序：    顶部使用简易见缝插针，分配空闲轨迹，最大程度上保证性能和浮动数值清晰。
	坐标轨迹：使用关键帧形式，一共32关键帧，部分类型有延长帧。
	出现：    对出现做1帧的延迟处理，即1帧出现5次伤害则分5帧依次出现。
	-------------------------------------------------------------------------------
	初始坐标类型：分为 顶部 左 右 左下 右下 中心
	顶部：
		Y轴轨迹数 以 math.floor(3.5 / UI缩放) 决定，其初始Y轴高度不同。
		在轨迹全部被占用后会随机分摊到屏幕顶部左右两边。
	其他类型：使用轨迹合并16-32帧，后来的文本会顶走前面的文本，从而跳过这部分停留的帧数。
]]

local COMBAT_TEXT_INIFILE          = X.PACKET_INFO.ROOT .. 'MY_CombatText/ui/MY_CombatText_Render.ini'
local COMBAT_TEXT_CONFIG           = X.FormatPath({'config/CombatText.jx3dat', X.PATH_TYPE.GLOBAL})
local COMBAT_TEXT_PLAYERID         = 0
local COMBAT_TEXT_IN_ROGUELIKE_MAP = false
local COMBAT_TEXT_TOTAL            = 32
local COMBAT_TEXT_UI_SCALE         = 1
local COMBAT_TEXT_TRAJECTORY       = 4   -- 顶部Y轴轨迹数量 根据缩放大小变化 0.8就是5条了 屏幕小更多

local COMBAT_TEXT_TYPE = {
	DAMAGE               = 'DAMAGE'              ,

	THERAPY              = 'THERAPY'             ,
	EFFECTIVE_THERAPY    = 'EFFECTIVE_THERAPY'   ,
	STEAL_LIFE           = 'STEAL_LIFE'          ,

	PHYSICS_DAMAGE       = 'PHYSICS_DAMAGE'      ,
	SOLAR_MAGIC_DAMAGE   = 'SOLAR_MAGIC_DAMAGE'  ,
	NEUTRAL_MAGIC_DAMAGE = 'NEUTRAL_MAGIC_DAMAGE',
	LUNAR_MAGIC_DAMAGE   = 'LUNAR_MAGIC_DAMAGE'  ,
	POISON_DAMAGE        = 'POISON_DAMAGE'       ,
	REFLECTED_DAMAGE     = 'REFLECTED_DAMAGE'    ,
	SPIRIT               = 'SPIRIT'              ,
	STAYING_POWER        = 'STAYING_POWER'       ,

	SHIELD_DAMAGE        = 'SHIELD_DAMAGE'       ,
	ABSORB_DAMAGE        = 'ABSORB_DAMAGE'       ,
	PARRY_DAMAGE         = 'PARRY_DAMAGE'        ,
	INSIGHT_DAMAGE       = 'INSIGHT_DAMAGE'      ,

	SKILL_BUFF           = 'SKILL_BUFF'          ,
	SKILL_DEBUFF         = 'SKILL_DEBUFF'        ,
	SKILL_MISS           = 'SKILL_MISS'          ,
	BUFF_IMMUNITY        = 'BUFF_IMMUNITY'       ,
	SKILL_DODGE          = 'SKILL_DODGE'         ,
	EXP                  = 'EXP'                 ,
	MSG                  = 'MSG'                 ,
	CRITICAL_MSG         = 'CRITICAL_MSG'        ,
}

local COMBAT_TEXT_CRITICAL = { -- 需要会心跳帧的文字类型
	[COMBAT_TEXT_TYPE.THERAPY             ] = true,
	[COMBAT_TEXT_TYPE.EFFECTIVE_THERAPY   ] = true,
	[COMBAT_TEXT_TYPE.STEAL_LIFE          ] = true,
	[COMBAT_TEXT_TYPE.PHYSICS_DAMAGE      ] = true,
	[COMBAT_TEXT_TYPE.SOLAR_MAGIC_DAMAGE  ] = true,
	[COMBAT_TEXT_TYPE.NEUTRAL_MAGIC_DAMAGE] = true,
	[COMBAT_TEXT_TYPE.LUNAR_MAGIC_DAMAGE  ] = true,
	[COMBAT_TEXT_TYPE.POISON_DAMAGE       ] = true,
	[COMBAT_TEXT_TYPE.REFLECTED_DAMAGE    ] = true,
	[COMBAT_TEXT_TYPE.EXP                 ] = true,
	[COMBAT_TEXT_TYPE.CRITICAL_MSG        ] = true,
}
local COMBAT_TEXT_EVENT  = { 'COMMON_HEALTH_TEXT', 'SKILL_EFFECT_TEXT', 'SKILL_MISS', 'SKILL_DODGE', 'SKILL_BUFF', 'BUFF_IMMUNITY' }
local COMBAT_TEXT_OFFICIAL_EVENT = { 'SKILL_EFFECT_TEXT', 'COMMON_HEALTH_TEXT', 'SKILL_MISS', 'SKILL_DODGE', 'SKILL_BUFF', 'BUFF_IMMUNITY', 'ON_EXP_LOG', 'SYS_MSG', 'FIGHT_HINT' }
local COMBAT_TEXT_SKILL_IGNORE = {}
local COMBAT_TEXT_SKILL_TYPE_IGNORE = {}
local COMBAT_TEXT_SKILL_STATIC_STRING = X.KvpToObject({ -- 需要变成特定字符串的伤害类型
	{SKILL_RESULT_TYPE.SHIELD_DAMAGE , g_tStrings.STR_MSG_ABSORB    },
	{SKILL_RESULT_TYPE.ABSORB_DAMAGE , g_tStrings.STR_MSG_ABSORB    },
	{SKILL_RESULT_TYPE.PARRY_DAMAGE  , g_tStrings.STR_MSG_COUNTERACT},
	{SKILL_RESULT_TYPE.INSIGHT_DAMAGE, g_tStrings.STR_MSG_INSIGHT   },
})

local COMBAT_TEXT_STYLES = {
	[0] = {
		2, 4.5, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
	},
	[1] = {
		2, 4.5, 4, 3, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
	},
	[2] = {
		1, 2, 3, 4.5, 3, 3, 3, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
	},
	[3] = {
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
	}
}

local COMBAT_TEXT_SCALE = { -- 各种伤害的缩放帧数 一共32帧
	CRITICAL = { -- 会心
		2, 4.5, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
		2, 2, 2, 2, 2, 2, 2, 2,
	},
	NORMAL = { -- 普通伤害
		1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5,
		1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5,
		1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5,
		1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5,
		1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5,
		1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5,
	},
}

local COMBAT_TEXT_POINT = {
	TOP = { -- 伤害 往上的 分四组 普通 慢 慢 快~~
		0,   6,   12,  18,  24,  30,  36,  42,
		45,  48,  51,  54,  57,  60,  63,  66,
		69,  72,  75,  78,  81,  84,  87,  90,
		100, 110, 120, 130, 140, 150, 160, 170,
	},
	RIGHT = { -- 从左往右的
		8,   16,  24,  32,  40,  48,  56,  64,
		72,  80,  88,  96,  104, 112, 120, 128,
		136, 136, 136, 136, 136, 136, 136, 136,
		136, 136, 136, 136, 136, 136, 136, 136,
		139, 142, 145, 148, 151, 154, 157, 160,
		163, 166, 169, 172, 175, 178, 181, 184,
	},
	LEFT = { -- 从右到左
		8,   16,  24,  32,  40,  48,  56,  64,
		72,  80,  88,  96,  104, 112, 120, 128,
		136, 136, 136, 136, 136, 136, 136, 136,
		136, 136, 136, 136, 136, 136, 136, 136,
		139, 142, 145, 148, 151, 154, 157, 160,
		163, 166, 169, 172, 175, 178, 181, 184,
	},
	BOTTOM_LEFT = { -- 左下角
		5,   10,  15,  20,  25,  30,  35,  40,
		45,  50,  55,  60,  65,  70,  75,  80,
		80,  80,  80,  80,  80,  80,  80,  80,
		80,  80,  80,  80,  80,  80,  80,  80,
		82,  84,  86,  88,  90,  92,  94,  96,
		98,  100, 102, 104, 106, 108, 110, 112,
	},
	BOTTOM_RIGHT = {
		5,   10,  15,  20,  25,  30,  35,  40,
		45,  50,  55,  60,  65,  70,  75,  80,
		80,  80,  80,  80,  80,  80,  80,  80,
		80,  80,  80,  80,  80,  80,  80,  80,
		82,  84,  86,  88,  90,  92,  94,  96,
		98,  100, 102, 104, 106, 108, 110, 112,
	},
}

local COMBAT_TEXT_COLOR = {
	-- 受伤
	[COMBAT_TEXT_TYPE.DAMAGE              ] = X.ENVIRONMENT.GAME_PROVIDER == 'remote' and { 253, 86, 86 } or { 255, 0, 0 }, -- 受伤 自己受到的伤害
	-- 治疗
	[COMBAT_TEXT_TYPE.THERAPY             ] = {   0, 255,   0 }, -- 治疗
	[COMBAT_TEXT_TYPE.EFFECTIVE_THERAPY   ] = {   0, 255,   0 }, -- 有效治疗
	[COMBAT_TEXT_TYPE.STEAL_LIFE          ] = {   0, 255,   0 }, -- 偷取气血
	-- 招式
	[COMBAT_TEXT_TYPE.PHYSICS_DAMAGE      ] = { 255, 255, 255 }, -- 外功攻击
	[COMBAT_TEXT_TYPE.SOLAR_MAGIC_DAMAGE  ] = { 255, 128, 128 }, -- 阳性攻击
	[COMBAT_TEXT_TYPE.NEUTRAL_MAGIC_DAMAGE] = { 255, 255,   0 }, -- 混元攻击
	[COMBAT_TEXT_TYPE.LUNAR_MAGIC_DAMAGE  ] = {  12, 242, 255 }, -- 阴性攻击
	[COMBAT_TEXT_TYPE.POISON_DAMAGE       ] = { 128, 255, 128 }, -- 毒性攻击
	[COMBAT_TEXT_TYPE.REFLECTED_DAMAGE    ] = { 255, 128, 128 }, -- 反弹伤害
	[COMBAT_TEXT_TYPE.SPIRIT              ] = { 160,   0, 160 }, -- 精神
	[COMBAT_TEXT_TYPE.STAYING_POWER       ] = { 255, 169,   0 }, -- 耐力

	[COMBAT_TEXT_TYPE.SHIELD_DAMAGE       ] = { 255, 255,   0 },
	[COMBAT_TEXT_TYPE.ABSORB_DAMAGE       ] = { 255, 255,   0 },
	[COMBAT_TEXT_TYPE.PARRY_DAMAGE        ] = { 255, 255,   0 },
	[COMBAT_TEXT_TYPE.INSIGHT_DAMAGE      ] = { 255, 255,   0 },

	[COMBAT_TEXT_TYPE.SKILL_BUFF          ] = { 255, 255,   0 },
	[COMBAT_TEXT_TYPE.SKILL_DEBUFF        ] = { 255,   0,   0 },
	[COMBAT_TEXT_TYPE.SKILL_MISS          ] = { 255, 255, 255 },
	[COMBAT_TEXT_TYPE.BUFF_IMMUNITY       ] = { 255, 255, 255 },
	[COMBAT_TEXT_TYPE.SKILL_DODGE         ] = { 255,   0,   0 },

	[COMBAT_TEXT_TYPE.EXP                 ] = { 255,   0, 255 },
	[COMBAT_TEXT_TYPE.MSG                 ] = { 255, 255,   0 },
	[COMBAT_TEXT_TYPE.CRITICAL_MSG        ] = { 255,   0,   0 },
}
local COMBAT_TEXT_CRITICAL_COLOR = {}

local COMBAT_TEXT_TYPE_CLASS = {
	[COMBAT_TEXT_TYPE.STEAL_LIFE       ] = 'THERAPY',
	[COMBAT_TEXT_TYPE.EFFECTIVE_THERAPY] = 'THERAPY',
	[COMBAT_TEXT_TYPE.THERAPY          ] = 'THERAPY',
}

local COMBAT_TEXT_LEAVE  = {}
local COMBAT_TEXT_FREE   = {}
--  合并伤害 cache 记录方式是 dwTargetID + _ + szPoint = nValue
local COMBAT_TEXT_COMBINE = {}
local COMBAT_TEXT_SHADOW = {}
local COMBAT_TEXT_QUEUE  = {}
local COMBAT_TEXT_CACHE  = { -- buff的名字cache
	BUFF   = {},
	DEBUFF = {},
}

local COMBAT_TEXT_TYPE_NAME = setmetatable(_L.COMBAT_TEXT_TYPE_NAME or {}, { __index = function(_, k) return k end })

local O = X.CreateUserSettingsModule('MY_CombatText', _L['System'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Enable combat text'],
		}),
		xSchema = X.Schema.Boolean,
		szVersion = '20241105',
		xDefaultValue = false,
	},
	bRender = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Enable render'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	fScale = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Font size'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 1,
	},
	nStyle = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Critical style'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 1,
	},
	nMaxAlpha = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			g_tStrings.STR_QUESTTRACE_CHANGE_ALPHA,
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 240,
	},
	nMaxCount = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Max count'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 300,
	},
	nTime = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Hold time'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 40,
	},
	nFadeIn = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Fade in time'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 4,
	},
	nFadeOut = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Fade out time'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 8,
	},
	nFont = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Font edit'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 19,
	},
	bImmunity = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Disable immunity'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bOtherCharacter = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Only show my related combat text'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bCritical = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Distinct critical color'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bOptimizeRoguelike = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Optimize in roguelike'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	-- 显示合并文本（致命一击）
	bEnableCombineText = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Show combine text'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bDisabledPartnerText = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Disable partner text'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	-- $name 名字 $sn   技能名 $crit 会心 $val  数值
	szSkill = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Skill style'],
		}),
		xSchema = X.Schema.String,
		xDefaultValue = '$sn' .. g_tStrings.STR_COLON .. '$crit $val',
	},
	szTherapy = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Therapy style'],
		}),
		xSchema = X.Schema.String,
		xDefaultValue = '$sn' .. g_tStrings.STR_COLON .. '$crit +$val',
	},
	szDamage = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Damage style'],
		}),
		xSchema = X.Schema.String,
		xDefaultValue = '$sn' .. g_tStrings.STR_COLON .. '$crit -$val',
	},
	bCasterNotI = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['$name not me'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bSnShorten2 = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['$sn shorten(2)'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bTherapyEffectiveOnly = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Therapy effective only'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	tColor = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Color edit'],
		}),
		xSchema = X.Schema.Map(X.Schema.OneOf(X.Schema.String, X.Schema.Number), X.Schema.Tuple(X.Schema.Number, X.Schema.Number, X.Schema.Number)),
		xDefaultValue = {},
	},
	tCriticalColor = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Critical color'],
		}),
		xSchema = X.Schema.Map(X.Schema.OneOf(X.Schema.String, X.Schema.Number), X.Schema.Tuple(X.Schema.Number, X.Schema.Number, X.Schema.Number)),
		xDefaultValue = {},
	},
	bSimplifyValue = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_CombatText'],
		szDescription = X.MakeCaption({
			_L['Simplify value'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}

local function IsEnabled()
	return D.bReady and O.bEnable
end

local function IsCombatTextPlayerID(...)
	if O.bOtherCharacter then
		return true
	end
	for i = 1, select('#', ...) do
		if select(i, ...) == COMBAT_TEXT_PLAYERID then
			return true
		end
	end
	return false
end

function D.GetColor(eType, bCritical)
	return (bCritical and O.bCritical)
		and O.tCriticalColor[eType]
		or O.tColor[eType]
		or COMBAT_TEXT_COLOR[eType]
		or { 255, 255, 255 }
end

function D.GetTargetShowValue(nValue)
	if O.bSimplifyValue then
		return X.FormatNumberDot(nValue, 1, false, 10000)
	end
	return nValue
end

function D.HideOfficialCombat()
	local frame = Station.Lookup('Lowest/CombatText')
	if frame then
		for _, v in ipairs(COMBAT_TEXT_OFFICIAL_EVENT) do
			frame:UnRegisterEvent(v)
		end
	end
end

function D.ShowOfficialCombat()
	local frame = Station.Lookup('Lowest/CombatText')
	if frame then
		for _, v in ipairs(COMBAT_TEXT_OFFICIAL_EVENT) do
			frame:UnRegisterEvent(v)
			frame:RegisterEvent(v)
		end
	end
end

function D.OnFrameCreate()
	for k, v in ipairs(COMBAT_TEXT_EVENT) do
		this:RegisterEvent(v)
	end
	this:ShowWhenUIHide()
	this:RegisterEvent('SYS_MSG')
	this:RegisterEvent('FIGHT_HINT')
	this:RegisterEvent('UI_SCALED')
	this:RegisterEvent('LOADING_END')
	this:RegisterEvent('NPC_ENTER_SCENE')
	this:RegisterEvent('ON_EXP_LOG')
	this:RegisterEvent('COINSHOP_ON_OPEN')
	this:RegisterEvent('COINSHOP_ON_CLOSE')
	this:RegisterEvent('ENTER_STORY_MODE')
	this:RegisterEvent('LEAVE_STORY_MODE')
	D.handle = this:Lookup('', '')
	D.FreeQueue()
	D.UpdateTrajectoryCount()
	X.BreatheCall('COMBAT_TEXT_CACHE', 1000 * 60 * 5, function()
		local count = 0
		for k, v in pairs(COMBAT_TEXT_LEAVE) do
			count = count + 1
		end
		if count > 10000 then
			COMBAT_TEXT_LEAVE = {}
			Log('[MY] CombatText cache beyond 10000 !!!')
		end
	end)
	X.BreatheCall('COMBAT_TEXT_COMBINE', 200, function()
		if not O.bEnableCombineText then
			return
		end
		for k, v in pairs(COMBAT_TEXT_COMBINE) do
			if v.nCount >= 3 then
				local object = X.IsPlayer(v.dwTargetID) and X.GetPlayer(v.dwTargetID) or X.GetNpc(v.dwTargetID)
				if object then
					local _, fMaxLife = X.GetCharacterLife(object)
					if v.nValue > fMaxLife * 0.35 then
						local shadow = D.GetFreeShadow(true)
						if shadow then
							D.CreateText(
								shadow,
								v.dwTargetID,
								_L['Critical Strike'] .. ' ' .. D.GetTargetShowValue(v.nValue),
								v.szPoint,
								COMBAT_TEXT_TYPE.CRITICAL_MSG,
								true,
								true
							)
						end
					end
				end
			end
			COMBAT_TEXT_COMBINE[k] = nil
		end
	end)
end
-- for i=1,5 do FireUIEvent('SKILL_EFFECT_TEXT',1073745690,MY.GetClientPlayerID(),true,5,1111,111,1)end
-- for i=1,5 do FireUIEvent('SKILL_EFFECT_TEXT',MY.GetClientPlayerID(),1073745690,true,5,1111,111,1)end
-- for i=1,5 do FireUIEvent('SKILL_EFFECT_TEXT',X.GetClientPlayerID(),1073741860,false,5,1111,111,1)end
-- for i=1, 5 do FireEvent('SKILL_BUFF', X.GetClientPlayerID(), true, 103, 1) end
-- FireUIEvent('SKILL_MISS', X.GetClientPlayerID(), X.GetClientPlayerID())
-- FireUIEvent('SYS_MSG', 'UI_OME_EXP_LOG', X.GetClientPlayerID(), X.GetClientPlayerID())
function D.OnEvent(szEvent)
	if szEvent == 'FIGHT_HINT' then -- 进出战斗文字
		if arg0 then
			OutputMessage('MSG_ANNOUNCE_RED', g_tStrings.STR_MSG_ENTER_FIGHT)
		else
			OutputMessage('MSG_ANNOUNCE_YELLOW', g_tStrings.STR_MSG_LEAVE_FIGHT)
		end
	elseif szEvent == 'COMMON_HEALTH_TEXT' then
		if arg1 ~= 0 then
			D.OnCommonHealth(arg0, arg1)
		end
	elseif szEvent == 'SKILL_EFFECT_TEXT' then
		-- 贯体治疗有效值 SKILL_EFFECT_TEXT 无法显示，于是让所有有效治疗走 SYS_MSG -> UI_OME_SKILL_EFFECT_LOG 通道
		if arg3 == SKILL_RESULT_TYPE.EFFECTIVE_THERAPY then
			return
		end
		D.OnSkillText(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
	elseif szEvent == 'SKILL_BUFF' then
		D.OnSkillBuff(arg0, arg1, arg2, arg3)
	elseif szEvent == 'BUFF_IMMUNITY' then
		if not O.bImmunity and IsCombatTextPlayerID(arg1) then
			D.OnBuffImmunity(arg0)
		end
	elseif szEvent == 'SKILL_MISS' then
		if IsCombatTextPlayerID(arg0, arg1) then
			D.OnSkillMiss(arg1)
		end
	elseif szEvent == 'UI_SCALED' then
		D.UpdateTrajectoryCount()
	elseif szEvent == 'SKILL_DODGE' then
		if IsCombatTextPlayerID(arg0, arg1) then
			D.OnSkillDodge(arg1)
		end
	elseif szEvent == 'NPC_ENTER_SCENE' then
		COMBAT_TEXT_LEAVE[arg0] = nil
	elseif szEvent == 'ON_EXP_LOG' then
		D.OnExpLog(arg0, arg1)
	elseif szEvent == 'SYS_MSG' then
		if arg0 == 'UI_OME_DEATH_NOTIFY' then
			if not X.IsPlayer(arg1) then
				COMBAT_TEXT_LEAVE[arg1] = true
			end
		elseif arg0 == 'UI_OME_SKILL_EFFECT_LOG' then
			-- 技能最终产生的效果（生命值的变化）；
			-- (arg1)dwCaster：施放者 (arg2)dwTarget：目标 (arg3)bReact：是否为反击 (arg4)nEffectType：Effect类型 (arg5)dwID:Effect的ID
			-- (arg6)dwLevel：Effect的等级 (arg7)bCriticalStrike：是否会心 (arg8)nCount：tResultCount数据表中元素个数 (arg9)tResultCount：数值集合
			-- 贯体治疗有效值 SKILL_EFFECT_TEXT 无法显示，于是让所有有效治疗走 SYS_MSG -> UI_OME_SKILL_EFFECT_LOG 通道
			if arg9[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] then
				D.OnSkillText(arg1, arg2, arg7, SKILL_RESULT_TYPE.EFFECTIVE_THERAPY, arg9[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY], arg5, arg6, arg4)
			end
			-- dwCasterID, dwTargetID, bCriticalStrike, nEffectType, nValue, dwSkillID, dwSkillLevel, nEffectType
		end
	elseif szEvent == 'LOADING_END' then
		this:Show()
		D.FreeQueue()
	elseif szEvent == 'COINSHOP_ON_OPEN' or szEvent == 'ENTER_STORY_MODE' then
		this:HideWhenUIHide()
	elseif szEvent == 'COINSHOP_ON_CLOSE' or szEvent == 'LEAVE_STORY_MODE' then
		this:ShowWhenUIHide()
	end
end

function D.FreeQueue()
	COMBAT_TEXT_LEAVE  = {}
	COMBAT_TEXT_FREE   = {}
	COMBAT_TEXT_SHADOW = {}
	COMBAT_TEXT_CACHE  = {
		BUFF   = {},
		DEBUFF = {},
	}
	D.handle:Clear()
	COMBAT_TEXT_QUEUE = {
		TOP          = {},
		LEFT         = {},
		RIGHT        = {},
		BOTTOM_LEFT  = {},
		BOTTOM_RIGHT = {},
	}
	setmetatable(COMBAT_TEXT_QUEUE, { __index = function(me) return me['TOP'] end, __newindex = function(me) return me['TOP'] end })
end
function D.OnFrameRender()
	if not D.bReady then
		return
	end
	local nTime     = GetTime()
	local nFadeIn   = O.nFadeIn
	local nFadeOut  = O.nFadeOut
	local nMaxAlpha = O.nMaxAlpha
	local nFont     = O.nFont
	local nDelay    = O.nTime
	local g_fScale  = O.fScale
	for k, v in pairs(COMBAT_TEXT_SHADOW) do
		local nFrame = (nTime - v.nTime) / nDelay + 1 -- 每一帧是多少毫秒 这里越小 动画越快
		local nBefore = math.floor(nFrame)
		local nAfter  = math.ceil(nFrame)
		local fDiff   = nFrame - nBefore
		local nTotal  = COMBAT_TEXT_POINT[v.szPoint] and #COMBAT_TEXT_POINT[v.szPoint] or COMBAT_TEXT_TOTAL
		k:ClearTriangleFanPoint()
		if nBefore < nTotal then
			local nTop   = 0
			local nLeft  = 0
			local nAlpha = nMaxAlpha
			local fScale = 1
			local bTop   = true
			-- alpha
			if nFrame < nFadeIn then
				nAlpha = nMaxAlpha * nFrame / nFadeIn
			elseif nFrame > nTotal - nFadeOut then
				nAlpha = nMaxAlpha * (nTotal - nFrame) / nFadeOut
			end
			-- 坐标
			if v.szPoint == 'TOP' or v.szPoint == 'TOP_LEFT' or v.szPoint == 'TOP_RIGHT' then
				local tTop = COMBAT_TEXT_POINT[v.szPoint]
				nTop = (-60 * g_fScale) + v.nSort * (-40 * g_fScale) - (tTop[nBefore] + (tTop[nAfter] - tTop[nBefore]) * fDiff)
				if v.szPoint == 'TOP_LEFT' or v.szPoint == 'TOP_RIGHT' then
					if v.szPoint == 'TOP_LEFT' then
						nLeft = -250
					elseif v.szPoint == 'TOP_RIGHT' then
						nLeft = 250
					end
					nTop = nTop -50
				end
			elseif v.szPoint == 'LEFT' then
				local tLeft = COMBAT_TEXT_POINT[v.szPoint]
				nLeft = -60 - (tLeft[nBefore] + (tLeft[nAfter] - tLeft[nBefore]) * fDiff)
				nAlpha = nAlpha * 0.85
			elseif v.szPoint == 'RIGHT' then
				local tLeft = COMBAT_TEXT_POINT[v.szPoint]
				nLeft = 60 + (tLeft[nBefore] + (tLeft[nAfter] - tLeft[nBefore]) * fDiff)
				nAlpha = nAlpha * 0.9
			elseif v.szPoint == 'BOTTOM_LEFT' or v.szPoint == 'BOTTOM_RIGHT' then
				local tLeft = COMBAT_TEXT_POINT[v.szPoint]
				local tTop = COMBAT_TEXT_POINT[v.szPoint]
				if v.szPoint == 'BOTTOM_LEFT' then
					nLeft = -130 - (tLeft[nBefore] + (tLeft[nAfter] - tLeft[nBefore]) * fDiff)
				else
					nLeft = 130 + (tLeft[nBefore] + (tLeft[nAfter] - tLeft[nBefore]) * fDiff)
				end
				nTop = 50 + tTop[nBefore] + (tTop[nAfter] - tTop[nBefore]) * fDiff
				fScale = 1.5
			end
			-- 缩放
			if COMBAT_TEXT_CRITICAL[v.eType] then
				local tScale  = v.bCriticalStrike and COMBAT_TEXT_SCALE.CRITICAL or COMBAT_TEXT_SCALE.NORMAL
				fScale  = tScale[nBefore]
				if tScale[nBefore] > tScale[nAfter] then
					fScale = fScale - ((tScale[nBefore] - tScale[nAfter]) * fDiff)
				elseif tScale[nBefore] < tScale[nAfter] then
					fScale = fScale + ((tScale[nAfter] - tScale[nBefore]) * fDiff)
				end
				if COMBAT_TEXT_TYPE_CLASS[v.eType] == 'THERAPY' then -- 治疗缩小
					if v.bCriticalStrike then
						fScale = math.max(fScale * 0.7, COMBAT_TEXT_SCALE.NORMAL[#COMBAT_TEXT_SCALE.NORMAL] + 0.1)
					end
					if v.dwTargetID == COMBAT_TEXT_PLAYERID then
						fScale = fScale * 0.95
					end
				elseif v.szPoint == 'TOP_LEFT' or v.szPoint == 'TOP_RIGHT' then -- 左右缩小
					fScale = fScale * 0.85
				end
				if v.szPoint == 'TOP' or v.szPoint == 'TOP_LEFT' or v.szPoint == 'TOP_RIGHT' then
					fScale = fScale * g_fScale
				end
			end
			-- draw
			local r, g, b = unpack(v.col or {255, 255, 255})
			if not COMBAT_TEXT_LEAVE[v.dwTargetID] or not v.object or not v.tPoint[1] then
				k:AppendCharacterID(v.dwTargetID, bTop, r, g, b, nAlpha, { 0, 0, 0, nLeft * COMBAT_TEXT_UI_SCALE, nTop * COMBAT_TEXT_UI_SCALE}, nFont, v.szText, 1, fScale)
				if v.object and v.object.nX then
					v.tPoint = { v.object.nX, v.object.nY, v.object.nZ }
				else -- DEBUG  JX3Client   [Script index] pointer invalid. call stack: 暂无完美解决方案 都会造成内存泄露
					if not COMBAT_TEXT_LEAVE[v.dwTargetID] then
						COMBAT_TEXT_LEAVE[v.dwTargetID] = true
					end
				end
			else
				local x, y, z = unpack(v.tPoint)
				k:AppendTriangleFan3DPoint(x, y, z, r, g, b, nAlpha, { 0, 1.65 * 64, 0, nLeft * COMBAT_TEXT_UI_SCALE, nTop * COMBAT_TEXT_UI_SCALE}, nFont, v.szText, 1, fScale)
			end
			-- 合并伤害 后顶前
			if not v.bJump and v.szPoint ~= 'TOP' and nFrame >= 16 and nFrame <= 32 then
				for kk, vv in pairs(COMBAT_TEXT_SHADOW) do
					if k ~= kk
						and vv.nFrame <= 32
						and v.szPoint == vv.szPoint
						and not vv.bJump
						and v.nTime > vv.nTime
					then
						vv.bJump = true
					end
				end
			end
			if v.bJump and v.szPoint ~= 'TOP' and nFrame >= 16 and nFrame <= 32 then
				v.nTime = v.nTime - (32 - nFrame) * nDelay
			else
				v.nFrame = nFrame
			end
		else
			if v.szPoint == 'RIGHT' and v.dwTargetID == COMBAT_TEXT_PLAYERID then
				if v.eType == COMBAT_TEXT_TYPE.SKILL_BUFF and COMBAT_TEXT_CACHE.BUFF[v.szText] then
					COMBAT_TEXT_CACHE.BUFF[v.szText] = nil
				elseif v.eType == COMBAT_TEXT_TYPE.SKILL_DEBUFF and COMBAT_TEXT_CACHE.DEBUFF[v.szText] then
					COMBAT_TEXT_CACHE.DEBUFF[v.szText] = nil
				end
			end
			k.free = true
			COMBAT_TEXT_SHADOW[k] = nil
		end
	end
	for k, v in pairs(COMBAT_TEXT_QUEUE) do
		for kk, vv in pairs(v) do
			if #vv > 0 then
				local dat = table.remove(vv, 1)
				if dat.dat.szPoint == 'TOP' then
					local nSort, szPoint = D.GetTrajectory(dat.dat.dwTargetID)
					dat.dat.nSort   = nSort
					dat.dat.szPoint = szPoint
				end
				dat.dat.nTime = GetTime()
				COMBAT_TEXT_SHADOW[dat.shadow] = dat.dat
			else
				COMBAT_TEXT_QUEUE[k][kk] = nil
			end
		end
	end
end

D.OnFrameBreathe = D.OnFrameRender
D.OnFrameRender  = D.OnFrameRender

function D.UpdateTrajectoryCount()
	if D.bReady then
		COMBAT_TEXT_UI_SCALE   = Station.GetUIScale() * 0.6
		COMBAT_TEXT_TRAJECTORY = O.fScale < 1.5
			and math.floor(3.5 / COMBAT_TEXT_UI_SCALE / O.fScale)
			or math.floor(3.5 / COMBAT_TEXT_UI_SCALE)
	end
end


local function TrajectorySort(a, b)
	if a.nCount == b.nCount then
		return a.nSort < b.nSort
	else
		return a.nCount < b.nCount
	end
end

-- 最大程度上使用见缝插针效果 缺少缓存 待补充
function D.GetTrajectory(dwTargetID, bCriticalStrike)
	local tSort = {}
	local fRange = 1 / COMBAT_TEXT_TRAJECTORY
	for i = 1, COMBAT_TEXT_TRAJECTORY do
		tSort[i] = { nSort = i, nCount = 0, fRange = i * fRange }
	end
	for k, v in pairs(COMBAT_TEXT_SHADOW) do
		if v.dwTargetID == dwTargetID
			and v.szPoint == 'TOP'
			and v.nFrame < 15
		then
			local fSort = (COMBAT_TEXT_POINT.TOP[math.floor(v.nFrame) + 1] + v.nSort * fRange * COMBAT_TEXT_POINT.TOP[COMBAT_TEXT_TOTAL]) / COMBAT_TEXT_POINT.TOP[COMBAT_TEXT_TOTAL]
			for i = 1, COMBAT_TEXT_TRAJECTORY do
				if fSort < tSort[i].fRange then
					tSort[i].nCount = tSort[i].nCount + 1
					break
				end
			end
		end
	end
	table.sort(tSort, TrajectorySort)
	local nSort = tSort[1].nSort - 1
	local szPoint = 'TOP'
	if tSort[1].nCount == 1 then
		szPoint = Random(2) == 1 and 'TOP_LEFT' or 'TOP_RIGHT'
		nSort = 0
	end
	return nSort, szPoint
end

function D.CreateColorText(shadow, dwTargetID, szText, szPoint, eType, bCriticalStrike, tCol, bIsCombineText)
	local object, tPoint
	local bIsPlayer = X.IsPlayer(dwTargetID)
	if dwTargetID ~= COMBAT_TEXT_PLAYERID then
		object = bIsPlayer and X.GetPlayer(dwTargetID) or X.GetNpc(dwTargetID)
		if object and object.nX then
			tPoint = { object.nX, object.nY, object.nZ }
		end
	end
	local dat = {
		szPoint         = szPoint,
		nSort           = 0,
		dwTargetID      = dwTargetID,
		szText          = szText,
		eType           = eType,
		nFrame          = 0,
		bCriticalStrike = bCriticalStrike,
		col             = tCol or D.GetColor(eType, bCriticalStrike),
		object          = object,
		tPoint          = tPoint,
	}
	if dat.bCriticalStrike or bIsCombineText then
		if szPoint == 'TOP' and not bIsCombineText then
			local nSort, point = D.GetTrajectory(dat.dwTargetID, true)
			dat.nSort = nSort
			dat.szPoint = point
		end
		dat.nTime = GetTime()
		COMBAT_TEXT_SHADOW[shadow] = dat
	else
		COMBAT_TEXT_QUEUE[szPoint][dwTargetID] = COMBAT_TEXT_QUEUE[szPoint][dwTargetID] or {}
		table.insert(COMBAT_TEXT_QUEUE[szPoint][dwTargetID], { shadow = shadow, dat = dat })
	end
end

function D.CreateText(shadow, dwTargetID, szText, szPoint, eType, bCriticalStrike, bIsCombineText)
	return D.CreateColorText(shadow, dwTargetID, szText, szPoint, eType, bCriticalStrike, nil, bIsCombineText)
end

local SKILL_RESULT_TYPE_TO_COMBAT_TEXT_TYPE = X.KvpToObject({
	{SKILL_RESULT_TYPE.THERAPY             , COMBAT_TEXT_TYPE.THERAPY             },
	{SKILL_RESULT_TYPE.EFFECTIVE_THERAPY   , COMBAT_TEXT_TYPE.EFFECTIVE_THERAPY   },
	{SKILL_RESULT_TYPE.STEAL_LIFE          , COMBAT_TEXT_TYPE.STEAL_LIFE          },
	{SKILL_RESULT_TYPE.PHYSICS_DAMAGE      , COMBAT_TEXT_TYPE.PHYSICS_DAMAGE      },
	{SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE  , COMBAT_TEXT_TYPE.SOLAR_MAGIC_DAMAGE  },
	{SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE, COMBAT_TEXT_TYPE.NEUTRAL_MAGIC_DAMAGE},
	{SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE  , COMBAT_TEXT_TYPE.LUNAR_MAGIC_DAMAGE  },
	{SKILL_RESULT_TYPE.POISON_DAMAGE       , COMBAT_TEXT_TYPE.POISON_DAMAGE       },
	{SKILL_RESULT_TYPE.REFLECTIED_DAMAGE   , COMBAT_TEXT_TYPE.REFLECTED_DAMAGE    },
	{SKILL_RESULT_TYPE.SPIRIT              , COMBAT_TEXT_TYPE.SPIRIT              },
	{SKILL_RESULT_TYPE.STAYING_POWER       , COMBAT_TEXT_TYPE.STAYING_POWER       },
	{SKILL_RESULT_TYPE.SHIELD_DAMAGE       , COMBAT_TEXT_TYPE.SHIELD_DAMAGE       },
	{SKILL_RESULT_TYPE.ABSORB_DAMAGE       , COMBAT_TEXT_TYPE.ABSORB_DAMAGE       },
	{SKILL_RESULT_TYPE.PARRY_DAMAGE        , COMBAT_TEXT_TYPE.PARRY_DAMAGE        },
	{SKILL_RESULT_TYPE.INSIGHT_DAMAGE      , COMBAT_TEXT_TYPE.INSIGHT_DAMAGE      },
})

function D.AppendCombineTable(dwTargetID, szPoint, nValue, szText)
	-- 右下角治疗屏蔽
	if O.bEnableCombineText and not (szPoint == 'BOTTOM_RIGHT') then
		local key = dwTargetID .. '_' .. szPoint
		if not COMBAT_TEXT_COMBINE[key] then
			COMBAT_TEXT_COMBINE[key] = {
				dwTargetID = dwTargetID,
				szPoint = szPoint,
				nValue = 0,
				nCount = 0,
				aList = {} -- debug
			}
		end
		COMBAT_TEXT_COMBINE[key].nValue = COMBAT_TEXT_COMBINE[key].nValue + (X.IsNumber(nValue) and nValue or 0)
		COMBAT_TEXT_COMBINE[key].nCount = COMBAT_TEXT_COMBINE[key].nCount + 1
		table.insert(COMBAT_TEXT_COMBINE[key].aList, szText)
	end
end

function D.OnSkillText(dwCasterID, dwTargetID, bCriticalStrike, nSkillResultType, nValue, dwSkillID, dwSkillLevel, nEffectType)
	local eType = SKILL_RESULT_TYPE_TO_COMBAT_TEXT_TYPE[nSkillResultType]
	if not eType then
		return
	end
	-- 特定类型的招式过滤
	if (dwCasterID == COMBAT_TEXT_PLAYERID or nSkillResultType == SKILL_RESULT_TYPE.STEAL_LIFE)
	and COMBAT_TEXT_SKILL_TYPE_IGNORE[nSkillResultType] then
		return
	end
	-- 特定的招式过滤
	if dwCasterID == COMBAT_TEXT_PLAYERID and COMBAT_TEXT_SKILL_IGNORE[dwSkillID] then
		return
	end
	-- 有效治疗过滤
	if (eType == COMBAT_TEXT_TYPE.EFFECTIVE_THERAPY and not O.bTherapyEffectiveOnly)
	or (eType == COMBAT_TEXT_TYPE.THERAPY and O.bTherapyEffectiveOnly) then
		return
	end
	-- 过滤无效治疗
	if COMBAT_TEXT_TYPE_CLASS[eType] == 'THERAPY' and nValue == 0 then
		return
	end
	-- 八荒衡鉴优化：保留玩家自己的伤害，屏蔽受到的伤害和治疗
	if COMBAT_TEXT_IN_ROGUELIKE_MAP and (COMBAT_TEXT_TYPE_CLASS[eType] == 'THERAPY' or dwTargetID == COMBAT_TEXT_PLAYERID) and O.bOptimizeRoguelike then
		return
	end
	local bIsPlayer = X.IsPlayer(dwCasterID)
	local KCaster = bIsPlayer and X.GetPlayer(dwCasterID) or X.GetNpc(dwCasterID)
	local KEmployer, dwEmployerID
	if not bIsPlayer and KCaster then
		if O.bDisabledPartnerText and X.IsPartnerNpc(KCaster.dwTemplateID) then
			return
		end
		dwEmployerID = KCaster.dwEmployer
		if dwEmployerID ~= 0 then -- NPC要算归属圈
			KEmployer = X.GetPlayer(dwEmployerID)
		end
	end
	-- 过滤他人数据
	if (dwCasterID ~= COMBAT_TEXT_PLAYERID and dwTargetID ~= COMBAT_TEXT_PLAYERID and dwEmployerID ~= COMBAT_TEXT_PLAYERID)
	and not O.bOtherCharacter then
		return
	end
	local shadow = D.GetFreeShadow()
	if not shadow then -- 没有空闲的shadow
		return
	end

	local szSkillName, szText, szReplaceText, bStaticSign
	-- replace text / point / color
	local szPoint = 'TOP'
	-- skill type effect by class and presets
	if COMBAT_TEXT_SKILL_STATIC_STRING[nSkillResultType] then -- 需要变成特定字符串的伤害类型
		szText = COMBAT_TEXT_SKILL_STATIC_STRING[nSkillResultType]
		if dwTargetID == COMBAT_TEXT_PLAYERID then
			szPoint = 'LEFT'
		end
	elseif COMBAT_TEXT_TYPE_CLASS[eType] == 'THERAPY' then
		if dwTargetID == COMBAT_TEXT_PLAYERID then
			szPoint = 'BOTTOM_RIGHT'
		end
		szReplaceText = O.szTherapy
	elseif dwTargetID == COMBAT_TEXT_PLAYERID then
		szPoint = 'BOTTOM_LEFT'
		szReplaceText = O.szDamage
	else
		szReplaceText = O.szSkill
	end
	-- specific skill type overwrite
	if eType == COMBAT_TEXT_TYPE.STEAL_LIFE then -- 吸血技能偷取避免重复获取 浪费性能
		szSkillName = g_tStrings.SKILL_STEAL_LIFE
	elseif eType == COMBAT_TEXT_TYPE.SPIRIT then
		if dwTargetID == COMBAT_TEXT_PLAYERID then
			szPoint = 'BOTTOM_RIGHT'
		end
		szReplaceText = O.szSkill
		szSkillName = g_tStrings.SKILL_SPIRIT
		bStaticSign = true
	elseif eType == COMBAT_TEXT_TYPE.STAYING_POWER then
		if dwTargetID == COMBAT_TEXT_PLAYERID then
			szPoint = 'BOTTOM_RIGHT'
		end
		szReplaceText = O.szSkill
		szSkillName = g_tStrings.SKILL_STAYING_POWER
		bStaticSign = true
	end
	-- skill name fallback
	if not szSkillName then
		szSkillName = nEffectType == SKILL_EFFECT_TYPE.BUFF
			and Table_GetBuffName(dwSkillID, dwSkillLevel)
			or Table_GetSkillName(dwSkillID, dwSkillLevel)
	end
	if szPoint == 'BOTTOM_LEFT' then -- 左下角肯定是伤害
		-- 苍云反弹技能修正颜色
		if KCaster and KCaster.dwID ~= COMBAT_TEXT_PLAYERID and  KCaster.dwForceID == 21 and nEffectType ~= SKILL_EFFECT_TYPE.BUFF then
			local hSkill = GetSkill(dwSkillID, dwSkillLevel)
			if hSkill and hSkill.dwBelongSchool ~= 18 and hSkill.dwBelongSchool ~= 0 then
				eType = COMBAT_TEXT_TYPE.REFLECTED_DAMAGE
			end
		end
		if eType ~= COMBAT_TEXT_TYPE.REFLECTED_DAMAGE then
			eType = COMBAT_TEXT_TYPE.DAMAGE
		end
	end
	-- draw text
	if not szText then -- 还未被定义的
		local szCasterName = ''
		if KCaster then
			if KEmployer then
				szCasterName = KEmployer.szName
			else
				szCasterName = KCaster.szName
			end
		end
		if O.bCasterNotI and (COMBAT_TEXT_PLAYERID == dwCasterID or COMBAT_TEXT_PLAYERID == dwEmployerID) then
			szCasterName = ''
		end
		if O.bSnShorten2 then
			szSkillName = X.StringSubW(szSkillName, 1, 2) -- wstring是兼容台服的 台服utf-8
		end
		szText = szReplaceText
		szText = szText:gsub('(%s?)$crit(%s?)', (bCriticalStrike and '%1'.. g_tStrings.STR_CS_NAME .. '%2' or ''))
		szText = szText:gsub('$name', szCasterName)
		szText = szText:gsub('$sn', szSkillName)
		szText = szText:gsub('$val', (bStaticSign and X.IsNumber(nValue) and nValue > 0 and '+' or '') .. (nValue and D.GetTargetShowValue(nValue) or ''))
	end
	if COMBAT_TEXT_TYPE_CLASS[eType] ~= 'THERAPY' then
		D.AppendCombineTable(dwTargetID, szPoint, nValue, szText)
	end
	D.CreateText(shadow, dwTargetID, szText, szPoint, eType, bCriticalStrike)
end

function D.OnSkillBuff(dwCharacterID, bCanCancel, dwID, nLevel)
	-- 八荒衡鉴优化：保留玩家自己的伤害，屏蔽受到的伤害和治疗
	if COMBAT_TEXT_IN_ROGUELIKE_MAP and O.bOptimizeRoguelike then
		return
	end
	if not Table_BuffIsVisible(dwID, nLevel) then
		return
	end
	local tBuff = Table_GetBuff(dwID, nLevel)
	if tBuff and tBuff.bHideAddName and tBuff.bHideAddName ~= 0 then
		return
	end
	local szBuffName = Table_GetBuffName(dwID, nLevel)
	if szBuffName == '' then
		return
	end
	local tCache = bCanCancel and COMBAT_TEXT_CACHE.BUFF or COMBAT_TEXT_CACHE.DEBUFF
	if tCache[szBuffName] then
		return
	end
	local shadow = D.GetFreeShadow()
	if not shadow then -- 没有空闲的shadow
		return
	end
	tCache[szBuffName] = true
	D.CreateText(shadow, dwCharacterID, szBuffName, 'RIGHT', bCanCancel and COMBAT_TEXT_TYPE.SKILL_BUFF or COMBAT_TEXT_TYPE.SKILL_DEBUFF, false)
end

function D.OnSkillMiss(dwTargetID)
	-- 八荒衡鉴优化：保留玩家自己的伤害，屏蔽受到的伤害和治疗
	if COMBAT_TEXT_IN_ROGUELIKE_MAP and O.bOptimizeRoguelike then
		return
	end
	local shadow = D.GetFreeShadow()
	if not shadow then -- 没有空闲的shadow
		return
	end
	local szPoint = dwTargetID == COMBAT_TEXT_PLAYERID and 'LEFT' or 'TOP'
	D.CreateText(shadow, dwTargetID, g_tStrings.STR_MSG_MISS, szPoint, COMBAT_TEXT_TYPE.SKILL_MISS, false)
end

function D.OnBuffImmunity(dwTargetID)
	-- 八荒衡鉴优化：保留玩家自己的伤害，屏蔽受到的伤害和治疗
	if COMBAT_TEXT_IN_ROGUELIKE_MAP and O.bOptimizeRoguelike then
		return
	end
	local shadow = D.GetFreeShadow()
	if not shadow then -- 没有空闲的shadow
		return
	end
	D.CreateText(shadow, dwTargetID, g_tStrings.STR_MSG_IMMUNITY, 'LEFT', COMBAT_TEXT_TYPE.BUFF_IMMUNITY, false)
end

-- FireUIEvent('COMMON_HEALTH_TEXT', X.GetClientPlayer().dwID, -8888)
function D.OnCommonHealth(dwCharacterID, nDeltaLife)
	-- 八荒衡鉴优化：保留玩家自己的伤害，屏蔽受到的伤害和治疗
	if COMBAT_TEXT_IN_ROGUELIKE_MAP and O.bOptimizeRoguelike then
		return
	end
	if nDeltaLife < 0 and not IsCombatTextPlayerID(dwCharacterID) then
		return
	end
	local shadow = D.GetFreeShadow()
	if not shadow then -- 没有空闲的shadow
		return
	end
	local szPoint = 'BOTTOM_LEFT'
	if nDeltaLife > 0 then
		if dwCharacterID ~= COMBAT_TEXT_PLAYERID then
			szPoint = 'TOP'
		else
			szPoint = 'BOTTOM_RIGHT'
		end
	end
	local szText = (nDeltaLife > 0 and '+' or '') .. D.GetTargetShowValue(nDeltaLife)
	local eType  = nDeltaLife > 0 and COMBAT_TEXT_TYPE.THERAPY or COMBAT_TEXT_TYPE.DAMAGE
	D.CreateText(shadow, dwCharacterID, szText, szPoint, eType, false)
end

function D.OnSkillDodge(dwTargetID)
	-- 八荒衡鉴优化：保留玩家自己的伤害，屏蔽受到的伤害和治疗
	if COMBAT_TEXT_IN_ROGUELIKE_MAP and O.bOptimizeRoguelike then
		return
	end
	local shadow = D.GetFreeShadow()
	if not shadow then -- 没有空闲的shadow
		return
	end
	D.CreateText(shadow, dwTargetID, g_tStrings.STR_MSG_DODGE, 'LEFT', COMBAT_TEXT_TYPE.SKILL_DODGE, false)
end

function D.OnExpLog(dwCharacterID, nExp)
	local shadow = D.GetFreeShadow()
	if not shadow then -- 没有空闲的shadow
		return
	end
	D.CreateText(shadow, dwCharacterID, g_tStrings.STR_COMBATMSG_EXP .. nExp, 'CENTER', COMBAT_TEXT_TYPE.EXP, true)
end

function D.CreateMessage(szText, tOptions)
	local shadow = D.GetFreeShadow()
	if not shadow then -- 没有空闲的shadow
		return
	end
	local dwTargetID = tOptions.dwTargetID or COMBAT_TEXT_PLAYERID
	local szPosition = tOptions.szPosition or 'CENTER'
	local bCritical = tOptions.bCritical or false
	local eType = bCritical and COMBAT_TEXT_TYPE.CRITICAL_MSG or COMBAT_TEXT_TYPE.MSG
	local tColor = tOptions.tColor
	D.CreateColorText(shadow, dwTargetID, szText, szPosition, eType, bCritical, tColor)
end

-- 获取的是否是合并的伤害
function D.GetFreeShadow(bIsCombineText)
	if not bIsCombineText then
		for k, v in ipairs(COMBAT_TEXT_FREE) do
			if v.free then
				v.free = false
				return v
			end
		end
	end

	if bIsCombineText or (O.nMaxCount > 0 and #COMBAT_TEXT_FREE < O.nMaxCount) then
		local handle = D.handle
		local sha = handle:AppendItemFromIni(COMBAT_TEXT_INIFILE, bIsCombineText and 'Shadow_Content' or 'Shadow_Content_2')
		sha:SetTriangleFan(GEOMETRY_TYPE.TEXT)
		sha:ClearTriangleFanPoint()
		table.insert(COMBAT_TEXT_FREE, sha)
		return sha
	end
end

function D.LoadConfig()
	local bExist = IsFileExist(COMBAT_TEXT_CONFIG)
	if bExist then
		local data = LoadLUAData(COMBAT_TEXT_CONFIG)
		if data then
			COMBAT_TEXT_CRITICAL          = data.COMBAT_TEXT_CRITICAL            or COMBAT_TEXT_CRITICAL
			COMBAT_TEXT_SCALE             = data.COMBAT_TEXT_SCALE               or COMBAT_TEXT_SCALE
			COMBAT_TEXT_POINT             = data.COMBAT_TEXT_POINT               or COMBAT_TEXT_POINT
			COMBAT_TEXT_EVENT             = data.COMBAT_TEXT_EVENT               or COMBAT_TEXT_EVENT
			COMBAT_TEXT_SKILL_IGNORE      = data.COMBAT_TEXT_SKILL_IGNORE        or {}
			COMBAT_TEXT_SKILL_TYPE_IGNORE = data.COMBAT_TEXT_SKILL_TYPE_IGNORE   or {}
			COMBAT_TEXT_COLOR             = data.COMBAT_TEXT_COLOR               or COMBAT_TEXT_COLOR
			COMBAT_TEXT_CRITICAL_COLOR    = data.COMBAT_TEXT_CRITICAL_COLOR      or COMBAT_TEXT_CRITICAL_COLOR
			X.OutputSystemMessage(_L['Combat text config loaded.'])
		else
			X.OutputSystemMessage(_L['Combat text config failed.'])
		end
	end
end

function D.CheckEnable()
	local ui = Station.Lookup('Lowest/MY_CombatText')
	if IsEnabled() then
		if O.bRender then
			COMBAT_TEXT_INIFILE = X.PACKET_INFO.ROOT .. 'MY_CombatText/ui/MY_CombatText_Render.ini'
		else
			COMBAT_TEXT_INIFILE = X.PACKET_INFO.ROOT .. 'MY_CombatText/ui/MY_CombatText.ini'
		end
		COMBAT_TEXT_SCALE.CRITICAL = COMBAT_TEXT_STYLES[O.nStyle] and COMBAT_TEXT_STYLES[O.nStyle] or COMBAT_TEXT_STYLES[0]
		D.LoadConfig()
		if ui then
			X.UI.CloseFrame(ui)
		end
		X.UI.OpenFrame(COMBAT_TEXT_INIFILE, 'MY_CombatText')
		D.HideOfficialCombat()
	else
		if ui then
			D.FreeQueue()
			X.UI.CloseFrame(ui)
			X.BreatheCall('COMBAT_TEXT_CACHE', false)
			X.BreatheCall('COMBAT_TEXT_COMBINE', false)
			collectgarbage('collect')
		end
		D.ShowOfficialCombat()
	end
	setmetatable(COMBAT_TEXT_POINT, { __index = function(me, key)
		if key == 'TOP_LEFT' or key == 'TOP_RIGHT' then
			return me['TOP']
		end
	end })
	local mt = { __index = function(me)
		return me[#me]
	end }
	setmetatable(COMBAT_TEXT_SCALE.CRITICAL, mt)
	setmetatable(COMBAT_TEXT_SCALE.NORMAL,   mt)
end


--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_CombatText',
	exports = {
		{
			preset = 'UIEvent',
			fields = {
				'CreateMessage',
			},
			root = D,
		},
	},
}
MY_CombatText = X.CreateModule(settings)
end


local PS = {}
function PS.OnPanelActive(frame)
	local ui = X.UI(frame)
	local nW, nH = ui:Size()
	local nPaddingX, nPaddingY = 20, 10
	local nX, nY = nPaddingX, nPaddingY
	local nDeltaY = 28
	local nChapterPaddingTop = 5
	local nChapterPaddingBottom = 3

	ui:Append('Text', { x = nX, y = nY, text = _L['Combat text'], font = 27 })
	nX = nX + 10
	nY = nY + nDeltaY + nChapterPaddingBottom

	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Enable combat text'],
		color = { 255, 128, 0 },
		checked = O.bEnable,
		onCheck = function(bCheck)
			O.bEnable = bCheck
			D.CheckEnable()
		end,
	}):Width() + 5

	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Enable render'],
		checked = O.bRender,
		onCheck = function(bCheck)
			O.bRender = bCheck
			D.CheckEnable()
		end,
		autoEnable = IsEnabled,
	}):Width() + 5
	nY = nY + nDeltaY

	nX = nPaddingX + 10
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Only show my related combat text'],
		checked = not O.bOtherCharacter,
		onCheck = function(bCheck)
			O.bOtherCharacter = not bCheck
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Disable immunity'],
		checked = O.bImmunity,
		onCheck = function(bCheck)
			O.bImmunity = bCheck
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Optimize in roguelike'],
		checked = O.bOptimizeRoguelike,
		onCheck = function(bCheck)
			O.bOptimizeRoguelike = bCheck
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	-- 显示合并文本
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Show combine text'],
		checked = O.bEnableCombineText,
		tip = {
			render = _L['Combine the same time combat text'],
			position = X.UI.TIP_POSITION.TOP_BOTTOM,
		},
		onCheck = function(bCheck)
			O.bEnableCombineText = bCheck
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Disable partner text'],
		checked = O.bDisabledPartnerText,
		onCheck = function(bCheck)
			O.bDisabledPartnerText = bCheck
		end,
		autoEnable = IsEnabled,
	}):Width() + 5


	nY = nY + nDeltaY

	nX = nPaddingX + 10
	ui:Append('Text', { x = nX, y = nY, text = g_tStrings.STR_QUESTTRACE_CHANGE_ALPHA, color = { 255, 255, 200 }, autoEnable = IsEnabled })
	nX = nX + 70
	ui:Append('WndSlider', {
		x = nX, y = nY, text = '',
		range = {1, 255},
		sliderStyle = X.UI.SLIDER_STYLE.SHOW_VALUE,
		value = O.nMaxAlpha,
		onChange = function(nVal)
			O.nMaxAlpha = nVal
		end,
		autoEnable = IsEnabled,
	})

	nX = nX + 180
	ui:Append('Text', { x = nX, y = nY, text = _L['Hold time'], color = { 255, 255, 200 }, autoEnable = IsEnabled })
	nX = nX + 70
	ui:Append('WndSlider', {
		x = nX, y = nY, textFormatter = function(val) return val .. _L['ms'] end,
		range = {700, 2500},
		sliderStyle = X.UI.SLIDER_STYLE.SHOW_VALUE,
		value = O.nTime * COMBAT_TEXT_TOTAL,
		onChange = function(nVal)
			O.nTime = nVal / COMBAT_TEXT_TOTAL
		end,
		autoEnable = IsEnabled,
	})
	nY = nY + nDeltaY

	nX = nPaddingX + 10
	ui:Append('Text', { x = nX, y = nY, text = _L['Fade in time'], color = { 255, 255, 200 }, autoEnable = IsEnabled })
	nX = nX + 70
	ui:Append('WndSlider', {
		x = nX, y = nY, textFormatter = function(val) return val .. _L['frame'] end,
		range = {0, 15},
		sliderStyle = X.UI.SLIDER_STYLE.SHOW_VALUE,
		value = O.nFadeIn,
		onChange = function(nVal)
			O.nFadeIn = nVal
		end,
		autoEnable = IsEnabled,
	})

	nX = nX + 180
	ui:Append('Text', { x = nX, y = nY, text = _L['Fade out time'], color = { 255, 255, 200 }, autoEnable = IsEnabled })
	nX = nX + 70
	ui:Append('WndSlider', {
		x = nX, y = nY, textFormatter = function(val) return val .. _L['frame'] end,
		rang = {0, 15},
		sliderStyle = X.UI.SLIDER_STYLE.SHOW_VALUE,
		value = O.nFadeOut,
		onChange = function(nVal)
			O.nFadeOut = nVal
		end,
		autoEnable = IsEnabled,
	})
	nY = nY + nDeltaY

	nX = nPaddingX + 10
	ui:Append('Text', { x = nX, y = nY, text = _L['Font size'], color = { 255, 255, 200 }, autoEnable = IsEnabled })
	nX = nX + 70
	ui:Append('WndSlider', {
		x = nX, y = nY, textFormatter = function(val) return (val / 100) .. _L['times'] end,
		range = {50, 200},
		sliderStyle = X.UI.SLIDER_STYLE.SHOW_VALUE,
		value = O.fScale * 100,
		onChange = function(nVal)
			O.fScale = nVal / 100
			D.UpdateTrajectoryCount()
		end,
		autoEnable = IsEnabled,
	})
	nX = nX + 180

	ui:Append('Text', {
		x = nX, y = nY,
		text = _L['Max count'],
		tip = {
			render = _L['Max same time combat text count limit'],
			position = X.UI.TIP_POSITION.TOP_BOTTOM,
		},
		color = { 255, 255, 200 },
		autoEnable = IsEnabled,
	})
	nX = nX + 70
	ui:Append('WndSlider', {
		x = nX, y = nY, text = '',
		textFormatter = function(val)
			return val == 0
				and _L['Limitless']
				or _L('Limit to %d', val)
		end,
		range = {0, 500},
		sliderStyle = X.UI.SLIDER_STYLE.SHOW_VALUE,
		value = O.nMaxCount,
		onChange = function(nVal)
			O.nMaxCount = nVal
		end,
		autoEnable = IsEnabled,
	})
	nY = nY + nDeltaY

	nX = nPaddingX + 10
	ui:Append('Text', { x = nX, y = nY, text = _L['Critical style'], color = { 255, 255, 200 }, autoEnable = IsEnabled })
	nX = nX + 70

	nX = nX + ui:Append('WndRadioBox', {
		x = nX, y = nY, text = _L['Hit feel'],
		group = 'style',
		checked = O.nStyle == 0,
		onCheck = function()
			O.nStyle = 0
			COMBAT_TEXT_SCALE.CRITICAL = COMBAT_TEXT_STYLES[0]
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	nX = nX + ui:Append('WndRadioBox', {
		x = nX, y = nY, text = _L['Low hit feel'],
		group = 'style',
		checked = O.nStyle == 1,
		onCheck = function()
			O.nStyle = 1
			COMBAT_TEXT_SCALE.CRITICAL = COMBAT_TEXT_STYLES[1]
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	nX = nX + ui:Append('WndRadioBox', {
		x = nX, y = nY, text = _L['Soft'],
		group = 'style',
		checked = O.nStyle == 2,
		onCheck = function()
			O.nStyle = 2
			COMBAT_TEXT_SCALE.CRITICAL = COMBAT_TEXT_STYLES[2]
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	ui:Append('WndRadioBox', {
		x = nX, y = nY, text = _L['Scale only'],
		group = 'style',
		checked = O.nStyle == 3,
		onCheck = function()
			O.nStyle = 3
			COMBAT_TEXT_SCALE.CRITICAL = COMBAT_TEXT_STYLES[3]
		end,
		autoEnable = IsEnabled,
	})
	nX = nX + 90
	nY = nY + nDeltaY

	nX = nPaddingX
	nY = nY + nChapterPaddingTop
	nX = nX + ui:Append('Text', { x = nX, y = nY, w = 'auto', text = _L['Text style'], font = 27, autoEnable = IsEnabled }):Width() + 5
	nX = nX + ui:Append('Text', {
		x = nX, y = nY,
		text = _L['Tips: $name means caster\'s name, $sn means skill name, $crit means critical, $val means value.'],
		color = { 196, 196, 196 },
		autoEnable = IsEnabled,
	}):Width() + 5
	nY = nY + nDeltaY + nChapterPaddingBottom

	nX = nPaddingX + 10
	ui:Append('Text', { x = nX, y = nY, text = _L['Skill style'], color = { 255, 255, 200 }, autoEnable = IsEnabled })
	nX = nX + 110
	ui:Append('WndEditBox', {
		x = nX, y = nY, w = 250, h = 25, text = O.szSkill, limit = 30,
		onChange = function(szText)
			O.szSkill = szText
		end,
		autoEnable = IsEnabled,
	})
	nX = nX + 250
	nY = nY + nDeltaY

	nX = nPaddingX + 10
	ui:Append('Text', { x = nX, y = nY, text = _L['Damage style'], color = { 255, 255, 200 }, autoEnable = IsEnabled })
	nX = nX + 110
	ui:Append('WndEditBox', {
		x = nX, y = nY, w = 250, h = 25, text = O.szDamage, limit = 30,
		onChange = function(szText)
			O.szDamage = szText
		end,
		autoEnable = IsEnabled,
	})
	nX = nX + 250
	nY = nY + nDeltaY

	nX = nPaddingX + 10
	ui:Append('Text', { x = nX, y = nY, text = _L['Therapy style'], color = { 255, 255, 200 }, autoEnable = IsEnabled })
	nX = nX + 110
	ui:Append('WndEditBox', {
		x = nX, y = nY, w = 250, h = 25, text = O.szTherapy, limit = 30,
		onChange = function(szText)
			O.szTherapy = szText
		end,
		autoEnable = IsEnabled,
	})
	nX = nX + 250
	nY = nY + nDeltaY

	nX = nPaddingX + 10
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, text = _L['$name not me'], checked = O.bCasterNotI,
		onCheck = function(bCheck)
			O.bCasterNotI = bCheck
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, text = _L['$sn shorten(2)'], checked = O.bSnShorten2,
		onCheck = function(bCheck)
			O.bSnShorten2 = bCheck
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, text = _L['Simplify value'], checked = O.bSimplifyValue,
		onCheck = function(bCheck)
			O.bSimplifyValue = bCheck
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, text = _L['Therapy effective only'], checked = O.bTherapyEffectiveOnly,
		onCheck = function(bCheck)
			O.bTherapyEffectiveOnly = bCheck
		end,
		autoEnable = IsEnabled,
	}):Width() + 5

	nX = nX + ui:Append('WndButton', {
		x = nX, y = nY, h = 24,
		text = _L['Font edit'],
		buttonStyle = 'FLAT',
		onClick = function()
			X.UI.OpenFontPicker(function(nFont)
				O.nFont = nFont
			end)
		end,
		tip = {
			render = function() return _L('Current font: %d', O.nFont) end,
			position = X.UI.TIP_POSITION.TOP_BOTTOM,
		},
		autoEnable = IsEnabled,
	}):Width() + 5
	nY = nY + nDeltaY

	nX = nPaddingX
	nY = nY + nChapterPaddingTop
	nX = nX + ui:Append('Text', { x = nX, y = nY, h = 24, text = _L['Color edit'], font = 27, autoEnable = IsEnabled }):Width() + 10
	nX = nX + 10

	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY + 2, h = 24,
		text = _L['Distinct critical color'],
		checked = O.bCritical,
		onCheck = function(bCheck)
			O.bCritical = bCheck
			X.Panel.Show()
			X.Panel.Focus()
			X.Panel.SwitchTab('MY_CombatText', true)
		end,
		autoEnable = IsEnabled,
	}):Width() + 10
	nX = nX + ui:Append('WndButton', {
		x = nX, y = nY + 2, w = 'auto', h = 24,
		text = _L['Reset color'],
		buttonStyle = 'FLAT',
		onClick = function()
			O('reset', { 'tColor', 'tCriticalColor' })
			X.Panel.Show()
			X.Panel.Focus()
			X.Panel.SwitchTab('MY_CombatText', true)
		end,
		autoEnable = IsEnabled,
	}):Width() + 10
	nY = nY + nDeltaY + nChapterPaddingBottom

	nX = nPaddingX + 20
	for _, eType in ipairs({
		COMBAT_TEXT_TYPE.DAMAGE               ,
		COMBAT_TEXT_TYPE.THERAPY              ,
		COMBAT_TEXT_TYPE.EFFECTIVE_THERAPY    ,
		COMBAT_TEXT_TYPE.STEAL_LIFE           ,
		COMBAT_TEXT_TYPE.PHYSICS_DAMAGE       ,
		COMBAT_TEXT_TYPE.SOLAR_MAGIC_DAMAGE   ,
		COMBAT_TEXT_TYPE.NEUTRAL_MAGIC_DAMAGE ,
		COMBAT_TEXT_TYPE.LUNAR_MAGIC_DAMAGE   ,
		COMBAT_TEXT_TYPE.POISON_DAMAGE        ,
		COMBAT_TEXT_TYPE.REFLECTED_DAMAGE     ,
	}) do
		if nX > nW - 100 then
			nX = nPaddingX + 20
			nY = nY + 25
		end
		local uiCritical
		ui:Append('Shadow', {
			x = nX, y = nY, color = D.GetColor(eType, false), w = 15, h = 15,
			onClick = function()
				local this = this
				X.UI.OpenColorPicker(function(r, g, b)
					O.tColor[eType] = { r, g, b }
					O.tColor = O.tColor
					if uiCritical then
						uiCritical:Color(D.GetColor(eType, true))
					end
					X.UI(this):Color(r, g, b)
				end)
			end,
			autoEnable = IsEnabled,
		})
		nX = nX + 20
		if O.bCritical then
			uiCritical = ui:Append('Shadow', {
				x = nX, y = nY, color = D.GetColor(eType, true), w = 15, h = 15,
				tip = {
					render = _L['Critical color'],
					position = X.UI.TIP_POSITION.BOTTOM_TOP,
				},
				onClick = function()
					local this = this
					X.UI.OpenColorPicker(function(r, g, b)
						O.tCriticalColor[eType] = { r, g, b }
						O.tCriticalColor = O.tCriticalColor
						X.UI(this):Color(r, g, b)
					end)
				end,
				autoEnable = IsEnabled,
			})
			nX = nX + 20
		end
		nX = nX + math.max(ui:Append('Text', {
			x = nX, y = nY, h = 15,
			text = COMBAT_TEXT_TYPE_NAME[eType],
			autoEnable = IsEnabled,
		}):Width() + 10, 100)
	end
	nY = nY + 30

	nX = nPaddingX + 20
	for _, eType in ipairs({
		COMBAT_TEXT_TYPE.SPIRIT               ,
		COMBAT_TEXT_TYPE.STAYING_POWER        ,
		COMBAT_TEXT_TYPE.SHIELD_DAMAGE        ,
		COMBAT_TEXT_TYPE.ABSORB_DAMAGE        ,
		COMBAT_TEXT_TYPE.PARRY_DAMAGE         ,
		COMBAT_TEXT_TYPE.INSIGHT_DAMAGE       ,
		COMBAT_TEXT_TYPE.SKILL_DODGE          ,
		COMBAT_TEXT_TYPE.SKILL_BUFF           ,
		COMBAT_TEXT_TYPE.SKILL_DEBUFF         ,
		COMBAT_TEXT_TYPE.BUFF_IMMUNITY        ,
		COMBAT_TEXT_TYPE.SKILL_MISS           ,
		COMBAT_TEXT_TYPE.EXP                  ,
		COMBAT_TEXT_TYPE.MSG                  ,
		COMBAT_TEXT_TYPE.CRITICAL_MSG         ,
	}) do
		if nX > nW - 100 then
			nX = nPaddingX + 20
			nY = nY + 25
		end
		ui:Append('Shadow', {
			x = nX, y = nY, color = D.GetColor(eType, false), w = 15, h = 15,
			onClick = function()
				local this = this
				X.UI.OpenColorPicker(function(r, g, b)
					O.tColor[eType] = { r, g, b }
					O.tColor = O.tColor
					X.UI(this):Color(r, g, b)
				end)
			end,
			autoEnable = IsEnabled,
		})
		nX = nX + 20
		nX = nX + math.max(ui:Append('Text', {
			x = nX, y = nY, h = 15,
			text = COMBAT_TEXT_TYPE_NAME[eType],
			autoEnable = IsEnabled,
		}):Width() + 10, 100)
	end
	nY = nY + 30

	ui:Append('WndWindow', { x = nX, y = nY + 10, w = nW, h = 0 }) -- 剑三的滚动有问题，必须使用一个 Wnd 才能触发滚动。。

	if IsFileExist(COMBAT_TEXT_CONFIG) then
		ui:Append('WndButton', {
			x = nW - 130 - nPaddingX, y = 15, h = 40,
			text = _L['Reload combat text config'],
			buttonStyle = 'SKEUOMORPHISM_LACE_BORDER',
			onClick = D.CheckEnable,
		})
	end
end
X.Panel.Register(_L['System'], 'MY_CombatText', _L['MY_CombatText'], 2041, PS)

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

local function OnLoadingEnding()
	local me = X.GetControlPlayer()
	if not me then
		--[[#DEBUG BEGIN]]
		X.OutputDebugMessage('CombatText get player id failed!!! try again', X.DEBUG_LEVEL.ERROR)
		--[[#DEBUG END]]
		X.DelayCall(1000, OnLoadingEnding)
		return
	end
	COMBAT_TEXT_PLAYERID = me.dwID
	--[[#DEBUG BEGIN]]
	-- X.OutputDebugMessage('CombatText get player id ' .. me.dwID, X.DEBUG_LEVEL.LOG)
	--[[#DEBUG END]]
	COMBAT_TEXT_IN_ROGUELIKE_MAP = X.IsInRoguelikeMap()
end
X.RegisterUserSettingsInit('MY_CombatText', function()
	D.bReady = true
	D.UpdateTrajectoryCount()
	D.CheckEnable()
end)
X.RegisterEvent('LOADING_ENDING', 'MY_CombatText', OnLoadingEnding) -- 很重要的优化
X.RegisterEvent('ON_NEW_PROXY_SKILL_LIST_NOTIFY', 'MY_CombatText', OnLoadingEnding) -- 长歌控制主体ID切换
X.RegisterEvent('ON_CLEAR_PROXY_SKILL_LIST_NOTIFY', 'MY_CombatText', OnLoadingEnding) -- 长歌控制主体ID切换
X.RegisterEvent('ON_PVP_SHOW_SELECT_PLAYER', 'MY_CombatText', function()
	COMBAT_TEXT_PLAYERID = arg0
end)
X.RegisterEvent('FIRST_LOADING_END', 'MY_CombatText', D.CheckEnable)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
