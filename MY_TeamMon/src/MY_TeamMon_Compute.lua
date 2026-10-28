--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @desc     : Data-defined variables for spell timers
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
local D = {}
local MAX_VARIABLES, MAX_DEPTH, MAX_NODES = 32, 16, 256
local MAX_EXCLUSIONS = 8
local COMPARISONS = { ['=='] = true, ['~='] = true, ['<'] = true, ['<='] = true, ['>'] = true, ['>='] = true }
local BINARY = {
	add = function(nLeft, nRight) return nLeft + nRight end,
	sub = function(nLeft, nRight) return nLeft - nRight end,
	mul = function(nLeft, nRight) return nLeft * nRight end,
	div = function(nLeft, nRight) assert(nRight ~= 0, 'division by zero'); return nLeft / nRight end,
	min = math.min,
	max = math.max,
	lt = function(nLeft, nRight) return nLeft < nRight end,
	le = function(nLeft, nRight) return nLeft <= nRight end,
	eq = function(nLeft, nRight) return nLeft == nRight end,
	ge = function(nLeft, nRight) return nLeft >= nRight end,
	gt = function(nLeft, nRight) return nLeft > nRight end,
}
local UNARY = { floor = math.floor, ceil = math.ceil, abs = math.abs }

local function IsFinite(nValue)
	return type(nValue) == 'number' and nValue == nValue and math.abs(nValue) < math.huge
end

local function ArrayLength(aValues, nMax)
	assert(type(aValues) == 'table', 'expected an array')
	local nLength, nCount = #aValues, 0
	assert(nLength <= nMax, 'too many entries')
	for nIndex in pairs(aValues) do
		assert(type(nIndex) == 'number' and nIndex % 1 == 0 and nIndex >= 1 and nIndex <= nLength, 'invalid array')
		nCount = nCount + 1
	end
	assert(nCount == nLength, 'sparse array')
	return nLength
end

local function CheckName(szName, tValues)
	assert(type(szName) == 'string' and #szName <= 64 and szName:match('^calc_[%w_]+$'), 'invalid variable name')
	assert(tValues[szName] == nil, 'duplicate variable: ' .. szName)
end

local function Evaluate(tConfig, aBackreferences)
	assert(type(tConfig) == 'table' and tConfig.nVersion == 1, 'unsupported variable schema')
	assert(type(tConfig.szUnavailable) == 'string' and #tConfig.szUnavailable > 0, 'missing unavailable text')
	assert(tConfig.nDebounce == nil or (IsFinite(tConfig.nDebounce) and tConfig.nDebounce >= 50
		and tConfig.nDebounce <= 1000), 'invalid debounce interval')
	assert(tConfig.bUpdate == nil or type(tConfig.bUpdate) == 'boolean', 'invalid update option')
	local aQueries, aValues = tConfig.aQueries or {}, tConfig.aValues or {}
	ArrayLength(aQueries, MAX_VARIABLES)
	ArrayLength(aValues, MAX_VARIABLES)
	assert(X.GetClientPlayer(), 'player unavailable')
	assert(MY_TeamMon.bEnable and not X.IsRestricted('MY_TeamMon'), 'team monitor unavailable')
	assert(not X.IsRestricted('MY_TeamMon.MapRestriction') or X.IsInDungeonMap(), 'team queries restricted in this map')
	local tValues, tMembers, tSeen = {}, {}, {}
	if #aQueries > 0 then
		for _, dwID in ipairs(X.GetTeamMemberList()) do
			if not tSeen[dwID] then
				local tInfo = X.GetTeamMemberInfo(dwID)
				assert(tInfo and type(tInfo.bOnline) == 'boolean', 'team member information unavailable')
				tMembers[#tMembers + 1] = { info = tInfo, player = X.GetPlayer(dwID), buffs = {} }
				tSeen[dwID] = true
			end
		end
		assert(#tMembers > 0, 'team unavailable')
	end
	local function ReadStack(tMember, dwID, nLevel)
		assert(tMember.player, 'online team member is not readable')
		local szKey = dwID .. ':' .. nLevel
		if tMember.buffs[szKey] == nil then
			assert(not X.IsRestricted('MY_TeamMon.HiddenBuff') or X.IsVisibleBuff(dwID, nLevel > 0 and nLevel or 1), 'buff restricted')
			local tBuff = X.GetBuff(tMember.player, dwID, nLevel)
			local nStack = 0
			if tBuff and tBuff.bValid ~= false then
				nStack = tBuff.nStackNum
			end
			assert(IsFinite(nStack) and nStack >= 0, 'invalid buff stack')
			tMember.buffs[szKey] = nStack
		end
		return tMember.buffs[szKey]
	end
	for _, tQuery in ipairs(aQueries) do
		assert(type(tQuery) == 'table', 'invalid query')
		CheckName(tQuery.szName, tValues)
		assert(IsFinite(tQuery.dwBuffID) and tQuery.dwBuffID > 0 and tQuery.dwBuffID % 1 == 0, 'invalid buff ID')
		local nLevel, nStack = tQuery.nLevel or 0, tQuery.nStackNum or 1
		local szOp, szAggregate = tQuery.szStackOp or '>=', tQuery.szAggregate or 'count'
		assert(IsFinite(nLevel) and nLevel >= 0 and nLevel % 1 == 0, 'invalid buff level')
		assert(IsFinite(nStack) and COMPARISONS[szOp], 'invalid stack condition')
		assert(szAggregate == 'count' or szAggregate == 'sum', 'invalid aggregate')
		assert(tQuery.bAliveOnly == nil or type(tQuery.bAliveOnly) == 'boolean', 'invalid alive condition')
		assert(not (tQuery.dwExcludeBuffID and tQuery.aExcludeBuffIDs), 'conflicting exclusion fields')
		local aExclusions = tQuery.aExcludeBuffIDs or (tQuery.dwExcludeBuffID and { tQuery.dwExcludeBuffID }) or {}
		ArrayLength(aExclusions, MAX_EXCLUSIONS)
		for _, dwBuffID in ipairs(aExclusions) do
			assert(IsFinite(dwBuffID) and dwBuffID > 0 and dwBuffID % 1 == 0, 'invalid excluded buff ID')
		end
		local nValue = 0
		for _, tMember in ipairs(tMembers) do
			local tInfo = tMember.info
			assert(not tInfo.bOnline or not tQuery.bAliveOnly or type(tInfo.bDeathFlag) == 'boolean', 'life state unavailable')
			if tInfo.bOnline and (not tQuery.bAliveOnly or not tInfo.bDeathFlag) then
				local nCount = ReadStack(tMember, tQuery.dwBuffID, nLevel)
				local bExcluded = false
				for _, dwBuffID in ipairs(aExclusions) do
					if ReadStack(tMember, dwBuffID, 0) > 0 then
						bExcluded = true
						break
					end
				end
				if not bExcluded and X.JudgeOperator(szOp, nCount, nStack) then
					nValue = nValue + (szAggregate == 'sum' and nCount or 1)
				end
			end
		end
		tValues[tQuery.szName] = nValue
	end
	local nNodes = 0
	local function Eval(oExpression, nDepth)
		nNodes = nNodes + 1
		assert(nDepth <= MAX_DEPTH and nNodes <= MAX_NODES, 'expression limit exceeded')
		if type(oExpression) == 'number' then
			assert(IsFinite(oExpression), 'non-finite literal')
			return oExpression
		end
		if type(oExpression) == 'string' then
			assert(tValues[oExpression] ~= nil, 'unknown variable: ' .. oExpression)
			return tValues[oExpression]
		end
		local nLength = ArrayLength(oExpression, 4)
		local szOp = oExpression[1]
		if szOp == 'if' then
			assert(nLength == 4, 'invalid if expression')
			local bCondition = Eval(oExpression[2], nDepth + 1)
			assert(type(bCondition) == 'boolean', 'expected a boolean condition')
			return Eval(oExpression[bCondition and 3 or 4], nDepth + 1)
		end
		local fnUnary = UNARY[szOp]
		if fnUnary then
			assert(nLength == 2, 'invalid unary expression')
			local nValue = Eval(oExpression[2], nDepth + 1)
			assert(IsFinite(nValue), 'expected a numeric operand')
			return fnUnary(nValue)
		end
		local fnBinary = BINARY[szOp]
		assert(fnBinary and nLength == 3, 'invalid binary expression')
		local nLeft, nRight = Eval(oExpression[2], nDepth + 1), Eval(oExpression[3], nDepth + 1)
		assert(IsFinite(nLeft) and IsFinite(nRight), 'expected numeric operands')
		return fnBinary(nLeft, nRight)
	end
	for _, tValue in ipairs(aValues) do
		assert(type(tValue) == 'table', 'invalid calculated value')
		CheckName(tValue.szName, tValues)
		local nValue = Eval(tValue.tExpression, 1)
		assert(IsFinite(nValue), 'expected a finite numeric result')
		tValues[tValue.szName] = nValue
	end
	local tResult = X.Clone(aBackreferences) or {}
	for szName, nValue in pairs(tValues) do
		tResult[szName] = nValue
	end
	return tResult
end

function D.Evaluate(tConfig, aBackreferences)
	local bSuccess, tResult = pcall(Evaluate, tConfig, aBackreferences)
	if bSuccess then
		return tResult
	end
	return nil, tostring(tResult)
end

function D.WatchesBuff(tConfig, dwBuffID)
	if type(tConfig) ~= 'table' or tConfig.bUpdate ~= true or type(tConfig.aQueries) ~= 'table' then
		return false
	end
	for nIndex = 1, math.min(#tConfig.aQueries, MAX_VARIABLES) do
		local tQuery = tConfig.aQueries[nIndex]
		if type(tQuery) == 'table' then
			if tQuery.dwBuffID == dwBuffID or tQuery.dwExcludeBuffID == dwBuffID then
				return true
			end
			if type(tQuery.aExcludeBuffIDs) == 'table' then
				for nExcludeIndex = 1, math.min(#tQuery.aExcludeBuffIDs, MAX_EXCLUSIONS) do
					if tQuery.aExcludeBuffIDs[nExcludeIndex] == dwBuffID then
						return true
					end
				end
			end
		end
	end
	return false
end

MY_TeamMon_Compute = X.CreateModule({
	name = 'MY_TeamMon_Compute',
	exports = {{ root = D, fields = { 'Evaluate', 'WatchesBuff' } }},
})
