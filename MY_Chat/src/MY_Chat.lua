--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 聊天辅助
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Chat/MY_Chat'
local PLUGIN_NAME = 'MY_Chat'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_ChatCopy'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.3') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------

if RegisterMsgHook then
	RegisterMsgHook(
		function(szMsg, nFont, bRich, r, g, b, szType, dwTalkerID, szName)
			if not bRich then
				szMsg = GetFormatText(szMsg, nFont, r, g, b)
				bRich = true
			end
			szMsg = '<text> name="MY_Chat" script="this.name=\'MY_Chat\';this.data=\''
				.. GetCurrentTime()
				.. '/' .. (nFont or '') .. '/' .. (r or '') .. '/' .. (g or '') .. '/' .. (b or '')
				.. '/' .. (szType or '') .. '/' .. (dwTalkerID or '') .. '/' .. (szName or '')
				.. '\'" text="" lockshowhide=1</text>'
				.. szMsg
			return szMsg, nFont, bRich, r, g, b
		end,
		X.Clone(X.CONSTANT.MSG_TYPE_LIST)
	)
end

local function UnwrapRawMessage(szMsg)
	return szMsg:gsub('^<text>[^>]*name="MY_Chat"[^>]*</text>', '')
end

local function ParseMessageInfo(...)
	local szInfo, szRawMessage
	if X.IsElement((...)) then
		local h, i, j = ...
		for i = i, j do
			local el = h:Lookup(i)
			if el:GetType() == 'Text' and el:GetName() == 'MY_Chat' then
				szInfo = el.data
				break
			end
		end
	elseif X.IsString((...)) then
		local szMsg = ...
		local szMatch = szMsg:match('script="this.name=\'MY_Chat\';this.data=\'([^\']+)\'"')
		if szMatch then
			szInfo = szMatch
			szRawMessage = UnwrapRawMessage(szMsg)
		end
	end
	if szInfo then
		local aInfo = X.SplitString(szInfo, '/')
		local tInfo = {
			dwTime       = tonumber(aInfo[1]),
			nFont        = tonumber(aInfo[2]),
			nR           = tonumber(aInfo[3]),
			nG           = tonumber(aInfo[4]),
			nB           = tonumber(aInfo[5]),
			szChannel    = aInfo[6]          ,
			dwTalkerID   = tonumber(aInfo[7]),
			szTalkerName = aInfo[8]          ,
			szRawMessage = szRawMessage      ,
		}
		return tInfo
	end
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_Chat',
	exports = {
		{
			fields = {
				ParseMessageInfo = ParseMessageInfo,
				UnwrapRawMessage = UnwrapRawMessage,
			},
		},
	},
}
MY_Chat = X.CreateModule(settings)
end

X.HookChatPanel('BEFORE', 'MY_Chat', function(h, szMsg, ...)
	local aXMLNode = X.XMLDecode(szMsg)
	if aXMLNode then
		for _, node in ipairs(aXMLNode) do
			local szType = X.XMLGetNodeType(node)
			local szName = X.XMLGetNodeData(node, 'name')
			local szText = X.XMLGetNodeData(node, 'text')
			local szScript = X.XMLGetNodeData(node, 'script')
			if szType == 'text'
			and szName == 'eventlink'
			and szText == 'ReputationLink' then -- 修复官方通过 eventlink 实现声望文本时没有处理聊天数据的问题
				local szReputation = szScript:match('this.szLinkInfo=\"Reputation/(%d+)\"')
				if szReputation then
					local dwReputation = tonumber(szReputation)
					if dwReputation then
						local reputation = Table_GetReputationForceInfo(dwReputation)
						if reputation then
							X.XMLSetNodeData(node, 'text', '[' .. reputation.szName .. ']')
						end
					end
				end
			end
		end
		szMsg = X.XMLEncode(aXMLNode)
	end
	return szMsg
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
