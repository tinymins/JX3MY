--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 游戏常量枚举
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) MY
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/lib/Constant')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. 'lang/lib/')
--------------------------------------------------------------------------------

local KvpToObject = X.KvpToObject

local function PickBranch(tData)
	return tData[X.ENVIRONMENT.GAME_BRANCH] or tData['remake']
end

local FORCE_TYPE = (function()
	local FORCE_TYPE = _G.FORCE_TYPE or X.FreezeTable({
		JIANG_HU  = 0 , -- 江湖
		SHAO_LIN  = 1 , -- 少林
		WAN_HUA   = 2 , -- 万花
		TIAN_CE   = 3 , -- 天策
		CHUN_YANG = 4 , -- 纯阳
		QI_XIU    = 5 , -- 七秀
		WU_DU     = 6 , -- 五毒
		TANG_MEN  = 7 , -- 唐门
		CANG_JIAN = 8 , -- 藏剑
		GAI_BANG  = 9 , -- 丐帮
		MING_JIAO = 10, -- 明教
		CANG_YUN  = 21, -- 苍云
		CHANG_GE  = 22, -- 长歌
		BA_DAO    = 23, -- 霸刀
		PENG_LAI  = 24, -- 蓬莱
		LING_XUE  = 25, -- 凌雪
		YAN_TIAN  = 211, -- 衍天
		YAO_ZONG  = 212, -- 药宗
		DAO_ZONG  = 213, -- 刀宗
		WAN_LING  = 214, -- 万灵
		DUAN_SHI  = 215, -- 段氏
		WU_XIANG  = 221, -- 无相
	})
	local res = {}
	for k, v in X.pairs_c(FORCE_TYPE) do
		if g_tStrings.tForceTitle[v] then
			res[k] = v
		end
	end
	return X.FreezeTable(res)
end)()

local FORCE_LIST = {
	{ dwID = FORCE_TYPE.JIANG_HU , szUITex = 'ui\\Image\\PlayerAvatar\\jianghu.tga'       , nFrame = -2, bAnimate = false }, -- 江湖
	{ dwID = FORCE_TYPE.SHAO_LIN , szUITex = 'ui\\Image\\PlayerAvatar\\shaolin.tga'       , nFrame = -2, bAnimate = false }, -- 少林
	{ dwID = FORCE_TYPE.WAN_HUA  , szUITex = 'ui\\Image\\PlayerAvatar\\wanhua.tga'        , nFrame = -2, bAnimate = false }, -- 万花
	{ dwID = FORCE_TYPE.TIAN_CE  , szUITex = 'ui\\Image\\PlayerAvatar\\tiance.tga'        , nFrame = -2, bAnimate = false }, -- 天策
	{ dwID = FORCE_TYPE.CHUN_YANG, szUITex = 'ui\\Image\\PlayerAvatar\\chunyang.tga'      , nFrame = -2, bAnimate = false }, -- 纯阳
	{ dwID = FORCE_TYPE.QI_XIU   , szUITex = 'ui\\Image\\PlayerAvatar\\qixiu.tga'         , nFrame = -2, bAnimate = false }, -- 七秀
	{ dwID = FORCE_TYPE.WU_DU    , szUITex = 'ui\\Image\\PlayerAvatar\\wudu.tga'          , nFrame = -2, bAnimate = false }, -- 五毒
	{ dwID = FORCE_TYPE.TANG_MEN , szUITex = 'ui\\Image\\PlayerAvatar\\tangmen.tga'       , nFrame = -2, bAnimate = false }, -- 唐门
	{ dwID = FORCE_TYPE.CANG_JIAN, szUITex = 'ui\\Image\\PlayerAvatar\\cangjian.tga'      , nFrame = -2, bAnimate = false }, -- 藏剑
	{ dwID = FORCE_TYPE.GAI_BANG , szUITex = 'ui\\Image\\PlayerAvatar\\gaibang.tga'       , nFrame = -2, bAnimate = false }, -- 丐帮
	{ dwID = FORCE_TYPE.MING_JIAO, szUITex = 'ui\\Image\\PlayerAvatar\\mingjiao.tga'      , nFrame = -2, bAnimate = false }, -- 明教
	{ dwID = FORCE_TYPE.CANG_YUN , szUITex = 'ui\\Image\\PlayerAvatar\\cangyun.tga'       , nFrame = -2, bAnimate = false }, -- 苍云
	{ dwID = FORCE_TYPE.CHANG_GE , szUITex = 'ui\\Image\\PlayerAvatar\\changge.tga'       , nFrame = -2, bAnimate = false }, -- 长歌
	{ dwID = FORCE_TYPE.BA_DAO   , szUITex = 'ui\\Image\\PlayerAvatar\\badao.tga'         , nFrame = -2, bAnimate = false }, -- 霸刀
	{ dwID = FORCE_TYPE.PENG_LAI , szUITex = 'ui\\Image\\PlayerAvatar\\penglai.tga'       , nFrame = -2, bAnimate = false }, -- 蓬莱
	{ dwID = FORCE_TYPE.LING_XUE , szUITex = 'ui\\Image\\PlayerAvatar\\lingxuege.tga'     , nFrame = -2, bAnimate = false }, -- 凌雪
	{ dwID = FORCE_TYPE.YAN_TIAN , szUITex = 'ui\\Image\\PlayerAvatar\\yantianzong.dds'   , nFrame = -2, bAnimate = false }, -- 衍天
	{ dwID = FORCE_TYPE.YAO_ZONG , szUITex = 'ui\\Image\\PlayerAvatar\\beitianyaozong.dds', nFrame = -2, bAnimate = false }, -- 药宗
	{ dwID = FORCE_TYPE.DAO_ZONG , szUITex = 'ui\\Image\\PlayerAvatar\\daozong.dds'       , nFrame = -2, bAnimate = false }, -- 刀宗
	{ dwID = FORCE_TYPE.WAN_LING , szUITex = 'ui\\Image\\PlayerAvatar\\wanling.tga'       , nFrame = -2, bAnimate = false }, -- 万灵
	{ dwID = FORCE_TYPE.DUAN_SHI , szUITex = 'ui\\Image\\PlayerAvatar\\DuanShi.tga'       , nFrame = -2, bAnimate = false }, -- 段氏
	{ dwID = FORCE_TYPE.WU_XIANG , szUITex = 'ui\\Image\\PlayerAvatar\\wuxiang.tga'       , nFrame = -2, bAnimate = false }, -- 无相
}
for i, v in X.ipairs_r(FORCE_LIST) do
	if not v.dwID or not g_tStrings.tForceTitle[v.dwID] then
		table.remove(FORCE_LIST, i)
	end
end

local KUNGFU_TYPE = (function()
	local KUNGFU_TYPE = {
		XI_SUI    = 10002, -- 少林 洗髓经
		YI_JIN    = 10003, -- 少林 易筋经
		ZI_XIA    = 10014, -- 纯阳 紫霞功
		TAI_XU    = 10015, -- 纯阳 太虚剑意
		HUA_JIAN  = 10021, -- 万花 花间游
		LI_JING   = 10028, -- 万花 离经易道
		AO_XUE    = 10026, -- 天策 傲血战意
		TIE_LAO   = 10062, -- 天策 铁牢律
		YUN_CHANG = 10080, -- 七秀 云裳心经
		BING_XIN  = 10081, -- 七秀 冰心诀
		WEN_SHUI  = 10144, -- 藏剑 问水诀
		SHAN_JU   = 10145, -- 藏剑 山居剑意
		DU_JING   = 10175, -- 五毒 毒经
		BU_TIAN   = 10176, -- 五毒 补天诀
		JING_YU   = 10224, -- 唐门 惊羽诀
		TIAN_LUO  = 10225, -- 唐门 天罗诡道
		FEN_YING  = 10242, -- 明教 焚影圣诀
		MING_ZUN  = 10243, -- 明教 明尊琉璃体
		XIAO_CHEN = 10268, -- 丐帮 笑尘诀
		TIE_GU    = 10389, -- 苍云 铁骨衣
		FEN_SHAN  = 10390, -- 苍云 分山劲
		MO_WEN    = 10447, -- 长歌 莫问
		XIANG_ZHI = 10448, -- 长歌 相知
		BEI_AO    = 10464, -- 霸刀 北傲诀
		LING_HAI  = 10533, -- 蓬莱 凌海诀
		YIN_LONG  = 10585, -- 凌雪 隐龙诀
		TAI_XUAN  = 10615, -- 衍天 太玄经
		LING_SU   = 10626, -- 药宗 灵素
		WU_FANG   = 10627, -- 药宗 无方
		GU_FENG   = 10698, -- 刀宗 孤峰诀
		SHAN_HAI  = 10756, -- 万灵 山海心诀
		ZHOU_TIAN = 10786, -- 段氏 周天功
	}
	local res = {}
	for k, v in pairs(KUNGFU_TYPE) do
		if Table_GetSkill(v) then
			res[k] = v
		end
	end
	return X.FreezeTable(res)
end)()

-- skillid, uitex, frame
local KUNGFU_LIST = {
	-- MT
	{ dwID = KUNGFU_TYPE.TIE_LAO  , dwForceID = FORCE_TYPE.TIAN_CE  , nIcon = 632  , szUITex = 'ui/Image/icon/skill_tiance01.UITex'    , nFrame = 0  }, -- 天策 铁牢律
	{ dwID = KUNGFU_TYPE.MING_ZUN , dwForceID = FORCE_TYPE.MING_JIAO, nIcon = 3864 , szUITex = 'ui/Image/icon/mingjiao_taolu_7.UITex'  , nFrame = 0  }, -- 明教 明尊琉璃体
	{ dwID = KUNGFU_TYPE.TIE_GU   , dwForceID = FORCE_TYPE.CANG_YUN , nIcon = 6315 , szUITex = 'ui/Image/icon/Skill_CangY_33.UITex'    , nFrame = 0  }, -- 苍云 铁骨衣
	{ dwID = KUNGFU_TYPE.XI_SUI   , dwForceID = FORCE_TYPE.SHAO_LIN , nIcon = 429  , szUITex = 'ui/Image/icon/skill_shaolin14.UITex'   , nFrame = 0  }, -- 少林 洗髓经
	-- 治疗
	{ dwID = KUNGFU_TYPE.YUN_CHANG, dwForceID = FORCE_TYPE.QI_XIU   , nIcon = 887  , szUITex = 'ui/Image/icon/skill_qixiu02.UITex'     , nFrame = 0  }, -- 七秀 云裳心经
	{ dwID = KUNGFU_TYPE.BU_TIAN  , dwForceID = FORCE_TYPE.WU_DU    , nIcon = 2767 , szUITex = 'ui/Image/icon/wudu_neigong_2.UITex'    , nFrame = 0  }, -- 五毒 补天诀
	{ dwID = KUNGFU_TYPE.LI_JING  , dwForceID = FORCE_TYPE.WAN_HUA  , nIcon = 412  , szUITex = 'ui/Image/icon/skill_wanhua23.UITex'    , nFrame = 0  }, -- 万花 离经易道
	{ dwID = KUNGFU_TYPE.XIANG_ZHI, dwForceID = FORCE_TYPE.CHANG_GE , nIcon = 7067 , szUITex = 'ui/Image/icon/skill_0514_23.UITex'     , nFrame = 0  }, -- 长歌 相知
	{ dwID = KUNGFU_TYPE.LING_SU  , dwForceID = FORCE_TYPE.YAO_ZONG , nIcon = 15593, szUITex = 'ui/image/icon/skill_21_9_10_1.UITex '  , nFrame = 0  }, -- 药宗 灵素
	-- 内功
	{ dwID = KUNGFU_TYPE.TIAN_LUO , dwForceID = FORCE_TYPE.TANG_MEN , nIcon = 3184 , szUITex = 'ui/Image/icon/skill_tangm_20.UITex'    , nFrame = 0  }, -- 唐门 天罗诡道
	{ dwID = KUNGFU_TYPE.BING_XIN , dwForceID = FORCE_TYPE.QI_XIU   , nIcon = 888  , szUITex = 'ui/Image/icon/skill_qixiu03.UITex'     , nFrame = 0  }, -- 七秀 冰心诀
	{ dwID = KUNGFU_TYPE.DU_JING  , dwForceID = FORCE_TYPE.WU_DU    , nIcon = 2766 , szUITex = 'ui/Image/icon/wudu_neigong_1.UITex'    , nFrame = 0  }, -- 五毒 毒经
	{ dwID = KUNGFU_TYPE.FEN_YING , dwForceID = FORCE_TYPE.MING_JIAO, nIcon = 3865 , szUITex = 'ui/Image/icon/mingjiao_taolu_8.UITex'  , nFrame = 0  }, -- 明教 焚影圣诀
	{ dwID = KUNGFU_TYPE.ZI_XIA   , dwForceID = FORCE_TYPE.CHUN_YANG, nIcon = 627  , szUITex = 'ui/Image/icon/skill_chunyang21.UITex'  , nFrame = 0  }, -- 纯阳 紫霞功
	{ dwID = KUNGFU_TYPE.HUA_JIAN , dwForceID = FORCE_TYPE.WAN_HUA  , nIcon = 406  , szUITex = 'ui/Image/icon/skill_wanhua17.UITex'    , nFrame = 0  }, -- 万花 花间游
	{ dwID = KUNGFU_TYPE.YI_JIN   , dwForceID = FORCE_TYPE.SHAO_LIN , nIcon = 425  , szUITex = 'ui/Image/icon/skill_shaolin10.UITex'   , nFrame = 0  }, -- 少林 易经经
	{ dwID = KUNGFU_TYPE.MO_WEN   , dwForceID = FORCE_TYPE.CHANG_GE , nIcon = 7071 , szUITex = 'ui/Image/icon/skill_0514_27.UITex'     , nFrame = 0  }, -- 长歌 莫问
	{ dwID = KUNGFU_TYPE.TAI_XUAN , dwForceID = FORCE_TYPE.YAN_TIAN , nIcon = 13894, szUITex = 'ui/image/icon/skill_20_9_14_1.uitex'   , nFrame = 0  }, -- 衍天 太玄经
	{ dwID = KUNGFU_TYPE.WU_FANG  , dwForceID = FORCE_TYPE.YAO_ZONG , nIcon = 15594, szUITex = 'ui/image/icon/skill_21_9_10_2.UITex '  , nFrame = 0  }, -- 药宗 无方
	{ dwID = KUNGFU_TYPE.DUAN_SHI , dwForceID = FORCE_TYPE.DUAN_SHI , nIcon = 22823, szUITex = 'ui/Image/icon/skill/Duanshi/skill_ds_8_28_1.UITex', nFrame = 0 }, -- 段氏 周天功
	-- 外功
	{ dwID = KUNGFU_TYPE.FEN_SHAN , dwForceID = FORCE_TYPE.CANG_YUN , nIcon = 6314 , szUITex = 'ui/Image/icon/Skill_CangY_32.UITex'    , nFrame = 0  }, -- 苍云 分山劲
	{ dwID = KUNGFU_TYPE.JING_YU  , dwForceID = FORCE_TYPE.TANG_MEN , nIcon = 3165 , szUITex = 'ui/Image/icon/skill_tangm_01.UITex'    , nFrame = 0  }, -- 唐门 惊羽诀
	{ dwID = KUNGFU_TYPE.WEN_SHUI , dwForceID = FORCE_TYPE.CANG_JIAN, nIcon = 2376 , szUITex = 'ui/Image/icon/cangjian_neigong_1.UITex', nFrame = 0  }, -- 藏剑 问水诀
	{ dwID = KUNGFU_TYPE.SHAN_JU  , dwForceID = FORCE_TYPE.CANG_JIAN, nIcon = 2377 , szUITex = 'ui/Image/icon/cangjian_neigong_2.UITex', nFrame = 0  }, -- 藏剑 山居剑意
	{ dwID = KUNGFU_TYPE.TAI_XU   , dwForceID = FORCE_TYPE.CHUN_YANG, nIcon = 619  , szUITex = 'ui/Image/icon/skill_chunyang13.UITex'  , nFrame = 0  }, -- 纯阳 太虚剑意
	{ dwID = KUNGFU_TYPE.AO_XUE   , dwForceID = FORCE_TYPE.TIAN_CE  , nIcon = 633  , szUITex = 'ui/Image/icon/skill_tiance02.UITex'    , nFrame = 0  }, -- 天策 傲血战意
	{ dwID = KUNGFU_TYPE.XIAO_CHEN, dwForceID = FORCE_TYPE.GAI_BANG , nIcon = 4610 , szUITex = 'ui/Image/icon/skill_GB_30.UITex'       , nFrame = 0  }, -- 丐帮 笑尘诀
	{ dwID = KUNGFU_TYPE.BEI_AO   , dwForceID = FORCE_TYPE.BA_DAO   , nIcon = 8424 , szUITex = 'ui/Image/icon/daoj_16_8_25_16.UITex'   , nFrame = 0  }, -- 霸刀 北傲诀
	{ dwID = KUNGFU_TYPE.LING_HAI , dwForceID = FORCE_TYPE.PENG_LAI , nIcon = 10709, szUITex = 'ui/image/icon/JNPL_18_10_30_27.uitex'  , nFrame = 0  }, -- 蓬莱 凌海诀
	{ dwID = KUNGFU_TYPE.YIN_LONG , dwForceID = FORCE_TYPE.LING_XUE , nIcon = 12128, szUITex = 'ui/image/icon/JNLXG_19_10_21_9.uitex'  , nFrame = 0  }, -- 凌雪 隐龙诀
	{ dwID = KUNGFU_TYPE.GU_FENG  , dwForceID = FORCE_TYPE.DAO_ZONG , nIcon = 17633, szUITex = 'ui/image/icon/skill_22_9_7_2.uitex'    , nFrame = 51 }, -- 刀宗 孤峰诀
	{ dwID = KUNGFU_TYPE.SHAN_HAI , dwForceID = FORCE_TYPE.WAN_LING , nIcon = 19664, szUITex = 'ui/image/icon/skill_23_8_22_1.uitex'   , nFrame = 9  }, -- 万灵 山海心诀
}
for i, v in X.ipairs_r(KUNGFU_LIST) do
	if not v.dwForceID or not Table_GetSkill(v.dwID) then
		table.remove(KUNGFU_LIST, i)
	end
end

local TEAM_MARK = {
	CLOUD = 1,
	SWORD = 2,
	AX    = 3,
	HOOK  = 4,
	DRUM  = 5,
	SHEAR = 6,
	STICK = 7,
	JADE  = 8,
	DART  = 9,
	FAN   = 10,
}

local MSG_TYPE_MENU = X.Clone(_G.UI_CHANNEL_POPUP_SETTING_TABLE) or {
	{
		szOption = g_tStrings.CHANNEL,
		'MSG_NORMAL', 'MSG_PARTY', 'MSG_MAP', 'MSG_BATTLE_FILED', 'MSG_GUILD',
		'MSG_GUILD_ALLIANCE', 'MSG_SCHOOL', 'MSG_WORLD', 'MSG_TEAM', 'MSG_ROOM', 'MSG_CAMP',
		'MSG_SEEK_MENTOR', 'MSG_FRIEND', 'MSG_GROUP', 'MSG_WHISPER', 'MSG_IDENTITY', 'MSG_JJC_BULLET_SCREEN', 'MSG_BATTLE_FIELD_SIDE', 'MSG_STORY_NPC', 'MSG_STORY_PLAYER', 'MSG_SSG_WHISPER',
	},
	{
		szOption = g_tStrings.EARN,
		'MSG_MONEY', 'MSG_EXP', 'MSG_ITEM', 'MSG_REPUTATION', 'MSG_CONTRIBUTE', 'MSG_ATTRACTION', 'MSG_PRESTIGE',
		'MSG_TRAIN', 'MSG_DESGNATION', 'MSG_ACHIEVEMENT', 'MSG_MENTOR_VALUE',
		'MSG_TONG_FUND', 'MSG_THEW_STAMINA',  'MSG_ARCHITECTURE',
	},
	{
		szOption = g_tStrings.FIGHT_MSG,
		{
			szOption = g_tStrings.STR_NAME_OWN,
			'MSG_SKILL_SELF_SKILL', 'MSG_SKILL_SELF_BENEFICIAL_SKILL', 'MSG_SKILL_SELF_HARMFUL_SKILL',
			'MSG_SKILL_SELF_BE_BENEFICIAL_SKILL', 'MSG_SKILL_SELF_BE_HARMFUL_SKILL',
			'MSG_SKILL_SELF_BUFF', 'MSG_SKILL_SELF_DEBUFF',
			'MSG_SKILL_SELF_MISS', 'MSG_SKILL_SELF_FAILED',
			'MSG_SELF_KILL', 'MSG_SELF_DEATH',
		},
		{
			szOption = g_tStrings.TEAMMATE,
			'MSG_SKILL_PARTY_SKILL', 'MSG_SKILL_PARTY_BENEFICIAL_SKILL', 'MSG_SKILL_PARTY_HARMFUL_SKILL',
			'MSG_SKILL_PARTY_BE_BENEFICIAL_SKILL', 'MSG_SKILL_PARTY_BE_HARMFUL_SKILL',
			'MSG_SKILL_PARTY_BUFF', 'MSG_SKILL_PARTY_DEBUFF', 'MSG_SKILL_PARTY_MISS', 'MSG_PARTY_KILL', 'MSG_PARTY_DEATH',
		},
		{
			szOption = g_tStrings.ENEMY,
			'MSG_SKILL_ENEMY_SKILL', 'MSG_SKILL_ENEMY_HARMFUL_SKILL', 'MSG_SKILL_ENEMY_BENEFICAL_SKILL',
			'MSG_SKILL_ENEMY_MISS', 'MSG_ENEMY_KILL', 'MSG_ENEMY_DEATH',
		},
		{
			szOption = g_tStrings.OTHER_PLAYER,
			'MSG_SKILL_OTHERS_SKILL', 'MSG_SKILL_OTHERS_BENEFICIAL_SKILL', 'MSG_SKILL_OTHERS_HARMFUL_SKILL',
			'MSG_SKILL_OTHERS_MISS', 'MSG_OTHERS_KILL', 'MSG_OTHERS_DEATH',
		},
		{
			szOption = 'NPC',
			'MSG_SKILL_NPC_SKILL', 'MSG_SKILL_NPC_BENEFICIAL_SKILL', 'MSG_SKILL_NPC_HARMFUL_SKILL', 'MSG_SKILL_NPC_MISS',
			'MSG_NPC_KILL', 'MSG_NPC_DEATH',
		},
		{
			szOption = g_tStrings.OTHER,
			'MSG_OTHER_ENCHANT', 'MSG_OTHER_SCENE',
		},
	},
	{
		szOption = g_tStrings.ENVIROMENT,
		'MSG_NPC_NEARBY', 'MSG_NPC_YELL', 'MSG_NPC_PARTY', 'MSG_NPC_WHISPER', 'MSG_NPC_FACE',
	},
}
table.insert(MSG_TYPE_MENU[1], 1, 'MSG_SYS')

local INVENTORY_INDEX_INDEX = setmetatable(
	{
		-- 帮会仓库界面虚拟背包位置
		GUILD_BANK = 10000,
		GUILD_BANK_PACKAGE1 = 10001,
		GUILD_BANK_PACKAGE2 = 10002,
		GUILD_BANK_PACKAGE3 = 10003,
		GUILD_BANK_PACKAGE4 = 10004,
		GUILD_BANK_PACKAGE5 = 10005,
		GUILD_BANK_PACKAGE6 = 10006,
		GUILD_BANK_PACKAGE7 = 10007,
		GUILD_BANK_PACKAGE8 = 10008,
	},
	{ __index = _G.INVENTORY_INDEX }
)
local INVENTORY_INDEX = setmetatable({}, { __index = INVENTORY_INDEX_INDEX, __newindex = function() end })

local CONSTANT = {
	MENU_DIVIDER = X.FreezeTable({ bDevide = true }),
	EMPTY_TABLE = X.FreezeTable({}),
	XML_LINE_BREAKER = GetFormatText('\n'),
	MAX_PLAYER_LEVEL = 50,
	UI_OBJECT = UI_OBJECT or X.FreezeTable({
		NONE             = -1, -- 空Box
		ITEM             = 0 , -- 身上有的物品。nUiId, dwBox, dwX, nItemVersion, nTabType, nIndex
		SHOP_ITEM        = 1 , -- 商店里面出售的物品 nUiId, dwID, dwShopID, dwIndex
		OTER_PLAYER_ITEM = 2 , -- 其他玩家身上的物品 nUiId, dwBox, dwX, dwPlayerID
		ITEM_ONLY_ID     = 3 , -- 只有一个ID的物品。比如装备链接之类的。nUiId, dwID, nItemVersion, nTabType, nIndex
		ITEM_INFO        = 4 , -- 类型物品 nUiId, nItemVersion, nTabType, nIndex, nCount(书nCount代表dwRecipeID)
		SKILL            = 5 , -- 技能。dwSkillID, dwSkillLevel, dwOwnerID
		CRAFT            = 6 , -- 技艺。dwProfessionID, dwBranchID, dwCraftID
		SKILL_RECIPE     = 7 , -- 配方dwID, dwLevel
		SYS_BTN          = 8 , -- 系统栏快捷方式dwID
		MACRO            = 9 , -- 宏
		MOUNT            = 10, -- 镶嵌
		ENCHANT          = 11, -- 附魔
		NOT_NEED_KNOWN   = 15, -- 不需要知道类型
		PENDANT          = 16, -- 挂件
		PET              = 17, -- 宠物
		MEDAL            = 18, -- 宠物徽章
		BUFF             = 19, -- BUFF
		MONEY            = 20, -- 金钱
		TRAIN            = 21, -- 修为
		EMOTION_ACTION   = 22, -- 动作表情
	}),
	GLOBAL_HEAD = GLOBAL_HEAD or X.FreezeTable({
		CLIENTPLAYER = 0,
		OTHERPLAYER  = 1,
		NPC          = 2,
		LIFE         = 0,
		GUILD        = 1,
		TITLE        = 2,
		NAME         = 3,
		MARK         = 4,
	}),
	EQUIPMENT_SUB = EQUIPMENT_SUB or X.FreezeTable({
		MELEE_WEAPON      = 0 , -- 近战武器
		RANGE_WEAPON      = 1 , -- 远程武器
		CHEST             = 2 , -- 上衣
		HELM              = 3 , -- 头部
		AMULET            = 4 , -- 项链
		RING              = 5 , -- 戒指
		WAIST             = 6 , -- 腰带
		PENDANT           = 7 , -- 腰缀
		PANTS             = 8 , -- 裤子
		BOOTS             = 9 , -- 鞋子
		BANGLE            = 10, -- 护臂
		WAIST_EXTEND      = 11, -- 腰部挂件
		PACKAGE           = 12, -- 包裹
		ARROW             = 13, -- 暗器
		BACK_EXTEND       = 14, -- 背部挂件
		HORSE             = 15, -- 坐骑
		BULLET            = 16, -- 弩或陷阱
		FACE_EXTEND       = 17, -- 脸部挂件
		MINI_AVATAR       = 18, -- 小头像
		PET               = 19, -- 跟宠
		L_SHOULDER_EXTEND = 20, -- 左肩挂件
		R_SHOULDER_EXTEND = 21, -- 右肩挂件
		BACK_CLOAK_EXTEND = 22, -- 披风
		TOTAL             = 23, --
	}),
	EQUIPMENT_INVENTORY = EQUIPMENT_INVENTORY or X.FreezeTable({
		MELEE_WEAPON  = 0 , -- 普通近战武器
		BIG_SWORD     = 1 , -- 重剑
		RANGE_WEAPON  = 2 , -- 远程武器
		CHEST         = 3 , -- 上衣
		HELM          = 4 , -- 头部
		AMULET        = 5 , -- 项链
		LEFT_RING     = 6 , -- 左手戒指
		RIGHT_RING    = 7 , -- 右手戒指
		WAIST         = 8 , -- 腰带
		PENDANT       = 9, -- 腰缀
		PANTS         = 10, -- 裤子
		BOOTS         = 11, -- 鞋子
		BANGLE        = 12, -- 护臂
		PACKAGE1      = 13, -- 扩展背包1
		PACKAGE2      = 14, -- 扩展背包2
		PACKAGE3      = 15, -- 扩展背包3
		PACKAGE4      = 16, -- 扩展背包4
		PACKAGE_MIBAO = 17, -- 绑定安全产品状态下赠送的额外背包格 （ItemList V9新增）
		BANK_PACKAGE1 = 18, -- 仓库扩展背包1
		BANK_PACKAGE2 = 19, -- 仓库扩展背包2
		BANK_PACKAGE3 = 20, -- 仓库扩展背包3
		BANK_PACKAGE4 = 21, -- 仓库扩展背包4
		BANK_PACKAGE5 = 22, -- 仓库扩展背包5
		ARROW         = 23, -- 暗器
		TOTAL         = 24,
	}),
	CHARACTER_OTACTION_TYPE = setmetatable({}, {
		__index = setmetatable(
			{
				ACTION_IDLE            = 0,
				ACTION_SKILL_PREPARE   = 1,
				ACTION_SKILL_CHANNEL   = 2,
				ACTION_RECIPE_PREPARE  = 3,
				ACTION_PICK_PREPARE    = 4,
				ACTION_PICKING         = 5,
				ACTION_ITEM_SKILL      = 6,
				ACTION_CUSTOM_PREPARE  = 7,
				ACTION_CUSTOM_CHANNEL  = 8,
				ACTION_SKILL_HOARD     = 9,
				ANCIENT_ACTION_PREPARE = 1000,
			},
			{ __index = _G.CHARACTER_OTACTION_TYPE }),
		__newindex = function() end,
	}),
	ROLE_TYPE_LABEL = X.FreezeTable({
		[ROLE_TYPE.STANDARD_MALE  ] = _L['Man'],
		[ROLE_TYPE.STANDARD_FEMALE] = _L['Woman'],
		[ROLE_TYPE.LITTLE_BOY     ] = _L['Boy'],
		[ROLE_TYPE.LITTLE_GIRL    ] = _L['Girl'],
	}),
	FORCE_LIST = FORCE_LIST,
	FORCE_TYPE = FORCE_TYPE,
	FORCE_TYPE_LABEL = g_tStrings.tForceTitle,
	FORCE_AVATAR = ((function()
		local FORCE_AVATAR = {}
		for i, v in ipairs(FORCE_LIST) do
			FORCE_AVATAR[v.dwID] = {v.szUITex, v.nFrame, v.bAnimate}
		end
		return setmetatable(
			FORCE_AVATAR,
			{
				__index = function(t, k)
					return t[FORCE_TYPE.JIANG_HU]
				end,
				__metatable = true,
			})
	end)()),
	KUNGFU_LIST = KUNGFU_LIST,
	KUNGFU_TYPE = KUNGFU_TYPE,
	KUNGFU_TYPE_LABEL_ABBR = setmetatable(X.Clone(_L.KUNGFU_TYPE_LABEL_ABBR), {
		__index = function(t)
			return _L.KUNGFU_TYPE_LABEL_ABBR[0]
		end,
		__metatable = true,
	}),
	KUNGFU_FORCE_TYPE = ((function()
		local res = {}
		for i, v in ipairs(KUNGFU_LIST) do
			res[v.dwID] = v.dwForceID
		end
		return res
	end)()),
	KUNGFU_MOUNT_TYPE = (function()
		local KUNGFU_MOUNT_TYPE = _G.KUNGFU_TYPE or X.FreezeTable({
			TIAN_CE     = 1,      -- 天策内功
			WAN_HUA     = 2,      -- 万花内功
			CHUN_YANG   = 3,      -- 纯阳内功
			QI_XIU      = 4,      -- 七秀内功
			SHAO_LIN    = 5,      -- 少林内功
			CANG_JIAN   = 6,      -- 藏剑内功
			GAI_BANG    = 7,      -- 丐帮内功
			MING_JIAO   = 8,      -- 明教内功
			WU_DU       = 9,      -- 五毒内功
			TANG_MEN    = 10,     -- 唐门内功
			CANG_YUN    = 18,     -- 苍云内功
			CHANG_GE    = 19,     -- 长歌内功
			BA_DAO      = 20,     -- 霸刀内功
			PENG_LAI    = 21,     -- 蓬莱内功
			LING_XUE    = 22,     -- 凌雪内功
			YAN_TIAN    = 23,     -- 衍天内功
		})
		local res = {}
		for k, v in X.pairs_c(KUNGFU_MOUNT_TYPE) do
			if g_tStrings.tForceTitle[v] then
				res[k] = v
			end
		end
		return X.FreezeTable(res)
	end)(),
	PEEK_OTHER_PLAYER_RESPOND = PEEK_OTHER_PLAYER_RESPOND or X.FreezeTable({
		INVALID             = 0,
		SUCCESS             = 1,
		FAILED              = 2,
		CAN_NOT_FIND_PLAYER = 3,
		TOO_FAR             = 4,
	}),
	MIC_STATE = MIC_STATE or X.FreezeTable({
		NOT_AVIAL = 1,
		CLOSE_NOT_IN_ROOM = 2,
		CLOSE_IN_ROOM = 3,
		KEY = 4,
		FREE = 5,
	}),
	SPEAKER_STATE = SPEAKER_STATE or X.FreezeTable({
		OPEN = 1,
		CLOSE = 2,
	}),
	CHAT_PANEL_INDEX_LIST = X.FreezeTable({
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		11,
		'_Recently',
	}),
	ITEM_QUALITY = X.FreezeTable({
		GRAY    = 0, -- 灰色
		WHITE   = 1, -- 白色
		GREEN   = 2, -- 绿色
		BLUE    = 3, -- 蓝色
		PURPLE  = 4, -- 紫色
		NACARAT = 5, -- 橙色
		GLODEN  = 6, -- 暗金
	}),
	CRAFT_TYPE = {
		MINING = 1, --采矿
		HERBALISM = 2, -- 神农
		SKINNING = 3, -- 庖丁
		READING = 8, -- 阅读
	},
	MOBA_MAP = {
		[412] = true, -- 列星岛
	},
	SCHOOL_MAP = {
		[  2] = true, -- 万花
		[  5] = true, -- 少林
		[  7] = true, -- 纯阳
		[ 11] = true, -- 天策
		[ 16] = true, -- 七秀
		[ 49] = true, -- 藏剑山庄
		[102] = true, -- 五毒
		[122] = true, -- 唐门
		[150] = true, -- 明教
		[159] = true, -- 丐帮
		[193] = true, -- 苍云
		[213] = true, -- 长歌门
		[243] = true, -- 霸刀山庄
		[333] = true, -- 蓬莱
		[419] = true, -- 凌雪阁
		[464] = true, -- 衍天宗
		[526] = true, -- 北天药宗
		[578] = true, -- 刀宗
		[642] = true, -- 万灵山庄
		[666] = true, -- 南诏段氏
		[158] = true, -- 天策·战乱
		[473] = true, -- 万花·乱世
		[474] = true, -- 七秀·乱世
		[475] = true, -- 少林·乱世
		[488] = true, -- 藏剑山庄·乱世
		[718] = true, -- 永宁湾
	},
	STARVE_MAP = {
		[421] = true, -- 浪客行·悬棺裂谷
		[422] = true, -- 浪客行·桑珠草原
		[423] = true, -- 浪客行·东水寨
		[424] = true, -- 浪客行·湘竹溪
		[425] = true, -- 浪客行·荒魂镇
		[433] = true, -- 浪客行·有间客栈
		[434] = true, -- 浪客行·绥梦山
		[435] = true, -- 浪客行·华清宫
		[436] = true, -- 浪客行·枫阳村
		[437] = true, -- 浪客行·荒雪路
		[438] = true, -- 浪客行·古祭坛
		[439] = true, -- 浪客行·雾荧洞
		[440] = true, -- 浪客行·阴风峡
		[441] = true, -- 浪客行·翡翠瑶池
		[442] = true, -- 浪客行·胡杨林道
		[443] = true, -- 浪客行·浮景峰
		[461] = true, -- 浪客行·落樱林
		[527] = true, -- 浪客行·苍离岛
		[528] = true, -- 浪客行·漓水
	},
	MONSTER_MAP = {
		[562] = true, -- 百战异闻录
	},
	ROGUELIKE_MAP = {
		[995] = true, -- 八荒衡鉴
	},
	CITY_MAP = {
		[  6] = true, -- 扬州
		[  8] = true, -- 洛阳
		[ 15] = true, -- 长安
		[108] = true, -- 成都
		[151] = true, -- 洛阳·战乱
		[156] = true, -- 长安·战乱
		[172] = true, -- 长安城
		[194] = true, -- 太原
		[239] = true, -- 洛阳城
		[332] = true, -- 侠客岛
	},
	STRONGHOLD_MAP = {
		[  9] = true, -- 洛道
		[ 13] = true, -- 金水镇
		[ 21] = true, -- 巴陵县
		[ 22] = true, -- 南屏山
		[ 23] = true, -- 龙门荒漠
		[ 30] = true, -- 昆仑
		[ 35] = true, -- 瞿塘峡
		[100] = true, -- 白龙口
		[101] = true, -- 无量山
		[103] = true, -- 融天岭
		[104] = true, -- 黑龙沼
		[105] = true, -- 苍山洱海
		[139] = true, -- 枫华谷·战乱
		[153] = true, -- 马嵬驿
	},
	-- “子地图”到“主地图”映射表：按地图生效的功能，在同一地图的子地图时，合并数据到主地图
	MAP_MERGE = {
		[143] = 147, -- 试炼之地
		[144] = 147, -- 试炼之地
		[145] = 147, -- 试炼之地
		[146] = 147, -- 试炼之地
		[195] = 196, -- 雁门关之役
		[276] = 281, -- 拭剑园
		[278] = 281, -- 拭剑园
		[279] = 281, -- 拭剑园
		[280] = 281, -- 拭剑园
		[296] = 297, -- 龙门绝境
	},
	MAP_NAME = {},
	NPC_NAME = {
		[58294] = '{$N62347}', -- 剑出鸿蒙
	},
	NPC_HIDDEN = {
		[19153] = true, -- 皇宫范围总控
		[27634] = true, -- 秦皇陵安禄山总控
		[56383] = true, -- 通关进度完成表现控制
		[60045] = true, -- 辉天堑铁库牢房的不知道什么东西
	},
	DOODAD_NAME = {
		[3713] = '{$D1}', -- 遗体
		[3714] = '{$D1}', -- 遗体
		[3114] = '{$I5,11091}', -- 峨眉白芽
		[3115] = '{$I5,11092}', -- 仙崖石花
		[3116] = '{$I5,11093}', -- 顾渚紫笋
	},
	FORCE_FOREGROUND_COLOR = (function()
		local OFFICIAL_COLOR = {}
		local function GetOfficialForceColor(k)
			if not OFFICIAL_COLOR[k] then
				local tColor
				if GetKungfuSchoolColor and Table_ForceToSchool then
					local bSuccess, dwSchoolID = X.SafeXpCall(Table_ForceToSchool, k)
					if bSuccess and dwSchoolID then
						local bSuccess, nR, nG, nB = X.SafeXpCall(GetKungfuSchoolColor, dwSchoolID)
						if bSuccess and nR and nG and nB then
							tColor = { nR, nG, nB }
						end
					end
				end
				OFFICIAL_COLOR[k] = tColor or {}
			end
			return X.Unpack(OFFICIAL_COLOR[k])
		end
		return setmetatable(
			KvpToObject({
				{ FORCE_TYPE.JIANG_HU , { 255, 255, 255 } }, -- 江湖
				{ FORCE_TYPE.SHAO_LIN , { 255, 178,  95 } }, -- 少林
				{ FORCE_TYPE.WAN_HUA  , { 196, 152, 255 } }, -- 万花
				{ FORCE_TYPE.TIAN_CE  , { 255, 111,  83 } }, -- 天策
				{ FORCE_TYPE.CHUN_YANG, {  22, 216, 216 } }, -- 纯阳
				{ FORCE_TYPE.QI_XIU   , { 255, 129, 176 } }, -- 七秀
				{ FORCE_TYPE.WU_DU    , {  55, 147, 255 } }, -- 五毒
				{ FORCE_TYPE.TANG_MEN , { 121, 183,  54 } }, -- 唐门
				{ FORCE_TYPE.CANG_JIAN, { 214, 249,  93 } }, -- 藏剑
				{ FORCE_TYPE.GAI_BANG , { 205, 133,  63 } }, -- 丐帮
				{ FORCE_TYPE.MING_JIAO, { 240,  70,  96 } }, -- 明教
				{ FORCE_TYPE.CANG_YUN , X.IS_REMOTE and { 255, 143, 80 } or { 180, 60, 0 } }, -- 苍云
				{ FORCE_TYPE.CHANG_GE , { 100, 250, 180 } }, -- 长歌
				{ FORCE_TYPE.BA_DAO   , { 106, 108, 189 } }, -- 霸刀
				{ FORCE_TYPE.PENG_LAI , { 171, 227, 250 } }, -- 蓬莱
				{ FORCE_TYPE.LING_XUE , X.IS_REMOTE and { 253, 86, 86 } or { 161,   9,  34 } }, -- 凌雪
				{ FORCE_TYPE.YAN_TIAN , { 166,  83, 251 } }, -- 衍天
				{ FORCE_TYPE.YAO_ZONG , {   0, 172, 153 } }, -- 药宗
				{ FORCE_TYPE.DAO_ZONG , { 107, 183, 242 } }, -- 刀宗
				{ FORCE_TYPE.WAN_LING , { 235, 215, 115 } }, -- 万灵
			}),
			{
				__index = function(t, k)
					local tColor
					local nR, nG, nB = GetOfficialForceColor(k)
					if nR and nG and nB then
						tColor = { nR, nG, nB }
					end
					-- NPC 以及未知门派
					if not tColor then
						tColor = { 225, 225, 225 }
					end
					t[k] = tColor
					return tColor
				end,
				__metatable = true,
			}
		)
	end)(),
	FORCE_BACKGROUND_COLOR = (function()
		local OFFICIAL_COLOR = {}
		local function GetOfficialForceColor(k)
			if not OFFICIAL_COLOR[k] then
				local tColor
				if ForceUI_GetFightColor then
					local bSuccess, tRetColor = X.SafeCall(ForceUI_GetFightColor, k)
					if bSuccess and tRetColor then
						tColor = tRetColor
					end
				end
				OFFICIAL_COLOR[k] = tColor or {}
			end
			return X.Unpack(OFFICIAL_COLOR[k])
		end
		return setmetatable(
			KvpToObject({
				{ FORCE_TYPE.JIANG_HU , { 220, 220, 220 } }, -- 江湖
				{ FORCE_TYPE.SHAO_LIN , { 125, 112,  10 } }, -- 少林
				{ FORCE_TYPE.WAN_HUA  , {  47,  14,  70 } }, -- 万花
				{ FORCE_TYPE.TIAN_CE  , { 105,  14,  14 } }, -- 天策
				{ FORCE_TYPE.CHUN_YANG, {   8,  90, 113 } }, -- 纯阳 56,175,255,232
				{ FORCE_TYPE.QI_XIU   , { 162,  74, 129 } }, -- 七秀
				{ FORCE_TYPE.WU_DU    , {   7,  82, 154 } }, -- 五毒
				{ FORCE_TYPE.TANG_MEN , {  75, 113,  40 } }, -- 唐门
				{ FORCE_TYPE.CANG_JIAN, { 148, 152,  27 } }, -- 藏剑
				{ FORCE_TYPE.GAI_BANG , { 159, 102,  37 } }, -- 丐帮
				{ FORCE_TYPE.MING_JIAO, { 145,  80,  17 } }, -- 明教
				{ FORCE_TYPE.CANG_YUN , { 157,  47,   2 } }, -- 苍云
				{ FORCE_TYPE.CHANG_GE , {  31, 120, 103 } }, -- 长歌
				{ FORCE_TYPE.BA_DAO   , {  49,  39, 110 } }, -- 霸刀
				{ FORCE_TYPE.PENG_LAI , {  93,  97, 126 } }, -- 蓬莱
				{ FORCE_TYPE.LING_XUE , { 161,   9,  34 } }, -- 凌雪
				{ FORCE_TYPE.YAN_TIAN , {  96,  45, 148 } }, -- 衍天
				{ FORCE_TYPE.YAO_ZONG , {  10,  81,  87 } }, -- 药宗
				{ FORCE_TYPE.DAO_ZONG , {  64, 101, 169 } }, -- 刀宗
				{ FORCE_TYPE.WAN_LING , { 160, 135,  75 } }, -- 万灵
			}),
			{
				__index = function(t, k)
					local tColor
					local nR, nG, nB = GetOfficialForceColor(k)
					if nR and nG and nB then
						tColor = { nR, nG, nB }
					end
					-- NPC 以及未知门派
					if not tColor then
						tColor = { 200, 200, 200 }
					end
					t[k] = tColor
					return tColor
				end,
				__metatable = true,
			}
		)
	end)(),
	CAMP_FOREGROUND_COLOR = setmetatable(
		KvpToObject({
			{ CAMP.NEUTRAL, { 255, 255, 255 } }, -- 中立
			{ CAMP.GOOD   , {  60, 128, 220 } }, -- 浩气盟
			{ CAMP.EVIL   , X.IS_REMOTE and { 255, 63, 63 } or { 160, 30, 30 } }, -- 恶人谷
		}),
		{
			__index = function(t, k)
				return { 225, 225, 225 }
			end,
			__metatable = true,
		}),
	CAMP_BACKGROUND_COLOR = setmetatable(
		KvpToObject({
			{ CAMP.NEUTRAL, { 255, 255, 255 } }, -- 中立
			{ CAMP.GOOD   , {  60, 128, 220 } }, -- 浩气盟
			{ CAMP.EVIL   , { 160,  30,  30 } }, -- 恶人谷
		}),
		{
			__index = function(t, k)
				return { 225, 225, 225 }
			end,
			__metatable = true,
		}),
	MSG_THEME = X.FreezeTable({
		NORMAL = 0,
		ERROR = 1,
		WARNING = 2,
		SUCCESS = 3,
	}),
	SKILL_TYPE = {
		[15054] = {
			[25] = 'HEAL', -- 梅花三弄
		},
	},
	MINI_MAP_POINT = {
		QUEST_REGION    = 1,
		TEAMMATE        = 2,
		SPARKING        = 3,
		DEATH           = 4,
		QUEST_NPC       = 5,
		DOODAD          = 6,
		MAP_MARK        = 7,
		FUNCTION_NPC    = 8,
		RED_NAME        = 9,
		NEW_PQ	        = 10,
		SPRINT_POINT    = 11,
		FAKE_FELLOW_PET = 12,
	},
	HOMELAND_RESULT_CODE = _G.HOMELAND_RESULT_CODE or {
		APPLY_COMMUNITY_INFO = 503,
	},
	FLOWERS_UIID = {
		[163810] = true, -- 黑玫瑰
		[163811] = true, -- 蓝玫瑰
		[163812] = true, -- 绿玫瑰
		[163813] = true, -- 黄玫瑰
		[163814] = true, -- 粉玫瑰
		[163815] = true, -- 红玫瑰
		[163816] = true, -- 紫玫瑰
		[163817] = true, -- 白玫瑰
		[163818] = true, -- 混色玫瑰
		[163819] = true, -- 橙玫瑰
		[163820] = true, -- 粉百合
		[163821] = true, -- 橙百合
		[163822] = true, -- 白百合
		[163823] = true, -- 黄百合
		[163824] = true, -- 绿百合
		[163825] = true, -- 蓝色绣球花
		[163826] = true, -- 粉色绣球花
		[163827] = true, -- 红色绣球花
		[163828] = true, -- 紫色绣球花
		[163829] = true, -- 白色绣球花
		[163830] = true, -- 黄色绣球花
		[163831] = true, -- 粉色郁金香
		[163832] = true, -- 混色郁金香
		[163833] = true, -- 红色郁金香
		[163834] = true, -- 白色郁金香
		[163835] = true, -- 金色郁金香
		[163836] = true, -- 蓝锦牵牛
		[163837] = true, -- 绯锦牵牛
		[163838] = true, -- 红锦牵牛
		[163839] = true, -- 紫锦牵牛
		[163840] = true, -- 黄锦牵牛
		[163841] = true, -- 荧光菌·蓝
		[163842] = true, -- 荧光菌·红
		[163843] = true, -- 荧光菌·紫
		[163844] = true, -- 荧光菌·白
		[163845] = true, -- 荧光菌·黄
		[250069] = true, -- 羽扇豆花·白
		[250070] = true, -- 羽扇豆花·红
		[250071] = true, -- 羽扇豆花·紫
		[250072] = true, -- 羽扇豆花·黄
		[250073] = true, -- 羽扇豆花·粉
		[250074] = true, -- 羽扇豆花·蓝
		[250075] = true, -- 羽扇豆花·蓝白
		[250076] = true, -- 羽扇豆花·黄粉
		[250510] = true, -- 白葫芦
		[250512] = true, -- 红葫芦
		[250513] = true, -- 橙葫芦
		[250514] = true, -- 黄葫芦
		[250515] = true, -- 绿葫芦
		[250516] = true, -- 青葫芦
		[250517] = true, -- 蓝葫芦
		[250518] = true, -- 紫葫芦
		[250519] = true, -- 普通麦子
		[250520] = true, -- 黑麦
		[250521] = true, -- 绿麦
		[250522] = true, -- 紫麦
		[250523] = true, -- 普通青菜
		[250524] = true, -- 紫冠青菜
		[250525] = true, -- 芜菁·白
		[250526] = true, -- 芜菁·青白
		[250527] = true, -- 芜菁·紫红
		[250528] = true, -- 嫩黄瓜
		[250529] = true, -- 老黄瓜
	},
	PLAYER_TALK_CHANNEL_TO_MSG_TYPE = KvpToObject({
		{ PLAYER_TALK_CHANNEL.WHISPER          , 'MSG_WHISPER'           },
		{ PLAYER_TALK_CHANNEL.NEARBY           , 'MSG_NORMAL'            },
		{ PLAYER_TALK_CHANNEL.TEAM             , 'MSG_PARTY'             },
		{ PLAYER_TALK_CHANNEL.ROOM             , 'MSG_ROOM'              },
		{ PLAYER_TALK_CHANNEL.TONG             , 'MSG_GUILD'             },
		{ PLAYER_TALK_CHANNEL.TONG_ALLIANCE    , 'MSG_GUILD_ALLIANCE'    },
		{ PLAYER_TALK_CHANNEL.TONG_SYS         , 'MSG_GUILD'             },
		{ PLAYER_TALK_CHANNEL.WORLD            , 'MSG_WORLD'             },
		{ PLAYER_TALK_CHANNEL.FORCE            , 'MSG_SCHOOL'            },
		{ PLAYER_TALK_CHANNEL.CAMP             , 'MSG_CAMP'              },
		{ PLAYER_TALK_CHANNEL.FRIENDS          , 'MSG_FRIEND'            },
		{ PLAYER_TALK_CHANNEL.RAID             , 'MSG_TEAM'              },
		{ PLAYER_TALK_CHANNEL.SENCE            , 'MSG_MAP'               },
		{ PLAYER_TALK_CHANNEL.BATTLE_FIELD     , 'MSG_BATTLE_FILED'      },
		{ PLAYER_TALK_CHANNEL.LOCAL_SYS        , 'MSG_SYS'               },
		{ PLAYER_TALK_CHANNEL.GM_MESSAGE       , 'MSG_SYS'               },
		{ PLAYER_TALK_CHANNEL.NPC_WHISPER      , 'MSG_NPC_WHISPER'       },
		{ PLAYER_TALK_CHANNEL.NPC_SAY_TO       , 'MSG_NPC_WHISPER'       },
		{ PLAYER_TALK_CHANNEL.NPC_NEARBY       , 'MSG_NPC_NEARBY'        },
		{ PLAYER_TALK_CHANNEL.NPC_PARTY        , 'MSG_NPC_PARTY'         },
		{ PLAYER_TALK_CHANNEL.NPC_SENCE        , 'MSG_NPC_YELL'          },
		{ PLAYER_TALK_CHANNEL.FACE             , 'MSG_FACE'              },
		{ PLAYER_TALK_CHANNEL.NPC_FACE         , 'MSG_NPC_FACE'          },
		{ PLAYER_TALK_CHANNEL.NPC_SAY_TO_CAMP  , 'MSG_CAMP'              },
		{ PLAYER_TALK_CHANNEL.IDENTITY         , 'MSG_IDENTITY'          },
		{ PLAYER_TALK_CHANNEL.BULLET_SCREEN    , 'MSG_JJC_BULLET_SCREEN' },
		{ PLAYER_TALK_CHANNEL.BATTLE_FIELD_SIDE, 'MSG_BATTLE_FIELD_SIDE' },
		{ PLAYER_TALK_CHANNEL.STORY_NPC        , 'MSG_STORY_NPC'         },
		{ PLAYER_TALK_CHANNEL.STORY_NPC_YELL   , 'MSG_STORY_NPC'         },
		{ PLAYER_TALK_CHANNEL.STORY_NPC_WHISPER, 'MSG_STORY_NPC'         },
		{ PLAYER_TALK_CHANNEL.STORY_NPC_YELL_TO, 'MSG_STORY_NPC'         },
		{ PLAYER_TALK_CHANNEL.STORY_PLAYER     , 'MSG_STORY_PLAYER'      },
	}),
	MSG_TYPE_LIST = (function()
		local aList = {}
		local function CollectMsgType(node)
			for _, v in ipairs(node) do
				if X.IsString(v) then
					table.insert(aList, v)
				elseif X.IsTable(v) then
					CollectMsgType(v)
				end
			end
			return aList
		end
		return CollectMsgType(MSG_TYPE_MENU)
	end)(),
	MSG_TYPE_MENU = MSG_TYPE_MENU,
	PLAYER_TALK_CHANNEL_HEADER = KvpToObject({
		{ PLAYER_TALK_CHANNEL.NEARBY       , '/s '  },
		{ PLAYER_TALK_CHANNEL.FRIENDS      , '/o '  },
		{ PLAYER_TALK_CHANNEL.TONG_ALLIANCE, '/a '  },
		{ PLAYER_TALK_CHANNEL.TEAM         , '/p '  },
		{ PLAYER_TALK_CHANNEL.RAID         , '/t '  },
		{ PLAYER_TALK_CHANNEL.ROOM         , '/gr ' },
		{ PLAYER_TALK_CHANNEL.BATTLE_FIELD , '/b '  },
		{ PLAYER_TALK_CHANNEL.TONG         , '/g '  },
		{ PLAYER_TALK_CHANNEL.SENCE        , '/y '  },
		{ PLAYER_TALK_CHANNEL.FORCE        , '/f '  },
		{ PLAYER_TALK_CHANNEL.CAMP         , '/c '  },
		{ PLAYER_TALK_CHANNEL.WORLD        , '/h '  },
	}),
	INVENTORY_INDEX = INVENTORY_INDEX,
	INVENTORY_TYPE = {
		EQUIP           = 1, -- 身上穿装备位置
		PACKAGE         = 2, -- 背包，自动切换额外背包
		BANK            = 3, -- 仓库
		GUILD_BANK      = 4, -- 帮会仓库
		ORIGIN_PACKAGE  = 5, -- 原始背包
		LIMITED_PACKAGE = 6, -- 额外背包
	},
	INVENTORY_EQUIP_LIST = {
		INVENTORY_INDEX.EQUIP,
		INVENTORY_INDEX.EQUIP_BACKUP1,
		INVENTORY_INDEX.EQUIP_BACKUP2,
		X.IIf(X.IS_CLASSIC, nil, INVENTORY_INDEX.EQUIP_BACKUP3),
	},
	INVENTORY_PACKAGE_LIST = {
		INVENTORY_INDEX.PACKAGE,
		INVENTORY_INDEX.PACKAGE1,
		INVENTORY_INDEX.PACKAGE2,
		INVENTORY_INDEX.PACKAGE3,
		INVENTORY_INDEX.PACKAGE4,
		INVENTORY_INDEX.PACKAGE_MIBAO,
	},
	INVENTORY_LIMITED_PACKAGE_LIST = {
		INVENTORY_INDEX.LIMITED_PACKAGE,
	},
	INVENTORY_BANK_LIST = {
		INVENTORY_INDEX.BANK,
		INVENTORY_INDEX.BANK_PACKAGE1,
		INVENTORY_INDEX.BANK_PACKAGE2,
		INVENTORY_INDEX.BANK_PACKAGE3,
		INVENTORY_INDEX.BANK_PACKAGE4,
		INVENTORY_INDEX.BANK_PACKAGE5,
	},
	INVENTORY_GUILD_BANK_LIST = {
		INVENTORY_INDEX.GUILD_BANK,
		INVENTORY_INDEX.GUILD_BANK_PACKAGE1,
		INVENTORY_INDEX.GUILD_BANK_PACKAGE2,
		INVENTORY_INDEX.GUILD_BANK_PACKAGE3,
		INVENTORY_INDEX.GUILD_BANK_PACKAGE4,
		INVENTORY_INDEX.GUILD_BANK_PACKAGE5,
		INVENTORY_INDEX.GUILD_BANK_PACKAGE6,
		INVENTORY_INDEX.GUILD_BANK_PACKAGE7,
		INVENTORY_INDEX.GUILD_BANK_PACKAGE8,
	},
	AUCTION_ITEM_LIST_TYPE = _G.AUCTION_ITEM_LIST_TYPE or X.FreezeTable({
		NORMAL_LOOK_UP = 0,
		PRICE_LOOK_UP  = 1,
		DETAIL_LOOK_UP = 2,
		SELL_LOOK_UP   = 3,
		AVG_LOOK_UP    = 4,
	}),
	LOOT_ITEM_TYPE = _G.LOOT_ITEM_TYPE or X.FreezeTable({
		INVALID               = 0,
		OWNER_LOOT            = 1,
		OVER_TIME_LOOTER_FREE = 2,
		ABSOLUTE_FREE         = 3,
		LOOTER_FREE           = 4,
		NEED_DISTRIBUTE       = 5,
		NEED_ROLL             = 6,
		NEED_BIDDING          = 7,
		TOTAL                 = 8,
	}),
	NPC_SPECIES_TYPE = _G.NPC_SPECIES_TYPE or X.FreezeTable({
		NPC_HUMANOID    = 1,
		NPC_BEAST       = 2,
		NPC_MECHANICAL  = 3,
		NPC_UNDEAD      = 4,
		NPC_GHOST       = 5,
		NPC_PLANT       = 6,
		NPC_LEGENDARY   = 7,
		NPC_CRITTER     = 8,
		NPC_OTHER       = 9,
		NPC_PET         = 10,
		NPC_GAS         = 11,
		NPC_BATTERY     = 12,
		NPC_TRAP        = 13,
		NPC_BOMB        = 14,
		NPC_FELLOW_PET  = 15,
		NPC_SWORD_POWER = 16,
		NPC_ASSISTED    = 17,
		NPC_MIRAGE      = 18,
		NPC_BEAST_PET   = 19,
		NPC_TONRAUM     = 20,
	}),
	DOODAD_KIND = X.FreezeTable(
		setmetatable({
			SPRINT = _G.DOODAD_KIND.SPRINT or _G.DOODAD_KIND.BANQUET or 15,
			BANQUET = _G.DOODAD_KIND.BANQUET or _G.DOODAD_KIND.SPRINT or 15,
		}, { __index = _G.DOODAD_KIND })
	),
	TEAM_MARK,
	TEAM_MARK_NAME = {
		[TEAM_MARK.CLOUD] = _L['TEAM_MARK_CLOUD'],
		[TEAM_MARK.SWORD] = _L['TEAM_MARK_SWORD'],
		[TEAM_MARK.AX   ] = _L['TEAM_MARK_AX'   ],
		[TEAM_MARK.HOOK ] = _L['TEAM_MARK_HOOK' ],
		[TEAM_MARK.DRUM ] = _L['TEAM_MARK_DRUM' ],
		[TEAM_MARK.SHEAR] = _L['TEAM_MARK_SHEAR'],
		[TEAM_MARK.STICK] = _L['TEAM_MARK_STICK'],
		[TEAM_MARK.JADE ] = _L['TEAM_MARK_JADE' ],
		[TEAM_MARK.DART ] = _L['TEAM_MARK_DART' ],
		[TEAM_MARK.FAN  ] = _L['TEAM_MARK_FAN'  ],
	},
	WORLD_MARK = {
		{ nIndex = 1 , dwNpcTemplateID = 20107, tColor = { 255, 255, 255 } },
		{ nIndex = 2 , dwNpcTemplateID = 20108, tColor = { 255, 128, 0   } },
		{ nIndex = 3 , dwNpcTemplateID = 20109, tColor = { 0  , 0  , 255 } },
		{ nIndex = 4 , dwNpcTemplateID = 20110, tColor = { 0  , 255, 0   } },
		{ nIndex = 5 , dwNpcTemplateID = 20111, tColor = { 255, 0  , 0   } },
		{ nIndex = 6 , dwNpcTemplateID = 36781, tColor = { 50 , 220, 255 } },
		{ nIndex = 7 , dwNpcTemplateID = 36782, tColor = { 255, 100, 220 } },
		{ nIndex = 8 , dwNpcTemplateID = 36783, tColor = { 255, 255, 0   } },
		{ nIndex = 9 , dwNpcTemplateID = 36784, tColor = { 200, 40,  255 } },
		{ nIndex = 10, dwNpcTemplateID = 36785, tColor = { 30,  255, 180 } },
	},
	CLIENT_VERSION_TYPE = _G.CLIENT_VERSION_TYPE or X.FreezeTable({
		NORMAL                 = 0,
		WEGAME                 = 1,
		STREAMING              = 2,
		MOBILE_ANDROID         = 3,
		MOBILE_IOS             = 4,
		MOBILE_PC              = 5,
		MOBILE_OHOS            = 6,
		MOBILE_MAC             = 7,
		MOBILE_WLCLOUD_ANDROID = 8,
		MOBILE_WLCLOUD_IOS     = 9,
	}),
	MACHINE_GPU_TYPE = X.FreezeTable({
		LOW    = 1,
		NORMAL = 2,
	}),
	MACHINE_GPU_LEVEL = X.FreezeTable({
		ENABLE     =  0,
		ATTEND     =  1,
		LOWEST     =  2, -- 最简
		LOW_MOST   =  3, -- 简约
		LOW        =  4, -- 均衡
		MEDIUM     =  5, -- 唯美 // 这档现在弃用了，原来选这档的人进来以后直接改成均衡
		HIGH       =  6, -- 高效
		PERFECTION =  7, -- 电影
		HD         =  8, -- 极致
		PERFECT    = 10, -- 沉浸
		EXPLORE    =  9, -- 探索 // 比 PERFECT 要高，但是枚举值却小一点
	}),
	USER_SETTINGS_LOCATION_OVERRIDE = X.FreezeTable({
		PRESET = 0,
		ROLE   = 1,
		SERVER = 2,
		GLOBAL = 3,
	}),
	ZHEN_PAI = PickBranch({
		classic = TALENT_TAB or KvpToObject({
			{
				FORCE_TYPE.SHAO_LIN,
				{
					{
						{ 2549, 2559, 2556, 0 },
						{ 2557, 2558, 2564, 2560 },
						{ 2561, 2563, 2551, 2565 },
						{ 2566, 2567, 2568, 64095 },
						{ 2570, 64002, 64004, 64096 },
						{ 64106, 2572, 64109, 0 },
					},
					{
						{ 2573, 2574, 2575, 0 },
						{ 2576, 2577, 2578, 2579 },
						{ 2580, 2581, 2582, 2583 },
						{ 2584, 2585, 2586, 2587 },
						{ 2588, 2562, 0, 0 },
						{ 0, 2589, 0, 0 },
					},
				}
			},
			{
				FORCE_TYPE.WAN_HUA,
				{
					{
						{ 2629, 2630, 2631, 0 },
						{ 2632, 2633, 2634, 2635 },
						{ 2639, 2637, 2638, 2636 },
						{ 2640, 2641, 2642, 64010 },
						{ 2643, 2644, 64112, 64022 },
						{ 64114, 2645, 64113, 0 },
					},
					{
						{ 2647, 2648, 2652, 0 },
						{ 2650, 2651, 2649, 2653 },
						{ 2654, 2655, 2656, 2657 },
						{ 2658, 2659, 2660, 3789 },
						{ 2661, 64001, 64116, 64131 },
						{ 0, 2663, 0, 0 },
					},
				}
			},
			{
				FORCE_TYPE.TIAN_CE,
				{
					{
						{ 2595, 2596, 2597, 0 },
						{ 2598, 2599, 2600, 2601 },
						{ 2602, 2603, 2604, 2605 },
						{ 2606, 2607, 2608, 64117 },
						{ 64118, 2609, 2610, 64119 },
						{ 0, 2611, 0, 0 },
					},
					{
						{ 2612, 2613, 2614, 0 },
						{ 2615, 2616, 2617, 2618 },
						{ 2619, 2620, 2621, 2622 },
						{ 2623, 2624, 2625, 0 },
						{ 2626, 2627, 0, 0 },
						{ 0, 2628, 0, 0 },
					},
				}
			},
			{
				FORCE_TYPE.CHUN_YANG,
				{
					{
						{ 2682, 2683, 0, 2684 },
						{ 2685, 2686, 2687, 2688 },
						{ 2689, 2690, 2691, 2692 },
						{ 2693, 2694, 2695, 2696 },
						{ 2698, 2697, 64008, 64135 },
						{ 64137, 64136, 2699, 0 },
					},
					{
						{ 2665, 2666, 0, 2667 },
						{ 2679, 2669, 2670, 2671 },
						{ 2672, 2673, 2674, 2675 },
						{ 64129, 2677, 2676, 2678 },
						{ 4080, 2668, 2680, 64133 },
						{ 64134, 2681, 0, 0 },
					},
				}
			},
			{
				FORCE_TYPE.QI_XIU,
				{
					{
						{ 2700, 2701, 2702, 0 },
						{ 2703, 2704, 2709, 2706 },
						{ 2707, 2708, 2705, 2710 },
						{ 2711, 2712, 64098, 2713 },
						{ 0, 2714, 2715, 0 },
						{ 0, 2716, 64103, 0 },
					},
					{
						{ 2717, 2718, 2719, 0 },
						{ 2720, 2721, 2722, 2723 },
						{ 2724, 2725, 2726, 2727 },
						{ 2728, 2729, 2730, 2731 },
						{ 64104, 64105, 2732, 0 },
						{ 0, 2733, 0, 0 },
					},
				}
			},
			{
				FORCE_TYPE.WU_DU,
				{
					{
						{ 2993, 0, 2935, 2936 },
						{ 2937, 2938, 2939, 2940 },
						{ 2941, 2218, 2942, 2943 },
						{ 2945, 2946, 2944, 64139 },
						{ 64140, 2947, 2948, 0 },
						{ 0, 0, 2227, 0 },
					},
					{
						{ 2949, 2950, 0, 2951 },
						{ 2952, 2953, 2954, 2955 },
						{ 2956, 2957, 2958, 2959 },
						{ 2960, 0, 2961, 2962 },
						{ 64138, 64041, 2963, 2964 },
						{ 0, 64643, 2965, 0 },
					},
				}
			},
			{
				FORCE_TYPE.TANG_MEN,
				{
					{
						{ 3260, 3261, 3262, 0 },
						{ 3263, 3264, 3265, 3266 },
						{ 3267, 3101, 3268, 3269 },
						{ 3270, 3271, 3272, 3492 },
						{ 0, 3273, 64082, 0 },
						{ 0, 3100, 0, 0 },
					},
					{
						{ 3275, 3276, 3277, 0 },
						{ 3278, 3279, 3280, 3281 },
						{ 64081, 3110, 3283, 3284 },
						{ 3285, 3286, 3287, 0 },
						{ 3288, 3282, 0, 0 },
						{ 0, 3111, 0, 0 },
					},
				}
			},
			{
				FORCE_TYPE.CANG_JIAN,
				{
					{
						{ 2734, 2735, 2736, 0 },
						{ 2737, 2738, 2739, 2740 },
						{ 2741, 2742, 2748, 2743 },
						{ 2745, 2744, 3417, 64024 },
						{ 2747, 2749, 64124, 2762 },
						{ 0, 2750, 0, 64125 },
					},
					{
						{ 2751, 2752, 2753, 0 },
						{ 2754, 2760, 2763, 2757 },
						{ 2758, 2755, 2759, 2761 },
						{ 2746, 2756, 2764, 64126 },
						{ 2765, 2766, 2767, 0 },
						{ 0, 2768, 0, 0 },
					},
				}
			},
			{
				FORCE_TYPE.MING_JIAO,
				{
					{
						{ 3986, 3987, 3988, 0 },
						{ 3989, 3990, 3991, 3992 },
						{ 3977, 3993, 3994, 3995 },
						{ 3996, 3997, 3998, 3999 },
						{ 4000, 4001, 0, 0 },
						{ 0, 3978, 0, 0 },
					},
					{
						{ 4002, 4003, 4004, 0 },
						{ 4005, 4009, 4007, 4008 },
						{ 3983, 4013, 4010, 4011 },
						{ 4012, 4006, 4014, 4015 },
						{ 4016, 4017, 0, 0 },
						{ 0, 3985, 0, 0 },
					},
				}
			},
		}),
	}),
}

-- 更新最高玩家等级数据
RegisterEvent('PLAYER_ENTER_SCENE', function()
	CONSTANT.MAX_PLAYER_LEVEL = math.max(
		CONSTANT.MAX_PLAYER_LEVEL,
		X.GetClientPlayer().nMaxLevel
	)
end)

X.CONSTANT = setmetatable({}, { __index = CONSTANT, __newindex = function() end })

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
