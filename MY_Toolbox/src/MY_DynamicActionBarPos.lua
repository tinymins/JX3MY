--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 记住动态技能栏上次位置
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_DynamicActionBarPos'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_DynamicActionBarPos'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_DynamicActionBarPos', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_DynamicActionBarPos'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
	tAnchors = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_DynamicActionBarPos'],
			_L['UI Anchor'],
		}),
		xSchema = X.Schema.Map(X.Schema.String, X.Schema.FrameAnchor),
		xDefaultValue = {},
	},
})
local D = {}

local HOOK_FRAME_NAME = {
	'DynamicActionBar', -- 各种动态技能栏
	'IdentityDynActBar', -- 身份开启栏
}

local REMPOS_FRAME_TYPE = X.FlipObjectKV({
	'DynamicMutualBar',
	'DynamicActionBar2', -- 右下角特殊技能栏
	-- 'DynamicPetBar', -- 御兽技能栏
	-- 'DynamicCarrierBar', -- 射箭塔技能栏
	-- 'DashBoard',
	'IdentityDynActBar',
})

function D.UpdateAnchor(szName)
	local frame = X.UI.LookupFrame(szName)
	if not frame then
		return
	end
	local szType = D.GetFrameType(frame)
	if not szType or not REMPOS_FRAME_TYPE[szType] then
		return
	end
	local an = O.tAnchors[szType]
	if not an then
		return
	end
	if frame.__MY_SetPoint then
		frame:__MY_SetPoint(an.s, 0, 0, an.r, an.x, an.y)
	else
		frame:SetPoint(an.s, 0, 0, an.r, an.x, an.y)
	end
	frame:CorrectPos()
end

function D.SaveAnchor(szName)
	local frame = X.UI.LookupFrame(szName)
	if not frame then
		return
	end
	local szType = D.GetFrameType(frame)
	if not szType or not REMPOS_FRAME_TYPE[szType] then
		return
	end
	O.tAnchors[szType] = GetFrameAnchor(frame, 'TOP_LEFT')
	O.tAnchors = O.tAnchors
end

function D.GetFrameType(frame)
	if frame:GetName() == 'DynamicActionBar' then
		local el = frame:Lookup('Wnd_Left', 'Image_Leftbg')
		if el then
			local szImage, nFrame = el:GetImagePath()
			if szImage:lower() == 'ui\\image\\jianghu\\jianghu06.uitex' and nFrame == 1 then
				return 'DynamicActionBar2'
			end
		end
		if frame:Lookup('Wnd_Left', 'Handle_Pet/Box_Pet') then
			return 'DynamicPetBar'
		end
	end
	return frame:GetName()
end

function D.Hook(szName)
	local function OnFrameCreate(frame)
		if not frame then
			return
		end
		local szType = D.GetFrameType(frame)
		if not REMPOS_FRAME_TYPE[szType] then
			return
		end
		if not frame.__MY_OnFrameDragEnd then
			frame.__MY_OnFrameDragEnd = frame.OnFrameDragEnd
			frame.OnFrameDragEnd = function()
				D.SaveAnchor(szName)
			end
		end
		if not frame.__MY_SetPoint then
			frame.__MY_SetPoint = frame.SetPoint
			frame.SetPoint = function(...)
				if X.IsEmpty(O.tAnchors[szType]) then
					frame.__MY_SetPoint(...)
				end
			end
		end
	end
	X.RegisterFrameCreate(szName, 'MY_DynamicActionBarPos', function()
		OnFrameCreate(arg0)
		D.UpdateAnchor(szName)
	end)
	X.RegisterFrameCreate('UI_SCALED', 'MY_DynamicActionBarPos__' .. szName, function()
		D.UpdateAnchor(szName)
	end)
	X.RegisterEvent('ON_LEAVE_CUSTOM_UI_MODE', 'MY_DynamicActionBarPos__' .. szName, function()
		D.SaveAnchor(szName)
	end)
	OnFrameCreate(X.UI.LookupFrame(szName))
end

function D.Unhook(szName)
	local frame = X.UI.LookupFrame(szName)
	if frame then
		if frame.__MY_OnFrameDragEnd then
			frame.OnFrameDragEnd = frame.__MY_OnFrameDragEnd
			frame.__MY_OnFrameDragEnd = nil
		end
		if frame.__MY_SetPoint then
			frame.SetPoint = frame.__MY_SetPoint
			frame.__MY_SetPoint = nil
		end
	end
	X.RegisterFrameCreate(szName, 'MY_DynamicActionBarPos', false)
	X.RegisterFrameCreate('UI_SCALED', 'MY_DynamicActionBarPos__' .. szName, false)
	X.RegisterEvent('ON_LEAVE_CUSTOM_UI_MODE', 'MY_DynamicActionBarPos__' .. szName, false)
end

function D.CheckEnable()
	for _, szName in ipairs(HOOK_FRAME_NAME) do
		if D.bReady and O.bEnable then
			D.Hook(szName)
		else
			D.Unhook(szName)
		end
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, nLH)
	ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 130,
		text = _L['Restore dynamic action bar pos'],
		checked = MY_DynamicActionBarPos.bEnable,
		onCheck = function()
			MY_DynamicActionBarPos.bEnable = not MY_DynamicActionBarPos.bEnable
		end,
	}):AutoWidth()
	nY = nY + nLH
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_DynamicActionBarPos',
	exports = {
		{
			fields = {
				'OnPanelActivePartial',
			},
			root = D,
		},
		{
			fields = {
				'bEnable',
				'tAnchors',
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bEnable',
				'tAnchors',
			},
			triggers = {
				bEnable = D.CheckEnable,
			},
			root = O,
		},
	},
}
MY_DynamicActionBarPos = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_DynamicActionBarPos', function()
	D.bReady = true
	D.CheckEnable()
end)

X.RegisterReload('MY_DynamicActionBarPos', function()
	for _, szName in ipairs(HOOK_FRAME_NAME) do
		D.Unhook(szName)
	end
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
