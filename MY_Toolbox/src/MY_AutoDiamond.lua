--------------------------------------------------------------------------------
-- This file is part of the JX3 Mingyi Plugin.
-- @link     : https://jx3.zhaiyiming.com/
-- @desc     : 自动按上次配方合石头
-- @author   : 茗伊 @双梦镇 @追风蹑影
-- @modifier : Emil Zhai (root@zhaiyiming.com)
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = 'MY_Toolbox/MY_AutoDiamond'
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

---------------------------------------------------------------------
-- 本地函数和变量
---------------------------------------------------------------------
local D = {
	nAutoCount = 0,
	nCompleteCount = 0,
	nSuccessCount = 0,
}

local O = X.CreateUserSettingsModule('MY_AutoDiamond', _L['General'], {
	bEnable = {
		ePathType = X.PATH_TYPE.ROLE,
		szLabel = _L['MY_Toolbox'],
		szDescription = X.MakeCaption({
			_L['MY_AutoDiamond'],
			_L['Enable'],
		}),
		xSchema = X.Schema.Boolean,
		xDefaultValue = false,
	},
})

-- 获取五行石数据
function D.GetDiamondData(dwBox, dwX)
	if not dwX then
		dwBox, dwX = select(2, dwBox:GetObjectData())
	end
	local d, item = {}, X.GetInventoryItem(X.GetClientPlayer(), dwBox, dwX)
	d.dwBox, d.dwX = dwBox, dwX
	if item then
		d.level = string.match(item.szName, _L['DIAMOND_REGEX'])
		d.id, d.bind, d.num, d.detail = item.nUiId, item.bBind, item.nStackNum, item.nDetail
		d.dwTabType, d.dwIndex = item.dwTabType, item.dwIndex
	end
	return d
end

-- 获取精炼面板元素
function D.LookupCastingPanel(szPath, szSubPath)
	local frame = Station.SearchFrame('CastingPanel')
	if not frame then
		return
	end
	if szSubPath then
		return frame:Lookup(szPath, szSubPath)
	end
	if szPath then
		return frame:Lookup(szPath)
	end
	return frame
end

-- 保存五行石精炼方案
function D.SaveDiamondFormula()
	local t = {}
	local box = D.LookupCastingPanel('PageSet_All/Page_Refine', 'Handle_BoxItem/Box_Refine')
		or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine', 'Handle_BoxItem/Box_Refine')
	local hList = D.LookupCastingPanel('PageSet_All/Page_Refine', 'Handle_RefineExpend')
		or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine', 'Handle_RefineExpend')
	if not box or not hList then
		return
	end
	table.insert(t, D.GetDiamondData(box))
	for i = 1, 16 do
		local box = hList:Lookup('Box_RefineExpend_' .. i)
		if box:IsObjectEnable() and box:GetObjectData() ~= -1 then
			table.insert(t, D.GetDiamondData(box))
		end
	end
	D.dFormula = t
end

-- 扫描背包石头及空位信息（存在 buggy cache）
function D.LoadBagDiamond()
	local t = {}
	for _, dwBox in ipairs(X.GetInventoryBoxList(X.CONSTANT.INVENTORY_TYPE.PACKAGE)) do
		for dwX = 0, X.GetInventoryBoxSize(dwBox) - 1 do
			local d = D.GetDiamondData(dwBox, dwX)
			if not d.id or d.level then
				for _, v in ipairs(D.dFormula) do
					if v.dwBox == dwBox and v.dwX == dwX then
						d = nil
					end
				end
				if d then
					table.insert(t, d)
				end
			end
		end
	end
	D.tBagCache = t
end

-- 还原背包格子里的石头，失败返回 false，成功返回 true
function D.RestoreBagDiamond(d)
	local me = X.GetClientPlayer()
	local tBag = D.tBagCache
	-- move box item
	local item = X.GetInventoryItem(me, d.dwBox, d.dwX)
	-- to stack
	if item then
		for k, v in ipairs(tBag) do
			if v.id == item.nUiId and v.bind == item.bBind and (v.num + item.nStackNum) <= item.nMaxStackNum then
				v.num = v.num + item.nStackNum
				me.ExchangeItem(d.dwBox, d.dwX, v.dwBox, v.dwX)
				item = nil
				break
			end
		end
	end
	-- to empty
	if item then
		for k, v in ipairs(tBag) do
			if not v.id then
				local v2 = D.GetDiamondData(d.dwBox, d.dwX)
				v2.dwBox, v2.dwX = v.dwBox, v.dwX
				tBag[k] = v2
				me.ExchangeItem(d.dwBox, d.dwX, v.dwBox, v.dwX)
				item = nil
				break
			end
		end
	end
	-- no freebox
	if item then
		return false
	end
	-- group bag by type/bind: same type, same bind, ... others
	local tBag2, nLeft = {}, d.num
	for _, v in ipairs(tBag) do
		if v.level == d.level and (v.bind == d.bind or v.bind == false) then
			local vt = nil
			for _, vv in ipairs(tBag2) do
				if vv.bind == v.bind then
					vt = vv
					break
				end
			end
			if not vt then
				vt = { num = 0, bind = v.bind }
				local vk = #tBag2 + 1
				if vk > 1 then
					if v.bind ~= d.bind then
						vk = 2
					else
						vk = 1
					end
				end
				table.insert(tBag2, vk, vt)
			end
			vt.num = vt.num + v.num
			table.insert(vt, v)
		end
	end
	-- select diamond1 (same type)
	for _, v in ipairs(tBag2) do
		if v.num >= nLeft then
			for _, vv in ipairs(v) do
				if vv.num >= nLeft then
					me.ExchangeItem(vv.dwBox, vv.dwX, d.dwBox, d.dwX, nLeft)
					vv.num = vv.num - nLeft
					break
				elseif vv.num > 0 then
					me.ExchangeItem(vv.dwBox, vv.dwX, d.dwBox, d.dwX, vv.num)
					nLeft = nLeft - vv.num
					vv.num = 0
				end
			end
			return true
		end
	end
	return false
end

-- 停止重复合成
function D.StopProduce()
	local box = D.LookupCastingPanel('PageSet_All/Page_Refine', 'Handle_BoxItem/Box_Refine')
		or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine', 'Handle_BoxItem/Box_Refine')
	if box then
		box:ClearObject()
	end
	D.dFormula = nil
	D.tBagCache = nil
end

-- 触发重复合成
function D.ProduceDiamond()
	if not D.fnProduceAction then
		D.StopProduce()
		X.OutputSystemAnnounceMessage(_L['Produce failed, action not exist.'], X.CONSTANT.MSG_THEME.ERROR)
		return
	end
	D.bAwaitDuang = true
	D.fnProduceAction()
end

-- 从系统面板抓取合成函数
function D.GetCastingAction()
	local fnAction = X.GetMessageBoxButtonAction('CastingPanelConfirm', 1)
	if fnAction then
		D.fnProduceAction = fnAction
		D.SaveDiamondFormula()
	end
end

-- 更新计数器
function D.UpdateDashboard()
	local edit = D.LookupCastingPanel('PageSet_All/Page_Refine/WndWindow_MYDiamond/WndEditBox_MYDiamond')
		or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine/WndWindow_MYDiamond/WndEditBox_MYDiamond')
	if edit then
		X.UI(edit):Text(D.nAutoCount, WNDEVENT_FIRETYPE.PREVENT)
	end
	local txt = D.LookupCastingPanel('PageSet_All/Page_Refine/WndWindow_MYDiamond', 'Text_Result')
		or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine/WndWindow_MYDiamond', 'Text_Result')
	if txt then
		X.UI(txt):Text(
			D.nCompleteCount > 0
				and _L(
					'Total: %d, success: %d (%.2f%%), failure: %d (%.2f%%)',
					D.nCompleteCount,
					D.nSuccessCount, (D.nSuccessCount / D.nCompleteCount) * 100,
					D.nCompleteCount - D.nSuccessCount, (1 - D.nSuccessCount / D.nCompleteCount) * 100
				)
				or ''
		)
	end
end

-- 自动摆五行石材料，开始下一轮合成
function D.DoAutoDiamond()
	local box = D.LookupCastingPanel('PageSet_All/Page_Refine', 'Handle_BoxItem/Box_Refine')
		or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine', 'Handle_BoxItem/Box_Refine')
	if not box then
		D.dFormula = nil
	end
	if not D.dFormula then
		return
	end
	-- 更新计数器
	D.nAutoCount = math.max(D.nAutoCount - 1, 0)
	D.bUpdateInfo = true
	-- 移除加锁（延迟一帧）
	X.DelayCall(50, function()
		if not box:IsValid() then
			D.StopProduce()
			X.OutputSystemAnnounceMessage(_L['Casting panel closed, produce stopped.'], X.CONSTANT.MSG_THEME.ERROR)
			return
		end
		local dwBox, dwX = select(2, box:GetObjectData())
		RemoveUILockItem('CastingPanel:' .. dwBox .. ',' .. dwX)
		box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
		box:SetObjectIcon(3388 - X.GetClientPlayer().nGender)
	end)
	-- 重新放入配方（延迟8帧执行，确保 unlock）
	X.DelayCall(200, function()
		if not box:IsValid() then
			D.StopProduce()
			X.OutputSystemAnnounceMessage(_L['Casting panel closed, produce stopped.'], X.CONSTANT.MSG_THEME.ERROR)
			return
		end
		if D.nAutoCount <= 0 then
			D.StopProduce()
			box:Clear()
			return
		end
		D.LoadBagDiamond()
		for _, v in ipairs(D.dFormula) do
			if not D.RestoreBagDiamond(v) then
				D.StopProduce()
				X.OutputSystemAnnounceMessage(_L['Restore bag failed, material may not enough.'], X.CONSTANT.MSG_THEME.ERROR)
				return
			end
		end
		D.ProduceDiamond()
	end)
end

-- 隐藏结果特效
function D.HideDuang()
	local sfxSuccess = D.LookupCastingPanel('PageSet_All/Page_Refine', 'SFX_CommonRefineSuccess')
		or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine', 'SFX_CommonRefineSuccess')
	local sfxFailure = D.LookupCastingPanel('PageSet_All/Page_Refine', 'SFX_CommonRefineFailure')
		or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine', 'SFX_CommonRefineFailure')
	if not sfxSuccess or not sfxFailure then
		return
	end
	sfxSuccess:Hide()
	sfxFailure:Hide()
end

-- 精炼结果显示
function D.PlayDuang(bSuccess)
	local sfx
	if bSuccess then
		sfx = D.LookupCastingPanel('PageSet_All/Page_Refine', 'SFX_CommonRefineSuccess')
			or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine', 'SFX_CommonRefineSuccess')
		PlaySound(SOUND.UI_SOUND, g_sound.ElementalStoneSuccess)
	else
		sfx = D.LookupCastingPanel('PageSet_All/Page_Refine', 'SFX_CommonRefineFailure')
			or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine', 'SFX_CommonRefineFailure')
		PlaySound(SOUND.UI_SOUND, g_sound.ElementalStoneFailed)
	end
	if not sfx then
		return
	end
	sfx:Hide()
	sfx:Show()
	sfx:Play()
end

-------------------------------------
-- 设置界面
-------------------------------------
function D.CheckInjection(bRemove)
	local page = D.LookupCastingPanel('PageSet_All/Page_Refine')
		or D.LookupCastingPanel('PageSet_All/Page_DiamondRefine')
	if not page then
		return
	end
	X.UI(page)
		:Fetch('WndWindow_MYDiamond')
		:Remove()
	if not bRemove and D.bReady and O.bEnable then
		local ui = X.UI(page):Append('WndWindow', { name = 'WndWindow_MYDiamond', y = 383, h = 24 })
		local nX, nY = 0, 2
		nX = nX + ui:Append('Text', {
			name = 'Text_MYDiamond',
			x = nX, y = nY, w = 'auto', h = 20,
			color = { 255, 128, 0 }, alpha = 192,
			text = _L['Produce diamond as last formula for'],
		}):Width() + 5
		nX = nX + ui:Append('WndEditBox', {
			name = 'WndEditBox_MYDiamond',
			text = D.nAutoCount,
			x = nX, y = nY - 2, w = 50, h = 20, alpha = 192,
			editType = X.UI.EDIT_TYPE.NUMBER,
			onChange = function(szText)
				D.nAutoCount = tonumber(szText) or 0
			end,
			tip = {
				render = _L['Will continue produce until counter reaches or casting failed.'],
				position = X.UI.TIP_POSITION.TOP_BOTTOM,
			},
		}):Width() + 5
		nX = nX + ui:Append('Text', {
			name = 'Text_MYDiamond2',
			x = nX, y = nY, w = 'auto', h = 20,
			color = { 255, 128, 0 }, alpha = 192,
			text = _L['times'],
		}):Width() + 5
		nX = nX + ui:Append('WndButtonBox', {
			name = 'WndButton_MYDiamond',
			x = nX, y = nY, w = 50, h = 20,
			buttonStyle = 'FLAT',
			text = _L['Stop'],
			onClick = function()
				D.dFormula = nil
			end,
			autoEnable = function() return D.dFormula and D.nAutoCount > 0 end,
		}):Width() + 5
		ui:Append('Text', { name = 'Text_Result', x = 0, y = 22, w = nX, h = 22, alpha = 192, alignHorizontal = 1 })
		ui:Width(nX)
		ui:Left((380 - nX) / 2)
		D.UpdateDashboard()
	end
end

function D.OnPanelActivePartial(ui, nPaddingX, nPaddingY, nW, nH, nX, nY)
	nX = nX + ui:Append('WndCheckBox', {
		x = nX, y = nY, w = 'auto',
		text = _L['Show batch refine diamond in casting panel'],
		checked = O.bEnable,
		onCheck = function(bChecked)
			O.bEnable = bChecked
			D.CheckInjection()
		end,
	}):Width() + 5

	return nX, nY
end

--------------------------------------------------------------------------------
-- 全局导出
--------------------------------------------------------------------------------
do
local settings = {
	name = 'MY_AutoDiamond',
	exports = {
		{
			preset = 'UIEvent',
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
				bEnable = D.CheckInjection,
			},
			root = O,
		},
	},
}
MY_AutoDiamond = X.CreateModule(settings)
end

--------------------------------------------------------------------------------
-- 事件注册
--------------------------------------------------------------------------------

X.RegisterFrameCreate('CastingPanel', 'MY_AutoDiamond', function() D.CheckInjection() end)
X.RegisterUserSettingsInit('MY_AutoDiamond', function()
	D.bReady = true
	D.CheckInjection()
end)
X.RegisterInit('MY_AutoDiamond', function() D.CheckInjection() end)
X.RegisterReload('MY_AutoDiamond', function() D.CheckInjection(true) end)

X.RegisterEvent('DIAMON_UPDATE', 'MY_AutoDiamond', function()
	-- 没有等待说明不在重复合成中，重置计数器
	if not D.bAwaitDuang then
		D.nCompleteCount = 0
		D.nSuccessCount = 0
		D.bUpdateInfo = true
	end
	-- 分析本次结果
	local bSuccess = false
	local nResult = arg0
	if nResult == DIAMOND_RESULT_CODE.SUCCESS then
		local d = D.dFormula and D.dFormula[1]
		if d and d.detail and d.detail > 0 then
			local KItem = X.GetInventoryItem(X.GetClientPlayer(), d.dwBox, d.dwX)
			if KItem then
				if KItem.nDetail > d.detail then
					bSuccess = true
					D.nSuccessCount = D.nSuccessCount + 1
				end
			end
		end
		D.nCompleteCount = D.nCompleteCount + 1
		D.bUpdateInfo = true
	end
	-- 播放结果动画
	if D.bAwaitDuang then
		D.HideDuang()
		if bSuccess then
			X.DelayCall(1, function()
				D.HideDuang()
				D.PlayDuang(true)
				OutputMessage('MSG_ANNOUNCE_YELLOW', g_tStrings.tFEProduce.SUCCEED)
			end)
		else
			X.DelayCall(1, function()
				D.HideDuang()
				D.PlayDuang(false)
				OutputMessage('MSG_ANNOUNCE_RED', g_tStrings.tFEProduce.FAILED)
			end)
		end
		D.bAwaitDuang = false
	end
	-- 触发下一次合成
	if D.dFormula then
		if D.nAutoCount <= 0 then
			D.StopProduce()
		elseif arg0 ~= DIAMOND_RESULT_CODE.SUCCESS then
			D.StopProduce()
			X.OutputSystemAnnounceMessage(_L['Casting failed, auto cast stopped.'], X.CONSTANT.MSG_THEME.ERROR)
		else
			D.DoAutoDiamond()
		end
	end
	-- 更新计数器渲染
	if D.bUpdateInfo then
		D.UpdateDashboard()
	end
end)
X.RegisterEvent('ON_MESSAGE_BOX_OPEN', 'MY_AutoDiamond', D.GetCastingAction)

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
