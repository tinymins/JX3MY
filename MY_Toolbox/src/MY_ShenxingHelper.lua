--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 神行千里助手
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_ShenxingHelper'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
X.RegisterRestriction('MY_ShenxingHelper.AncientMap', { ['*'] = true, intl = false })
X.RegisterRestriction('MY_ShenxingHelper.OpenAllMap', { ['*'] = true, intl = false })
X.RegisterRestriction('MY_ShenxingHelper.AvoidBlackCD', { ['*'] = false, remake = true })
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_ShenxingHelper', _L['General'], {
	bAncientMap = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_ShenxingHelper'],
			_L['Shenxing to ancient maps'],
		}),
		szRestriction = 'MY_ShenxingHelper.AncientMap',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bOpenAllMap = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_ShenxingHelper'],
			_L['Force open all map shenxing'],
		}),
		szRestriction = 'MY_ShenxingHelper.OpenAllMap',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	bAvoidBlackCD = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_ShenxingHelper'],
			_L['Avoid blacking shenxing cd'],
		}),
		szRestriction = 'MY_ShenxingHelper.AvoidBlackCD',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}

local NONWAR_DATA = {
	{ id =  8, x =   70, y =    5 }, -- 洛阳
	{ id = 11, x =  170, y = -160 }, -- 天策
	{ id = 12, x = -150, y =  110 }, -- 枫华
	{ id = 15, x = -450, y =   65 }, -- 长安
	{ id = 26, x =  -20, y =   90 }, -- 荻花宫
	{ id = 32, x =   50, y =   45 }, -- 小战宝
}

--------------------------------------------------------------------------
-- 【台服用】老地图神行
--------------------------------------------------------------------------
function D.HookNonwarMap()
	local h = Station.Lookup('Topmost1/WorldMap/Wnd_All', 'Handle_CopyBtn')
	if not h or h.__MY_NonwarData then
		return
	end
	local me = X.GetClientPlayer()
	if not me then
		return
	end
	for i = 0, h:GetItemCount() - 1 do
		local m = h:Lookup(i)
		if m and m.mapid == 160 then
			local _w, _ = m:GetSize()
			local fS = m.w / _w
			for _, v in ipairs(NONWAR_DATA) do
				local bOpen = me.GetMapVisitFlag(v.id)
				local szFile, nFrame = 'ui/Image/MiddleMap/MapWindow.UITex', 41
				if bOpen then
					nFrame = 98
				end
				h:AppendItemFromString('<image>name="mynw_' .. v.id .. '" path='..EncodeComponentsString(szFile)..' frame='..nFrame..' eventid=341</image>')
				local img = h:Lookup(h:GetItemCount() - 1)
				img.bMYNonwar = true
				img.bEnable = bOpen
				img.bSelect = bOpen and v.id ~= 26 and v.id ~= 32
				img.x = m.x + v.x
				img.y = m.y + v.y
				img.w, img.h = m.w, m.h
				img.id, img.mapid = v.id, v.id
				img.middlemapindex = 0
				img.name = Table_GetMapName(img.mapid)
				img.city = img.name
				img.button = m.button
				img.copy = true
				img.OnItemMouseEnter = function()
					img:SetAlpha(255)
					return X.UI.FormatUIEventMask(true, true)
				end
				img.OnItemMouseLeave = function()
					img:SetAlpha(200)
					return X.UI.FormatUIEventMask(true, true)
				end
				img:SetAlpha(200)
				img:SetSize(img.w / fS, img.h / fS)
				img:SetRelPos(img.x / fS - (img.w / fS / 2), img.y / fS - (img.h / fS / 2))
			end
			h:FormatAllItemPos()
			break
		end
	end
	h.__MY_NonwarData = true
end

function D.UnhookNonwarMap()
	local h = Station.Lookup('Topmost1/WorldMap/Wnd_All', 'Handle_CopyBtn')
	if not h or not h.__MY_NonwarData then
		return
	end
	for i = h:GetItemCount() - 1, 0, -1 do
		local m = h:Lookup(i)
		if m.bMYNonwar then
			h:RemoveItem(m)
		end
	end
	h.__MY_NonwarData = nil
end

function D.CheckNonwarMapEnable()
	if D.bReady and O.bAncientMap and not X.IsRestricted('MY_ShenxingHelper') then
		D.HookNonwarMap()
	else
		D.UnhookNonwarMap()
	end
end
X.RegisterFrameCreate('WorldMap', 'MY_ShenxingHelper__NonwarMap', D.CheckNonwarMapEnable)

--------------------------------------------------------------------------
-- 【台服用】强开所有地图
--------------------------------------------------------------------------
function D.HookOpenAllMap()
	local h = Station.Lookup('Topmost1/WorldMap/Wnd_All', '')
	if not h then
		return
	end
	local me = X.GetClientPlayer()
	local dwCurrMapID = me and me.GetScene().dwMapID
	for _, szHandleName in ipairs({ 'Handle_CityBtn', 'Handle_CopyBtn' }) do
		local hList = h:Lookup(szHandleName)
		if hList then
			for i = 0, hList:GetItemCount() - 1 do
				local hItem = hList:Lookup(i)
				if hItem.dwMYMapID == nil then
					hItem.dwMYMapID = hItem.mapid
				end
				if hItem.bMYEnable == nil then
					hItem.bMYEnable = hItem.bEnable
				end
				if hItem.mapid == 1 or dwCurrMapID == hItem.mapid then
					hItem.mapid = tostring(hItem.mapid)
				else
					hItem.mapid = tonumber(hItem.mapid) or hItem.mapid
				end
				hItem.bEnable = true
			end
		end
	end
end

function D.UnhookOpenAllMap()
	local h = Station.Lookup('Topmost1/WorldMap/Wnd_All', '')
	if not h then
		return
	end
	for _, szHandleName in ipairs({ 'Handle_CityBtn', 'Handle_CopyBtn' }) do
		local hList = h:Lookup(szHandleName)
		if hList then
			for i = 0, hList:GetItemCount() - 1 do
				local hItem = hList:Lookup(i)
				if hItem.dwMYMapID ~= nil then
					hItem.mapid = hItem.dwMYMapID
					hItem.dwMYMapID = nil
				end
				if hItem.bMYEnable ~= nil then
					hItem.bEnable = hItem.bMYEnable
					hItem.bMYEnable = nil
				end
			end
		end
	end
end

function D.CheckOpenAllMapEnable()
	if D.bReady and O.bOpenAllMap and not X.IsRestricted('MY_ShenxingHelper') then
		X.RegisterEvent({
			'LOADING_END',
			'UPDATE_ROAD_TRACK_FORCE',
			'UPDATE_ROUTE_NODE_OPEN_LIST',
			'ON_MAP_VISIT_FLAG_CHANGED',
			'SYNC_ROLE_DATA_END',
			'PLAYER_LEVEL_UPDATE',
		}, 'MY_AutoMemorizeBook', D.HookOpenAllMap)
		X.DelayCall('MY_ShenxingHelper__HookOpenAllMap', 200, D.HookOpenAllMap)
		D.HookOpenAllMap()
	else
		X.RegisterEvent({
			'LOADING_END',
			'UPDATE_ROAD_TRACK_FORCE',
			'UPDATE_ROUTE_NODE_OPEN_LIST',
			'ON_MAP_VISIT_FLAG_CHANGED',
			'SYNC_ROLE_DATA_END',
			'PLAYER_LEVEL_UPDATE',
		}, 'MY_ShenxingHelper__OpenAllMap', false)
		X.DelayCall('MY_ShenxingHelper__HookOpenAllMap', false)
		D.UnhookOpenAllMap()
	end
end
X.RegisterFrameCreate('WorldMap', 'MY_ShenxingHelper__OpenAllMap', D.CheckOpenAllMapEnable)

--------------------------------------------------------------------------
-- 防止神行CD被黑
--------------------------------------------------------------------------
function D.CheckAvoidBlackShenxingEnable()
	if D.bReady and O.bAvoidBlackCD and not X.IsRestricted('MY_ShenxingHelper.AvoidBlackCD') then
		X.RegisterEvent('DO_SKILL_CAST', 'MY_AvoidBlackShenxingCD', function()
			local dwID, dwSkillID, dwSkillLevel = arg0, arg1, arg2
			if not(X.GetClientPlayerID() == dwID and
			Table_IsSkillFormationCaster(dwSkillID, dwSkillLevel)) then
				return
			end
			local player = X.GetClientPlayer()
			if not player then
				return
			end

			local nType, dwSkillID, dwSkillLevel, fProgress = X.GetCharacterOTActionState(player)
			if not ((
				nType == X.CONSTANT.CHARACTER_OTACTION_TYPE.ACTION_SKILL_PREPARE
				or nType == X.CONSTANT.CHARACTER_OTACTION_TYPE.ACTION_SKILL_CHANNEL
				or nType == X.CONSTANT.CHARACTER_OTACTION_TYPE.ANCIENT_ACTION_PREPARE
			) and dwSkillID == 3691) then
				return
			end
			X.OutputSystemMessage(_L['Shenxing has been cancelled, cause you got the zhenyan.'])
			player.StopCurrentAction()
		end)
	else
		X.RegisterEvent('DO_SKILL_CAST', 'MY_AvoidBlackShenxingCD')
	end
end

--------------------------------------------------------------------------
-- 模块事件监听
--------------------------------------------------------------------------
function D.CheckEnable()
	D.CheckNonwarMapEnable()
	D.CheckOpenAllMapEnable()
	D.CheckAvoidBlackShenxingEnable()
end

function D.RemoveHook()
	D.UnhookNonwarMap()
	D.UnhookOpenAllMap()
end

--------------------------------------------------------------------------
-- 设置界面
--------------------------------------------------------------------------
function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	if not X.IsRestricted('MY_ShenxingHelper.AvoidBlackCD') then
		nX = nX + ui:Append('WndCheckBox', {
			x = nX, y = nY, w = 'auto',
			text = _L['Avoid blacking shenxing cd'],
			tip = {
				render = _L['Got zhenyan wen shenxing, your shengxing will be blacked.'],
				position = X.UI.TIP_POSITION.BOTTOM_TOP,
			},
			checked = MY_ShenxingHelper.bAvoidBlackCD,
			onCheck = function(bChecked)
				MY_ShenxingHelper.bAvoidBlackCD = bChecked
			end,
		}):Width() + 5
	end

	if not X.IsRestricted('MY_ShenxingHelper.AncientMap') then
		nX = nX + ui:Append('WndCheckBox', {
			x = nX, y = nY, w = 'auto',
			text = _L['Shenxing to ancient maps'],
			checked = MY_ShenxingHelper.bAncientMap,
			onCheck = function(bChecked)
				MY_ShenxingHelper.bAncientMap = bChecked
			end,
		}):Width() + 5
	end

	if not X.IsRestricted('MY_ShenxingHelper.OpenAllMap') then
		nX = nX + ui:Append('WndCheckBox', {
			x = nX, y = nY, w = 'auto',
			text = _L['Force open all map shenxing'],
			tip = {
				render = _L['Shenxing can fly to undiscovered maps'],
				position = X.UI.TIP_POSITION.BOTTOM_TOP,
			},
			checked = MY_ShenxingHelper.bOpenAllMap,
			onCheck = function(bChecked)
				MY_ShenxingHelper.bOpenAllMap = bChecked
			end,
		}):Width() + 5
	end

	nX = nPaddingX
	nY = nY + nLH
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_ShenxingHelper',
	exports = {
		{
			fields = {
				'OnPanelActivePartial',
			},
			root = D,
		},
		{
			fields = {
				'bAncientMap',
				'bOpenAllMap',
				'bAvoidBlackCD',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bAncientMap',
				'bOpenAllMap',
				'bAvoidBlackCD',
			},
			triggers = {
				bAncientMap = D.CheckNonwarMapEnable,
				bOpenAllMap = D.CheckOpenAllMapEnable,
				bAvoidBlackCD = D.CheckAvoidBlackShenxingEnable,
			},
			root = O,
		},
	},
}
MY_ShenxingHelper = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterEvent('MY_RESTRICTION', 'MY_ShenxingHelper', function()
	if arg0 and arg0 ~= 'MY_ShenxingHelper' then
		return
	end
	D.CheckEnable()
end)
X.RegisterUserSettingsInit('MY_ShenxingHelper', function()
	D.bReady = true
	D.CheckEnable()
end)
X.RegisterReload('MY_ShenxingHelper', D.RemoveHook)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
