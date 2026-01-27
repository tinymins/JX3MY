--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 游戏字体
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Font/MY_Font'
local PLUGIN_NAME = 'MY_Font'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Font'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.2') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------

-- 本地变量
local D = {}
local CONFIG_PATH = {'config/fontconfig.jx3dat', X.PATH_TYPE.GLOBAL}
local CONFIG = X.LoadLUAData(CONFIG_PATH) or {}

-- 设置字体
function D.SetFont(tIDs, szName, szFile, nSize, tStyle)
	-- tIDs  : 要改变字体的类型组（标题/文本/姓名 等）
	-- szName: 字体名称
	-- szFile: 字体路径
	-- nSize : 字体大小
	-- tStyle: {
	--     ['vertical'] = (bool),
	--     ['border'  ] = (bool),
	--     ['shadow'  ] = (bool),
	--     ['mono'    ] = (bool),
	--     ['mipmap'  ] = (bool),
	-- }
	-- Ex: SetFont(Font.GetChatFontID(), '黑体', '\\UI\\Font\\方正黑体_GBK.ttf', 16, {['shadow'] = true})
	for _, dwID in ipairs(tIDs) do
		local szName1, szFile1, nSize1, tStyle1 = Font.GetFont(dwID)
		Font.SetFont(dwID, szName or szName1, szFile or szFile1, nSize or nSize1, tStyle or tStyle1)
		if dwID == Font.GetChatFontID() then
			X.UI.OpenFrame('ChatSettingPanel')
			OutputWarningMessage('MSG_REWARD_GREEN', _L['Please click apply or sure button to save change!'], 10)
		end
		CONFIG[dwID] = {szName or szName1, szFile or szFile1, nSize or nSize1, tStyle or tStyle1}
	end
	X.SaveLUAData(CONFIG_PATH, CONFIG)
	Station.SetUIScale(Station.GetUIScale(), true)
end

-- 字体配置项
local FONT_TYPE = {
	{
		szTitle = _L['Common UI Text'],
		Get = function()
			local szFontName, szFontFile = Font.GetFont(0)
			return szFontName, szFontFile
		end,
		Set = function(szFontName, szFontFile)
			D.SetFont({0, 1, 2, 3, 4, 6}, szFontName, szFontFile)
		end,
	},
	{
		szTitle = _L['Chat Panel Text'],
		Get = function()
			local szFontName, szFontFile = Font.GetFont(Font.GetChatFontID())
			return szFontName, szFontFile
		end,
		Set = function(szFontName, szFontFile)
			D.SetFont({Font.GetChatFontID()}, szFontName, szFontFile)
		end,
	},
	{
		szTitle = _L['Combat Text'],
		Get = function()
			local szFontName, szFontFile = Font.GetFont(7)
			return szFontName, szFontFile
		end,
		Set = function(szFontName, szFontFile)
			D.SetFont({7}, szFontName, szFontFile)
		end,
	},
}
if Global_SetCaptionParams then
	table.insert(FONT_TYPE, {
		szTitle = _L['Lifebar Text'],
		Get = function()
			local szFontName, szFontFile = '', g_tStrings.STR_CUSTOM_TEAM or ''
			if Global_GetCaptionFontConfig then
				szFontFile = Global_GetCaptionFontConfig().szFontFile or ''
				for _, p in ipairs(X.GetFontList()) do
					if p.szFile == szFontFile then
						szFontName = p.szName
						break
					end
				end
			end
			return szFontName, szFontFile
		end,
		Set = function(szFontName, szFontFile)
			local tParams = {
				{ vtype = 's', key = 'FontFile', value = szFontFile },
				-- { vtype = 'f', key = 'FontZoomInScale', value = 3 },
			}
			Global_SetCaptionParams(tParams)
		end,
	})
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_Font',
	exports = {
		{
			fields = {
				'SetFont',
			},
			root = D,
		},
	},
}
MY_Font = X.CreateModule(settings)
end

-- 配置界面
local PS = {}
function PS.OnPanelActive(wnd)
	local ui = X.UI(wnd)
	local nPaddingX, nPaddingY = 10, 30
	local nX, nY = nPaddingX, nPaddingY
	local nW, nH = ui:Size()
	local aFontList = X.GetFontList()
	local aFontName, aFontPath = {}, {}

	for _, p in ipairs(aFontList) do
		table.insert(aFontName, p.szName)
		table.insert(aFontPath, p.szFile)
	end

	for _, p in ipairs(FONT_TYPE) do
		local szFontName, szFontFile = p.Get()
		local acFontFile, acFontName, btnApply
		local function UpdateBtnEnable()
			local szNewFile = acFontFile:Text()
			local bFileExist = IsFileExist(szNewFile)
			acFontFile:Color(bFileExist and {255, 255, 255} or {255, 0, 0})
			btnApply:Enable(bFileExist and szNewFile ~= szFontFile)
		end

		ui:Append('Text', { text = _L[' * '] .. p.szTitle, x = nX, y = nY })
		nY = nY + 30

		acFontFile = ui:Append('WndAutocomplete', {
			x = nX, y = nY, w = nW - nX - 60 - 150 - 5 - 35 - 5 - nX - 5, h = 25,
			text = szFontFile,
			onChange = function(szText)
				UpdateBtnEnable()
				szText = StringLowerW(szText)
				for _, p in ipairs(aFontList) do
					if StringLowerW(p.szFile) == szText then
						if acFontName:Text() ~= p.szName then
							acFontName:Text(p.szName)
						end
						return
					end
				end
				acFontName:Text(g_tStrings.STR_CUSTOM_TEAM)
			end,
			onClick = function()
				if IsPopupMenuOpened() then
					X.UI(this):Autocomplete('close')
				else
					X.UI(this):Autocomplete('search', '')
				end
			end,
			autocomplete = {{'option', 'source', aFontPath}},
		})

		ui:Append('WndButton', {
			x = nW - nX - 60 - 150 - 5 - 35 - 5, y = nY, w = 35, h = 25,
			text = '...',
			buttonStyle = 'FLAT',
			onClick = function()
				local file = GetOpenFileName(_L['Please select your font file.'], 'Font File(*.ttf;*.otf;*.fon)\0*.ttf;*.otf;*.fon\0All Files(*.*)\0*.*\0\0')
				if not X.IsEmpty(file) then
					file = X.GetRelativePath(file, '') or file
					acFontFile:Text(X.StringReplaceW(file, '/', '\\'))
				end
			end,
		})

		acFontName = ui:Append('WndAutocomplete', {
			x = nW - nX - 60 - 150 - 5, y = nY, w = 150, h = 25,
			text = szFontName,
			onChange = function(szText)
				UpdateBtnEnable()
				szText = StringLowerW(szText)
				for _, p in ipairs(aFontList) do
					if StringLowerW(p.szName) == szText
					and acFontFile:Text() ~= p.szFile then
						acFontFile:Text(p.szFile)
						return
					end
				end
			end,
			onClick = function()
				if IsPopupMenuOpened() then
					X.UI(this):Autocomplete('close')
				else
					X.UI(this):Autocomplete('search', '')
				end
			end,
			autocomplete = {{'option', 'source', aFontName}},
		})

		btnApply = ui:Append('WndButton', {
			x = nW - nX - 60, y = nY, w = 60, h = 25,
			text = _L['Apply'], enable = false,
			buttonStyle = 'FLAT',
			onClick = function()
				p.Set(acFontName:Text(), acFontFile:Text())
				szFontName, szFontFile = p.Get()
				acFontName:Text(szFontName, WNDEVENT_FIRETYPE.PREVENT)
				acFontFile:Text(szFontFile, WNDEVENT_FIRETYPE.PREVENT)
				UpdateBtnEnable()
			end
		})
		nY = nY + 40
	end

	nX = nPaddingX + 5
	nY = nY + 10
	nY = nY + ui:Append('Text', {
		x = nX, y = nY, w = nW - nX * 2, multiline = true, alignVertical = 0,
		text = _L['1. This plugin only modifies in-game font settings and does not include font files. You need to prepare font files yourself.'],
	}):AutoHeight():Height() + 2
	nY = nY + ui:Append('Text', {
		x = nX, y = nY, w = nW - nX * 2, multiline = true, alignVertical = 0,
		text = _L['2. Font files can be downloaded from various font websites. Please pay attention to copyright issues.'],
	}):AutoHeight():Height() + 2
	nY = nY + ui:Append('Text', {
		x = nX, y = nY, w = nW - nX * 2, multiline = true, alignVertical = 0,
		text = _L['3. It is recommended to use common TTF or OTF format font files. Avoid using FON format to prevent compatibility issues.'],
	}):AutoHeight():Height() + 2
	nY = nY + ui:Append('Text', {
		x = nX, y = nY, w = nW - nX * 2, multiline = true, alignVertical = 0,
		text = _L['4. Place the prepared font files in the font directory to use them, click button below to open font folder.'],
	}):AutoHeight():Height() + 2

	nX = nPaddingX
	nY = nY + 10
	ui:Append('WndButton', {
		x = nX, y = nY, w = 150, h = 30,
		text = _L['Open font folder'],
		onClick = function()
			X.OpenFolder(X.FormatPath({'font/', X.PATH_TYPE.GLOBAL}))
		end,
	})

	ui:Append('WndButton', {
		x = nX + 160, y = nY, w = 150, h = 30,
		text = _L['Refresh font list'],
		onClick = function()
			X.Panel.SwitchTab('MY_Font', true)
		end,
	})

	ui:Append('WndButton', {
		x = nX + 320, y = nY, w = 150, h = 30,
		text = _L['Get more fonts'],
		onClick = function()
			X.OpenBrowser('https://j3cx.com/fonts/' .. X.ENVIRONMENT.GAME_LOCALE, 'outer')
		end,
	})
end
X.Panel.Register(_L['System'], 'MY_Font', _L['MY_Font'], 'ui/Image/UICommon/CommonPanel7.UITex|36', PS)

-- 兼容历史位置
do
	local szSrcDir = X.PACKET_INFO.ROOT .. 'MY_FontResource/font/'
	local aFontDesc = X.LoadLUAData(szSrcDir .. X.ENVIRONMENT.GAME_LANG .. '.jx3dat')
	if aFontDesc then
		local szDstDir = X.FormatPath({'font/', X.PATH_TYPE.GLOBAL})
		for _, tFont in ipairs(aFontDesc) do
			if tFont.tLang[X.ENVIRONMENT.GAME_LANG] and tFont.szFile:sub(1, 2) == './' then
				local szSrcFile = X.NormalizePath(szSrcDir .. tFont.szFile:sub(3))
				if IsFileExist(szSrcFile) then
					local szExt = string.match(tFont.szFile, '%.([^%.]+)$') or 'ttf'
					local szDstFile = szDstDir .. tFont.szName .. '.' .. szExt
					CPath.Move(szSrcFile, szDstFile)
				end
			end
		end
	end
end

-- 初始化设置
do
	local bChanged = false
	for dwID, tConfig in pairs(CONFIG) do
		local szName, szFile, nSize, tStyle = unpack(tConfig)
		if IsFileExist(szFile) then
			local szCurName, szCurFile, nCurSize, tCurStyle = Font.GetFont(dwID)
			local szNewName, szNewFile, nNewSize, tNewStyle = szName or szCurName, szFile or szCurFile, nSize or nCurSize, tStyle or tCurStyle
			if not X.IsEquals(szNewName, szCurName) or not X.IsEquals(szNewFile, szCurFile)
			or not X.IsEquals(nNewSize, nCurSize) or not X.IsEquals(tNewStyle, tCurStyle) then
				Font.SetFont(dwID, szNewName, szNewFile, nNewSize, tNewStyle)
				bChanged = true
			end
		end
	end
	if bChanged then
		Station.SetUIScale(Station.GetUIScale(), true)
	end
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
