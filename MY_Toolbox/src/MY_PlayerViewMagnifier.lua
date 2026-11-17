--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : ÊÔÒÂ¼ä
-- @author   : ÜøÒÁ @Ë«ÃÎÕò @×··çõæÓ°
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_PlayerViewMagnifier'
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

local function onFrameCreate()
	local config
	if arg0:GetName() == 'PlayerView' then
		config = X.UI.IS_GLASSMORPHISM
			and { x = 30, y = 3, w = 25, h = 25 }
			or { x = 35, y = 8, w = 30, h = 30 }
	elseif arg0:GetName() == 'ExteriorView' then
		config = X.UI.IS_GLASSMORPHISM
			and { x = 15, y = 3, w = 25, h = 25 }
			or { x = 20, y = 15, w = 40, h = 40 }
	end
	if config then
		local frame, ui, nOriX, nOriY, nOriW, nOriH = arg0, X.UI(arg0), 0, 0, 0, 0
		local function Fullscreen()
			local nCurrentW, nCurrentH = ui:Size()
			local nClientW, nClientH = Station.GetClientSize()
			local fCoefficient = math.min(nClientW / nCurrentW, nClientH / nCurrentH)
			local fAbsCoefficient = nCurrentW / nOriW * fCoefficient
			frame:EnableDrag(true)
			frame:SetDragArea(0, 0, frame:GetW(), 50 * fAbsCoefficient)
			frame:Scale(fCoefficient, fCoefficient)
			ui:Find('.Text'):FontScale(fAbsCoefficient)
			frame:SetPoint('CENTER', 0, 0, 'CENTER', 0, 0)
		end
		ui:AppendFromIni(PLUGIN_ROOT .. '/ui/Btn_MagnifierUp.ini', 'Btn_MagnifierUp', {
			name = 'Btn_MY_MagnifierUp',
			x = config.x, y = config.y, w = config.w, h = config.h,
			onClick = function()
				nOriX, nOriY = ui:Pos()
				nOriW, nOriH = ui:Size()
				Fullscreen()
				ui:Children('#Btn_MY_MagnifierUp'):Hide()
				ui:Children('#Btn_MY_MagnifierDown'):Show()
			end,
			tip = _L['Click to enable MY player view magnifier'],
		})
		ui:AppendFromIni(X.PACKET_INFO.ROOT .. 'MY_Toolbox/ui/Btn_MagnifierDown.ini', 'Btn_MagnifierDown', {
			name = 'Btn_MY_MagnifierDown',
			x = config.x, y = config.y, w = config.w, h = config.h, visible = false,
			onClick = function()
				local nCW, nCH = ui:Size()
				local fCoefficient = nOriW / nCW
				frame:Scale(fCoefficient, fCoefficient)
				ui:Pos(nOriX, nOriY)
				ui:Find('.Text'):FontScale(1)
				ui:Children('#Btn_MY_MagnifierUp'):Show()
				ui:Children('#Btn_MY_MagnifierDown'):Hide()
				nOriX, nOriY, nOriW, nOriH = nil
			end,
			tip = _L['Click to disable MY player view magnifier'],
		})
		if X.UI.IS_GLASSMORPHISM then
			X.UI.SetButtonUITex(
				ui:Children('#Btn_MY_MagnifierUp'):Raw(),
				'ui\\Image\\UItimate\\UICommon\\Button2.UITex',
				37,
				38,
				39,
				40
			)
			X.UI.SetButtonUITex(
				ui:Children('#Btn_MY_MagnifierDown'):Raw(),
				'ui\\Image\\UItimate\\UICommon\\Button2.UITex',
				41,
				42,
				43,
				44
			)
		end
		X.RegisterEvent('UI_SCALED', 'MY_PlayerViewMagnifier' .. arg0:GetName(), function()
			if not frame or not frame:IsValid() then
				return 0
			end
			if X.IsEmpty(nOriX) or X.IsEmpty(nOriY) or X.IsEmpty(nOriW) or X.IsEmpty(nOriH) then
				return
			end
			Fullscreen()
		end)
	end
end
X.RegisterFrameCreate('PlayerView', 'MY_PlayerViewMagnifier', onFrameCreate)
X.RegisterFrameCreate('ExteriorView', 'MY_PlayerViewMagnifier', onFrameCreate)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
