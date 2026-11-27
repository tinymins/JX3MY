--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 云端宏
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_YunMacro'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
X.RegisterRestriction('MY_YunMacro', { ['*'] = false })
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_YunMacro', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_YunMacro'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
})
local D = {}

function D.Hook()
	local frame = Station.SearchFrame('MacroSettingPanel')
	if not frame then
		return
	end
	local edtName = frame:Lookup('Edit_Name')
	local imgNameBg = frame:Lookup('', 'Image_NameBg')
	local edtDesc = frame:Lookup('Edit_Desc')
	local edtMacro = frame:Lookup('Edit_Content')
	local btnNew = frame:Lookup('Btn_New')
	local hIconList = frame:Lookup('', 'Handle_Icon')
	local nX = edtName:GetRelX() + edtName:GetW() + 10
	local nY = edtName:GetRelY() - 4
	local nH = edtName:GetH()
	if imgNameBg then
		nY = imgNameBg:GetRelY()
		nH = imgNameBg:GetH()
	end
	nX = nX + X.UI(frame):Append('WndButton', {
		name = 'Btn_YunMacro_Update',
		x = nX, y = nY,
		w = 'auto', h = nH,
		text = _L['Sync yun macro'],
		onClick = function()
			local szName = X.TrimString(edtName:GetText())
			if X.IsEmpty(szName) then
				return X.Alert(_L['Please input macro name first.'])
			end
			X.Alert('MY_YunMacro', _L['Macro update started, please keep panel opened and wait.'], nil, _L['Got it'])
			X.Ajax({
				url = MY_RSS.PULL_BASE_URL .. '/api/macro/query',
				data = {
					l = X.ENVIRONMENT.GAME_LANG,
					L = X.ENVIRONMENT.GAME_EDITION,
					name = szName,
				},
				success = function(szHTML)
					local res, err = X.DecodeJSON(szHTML)
					if res then
						if res.msg then
							return X.Alert('MY_YunMacro', res.msg)
						end
						local bValid, szErrID, nLine, szErrMsg = X.IsMacroValid(res.data)
						if bValid then
							res.desc = X.ReplaceSensitiveWord(res.desc)
						else
							res, err = false, szErrMsg
						end
					end
					if not res then
						return X.Alert('MY_YunMacro', _L['ERR: Info content is illegal!'] .. '\n\n' .. err, nil, _L['Got it'])
					end
					if res.icon then
						for i = 0, hIconList:GetItemCount() - 1 do
							local h = hIconList:Lookup(i)
							if h:GetType() == 'Handle' then
								h = h:Lookup('Box_Icon')
							end
							h:SetObjectInUse(false)
						end
						local box = hIconList:Lookup(0)
						if box:GetType() == 'Handle' then
							box = box:Lookup('Box_Icon')
						end
						box:SetObjectInUse(true)
						box:SetObjectIcon(res.icon)
						box.nIconID = res.icon
						hIconList.nIconID = res.icon
					end
					edtDesc:SetText(res.desc)
					edtDesc:SetCaretPos(0)
					edtMacro:SetText(res.data)
					edtMacro:SetCaretPos(0)
					X.Alert('MY_YunMacro', _L['Macro update succeed, please click save button.'], nil, _L['Got it'])
				end,
				error = function()
					X.Alert('MY_YunMacro', _L['Macro update failed...'], nil, _L['Got it'])
				end,
			})
		end,
	}):Width()
	X.UI(frame):Append('WndButton', {
		name = 'Btn_YunMacro_Details',
		x = nX, y = nY,
		w = 'auto', h = nH,
		text = _L['Show yun macro details'],
		onClick = function()
			local szName = X.TrimString(edtName:GetText())
			if X.IsEmpty(szName) then
				return X.Alert(_L['Please input macro name first.'])
			end
			local szURL = MY_RSS.PAGE_BASE_URL .. '/macro/details?'
				.. X.EncodeQuerystring(X.ConvertToUTF8({
					l = X.ENVIRONMENT.GAME_LANG,
					L = X.ENVIRONMENT.GAME_EDITION,
					name = szName,
				}))
			X.UI.OpenBrowser(szURL, { key = 'MY_YunMacro_' .. GetStringCRC(szName), layer = 'Topmost', readonly = true })
		end,
	})
	X.UI(frame):Append('WndButton', {
		name = 'Btn_YunMacro_Tops',
		x = edtMacro:GetRelX(), y = btnNew:GetRelY(),
		w = btnNew:GetW(), h = btnNew:GetH(),
		text = _L['Top yun macro'],
		onClick = function()
			local szURL = MY_RSS.PAGE_BASE_URL .. '/macro/tops?'
				.. X.EncodeQuerystring(X.ConvertToUTF8({
					l = X.ENVIRONMENT.GAME_LANG,
					L = X.ENVIRONMENT.GAME_EDITION,
					kungfu = tostring(UI_GetPlayerMountKungfuID()),
				}))
			X.OpenBrowser(szURL)
		end,
	})
end

function D.Unhook()
	local frame = Station.SearchFrame('MacroSettingPanel')
	if not frame then
		return
	end
	for _, s in ipairs({
		'Btn_YunMacro_Update',
		'Btn_YunMacro_Details',
		'Btn_YunMacro_Tops',
	}) do
		local el = frame:Lookup(s)
		if el then
			el:Destroy()
		end
	end
end

function D.Apply()
	if D.bReady and O.bEnable then
		D.Hook()
		X.RegisterFrameCreate('MacroSettingPanel', 'MY_YunMacro', D.Hook)
		X.RegisterReload('MY_YunMacro', D.Unhook)
	else
		D.Unhook()
		X.RegisterFrameCreate('MacroSettingPanel', 'MY_YunMacro', false)
		X.RegisterReload('MY_YunMacro', false)
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	if not X.IsRestricted('MY_YunMacro') then
		nX = nX + ui:Append('WndCheckBox', {
			x = nX, y = nY, w = 'auto',
			text = _L['Cloud macro'],
			tip = {
				render = _L['Click icon on macro panel to view macro wiki'],
				position = X.UI.TIP_POSITION.BOTTOM_TOP,
			},
			checked = MY_YunMacro.bEnable,
			onCheck = function(bChecked)
				MY_YunMacro.bEnable = bChecked
			end,
		}):Width() + 5
	end
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_YunMacro',
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
			},
			root = O,
		},
	},
	imports = {
		{
			fields = {
				'bEnable',
			},
			triggers = {
				bEnable = D.Apply,
			},
			root = O,
		},
	},
}
MY_YunMacro = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_YunMacro', function()
	D.bReady = true
	D.Apply()
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
