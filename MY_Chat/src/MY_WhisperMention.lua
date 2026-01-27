--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 记录点名到密聊频道
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Chat/MY_WhisperMention'
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Chat'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.3') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_WhisperMention', _L['Chat'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_WhisperMention'],
			_L['Redirect mention to whisper'],
		}),
		szVersion = '20241023',
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
	bDisableOfficial = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Chat'],
		szDescription = X.MakeCaption({
			_L['MY_WhisperMention'],
			_L['Filter official mention'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
})
local D = {
	bEnable = false,
	bDisableOfficial = false,
	aMentionMsg = {},
}

function D.SyncSettings()
	D.bEnable = O.bEnable
	D.bDisableOfficial = O.bDisableOfficial
end

function D.Apply()
	if D.bEnable then
		X.HookChatPanel('FILTER', 'MY_WhisperMention', function(h, szMsg, szChannel, dwTime)
			local tInfo = MY_Chat.ParseMessageInfo(szMsg)
			local szRawMessage = szMsg
			if tInfo then
				dwTime       = tInfo.dwTime
				szChannel    = tInfo.szChannel
				szRawMessage = tInfo.szRawMessage or szMsg
			end
			if h.__MY_LastMsg == szRawMessage and h.__MY_LastMsgChannel ~= szChannel and szChannel == 'MSG_WHISPER' then
				return false
			end
			h.__MY_LastMsg = szMsg
			h.__MY_LastMsgChannel = szChannel
			return true
		end)
	else
		X.HookChatPanel('FILTER', 'MY_WhisperMention', false)
	end
end

function D.ClearMsg(szMsg)
	return MY_Chat.UnwrapRawMessage(szMsg)
end

function D.OnMessageArrive(szChannel, szMsg, nFont, bRich, r, g, b, dwTalkerID, szName)
	local me = X.GetClientPlayer()
	if not me then
		return
	end
	local bEcho = false
	local aXMLNode = X.XMLDecode(szMsg)
	if not X.IsTable(aXMLNode) then
		return
	end
	for _, node in ipairs(aXMLNode) do
		local nodeType = X.XMLGetNodeType(node)
		local nodeName = X.XMLGetNodeData(node, 'name') or ''
		local nodeText = X.XMLGetNodeData(node, 'text')
		if nodeType == 'text' and nodeName:sub(1, 8) == 'namelink' and nodeText:sub(2, -2) == me.szName then
			bEcho = true
			break
		end
	end
	if bEcho then
		if D.bEnable and dwTalkerID ~= me.dwID then
			OutputMessage('MSG_WHISPER', szMsg, bRich, nFont, {r, g, b}, dwTalkerID, szName)
		end
		table.insert(D.aMentionMsg, {
			szChannel = szChannel,
			szMsg = D.ClearMsg(szMsg),
			dwTalkerID = dwTalkerID,
			szName = szName,
			dwTime = GetCurrentTime(),
		})
		X.DelayCall('MY_WhisperMention', 1500, D.OnMentionMsgGC)
	end
end

function D.OnMentionMsgGC()
	while true do
		local tMention = D.aMentionMsg[1]
		if not tMention or tMention.dwTime + 1 > GetCurrentTime() then
			break
		end
		table.remove(D.aMentionMsg, 1)
	end
end

function D.OnMsgFilter(szMsgType, szMsg, nFont, bRich, r, g, b, dwTalkerID, szName)
	if D.bEnable or D.bDisableOfficial then
		szMsg = D.ClearMsg(szMsg)
		for _, v in ipairs(D.aMentionMsg) do
			if dwTalkerID == v.dwTalkerID and szMsg == v.szMsg and v.dwTime + 1 > GetCurrentTime() then
				return true
			end
		end
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY, lineHeight)
	nX = nPaddingX
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Redirect mention to whisper'],
		checked = O.bEnable,
		onCheck = function(bChecked)
			O.bEnable = bChecked
			D.SyncSettings()
			D.Apply()
		end,
	}):Width() + 5
	if X.IS_REMAKE then
		nX = ui:Append('WndCheckBox', {
			x = nX, y = nY, w = 'auto',
			text = _L['Filter official mention'],
			checked = O.bDisableOfficial,
			onCheck = function(bChecked)
				O.bDisableOfficial = bChecked
				D.SyncSettings()
			end,
			autoEnable = function() return not O.bEnable end,
		}):Width() + 5
	end
	nY = nY + lineHeight
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_WhisperMention',
	exports = {
		{
			fields = {
				OnPanelActivePartial = D.OnPanelActivePartial,
			},
		},
	},
}
MY_WhisperMention = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterMsgMonitor(
	{
		'MSG_NORMAL',
		'MSG_PARTY',
		'MSG_MAP',
		'MSG_BATTLE_FILED',
		'MSG_GUILD',
		'MSG_GUILD_ALLIANCE',
		'MSG_SCHOOL',
		'MSG_WORLD',
		'MSG_TEAM',
		'MSG_CAMP',
		'MSG_GROUP',
		'MSG_SEEK_MENTOR',
		'MSG_FRIEND',
		'MSG_IDENTITY',
		'MSG_SYS',
		'MSG_NPC_NEARBY',
		'MSG_NPC_YELL',
		'MSG_NPC_PARTY',
		'MSG_NPC_WHISPER',
	},
	'MY_WhisperMention',
	D.OnMessageArrive
)
X.RegisterMsgFilter('MSG_WHISPER', 'MY_WhisperMention', D.OnMsgFilter)

X.RegisterUserSettingsInit('MY_WhisperMention', function()
	D.SyncSettings()
	D.Apply()
end)
X.RegisterUserSettingsRelease('MY_WhisperMention', function()
	D.bEnable = false
	D.Apply()
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
