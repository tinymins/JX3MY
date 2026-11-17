--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 试炼之地九宫助手
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_JiugongHelper'
local PLUGIN_NAME = 'MY_Toolbox'
local PLUGIN_ROOT = X.PACKET_INFO.ROOT .. PLUGIN_NAME
local MODULE_NAME = 'MY_Toolbox'
local _L = X.LoadLangPack(PLUGIN_ROOT .. '/lang/')
--------------------------------------------------------------------------
if not X.AssertVersion(MODULE_NAME, _L[MODULE_NAME], '^29.0.14') then
	return
end
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
X.RegisterRestriction('MY_JiugongHelper', { ['*'] = true, intl = false })
--------------------------------------------------------------------------

local O = X.CreateUserSettingsModule('MY_JiugongHelper', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_JiugongHelper'],
			_L['Enable'],
		}),
		szRestriction = 'MY_JiugongHelper',
		xSchema = X.Schema.Boolean,
		xDefaultValue = true,
	},
})
local D = {}

function D.Apply()
	if D.bReady then
		X.RegisterEvent('OPEN_WINDOW', 'JIUGONG_HELPER', function(event)
			if X.IsRestricted('MY_JiugongHelper') then
				return
			end
			-- 确定当前对话对象是醉逍遥（18707）
			local target = GetTargetHandle(X.GetClientPlayer().GetTarget())
			if target and target.dwTemplateID ~= 18707 then
				return
			end
			local szText = arg1
			-- 匹配字符串
			string.gsub(szText, '<T1916><(T%d+)><T1926><(T%d+)><T1928><(T%d+)><T1924>.+<T1918><(T%d+)><T1931><(T%d+)><T1933><(T%d+)><T1935>.+<T1920><(T%d+)><T1937><(T%d+)><T1938><(T%d+)><T1939>', function(n1,n2,n3,n4,n5,n6,n7,n8,n9)
				local tNumList = {
					T1925 = 1, T1927 = 2, T1929 = 3,
					T1930 = 4, T1932 = 5, T1934 = 6,
					T1936 = 7, T1922 = 8, T1923 = 9,
					T1940 = false,
				}
				local tDefaultSolution = {
					{8,1,6,3,5,7,4,9,2},
					{6,1,8,7,5,3,2,9,4},
					{4,9,2,3,5,7,8,1,6},
					{2,9,4,7,5,3,6,1,8},
					{6,7,2,1,5,9,8,3,4},
					{8,3,4,1,5,9,6,7,2},
					{2,7,6,9,5,1,4,3,8},
					{4,3,8,9,5,1,2,7,6},
				}

				n1,n2,n3,n4,n5,n6,n7,n8,n9 = tNumList[n1],tNumList[n2],tNumList[n3],tNumList[n4],tNumList[n5],tNumList[n6],tNumList[n7],tNumList[n8],tNumList[n9]
				local tQuestion = {n1,n2,n3,n4,n5,n6,n7,n8,n9}
				local tSolution
				for _, solution in ipairs(tDefaultSolution) do
					local bNotMatch = false
					for i, v in ipairs(solution) do
						if tQuestion[i] and tQuestion[i] ~= v then
							bNotMatch = true
							break
						end
					end
					if not bNotMatch then
						tSolution = solution
						break
					end
				end
				local szText
				if tSolution then
					local szSequence = ''
					for i, v in ipairs(tQuestion) do
						szSequence = szSequence .. NumberToChinese(tSolution[i])
						if not tQuestion[i] then
							szSequence = szSequence
						end
						szSequence = szSequence .. ' '
					end
					local szBlank = ''
					for i, v in ipairs(tQuestion) do
						if not tQuestion[i] then
							szBlank = szBlank .. NumberToChinese(tSolution[i]) .. ' '
						end
					end
					szText = _L('The jiugong full sequence is: %s, blank is: %s.', szSequence, szBlank)
				else
					szText = _L['Failed to calc.']
				end
				X.OutputSystemMessage(szText)
				OutputWarningMessage('MSG_WARNING_RED', szText, 10)
			end)
		end)
	else
		X.RegisterEvent('OPEN_WINDOW', 'JIUGONG_HELPER', false)
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
	name = 'MY_JiugongHelper',
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
MY_JiugongHelper = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterUserSettingsInit('MY_JiugongHelper', function()
	D.bReady = true
	D.Apply()
end)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
