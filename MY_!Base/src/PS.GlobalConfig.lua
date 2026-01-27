--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 全局杂项设置
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) MY
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/PS.GlobalConfig')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. 'lang/PS/')
--------------------------------------------------------------------------------

local PS = {}

function PS.OnPanelActive(wnd)
	local ui = X.UI(wnd)
	local W, H = ui:Size()
	local nPaddingX, nPaddingY, LH = 20, 20, 30
	local nX, nY, nLFY = nPaddingX, nPaddingY, nPaddingY

	ui:Append('Text', {
		x = nPaddingX - 10, y = nY,
		text = _L['Distance type'],
		color = { 255, 255, 0 },
	}):AutoWidth()
	nX, nY = nPaddingX, nY + 30

	for _, p in ipairs(X.GetDistanceTypeList()) do
		nX = nX + ui:Append('WndRadioBox', {
			x = nX, y = nY, w = 100, h = 25, group = 'distance type',
			text = p.szText,
			checked = X.GetGlobalDistanceType() == p.szType,
			onCheck = function(bChecked)
				if not bChecked then
					return
				end
				X.SetGlobalDistanceType(p.szType)
			end,
		}):AutoWidth():Width() + 10
	end
	nX, nY = nPaddingX, nY + 30
	nLFY = nY

	local Notify = _G[X.NSFormatString('{$NS}_Notify')]
	if Notify then
		nX, nY, nLFY = Notify.OnPanelActivePartial(ui, nPaddingX, nPaddingY, W, H, LH, nX, nY, nLFY)
	end

	local HoverEntry = _G[X.NSFormatString('{$NS}_HoverEntry')]
	if HoverEntry then
		nX, nY, nLFY = HoverEntry.OnPanelActivePartial(ui, nPaddingX, nPaddingY, W, H, LH, nX, nY, nLFY)
	end

	local FloatBar = _G[X.NSFormatString('{$NS}_FloatBar')]
	if FloatBar then
		nX, nY, nLFY = FloatBar.OnPanelActivePartial(ui, nPaddingX, nPaddingY, W, H, LH, nX, nY, nLFY)
	end

	nX, nY = nPaddingX, nY + 30
	nLFY = nY

	ui:Append('Text', {
		x = nPaddingX - 10, y = nY,
		text = _L['User Settings'],
		color = { 255, 255, 0 },
	}):AutoWidth()
	nX, nY = nPaddingX, nY + 30

	nX = nX + ui:Append('WndComboBox', {
		x = nX, y = nY, h = 30,
		text = _L['Use preset user settings'],
		menu = function()
			local szCurrentID = X.GetUserSettingsPresetID()
			local szDefaultID = X.GetUserSettingsPresetID(true)
			local menu = {
				{
					szOption = _L['Role original user settings'],
					fnAction = function()
						X.SetUserSettingsPresetID('')
						X.UI.ClosePopupMenu()
						X.Panel.SwitchTab('GlobalConfig', true)
					end,
					bCheck = true, bChecked = szCurrentID == '',
					{
						szOption = _L['Set default preset'],
						fnAction = function()
							X.SetUserSettingsPresetID('', true)
							X.UI.ClosePopupMenu()
							X.Panel.SwitchTab('GlobalConfig', true)
						end,
						bCheck = true, bChecked = szDefaultID == '',
					},
				},
				X.CONSTANT.MENU_DIVIDER,
			}
			local aPresetID = X.GetUserSettingsPresetList()
			if not X.IsEmpty(aPresetID) then
				table.insert(menu, { szOption = _L['Preset list'], bDisable = true })
				for _, szID in ipairs(aPresetID) do
					local m = {
						szOption = szID,
						fnAction = function()
							X.SetUserSettingsPresetID(szID)
							X.UI.ClosePopupMenu()
							X.Panel.SwitchTab('GlobalConfig', true)
						end,
						bCheck = true, bChecked = szCurrentID == szID,
						{
							szOption = _L['Set default preset'],
							fnAction = function()
								X.SetUserSettingsPresetID(szID, true)
								X.UI.ClosePopupMenu()
								X.Panel.SwitchTab('GlobalConfig', true)
							end,
							bCheck = true, bChecked = szDefaultID == szID,
						},
					}
					if m.bChecked then
						table.insert(m, {
							szOption = _L['Reconnect'],
							fnAction = function()
								X.ReleaseUserSettingsDB()
								X.ConnectUserSettingsDB()
								X.UI.ClosePopupMenu()
								X.Panel.SwitchTab('GlobalConfig', true)
							end,
						})
					else
						table.insert(m, {
							szOption = _L['Delete'],
							fnAction = function()
								X.RemoveUserSettingsPreset(szID)
								X.UI.ClosePopupMenu()
							end,
						})
					end
					table.insert(menu, m)
				end
				table.insert(menu, X.CONSTANT.MENU_DIVIDER)
			end
			table.insert(menu, {
				szOption = _L['* New *'],
				fnAction = function()
					GetUserInput(
						_L['Please input preset id:'],
						function(szText)
							local szErrmsg = X.SetUserSettingsPresetID(szText)
							if szErrmsg then
								X.OutputSystemAnnounceMessage(szErrmsg, X.CONSTANT.MSG_THEME.ERROR)
								X.Alert(szErrmsg)
							end
						end,
						nil, nil, nil, 'common')
				end,
			})
			return menu
		end,
		tip = {
			render = _L['PRESET_DESC'],
			position = X.UI.TIP_POSITION.TOP_BOTTOM,
		},
	}):AutoWidth():Width() + 5

	nX = nX + ui:Append('WndButtonBox', {
		x = nX, y = nY, h = 30,
		text = _L['Location override'],
		onClick = function()
			X.OpenUserSettingsLocationOverridePanel()
		end,
	}):AutoWidth():Width() + 5

	nX = nX + ui:Append('WndButtonBox', {
		x = nX, y = nY, h = 30,
		text = _L['Export data'],
		onClick = function()
			X.OpenUserSettingsExportPanel()
		end,
	}):AutoWidth():Width() + 5

	nX = nX + ui:Append('WndButtonBox', {
		x = nX, y = nY, h = 30,
		text = _L['Import data'],
		onClick = function()
			X.OpenUserSettingsImportPanel()
		end,
	}):AutoWidth():Width() + 5

	nX = nX + ui:Append('WndButtonBox', {
		x = nX, y = nY, h = 30,
		text = _L['Backup folder'],
		onClick = function()
			X.OpenFolder(X.GetAbsolutePath({'export/settings/', X.PATH_TYPE.GLOBAL}))
		end,
	}):AutoWidth():Width() + 5
	nX, nY = nPaddingX, nY + 35

	ui:Append('Text', {
		x = nPaddingX - 10, y = nY,
		text = _L['System Info'],
		color = { 255, 255, 0 },
	}):AutoWidth()
	nY = nY + 40

	local uiMemory = ui:Append('Text', {
		x = nX, y = nY, w = W - nX - nPaddingX,
		alpha = 150, font = 162,
	})
	nY = nY + 25

	local uiSize = ui:Append('Text', {
		x = nX, y = nY, w = W - nX - nPaddingX,
		alpha = 150, font = 162,
	})
	nY = nY + 25

	local uiUIScale = ui:Append('Text', {
		x = nX, y = nY, w = W - nX - nPaddingX,
		alpha = 150, font = 162,
	})
	nY = nY + 25

	local uiFontScale = ui:Append('Text', {
		x = nX, y = nY, w = W - nX - nPaddingX,
		alpha = 150, font = 162,
	})
	nY = nY + 25

	local function onRefresh()
		uiMemory:Text(string.format('Memory: %.2fMB', collectgarbage('count') / 1024))
		uiSize:Text(string.format('UISize: %.2fx%.2f', Station.GetClientSize()))
		uiUIScale:Text(string.format('UIScale: %.2f (%.2f)', X.GetUIScale(), X.GetOriginUIScale()))
		uiFontScale:Text(string.format('FontScale: %.2f (%.2f)', X.GetFontScale(), Font.GetOffset()))
	end
	onRefresh()
	X.BreatheCall('GlobalConfig', onRefresh)
end

function PS.OnPanelDeactive()
	X.BreatheCall('GlobalConfig', false)
end

X.Panel.Register(_L['System'], 'GlobalConfig', _L['GlobalConfig'], 'ui\\Image\\Minimap\\Minimap.UITex|181', PS)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
