--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 玩家名字变成link方便组队
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_DialogNameLink'
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

local O = X.CreateUserSettingsModule('MY_DialogNameLink', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_DialogNameLink'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}

function D.Apply()
	if D.bReady and O.bEnable then
		X.RegisterEvent('OPEN_WINDOW', 'NAMELINKER', function(event)
			local h
			for _, p in ipairs({
				{'Normal/DialoguePanel', '', 'Handle_Message'},
				{'Lowest2/PlotDialoguePanel', 'Wnd_Dialogue', 'Handle_Dialogue'},
			}) do
				local frame = Station.Lookup(p[1])
				if frame and frame:IsVisible() then
					h = frame:Lookup(p[2], p[3])
					if h then
						break
					end
				end
			end
			if not h then
				return
			end
			for i = 0, h:GetItemCount() - 1 do
				local hItem = h:Lookup(i)
				if hItem:GetType() == 'Text' then
					local szText = hItem:GetText()
					for _, szPattern in ipairs(_L.NAME_PATTERN_LIST) do
						local _, _, szName = szText:find(szPattern)
						if szName then
							local nPos1, nPos2 = szText:find(szName)
							h:InsertItemFromString(i, true, GetFormatText(szText:sub(nPos2 + 1), hItem:GetFontScheme()))
							h:InsertItemFromString(i, true, GetFormatText('[' .. szText:sub(nPos1, nPos2) .. ']', nil, nil, nil, nil, nil, nil, 'namelink'))
							local txtName = h:Lookup(i + 1)
							X.RenderChatLink(txtName)
							if MY_Farbnamen and MY_Farbnamen.Render then
								MY_Farbnamen.Render(txtName, { bColor = false })
							end
							hItem:SetText(szText:sub(1, nPos1 - 1))
							hItem:SetFontColor(0, 0, 0)
							hItem:AutoSize()
							break
						end
					end
				end
			end
			h:FormatAllItemPos()
		end)
	else
		X.RegisterEvent('OPEN_WINDOW', 'NAMELINKER', false)
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_DialogNameLink',
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
MY_DialogNameLink = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_DialogNameLink', function()
	D.bReady = true
	D.Apply()
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
