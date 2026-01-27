--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 聊天栏姓名一键打码
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Chat/MY_ChatMosaics'
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_ChatMosaics'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.3') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------
local O = X.CreateUserSettingsModule(MODULE_NAME, _L['Chat'], {
	tIgnoreNames = { -- 忽略名单
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMosaics'],
		szDescription = X.MakeCaption({
			_L['unmosaics names (split by comma)'],
		}),
		xSchema = X.Schema.Map(X.Schema.String, X.Schema.Boolean),
		xDefaultValue = {},
	},
	nMosaicsMode = { -- 局部打码模式
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMosaics'],
		szDescription = X.MakeCaption({
			_L['mosaics mode'],
		}),
		xSchema = X.Schema.Number,
		xDefaultValue = 4,
	},
	bIgnoreOwnName = { -- 不打码自己的名字
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_ChatMosaics'],
		szDescription = X.MakeCaption({
			_L['no mosaics on my own name'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
})
local D = {
	bEnabled = false,            -- 启用状态
	szMosaics = _L.MOSAICS_CHAR, -- 马赛克字符
}

function D.OnMosaicsEnable()
	if not D.tSysHeadTopState then
		D.tSysHeadTopState = {
			['OTHERPLAYER_NAME'  ] = GetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.OTHERPLAYER , X.CONSTANT.GLOBAL_HEAD.NAME ),
			['OTHERPLAYER_GUILD' ] = GetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.OTHERPLAYER , X.CONSTANT.GLOBAL_HEAD.GUILD),
			['CLIENTPLAYER_NAME' ] = GetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.CLIENTPLAYER, X.CONSTANT.GLOBAL_HEAD.NAME ),
			['CLIENTPLAYER_GUILD'] = GetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.CLIENTPLAYER, X.CONSTANT.GLOBAL_HEAD.GUILD),
		}
	end
	SetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.OTHERPLAYER, X.CONSTANT.GLOBAL_HEAD.NAME , false)
	SetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.OTHERPLAYER, X.CONSTANT.GLOBAL_HEAD.GUILD, false)
	SetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.CLIENTPLAYER, X.CONSTANT.GLOBAL_HEAD.NAME , false)
	SetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.CLIENTPLAYER, X.CONSTANT.GLOBAL_HEAD.GUILD, false)
end

function D.OnMosaicsDisable()
	if D.tSysHeadTopState then
		SetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.OTHERPLAYER , X.CONSTANT.GLOBAL_HEAD.NAME , D.tSysHeadTopState['OTHERPLAYER_NAME'])
		SetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.OTHERPLAYER , X.CONSTANT.GLOBAL_HEAD.GUILD, D.tSysHeadTopState['OTHERPLAYER_GUILD'])
		SetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.CLIENTPLAYER, X.CONSTANT.GLOBAL_HEAD.NAME , D.tSysHeadTopState['CLIENTPLAYER_NAME'])
		SetGlobalTopHeadFlag(X.CONSTANT.GLOBAL_HEAD.CLIENTPLAYER, X.CONSTANT.GLOBAL_HEAD.GUILD, D.tSysHeadTopState['CLIENTPLAYER_GUILD'])
		D.tSysHeadTopState = nil
	end
end

X.RegisterExit('MY_ChatMosaics', D.OnMosaicsDisable)

function D.ResetMosaics()
	-- re mosaics
	D.bForceUpdate = true
	for _, k in X.pairs_c(X.CONSTANT.CHAT_PANEL_INDEX_LIST) do
		local hFrame = X.GetChatPanel(k)
		if hFrame then
			D.Mosaics(hFrame:Lookup('Wnd_Message', 'Handle_Message'))
		end
	end
	D.bForceUpdate = nil
	-- hook chat panel
	if D.bEnabled then
		X.HookChatPanel('AFTER', 'MY_ChatMosaics', function(h, nIndex)
			D.Mosaics(h, nIndex)
		end)
		D.OnMosaicsEnable()
	else
		X.HookChatPanel('AFTER', 'MY_ChatMosaics', false)
		D.OnMosaicsDisable()
	end
	FireUIEvent('ON_MY_MOSAICS_RESET')
end

function D.NameLink_GetText(h, ...)
	return h.__MY_ChatMosaics_szText or h.__MY_ChatMosaics_GetText(h, ...)
end

function D.MosaicsString(szText)
	if not D.bEnabled then
		return szText
	end
	local bQuote = szText:sub(1, 1) == '[' and szText:sub(-1, -1) == ']'
	if bQuote then
		szText = szText:sub(2, -2) -- 去掉[]括号
	end
	if (not O.bIgnoreOwnName or szText ~= X.GetClientPlayer().szName) and not O.tIgnoreNames[szText] then
		local nLen = X.StringLenW(szText)
		if O.nMosaicsMode == 3 and nLen > 2 then
			szText = X.StringSubW(szText, 1, 1) .. string.rep(D.szMosaics, nLen - 2) .. X.StringSubW(szText, nLen, nLen)
		elseif O.nMosaicsMode == 1 and nLen > 1 then
			szText = X.StringSubW(szText, 1, 1) .. string.rep(D.szMosaics, nLen - 1)
		elseif O.nMosaicsMode == 2 and nLen > 1 then
			szText = string.rep(D.szMosaics, nLen - 1) .. X.StringSubW(szText, nLen, nLen)
		elseif O.nMosaicsMode == 4 or nLen <= 1 then
			szText = string.rep(D.szMosaics, nLen)
		else
			szText = X.StringSubW(szText, 1, 1) .. string.rep(D.szMosaics, nLen - 1)
		end
	end
	if bQuote then
		szText = '[' .. szText .. ']' -- 加回[]括号
	end
	return szText
end

function D.Mosaics(h, nPos, nLen)
	if not h then
		return
	end
	if h:GetType() == 'Text' then
		if D.bEnabled then
			if not h.__MY_ChatMosaics_szText or D.bForceUpdate then
				h.__MY_ChatMosaics_szText = h.__MY_ChatMosaics_szText or h:GetText()
				if not h.__MY_ChatMosaics_GetText then
					h.__MY_ChatMosaics_GetText = h.GetText
					h.GetText = D.NameLink_GetText
				end
				h:SetText(D.MosaicsString(h.__MY_ChatMosaics_szText))
				h:AutoSize()
			end
		else
			if h.__MY_ChatMosaics_GetText then
				h.GetText = h.__MY_ChatMosaics_GetText
				h.__MY_ChatMosaics_GetText = nil
			end
			if h.__MY_ChatMosaics_szText then
				h:SetText(h.__MY_ChatMosaics_szText)
				h.__MY_ChatMosaics_szText = nil
				h:AutoSize()
			end
		end
	elseif h:GetType() == 'Handle' then
		local nEndPos = (nLen and (nPos + nLen)) or (h:GetItemCount() - 1)
		for i = nPos or 0, nEndPos do
			local hItem = h:Lookup(i)
			if hItem and (hItem:GetName():sub(0, 9)) == 'namelink_' then
				D.Mosaics(hItem)
			end
		end
		h:FormatAllItemPos()
	end
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_ChatMosaics',
	exports = {
		{
			preset = 'UIEvent',
			fields = {
				'Mosaics',
				'MosaicsString',
				'bEnabled',
			},
			root = D,
		},
	},
	imports = {
		{
			fields = {
				'bEnabled',
			},
			triggers = {
				bEnabled = function ()
					D.ResetMosaics()
				end,
			},
			root = D,
		},
	},
}
MY_ChatMosaics = X.CreateModule(settings)
end

local PS = {}

function PS.OnPanelActive(wnd)
	local ui = X.UI(wnd)
	local nW, nH = ui:Size()
	local nX, nY = 20, 30

	ui:Append('WndCheckBox', {
		text = _L['chat mosaics (mosaics names in chat panel)'],
		x = nX, y = nY, w = 400,
		checked = MY_ChatMosaics.bEnabled,
		onCheck = function(bCheck)
			MY_ChatMosaics.bEnabled = bCheck
			D.ResetMosaics()
		end,
	})
	nY = nY + 30

	ui:Append('WndCheckBox', {
		text = _L['no mosaics on my own name'],
		x = nX, y = nY, w = 400,
		checked = O.bIgnoreOwnName,
		onCheck = function(bCheck)
			O.bIgnoreOwnName = bCheck
			D.ResetMosaics()
		end,
	})
	nY = nY + 30

	ui:Append('WndRadioBox', {
		text = _L['part mosaics A (mosaics except 1st and last character)'],
		x = nX, y = nY, w = 400,
		group = 'PART_MOSAICS',
		checked = O.nMosaicsMode == 1,
		onCheck = function(bCheck)
			if bCheck then
				O.nMosaicsMode = 1
				D.ResetMosaics()
			end
		end,
	})
	nY = nY + 30

	ui:Append('WndRadioBox', {
		text = _L['part mosaics B (mosaics except 1st character)'],
		x = nX, y = nY, w = 400,
		group = 'PART_MOSAICS',
		checked = O.nMosaicsMode == 2,
		onCheck = function(bCheck)
			if bCheck then
				O.nMosaicsMode = 2
				D.ResetMosaics()
			end
		end,
	})
	nY = nY + 30

	ui:Append('WndRadioBox', {
		text = _L['part mosaics C (mosaics except last character)'],
		x = nX, y = nY, w = 400,
		group = 'PART_MOSAICS',
		checked = O.nMosaicsMode == 3,
		onCheck = function(bCheck)
			if bCheck then
				O.nMosaicsMode = 3
				D.ResetMosaics()
			end
		end,
	})
	nY = nY + 30

	ui:Append('WndRadioBox', {
		text = _L['part mosaics D (mosaics all character)'],
		x = nX, y = nY, w = 400,
		group = 'PART_MOSAICS',
		checked = O.nMosaicsMode == 4,
		onCheck = function(bCheck)
			if bCheck then
				O.nMosaicsMode = 4
				D.ResetMosaics()
			end
		end,
	})
	nY = nY + 30

	ui:Append('WndEditBox', {
		placeholder = _L['mosaics character'],
		x = nX, y = nY, w = nW - 2 * nX, h = 25,
		text = D.szMosaics,
		onChange = function(szText)
			if szText == '' then
				D.szMosaics = _L.MOSAICS_CHAR
			else
				D.szMosaics = szText
			end
			D.ResetMosaics()
		end,
	})
	nY = nY + 30

	ui:Append('WndEditBox', {
		placeholder = _L['unmosaics names (split by comma)'],
		x = nX, y = nY, w = nW - 2 * nX, h = nH - nY - 50,
		text = (function()
			local t = {}
			for szName, _ in pairs(O.tIgnoreNames) do
				table.insert(t, szName)
			end
			table.concat(t, ',')
		end)(),
		onChange = function(szText)
			local tIgnoreNames = {}
			for _, szName in ipairs(X.SplitString(szText, ',')) do
				tIgnoreNames[szName] = true
			end
			O.tIgnoreNames = tIgnoreNames
			D.ResetMosaics()
		end,
	})
	nY = nY + 30
end

X.Panel.Register(_L['Chat'], 'MY_Chat_ChatMosaics', _L['chat mosaics'], 'ui/Image/UICommon/yirong3.UITex|50', PS)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
