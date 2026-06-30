--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 团队监控核心
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @ref      : William Chan (Webster)
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_TeamMon/MY_TeamMon'
local PLUGIN_NAME = 'MY_TeamMon'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_TeamMon'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.1') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local bRestricted = false
X.RegisterRestriction('MY_TeamMon', { ['*'] = false })
X.RegisterRestriction('MY_TeamMon.Cataclysm', { ['*'] = false, exp = false })
X.RegisterRestriction('MY_TeamMon.MapRestriction', { ['*'] = true })
X.RegisterRestriction('MY_TeamMon.HiddenBuff', { ['*'] = true })
X.RegisterRestriction('MY_TeamMon.HiddenSkill', { ['*'] = true })
X.RegisterRestriction('MY_TeamMon.HiddenDoodad', { ['*'] = true })
X.RegisterRestriction('MY_TeamMon.Note', { ['*'] = true })
X.RegisterRestriction('MY_TeamMon.AutoSelect', { ['*'] = true })
X.RegisterRestriction('MY_TeamMon_ScreenHeadAlarm', { ['*'] = false })
--------------------------------------------------------------------------

local MY_SplitString, MY_TrimString = X.SplitString, X.TrimString
local MY_GetFormatText, MY_GetPureText = X.GetFormatText, X.GetPureText
local FireUIEvent, MY_IsVisibleBuff, Table_IsSkillShow = FireUIEvent, X.IsVisibleBuff, Table_IsSkillShow
local GetHeadTextForceFontColor, TargetPanel_SetOpenState = GetHeadTextForceFontColor, TargetPanel_SetOpenState

local MY_TEAM_MON_REMOTE_DATA_ROOT = X.FormatPath({'userdata/team_mon/remote/', X.PATH_TYPE.GLOBAL})
local MY_TEAM_MON_TYPE = {
	OTHER           = 0,
	BUFF_GET        = 1,
	BUFF_LOSE       = 2,
	NPC_ENTER       = 3,
	NPC_LEAVE       = 4,
	NPC_TALK        = 5,
	NPC_LIFE        = 6,
	NPC_FIGHT       = 7,
	SKILL_BEGIN     = 8,
	SKILL_END       = 9,
	SYS_TALK        = 10,
	NPC_ALLLEAVE    = 11,
	NPC_DEATH       = 12,
	NPC_ALLDEATH    = 13,
	TALK_MONITOR    = 14,
	COMMON          = 15,
	NPC_MANA        = 16,
	DOODAD_ENTER    = 17,
	DOODAD_LEAVE    = 18,
	DOODAD_ALLLEAVE = 19,
	CHAT_MONITOR    = 20,
}
local MY_TEAM_MON_SCRUTINY_TYPE = { SELF = 1, TEAM = 2, ENEMY = 3, TARGET = 4 }
local MY_TEAM_MON_SPECIAL_MAP = {
	COMMON          =  -1, -- 通用
	CITY            =  -2, -- 主城
	DUNGEON         =  -3, -- 秘境
	TEAM_DUNGEON    =  -4, -- 小队秘境
	RAID_DUNGEON    =  -5, -- 团队秘境
	STARVE          =  -6, -- 浪客行
	VILLAGE         =  -7, -- 野外
	ARENA           =  -8, -- 名剑大会
	BATTLEFIELD     = -10, -- 战场
	PUBG            = -11, -- 绝境战场
	ZOMBIE          = -12, -- 李渡鬼域
	MONSTER         = -13, -- 百战
	MOBA            = -14, -- 列星虚境
	HOMELAND        = -15, -- 家园
	ROGUELIKE       = -16, -- 八荒衡鉴
	COMPETITION     = -17, -- 竞技
	GUILD_TERRITORY = -18, -- 帮会领地
	CAMP            = -19, -- 阵营地图
	STRONGHOLD      = -20, -- 据点地图
	SCHOOL		    = -21, -- 门派地图
	RECYCLE_BIN     =  -9, -- 回收站
}
local MY_TEAM_MON_SPECIAL_MAP_NAME = {
	[MY_TEAM_MON_SPECIAL_MAP.COMMON         ] = _L['Common data'],
	[MY_TEAM_MON_SPECIAL_MAP.CITY           ] = _L['City data'],
	[MY_TEAM_MON_SPECIAL_MAP.DUNGEON        ] = _L['Dungeon data'],
	[MY_TEAM_MON_SPECIAL_MAP.TEAM_DUNGEON   ] = _L['Team dungeon data'],
	[MY_TEAM_MON_SPECIAL_MAP.RAID_DUNGEON   ] = _L['Raid dungeon data'],
	[MY_TEAM_MON_SPECIAL_MAP.STARVE         ] = _L['Starve data'],
	[MY_TEAM_MON_SPECIAL_MAP.VILLAGE        ] = _L['Village data'],
	[MY_TEAM_MON_SPECIAL_MAP.ARENA          ] = _L['Arena data'],
	[MY_TEAM_MON_SPECIAL_MAP.BATTLEFIELD    ] = _L['Battlefield data'],
	[MY_TEAM_MON_SPECIAL_MAP.PUBG           ] = _L['Pubg data'],
	[MY_TEAM_MON_SPECIAL_MAP.ZOMBIE         ] = _L['Zombie data'],
	[MY_TEAM_MON_SPECIAL_MAP.MONSTER        ] = _L['Monster data'],
	[MY_TEAM_MON_SPECIAL_MAP.MOBA           ] = _L['Moba data'],
	[MY_TEAM_MON_SPECIAL_MAP.HOMELAND       ] = _L['Homeland data'],
	[MY_TEAM_MON_SPECIAL_MAP.GUILD_TERRITORY] = _L['Guild territory data'],
	[MY_TEAM_MON_SPECIAL_MAP.ROGUELIKE      ] = _L['Roguelike data'],
	[MY_TEAM_MON_SPECIAL_MAP.COMPETITION    ] = _L['Competition data'],
	[MY_TEAM_MON_SPECIAL_MAP.CAMP           ] = _L['Camp data'],
	[MY_TEAM_MON_SPECIAL_MAP.STRONGHOLD     ] = _L['Stronghold data'],
	[MY_TEAM_MON_SPECIAL_MAP.SCHOOL         ] = _L['School data'],
	[MY_TEAM_MON_SPECIAL_MAP.RECYCLE_BIN    ] = _L['Recycle bin data'],
}
local MY_TEAM_MON_SPECIAL_MAP_INFO = {}
for _, dwMapID in pairs(MY_TEAM_MON_SPECIAL_MAP) do
	local map = X.FreezeTable({
		dwID = dwMapID,
		dwMapID = dwMapID,
		szName = MY_TEAM_MON_SPECIAL_MAP_NAME[dwMapID],
	})
	MY_TEAM_MON_SPECIAL_MAP_INFO[map.szName] = map
	MY_TEAM_MON_SPECIAL_MAP_INFO[map.dwMapID] = map
end
-- 核心优化变量
local MY_TEAM_MON_CORE_PLAYERID = 0
local MY_TEAM_MON_CORE_NAME     = 0

local MY_TEAM_MON_MAX_INTERVAL  = 300
local MY_TEAM_MON_MAX_CACHE     = 3000 -- 最大的cache数量 主要是UI的问题
local MY_TEAM_MON_DEL_CACHE     = 1000 -- 每次清理的数量 然后会做一次gc
local MY_TEAM_MON_INI_FILE      = X.PACKET_INFO.ROOT .. 'MY_TeamMon/ui/MY_TeamMon.ini'

local MY_TEAM_MON_SHARE_QUEUE  = {}
local MY_TEAM_MON_MARK_QUEUE   = {}
local MY_TEAM_MON_MARK_IDLE    = true -- 标记空闲

local MY_TEAM_MON_SHIELDED_TOTAL             = false -- 标记当前在功能限制状态 限制所有功能监听
local MY_TEAM_MON_SHIELDED_OTHER_PLAYER      = false -- 标记当前在可能发生PVP战斗的地图 限制他人战斗功能监听
local MY_TEAM_MON_SHIELDED_ENTER_LEAVE_SCENE = false -- 标记当前在功能限制状态 限制场景目标进出功能监听
----
local MY_TEAM_MON_LEFT_BRACKET      = _L['[']
local MY_TEAM_MON_RIGHT_BRACKET     = _L[']']
local MY_TEAM_MON_LEFT_BRACKET_XML  = MY_GetFormatText(MY_TEAM_MON_LEFT_BRACKET, 44, 255, 255, 255)
local MY_TEAM_MON_RIGHT_BRACKET_XML = MY_GetFormatText(MY_TEAM_MON_RIGHT_BRACKET, 44, 255, 255, 255)
----
local MY_TEAM_MON_TYPE_LIST = { 'BUFF', 'DEBUFF', 'CASTING', 'NPC', 'DOODAD', 'TALK', 'CHAT' }

local MY_TEAM_MON_EVENTS = {
	'NPC_ENTER_SCENE',
	'NPC_LEAVE_SCENE',
	'MY_TEAM_MON_NPC_FIGHT',
	'MY_TEAM_MON_NPC_ENTER_SCENE',
	'MY_TEAM_MON_ALL_LEAVE_SCENE',
	'MY_TEAM_MON_NPC_LIFE_CHANGE',
	'MY_TEAM_MON_NPC_MANA_CHANGE',

	'DOODAD_ENTER_SCENE',
	'DOODAD_LEAVE_SCENE',
	'MY_TEAM_MON_DOODAD_ENTER_SCENE',
	'MY_TEAM_MON_DOODAD_ALL_LEAVE_SCENE',

	'BUFF_UPDATE',
	'SYS_MSG',
	'DO_SKILL_CAST',

	'PLAYER_SAY',
	'ON_WARNING_MESSAGE',

	'PARTY_SET_MARK',
}

local CACHE = {
	TEMP        = {}, -- 近期事件记录MAP 这里用弱表 方便处理
	MAP         = {},
	NPC_LIST    = {},
	DOODAD_LIST = {},
	SKILL_LIST  = {},
	INTERVAL    = {},
	CD_STR      = {},
	HP_CD_STR   = {},
}

local D = X.LazyLoadingTable({
	FILE   = {}, -- 文件原始数据
	META   = {}, -- 文件原信息
	CONFIG = {}, -- 文件原始配置项
	TEMP   = {}, -- 近期事件记录
	DATA   = {}, -- 需要监控的数据合集
}, {
	PW = function() return X.SECRET['FILE::TEAM_MON_DATA_PW'] end,
})

-- 初始化table 虽然写法没有直接写来得好 但是为了方便以后改动
do
	for k, v in ipairs(MY_TEAM_MON_TYPE_LIST) do
		D.FILE[v]         = {}
		D.DATA[v]         = {}
		D.TEMP[v]         = {}
		CACHE.MAP[v]      = {}
		CACHE.INTERVAL[v] = {}
		CACHE.TEMP[v]     = setmetatable({}, { __mode = 'v' })
		if v == 'TALK' or v == 'CHAT' then -- init talk stru
			CACHE.MAP[v].HIT   = {}
			CACHE.MAP[v].OTHER = {}
		end
	end
end

local O = X.CreateUserSettingsModule('MY_TeamMon', _L['Raid'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Enable MY_TeamMon'],
		}),
		szRestriction = 'MY_TeamMon',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bCommon = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Use common data'],
		}),
		szRestriction = 'MY_TeamMon',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bPushScreenHead = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Lifebar alarm'],
		}),
		szRestriction = 'MY_TeamMon',
		szVersion = '20241029',
		xSchema = X.Schema.Boolean,
		xDefaultValue = X.IS_REMAKE,
	},
	bPushCenterAlarm = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Center alarm'],
		}),
		szRestriction = 'MY_TeamMon',
		szVersion = '20241029',
		xSchema = X.Schema.Boolean,
		xDefaultValue = X.IS_REMAKE,
	},
	bPushVoiceAlarm = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Voice alarm'],
		}),
		szRestriction = 'MY_TeamMon',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bPushBigFontAlarm = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Large text alarm'],
		}),
		szRestriction = 'MY_TeamMon',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bPushTeamPanel = { -- 面板buff监控
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Team panel bind show buff'],
		}),
		szRestriction = 'MY_TeamMon',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bPushFullScreen = { -- 全屏泛光
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Fullscreen alarm'],
		}),
		szRestriction = 'MY_TeamMon',
		szVersion = '20241029',
		xSchema = X.Schema.Boolean,
		xDefaultValue = X.IS_REMAKE,
	},
	bPushTeamChannel = { -- 团队报警
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Team channel alarm'],
		}),
		szRestriction = 'MY_TeamMon',
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bPushWhisperChannel = { -- 密聊报警
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Whisper channel alarm'],
		}),
		szRestriction = 'MY_TeamMon',
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bPushBuffList = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Buff list'],
		}),
		szRestriction = 'MY_TeamMon',
		szVersion = '20241029',
		xSchema = X.Schema.Boolean,
		xDefaultValue = X.IS_REMAKE,
	},
	bPushPartyBuffList = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Party buff list'],
		}),
		szRestriction = 'MY_TeamMon',
		szVersion = '20241029',
		xSchema = X.Schema.Boolean,
		xDefaultValue = X.IS_REMAKE,
	},
	bShowVoicePacketRecommendation = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_TeamMon'],
		szDescription = X.MakeCaption({
			_L['Show voice recommendation confirm on load data'],
		}),
		szRestriction = 'MY_TeamMon',
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
})

local function GetUserDataPath()
	local ePathType = O.bCommon and X.PATH_TYPE.GLOBAL or X.PATH_TYPE.ROLE
	local szPathV1 = X.FormatPath({'userdata/TeamMon/Config.jx3dat', ePathType})
	local szPath = X.FormatPath({'userdata/team_mon/local.jx3dat', ePathType})
	if IsLocalFileExist(szPathV1) then
		local data = X.LoadLUAData(szPathV1)
		X.SaveLUAData(szPath, {
			data = data,
			config = {},
		})
		CPath.DelFile(szPathV1)
	end
	X.OutputDebugMessage('[MY_TeamMon] Data path: ' .. szPath, X.DEBUG_LEVEL.LOG)
	return szPath
end

local function RenderCustomText(szTemplate, szSender, szReceiver, aBackreferences)
	local tVar = X.Clone(aBackreferences) or {}
	tVar.sender = szSender
	tVar.receiver = szReceiver
	return X.RenderTemplateString(szTemplate, tVar, -1, false, false)
end

local function FilterCustomText(szTemplate, szSender, szReceiver, aBackreferences)
	local tVar = X.Clone(aBackreferences) or {}
	tVar.sender = szSender
	tVar.receiver = szReceiver
	return X.RenderTemplateString(szTemplate, tVar, -1, true, false)
end

local function ParseCustomText(szTemplate, szSender, szReceiver, aBackreferences)
	local tVar = X.Clone(aBackreferences) or {}
	tVar.sender = szSender
	tVar.receiver = szReceiver
	return X.RenderTemplateString(szTemplate, tVar, 8, true, true)
end

local function ConstructSpeech(aText, aXml, szText, nFont, nR, nG, nB)
	if aXml then
		if X.IsString(nFont) then
			table.insert(aXml, nFont)
		else
			table.insert(aXml, MY_GetFormatText(szText, nFont, nR, nG, nB))
		end
	end
	if aText then
		table.insert(aText, szText)
	end
end

-- 解析分段倒计时
---@param szCountdown string @倒计时字符串，如 “10,文本提示;20,文本提示;30,文本提示”
---@return table @倒计时列表
local function ParseCountdown(szCountdown)
	if not CACHE.CD_STR[szCountdown] then
		local aCountdown, bError = {}, false
		for _, szPart in ipairs(MY_SplitString(szCountdown, ';')) do
			local aParams, bPartError = MY_SplitString(szPart, ','), true
			if #aParams >= 2 then
				local nTime = tonumber(aParams[1])
				local szContent = aParams[2]
				local szVoice
				local szParam, bUnknownParam, bParamRecognized
				for i = 3, #aParams do
					szParam = aParams[i]
					bParamRecognized = false
					if not szVoice and not bParamRecognized then
						if szParam:sub(1, 3) == 'VO:'
						or szParam:sub(1, 3) == 'VC:' then
							szVoice = szParam:sub(4)
							bParamRecognized = true
						end
					end
					if not bParamRecognized then
						bUnknownParam = true
					end
				end
				if nTime and szContent and nTime and szContent ~= '' and not bUnknownParam then
					table.insert(aCountdown, {
						nTime = nTime,
						szContent = szContent,
						szVoice = szVoice,
					})
					bPartError = false
				end
			end
			if bPartError then
				bError = true
			end
		end
		if X.IsEmpty(aCountdown) then
			aCountdown = nil
		else
			table.sort(aCountdown, function(a, b)
				return a.nTime < b.nTime
			end)
		end
		CACHE.CD_STR[szCountdown] = {aCountdown, bError}
	end
	return X.Clone(CACHE.CD_STR[szCountdown][1]), CACHE.CD_STR[szCountdown][2]
end

-- 解析气血内力监控
---@param szString string @气血内力监控字符串，如 “0.5-,气血下降50%提示;0.3+,气血回升30%提示,5;0.1,气血10%提示,15”，时间可选，不填时间时仅显示提示不显示倒计时
---@return table @气血内力监控列表
local function ParseHPCountdown(szString)
	if not CACHE.HP_CD_STR[szString] then
		local aHPCountdown, bError = {}, false
		for _, szPart in ipairs(MY_SplitString(szString, ';')) do
			local aParams, bPartError = MY_SplitString(szPart, ','), true
			if #aParams >= 2 then
				local nValue, szOperator = nil, aParams[1]:sub(-1)
				if szOperator == '+' or szOperator == '-' or szOperator == '*' then
					nValue = tonumber(aParams[1]:sub(1, -2))
				else
					szOperator = '*'
					nValue = tonumber(aParams[1])
				end
				local szContent = aParams[2]
				local nTime
				local szVoice
				local szParam, bUnknownParam, bParamRecognized
				for i = 3, #aParams do
					szParam = aParams[i]
					bParamRecognized = false
					if not szVoice and not bParamRecognized then
						if szParam:sub(1, 3) == 'VO:'
						or szParam:sub(1, 3) == 'VC:' then
							szVoice = szParam:sub(4)
							bParamRecognized = true
						end
					end
					if not nTime and not bParamRecognized and i == 3 then
						if tonumber(szParam) then
							nTime = tonumber(szParam)
							bParamRecognized = true
						end
					end
					if not bParamRecognized then
						bUnknownParam = true
					end
				end
				if nValue and szOperator and szContent ~= '' and not bUnknownParam then
					table.insert(aHPCountdown, {
						nValue = nValue * 100,
						szOperator = szOperator,
						szContent = szContent,
						nTime = nTime,
						szVoice = szVoice,
					})
					bPartError = false
				end
			end
			if bPartError then
				bError = true
			end
		end
		if X.IsEmpty(aHPCountdown) then
			aHPCountdown = nil
		else
			table.sort(aHPCountdown, function(a, b)
				return a.nValue > b.nValue
			end)
		end
		CACHE.HP_CD_STR[szString] = {aHPCountdown, bError}
	end
	return X.Clone(CACHE.HP_CD_STR[szString][1]), CACHE.HP_CD_STR[szString][2]
end

function D.OnFrameCreate()
	this:RegisterEvent('MY_TEAM_MON_LOADING_END')
	this:RegisterEvent('MY_TEAM_MON_CREATE_CACHE')
	this:RegisterEvent('LOADING_END')
	D.Enable(O.bEnable)
	D.Log('init success!')
	X.BreatheCall('MY_TeamMon_CacheClear', 60 * 2 * 1000, function()
		for k, v in ipairs(MY_TEAM_MON_TYPE_LIST) do
			if #D.TEMP[v] > MY_TEAM_MON_MAX_CACHE then
				D.FreeCache(v)
			end
		end
		for k, v in pairs(CACHE.INTERVAL) do
			for kk, vv in pairs(v) do
				if #vv > MY_TEAM_MON_MAX_INTERVAL then
					CACHE.INTERVAL[k][kk] = {}
				end
			end
		end
	end)
end

function D.OnFrameBreathe()
	local me = X.GetClientPlayer()
	if not me then
		return
	end
	-- local dwType, dwID = me.GetTarget()
	for dwTemplateID, npcInfo in pairs(CACHE.NPC_LIST) do
		local data = D.GetData('NPC', dwTemplateID)
		if data then
			-- local bTempTarget = false
			-- for kk, vv in ipairs(data.tCountdown or {}) do
			-- 	if vv.nClass == MY_TEAM_MON_TYPE.NPC_MANA then
			-- 		bTempTarget = true
			-- 		break
			-- 	end
			-- end
			local bFightFlag = false
			local fLifePer, fManaPer
			-- TargetPanel_SetOpenState(true)
			for dwNpcID, tab in pairs(npcInfo.tList) do
				local npc = X.GetNpc(dwNpcID)
				if npc then
					-- if bTempTarget then
					-- 	X.SetClientPlayerTarget(TARGET.NPC, vv)
					-- 	X.SetClientPlayerTarget(dwType, dwID)
					-- end
					-- 血量变化检查
					local fCurrentLife, fMaxLife = X.GetCharacterLife(npc)
					if fMaxLife > 1 then
						local nLife = math.floor(fCurrentLife / fMaxLife * 100)
						if tab.nLife ~= nLife then
							local nStart = tab.nLife or nLife
							local bIncrease = nLife >= nStart
							local nStep = bIncrease and 1 or -1
							if tab.nLife then
								nStart = nStart + nStep
							end
							for nLife = nStart, nLife, nStep do
								FireUIEvent('MY_TEAM_MON_NPC_LIFE_CHANGE', dwTemplateID, nLife, bIncrease)
							end
							tab.nLife = nLife
						end
					end
					-- 蓝量变化检查
					-- if bTempTarget then
					if npc.nMaxMana > 1 then
						local nMana = math.floor(npc.nCurrentMana / npc.nMaxMana * 100)
						if tab.nMana ~= nMana then
							local nStart = tab.nMana or nMana
							local bIncrease = nMana >= nStart
							local nStep = bIncrease and 1 or -1
							if tab.nMana then
								nStart = nStart + nStep
							end
							for nMana = nStart, nMana, nStep do
								FireUIEvent('MY_TEAM_MON_NPC_MANA_CHANGE', dwTemplateID, nMana, bIncrease)
							end
							tab.nMana = nMana
						end
					end
					-- end
					-- 战斗标记检查
					if npc.bFightState ~= tab.bFightState then
						if npc.bFightState then
							local nTime = GetTime()
							npcInfo.nSec = nTime
							FireUIEvent('MY_TEAM_MON_NPC_FIGHT', dwTemplateID, true, nTime)
						else
							local nTime = GetTime() - (npcInfo.nSec or GetTime())
							npcInfo.nSec = nil
							FireUIEvent('MY_TEAM_MON_NPC_FIGHT', dwTemplateID, false, nTime)
						end
						tab.bFightState = npc.bFightState
					end
				end
			end
			-- TargetPanel_SetOpenState(false)
		end
	end
end

function D.OnSetMark(bFinish)
	if bFinish then
		MY_TEAM_MON_MARK_IDLE = true
	end
	if MY_TEAM_MON_MARK_IDLE and #MY_TEAM_MON_MARK_QUEUE >= 1 then
		MY_TEAM_MON_MARK_IDLE = false
		local r = table.remove(MY_TEAM_MON_MARK_QUEUE, 1)
		local res, err, trace = X.XpCall(r.fnAction)
		if not res then
			FireUIEvent('CALL_LUA_ERROR', 'MY_TeamMon_Mark ERROR: ' .. err .. '\n' .. trace)
			D.OnSetMark(true)
		end
	end
end

function D.OnEvent(szEvent)
	if szEvent == 'BUFF_UPDATE' then
		D.OnBuff(arg0, arg1, arg3, arg4, arg5, arg8, arg9)
	elseif szEvent == 'SYS_MSG' then
		if arg0 == 'UI_OME_DEATH_NOTIFY' then
			if not X.IsPlayer(arg1) then
				D.OnDeath(arg1, arg2)
			end
		elseif arg0 == 'UI_OME_SKILL_CAST_LOG' then
			D.OnSkillCast(arg1, arg2, arg3, arg0)
		elseif (arg0 == 'UI_OME_SKILL_BLOCK_LOG'
		or arg0 == 'UI_OME_SKILL_SHIELD_LOG' or arg0 == 'UI_OME_SKILL_MISS_LOG'
		or arg0 == 'UI_OME_SKILL_DODGE_LOG'	or arg0 == 'UI_OME_SKILL_HIT_LOG')
		and arg3 == SKILL_EFFECT_TYPE.SKILL then
			D.OnSkillCast(arg1, arg4, arg5, arg0)
		elseif arg0 == 'UI_OME_SKILL_EFFECT_LOG' and arg4 == SKILL_EFFECT_TYPE.SKILL then
			D.OnSkillCast(arg1, arg5, arg6, arg0)
		end
	elseif szEvent == 'DO_SKILL_CAST' then
		D.OnSkillCast(arg0, arg1, arg2, szEvent)
	elseif szEvent == 'PARTY_SET_MARK' then
		D.OnSetMark(true)
	elseif szEvent == 'PLAYER_SAY' then
		if not X.IsPlayer(arg1) then
			local szText = MY_GetPureText(arg0)
			if szText and szText ~= '' then
				D.OnCallMessage('TALK', szText, arg1, arg3 == '' and '%' or arg3)
			else
				X.OutputDebugMessage(_L['MY_TeamMon'], 'GetPureText ERROR: ' .. arg0, X.DEBUG_LEVEL.WARNING)
			end
		end
	elseif szEvent == 'ON_WARNING_MESSAGE' then
		D.OnCallMessage('TALK', arg1)
	elseif szEvent == 'DOODAD_ENTER_SCENE' or szEvent == 'MY_TEAM_MON_DOODAD_ENTER_SCENE' then
		local doodad = X.GetDoodad(arg0)
		if doodad then
			D.OnDoodadEvent(doodad, true)
		end
	elseif szEvent == 'DOODAD_LEAVE_SCENE' then
		local doodad = X.GetDoodad(arg0)
		if doodad then
			D.OnDoodadEvent(doodad, false)
		end
	elseif szEvent == 'MY_TEAM_MON_DOODAD_ALL_LEAVE_SCENE' then
		D.OnDoodadAllLeave(arg0)
	elseif szEvent == 'NPC_ENTER_SCENE' or szEvent == 'MY_TEAM_MON_NPC_ENTER_SCENE' then
		local npc = X.GetNpc(arg0)
		if npc then
			D.OnNpcEvent(npc, true)
		end
	elseif szEvent == 'NPC_LEAVE_SCENE' then
		local npc = X.GetNpc(arg0)
		if npc then
			D.OnNpcEvent(npc, false)
		end
	elseif szEvent == 'MY_TEAM_MON_ALL_LEAVE_SCENE' then
		D.OnNpcAllLeave(arg0)
	elseif szEvent == 'MY_TEAM_MON_NPC_FIGHT' then
		D.OnNpcFight(arg0, arg1)
	elseif szEvent == 'MY_TEAM_MON_NPC_LIFE_CHANGE' or szEvent == 'MY_TEAM_MON_NPC_MANA_CHANGE' then
		D.OnNpcInfoChange(szEvent, arg0, arg1, arg2)
	elseif szEvent == 'LOADING_END' or szEvent == 'MY_TEAM_MON_CREATE_CACHE' or szEvent == 'MY_TEAM_MON_LOADING_END' then
		D.FireCrossMapEvent('before')
		D.CreateData(szEvent)
		X.DelayCall('MY_TeamMon__FireCrossMapEvent__after', D.FireCrossMapEvent, 'after')
	end
end

function D.SendChat(...)
	if bRestricted then
		return
	end
	return X.SendChat(...)
end

function D.SendBgMsg(...)
	if bRestricted then
		return
	end
	return X.SendBgMsg(...)
end

function D.Log(szMsg)
	return Log('[MY_TeamMon] ' .. szMsg)
end

function D.Talk(szType, szMsg, szTarget)
	local me = X.GetClientPlayer()
	if not me then
		return
	end
	local szKey = 'MY_TeamMon.' .. GetLogicFrameCount()
	if szType == 'RAID' then
		if szTarget then
			szMsg = X.StringReplaceW(szMsg, _L['['] .. szTarget .. _L[']'], ' [' .. szTarget .. '] ')
			szMsg = X.StringReplaceW(szMsg, _L['['] .. g_tStrings.STR_YOU .. _L[']'], ' [' .. szTarget .. '] ')
		end
		if me.IsInParty() then
			D.SendChat(PLAYER_TALK_CHANNEL.RAID, szMsg, { uuid = szKey .. GetStringCRC(szType .. szMsg) })
		end
	elseif szType == 'WHISPER' then
		if szTarget then
			szMsg = X.StringReplaceW(szMsg, '[' .. szTarget .. ']', _L['['] .. g_tStrings.STR_YOU .. _L[']'])
			szMsg = X.StringReplaceW(szMsg, _L['['] .. szTarget .. _L[']'], _L['['] .. g_tStrings.STR_YOU .. _L[']'])
		end
		if szTarget == me.szName then
			X.OutputWhisperMessage(szMsg, _L['MY_TeamMon'])
		else
			D.SendChat(szTarget, szMsg, { uuid = szKey .. GetStringCRC(szType .. szMsg) })
		end
	elseif szType == 'RAID_WHISPER' then
		if me.IsInParty() then
			local team = GetClientTeam()
			for _, v in ipairs(team.GetTeamMemberList()) do
				local szName = team.GetClientTeamMemberName(v)
				local szText = X.StringReplaceW(szMsg, '[' .. szName .. ']', _L['['] .. g_tStrings.STR_YOU ..  _L[']'])
				if szName == me.szName then
					X.OutputWhisperMessage(szText, _L['MY_TeamMon'])
				else
					D.SendChat(szName, szText, { uuid = szKey .. GetStringCRC(szType .. szText .. szName) })
				end
			end
		end
	end
end

-- 更新当前地图使用条件
function D.UpdateShieldStatus()
	local bShieldedTotal = false
	local bShieldedOtherPlayer = false
	local bShieldedEnterLeaveScene = false
	if X.IsRestricted('MY_TeamMon.MapRestriction') then
		-- 地图限制判断
		if X.IsInPubgMap() then
			bShieldedTotal = true
		end
		if not X.IsInDungeonMap() then
			bShieldedOtherPlayer = true
		end
		-- 地图限制提示
		if not MY_TEAM_MON_SHIELDED_TOTAL and bShieldedTotal then
			X.OutputSystemMessage(_L['MY_TeamMon is blocked in current kungfu, temporary disabled.'])
		elseif not MY_TEAM_MON_SHIELDED_OTHER_PLAYER and bShieldedOtherPlayer then
			X.OutputSystemMessage(_L['MY_TeamMon is shielded other player in this map, temporary disabled.'])
		end
	end
	MY_TEAM_MON_SHIELDED_TOTAL = bShieldedTotal
	MY_TEAM_MON_SHIELDED_OTHER_PLAYER = bShieldedOtherPlayer
	MY_TEAM_MON_SHIELDED_ENTER_LEAVE_SCENE = bShieldedEnterLeaveScene
end

local function CreateCache(szType, tab)
	local data  = D.DATA[szType]
	local cache = CACHE.MAP[szType]
	for k, v in ipairs(tab) do
		data[#data + 1] = v
		if v.nLevel then
			cache[v.dwID] = cache[v.dwID] or {}
			cache[v.dwID][v.nLevel] = k
		else -- other
			cache[v.dwID] = k
		end
	end
	D.Log('create ' .. szType .. ' data success!')
end
-- 核心函数 缓存创建 UI缓存创建
function D.CreateData(szEvent)
	local nTime   = GetTime()
	local dwMapID = X.GetMapID(true)
	local me = X.GetClientPlayer()
	-- 用于更新 BUFF / CAST / NPC 缓存处理 不需要再获取本地对象
	MY_TEAM_MON_CORE_NAME     = me.szName
	MY_TEAM_MON_CORE_PLAYERID = me.dwID
	D.Log('get player info cache success!')
	-- 更新功能屏蔽状态
	D.UpdateShieldStatus()
	-- 重建metatable 获取ALL数据的方法 主要用于UI 逻辑中毫无作用
	for kType, vTable in pairs(D.FILE)  do
		setmetatable(D.FILE[kType], { __index = function(me, index)
			if index == _L['All data'] then
				local t = {}
				for k, v in pairs(vTable) do
					if k ~= MY_TEAM_MON_SPECIAL_MAP.RECYCLE_BIN then
						for kk, vv in ipairs(v) do
							t[#t +1] = vv
						end
					end
				end
				return t
			end
		end })
		-- 重建所有数据的metatable
		for k, v in pairs(vTable) do
			for kk, vv in ipairs(v) do
				setmetatable(vv, { __index = function(_, val)
					if val == 'dwMapID' then
						return k
					elseif val == 'nIndex' then
						return kk
					end
				end })
			end
		end
	end
	D.Log('create metatable success!')
	-- 清空当前数据和MAP
	for k, v in pairs(D.DATA) do
		D.DATA[k] = {}
	end
	for k, v in pairs(CACHE.MAP) do
		CACHE.MAP[k] = {}
		if k == 'TALK' or k == 'CHAT' then
			CACHE.MAP[k].HIT   = {}
			CACHE.MAP[k].OTHER = {}
		end
	end
	pcall(Raid_MonitorBuffs) -- clear
	-- 重建MAP
	for _, v in ipairs({ 'BUFF', 'DEBUFF', 'CASTING', 'NPC', 'DOODAD' }) do
		for _, d in D.IterTable(MY_TeamMon.GetTable(v), dwMapID, false) do
			CreateCache(v, d)
		end
	end
	-- 单独重建TALK数据
	do
		for _, vType in ipairs({ 'TALK', 'CHAT' }) do
			local data = D.FILE[vType]
			local talk = D.DATA[vType]
			CACHE.MAP[vType] = {
				HIT   = {},
				OTHER = {},
			}
			local cache = CACHE.MAP[vType]
			for _, v in D.IterTable(data, dwMapID, true) do
				talk[#talk + 1] = v
			end
			for k, v in ipairs(talk) do
				if v.szContent then
					if v.szContent:find('{$me}') or v.szContent:find('{$team}') or v.bSearch or v.bReg then -- 具有通配符和搜索标记的数据不作 HIT 高速匹配策略考虑
						table.insert(cache.OTHER, v)
					elseif not (cache.HIT[v.szContent] and cache.HIT[v.szContent][v.szTarget or 'sys']) then -- 按照数据优先级顺序（地图＞地图组＞通用），同级按照下标先后顺序，只取第一个匹配结果
						cache.HIT[v.szContent] = cache.HIT[v.szContent] or {}
						cache.HIT[v.szContent][v.szTarget or 'sys'] = v
					end
				else
					X.OutputDebugMessage('MY_TeamMon', '[Warning] ' .. vType .. ' data is not szContent #' .. k .. ', please do check it!', X.DEBUG_LEVEL.WARNING)
				end
			end
			D.Log('create ' .. vType .. ' data success!')
		end
	end
	if O.bPushTeamPanel then
		local tBuff = {}
		for k, v in ipairs(D.DATA.BUFF) do
			if v[MY_TEAM_MON_TYPE.BUFF_GET] and v[MY_TEAM_MON_TYPE.BUFF_GET].bTeamPanel then
				table.insert(tBuff, v.dwID)
			end
		end
		for k, v in ipairs(D.DATA.DEBUFF) do
			if v[MY_TEAM_MON_TYPE.BUFF_GET] and v[MY_TEAM_MON_TYPE.BUFF_GET].bTeamPanel then
				table.insert(tBuff, v.dwID)
			end
		end
		pcall(Raid_MonitorBuffs, tBuff)
	end
	D.Log('MAPID: ' .. dwMapID ..  ' create data success:' .. GetTime() - nTime  .. 'ms')
	-- gc
	if szEvent ~= 'MY_TEAM_MON_CREATE_CACHE' then
		CACHE.SKILL_LIST = {}
		CACHE.HP_CD_STR  = {}
		D.Log('collectgarbage(\'count\') ' .. collectgarbage('count'))
		collectgarbage('collect')
		D.Log('collectgarbage(\'collect\') ' .. collectgarbage('count'))
	end
	-- clear nearby cache
	CACHE.NPC_LIST    = {}
	CACHE.DOODAD_LIST = {}
	-- re-scan nearby
	for _, v in pairs(X.GetNearNpcID()) do
		FireUIEvent('MY_TEAM_MON_NPC_ENTER_SCENE', v)
	end
	for _, v in pairs(X.GetNearDoodadID()) do
		FireUIEvent('MY_TEAM_MON_DOODAD_ENTER_SCENE', v)
	end
	FireUIEvent('MY_TEAM_MON__UI__FREE_CACHE')
end

function D.FreeCache(szType)
	local t = {}
	local tTemp = D.TEMP[szType]
	for i = MY_TEAM_MON_DEL_CACHE, #tTemp do
		t[#t + 1] = tTemp[i]
	end
	D.TEMP[szType] = t
	collectgarbage('collect')
	FireUIEvent('MY_TEAM_MON__UI__TEMP_RELOAD', szType)
	D.Log(szType .. ' cache clear!')
end

function D.CheckScrutinyType(nScrutinyType, dwID)
	if nScrutinyType == MY_TEAM_MON_SCRUTINY_TYPE.SELF and dwID ~= MY_TEAM_MON_CORE_PLAYERID then
		return false
	elseif nScrutinyType == MY_TEAM_MON_SCRUTINY_TYPE.TEAM and (not X.IsTeammate(dwID) and dwID ~= MY_TEAM_MON_CORE_PLAYERID) then
		return false
	elseif nScrutinyType == MY_TEAM_MON_SCRUTINY_TYPE.ENEMY and not IsEnemy(MY_TEAM_MON_CORE_PLAYERID, dwID) then
		return false
	elseif nScrutinyType == MY_TEAM_MON_SCRUTINY_TYPE.TARGET then
		local me = X.GetClientPlayer()
		local obj = X.GetTargetHandle(X.GetCharacterTarget(me))
		if not obj or obj and obj.dwID ~= dwID then
			return false
		end
	end
	return true
end

function D.CheckKungFu(tKungFu)
	if tKungFu['SKILL#' .. UI_GetPlayerMountKungfuID()] then
		return true
	end
	return false
end

function D.GetTargetHandle(dwID)
	if X.IsPlayer(dwID) then
		return X.GetPlayer(dwID)
	end
	return X.GetNpc(dwID)
end

-- 智能标记逻辑
function D.SetTeamMark(szType, tMark, dwCharacterID, dwID, nLevel)
	if not X.IsClientPlayerTeamMarker() or bRestricted then
		return
	end
	local function fnGetNextMark()
		local team, tar = GetClientTeam()
		local tTeamMark = X.FlipObjectKV(team.GetTeamMark())
		if szType == 'NPC' then
			for nMark, bMark in ipairs(tMark) do
				if bMark and tTeamMark[nMark] ~= dwCharacterID then
					tar = tTeamMark[nMark] and tTeamMark[nMark] ~= 0 and D.GetTargetHandle(tTeamMark[nMark])
					if not tar or tar.dwTemplateID ~= dwID then
						return nMark, dwCharacterID
					end
				end
			end
		elseif szType == 'BUFF' or szType == 'DEBUFF' then
			for nMark, bMark in ipairs(tMark) do
				if bMark and tTeamMark[nMark] ~= dwCharacterID then
					tar = tTeamMark[nMark] and tTeamMark[nMark] ~= 0 and D.GetTargetHandle(tTeamMark[nMark])
					if not tar or not X.GetBuff(tar, dwID) then
						return nMark, dwCharacterID
					end
				end
			end
		elseif szType == 'CASTING' then
			for nMark, bMark in ipairs(tMark) do
				if bMark and (not tTeamMark[nMark] or tTeamMark[nMark] ~= dwCharacterID) then
					return nMark, dwCharacterID
				end
			end
		end
	end
	local fnAction = function()
		local nMark, dwCharacterID = fnGetNextMark()
		if nMark and dwCharacterID and X.SetTeamMarkCharacter(nMark, dwCharacterID) then
			return
		end
		D.OnSetMark(true) -- 标记失败 直接处理下一个
	end
	table.insert(MY_TEAM_MON_MARK_QUEUE, {
		fnAction = fnAction,
	})
	D.OnSetMark()
end

-- 根据配置获取倒计时实例的 类型 与 唯一标识符
function D.GetCountdownTypeKey(data, nIndex, szSender, szReceiver, aBackreferences)
	local v = data.tCountdown[nIndex]
	local nType, szKey = v.nClass, v.key
	if szKey then
		nType = MY_TEAM_MON_TYPE.COMMON
		szKey = RenderCustomText(szKey, szSender, szReceiver, aBackreferences)
	else
		szKey = nIndex .. '.' .. (data.dwID or 0) .. '.' .. (data.nLevel or 0) .. '.' .. (data.nIndex or 0) .. '.' .. X.EncodeLUAData(aBackreferences)
	end
	return nType, szKey
end

-- 倒计时处理 支持定义无限的倒计时
function D.CountdownEvent(data, nClass, szSender, szReceiver, aBackreferences)
	if data.tCountdown then
		for i, v in ipairs(data.tCountdown) do
			if nClass == v.nClass then
				local nType, szKey = D.GetCountdownTypeKey(data, i, szSender, szReceiver, aBackreferences)
				local tParam = {
					nIcon     = v.nIcon or data.nIcon or 340,
					nFrame    = v.nFrame,
					szContent = FilterCustomText(v.szName or data.szName, szSender, szReceiver, aBackreferences),
					nTime     = v.nTime,
					nRefresh  = v.nRefresh,
					bTalk     = v.bTeamChannel,
					bHold     = v.bHold,
				}
				D.FireCountdownEvent(nType, szKey, tParam, szSender, szReceiver, aBackreferences)
			end
		end
	end
end

-- 发布事件 为了方便日后修改 集中起来
function D.FireCountdownEvent(nType, szKey, tParam, szSender, szReceiver, aBackreferences)
	if not O.bPushTeamChannel then
		tParam.bTalk = false
	end
	FireUIEvent('MY_TEAM_MON__SPELL_TIMER__CREATE', nType, szKey, tParam, szSender, szReceiver, aBackreferences)
end

function D.GetSrcName(dwID)
	if not dwID then
		return nil
	end
	if dwID == 0 then
		return g_tStrings.COINSHOP_SOURCE_NULL
	end
	local dwType = X.IsPlayer(dwID) and TARGET.PLAYER or TARGET.NPC
	return X.GetTargetName(dwType, dwID) or dwID
end

-- local a=GetTime();for i=1, 10000 do FireUIEvent('BUFF_UPDATE',X.GetClientPlayerID(),false,1,true,i,1,1,1,1,0) end;Output(GetTime()-a)
-- 事件操作
function D.OnBuff(dwOwner, bDelete, bCanCancel, dwBuffID, nCount, nBuffLevel, dwSkillSrcID)
	if MY_TEAM_MON_SHIELDED_TOTAL then
		return
	end
	if MY_TEAM_MON_SHIELDED_OTHER_PLAYER and X.IsPlayer(dwSkillSrcID) and dwSkillSrcID ~= MY_TEAM_MON_CORE_PLAYERID then
		return
	end
	local szType = bCanCancel and 'BUFF' or 'DEBUFF'
	local key = dwBuffID .. '_' .. nBuffLevel
	local data = D.GetData(szType, dwBuffID, nBuffLevel)
	local nTime = GetTime()
	if not bDelete then
		-- 近期记录
		if MY_IsVisibleBuff(dwBuffID, nBuffLevel) or not X.IsRestricted('MY_TeamMon.HiddenBuff') then
			local tWeak, tTemp = CACHE.TEMP[szType], D.TEMP[szType]
			if not tWeak[key] then
				local t = {
					dwMapID      = X.GetMapID(),
					dwID         = dwBuffID,
					nLevel       = nBuffLevel,
					bIsPlayer    = dwSkillSrcID ~= 0 and X.IsPlayer(dwSkillSrcID),
					szSrcName    = D.GetSrcName(dwSkillSrcID),
					nCurrentTime = GetCurrentTime()
				}
				tWeak[key] = t
				tTemp[#tTemp + 1] = tWeak[key]
				FireUIEvent('MY_TEAM_MON__UI__TEMP_UPDATE', szType, t)
			end
			-- 记录时间
			CACHE.INTERVAL[szType][key] = CACHE.INTERVAL[szType][key] or {}
			if #CACHE.INTERVAL[szType][key] > 0 then
				if nTime - CACHE.INTERVAL[szType][key][#CACHE.INTERVAL[szType][key]] > 1000 then
					CACHE.INTERVAL[szType][key][#CACHE.INTERVAL[szType][key] + 1] = nTime
				end
			else
				CACHE.INTERVAL[szType][key][#CACHE.INTERVAL[szType][key] + 1] = nTime
			end
		end
	end
	if data then
		local tar = X.GetTargetHandle(X.IsPlayer(dwOwner) and TARGET.PLAYER or TARGET.NPC, dwOwner)
		local buff = tar and X.GetBuff(tar, dwBuffID, nBuffLevel)
		local cfg, nClass
		if data.nScrutinyType and not D.CheckScrutinyType(data.nScrutinyType, dwOwner) then -- 监控对象检查
			return
		end
		if data.tKungFu and not D.CheckKungFu(data.tKungFu) then -- 自身身法需求检查
			return
		end
		if data.nCount and nCount < data.nCount then -- 层数检查
			return
		end
		if bDelete then
			cfg, nClass = data[MY_TEAM_MON_TYPE.BUFF_LOSE], MY_TEAM_MON_TYPE.BUFF_LOSE
		else
			cfg, nClass = data[MY_TEAM_MON_TYPE.BUFF_GET], MY_TEAM_MON_TYPE.BUFF_GET
		end
		local szSender = X.GetTargetName(X.IsPlayer(dwSkillSrcID) and TARGET.PLAYER or TARGET.NPC, dwSkillSrcID)
		local szReceiver = X.GetTargetName(X.IsPlayer(dwOwner) and TARGET.PLAYER or TARGET.NPC, dwOwner)
		D.CountdownEvent(data, nClass, szSender, szReceiver)
		if cfg then
			local szName, nIcon = X.GetBuffName(dwBuffID, nBuffLevel)
			if data.szName then
				szName = FilterCustomText(data.szName, szSender, szReceiver)
			end
			if data.nIcon then
				nIcon = data.nIcon
			end
			local aXml, aText = {}, {}
			ConstructSpeech(aText, aXml, MY_TEAM_MON_LEFT_BRACKET, MY_TEAM_MON_LEFT_BRACKET_XML)
			ConstructSpeech(aText, aXml, szReceiver == MY_TEAM_MON_CORE_NAME and g_tStrings.STR_YOU or szReceiver, 44, 255, 255, 0)
			ConstructSpeech(aText, aXml, MY_TEAM_MON_RIGHT_BRACKET, MY_TEAM_MON_RIGHT_BRACKET_XML)
			if nClass == MY_TEAM_MON_TYPE.BUFF_GET then
				ConstructSpeech(aText, aXml, _L['Get buff'], 44, 255, 255, 255)
				ConstructSpeech(aText, aXml, szName .. ' x' .. nCount, 44, 255, 255, 0)
				if buff then
					local nTime = X.GetEndTime(buff.nEndFrame)
					if nTime < 31536000 then
						local szTime
						if nTime > 600 then
							szTime = X.FormatDuration(nTime, 'CHINESE')
						else
							szTime = _L('%ds', nTime)
						end
						ConstructSpeech(aText, aXml, _L(', remain time %s', szTime), 44, 255, 255, 255)
					end
				end
				if data.szNote and not X.IsRestricted('MY_TeamMon.Note') then
					ConstructSpeech(aText, aXml, _L[','], 44, 255, 255, 255)
					ConstructSpeech(aText, aXml, FilterCustomText(data.szNote, szSender, szReceiver), 44, 255, 255, 255)
				end
				ConstructSpeech(aText, aXml, _L['.'], 44, 255, 255, 255)
			else
				ConstructSpeech(aText, aXml, _L['Lose buff'], 44, 255, 255, 255)
				ConstructSpeech(aText, aXml, szName, 44, 255, 255, 0)
			end
			local szXml, szText = table.concat(aXml), table.concat(aText)
			if O.bPushCenterAlarm and cfg.bCenterAlarm then
				FireUIEvent('MY_TEAM_MON__CENTER_ALARM__CREATE', szXml, 3, true)
			end
			-- 特大文字
			if O.bPushBigFontAlarm and cfg.bBigFontAlarm and (MY_TEAM_MON_CORE_PLAYERID == dwOwner or not X.IsPlayer(dwOwner)) then
				FireUIEvent('MY_TEAM_MON__LARGE_TEXT_ALARM', szText, data.col or { GetHeadTextForceFontColor(dwOwner, MY_TEAM_MON_CORE_PLAYERID) })
			end
			-- 语音报警
			if O.bPushVoiceAlarm and cfg.szVoice and (not cfg.bVoiceSelfOnly or dwOwner == MY_TEAM_MON_CORE_PLAYERID) then
				FireUIEvent('MY_TEAM_MON__VOICE_ALARM', cfg.szVoice)
			end
			if not X.IsRestricted('MY_TeamMon.AutoSelect') and cfg.bSelect then
				SetTarget(X.IsPlayer(dwOwner) and TARGET.PLAYER or TARGET.NPC, dwOwner)
			end

			-- 获得处理
			if nClass == MY_TEAM_MON_TYPE.BUFF_GET then
				if cfg.bAutoCancel and MY_TEAM_MON_CORE_PLAYERID == dwOwner then
					X.CancelBuff(X.GetClientPlayer(), dwBuffID)
				end
				if cfg.tMark then
					D.SetTeamMark(szType, cfg.tMark, dwOwner, dwBuffID, nBuffLevel)
				end
				-- 重要Buff列表
				if O.bPushPartyBuffList and X.IsPlayer(dwOwner) and cfg.bPartyBuffList and (X.IsTeammate(dwOwner) or MY_TEAM_MON_CORE_PLAYERID == dwOwner) then
					FireUIEvent('MY_TEAM_MON__PARTY_BUFF_LIST', dwOwner, data.dwID, data.nLevel, data.nIcon)
				end
				-- 头顶报警
				if O.bPushScreenHead and cfg.bScreenHead then
					FireUIEvent('MY_LIFEBAR_COUNTDOWN', dwOwner, szType, 'MY_TEAM_MON_BUFF_' .. data.dwID, {
						dwBuffID = data.dwID,
						szText = szName,
						col = data.col or (szType == 'BUFF' and {0, 255, 0} or {255, 0, 0}),
					})
				end
				if MY_TEAM_MON_CORE_PLAYERID == dwOwner then
					if O.bPushBuffList and cfg.bBuffList then
						local col = szType == 'BUFF' and { 0, 255, 0 } or { 255, 0, 0 }
						if data.col then
							col = data.col
						end
						FireUIEvent('MY_TEAM_MON__BUFF_LIST__CREATE', data.dwID, data.nLevel, col, data, szSender, szReceiver)
					end
					-- 全屏泛光
					if O.bPushFullScreen and cfg.bFullScreen then
						FireUIEvent('MY_TEAM_MON__FULL_SCREEN_ALARM__CREATE', data.dwID .. '_'  .. data.nLevel, {
							nTime = 3,
							col = data.col,
							tBindBuff = { data.dwID, data.nLevel }
						})
					end
				end
				-- 添加到团队面板
				if O.bPushTeamPanel and cfg.bTeamPanel
				and (not cfg.bOnlySelfSrc or dwSkillSrcID == MY_TEAM_MON_CORE_PLAYERID)
				and X.IsEmpty(data.aCataclysmBuff)
				and not X.IsRestricted('MY_TeamMon.Cataclysm') then
					FireUIEvent('MY_RAID_REC_BUFF', dwOwner, {
						dwID      = data.dwID,
						nLevel    = data.bCheckLevel and data.nLevel or 0,
						nLevelEx  = data.nLevel,
						nStackNum = data.nCount,
						col       = data.col,
						nIcon     = data.nIcon,
						bOnlyMine = cfg.bOnlySelfSrc,
					})
				end
			end
			if O.bPushTeamChannel and cfg.bTeamChannel then
				D.Talk('RAID', szText, szReceiver)
			end
			if O.bPushWhisperChannel and cfg.bWhisperChannel then
				D.Talk('WHISPER', szText, szReceiver)
			end
		end
	end
end

-- 技能事件
function D.OnSkillCast(dwCaster, dwCastID, dwLevel, szEvent)
	if MY_TEAM_MON_SHIELDED_TOTAL then
		return
	end
	if MY_TEAM_MON_SHIELDED_OTHER_PLAYER and X.IsPlayer(dwCaster) and dwCaster ~= MY_TEAM_MON_CORE_PLAYERID then
		return
	end
	local key = dwCastID .. '_' .. dwLevel
	local nTime = GetTime()
	CACHE.SKILL_LIST[dwCaster] = CACHE.SKILL_LIST[dwCaster] or {}
	if CACHE.SKILL_LIST[dwCaster][key] and nTime - CACHE.SKILL_LIST[dwCaster][key] < 62.5 then -- 1/16
		return
	end
	if dwCastID == 13165 then -- 内功切换
		if szEvent == 'UI_OME_SKILL_CAST_LOG' then
			FireUIEvent('MY_KUNGFU_SWITCH', dwCaster)
		end
	end
	local data = D.GetData('CASTING', dwCastID, dwLevel)
	if Table_IsSkillShow(dwCastID, dwLevel) or not X.IsRestricted('MY_TeamMon.HiddenSkill') then
		local tWeak, tTemp = CACHE.TEMP.CASTING, D.TEMP.CASTING
		if not tWeak[key] then
			local t = {
				dwMapID      = X.GetMapID(),
				dwID         = dwCastID,
				nLevel       = dwLevel,
				bIsPlayer    = X.IsPlayer(dwCaster),
				szSrcName    = D.GetSrcName(dwCaster),
				nCurrentTime = GetCurrentTime()
			}
			tWeak[key] = t
			tTemp[#tTemp + 1] = tWeak[key]
			FireUIEvent('MY_TEAM_MON__UI__TEMP_UPDATE', 'CASTING', t)
		end
		CACHE.INTERVAL.CASTING[key] = CACHE.INTERVAL.CASTING[key] or {}
		CACHE.INTERVAL.CASTING[key][#CACHE.INTERVAL.CASTING[key] + 1] = nTime
		CACHE.SKILL_LIST[dwCaster][key] = nTime
	end
	-- 监控数据
	if data then
		if data.nScrutinyType and not D.CheckScrutinyType(data.nScrutinyType, dwCaster) then -- 监控对象检查
			return
		end
		if data.tKungFu and not D.CheckKungFu(data.tKungFu) then -- 自身身法需求检查
			return
		end
		local szName, nIcon = X.GetSkillName(dwCastID, dwLevel)
		local szSender, szReceiver
		local KObject = X.IsPlayer(dwCaster) and X.GetPlayer(dwCaster) or X.GetNpc(dwCaster)
		if KObject then
			szSender = X.GetTargetName(X.IsPlayer(dwCaster) and TARGET.PLAYER or TARGET.NPC, dwCaster)
			szReceiver = X.GetTargetName(KObject.GetTarget())
		else
			szSender = X.GetTargetName(X.IsPlayer(dwCaster) and TARGET.PLAYER or TARGET.NPC, dwCaster)
		end
		if data.szName then
			szName = FilterCustomText(data.szName, szSender, szReceiver)
		end
		if data.nIcon then
			nIcon = data.nIcon
		end
		local cfg, nClass
		if szEvent == 'UI_OME_SKILL_CAST_LOG' then
			cfg, nClass = data[MY_TEAM_MON_TYPE.SKILL_BEGIN], MY_TEAM_MON_TYPE.SKILL_BEGIN
		else
			cfg, nClass = data[MY_TEAM_MON_TYPE.SKILL_END], MY_TEAM_MON_TYPE.SKILL_END
		end
		D.CountdownEvent(data, nClass, szSender, szReceiver)
		if cfg then
			local aXml, aText = {}, {}
			ConstructSpeech(aText, aXml, MY_TEAM_MON_LEFT_BRACKET, MY_TEAM_MON_LEFT_BRACKET_XML)
			ConstructSpeech(aText, aXml, szSender, 44, 255, 255, 0)
			ConstructSpeech(aText, aXml, MY_TEAM_MON_RIGHT_BRACKET, MY_TEAM_MON_RIGHT_BRACKET_XML)
			if nClass == MY_TEAM_MON_TYPE.SKILL_END then
				ConstructSpeech(aText, aXml, _L['use of'], 44, 255, 255, 255)
			else
				ConstructSpeech(aText, aXml, _L['Casting'], 44, 255, 255, 255)
			end
			ConstructSpeech(aText, aXml, MY_TEAM_MON_LEFT_BRACKET, MY_TEAM_MON_LEFT_BRACKET_XML)
			ConstructSpeech(aText, aXml, szName, 44, 255, 255, 0)
			ConstructSpeech(aText, aXml, MY_TEAM_MON_RIGHT_BRACKET, MY_TEAM_MON_RIGHT_BRACKET_XML)
			if data.bMonTarget and szReceiver then
				ConstructSpeech(aText, aXml, g_tStrings.TARGET, 44, 255, 255, 255)
				ConstructSpeech(aText, aXml, MY_TEAM_MON_LEFT_BRACKET, MY_TEAM_MON_LEFT_BRACKET_XML)
				ConstructSpeech(aText, aXml, szReceiver == MY_TEAM_MON_CORE_NAME and g_tStrings.STR_YOU or szReceiver, 44, 255, 255, 0)
				ConstructSpeech(aText, aXml, MY_TEAM_MON_RIGHT_BRACKET, MY_TEAM_MON_RIGHT_BRACKET_XML)
			end
			if data.szNote and not X.IsRestricted('MY_TeamMon.Note') then
				ConstructSpeech(aText, aXml, ' ' .. FilterCustomText(data.szNote, szSender, szReceiver), 44, 255, 255, 255)
			end
			local szXml, szText = table.concat(aXml), table.concat(aText)
			if O.bPushCenterAlarm and cfg.bCenterAlarm then
				FireUIEvent('MY_TEAM_MON__CENTER_ALARM__CREATE', szXml, 3, true)
			end
			-- 特大文字
			if O.bPushBigFontAlarm and cfg.bBigFontAlarm then
				FireUIEvent('MY_TEAM_MON__LARGE_TEXT_ALARM', szText, data.col or { GetHeadTextForceFontColor(dwCaster, MY_TEAM_MON_CORE_PLAYERID) })
			end
			if not X.IsRestricted('MY_TeamMon.AutoSelect') and cfg.bSelect then
				SetTarget(X.IsPlayer(dwCaster) and TARGET.PLAYER or TARGET.NPC, dwCaster)
			end
			if cfg.tMark then
				D.SetTeamMark('CASTING', cfg.tMark, dwCaster, dwCastID, dwLevel)
			end
			-- 语音报警
			if O.bPushVoiceAlarm and cfg.szVoice then
				FireUIEvent('MY_TEAM_MON__VOICE_ALARM', cfg.szVoice)
			end
			-- 头顶报警
			if O.bPushScreenHead and cfg.bScreenHead then
				FireUIEvent('MY_LIFEBAR_COUNTDOWN', dwCaster, 'CASTING', 'MY_TEAM_MON_CASTING_' .. data.dwID, {
					dwSkillID = dwCastID,
					szText = szName,
					col = data.col,
				})
			end
			-- 全屏泛光
			if O.bPushFullScreen and cfg.bFullScreen then
				FireUIEvent('MY_TEAM_MON__FULL_SCREEN_ALARM__CREATE', data.dwID .. '#SKILL#'  .. data.nLevel, { nTime = 3, col = data.col})
			end
			if O.bPushTeamChannel and cfg.bTeamChannel then
				D.Talk('RAID', szText, szReceiver)
			end
			if O.bPushWhisperChannel and cfg.bWhisperChannel then
				D.Talk('RAID_WHISPER', szText, szReceiver)
			end
		end
	end
end

-- NPC事件
function D.OnNpcEvent(npc, bEnter)
	local data = D.GetData('NPC', npc.dwTemplateID)
	local nTime = GetTime()
	if MY_TEAM_MON_SHIELDED_OTHER_PLAYER and X.IsPlayer(npc.dwEmployer) and npc.dwEmployer ~= MY_TEAM_MON_CORE_PLAYERID then
		return
	end
	if bEnter then
		if not CACHE.NPC_LIST[npc.dwTemplateID] then
			CACHE.NPC_LIST[npc.dwTemplateID] = {
				tList       = {},
				nTime       = -1,
				nCount      = 0,
			}
		end
		CACHE.NPC_LIST[npc.dwTemplateID].tList[npc.dwID] = {
			bFightState = false,
		}
		CACHE.NPC_LIST[npc.dwTemplateID].nCount = CACHE.NPC_LIST[npc.dwTemplateID].nCount + 1
		local tWeak, tTemp = CACHE.TEMP.NPC, D.TEMP.NPC
		if not tWeak[npc.dwTemplateID] then
			local t = {
				dwMapID      = X.GetMapID(),
				dwID         = npc.dwTemplateID,
				nFrame       = select(2, GetNpcHeadImage(npc.dwID)),
				col          = { GetHeadTextForceFontColor(npc.dwID, MY_TEAM_MON_CORE_PLAYERID) },
				nCurrentTime = GetCurrentTime()
			}
			tWeak[npc.dwTemplateID] = t
			tTemp[#tTemp + 1] = tWeak[npc.dwTemplateID]
			FireUIEvent('MY_TEAM_MON__UI__TEMP_UPDATE', 'NPC', t)
		end
		CACHE.INTERVAL.NPC[npc.dwTemplateID] = CACHE.INTERVAL.NPC[npc.dwTemplateID] or {}
		if #CACHE.INTERVAL.NPC[npc.dwTemplateID] > 0 then
			if nTime - CACHE.INTERVAL.NPC[npc.dwTemplateID][#CACHE.INTERVAL.NPC[npc.dwTemplateID]] > 500 then
				CACHE.INTERVAL.NPC[npc.dwTemplateID][#CACHE.INTERVAL.NPC[npc.dwTemplateID] + 1] = nTime
			end
		else
			CACHE.INTERVAL.NPC[npc.dwTemplateID][#CACHE.INTERVAL.NPC[npc.dwTemplateID] + 1] = nTime
		end
	else
		local npcInfo = CACHE.NPC_LIST[npc.dwTemplateID]
		if npcInfo then
			local tab = npcInfo.tList[npc.dwID]
			if tab then
				npcInfo.tList[npc.dwID] = nil
				npcInfo.nCount = npcInfo.nCount - 1
				if tab.bFightState then
					FireUIEvent('MY_TEAM_MON_NPC_FIGHT', npc.dwTemplateID, false, GetTime() - (tab.nSec or GetTime()))
				end
				if npcInfo.nCount == 0 then
					CACHE.NPC_LIST[npc.dwTemplateID] = nil
					FireUIEvent('MY_TEAM_MON_ALL_LEAVE_SCENE', npc.dwTemplateID)
				end
			end
		end
	end
	if MY_TEAM_MON_SHIELDED_TOTAL or MY_TEAM_MON_SHIELDED_ENTER_LEAVE_SCENE then
		return
	end
	if data then
		local cfg, nClass, nCount
		if data.tKungFu and not D.CheckKungFu(data.tKungFu) then -- 自身身法需求检查
			return
		end
		local szSender = nil
		local szReceiver = X.GetNpcName(npc.dwID)
		if bEnter then
			cfg, nClass = data[MY_TEAM_MON_TYPE.NPC_ENTER], MY_TEAM_MON_TYPE.NPC_ENTER
			nCount = CACHE.NPC_LIST[npc.dwTemplateID].nCount
		else
			cfg, nClass = data[MY_TEAM_MON_TYPE.NPC_LEAVE], MY_TEAM_MON_TYPE.NPC_LEAVE
		end
		if nClass == MY_TEAM_MON_TYPE.NPC_LEAVE then
			if data.bAllLeave and CACHE.NPC_LIST[npc.dwTemplateID] then
				return
			end
		else
			-- 场地上的NPC数量没达到预期数量
			if data.nCount and nCount < data.nCount then
				return
			end
			if cfg then
				if cfg.tMark then
					D.SetTeamMark('NPC', cfg.tMark, npc.dwID, npc.dwTemplateID)
				end
				-- 头顶报警
				if O.bPushScreenHead and cfg.bScreenHead then
					local szNote, szName = nil, FilterCustomText(data.szName, szSender, szReceiver)
					if not X.IsRestricted('MY_TeamMon.Note') then
						szNote = FilterCustomText(data.szNote, szSender, szReceiver) or szName
					end
					FireUIEvent('MY_LIFEBAR_COUNTDOWN', npc.dwID, 'NPC', 'MY_TEAM_MON_NPC_' .. npc.dwID, {
						szName = szName,
						szText = szNote,
						col = data.col,
					})
				end
			end
			if nTime - CACHE.NPC_LIST[npc.dwTemplateID].nTime < 500 then -- 0.5秒内进入相同的NPC直接忽略
				return -- D.Log('IGNORE NPC ENTER SCENE ID:' .. npc.dwTemplateID .. ' TIME:' .. nTime .. ' TIME2:' .. CACHE.NPC_LIST[npc.dwTemplateID].nTime)
			else
				CACHE.NPC_LIST[npc.dwTemplateID].nTime = nTime
			end
		end
		D.CountdownEvent(data, nClass, szSender, szReceiver)
		if cfg then
			local szName = szReceiver
			if data.szName then
				szName = FilterCustomText(data.szName, szSender, szReceiver)
			end
			local aXml, aText = {}, {}
			ConstructSpeech(aText, aXml, MY_TEAM_MON_LEFT_BRACKET, MY_TEAM_MON_LEFT_BRACKET_XML)
			ConstructSpeech(aText, aXml, szName, 44, 255, 255, 0)
			ConstructSpeech(aText, aXml, MY_TEAM_MON_RIGHT_BRACKET, MY_TEAM_MON_RIGHT_BRACKET_XML)
			if nClass == MY_TEAM_MON_TYPE.NPC_ENTER then
				ConstructSpeech(aText, aXml, _L['Appear'], 44, 255, 255, 255)
				if nCount > 1 then
					ConstructSpeech(aText, aXml, ' x' .. nCount, 44, 255, 255, 0)
				end
				if data.szNote and not X.IsRestricted('MY_TeamMon.Note') then
					ConstructSpeech(aText, aXml, ' ' .. FilterCustomText(data.szNote, szSender, szReceiver), 44, 255, 255, 255)
				end
			else
				ConstructSpeech(aText, aXml, _L['Disappear'], 44, 255, 255, 255)
			end
			local szXml, szText = table.concat(aXml), table.concat(aText)
			if O.bPushCenterAlarm and cfg.bCenterAlarm then
				FireUIEvent('MY_TEAM_MON__CENTER_ALARM__CREATE', szXml, 3, true)
			end
			-- 特大文字
			if O.bPushBigFontAlarm and cfg.bBigFontAlarm then
				FireUIEvent('MY_TEAM_MON__LARGE_TEXT_ALARM', szText, data.col or { GetHeadTextForceFontColor(npc.dwID, MY_TEAM_MON_CORE_PLAYERID) })
			end
			-- 语音报警
			if O.bPushVoiceAlarm and cfg.szVoice then
				FireUIEvent('MY_TEAM_MON__VOICE_ALARM', cfg.szVoice)
			end

			if O.bPushTeamChannel and cfg.bTeamChannel then
				D.Talk('RAID', szText)
			end
			if O.bPushWhisperChannel and cfg.bWhisperChannel then
				D.Talk('RAID_WHISPER', szText)
			end

			if nClass == MY_TEAM_MON_TYPE.NPC_ENTER then
				if not X.IsRestricted('MY_TeamMon.AutoSelect') and cfg.bSelect then
					SetTarget(TARGET.NPC, npc.dwID)
				end
				if O.bPushFullScreen and cfg.bFullScreen then
					FireUIEvent('MY_TEAM_MON__FULL_SCREEN_ALARM__CREATE', 'NPC', { nTime  = 3, col = data.col, bFlash = true })
				end
			end
		end
	end
end

-- DOODAD事件
function D.OnDoodadEvent(doodad, bEnter)
	local data = D.GetData('DOODAD', doodad.dwTemplateID)
	local nTime = GetTime()
	if bEnter then
		if not CACHE.DOODAD_LIST[doodad.dwTemplateID] then
			CACHE.DOODAD_LIST[doodad.dwTemplateID] = {
				tList       = {},
				nTime       = -1,
				nCount      = 0,
			}
		end
		CACHE.DOODAD_LIST[doodad.dwTemplateID].tList[doodad.dwID] = {}
		CACHE.DOODAD_LIST[doodad.dwTemplateID].nCount = CACHE.DOODAD_LIST[doodad.dwTemplateID].nCount + 1
		if doodad.nKind ~= DOODAD_KIND.ORNAMENT or not X.IsRestricted('MY_TeamMon.HiddenDoodad') then
			local tWeak, tTemp = CACHE.TEMP.DOODAD, D.TEMP.DOODAD
			if not tWeak[doodad.dwTemplateID] then
				local t = {
					dwMapID      = X.GetMapID(),
					dwID         = doodad.dwTemplateID,
					nCurrentTime = GetCurrentTime()
				}
				tWeak[doodad.dwTemplateID] = t
				tTemp[#tTemp + 1] = tWeak[doodad.dwTemplateID]
				FireUIEvent('MY_TEAM_MON__UI__TEMP_UPDATE', 'DOODAD', t)
			end
		end
		CACHE.INTERVAL.DOODAD[doodad.dwTemplateID] = CACHE.INTERVAL.DOODAD[doodad.dwTemplateID] or {}
		if #CACHE.INTERVAL.DOODAD[doodad.dwTemplateID] > 0 then
			if nTime - CACHE.INTERVAL.DOODAD[doodad.dwTemplateID][#CACHE.INTERVAL.DOODAD[doodad.dwTemplateID]] > 500 then
				CACHE.INTERVAL.DOODAD[doodad.dwTemplateID][#CACHE.INTERVAL.DOODAD[doodad.dwTemplateID] + 1] = nTime
			end
		else
			CACHE.INTERVAL.DOODAD[doodad.dwTemplateID][#CACHE.INTERVAL.DOODAD[doodad.dwTemplateID] + 1] = nTime
		end
	else
		local doodadInfo = CACHE.DOODAD_LIST[doodad.dwTemplateID]
		if doodadInfo then
			local tab = doodadInfo.tList[doodad.dwID]
			if tab then
				doodadInfo.tList[doodad.dwID] = nil
				doodadInfo.nCount = doodadInfo.nCount - 1
				if doodadInfo.nCount == 0 then
					CACHE.DOODAD_LIST[doodad.dwTemplateID] = nil
					FireUIEvent('MY_TEAM_MON_DOODAD_ALL_LEAVE_SCENE', doodad.dwTemplateID)
				end
			end
		end
	end
	if MY_TEAM_MON_SHIELDED_TOTAL or MY_TEAM_MON_SHIELDED_ENTER_LEAVE_SCENE then
		return
	end
	if data then
		local cfg, nClass, nCount
		if data.tKungFu and not D.CheckKungFu(data.tKungFu) then -- 自身身法需求检查
			return
		end
		local szSender = nil
		local szReceiver = X.GetDoodadName(doodad.dwID)
		if bEnter then
			cfg, nClass = data[MY_TEAM_MON_TYPE.DOODAD_ENTER], MY_TEAM_MON_TYPE.DOODAD_ENTER
			nCount = CACHE.DOODAD_LIST[doodad.dwTemplateID].nCount
		else
			cfg, nClass = data[MY_TEAM_MON_TYPE.DOODAD_LEAVE], MY_TEAM_MON_TYPE.DOODAD_LEAVE
		end
		if nClass == MY_TEAM_MON_TYPE.DOODAD_LEAVE then
			if data.bAllLeave and CACHE.DOODAD_LIST[doodad.dwTemplateID] then
				return
			end
		else
			-- 场地上的DOODAD数量没达到预期数量
			if data.nCount and nCount < data.nCount then
				return
			end
			if cfg then
				-- 头顶报警
				if O.bPushScreenHead and cfg.bScreenHead then
					local szNote, szName = nil, FilterCustomText(data.szName, szSender, szReceiver)
					if not X.IsRestricted('MY_TeamMon.Note') then
						szNote = FilterCustomText(data.szNote, szSender, szReceiver) or szName
					end
					FireUIEvent('MY_LIFEBAR_COUNTDOWN', doodad.dwID, 'DOODAD', 'MY_TEAM_MON_DOODAD_' .. doodad.dwID, {
						szName = szName,
						szText = szNote,
						col = data.col,
					})
				end
			end
			if nTime - CACHE.DOODAD_LIST[doodad.dwTemplateID].nTime < 500 then
				return
			else
				CACHE.DOODAD_LIST[doodad.dwTemplateID].nTime = nTime
			end
		end
		D.CountdownEvent(data, nClass, szSender, szReceiver)
		if cfg then
			local szName = szReceiver
			if data.szName then
				szName = FilterCustomText(data.szName, szSender, szReceiver)
			end
			local aXml, aText = {}, {}
			ConstructSpeech(aText, aXml, MY_TEAM_MON_LEFT_BRACKET, MY_TEAM_MON_LEFT_BRACKET_XML)
			ConstructSpeech(aText, aXml, szName, 44, 255, 255, 0)
			ConstructSpeech(aText, aXml, MY_TEAM_MON_RIGHT_BRACKET, MY_TEAM_MON_RIGHT_BRACKET_XML)
			if nClass == MY_TEAM_MON_TYPE.DOODAD_ENTER then
				ConstructSpeech(aText, aXml, _L['Appear'], 44, 255, 255, 255)
				if nCount > 1 then
					ConstructSpeech(aText, aXml, ' x' .. nCount, 44, 255, 255, 0)
				end
				if data.szNote and not X.IsRestricted('MY_TeamMon.Note') then
					ConstructSpeech(aText, aXml, ' ' .. FilterCustomText(data.szNote, szSender, szReceiver), 44, 255, 255, 255)
				end
			else
				ConstructSpeech(aText, aXml, _L['Disappear'], 44, 255, 255, 255)
			end
			local szXml, szText = table.concat(aXml), table.concat(aText)
			if O.bPushCenterAlarm and cfg.bCenterAlarm then
				FireUIEvent('MY_TEAM_MON__CENTER_ALARM__CREATE', szXml, 3, true)
			end
			-- 特大文字
			if O.bPushBigFontAlarm and cfg.bBigFontAlarm then
				FireUIEvent('MY_TEAM_MON__LARGE_TEXT_ALARM', szText, data.col or { 255, 255, 0 })
			end
			-- 语音报警
			if O.bPushVoiceAlarm and cfg.szVoice then
				FireUIEvent('MY_TEAM_MON__VOICE_ALARM', cfg.szVoice)
			end

			if O.bPushTeamChannel and cfg.bTeamChannel then
				D.Talk('RAID', szText)
			end
			if O.bPushWhisperChannel and cfg.bWhisperChannel then
				D.Talk('RAID_WHISPER', szText)
			end

			if nClass == MY_TEAM_MON_TYPE.DOODAD_ENTER then
				if not X.IsRestricted('MY_TeamMon.AutoSelect') and cfg.bSelect then
					SetTarget(TARGET.DOODAD, doodad.dwID)
				end
				if O.bPushFullScreen and cfg.bFullScreen then
					FireUIEvent('MY_TEAM_MON__FULL_SCREEN_ALARM__CREATE', 'DOODAD', { nTime  = 3, col = data.col, bFlash = true })
				end
			end
		end
	end
end

function D.OnDoodadAllLeave(dwTemplateID)
	if MY_TEAM_MON_SHIELDED_TOTAL or MY_TEAM_MON_SHIELDED_ENTER_LEAVE_SCENE then
		return
	end
	local data = D.GetData('DOODAD', dwTemplateID)
	if data then
		local szSender = nil
		local szReceiver = X.GetDoodadTemplateName(dwTemplateID)
		D.CountdownEvent(data, MY_TEAM_MON_TYPE.DOODAD_ALLLEAVE, szSender, szReceiver)
	end
end

-- 系统和NPC喊话处理
-- OutputMessage('MSG_SYS', 1..'\n')
function D.OnCallMessage(szEvent, szContent, dwNpcID, szNpcName)
	if MY_TEAM_MON_SHIELDED_TOTAL then
		return
	end
	if dwNpcID and not X.IsPlayer(dwNpcID) then
		local npc = X.GetNpc(dwNpcID)
		if npc and X.IsShieldedNpc(npc.dwTemplateID, 'TALK') then
			return
		end
	end
	-- 近期记录
	szContent = tostring(szContent)
	local me = X.GetClientPlayer()
	local key = (szNpcName or 'sys') .. '::' .. szContent
	local tWeak, tTemp = CACHE.TEMP[szEvent], D.TEMP[szEvent]
	if not tWeak[key] then
		local t = {
			dwMapID      = me.GetMapID(),
			szContent    = szContent,
			szTarget     = szNpcName,
			nCurrentTime = GetCurrentTime()
		}
		tWeak[key] = t
		tTemp[#tTemp + 1] = tWeak[key]
		FireUIEvent('MY_TEAM_MON__UI__TEMP_UPDATE', szEvent, t)
	end
	local cache, data = CACHE.MAP[szEvent], nil
	if cache.HIT[szContent] then
		data = cache.HIT[szContent][szNpcName or 'sys']
			or cache.HIT[szContent]['%']
	end
	local szSender, dwReceiverID, szReceiver, aBackreferences = szNpcName or _L['JX3']
	if not data then -- 涉及匹配的规则不会被缓存，不适用 wstring ，性能考虑为前提
		local bInParty = me.IsInParty()
		local team     = GetClientTeam()
		for _, v in ipairs(cache.OTHER) do -- 按照数据优先级顺序（地图＞地图组＞通用），同级按照下标先后顺序，只取第一个匹配结果
			local content = v.szContent
			if v.szContent:find('{$me}', nil, true) then
				dwReceiverID = me.dwID
				szReceiver = me.szName
				content = v.szContent:gsub('{$me}', me.szName) -- 转换me是自己名字
			else
				dwReceiverID, szReceiver = nil
			end
			if bInParty and content:find('{$team}', nil, true) then
				if v.bReg then
					-- 正则模式（带{$team}）：逆向排除，先遍历成员名，替换为空，若替换成功，说明命中，再将正则规则{$team}替换为空，匹配剩余的内容，如此只用一次正则，节约性能
					local nHitMemberID, szHitMemberName, szProcessedContent
					local tMembers = {}
					-- 按名字长度降序排序，避免名字包含关系导致误判替换
					for _, vv in ipairs(team.GetTeamMemberList()) do
						tMembers[#tMembers + 1] = { dwID = vv, szName = team.GetClientTeamMemberName(vv) }
					end
					table.sort(tMembers, function(a, b) return #a.szName > #b.szName end)
					-- 替换正则规则{$team}为空，并获取{$team}数量，决定后续成员名替换为空次数
					local szPattern, nTeamCount = content:gsub('{$team}', '')
					for _, member in ipairs(tMembers) do
						local szReplaced = string.gsub(szContent, member.szName, '', nTeamCount)
						if #szReplaced < #szContent then
							nHitMemberID = member.dwID
							szHitMemberName = member.szName
							szProcessedContent = szReplaced
							break
						end
					end
					if nHitMemberID and szHitMemberName then
						local res = {string.find(szProcessedContent, szPattern)}
						if res[1] then
							table.remove(res, 1)
							table.remove(res, 1)
							data = v
							aBackreferences = res
							dwReceiverID = nHitMemberID
							szReceiver = szHitMemberName
							break
						end
					end
				else
					local c = content
					for _, vv in ipairs(team.GetTeamMemberList()) do
						if string.find(szContent, c:gsub('{$team}', team.GetClientTeamMemberName(vv)), nil, true) and (v.szTarget == szNpcName or v.szTarget == '%') then -- hit
							data = v
							dwReceiverID = vv
							szReceiver = team.GetClientTeamMemberName(vv)
							break
						end
					end
					if dwReceiverID and szReceiver then
						break
					end
				end
			elseif v.szTarget == szNpcName or v.szTarget == '%' then
				if v.bReg then
					local res = {string.find(szContent, content)}
					if res[1] then
						table.remove(res, 1)
						table.remove(res, 1)
						data = v
						aBackreferences = res
						break
					end
				elseif string.find(szContent, content, nil, true) then
					data = v
					break
				end
			end
		end
	end
	if data then
		local nClass = szEvent == 'TALK'
			and MY_TEAM_MON_TYPE.TALK_MONITOR
			or MY_TEAM_MON_TYPE.CHAT_MONITOR
		if not dwReceiverID and not szReceiver and data.szContent:find('{$me}', nil, true) then
			dwReceiverID = me.dwID
			szReceiver = me.szName
		end
		D.CountdownEvent(data, nClass, szSender, szReceiver, aBackreferences)
		local cfg = data[nClass]
		if cfg then
			local aXml, aText, aTalkXml, aTalkText = {}, {}, {}, {}
			if szReceiver then
				ConstructSpeech(aTalkText, aTalkXml, MY_TEAM_MON_LEFT_BRACKET, MY_TEAM_MON_LEFT_BRACKET_XML)
				ConstructSpeech(aTalkText, aTalkXml, szSender, 44, 255, 255, 0)
				ConstructSpeech(aTalkText, aTalkXml, MY_TEAM_MON_RIGHT_BRACKET, MY_TEAM_MON_RIGHT_BRACKET_XML)
				ConstructSpeech(aTalkText, aTalkXml, _L['is calling'], 44, 255, 255, 255)
				ConstructSpeech(aTalkText, aTalkXml, MY_TEAM_MON_LEFT_BRACKET, MY_TEAM_MON_LEFT_BRACKET_XML)
				ConstructSpeech(aTalkText, aTalkXml, szReceiver == me.szName and g_tStrings.STR_YOU or szReceiver, 44, 255, 255, 0)
				ConstructSpeech(aTalkText, aTalkXml, MY_TEAM_MON_RIGHT_BRACKET, MY_TEAM_MON_RIGHT_BRACKET_XML)
				ConstructSpeech(aTalkText, aTalkXml, _L['\'s name.'], 44, 255, 255, 255)
			else
				ConstructSpeech(aTalkText, aTalkXml, MY_TEAM_MON_LEFT_BRACKET, MY_TEAM_MON_LEFT_BRACKET_XML)
				ConstructSpeech(aTalkText, aTalkXml, szSender, 44, 255, 255, 0)
				ConstructSpeech(aTalkText, aTalkXml, MY_TEAM_MON_RIGHT_BRACKET, MY_TEAM_MON_RIGHT_BRACKET_XML)
				ConstructSpeech(aTalkText, aTalkXml, g_tStrings.HEADER_SHOW_SAY, 44, 255, 255, 0)
				ConstructSpeech(aTalkText, aTalkXml, szContent, 44, 255, 255, 0)
			end
			if data.szNote then
				ConstructSpeech(aText, aXml, FilterCustomText(data.szNote, szSender, szReceiver, aBackreferences) or szContent, 44, 255, 255, 255)
			end
			local szXml, szText, szTalkXml, szTalkText = table.concat(aXml), table.concat(aText), table.concat(aTalkXml), table.concat(aTalkText)
			if X.IsEmpty(szXml) then
				szXml = szTalkXml
			end
			if X.IsEmpty(szText) then
				szText = szTalkText
			end
			if dwReceiverID then -- 点了人名
				if O.bPushWhisperChannel and cfg.bWhisperChannel then
					D.Talk('WHISPER', szTalkText, szReceiver)
				end
				-- 头顶报警
				if O.bPushScreenHead and cfg.bScreenHead then
					FireUIEvent('MY_LIFEBAR_COUNTDOWN', dwReceiverID, 'TIME', 'MY_TEAM_MON_TIME_' .. dwReceiverID, {
						nTime = GetTime() + 5000,
						szText = _L('%s call name', szNpcName or g_tStrings.SYSTEM),
						col = data.col,
						bHideProgress = true,
					})
				end
				if not X.IsRestricted('MY_TeamMon.AutoSelect') and cfg.bSelect then
					SetTarget(TARGET.PLAYER, dwReceiverID)
				end
			else -- 没点名
				if O.bPushWhisperChannel and cfg.bWhisperChannel then
					D.Talk('RAID_WHISPER', szTalkText)
				end
				-- 头顶报警
				if O.bPushScreenHead and cfg.bScreenHead then
					FireUIEvent('MY_LIFEBAR_COUNTDOWN', dwNpcID or me.dwID, 'TIME', 'MY_TEAM_MON_TIME_' .. (dwNpcID or me.dwID), {
						nTime = GetTime() + 5000,
						szText = szText,
						col = data.col,
						bHideProgress = true,
					})
				end
			end
			-- 中央报警
			if O.bPushCenterAlarm and cfg.bCenterAlarm then
				FireUIEvent('MY_TEAM_MON__CENTER_ALARM__CREATE', #aXml > 0 and szXml or szText, 3, #aXml > 0)
			end
			-- 特大文字
			if O.bPushBigFontAlarm and cfg.bBigFontAlarm then
				FireUIEvent('MY_TEAM_MON__LARGE_TEXT_ALARM', szText, data.col or { 255, 128, 0 })
			end
			-- 语音报警
			if O.bPushVoiceAlarm and cfg.szVoice then
				FireUIEvent('MY_TEAM_MON__VOICE_ALARM', cfg.szVoice)
			end
			if O.bPushFullScreen and cfg.bFullScreen then
				if not dwReceiverID or dwReceiverID == me.dwID then
					FireUIEvent('MY_TEAM_MON__FULL_SCREEN_ALARM__CREATE', szEvent, { nTime  = 3, col = data.col or { 0, 255, 0 }, bFlash = true })
				end
			end
			if O.bPushTeamChannel and cfg.bTeamChannel then
				if szReceiver and not data.szNote then
					D.Talk('RAID', szTalkText, szReceiver)
				else
					D.Talk('RAID', szTalkText)
				end
			end
		end
	end
end

-- NPC死亡事件 触发倒计时
function D.OnDeath(dwCharacterID, dwKiller)
	if MY_TEAM_MON_SHIELDED_TOTAL then
		return
	end
	local npc = X.GetNpc(dwCharacterID)
	if npc then
		local data = D.GetData('NPC', npc.dwTemplateID)
		if data then
			local dwTemplateID = npc.dwTemplateID
			local szSender = X.GetTargetName(X.IsPlayer(dwKiller) and TARGET.PLAYER or TARGET.NPC, dwKiller, { eShowID = 'auto' })
			local szReceiver = X.GetNpcName(npc.dwID)
			D.CountdownEvent(data, MY_TEAM_MON_TYPE.NPC_DEATH, szSender, szReceiver)
			local bAllDeath = true
			if CACHE.NPC_LIST[dwTemplateID] then
				for k, v in pairs(CACHE.NPC_LIST[dwTemplateID].tList) do
					local npc = X.GetNpc(k)
					if npc and npc.nMoveState ~= MOVE_STATE.ON_DEATH then
						bAllDeath = false
						break
					end
				end
			end
			if bAllDeath then
				D.CountdownEvent(data, MY_TEAM_MON_TYPE.NPC_ALLDEATH, szSender, szReceiver)
			end
		end
	end
end

-- NPC进出战斗事件 触发倒计时
function D.OnNpcFight(dwTemplateID, bFight)
	if MY_TEAM_MON_SHIELDED_TOTAL then
		return
	end
	local data = D.GetData('NPC', dwTemplateID)
	if data then
		local szSender = nil
		local szReceiver = X.GetNpcTemplateName(dwTemplateID)
		if bFight then
			D.CountdownEvent(data, MY_TEAM_MON_TYPE.NPC_FIGHT, szSender, szReceiver)
		elseif data.tCountdown then -- 脱离的时候清空下
			for i, v in ipairs(data.tCountdown) do
				if v.nClass == MY_TEAM_MON_TYPE.NPC_FIGHT and not v.bFightHold then
					local nType, szKey = D.GetCountdownTypeKey(data, i, szSender, szReceiver)
					FireUIEvent('MY_TEAM_MON__SPELL_TIMER__DEL', nType, szKey) -- try kill
				end
			end
		end
	end
end

-- 不该放在倒计时中 需要重构
function D.OnNpcInfoChange(szEvent, dwTemplateID, nPer, bIncrease)
	if MY_TEAM_MON_SHIELDED_TOTAL then
		return
	end
	local data = D.GetData('NPC', dwTemplateID)
	if data and data.tCountdown then
		local dwType = szEvent == 'MY_TEAM_MON_NPC_LIFE_CHANGE' and MY_TEAM_MON_TYPE.NPC_LIFE or MY_TEAM_MON_TYPE.NPC_MANA
		local szSender = nil
		local szReceiver = X.GetNpcTemplateName(dwTemplateID)
		for k, v in ipairs(data.tCountdown) do
			if v.nClass == dwType then
				local aHPCountdown = ParseHPCountdown(v.nTime)
				for kk, tHpCd in ipairs(aHPCountdown) do
					if tHpCd.nValue == nPer
					and (tHpCd.szOperator == '*' or (bIncrease and tHpCd.szOperator == '+') or (not bIncrease and tHpCd.szOperator == '-')) then -- hit
						local szName = FilterCustomText(data.szName, szSender, szReceiver) or szReceiver
						local aXml, aText = {}, {}
						ConstructSpeech(aText, aXml, MY_TEAM_MON_LEFT_BRACKET, MY_TEAM_MON_LEFT_BRACKET_XML)
						ConstructSpeech(aText, aXml, szName, 44, 255, 255, 0)
						ConstructSpeech(aText, aXml, MY_TEAM_MON_RIGHT_BRACKET, MY_TEAM_MON_RIGHT_BRACKET_XML)
						ConstructSpeech(aText, aXml, dwType == MY_TEAM_MON_TYPE.NPC_LIFE and _L['\'s life remaining to '] or _L['\'s mana reaches '], 44, 255, 255, 255)
						ConstructSpeech(aText, aXml, ' ' .. tHpCd.nValue .. '%', 44, 255, 255, 0)
						ConstructSpeech(aText, aXml, ' ' .. FilterCustomText(tHpCd.szContent, szSender, szReceiver), 44, 255, 255, 255)
						local szXml, szText = table.concat(aXml), table.concat(aText)
						if O.bPushCenterAlarm then
							FireUIEvent('MY_TEAM_MON__CENTER_ALARM__CREATE', szXml, 3, true)
						end
						if O.bPushBigFontAlarm then
							FireUIEvent('MY_TEAM_MON__LARGE_TEXT_ALARM', szText, data.col or { 255, 128, 0 })
						end
						if O.bPushTeamChannel and v.bTeamChannel then
							D.Talk('RAID', szText)
						end
						if O.bPushVoiceAlarm and tHpCd.szVoice then
							FireUIEvent('MY_TEAM_MON__VOICE_ALARM', tHpCd.szVoice)
						end
						if tHpCd.nTime then
							local nType, szKey = v.nClass, v.key
							if szKey then
								nType = MY_TEAM_MON_TYPE.COMMON
							else
								szKey = k .. '.' .. dwTemplateID .. '.' .. kk
							end
							local tParam = {
								nIcon     = v.nIcon,
								nFrame    = v.nFrame,
								szContent = FilterCustomText(tHpCd.szContent, szSender, szReceiver),
								nTime     = tHpCd.nTime,
								bTalk     = v.bTeamChannel,
								bHold     = v.bHold,
							}
							D.FireCountdownEvent(nType, szKey, tParam, szSender, szReceiver)
						end
						break
					end
				end
			end
		end
	end
end

-- NPC 全部消失的倒计时处理
function D.OnNpcAllLeave(dwTemplateID)
	if MY_TEAM_MON_SHIELDED_TOTAL or MY_TEAM_MON_SHIELDED_ENTER_LEAVE_SCENE then
		return
	end
	local data = D.GetData('NPC', dwTemplateID)
	local szSender = nil
	local szReceiver = X.GetNpcTemplateName(dwTemplateID)
	if data then
		D.CountdownEvent(data, MY_TEAM_MON_TYPE.NPC_ALLLEAVE, szSender, szReceiver)
	end
end

local MAP_ID, PREV_MAP_ID
function D.FireCrossMapEvent(szWhen)
	local dwMapID = X.GetMapID(true)
	if szWhen == 'before' then
		if PREV_MAP_ID and PREV_MAP_ID ~= dwMapID then
			local map = PREV_MAP_ID and X.GetMapInfo(PREV_MAP_ID)
			if map then
				local szEvent = 'CHAT'
				local szContent = _L('Leave map %s.', map.szName)
				D.OnCallMessage(szEvent, szContent)
			end
			PREV_MAP_ID = dwMapID
		end
	elseif szWhen == 'after' then
		if MAP_ID ~= dwMapID then
			local map = X.GetMapInfo(dwMapID)
			if map then
				local szEvent = 'CHAT'
				local szContent = _L('Enter map %s.', map.szName)
				D.OnCallMessage(szEvent, szContent)
			end
			MAP_ID = dwMapID
		end
	end
end

-- RegisterMsgMonitor
function D.RegisterMessage(bEnable)
	if bEnable then
		X.RegisterMsgMonitor('MSG_SYS', 'MY_TeamMon_MON', function(szChannel, szMsg, nFont, bRich)
			if MY_TEAM_MON_SHIELDED_TOTAL then
				return
			end
			if not X.GetClientPlayer() then
				return
			end
			if bRich then
				szMsg = MY_GetPureText(szMsg)
			end
			-- local res, err = pcall(D.OnCallMessage, 'CHAT', szMsg:gsub('\r', ''))
			-- if not res then
			-- 	return X.OutputDebugMessage(err, X.DEBUG_LEVEL.WARNING)
			-- end
			szMsg = szMsg:gsub('\r', '')
			D.OnCallMessage('CHAT', szMsg)
		end)
	else
		X.RegisterMsgMonitor('MSG_SYS', 'MY_TeamMon_MON', false)
	end
end

-- UI操作
function D.GetFrame()
	return Station.Lookup('Normal/MY_TeamMon')
end

function D.Open()
	local frame = D.GetFrame()
	if frame then
		for k, v in ipairs(MY_TEAM_MON_EVENTS) do
			frame:UnRegisterEvent(v)
			frame:RegisterEvent(v)
		end
		D.RegisterMessage(true)
	end
end

function D.Close()
	local frame = D.GetFrame()
	if frame then
		for k, v in ipairs(MY_TEAM_MON_EVENTS) do
			frame:UnRegisterEvent(v)  -- kill all event
		end
		D.RegisterMessage(false)
		FireUIEvent('MY_TEAM_MON__SPELL_TIMER__CLEAR')
		CACHE.NPC_LIST    = {}
		CACHE.DOODAD_LIST = {}
		CACHE.SKILL_LIST  = {}
		collectgarbage('collect')
	end
end

function D.Enable(bEnable, bFireUIEvent)
	if D.bReady and bEnable then
		local res, err = pcall(D.Open)
		if not res then
			return X.OutputDebugMessage(err, X.DEBUG_LEVEL.WARNING)
		end
		if bFireUIEvent then
			FireUIEvent('MY_TEAM_MON_LOADING_END')
		end
		FireUIEvent('MY_TEAM_MON_CREATE_CACHE')
	else
		D.Close()
	end
end

function D.Init()
	local K = string.char(75, 69)
	local k = string.char(80, 87)
	if X.IsString(D[k]) then
		D[k] = X[K](D[k] .. string.char(77, 89))
	end
	D.LoadUserData()
	X.UI.OpenFrame(MY_TEAM_MON_INI_FILE, 'MY_TeamMon')
end

-- 保存用户监控数据、配置
function D.SaveUserData()
	X.SaveLUAData(
		GetUserDataPath(),
		{
			data = D.FILE,
			meta = D.META,
			config = D.CONFIG,
		})
end

-- 加载用户监控数据、配置
function D.LoadUserData()
	local data = X.LoadLUAData(GetUserDataPath())
	if X.IsTable(data) then
		for k, v in pairs(D.FILE) do
			D.FILE[k] = data.data[k] or {}
		end
		D.META = data.meta or {}
		D.CONFIG = data.config or {}
		FireUIEvent('MY_TEAM_MON_CREATE_CACHE')
		FireUIEvent('MY_TEAM_MON_DATA_RELOAD')
	else
		D.ImportDataFromFile(
			X.ENVIRONMENT.GAME_EDITION ..  '.jx3dat',
			MY_TEAM_MON_TYPE_LIST,
			'REPLACE',
			function()
				D.Log('load custom data finish!')
			end)
	end
end

-- 获取用户配置项
function D.GetUserConfig(szKey)
	return D.CONFIG[szKey]
end

-- 设置用户配置项
function D.SetUserConfig(szKey, oVal)
	D.CONFIG[szKey] = oVal
end

-- 从内存导入数据
function D.ImportData(data, aType, szMode, fnAction)
	if not data then
		X.SafeCall(fnAction, false, 'Can not read empty data.')
		return
	end
	if not aType then
		aType = X.Clone(MY_TEAM_MON_TYPE_LIST)
	end
	if szMode == 'REPLACE' then
		for _, k in ipairs(aType) do
			D.FILE[k] = data[k] or {}
		end
	elseif szMode == 'MERGE_OVERWRITE' or szMode == 'MERGE_SKIP' then
		local fnMergeData = function(tab_data)
			for _, szType in ipairs(aType) do
				if tab_data[szType] then
					for k, v in pairs(tab_data[szType]) do
						for kk, vv in ipairs(v) do
							if not D.CheckSameData(szType, k, vv.dwID or vv.szContent, vv.nLevel or vv.szTarget) then
								D.FILE[szType][k] = D.FILE[szType][k] or {}
								table.insert(D.FILE[szType][k], vv)
							end
						end
					end
				end
			end
		end
		if szMode == 'MERGE_SKIP' then -- 源文件优先
			fnMergeData(data)
		elseif szMode == 'MERGE_OVERWRITE' then -- 新文件优先
			-- 其实就是交换下顺序
			local tab_data = clone(D.FILE)
			for _, k in ipairs(aType) do
				D.FILE[k] = data[k] or {}
			end
			fnMergeData(tab_data)
		end
	end
	if X.IsTable(data.__meta) then
		if not (X.IsEmpty(data.__meta.szOfficialVoicePacketUUID) and X.IsEmpty(data.__meta.szCustomVoicePacketUUID))
		and O.bShowVoicePacketRecommendation then
			MY_TeamMon_VoiceAlarm.ShowVoiceRecommendation(data.__meta.szOfficialVoicePacketUUID, data.__meta.szCustomVoicePacketUUID)
		end
		D.META = data.__meta
	else
		D.META = {}
	end
	FireUIEvent('MY_TEAM_MON_CREATE_CACHE')
	FireUIEvent('MY_TEAM_MON_DATA_MODIFY')
	FireUIEvent('MY_TEAM_MON_DATA_RELOAD')
	FireUIEvent('MY_TEAM_MON__UI__DATA_RELOAD')
	-- bStatus, szFilePath, aType, szMode, tMeta
	X.SafeCall(fnAction, true, 'LUAData', aType, szMode, X.Clone(D.META))
end

-- 从文件导入数据
function D.ImportDataFromFile(szFileName, aType, szMode, fnAction)
	local szFullPath = szFileName:sub(2, 2) == ':'
		and szFileName
		or X.GetAbsolutePath(szFileName)
	local szFilePath = X.GetRelativePath(szFullPath, {'', X.PATH_TYPE.NORMAL}) or szFullPath
	if not IsFileExist(szFilePath) then
		X.SafeCall(fnAction, false, 'File does not exist.')
		return
	end
	local data = X.LoadLUAData(szFilePath, { passphrase = D.PW })
		or X.LoadLUAData(szFilePath, { passphrase = false })
	if not data then
		X.SafeCall(fnAction, false, 'Can not read data file.')
		return
	end
	D.ImportData(data, aType, szMode, function(bStatus, szFilePath, aType, szMode, tMeta) fnAction(bStatus, szFullPath:gsub('\\', '/'), aType, szMode, tMeta) end)
end

-- 导出数据到文件
function D.ExportDataToFile(szFileName, aType, szFormat, szAuthor, fnAction)
	local data = {}
	for _, k in ipairs(aType) do
		data[k] = D.FILE[k]
	end
	-- MY.20231110: add meta inherit
	data.__meta = X.Clone(D.META)
	-- HM.20170504: add meta data
	data.__meta.szEdition = X.ENVIRONMENT.GAME_EDITION
	data.__meta.szAuthor = not X.IsEmpty(szAuthor) and szAuthor or X.GetClientPlayerName()
	data.__meta.szServer = select(4, GetUserServer())
	data.__meta.nTimeStamp = GetCurrentTime()
	data.__meta.szOfficialVoicePacketUUID = MY_TeamMon_VoiceAlarm.GetCurrentPacketUUID('OFFICIAL')
	data.__meta.szCustomVoicePacketUUID = MY_TeamMon_VoiceAlarm.GetCurrentPacketUUID('CUSTOM')
	local szPath = MY_TEAM_MON_REMOTE_DATA_ROOT .. szFileName
	if szFormat == 'JSON' or szFormat == 'JSON_FORMATTED' then
		if szFormat ~= 'JSON' then
			szPath = szPath .. '.' .. szFormat:lower():sub(6)
		end
		szPath = szPath .. '.json'
		SaveDataToFile(X.EncodeJSON(data, szFormat == 'JSON_FORMATTED'), szPath)
	else
		if szFormat ~= 'LUA' then
			szPath = szPath .. '.' .. szFormat:lower():sub(5)
		end
		szPath = szPath .. '.jx3dat'
		local option = {
			passphrase = szFormat == 'LUA_ENCRYPTED'
				and D.PW
				or false,
			crc = szFormat == 'LUA_ENCRYPTED',
			compress = szFormat == 'LUA_ENCRYPTED',
			indent = szFormat == 'LUA_FORMATTED' and '\t' or nil,
			encoder = (szFormat == 'LUA' or szFormat == 'LUA_FORMATTED') and 'luatext' or nil,
		}
		X.SaveLUAData(szPath, data, option)
	end
	X.SafeCall(fnAction, X.GetAbsolutePath(szPath))
end

-- 获取整个表
function D.GetTable(szType, bTemp)
	if bTemp then
		return D.TEMP[szType]
	else
		return D.FILE[szType]
	end
end

-- 迭代数据表子序列
function D.IterTable(data, dwMapID, bIterItem, bReverse)
	local res = {}
	if data then
		if dwMapID == 0 then
			dwMapID = X.GetMapID(true)
		end
		if data[MY_TEAM_MON_SPECIAL_MAP.COMMON] then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.COMMON])
		end
		if X.IsCompetitionMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.COMPETITION])
		end
		if X.IsDungeonMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.DUNGEON])
		end
		if X.IsDungeonMap(dwMapID, true) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.RAID_DUNGEON])
		end
		if X.IsDungeonMap(dwMapID, false) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.TEAM_DUNGEON])
		end
		if X.IsCityMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.CITY])
		end
		if X.IsVillageMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.VILLAGE])
		end
		if X.IsCampMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.CAMP])
		end
		if X.IsStrongholdMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.STRONGHOLD])
		end
		if X.IsStarveMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.STARVE])
		end
		if X.IsArenaMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.ARENA])
		end
		if X.IsBattlefieldMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.BATTLEFIELD])
		end
		if X.IsPubgMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.PUBG])
		end
		if X.IsZombieMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.ZOMBIE])
		end
		if X.IsMonsterMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.MONSTER])
		end
		if X.IsMobaMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.MOBA])
		end
		if X.IsSchoolMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.SCHOOL])
		end
		if X.IsHomelandMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.HOMELAND])
		end
		if X.IsGuildTerritoryMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.GUILD_TERRITORY])
		end
		if X.IsRoguelikeMap(dwMapID) then
			table.insert(res, data[MY_TEAM_MON_SPECIAL_MAP.ROGUELIKE])
		end
		if data[dwMapID] then
			table.insert(res, data[dwMapID])
		end
	end
	if bReverse then
		if bIterItem then
			return X.sipairs(unpack(res))
		end
		return X.ipairs(res)
	end
	if bIterItem then
		return X.sipairs_r(unpack(res))
	end
	return X.ipairs_r(res)
end

function D.GetMapName(dwMapID)
	if dwMapID == _L['All data'] then
		return dwMapID
	end
	local map = D.GetMapInfo(dwMapID)
	if map then
		return map.szName
	end
	return '#' .. dwMapID
end

function D.GetMapInfo(id)
	return MY_TEAM_MON_SPECIAL_MAP_INFO[id] or X.GetMapInfo(id)
end

local function GetData(tab, szType, dwID, nLevel)
	-- D.Log('LOOKUP TYPE:' .. szType .. ' ID:' .. dwID .. ' LEVEL:' .. nLevel)
	if nLevel then
		for k, v in ipairs(tab) do
			if v.dwID == dwID and (not v.bCheckLevel or v.nLevel == nLevel) then
				CACHE.MAP[szType][dwID][nLevel] = k
				return v
			end
		end
	else
		for k, v in ipairs(tab) do
			if v.dwID == dwID then
				CACHE.MAP[szType][dwID] = k
				return v
			end
		end
	end
end

-- 获取监控数据 注意 不是获取文件内的 如果想找文件内的 请使用 GetTable
function D.GetData(szType, dwID, nLevel)
	local cache = CACHE.MAP[szType][dwID]
	if cache then
		local tab = D.DATA[szType]
		if nLevel then
			if cache[nLevel] then
				local data = tab[cache[nLevel]]
				if data and data.dwID == dwID and (not data.bCheckLevel or data.nLevel == nLevel) then
					-- D.Log('HIT TYPE:' .. szType .. ' ID:' .. dwID .. ' LEVEL:' .. nLevel)
					return data
				else
					-- D.Log('RELOOKUP TYPE:' .. szType .. ' ID:' .. dwID .. ' LEVEL:' .. nLevel)
					return GetData(tab, szType, dwID, nLevel)
				end
			else
				for k, v in pairs(cache) do
					local data = tab[cache[k]]
					if data and data.dwID == dwID and (not data.bCheckLevel or data.nLevel == nLevel) then
						return data
					end
				end
				return GetData(tab, szType, dwID, nLevel)
			end
		else
			local data = tab[cache]
			if data and data.dwID == dwID then
				-- D.Log('HIT TYPE:' .. szType .. ' ID:' .. dwID .. ' LEVEL:0')
				return data
			else
				-- D.Log('RELOOKUP TYPE:' .. szType .. ' ID:' .. dwID .. ' LEVEL:0')
				return GetData(tab, szType, dwID)
			end
		end
	-- else
		-- D.Log('IGNORE TYPE:' .. szType .. ' ID:' .. dwID .. ' LEVEL:' .. (nLevel or 0))
	end
end

-- 删除 移动 添加 清空
function D.RemoveData(szType, dwMapID, nIndex)
	if nIndex then
		if not D.FILE[szType][dwMapID] or not D.FILE[szType][dwMapID][nIndex] then
			return
		end
		if dwMapID == MY_TEAM_MON_SPECIAL_MAP.RECYCLE_BIN then
			table.remove(D.FILE[szType][dwMapID], nIndex)
			if #D.FILE[szType][dwMapID] == 0 then
				D.FILE[szType][dwMapID] = nil
			end
			return
		end
		D.MoveData(szType, dwMapID, nIndex, MY_TEAM_MON_SPECIAL_MAP.RECYCLE_BIN)
	elseif dwMapID then
		if not D.FILE[szType][dwMapID] then
			return
		end
		D.FILE[szType][dwMapID] = nil
	else
		if not D.FILE[szType] then
			return
		end
		D.FILE[szType] = {}
	end
	FireUIEvent('MY_TEAM_MON_CREATE_CACHE')
	FireUIEvent('MY_TEAM_MON_DATA_MODIFY')
	FireUIEvent('MY_TEAM_MON_DATA_RELOAD', { [szType] = true })
	FireUIEvent('MY_TEAM_MON__UI__DATA_RELOAD')
end

function D.RemoveMeta()
	D.META = {}
end

function D.CheckSameData(szType, dwMapID, dwID, nLevel)
	if D.FILE[szType][dwMapID] then
		if dwMapID ~= MY_TEAM_MON_SPECIAL_MAP.RECYCLE_BIN then
			for k, v in ipairs(D.FILE[szType][dwMapID]) do
				if type(dwID) == 'string' then
					if dwID == v.szContent and nLevel == v.szTarget then
						return k, v
					end
				else
					if dwID == v.dwID and (not v.bCheckLevel or nLevel == v.nLevel) then
						return k, v
					end
				end
			end
		end
	end
end

function D.MoveData(szType, dwMapID, nIndex, dwTargetMapID, bCopy)
	if dwMapID == dwTargetMapID then
		return
	end
	if not D.FILE[szType][dwMapID] or not D.FILE[szType][dwMapID][nIndex] then
		return
	end
	local data = D.FILE[szType][dwMapID][nIndex]
	if D.CheckSameData(szType, dwTargetMapID, data.dwID or data.szContent, data.nLevel or data.szTarget) then
		return X.Alert(_L['Same data exist'])
	end
	D.FILE[szType][dwTargetMapID] = D.FILE[szType][dwTargetMapID] or {}
	table.insert(D.FILE[szType][dwTargetMapID], clone(D.FILE[szType][dwMapID][nIndex]))
	if not bCopy then
		table.remove(D.FILE[szType][dwMapID], nIndex)
		if #D.FILE[szType][dwMapID] == 0 then
			D.FILE[szType][dwMapID] = nil
		end
	end
	FireUIEvent('MY_TEAM_MON_CREATE_CACHE')
	FireUIEvent('MY_TEAM_MON_DATA_MODIFY')
	FireUIEvent('MY_TEAM_MON_DATA_RELOAD', { [szType] = true })
	FireUIEvent('MY_TEAM_MON__UI__DATA_RELOAD')
end

-- 交换 其实没用 满足强迫症
function D.Exchange(szType, dwMapID, nIndex1, nIndex2)
	if nIndex1 == nIndex2 then
		return
	end
	if not D.FILE[szType][dwMapID] then
		return
	end
	local data1 = D.FILE[szType][dwMapID][nIndex1]
	local data2 = D.FILE[szType][dwMapID][nIndex2]
	if not data1 or not data2 then
		return
	end
	-- local data = table.remove(D.FILE[szType][dwMapID], nIndex1)
	-- table.insert(D.FILE[szType][dwMapID], nIndex2 + 1, data)
	D.FILE[szType][dwMapID][nIndex1] = data2
	D.FILE[szType][dwMapID][nIndex2] = data1
	FireUIEvent('MY_TEAM_MON_CREATE_CACHE')
	FireUIEvent('MY_TEAM_MON_DATA_MODIFY')
	FireUIEvent('MY_TEAM_MON_DATA_RELOAD', { [szType] = true })
	FireUIEvent('MY_TEAM_MON__UI__DATA_RELOAD')
end

function D.AddData(szType, dwMapID, data)
	D.FILE[szType][dwMapID] = D.FILE[szType][dwMapID] or {}
	table.insert(D.FILE[szType][dwMapID], data)
	FireUIEvent('MY_TEAM_MON_CREATE_CACHE')
	FireUIEvent('MY_TEAM_MON_DATA_MODIFY')
	FireUIEvent('MY_TEAM_MON_DATA_RELOAD', { [szType] = true })
	FireUIEvent('MY_TEAM_MON__UI__DATA_RELOAD')
	return D.FILE[szType][dwMapID][#D.FILE[szType][dwMapID]]
end

function D.ClearTemp(szType)
	CACHE.INTERVAL[szType] = {}
	D.TEMP[szType] = {}
	FireUIEvent('MY_TEAM_MON__UI__TEMP_RELOAD')
	collectgarbage('collect')
	D.Log('clear ' .. szType .. ' cache success!')
end

function D.GetIntervalData(szType, key)
	if CACHE.INTERVAL[szType] then
		return CACHE.INTERVAL[szType][key]
	end
end

function D.ConfirmShare()
	if #MY_TEAM_MON_SHARE_QUEUE > 0 then
		local t = MY_TEAM_MON_SHARE_QUEUE[1]
		X.Confirm(_L('%s share a %s data to you, accept?', t.szName, _L[t.szType]), function()
			local data = t.tData
			local nIndex = D.CheckSameData(t.szType, t.dwMapID, data.dwID or data.szContent, data.nLevel or data.szTarget)
			if nIndex then
				D.RemoveData(t.szType, t.dwMapID, nIndex)
			end
			D.AddData(t.szType, t.dwMapID, data)
			table.remove(MY_TEAM_MON_SHARE_QUEUE, 1)
			X.DelayCall(100, D.ConfirmShare)
		end, function()
			table.remove(MY_TEAM_MON_SHARE_QUEUE, 1)
			X.DelayCall(100, D.ConfirmShare)
		end)
	end
end

function D.OnShare(_, data, nChannel, dwID, szName, bIsSelf)
	if not bIsSelf then
		table.insert(MY_TEAM_MON_SHARE_QUEUE, {
			szType  = data[1],
			tData   = data[3],
			szName  = szName,
			dwMapID = data[2]
		})
		D.ConfirmShare()
	end
end

X.RegisterEvent('MY_RESTRICTION', 'MY_TeamMon', function()
	if arg0 and arg0 ~= 'MY_TeamMon' then
		return
	end
	FireUIEvent('MY_TEAM_MON_DATA_RELOAD')
end)
X.RegisterEvent('MY_RESTRICTION', 'MY_TeamMon.MapRestriction', function()
	if arg0 and arg0 ~= 'MY_TeamMon.MapRestriction' then
		return
	end
	D.UpdateShieldStatus()
end)
X.RegisterKungfuMount('MY_TeamMon', D.UpdateShieldStatus)

X.RegisterInit('MY_TeamMon', function()
	X.RegisterEvent('LOADING_ENDING', 'MY_TeamMon', function()
		FireUIEvent('MY_TEAM_MON_DATA_RELOAD')
	end)
	D.bReady = true
	D.Init()
end)
X.RegisterFlush('MY_TeamMon', D.SaveUserData)
X.RegisterBgMsg('MY_TEAM_MON_SHARE', D.OnShare)

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_TeamMon',
	exports = {
		{
			preset = 'UIEvent',
			fields = {
				MY_TEAM_MON_REMOTE_DATA_ROOT = MY_TEAM_MON_REMOTE_DATA_ROOT,
				MY_TEAM_MON_SPECIAL_MAP      = MY_TEAM_MON_SPECIAL_MAP     ,
				MY_TEAM_MON_TYPE             = MY_TEAM_MON_TYPE            ,
				MY_TEAM_MON_TYPE_LIST        = MY_TEAM_MON_TYPE_LIST       ,
				MY_TEAM_MON_SCRUTINY_TYPE    = MY_TEAM_MON_SCRUTINY_TYPE   ,
				FilterCustomText             = FilterCustomText            ,
				ParseCustomText              = ParseCustomText             ,
				ParseCountdown               = ParseCountdown              ,
				ParseHPCountdown             = ParseHPCountdown            ,
				'Enable',
				'GetTable',
				IterTable = function(...)
					if X.IsRestricted('MY_TeamMon') then
						return X.ipairs_r({})
					end
					return D.IterTable(...)
				end,
				'GetMapName',
				'GetMapInfo',
				'GetData',
				'GetIntervalData',
				'RemoveData',
				'RemoveMeta',
				'MoveData',
				'CheckSameData',
				'ClearTemp',
				'AddData',
				'GetUserConfig',
				'SetUserConfig',
				'ImportData',
				'ImportDataFromFile',
				'ExportDataToFile',
				'Exchange',
				'SendChat',
				'SendBgMsg',
			},
			root = D,
		},
		{
			fields = {
				'bEnable',
				'bCommon',
				'bPushScreenHead',
				'bPushCenterAlarm',
				'bPushVoiceAlarm',
				'bPushBigFontAlarm',
				'bPushTeamPanel',
				'bPushFullScreen',
				'bPushTeamChannel',
				'bPushWhisperChannel',
				'bPushBuffList',
				'bPushPartyBuffList',
				'bShowVoicePacketRecommendation',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bEnable',
				'bCommon',
				'bPushScreenHead',
				'bPushCenterAlarm',
				'bPushVoiceAlarm',
				'bPushBigFontAlarm',
				'bPushTeamPanel',
				'bPushFullScreen',
				'bPushTeamChannel',
				'bPushWhisperChannel',
				'bPushBuffList',
				'bPushPartyBuffList',
				'bShowVoicePacketRecommendation',
			},
			triggers = {
				bEnable = function(k, v)
					D.Enable(v, true)
				end,
			},
			root = O,
		},
	},
}
MY_TeamMon = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
