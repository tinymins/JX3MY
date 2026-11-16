-- Run from the repository root with Lua 5.1.
-- Optional arguments: official macro.lua, original Game.Macro.lua.
local szSource = 'MY_!Base/src/lib/Game.Macro.lua'
local function ReadFile(szPath)
	local hFile = assert(io.open(szPath, 'rb'))
	local szText = hFile:read('*a')
	hFile:close()
	return szText
end

local szStringSource = ReadFile('MY_!Base/src/lib/String.lua')
local szStringHelpers = assert(szStringSource:match('(function X.SplitString.-)function X.EscapeString'))
	.. assert(szStringSource:match('(function X.TrimString.-)function X.EncryptString'))
local szSkill = string.char(204, 171, 188, 171, 206, 222, 188, 171) -- GBK skill name
local szBuff = string.char(204, 171, 188, 171) -- GBK buff name
local aCases = {}
local nChecks = 0

local function LoadValidator(bClassic, szPath)
	local X = {
		IS_CLASSIC = bClassic,
		PACKET_INFO = {FRAMEWORK_ROOT = ''},
		NSFormatString = function(szText) return szText end,
		ReportModuleLoading = function() end,
		IsDebugging = function() return false end,
		IsString = function(value) return type(value) == 'string' end,
		IsEmpty = function(value) return value == nil or value == '' end,
		StringFindW = function(szText, szNeedle, nStart)
			return string.find(szText, szNeedle, nStart, true)
		end,
		GetSkillByName = function(szName)
			return szName == szSkill or szName == 'Skill' or szName == 'Skill With Space'
		end,
		GetBuffByName = function(szName)
			return szName == szBuff or szName == 'Buff' or szName == 'Buff With Space'
		end,
		LoadLangPack = function() return function(szFormat, ...) return string.format(szFormat, ...) end end,
	}
	local tEnv = setmetatable({MY = X, X = X}, {__index = _G})
	setfenv(assert(loadstring(szStringHelpers)), tEnv)()
	setfenv(assert(loadfile(szPath or szSource)), tEnv)()
	return X
end

local X = LoadValidator(true)
local function Check(szText, bExpected, szError, nLine)
	local bValid, szActualError, nActualLine = X.IsMacroValid(szText)
	assert(bValid == bExpected, string.format('validity: %q expected %s, got %s (%s)',
		szText, tostring(bExpected), tostring(bValid), tostring(szActualError)))
	if szError then
		assert(szActualError == szError, szText .. ': ' .. tostring(szActualError))
		assert(nActualLine == (nLine or 1), 'wrong error line')
	end
	table.insert(aCases, szText)
	nChecks = nChecks + 1
end

-- The seven requested forms are the only new syntax covered by this patch.
local aRequested = {
	'/castself ' .. szSkill, '/fcastself ' .. szSkill,
	'/casttarget ' .. szSkill, '/fcasttarget ' .. szSkill,
	'/cast [skill_energy:' .. szSkill .. '=max] ' .. szSkill,
	'/cast [moon~=sun] ' .. szSkill, '/cast [sun~=moon] ' .. szSkill,
}
for _, szText in ipairs(aRequested) do
	Check(szText, true)
end
for _, szAction in ipairs({'cast', 'fcast', 'castself', 'fcastself', 'casttarget', 'fcasttarget'}) do
	Check('/' .. szAction .. ' [life>0.3] ' .. szSkill, true)
	Check('/' .. szAction .. ' [skill_energy:' .. szSkill .. '=max|moon~=sun&buff:' .. szBuff .. '>=2] ' .. szSkill, true)
	Check('/' .. szAction .. ' Unknown', false, 'UNKNOWN_ACTION_SKILL')
end
for _, szCondition in ipairs({
	'skill_energy:Skill=maxXYZ', 'skill_energy:Skill=MAX', 'skill_energy:Skill==max',
	'skill_energy:Skill~=max', 'skill_energy:Skill>=max', 'life=max', 'buff:Buff=max',
	'moon~=sunXYZ', 'sun~=moonXYZ', 'prefixsun~=moon', 'sun~=moon~=sun',
	'unknown=2',
}) do
	Check('/cast [' .. szCondition .. '] Skill', false, 'UNKNOWN_CONDITION')
end
Check('/cast [skill_energy:Unknown=max] Skill', false, 'UNKNOWN_CONDITION_SKILL')
Check('/cast [skill_energy:Skill =max] Skill', false, 'UNKNOWN_CONDITION_SKILL')
Check('/cast [buff:Buff >= 2] Skill', false, 'UNKNOWN_CONDITION_BUFF')
Check('/cast [skill_energy:Skill = 2] Skill', false, 'UNKNOWN_CONDITION_SKILL')
Check('/cast [last_skill=Unknown] Skill', false, 'UNKNOWN_ACTION_SKILL')
Check('/unknown Skill', false, 'UNKNOWN_ACTION')
Check('/cast Skill\n\n/unknown Skill', false, 'UNKNOWN_ACTION', 3)
Check('', true)

-- Compare unrelated legacy behavior, including strict name whitespace and
-- existing loose operator handling, instead of changing it in this patch.
local aUnchanged = {
	'/cast [buff:Buff >= 2] Skill', '/cast [skill_energy:Skill = 2] Skill',
	'/cast [buff: Buff] Skill', '/cast [nobuff:Buff ] Skill',
	'/cast [last_skill= Skill ] Skill', '/cast [last_skill=Unknown] Skill',
	'/cast [skill:Skill] Skill', '/cast [noskill:Skill] Skill',
	'/cast [skill_notin_cd:Skill] Skill', '/cast [npclevel>1] Skill',
	'/cast [yaoxing>1] Skill', '/cast[life>0] Skill',
	'/cast 123', '/cast [buff:456] Skill',
	'/cast [life>-1] Skill', '/cast [life>1e-3] Skill', '#description',
	'/cast [sun<moonXYZ] Skill', '/cast [life=1..2] Skill',
	'/cast [life=] Skill', '/cast [unknown=2] Skill',
	'/cast Skill\n\n/unknown Skill',
}
for _, szOperator in ipairs({'=', '~=', '<', '<=', '>', '>=', '==', '><', '=>', '=<', '~~', '~', '>>', '<>'}) do
	for _, szCondition in ipairs({
		'life' .. szOperator .. '2', 'buff:Buff' .. szOperator .. '2',
		'skill_energy:Skill' .. szOperator .. '2', 'last_skill' .. szOperator .. 'Skill',
	}) do
		table.insert(aUnchanged, '/cast [' .. szCondition .. '] Skill')
	end
end
if arg[2] then
	local function Compare(tBefore, tAfter, szText)
		local aBefore, aAfter = {tBefore.IsMacroValid(szText)}, {tAfter.IsMacroValid(szText)}
		for nIndex = 1, 4 do
			assert(aBefore[nIndex] == aAfter[nIndex], 'unrelated behavior changed: ' .. szText)
		end
	end
	local tOldClassic = LoadValidator(true, arg[2])
	for _, szText in ipairs(aRequested) do
		assert(not tOldClassic.IsMacroValid(szText), 'baseline no longer reproduces: ' .. szText)
	end
	for _, szText in ipairs(aUnchanged) do
		Compare(tOldClassic, X, szText)
	end
	local tOldRemake, tRemake = LoadValidator(false, arg[2]), LoadValidator(false)
	for _, aInputs in ipairs({aCases, aUnchanged}) do
		for _, szText in ipairs(aInputs) do
			Compare(tOldRemake, tRemake, szText)
		end
	end
	print('PASS seven original failures reproduced; unchanged classic cases: ' .. #aUnchanged)
	print('PASS remake differential: ' .. (#aCases + #aUnchanged) .. ' inputs')
end

if arg[1] then
	local tPlayer = {
		nCurrentSunEnergy = 2000, nCurrentMoonEnergy = 4000,
		GetCDMaxCount = function() return 3, 1 end,
		GetCDLeft = function() return 0, 3 end,
		GetBuffCount = function() return 1 end,
	}
	local tEnv = setmetatable({
		RegisterEvent = function() end,
		g_tStrings = {
			CHUNJIE_TIGER_COMMAND = {'t1', 't2', 't3', 't4', 't5'},
			CHUNJIE_RABBIT_COMMAND = {'r1', 'r2', 'r3', 'r4', 'r5'},
			CHUNJIE_DRAGON_COMMAND = {'d1', 'd2', 'd3', 'd4', 'd5'},
			TangMenPig = {'p1', 'p2', 'p3', 'p4', 'p5'},
			COMMAND_PLAYED = {PLAYED = 'alias_played', CREATETIME = 'alias_createtime'},
		},
		FORCE_TYPE = {MING_JIAO = 1},
		MACRO_SKILL_CAST_MODE = {SELF = 1, TARGET = 2},
		Kungfu_GetPlayerMountType = function() return 1 end,
		GetClientPlayer = function() return tPlayer end,
		StringFindW = function(szText, szNeedle, nStart) return string.find(szText, szNeedle, nStart, true) end,
		SplitString = X.SplitString,
		g_SkillNameToID = {Skill = 123},
		UI_GetClientPlayerID = function() return 9 end,
		Buffer_Get = function(_, _, tBuff)
			tBuff.dwID, tBuff.nLevel, tBuff.dwSkillSrcID, tBuff.nStackNum = 1, 1, 9, 2
		end,
		Table_GetBuffName = function() return 'Buff' end,
		SetIsMacroSkillCasting = function() end,
	}, {__index = _G})
	local szProbe = '\nreturn {judge = JudgeCondition, setCast = function(fn) try_cast = fn end}'
	local tOfficial = setfenv(assert(loadstring(ReadFile(arg[1]) .. szProbe)), tEnv)()
	for _, szCondition in ipairs({'skill_energy:Skill=max', 'sun~=moon', 'moon~=sun'}) do
		assert(tOfficial.judge(szCondition), 'official condition mismatch: ' .. szCondition)
	end
	for _, tCase in ipairs({{'cast', nil, nil}, {'fcast', true, nil},
		{'castself', nil, 1}, {'fcastself', true, 1}, {'casttarget', nil, 2}, {'fcasttarget', true, 2}}) do
		local bCalled = false
		tOfficial.setCast(function(szName, bForce, _, nMode)
			assert(szName == 'Skill' and bForce == tCase[2] and nMode == tCase[3])
			bCalled = true
		end)
		local szText = '/' .. tCase[1] .. ' [skill_energy:Skill=max] Skill'
		assert(X.IsMacroValid(szText))
		local tOpt = tEnv.GetOptData(szText)
		tEnv.GetMacroAction(tOpt.cmd)(tOpt.cmd_param, tOpt.condition)
		assert(bCalled, 'official action not called: ' .. tCase[1])
	end
	print('PASS official macro.lua conditions and SELF/TARGET dispatch (mocked skill cast)')
end
print('PASS classic validation: ' .. nChecks .. ' cases; ' .. _VERSION)
