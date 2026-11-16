-- Run from the repository root with Lua 5.1: lua tests/team_mon_compute.lua
-- Uses real calculator, template, countdown dispatch and timer code; game/UI are fixtures.
local nPassed, nFailed = 0, 0
local function Equal(a, b)
	assert(a == b, tostring(a) .. ' ~= ' .. tostring(b))
end
local function Near(a, b)
	assert(math.abs(a - b) < 0.00001, tostring(a) .. ' ~= ' .. tostring(b))
end
local function Test(szName, fnTest)
	local bOK, szError = pcall(fnTest)
	if bOK then
		nPassed = nPassed + 1
		print('PASS ' .. szName)
		return
	end
	nFailed = nFailed + 1
	print('FAIL ' .. szName .. ': ' .. tostring(szError))
end
local function Clone(oValue)
	if type(oValue) ~= 'table' then
		return oValue
	end
	local tResult = {}
	for k, v in pairs(oValue) do
		tResult[k] = Clone(v)
	end
	return tResult
end
local function Serialize(oValue)
	if type(oValue) ~= 'table' then
		return type(oValue) .. ':' .. tostring(oValue)
	end
	local aKeys, aResult = {}, {}
	for k in pairs(oValue) do
		aKeys[#aKeys + 1] = k
	end
	table.sort(aKeys, function(a, b) return tostring(a) < tostring(b) end)
	for _, k in ipairs(aKeys) do
		aResult[#aResult + 1] = Serialize(k) .. '=' .. Serialize(oValue[k])
	end
	return '{' .. table.concat(aResult, ',') .. '}'
end
local function Read(szPath)
	local hFile = assert(io.open(szPath, 'rb'))
	local szText = hFile:read('*a')
	hFile:close()
	return szText
end
local function Extract(szText, szStart, szEnd)
	local nStart = assert(szText:find(szStart, 1, true))
	local nEnd = assert(szText:find(szEnd, nStart + #szStart, true))
	return szText:sub(nStart, nEnd - 1)
end

local nNow, nReads, nVoices, nWrites = 0, 0, 0, 0
local tPlayers, tInfo, aMembers, tRestrictions = {}, {}, {}, {}
local bInDungeon = true
local aItems, aDebug = {}, {}
local function Node()
	local h = { text = '' }
	function h:SetText(szText) self.text = szText; nWrites = nWrites + 1 end
	function h:GetText() return self.text end
	function h:SetPercentage(nValue) self.percentage = nValue end
	for _, szName in ipairs({ 'SetFontColor', 'SetColorRGB', 'SetObject', 'SetObjectIcon', 'Set2DRotation', 'SetRelX', 'SetW',
		'SetAlpha', 'SetFrame' }) do
		h[szName] = function() end
	end
	return h
end
local hList = {}
function hList:AppendItemFromData()
	local h = { valid = true, nodes = {} }
	function h:IsValid() return self.valid end
	function h:Lookup(szName)
		self.nodes[szName] = self.nodes[szName] or Node()
		return self.nodes[szName]
	end
	function h:Show() end
	function h:FormatAllItemPos() end
	function h:SetUserData(nValue) self.userData = nValue end
	aItems[#aItems + 1] = h
	return h
end
function hList:RemoveItem(h) h.valid = false end
function hList:Clear()
	for _, h in ipairs(aItems) do h.valid = false end
end
function hList:Sort() end
function hList:FormatAllItemPos() end
this = {}
function this:RegisterEvent() end
function this:CreateItemData() return {} end
function this:Lookup() return hList end
function this:SetPoint() end
function this:CorrectPos() end

MY = {
	Clone = Clone, EncodeLUAData = Serialize,
	PACKET_INFO = { ROOT = '', FRAMEWORK_ROOT = '' }, PATH_TYPE = { ROLE = 1 }, DEBUG_LEVEL = { ERROR = 1 },
	Schema = {}, CONSTANT = { MSG_THEME = {} },
	IsTable = function(v) return type(v) == 'table' end,
	IsNil = function(v) return v == nil end,
	IsEmpty = function(v) return v == nil or v == '' or (type(v) == 'table' and next(v) == nil) end,
	IsNumber = function(v) return type(v) == 'number' end,
	IsString = function(v) return type(v) == 'string' end,
	StringFindW = function(s, p, i) return s:find(p, i, true) end,
	StringLenW = string.len, StringSubW = string.sub,
	ReplaceSensitiveWord = function(v) return v end,
	GetClientPlayerName = function() return 'self' end,
	GetClientPlayerID = function() return 1 end,
	GetClientPlayer = function() return tPlayers[1] end,
	GetTeamMemberList = function() return aMembers end,
	GetTeamMemberInfo = function(dwID) return tInfo[dwID] end,
	GetPlayer = function(dwID) return tPlayers[dwID] end,
	GetBuff = function(kPlayer, dwID, nLevel)
		nReads = nReads + 1
		local tBuff = kPlayer.buffs[dwID]
		if tBuff and (nLevel == 0 or nLevel == tBuff.nLevel) then
			return tBuff
		end
	end,
	IsTeammate = function(dwID) return tInfo[dwID] ~= nil end,
	IsRestricted = function(szKey) return tRestrictions[szKey] or false end,
	IsInDungeonMap = function() return bInDungeon end,
	IsVisibleBuff = function() return true end,
	NSFormatString = function(s) return s end,
	AssertVersion = function() return true end,
	ReportModuleLoading = function() end,
	RegisterRestriction = function() end,
	RegisterEvent = function() end,
	RegisterUserSettingsInit = function() end,
	RegisterUserSettingsRelease = function() end,
	MakeCaption = function() return '' end,
	FormatDuration = function(n) return tostring(n) end,
	OutputDebugMessage = function(s) aDebug[#aDebug + 1] = s end,
	OutputSystemMessage = function() error('unexpected timer format error') end,
}
function MY.SplitString(szText, szSeparator)
	local aParts, nPosition = {}, 1
	while true do
		local nStart, nEnd = szText:find(szSeparator, nPosition, true)
		local szPart = szText:sub(nPosition, nStart and nStart - 1 or #szText)
		if szPart ~= '' then
			aParts[#aParts + 1] = szPart
		end
		if not nStart then
			return aParts
		end
		nPosition = nEnd + 1
	end
end
function MY.LoadLangPack()
	return setmetatable({}, { __index = function(_, k) return k end,
		__call = function(_, s, ...) return string.format(s, ...) end })
end
function MY.CreateUserSettingsModule(_, _, tFields)
	local tResult = {}
	for k, v in pairs(tFields) do tResult[k] = Clone(v.xDefaultValue) end
	return tResult
end
function MY.CreateModule(tSettings)
	local tResult = {}
	for _, tExport in ipairs(tSettings.exports) do
		if tExport.preset == 'UIEvent' then
			for k, v in pairs(tExport.root) do tResult[k] = v end
		end
		for _, szName in ipairs(tExport.fields or {}) do tResult[szName] = tExport.root[szName] end
	end
	return tResult
end
GetTime = function() return nNow end
UI_OBJECT_NOT_NEED_KNOWN = 0
PLAYER_TALK_CHANNEL = { RAID = 1 }
local function Emit(szEvent, ...)
	local aOld, aArgs = {}, { ... }
	for i = 0, 11 do aOld[i] = _G['arg' .. i]; _G['arg' .. i] = aArgs[i + 1] end
	MY_TeamMon_SpellTimer.OnEvent(szEvent)
	for i = 0, 11 do _G['arg' .. i] = aOld[i] end
end
function FireUIEvent(szEvent, ...)
	if szEvent == 'MY_TEAM_MON__VOICE_ALARM' then
		nVoices = nVoices + 1
		return
	end
	Emit(szEvent, ...)
end

assert(loadfile('MY_!Base/src/lib/Game.String.lua'))()
assert(loadfile('MY_!Base/src/lib/System.Operator.lua'))()
local szCore = Read('MY_TeamMon/src/MY_TeamMon.lua')
local szHelpers = Extract(szCore, 'local function RenderCustomText(', 'local function ConstructSpeech(')
local szParser = szCore:sub(assert(szCore:find('local function ParseCountdown(', 1, true)),
	assert(szCore:find('local function ParseHPCountdown(', 1, true)) - 1)
X = MY
CACHE = { CD_STR = {} }
MY_SplitString = MY.SplitString
D, O = {}, { bPushTeamChannel = false }
MY_TEAM_MON_TYPE = { COMMON = 15, SKILL_BEGIN = 8, NPC_LEAVE = 4, BUFF_GET = 1 }
assert(loadstring(szHelpers .. szParser
	.. Extract(szCore, 'function D.GetCountdownTypeKey(', 'function D.GetSrcName(')
	.. '\nD.FilterCustomText=FilterCustomText;D.ParseCountdown=ParseCountdown'))()
MY_TeamMon = D
MY_TeamMon.bEnable, MY_TeamMon.bPushVoiceAlarm = true, true
MY_TeamMon.MY_TEAM_MON_TYPE = MY_TEAM_MON_TYPE
assert(loadfile('MY_TeamMon/src/MY_TeamMon_Compute.lua'))()
assert(loadfile('MY_TeamMon/src/MY_TeamMon_SpellTimer.lua'))()
MY_TeamMon_SpellTimer.OnFrameCreate()

local function World()
	hList:Clear()
	nNow, nReads, nVoices, nWrites = 0, 0, 0, 0
	tPlayers, tInfo, aMembers, tRestrictions = {}, {}, {}, {}
	bInDungeon, MY_TeamMon.bEnable = true, true
	for i = 1, 25 do
		aMembers[i] = i
		tInfo[i] = { bOnline = true, bDeathFlag = false }
		tPlayers[i] = { dwID = i, buffs = {}, IsInParty = function() return true end }
		if i <= 10 then
			tPlayers[i].buffs[1001] = { nLevel = 1, nStackNum = 2 }
		end
		if i > 10 and i <= 15 then
			tPlayers[i].buffs[1002] = { nLevel = 1, nStackNum = 1 }
		end
	end
	Emit('MY_TEAM_MON__SPELL_TIMER__CLEAR')
end
local function Config()
	return { nVersion = 1, szUnavailable = 'waiting', bUpdate = true, aQueries = {
		{ szName = 'calc_red2', dwBuffID = 1001, nStackNum = 2, szStackOp = '==', bAliveOnly = true },
		{ szName = 'calc_black', dwBuffID = 1002, bAliveOnly = true },
	}, aValues = {{ szName = 'calc_diff', tExpression = { 'sub', 'calc_black', 'calc_red2' } }} }
end
local function Item(tConfig, oTime, szKey)
	return { dwID = 9001, nLevel = 1, tCountdown = {{ nClass = 8, key = szKey, nTime = oTime or 20,
		nRefresh = 0, szName = 'R2x{$calc_red2} Bx{$calc_black} {$sender} {$1}', tVars = tConfig }} }
end
local function Start(tConfig, oTime, szKey)
	MY_TeamMon.CountdownEvent(Item(tConfig, oTime, szKey), 8, 'boss', 'self', { 'capture' })
	return aItems[#aItems]
end
local function Tick(nTime)
	nNow = nTime
	MY_TeamMon_SpellTimer.OnFrameBreathe()
end
local function Buff(dwOwner, dwID, nStack)
	tPlayers[dwOwner].buffs[dwID] = nStack and { nLevel = 1, nStackNum = nStack } or nil
	Emit('BUFF_UPDATE', dwOwner, not nStack, 1, false, dwID, nStack or 0, 0, false, 1, 1)
end

local function SixWorld()
	World()
	for i = 1, 25 do
		tPlayers[i].buffs = {}
	end
	for _, aRange in ipairs({ { 1, 4, 34095, 1 }, { 5, 9, 34095, 2 }, { 16, 18, 34096, 1 },
		{ 19, 21, 34096, 2 }, { 22, 22, 34095, 3 }, { 23, 23, 34095, 4 },
		{ 24, 24, 34096, 3 }, { 25, 25, 34096, 4 } }) do
		for i = aRange[1], aRange[2] do
			tPlayers[i].buffs[aRange[3]] = { nLevel = 1, nStackNum = aRange[4] }
		end
	end
	for _, i in ipairs({ 9, 15, 21, 25 }) do
		tPlayers[i].buffs[34097] = { nLevel = 1, nStackNum = 1 }
	end
end
local function SixExample()
	return assert(loadfile('MY_TeamMon/docs/examples/six-state-countdown.lua'))()
end
local function SixResult()
	return assert(MY_TeamMon_Compute.Evaluate(SixExample().tCountdown[1].tVars))
end
local function SixSum(tValues)
	return tValues.calc_red1 + tValues.calc_red2 + tValues.calc_zero
		+ tValues.calc_black1 + tValues.calc_black2 + tValues.calc_other
end

Test('25-player count, grouping, formula and capture variables', function()
	World()
	local tResult = assert(MY_TeamMon_Compute.Evaluate(Config(), { [1] = 'capture' }))
	Equal(tResult.calc_red2, 10); Equal(tResult.calc_black, 5); Equal(tResult.calc_diff, -5); Equal(tResult[1], 'capture')
	local h = Start(Config(), 20, 'counts')
	Equal(h.txt:GetText(), 'R2x10 Bx5 boss capture')
end)
Test('query sums, absence, isolation exclusion, death and offline filters', function()
	World()
	tPlayers[1].buffs[1003] = { nLevel = 1, nStackNum = 1 }
	tInfo[2].bDeathFlag = true; tInfo[3].bOnline = false; tPlayers[3] = nil
	local t = Config(); t.aQueries[1].dwExcludeBuffID = 1003
	Equal(assert(MY_TeamMon_Compute.Evaluate(t)).calc_red2, 7)
	t.aQueries[1].szAggregate = 'sum'
	Equal(assert(MY_TeamMon_Compute.Evaluate(t)).calc_red2, 14)
	t.aQueries[1].dwExcludeBuffID = nil; t.aQueries[1].szAggregate = 'count'; t.aQueries[1].nStackNum = 0
	Equal(assert(MY_TeamMon_Compute.Evaluate(t)).calc_red2, 15)
end)
Test('missing online player is unavailable, not a zero stack', function()
	World(); tPlayers[4] = nil
	local r, e = MY_TeamMon_Compute.Evaluate(Config())
	Equal(r, nil); assert(e:find('not readable', 1, true))
	Equal(Start(Config(), 20, 'missing').txt:GetText(), 'waiting')
end)
Test('missing player recovers on scene event', function()
	World(); local p = tPlayers[4]; tPlayers[4] = nil
	local h = Start(Config(), 20, 'recovery')
	tPlayers[4] = p; Emit('PLAYER_ENTER_SCENE', 4); Tick(101)
	Equal(h.txt:GetText(), 'R2x10 Bx5 boss capture')
end)
Test('Buff stack change preserves timer start, deadline and progress', function()
	World(); local h = Start(Config(), 20, 'update')
	nNow = 5000; Buff(1, 1001, 3); Tick(5050)
	Equal(h.txt:GetText(), 'R2x10 Bx5 boss capture')
	Tick(5101)
	Equal(h.txt:GetText(), 'R2x9 Bx5 boss capture')
	Equal(h.nCreate, 0); Equal(h.nLeft, 0); Equal(h.countdown, 20)
	Near(h.img.percentage, (20 - 5.101) / 20)
end)
Test('Buff gain and deletion both update aggregate values', function()
	World(); local h = Start(Config(), 20, 'gain-loss')
	Buff(20, 1002, 1); Tick(101); Equal(h.txt:GetText(), 'R2x10 Bx6 boss capture')
	Buff(11, 1002, nil); Tick(202); Equal(h.txt:GetText(), 'R2x10 Bx5 boss capture')
end)
Test('unrelated Buff and non-team events do not query or update', function()
	World(); Start(Config(), 20, 'irrelevant'); local nBefore = nReads
	Buff(1, 9999, 1); Emit('BUFF_UPDATE', 999, false, 1, false, 1001, 2); Tick(200)
	Equal(nReads, nBefore)
end)
Test('burst updates are coalesced with a bounded wait', function()
	World(); local h = Start(Config(), 20, 'burst'); local nBefore = nReads
	Buff(1, 1001, 3); nNow = 80; Buff(2, 1001, 3); Tick(101)
	Equal(h.txt:GetText(), 'R2x8 Bx5 boss capture'); Equal(nReads - nBefore, 50)
end)
Test('unchanged result does not rewrite action text', function()
	World(); local h = Start(Config(), 20, 'unchanged')
	local nCalls = 0; local fnSet = h.txt.SetText
	h.txt.SetText = function(self, s) nCalls = nCalls + 1; fnSet(self, s) end
	Buff(1, 1001, 2); Tick(101); Equal(nCalls, 0)
end)
Test('multisegment update changes future text without replaying voice', function()
	World(); local h = Start(Config(), '5,First {$calc_red2},VO:one;10,Second {$calc_black},VO:two;', 'segments')
	Equal(nVoices, 1)
	nNow = 1000; Buff(1, 1001, 3); Buff(11, 1002, nil); Tick(1101)
	Equal(h.txt:GetText(), 'First 9'); Equal(h.countdown[2].szContent, 'Second 4'); Equal(nVoices, 1)
	Tick(5100); Equal(h.txt:GetText(), 'Second 4'); Equal(nVoices, 2)
	nNow = 6000; Buff(12, 1002, nil); Tick(6101)
	Equal(h.txt:GetText(), 'Second 3'); Equal(nVoices, 2)
	Near(h.countdown[1].nTime - (nNow - h.nLeft) / 1000, 3.899)
end)
Test('phase deletion via same key and nTime=0 cannot resurrect', function()
	World(); local h = Start(Config(), 20, 'phase')
	Buff(1, 1001, 3)
	MY_TeamMon.CountdownEvent({ tCountdown = {{ key = 'phase', nClass = 4, nTime = 0 }} }, 4)
	Equal(h.valid, false); local nBefore = nReads; Tick(101); Equal(nReads, nBefore)
end)
Test('DEL and CLEAR remove computed timers without later resurrection', function()
	World(); local h = Start(Config(), 20, 'delete')
	Emit('MY_TEAM_MON__SPELL_TIMER__DEL', 15, 'delete'); Buff(1, 1001, 3); Tick(101); Equal(h.valid, false)
	h = Start(Config(), 20, 'clear'); Emit('MY_TEAM_MON__SPELL_TIMER__CLEAR'); Buff(2, 1001, 3); Tick(202)
	Equal(h.valid, false)
end)
Test('same-key legacy replacement removes the old dynamic binding', function()
	World(); local h = Start(Config(), 20, 'replace')
	local item = Item(nil, 10, 'replace'); item.tCountdown[1].szName = 'legacy'
	MY_TeamMon.CountdownEvent(item, 8); Buff(1, 1001, 3); local nBefore = nReads; Tick(101)
	Equal(h.txt:GetText(), 'legacy'); Equal(h.tVars, nil); Equal(nReads, nBefore)
end)
Test('legacy fixed and segmented countdowns do not query team data', function()
	World(); local h = Start(nil, 20, 'legacy')
	Equal(h.txt:GetText(), 'R2x Bx boss capture'); Equal(nReads, 0)
	h = Start(nil, '5,old one;10,old two;', 'legacy-parts'); Tick(5100)
	Equal(h.txt:GetText(), 'old two'); Equal(nReads, 0)
end)
Test('existing nRefresh still blocks event-triggered replacement', function()
	World(); local item = Item(Config(), 20, 'lock'); item.tCountdown[1].nRefresh = 10
	MY_TeamMon.CountdownEvent(item, 8); local h = aItems[#aItems]
	nNow = 1000; item.tCountdown[1].nTime = 50; MY_TeamMon.CountdownEvent(item, 8)
	Equal(h.nCreate, 0); Equal(h.countdown, 20)
	Buff(1, 1001, 3); Tick(1101); Equal(h.txt:GetText(), 'R2x9 Bx5  ')
	Equal(h.nCreate, 0); Equal(h.countdown, 20)
end)
Test('one-shot configuration does not subscribe to later Buff changes', function()
	World(); local t = Config(); t.bUpdate = false; local h = Start(t, 20, 'once'); local nBefore = nReads
	Buff(1, 1001, 3); Tick(101); Equal(h.txt:GetText(), 'R2x10 Bx5 boss capture'); Equal(nReads, nBefore)
end)
Test('anonymous timer identity is independent of computed values', function()
	World(); local h = Start(Config(), 20); local nBefore = #aItems
	Buff(1, 1001, 3); Tick(101); Equal(#aItems, nBefore); Equal(h.txt:GetText(), 'R2x9 Bx5 boss capture')
end)
Test('data reload clears computed bindings but retains legacy timers', function()
	World(); local h = Start(Config(), 20, 'reload'); local old = Start(nil, 20, 'reload-old')
	Emit('MY_TEAM_MON_DATA_RELOAD'); Equal(h.valid, false); Equal(old.valid, true)
end)
Test('data reload releases computed cooldowns, including already expired timers', function()
	World(); local item = Item(Config(), 1, 'reload-lock'); item.tCountdown[1].nRefresh = 30
	MY_TeamMon.CountdownEvent(item, 8); local h = aItems[#aItems]
	Tick(1001); Equal(h.valid, false)
	Emit('MY_TEAM_MON_DATA_RELOAD'); MY_TeamMon.CountdownEvent(item, 8)
	Equal(aItems[#aItems].valid, true); assert(aItems[#aItems] ~= h)
end)
Test('offline members do not require a readable life state', function()
	World(); tInfo[2] = { bOnline = false }; tPlayers[2] = nil
	Equal(assert(MY_TeamMon_Compute.Evaluate(Config())).calc_red2, 9)
	tInfo[2].bOnline = true
	Equal(MY_TeamMon_Compute.Evaluate(Config()), nil)
end)
Test('party and life events update the live aggregate', function()
	World(); local h = Start(Config(), 20, 'party-life')
	tInfo[1].bDeathFlag = true; Emit('PLAYER_STATE_UPDATE', 1); Tick(101)
	Equal(h.txt:GetText(), 'R2x9 Bx5 boss capture')
	tInfo[2].bOnline = false; Emit('PARTY_SET_MEMBER_ONLINE_FLAG', 2); Tick(202)
	Equal(h.txt:GetText(), 'R2x8 Bx5 boss capture')
	tInfo[2].bOnline = true; Emit('PARTY_SET_MEMBER_ONLINE_FLAG', 2); Tick(303)
	Equal(h.txt:GetText(), 'R2x9 Bx5 boss capture')
end)
Test('control times keep their original cooldown and deletion behavior', function()
	World(); local h = Start(Config(), 20, 'controls')
	local item = Item(Config(), -2, 'controls'); item.tCountdown[1].nRefresh = 5
	local nBefore = nReads; MY_TeamMon.CountdownEvent(item, 8)
	Equal(h.valid, true); Equal(nReads, nBefore)
	item.tCountdown[1].nTime = -1; MY_TeamMon.CountdownEvent(item, 8)
	Equal(h.valid, false); Equal(nReads, nBefore)
	local nItems = #aItems; Start(Config(), 20, 'controls'); Equal(#aItems, nItems)
	nNow = 5001; Start(Config(), 20, 'controls'); Equal(#aItems, nItems + 1)
end)
Test('loading removes unheld timers and does not resurrect them', function()
	World(); local h = Start(Config(), 20, 'loading')
	Emit('LOADING_END'); Equal(h.valid, false)
	local nBefore = nReads; Buff(1, 1001, 3); Tick(101); Equal(nReads, nBefore)
end)
Test('nonpositive numeric timers cannot retain malformed variable bindings', function()
	World(); local h = Start('invalid', -3, 'negative')
	Equal(h.tVars, nil); Equal(nReads, 0)
	Emit('BUFF_UPDATE', 1, false, 1, false, 1001, 3); Tick(101); Equal(h.valid, false)
end)
Test('queries reuse one snapshot without modifying config or Buff objects', function()
	World(); local t = Config(); t.aQueries[2].dwBuffID = 1001
	local szBefore, szBuffs = Serialize(t), Serialize(tPlayers)
	local r = assert(MY_TeamMon_Compute.Evaluate(t))
	Equal(r.calc_red2, 10); Equal(r.calc_black, 10); Equal(nReads, 25)
	Equal(Serialize(t), szBefore); Equal(Serialize(tPlayers), szBuffs)
end)
Test('expired timer does not query or reappear after a Buff change', function()
	World(); local h = Start(Config(), 1, 'expire'); Tick(1001); Equal(h.valid, false)
	local nBefore = nReads; Buff(1, 1001, 3); Tick(1200); Equal(nReads, nBefore)
end)
Test('map, feature and hidden-Buff restrictions are respected', function()
	World(); tRestrictions['MY_TeamMon.MapRestriction'] = true; bInDungeon = false
	Equal(MY_TeamMon_Compute.Evaluate(Config()), nil); Equal(nReads, 0)
	bInDungeon = true; MY_TeamMon.bEnable = false; Equal(MY_TeamMon_Compute.Evaluate(Config()), nil); Equal(nReads, 0)
	MY_TeamMon.bEnable = true; tRestrictions['MY_TeamMon.HiddenBuff'] = true
	local fnVisible = MY.IsVisibleBuff; MY.IsVisibleBuff = function() return false end
	Equal(MY_TeamMon_Compute.Evaluate(Config()), nil); Equal(nReads, 0); MY.IsVisibleBuff = fnVisible
end)
Test('arithmetic, lazy conditionals and ordered variable references', function()
	World(); local t = Config()
	t.aValues = {
		{ szName = 'calc_a', tExpression = { 'floor', { 'div', { 'mul', 'calc_red2', 3 }, 4 } } },
		{ szName = 'calc_b', tExpression = { 'if', { 'gt', 'calc_a', 5 }, { 'max', 'calc_a', 8 }, { 'div', 1, 0 } } },
		{ szName = 'calc_c', tExpression = { 'ceil', { 'abs', { 'sub', 0, 1.2 } } } },
	}
	local r = assert(MY_TeamMon_Compute.Evaluate(t)); Equal(r.calc_a, 7); Equal(r.calc_b, 8); Equal(r.calc_c, 2)
end)
Test('invalid expressions and numeric failures are isolated', function()
	World()
	for _, expr in ipairs({ { 'div', 1, 0 }, { 'mul', 1e308, 1e308 }, { 'unknown', 1, 2 }, 'missing', { 'if', 1, 2, 3 } }) do
		local t = Config(); t.aValues[1].tExpression = expr
		Equal(MY_TeamMon_Compute.Evaluate(t), nil)
	end
	local t = Config(); t.aValues[1].tExpression = { 'lt', 1, 2 }; Equal(MY_TeamMon_Compute.Evaluate(t), nil)
end)
Test('schema, names, array shapes and expression depth are bounded', function()
	World(); local t = Config(); t.nVersion = 9; Equal(MY_TeamMon_Compute.Evaluate(t), nil)
	t = Config(); t.aQueries[1].szName = 'sender'; Equal(MY_TeamMon_Compute.Evaluate(t), nil)
	t = Config(); t.aQueries[2].szName = t.aQueries[1].szName; Equal(MY_TeamMon_Compute.Evaluate(t), nil)
	t = Config(); t.aQueries.unexpected = {}; Equal(MY_TeamMon_Compute.Evaluate(t), nil)
	t = Config(); local e = 1; for _ = 1, 20 do e = { 'abs', e } end
	t.aValues[1].tExpression = e; Equal(MY_TeamMon_Compute.Evaluate(t), nil)
end)
Test('invalid debounce configuration cannot crash game event dispatch', function()
	World(); local t = Config(); t.nDebounce = 'invalid'; local h = Start(t, 20, 'bad-delay')
	Buff(1, 1001, 3); Tick(101); Equal(h.txt:GetText(), 'waiting')
end)
Test('duplicate team IDs are counted once', function()
	World(); aMembers[#aMembers + 1] = 1
	Equal(assert(MY_TeamMon_Compute.Evaluate(Config())).calc_red2, 10)
end)
Test('six exclusive categories render all six counts and partition the team', function()
	SixWorld(); local t = SixResult()
	Equal(t.calc_red1, 4); Equal(t.calc_red2, 4); Equal(t.calc_zero, 5)
	Equal(t.calc_black1, 3); Equal(t.calc_black2, 2); Equal(t.calc_other, 7)
	Equal(SixSum(t), 25); Equal(t.calc_total, 25)
	local data = SixExample(); local nBefore = #aItems
	MY_TeamMon.CountdownEvent(data, 8)
	Equal(#aItems - nBefore, 6)
	for i, entry in ipairs(data.tCountdown) do
		Equal(aItems[nBefore + i].txt:GetText(), MY_TeamMon.FilterCustomText(entry.szName, nil, nil, t))
	end
end)
Test('isolation takes precedence over red2 and refreshes without resetting timers', function()
	SixWorld(); local data = SixExample(); local nBefore = #aItems
	MY_TeamMon.CountdownEvent(data, 8)
	Buff(5, 34097, 1); Tick(101)
	local t = SixResult(); Equal(t.calc_red2, 3); Equal(t.calc_other, 8); Equal(SixSum(t), 25)
	for i, entry in ipairs(data.tCountdown) do
		local h = aItems[nBefore + i]
		Equal(h.txt:GetText(), MY_TeamMon.FilterCustomText(entry.szName, nil, nil, t))
		Equal(h.nCreate, 0); Equal(h.nLeft, 0); Equal(h.countdown, 20)
	end
	Buff(5, 34097, nil); Tick(202)
	t = SixResult(); Equal(t.calc_red2, 4); Equal(t.calc_other, 7); Equal(SixSum(t), 25)
end)
Test('zero, black2, and high layers move to other exactly once', function()
	SixWorld(); Buff(10, 34097, 1); Buff(19, 34097, 1); Buff(6, 34095, 4)
	local t = SixResult()
	Equal(t.calc_zero, 4); Equal(t.calc_black2, 1); Equal(t.calc_red2, 3)
	Equal(t.calc_other, 10); Equal(SixSum(t), 25)
	Buff(10, 34097, nil); Buff(19, 34097, nil); Buff(6, 34095, 2)
	Equal(SixResult().calc_other, 7)
end)
Test('conflicting raw colors are conservatively classified only as other', function()
	SixWorld(); Buff(1, 34096, 1)
	local t = SixResult(); Equal(t.calc_red1, 3); Equal(t.calc_black1, 3)
	Equal(t.calc_other, 8); Equal(SixSum(t), 25)
end)
Test('unreadable team data does not enter zero or other in six-category display', function()
	SixWorld(); tPlayers[5] = nil; local data = SixExample(); local nBefore = #aItems
	Equal(MY_TeamMon_Compute.Evaluate(data.tCountdown[1].tVars), nil)
	MY_TeamMon.CountdownEvent(data, 8)
	for i = 1, 6 do
		Equal(aItems[nBefore + i].txt:GetText(), data.tCountdown[i].tVars.szUnavailable)
	end
end)
Test('multiple exclusion IDs are validated and included in Buff dependencies', function()
	SixWorld(); local t = SixExample().tCountdown[1].tVars
	Equal(MY_TeamMon_Compute.WatchesBuff(t, 34097), true)
	Equal(MY_TeamMon_Compute.WatchesBuff(t, 99999), false)
	for _, invalid in ipairs({ 'invalid', { 34097, 0 }, { [1] = 34097, [3] = 34096 },
		{ 1, 2, 3, 4, 5, 6, 7, 8, 9 } }) do
		t.aQueries[2].aExcludeBuffIDs = invalid
		Equal(MY_TeamMon_Compute.Evaluate(t), nil)
	end
	t.aQueries[2].aExcludeBuffIDs = { 34097 }; t.aQueries[2].dwExcludeBuffID = 34096
	Equal(MY_TeamMon_Compute.Evaluate(t), nil)
end)
print(('RESULT %d passed, %d failed'):format(nPassed, nFailed))
assert(nFailed == 0, 'computed countdown tests failed')
