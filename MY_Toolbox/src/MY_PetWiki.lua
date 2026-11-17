--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 宠物百科
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_PetWiki'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_PetWiki', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_PetWiki'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	nW = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_PetWiki'],
			_L['UI Width'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 850,
	},
	nH = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_PetWiki'],
			_L['UI Height'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 610,
	},
})
local D = {}

function D.OnWebSizeChange()
	if X.UI(this):FrameVisualState() == X.UI.FRAME_VISUAL_STATE.NORMAL then
		O.nW, O.nH = this:GetSize()
	end
end

function D.Open(dwPetIndex)
	local tPet = Table_GetFellowPet(dwPetIndex)
	if not tPet then
		return
	end
	local szURL = MY_RSS.PAGE_BASE_URL .. '/pet/' .. dwPetIndex .. '?'
		.. X.EncodeQuerystring(X.ConvertToUTF8({
			l = X.ENVIRONMENT.GAME_LANG,
			L = X.ENVIRONMENT.GAME_EDITION,
			player = X.GetClientPlayerName(),
		}))
	local szKey = 'PetsWiki_' .. dwPetIndex
	local szTitle = tPet.szName .. ' - ' .. X.XMLGetPureText(tPet.szDesc)
	szKey = X.UI.OpenBrowser(szURL, {
		key = szKey,
		title = szTitle,
		w = O.nW, h = O.nH,
		readonly = true,
	})
	X.UI(X.UI.LookupBrowser(szKey)):Size(D.OnWebSizeChange)
end

function D.HookPetFrame(frame)
	----------------
	-- 怀旧版
	----------------
	local hMyPets = frame:Lookup('PageSet_All/Page_MyPet/WndScroll_myPets', '')
	if hMyPets then
		local function OnPetItemLButtonClick()
			if O.bEnable and this.tPet and not IsCtrlKeyDown() and not IsAltKeyDown() and this:IsObjectSelected() then
				D.Open(this.tPet.dwPetIndex)
				return
			end
			return X.UI.FormatUIEventMask(false, true)
		end
		X.UI.HookHandleAppend(hMyPets, function(_, hMyPet)
			local hPets = hMyPet:Lookup('Handle_petsBox')
			X.DelayCall(function()
				if not hPets:IsValid() then
					return
				end
				X.UI.HookHandleAppend(hPets, function(_, hPet)
					X.DelayCall(function()
						if not hPet:IsValid() then
							return
						end
						local box = hPet:Lookup('Box_petItem')
						X.SetMemberFunctionHook(
							box,
							'OnItemLButtonClick',
							'MY_PetWiki',
							OnPetItemLButtonClick,
							{ bAfterOrigin = true, bPassReturn = true, bHookReturn = true })
						box:RegisterEvent(ITEM_EVENT.LBUTTONCLICK)
					end)
				end)
			end)
		end)
	end

	----------------
	-- 重制版
	----------------
	local hMedalPets = frame:Lookup('PageSet_All/Page_MedalCollected/Wnd_MedalCollect', 'Handle_MedalPets')
	if hMedalPets then
		local function OnPetItemLButtonClick()
			if O.bEnable and this.tPet and not IsCtrlKeyDown() and not IsAltKeyDown() and this:IsObjectSelected() then
				D.Open(this.tPet.dwPetIndex)
				return
			end
			return X.UI.FormatUIEventMask(false, true)
		end
		for nNum = 1, 10 do
			local hMedal = hMedalPets:Lookup('Handle_MedalPet_' .. nNum)
			if hMedal then
				for nIndex = 1, nNum do
					local boxPet = hMedal:Lookup('Box_MedalPet_' .. nNum .. '_' .. nIndex)
					if boxPet then
						X.SetMemberFunctionHook(
							boxPet,
							'OnItemLButtonClick',
							'MY_PetWiki',
							OnPetItemLButtonClick,
							{ bAfterOrigin = true, bPassReturn = true, bHookReturn = true })
						boxPet:RegisterEvent(ITEM_EVENT.LBUTTONCLICK)
					end
				end
			end
		end
	end

	local hPreferList = frame:Lookup('PageSet_All/Page_MyPet/WndScroll_Pets/WndContainer_Pets/Wnd_Prefer', '')
	if hPreferList then
		local function OnPetItemLButtonClick()
			if O.bEnable and this:GetParent().tPet and not IsCtrlKeyDown() and not IsAltKeyDown() and this:IsObjectSelected() then
				D.Open(this:GetParent().tPet.dwPetIndex)
				return
			end
			return X.UI.FormatUIEventMask(false, true)
		end
		for i = 0, hPreferList:GetItemCount() - 1 do
			local hBox = hPreferList:Lookup(i):Lookup('Box_Prefer')
			X.SetMemberFunctionHook(
				hBox,
				'OnItemLButtonClick',
				'MY_PetWiki',
				OnPetItemLButtonClick,
				{ bAfterOrigin = true, bPassReturn = true, bHookReturn = true })
			hBox:RegisterEvent(ITEM_EVENT.LBUTTONCLICK)
		end
	end

	local hPets = frame:Lookup('PageSet_All/Page_MyPet/WndScroll_Pets/WndContainer_Pets/Wnd_Pets', '')
	if hPets then
		local function OnPetItemLButtonClick()
			if O.bEnable and this.tPet and not IsCtrlKeyDown() and not IsAltKeyDown() and this:IsObjectSelected() then
				D.Open(this.tPet.dwPetIndex)
				return
			end
			return X.UI.FormatUIEventMask(false, true)
		end
		X.UI.HookHandleAppend(hPets, function(_, hGroup)
			local hList = hGroup and hGroup:Lookup((hGroup:GetName():gsub('Handle_Pets', 'Handle_List')))
			if not hList then
				return
			end
			X.UI.HookHandleAppend(hList, function(_, hItem)
				X.DelayCall(function()
					local boxPet = hItem:IsValid() and hItem:Lookup('Box_PetItem')
					if not boxPet then
						return
					end
					X.SetMemberFunctionHook(
						boxPet,
						'OnItemLButtonClick',
						'MY_PetWiki',
						OnPetItemLButtonClick,
						{ bAfterOrigin = true, bPassReturn = true, bHookReturn = true })
					boxPet:RegisterEvent(ITEM_EVENT.LBUTTONCLICK)
				end)
			end)
		end)
		local hList = hPets:Lookup('Handle_ListAcquired')
		if hList then
			X.UI.HookHandleAppend(hList, function(_, hItem)
				X.DelayCall(function()
					local boxPet = hItem:IsValid() and hItem:Lookup('Box_PetItem')
					if not boxPet then
						return
					end
					X.SetMemberFunctionHook(
						boxPet,
						'OnItemLButtonClick',
						'MY_PetWiki',
						OnPetItemLButtonClick,
						{ bAfterOrigin = true, bPassReturn = true, bHookReturn = true })
					boxPet:RegisterEvent(ITEM_EVENT.LBUTTONCLICK)
				end)
			end)
		end
	end
end

X.RegisterInit('MY_PetWiki', function()
	local frame = Station.Lookup('Normal/NewPet')
	if not frame then
		return
	end
	D.HookPetFrame(frame)
end)

X.RegisterFrameCreate('NewPet', 'MY_PetWiki', function(name, frame)
	D.HookPetFrame(frame)
end)

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Pet wiki'],
		tip = {
			render = _L['Click icon on pet panel to view pet wiki'],
			position = X.UI.TIP_POSITION.BOTTOM_TOP,
		},
		checked = MY_PetWiki.bEnable,
		onCheck = function(bChecked)
			MY_PetWiki.bEnable = bChecked
		end,
	}):Width() + 5
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_PetWiki',
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
MY_PetWiki = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
