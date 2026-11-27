--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 名剑大会自动切换团队频道
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_ArenaHelper'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
X.RegisterRestriction('MY_ArenaHelper.bAutoShowModel', { remake = true })
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_ArenaHelper', _L['General'], {
	bRestoreAuthorityInfo = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_ArenaHelper'],
			_L['Auto restore team info in arena'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bAutoShowModel = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_ArenaHelper'],
			_L['Auto cancel hide player in arena'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
		szRestriction = 'MY_ArenaHelper.bAutoShowModel',
	},
	bAutoShowModelBattlefield = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_ArenaHelper'],
			_L['Auto cancel hide player in battlefield'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bAutoShowModelPubg = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_ArenaHelper'],
			_L['Auto cancel hide player in pubg'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
})
local D = {}

-- auto restore team authourity info in arena
do local l_tTeamInfo, l_bConfigEnd
X.RegisterEvent('ARENA_START', function() l_bConfigEnd = true end)
X.RegisterEvent('LOADING_ENDING', function() l_bConfigEnd = false end)
X.RegisterEvent('PARTY_DELETE_MEMBER', function() l_bConfigEnd = false end)
local function RestoreTeam()
	local me, team = X.GetClientPlayer(), GetClientTeam()
	if not l_tTeamInfo
	or not O.bRestoreAuthorityInfo
	or not X.IsClientPlayerTeamLeader()
	or not me.IsInParty() or not X.IsInArenaMap() then
		return
	end
	X.SetTeamInfo(l_tTeamInfo)
end
X.RegisterEvent('PARTY_ADD_MEMBER', RestoreTeam)

local function SaveTeam()
	local me, team = X.GetClientPlayer(), GetClientTeam()
	if not me.IsInParty() or not X.IsInArenaMap() or l_bConfigEnd then
		return
	end
	l_tTeamInfo = X.GetTeamInfo()
end
X.RegisterEvent({'TEAM_AUTHORITY_CHANGED', 'PARTY_SET_FORMATION_LEADER', 'TEAM_CHANGE_MEMBER_GROUP'}, SaveTeam)
end

-- 进入JJC自动显示所有人物
do
local l_bShowNpc, l_bShowPlayer, l_bShowPartyOverride
X.RegisterEvent('LOADING_END', 'MY_ArenaHelper_ShowTargetModel', function()
	if not O.bAutoShowModel and not O.bAutoShowModelBattlefield and not O.bAutoShowModelPubg then
		return
	end
	local bHasValue = X.IsBoolean(l_bShowNpc) and X.IsBoolean(l_bShowPlayer) and X.IsBoolean(l_bShowPartyOverride)
	if (X.IsInArenaMap() and O.bAutoShowModel and not X.IsRestricted('MY_ArenaHelper.bAutoShowModel'))
	or (X.IsInBattlefieldMap() and O.bAutoShowModelBattlefield)
	or (X.IsInPubgMap() and O.bAutoShowModelPubg) then
		if not bHasValue then
			l_bShowNpc = X.GetNpcVisibility()
			l_bShowPlayer, l_bShowPartyOverride = X.GetPlayerVisibility()
			X.SetNpcVisibility(true)
			X.SetPlayerVisibility(true, true)
		end
	elseif bHasValue then
		X.SetNpcVisibility(l_bShowNpc)
		X.SetPlayerVisibility(l_bShowPlayer, l_bShowPartyOverride)
		l_bShowNpc, l_bShowPlayer, l_bShowPartyOverride = nil, nil, nil
	end
end)
X.RegisterReload('MY_ArenaHelper_ShowTargetModel', function()
	local bHasValue = X.IsBoolean(l_bShowNpc) and X.IsBoolean(l_bShowPlayer) and X.IsBoolean(l_bShowPartyOverride)
	if not bHasValue then
		return
	end
	X.SetNpcVisibility(l_bShowNpc)
	X.SetPlayerVisibility(l_bShowPlayer, l_bShowPartyOverride)
end)
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	-- 名剑大会自动恢复队伍信息
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Auto restore team info in arena'],
		checked = MY_ArenaHelper.bRestoreAuthorityInfo,
		onCheck = function(bChecked)
			MY_ArenaHelper.bRestoreAuthorityInfo = bChecked
		end,
	}):Width() + 5

	-- 名剑大会自动取消屏蔽
	if not X.IsRestricted('MY_ArenaHelper.bAutoShowModel') then
		nX = nX + ui:Append('WndCheckBox', {
			x = nX, y = nY, w = 'auto',
			text = _L['Auto cancel hide player in arena'],
			checked = MY_ArenaHelper.bAutoShowModel,
			onCheck = function(bChecked)
				MY_ArenaHelper.bAutoShowModel = bChecked
			end,
		}):Width() + 5
	end

	nY = nY + nLH
	nX = nPaddingX

	-- 战场自动取消屏蔽
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Auto cancel hide player in battlefield'],
		checked = MY_ArenaHelper.bAutoShowModelBattlefield,
		onCheck = function(bChecked)
			MY_ArenaHelper.bAutoShowModelBattlefield = bChecked
		end,
	}):Width() + 5

	-- 自动取消屏蔽
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Auto cancel hide player in pubg'],
		checked = MY_ArenaHelper.bAutoShowModelPubg,
		onCheck = function(bChecked)
			MY_ArenaHelper.bAutoShowModelPubg = bChecked
		end,
	}):Width() + 5

	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_ArenaHelper',
	exports = {
		{
			fields = {
				'OnPanelActivePartial',
			},
			root = D,
		},
		{
			fields = {
				'bRestoreAuthorityInfo',
				'bAutoShowModel',
				'bAutoShowModelBattlefield',
				'bAutoShowModelPubg',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bRestoreAuthorityInfo',
				'bAutoShowModel',
				'bAutoShowModelBattlefield',
				'bAutoShowModelPubg',
			},
			root = O,
		},
	},
}
MY_ArenaHelper = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
