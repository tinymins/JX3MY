--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 检测附近共战
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_GongzhanCheck'
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

local D = {}
local O = {
	nGongzhanPublishChannel = PLAYER_TALK_CHANNEL.LOCAL_SYS,
}

local tChannels = {
	{ nChannel = PLAYER_TALK_CHANNEL.LOCAL_SYS, szName = _L['PTC_LOCAL_SYS_CHANNEL'], rgb = GetMsgFontColor('MSG_SYS'   , true) },
	{ nChannel = PLAYER_TALK_CHANNEL.TEAM     , szName = _L['PTC_TEAM_CHANNEL'  ], rgb = GetMsgFontColor('MSG_TEAM'  , true) },
	{ nChannel = PLAYER_TALK_CHANNEL.RAID     , szName = _L['PTC_RAID_CHANNEL'  ], rgb = GetMsgFontColor('MSG_TEAM'  , true) },
	{ nChannel = PLAYER_TALK_CHANNEL.TONG     , szName = _L['PTC_TONG_CHANNEL'  ], rgb = GetMsgFontColor('MSG_GUILD' , true) },
}
function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	ui:Append('WndButton', {
		x = nW - 130, y = 30,
		text = _L['Check nearby gongzhan'],
		onLClick = function()
			if X.BreatheCall('MY_GongzhanCheck') then
				X.BreatheCall('MY_GongzhanCheck', false)
			else
				-- 逻辑：两次遍历附近的人 第一次同步数据 第二次输出数据
				local me = X.GetClientPlayer()
				local nChannel = O.nGongzhanPublishChannel or PLAYER_TALK_CHANNEL.LOCAL_SYS
				local dwTarType, dwTarID = X.GetCharacterTarget(me)
				local aPendingID = X.GetNearPlayerID() -- 等待扫描的玩家
				local aProcessID = X.Clone(aPendingID) -- 等待输出的玩家
				local aGongZhan = {} -- 扫描到的共战数据
				local nCount, nIndex = #aPendingID, 1
				local function Echo(nIndex, nCount)
					X.OutputAnnounceMessage(_L('Scanning gongzhan: %d/%d', nIndex, nCount))
				end
				X.RenderCall('MY_GongzhanCheck', function()
					local bTermial, bStep
					if nIndex <= nCount then -- 获取下一个有效的扫描目标
						local dwID = aPendingID[nIndex]
						local tar = X.GetPlayer(dwID)
						while not tar and nIndex <= nCount do
							Echo(nIndex, nCount * 2 + 1)
							nIndex = nIndex + 1
							dwID = aPendingID[nIndex]
							tar = X.GetPlayer(dwID)
						end
						if tar then
							local me = X.GetClientPlayer()
							local dwType, dwID = X.GetCharacterTarget(me)
							if dwType ~= TARGET.PLAYER or dwID ~= tar.dwID then -- 设置目标同步BUFF数据
								X.SetClientPlayerTarget(TARGET.PLAYER, tar.dwID)
							else
								Echo(nIndex, nCount * 2 + 1)
								nIndex = nIndex + 1
							end
						end
					elseif nIndex <= nCount * 2 then -- 获取下一个有效的输出目标
						local dwID = aProcessID[nIndex - nCount]
						local tar = X.GetPlayer(dwID)
						while not tar and nIndex <= nCount * 2 do
							Echo(nIndex, nCount * 2 + 1)
							nIndex = nIndex + 1
							dwID = aProcessID[nIndex - nCount]
							tar = X.GetPlayer(dwID)
						end
						if tar then
							local me = X.GetClientPlayer()
							local dwType, dwID = X.GetCharacterTarget(me)
							if dwType ~= TARGET.PLAYER or dwID ~= tar.dwID then -- 先设置目标才能获取BUFF数据
								X.SetClientPlayerTarget(TARGET.PLAYER, tar.dwID)
							else
								-- 检测是否有共战
								for _, buff in X.ipairs_c(X.GetBuffList(tar)) do
									if (not buff.bCanCancel) and string.find(Table_GetBuffName(buff.dwID, buff.nLevel), _L['GongZhan']) ~= nil then
										local info = Table_GetBuff(buff.dwID, buff.nLevel)
										if info and info.bShow ~= 0 then
											table.insert(aGongZhan, { szName = tar.szName, nTime = (buff.nEndFrame - GetLogicFrameCount()) / 16 })
										end
									end
								end
								Echo(nIndex, nCount * 2 + 1)
								nIndex = nIndex + 1
							end
						end
					else
						Echo(nIndex, nCount * 2 + 1)
						X.SendChat(nChannel, _L['------------------------------------'])
						for _, r in ipairs(aGongZhan) do
							X.SendChat(nChannel, _L('Detected [%s] has GongZhan buff for %s.', r.szName, X.FormatDuration(r.nTime, 'CHINESE')))
						end
						X.SendChat(nChannel, _L('Nearby GongZhan Total Count: %d.', #aGongZhan))
						X.SendChat(nChannel, _L['------------------------------------'])
						X.SetClientPlayerTarget(dwTarType, dwTarID)
						return 0
					end
				end)
			end
		end,
		menuRClick = function()
			local t = { { szOption = _L['send to ...'], bDisable = true }, { bDevide = true } }
			for _, tChannel in ipairs(tChannels) do
				table.insert( t, {
					szOption = tChannel.szName,
					rgb = tChannel.rgb,
					bCheck = true, bMCheck = true, bChecked = O.nGongzhanPublishChannel == tChannel.nChannel,
					fnAction = function()
						O.nGongzhanPublishChannel = tChannel.nChannel
					end
				} )
			end
			return t
		end,
	})
	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_GongzhanCheck',
	exports = {
		{
			fields = {
				OnPanelActivePartial = D.OnPanelActivePartial,
			},
		},
	},
}
MY_GongzhanCheck = X.CreateModule(settings)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
