--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 欢迎页
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) MY
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/PS.Welcome')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. 'lang/PS/')
--------------------------------------------------------------------------------

local D = {}
local PS = { bWelcome = true, bHide = true }

local function GetMemoryText()
	return string.format('Memory:%.1fMB', collectgarbage('count') / 1024)
end

local function GetAdvText()
	local me = X.GetClientPlayer()
	if not me then
		return ''
	end
	return _L('%s, welcome to use %s!', me.szName, X.PACKET_INFO.NAME)
end

local function GetSvrText()
	local nFeeTime = X.GetTimeOfFee() - GetCurrentTime()
	local szFeeTime = nFeeTime > 0
		and _L('Fee left %s', X.FormatDuration(nFeeTime, 'CHINESE', { accuracyUnit = X.ENVIRONMENT.GAME_BRANCH == 'classic' and 'hour' or nil }))
		or _L['Fee left unknown']
	return X.GetRegionName() .. '::' .. X.GetServerName()
		.. ' (' .. X.GetRegionOriginName() .. '::' .. X.GetServerOriginName() .. ')'
		.. g_tStrings.STR_CONNECT
		.. szFeeTime
end

function PS.OnPanelActive(wnd)
	local ui = X.UI(wnd)
	local nW, nH = ui:Size()
	local nPosterIndex = D.nPosterIndex
		and (GetTime() % #X.PACKET_INFO.POSTER_IMAGE_LIST + 1)
		or (#X.PACKET_INFO.POSTER_IMAGE_LIST)
	if nPosterIndex == D.nPosterIndex then
		nPosterIndex = (nPosterIndex + 1) % #X.PACKET_INFO.POSTER_IMAGE_LIST + 1
	end
	D.nPosterIndex = nPosterIndex
	ui:Append('Shadow', { name = 'Shadow_Adv', x = 0, y = 0, w = 0, h = 0, color = { 140, 140, 140 } })
	ui:Append('Image', { name = 'Image_Adv', x = 0, y = 0, w = 0, h = 0, image = X.PACKET_INFO.POSTER_IMAGE_LIST[nPosterIndex], imageFrame = 0 })
	ui:Append('Text', { name = 'Text_Adv', x = 10, y = 300, w = 557, font = 200, text = GetAdvText() })
	ui:Append('Text', { name = 'Text_Memory', x = 10, y = 300, w = 150, alpha = 150, font = 162, text = GetMemoryText(), alignHorizontal = 2 })
	ui:Append('Text', { name = 'Text_Svr', x = 10, y = 345, w = 557, font = 204, text = GetSvrText(), alpha = 220 })
	local x = 7
	-- 奇遇分享
	x = x + ui:Append('WndCheckBox', {
		x = x, h = 25,
		name = 'WndCheckBox_SerendipityNotify',
		text = _L['Show share notify.'],
		checked = MY_Serendipity.bEnable,
		onCheck = function(bChecked)
			if bChecked then
				local ui = X.UI(this)
				X.Confirm(_L['Check this will monitor system message for serendipity and share it, are you sure?'], function()
					MY_Serendipity.bEnable = bChecked
					ui:Check(true, WNDEVENT_FIRETYPE.PREVENT)
				end)
				ui:Check(false, WNDEVENT_FIRETYPE.PREVENT)
			else
				MY_Serendipity.bEnable = bChecked
			end
		end,
		tip = {
			render = _L['Monitor serendipity and show share notify.'],
			position = X.UI.TIP_POSITION.BOTTOM_TOP,
		},
	}):AutoWidth():Width()
	local xS0 = x + ui:Append('WndCheckBox', {
		x = x, h = 25,
		name = 'WndCheckBox_SerendipityAutoShare',
		text = _L['Auto share.'],
		checked = MY_Serendipity.bAutoShare,
		onCheck = function()
			MY_Serendipity.bAutoShare = not MY_Serendipity.bAutoShare
		end,
		autoEnable = function() return MY_Serendipity.bEnable end,
	}):AutoWidth():Width()
	-- 自动分享子项
	x = xS0
	x = x + ui:Append('WndCheckBox', {
		x = x, h = 25,
		name = 'WndCheckBox_SerendipitySilentMode',
		text = _L['Silent mode.'],
		checked = MY_Serendipity.bSilentMode,
		onCheck = function()
			MY_Serendipity.bSilentMode = not MY_Serendipity.bSilentMode
		end,
		autoVisible = function() return MY_Serendipity.bAutoShare end,
		autoEnable = function() return MY_Serendipity.bEnable end,
	}):AutoWidth():Width()
	x = x + 5
	x = x + ui:Append('WndEditBox', {
		x = x, w = 105 + 3, h = 28,
		name = 'WndEditBox_SerendipitySilentMode',
		placeholder = _L['Realname, leave blank for anonymous.'],
		tip = {
			render = _L['Realname, leave blank for anonymous.'],
			position = X.UI.TIP_POSITION.BOTTOM_TOP,
		},
		limit = 6,
		text = X.LoadLUAData({'config/realname.jx3dat', X.PATH_TYPE.ROLE}) or X.GetClientPlayer().szName:gsub('@.-$', ''),
		onChange = function(szText)
			X.SaveLUAData({'config/realname.jx3dat', X.PATH_TYPE.ROLE}, szText)
		end,
		autoVisible = function() return MY_Serendipity.bAutoShare end,
		autoEnable = function() return MY_Serendipity.bEnable end,
	}):Width()
	-- 手动分享子项
	x = xS0
	x = x + ui:Append('WndCheckBox', {
		x = x, h = 25,
		name = 'WndCheckBox_SerendipityNotifyTip',
		text = _L['Show notify tip.'],
		checked = MY_Serendipity.bPreview,
		onCheck = function()
			MY_Serendipity.bPreview = not MY_Serendipity.bPreview
		end,
		autoVisible = function() return not MY_Serendipity.bAutoShare end,
		autoEnable = function() return MY_Serendipity.bEnable end,
	}):AutoWidth():Width()
	x = x + ui:Append('WndCheckBox', {
		x = x, h = 25,
		name = 'WndCheckBox_SerendipityNotifySound',
		text = _L['Play notify sound.'],
		checked = MY_Serendipity.bSound,
		onCheck = function()
			MY_Serendipity.bSound = not MY_Serendipity.bSound
		end,
		autoEnable = function() return MY_Serendipity.bEnable and not MY_Serendipity.bAutoShare end,
		autoVisible = function() return not MY_Serendipity.bAutoShare end,
	}):AutoWidth():Width()
	x = x + ui:Append('WndButton', {
		x = x, h = 30,
		name = 'WndButton_SerendipitySearch',
		text = _L['serendipity'],
		onClick = function()
			local szNameU = AnsiToUTF8(X.GetClientPlayerInfo().szName)
			local szNameCRC = ('%x%x%x'):format(szNameU:byte(), GetStringCRC(szNameU), szNameU:byte(-1))
			X.UI.OpenBrowser(
				'https://j3cx.com/serendipity/?'
					.. X.EncodeQuerystring(X.SignPostData(X.ConvertToUTF8(
						{
							l = X.ENVIRONMENT.GAME_LANG,
							L = X.ENVIRONMENT.GAME_EDITION,
							S = X.GetRegionOriginName(),
							s = X.GetServerOriginName(),
							n = X.GetClientPlayerInfo().szName,
							N = szNameCRC,
						}),
						X.KGUIEncrypt(X.SECRET['J3CX::SERENDIPITY'])
					)),
				{ openurl = 'https://j3cx.com/serendipity', controls = false })
		end,
	}):AutoWidth():Width() + 5
	-- 数据位置
	x = x + ui:Append('WndButton', {
		x = x, h = 30,
		name = 'WndButton_UserPreference',
		text = _L['User preference storage'],
		menu = function()
			return {
				{
					szOption = _L['User preference'],
					fnMouseEnter = function()
						local nX, nY = this:GetAbsX(), this:GetAbsY()
						local nW, nH = this:GetW(), this:GetH()
						OutputTip(GetFormatText(_L['User preference'] .. _L['Storage location'], nil, 255, 255, 0), 600, {nX, nY, nW, nH}, ALW.BOTTOM_TOP)
					end,
					fnMouseLeave = function()
						HideTip()
					end,
					fnAction = function()
						X.OpenFolder(X.GetAbsolutePath({'', X.PATH_TYPE.ROLE}))
						X.UI.ClosePopupMenu()
					end,
				},
				{
					szOption = _L['Server preference'],
					fnMouseEnter = function()
						local nX, nY = this:GetAbsX(), this:GetAbsY()
						local nW, nH = this:GetW(), this:GetH()
						OutputTip(GetFormatText(_L['Server preference'] .. _L['Storage location'], nil, 255, 255, 0), 600, {nX, nY, nW, nH}, ALW.BOTTOM_TOP)
					end,
					fnMouseLeave = function()
						HideTip()
					end,
					fnAction = function()
						X.OpenFolder(X.GetAbsolutePath({'', X.PATH_TYPE.SERVER}))
						X.UI.ClosePopupMenu()
					end,
				},
				{
					szOption = _L['Global preference'],
					fnMouseEnter = function()
						local nX, nY = this:GetAbsX(), this:GetAbsY()
						local nW, nH = this:GetW(), this:GetH()
						OutputTip(GetFormatText(_L['Global preference'] .. _L['Storage location'], nil, 255, 255, 0), 600, {nX, nY, nW, nH}, ALW.BOTTOM_TOP)
					end,
					fnMouseLeave = function()
						HideTip()
					end,
					fnAction = function()
						X.OpenFolder(X.GetAbsolutePath({'', X.PATH_TYPE.GLOBAL}))
						X.UI.ClosePopupMenu()
					end,
				},
				X.CONSTANT.MENU_DIVIDER,
				{
					szOption = _L['Flush data'],
					fnMouseEnter = function()
						local nX, nY = this:GetAbsX(), this:GetAbsY()
						local nW, nH = this:GetW(), this:GetH()
						OutputTip(GetFormatText(_L['Config and data will be saved when exit game, click to save immediately'], nil, 255, 255, 0), 600, {nX, nY, nW, nH}, ALW.BOTTOM_TOP)
					end,
					fnMouseLeave = function()
						HideTip()
					end,
					fnAction = function()
						X.FireFlush()
						X.UI.ClosePopupMenu()
					end,
				},
				{
					szOption = _L['Export data'],
					fnAction = function()
						X.OpenUserSettingsExportPanel()
						X.UI.ClosePopupMenu()
					end,
				},
				{
					szOption = _L['Import data'],
					fnAction = function()
						X.OpenUserSettingsImportPanel()
						X.UI.ClosePopupMenu()
					end,
				},
			}
		end,
	}):AutoWidth():Width() + 5
	x = x + ui:Append('WndButton', {
		name = 'WndButton_AddonErrorMessage',
		x = x, h = 30,
		text = _L['Error message'],
		menu = function()
			local menu = {}
			if IsCtrlKeyDown() and IsAltKeyDown() and IsShiftKeyDown() then
				table.insert(menu, 1, {
					szOption = _L['Enable debug tools'],
					rgb = { 255, 128, 0 },
					fnAction = function()
						X.SetDebugging('Dev_LuaWatcher', true)
						X.SetDebugging('Dev_UIEditor', true)
						X.SetDebugging('Dev_UIManager', true)
						X.SetDebugging('Dev_UIFindStation', true)
						X.SetDebugging('Dev_DebugLogs', true)
						X.SetDebugging('Dev_BgMsgViewer', true)
						X.OutputSystemAnnounceMessage(_L['Debug tools has been enabled...'])
						X.Panel.Reopen()
						X.UI.ClosePopupMenu()
					end,
				})
				table.insert(menu, 2, X.CONSTANT.MENU_DIVIDER)
			end
			if X.IsDebugging('Dev_BgMsgViewer') then
				table.insert(menu, 1, {
					szOption = _L['Open BgMsgViewer'],
					rgb = { 128, 255, 128 },
					fnAction = function()
						_G[X.NSFormatString('{$NS}_BgMsgViewer')].Open()
						X.UI.ClosePopupMenu()
					end,
				})
				table.insert(menu, 2, X.CONSTANT.MENU_DIVIDER)
			end
			table.insert(menu, {
				szOption = _L['Show error message'],
				tip = {
					render = _L['Show error message, please commit it while report bugs'],
					position = X.UI.TIP_POSITION.BOTTOM_TOP,
				},
				fnAction = function()
					local szErrmsg = X.GetAddonErrorMessage()
					local nErrmsgLen, nMaxLen = #szErrmsg, 1024
					if nErrmsgLen == 0 then
						X.Alert(_L['No error message found.'])
						return
					end
					if nErrmsgLen > 300 then
						szErrmsg = szErrmsg:sub(0, nMaxLen)
							.. '\n========================================'
							.. '\n' .. '... ' .. (nErrmsgLen - nMaxLen) .. ' char(s) omitted.'
							.. '\n========================================'
							.. '\n# Full error logs:'
							.. '\n> ' .. X.GetAbsolutePath(X.GetAddonErrorMessageFilePath())
							.. '\n========================================'
					end
					X.UI.OpenTextEditor(szErrmsg, { w = 800, h = 600, title = _L['Error message'] })
					X.UI.ClosePopupMenu()
				end,
			})
			table.insert(menu, {
				szOption = _L['Open error message folder'],
				fnAction = function()
					X.OpenFolder(X.GetAbsolutePath(X.GetAddonErrorMessageFilePath()))
					X.UI.ClosePopupMenu()
				end,
			})
			table.insert(menu, {
				szOption = _L['Open logs folder'],
				fnAction = function()
					X.OpenFolder(X.GetAbsolutePath(X.FormatPath({'logs/', X.PATH_TYPE.ROLE})))
					X.UI.ClosePopupMenu()
				end,
			})
			table.insert(menu, X.CONSTANT.MENU_DIVIDER)
			table.insert(menu, {
				szOption = _L['Report bugs'],
				fnAction = function()
					X.OpenBrowser(X.PACKET_INFO.AUTHOR_FEEDBACK_URL)
					X.UI.ClosePopupMenu()
				end,
			})
			return menu
		end,
	}):AutoWidth():Width() + 5
	function D.fnDrawRSS()
		local tRSS = MY_RSS.Get('MP')
		if tRSS and X.IsString(tRSS.t) then
			local function FormatSQS(s)
				local SQS = X.EncodeQuerystring(X.SignPostData(X.ConvertToUTF8(
					{
						l = X.ENVIRONMENT.GAME_LANG,
						L = X.ENVIRONMENT.GAME_EDITION,
						S = X.GetRegionOriginName(),
						s = X.GetServerOriginName(),
						n = X.GetClientPlayerInfo().szName,
					}),
					X.SECRET['J3CX::SHARE_MSG']
				))
				return X.StringReplaceW(s, '{$SQS}', SQS)
			end
			local szText = tRSS.t
			local szPath = X.IsString(tRSS.u) and tRSS.u or nil
			local szMode = X.IsString(tRSS.m) and tRSS.m or nil
			local function CreateMenu(menu, data)
				for _, v in ipairs(data) do
					if X.IsTable(v) and X.IsString(v.t) then
						local m = {
							szOption = v.t,
							fnAction = function()
								if not X.IsString(v.u) then
									return
								end
								X.OpenBrowser(FormatSQS(v.u), v.m)
								X.UI.ClosePopupMenu()
							end,
						}
						if v.c then
							m.r, m.g, m.b = X.HumanColor2RGB(v.c)
						end
						if X.IsTable(v.s) then
							m = CreateMenu(m, v.s)
						end
						table.insert(menu, m)
					end
				end
				return menu
			end
			local menu = CreateMenu({}, tRSS.s)
			local t = {
				x = x, h = 30,
				name = 'WndButton_RSS',
				text = szText,
			}
			if tRSS.c then
				t.r, t.g, t.b = X.HumanColor2RGB(tRSS.c)
			end
			if #menu == 0 then
				t.onClick = function()
					X.OpenBrowser(FormatSQS(szPath), szMode)
				end
			else
				t.menu = menu
			end
			x = x + ui:Append('WndButton', t):AutoWidth():Width() + 5
			PS.OnPanelResize(wnd)
			D.fnDrawRSS = nil
		end
	end
	PS.OnPanelResize(wnd)
end

function PS.OnPanelResize(wnd)
	local ui = X.UI(wnd)
	local nW, nH = ui:Size()
	local fScaleH = nW / 557 * 278
	local nBottomH = 90
	if fScaleH > nH - nBottomH then
		ui:Fetch('Shadow_Adv'):Size((nH - nBottomH) / 278 * 557, (nH - nBottomH))
		ui:Fetch('Image_Adv'):Size((nH - nBottomH) / 278 * 557, (nH - nBottomH))
		ui:Fetch('Text_Memory'):Pos(nW - 150, nH - nBottomH + 10)
		ui:Fetch('Text_Adv'):Pos(10, nH - nBottomH + 10)
		ui:Fetch('Text_Svr'):Pos(10, nH - nBottomH + 35)
	else
		ui:Fetch('Shadow_Adv'):Size(nW, fScaleH)
		ui:Fetch('Image_Adv'):Size(nW, fScaleH)
		ui:Fetch('Text_Memory'):Pos(nW - 150, fScaleH + 10)
		ui:Fetch('Text_Adv'):Pos(10, fScaleH + 10)
		ui:Fetch('Text_Svr'):Pos(10, fScaleH + 35)
	end
	ui:Fetch('WndCheckBox_SerendipityNotify'):Top(fScaleH + 66.5)
	ui:Fetch('WndCheckBox_SerendipityAutoShare'):Top(fScaleH + 66.5)
	ui:Fetch('WndCheckBox_SerendipitySilentMode'):Top(fScaleH + 66.5)
	ui:Fetch('WndEditBox_SerendipitySilentMode'):Top(fScaleH + 65)
	ui:Fetch('WndCheckBox_SerendipityNotifyTip'):Top(fScaleH + 66.5)
	ui:Fetch('WndCheckBox_SerendipityNotifySound'):Top(fScaleH + 66.5)
	ui:Fetch('WndButton_SerendipitySearch'):Top(fScaleH + 65)
	ui:Fetch('WndButton_UserPreference'):Top(fScaleH + 65)
	ui:Fetch('WndButton_AddonErrorMessage'):Top(fScaleH + 65)
	ui:Fetch('WndButton_RSS'):Top(fScaleH + 65)
end

function PS.OnPanelBreathe(wnd)
	local ui = X.UI(wnd)
	ui:Fetch('Text_Adv'):Text(GetAdvText())
	ui:Fetch('Text_Svr'):Text(GetSvrText())
	ui:Fetch('Text_Memory'):Text(GetMemoryText())
end

function PS.OnPanelDeactivate()
	D.fnDrawRSS = nil
end

X.Panel.Register(nil, 'Welcome', _L['Welcome'], '', PS)

X.RegisterEvent('MY_RSS_UPDATE', 'PS_Welcome_RSS_Update', function()
	if arg0 and arg0 ~= 'MP' then
		return
	end
	X.SafeCall(D.fnDrawRSS)
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
