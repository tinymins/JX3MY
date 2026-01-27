--------------------------------------------------------------------------------
-- This file is part of the JX3 Plugin Project.
-- @desc     : 界面库
-- @copyright: Emil Zhai <root@zhaiyiming.com>
--------------------------------------------------------------------------------
---@class (partial) MY
local X = MY
--------------------------------------------------------------------------------
local MODULE_PATH = X.NSFormatString('{$NS}_!Base/lib/UI')
--------------------------------------------------------------------------------
--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'START')--[[#DEBUG END]]
--------------------------------------------------------------------------------
local _L = X.LoadLangPack(X.PACKET_INFO.FRAMEWORK_ROOT .. 'lang/lib/')
--------------------------------------------------------------------------------

-- TODO: 界面库需要重构，该文件应作为入口文件，仅用于分发各个组件的函数调用
-- TODO: 应当增加基础组件类型操作对象 ComponentBase ，可以提供组件的基本操作方法如 ComponentBase.Size(raw, ...)
-- TODO: 应当增加组件注册函数 function X.UI.RegisterComponent(function(super, GetComponentProp, SetComponentProp) return szComponentName, ComponentOO end)
-- TODO: 子组件可以覆盖基础组件的操作方法，如 ComponentOO.Size(raw, ...)
-- TODO: 子组件也可以通过 super 调用基础组件的方法，如 super.Size(raw, ...)
-- TODO: 有时间再说吧，是个大工程

-------------------------------------------------------------------------------------------------------

X.UI.ITEM_EVENT = X.FreezeTable({
	L_BUTTON_DOWN     = 0x00000001,
	R_BUTTON_DOWN     = 0x00000002,
	L_BUTTON_UP       = 0x00000004,
	R_BUTTON_UP       = 0x00000008,
	L_BUTTON_CLICK    = 0x00000010,
	R_BUTTON_CLICK    = 0x00000020,
	L_BUTTON_DB_CLICK = 0x00000040,
	R_BUTTON_DB_CLICK = 0x00000080,
	MOUSE_ENTER_LEAVE = 0x00000100,
	MOUSE_AREA        = 0x00000200,
	MOUSE_MOVE        = 0x00000400,
	MOUSE_WHEEL       = 0x00000800,
	KEY_DOWN          = 0x00001000,
	KEY_UP            = 0x00002000,
	M_BUTTON_DOWN     = 0x00004000,
	M_BUTTON_UP       = 0x00008000,
	M_BUTTON_CLICK    = 0x00010000,
	M_BUTTON_DB_CLICK = 0x00020000,
	MOUSE_HOVER       = 0x00040000,
	L_BUTTON_DRAG     = 0x00080000,
	R_BUTTON_DRAG     = 0x00100000,
	M_BUTTON_DRAG     = 0x00200000,
	MOUSE_IN_OUT      = 0x00400000,
})
X.UI.CURSOR = CURSOR or X.FreezeTable({
	NORMAL              = 0,
	CAST                = 1,
	UNABLECAST          = 2,
	TRAVEL              = 3,
	UNABLETRAVEL        = 4,
	SELL                = 5,
	UNABLESELL          = 6,
	BUYBACK             = 7,
	UNABLEBUYBACK       = 8,
	REPAIRE             = 9,
	UNABLEREPAIRE       = 10,
	ATTACK              = 11,
	UNABLEATTACK        = 12,
	SPEAK               = 13,
	UNABLESPEAK         = 14,
	LOOT                = 15,
	UNABLELOOT          = 16,
	LOCK                = 17,
	UNABLELOCK          = 18,
	INSPECT             = 19,
	UNABLEINSPECT       = 20,
	SPLIT               = 21,
	UNABLESPLIT         = 22,
	FLOWER              = 23,
	UNABLEFLOWER        = 24,
	MINE                = 25,
	UNABLEMINE          = 26,
	SEARCH              = 27,
	UNABLESEARCH        = 28,
	QUEST               = 29,
	UNABLEQUEST         = 30,
	READ                = 31,
	UNABLEREAD          = 32,
	MARKPRICE           = 33,
	TOP_BOTTOM          = 34,
	LEFT_RIGHT          = 35,
	LEFTTOP_RIGHTBOTTOM = 36,
	RIGHTTOP_LEFTBOTTOM = 37,
	CURSOR_MOVE         = 38,
	CHESS               = 57,
	CHAT_LOCK           = 58,
	HAND_OBJECT         = 59,
	DESTROY             = 60,
	DRAG                = 61,
	ON_DRAG             = 62,
	DRAW                = 63,
	POSITION            = 64,
	HOMELAND_BRUSH      = 65,
	HOMELAND_DIG_CELLAR = 66,
})
X.UI.MOUSE_BUTTON = X.FreezeTable({
	LEFT   = 1,
	MIDDLE = 0,
	RIGHT  = -1,
})
X.UI.TIP_POSITION = X.FreezeTable({
	FOLLOW_MOUSE              = -1,
	CENTER                    = ALW.CENTER,
	LEFT_RIGHT                = ALW.LEFT_RIGHT,
	RIGHT_LEFT                = ALW.RIGHT_LEFT,
	TOP_BOTTOM                = ALW.TOP_BOTTOM,
	BOTTOM_TOP                = ALW.BOTTOM_TOP,
	RIGHT_LEFT_AND_BOTTOM_TOP = ALW.RIGHT_LEFT_AND_BOTTOM_TOP,
})
X.UI.ALIGN_HORIZONTAL = X.FreezeTable({
	LEFT   = 0,
	CENTER = 1,
	RIGHT  = 2,
})
X.UI.ALIGN_VERTICAL = X.FreezeTable({
	TOP    = 0,
	MIDDLE = 1,
	BOTTOM = 2,
})
X.UI.TIP_HIDE_WAY = X.FreezeTable({
	NO_HIDE      = 100,
	HIDE         = 101,
	ANIMATE_HIDE = 102,
})
X.UI.SLIDER_STYLE = X.FreezeTable({
	SHOW_VALUE    = false,
	SHOW_PERCENT  = true,
})
X.UI.IMAGE_TYPE = IMAGE or X.FreezeTable({
	NORMAL             = 0,
	LEFT_RIGHT         = 1,
	RIGHT_LEFT         = 2,
	TOP_BOTTOM         = 3,
	BOTTOM_TOP         = 4,
	TIMER_HIDE         = 5,
	ROTATE             = 6,
	FLIP_VERTICAL      = 7,
	FLIP_HORIZONTAL    = 8,
	FLIP_CENTRAL       = 9,
	NINE_PART          = 10,
	LEFT_CENTER_RIGHT  = 11,
	TOP_CENTER_BOTTOM  = 12,
	TIMER_SHOW         = 13,
	REVERSE_TIMER_HIDE = 14,
	REVERSE_TIMER_SHOW = 15,
})
X.UI.WND_SIDE = X.FreezeTable({
	TOP           = 0,
	BOTTOM        = 1,
	LEFT          = 2,
	RIGHT         = 3,
	TOP_LEFT      = 4,
	TOP_RIGHT     = 5,
	BOTTOM_LEFT   = 6,
	BOTTOM_RIGHT  = 7,
	CENTER        = 8,
	LEFT_CENTER   = 9,
	RIGHT_CENTER  = 1,
	TOP_CENTER    = 1,
	BOTTOM_CENTER = 1,
})
X.UI.EDIT_TYPE = X.FreezeTable({
	NUMBER = 0, -- 数字
	ASCII = 1, -- 英文
	WIDE_CHAR = 2, -- 中英文
})
X.UI.WND_CONTAINER_STYLE = _G.WND_CONTAINER_STYLE or X.FreezeTable({
	CUSTOM = 0,
	LEFT_TOP = 1,
	LEFT_BOTTOM = 2,
	RIGHT_TOP = 3,
	RIGHT_BOTTOM = 4,
})
X.UI.FRAME_VISUAL_STATE = X.FreezeTable({
	NORMAL = 0, -- 普通
	MINIMIZE = 1, -- 最小化
	MAXIMIZE = 2, -- 最大化
})
X.UI.FRAME_THEME = X.FreezeTable({
	INTACT = 'intact', -- 完整窗体
	SIMPLE = 'simple', -- 简单窗体
	FLOAT  = 'float' , -- 浮动窗体
	EMPTY  = 'empty' , -- 空白窗体
})
X.UI.LAYER_LIST = {'Lowest', 'Lowest1', 'Lowest2', 'Normal', 'Normal1', 'Normal2', 'Topmost', 'Topmost1', 'Topmost2'}
X.UI.IS_GLASSMORPHISM = IsFileExist('ui\\Image\\denglu\\Sign_BdCommon.UITex') and not X.IS_CLASSIC

local BUTTON_STYLE_CONFIG = {
	DEFAULT = {
		nWidth = 100,
		nHeight = 26,
		nMarginBottom = 0,
		nPaddingTop = 2,
		nPaddingRight = 10,
		nPaddingBottom = 4,
		nPaddingLeft = 10,
		szImage = 'ui/Image/UICommon/CommonPanel.UITex',
		nNormalGroup = 25,
		nMouseOverGroup = 26,
		nMouseDownGroup = 27,
		nDisableGroup = 28,
	},
	FLAT_RADIUS = {
		nWidth = 44,
		nHeight = 23,
		nMarginBottom = 0,
		nPaddingTop = 3,
		nPaddingRight = 5,
		nPaddingBottom = 3,
		nPaddingLeft = 5,
		szImage = X.PACKET_INFO.FRAMEWORK_ROOT .. 'img/UIComponents.UITex',
		nNormalGroup = 0,
		nMouseOverGroup = 1,
		nMouseDownGroup = 2,
		nDisableGroup = 3,
	},
	LINK = X.FreezeTable({
		nWidth = 60,
		nHeight = 25,
		nPaddingTop = 3,
		nPaddingRight = 5,
		nPaddingBottom = 3,
		nPaddingLeft = 5,
		szImage = 'ui/Image/UICommon/CommonPanel.UITex',
		nNormalGroup = -1,
		nMouseOverGroup = -1,
		nMouseDownGroup = -1,
		nDisableGroup = -1,
		nNormalFont = 162,
		nMouseOverFont = 0,
		nMouseDownFont = 162,
		nDisableFont = 161,
		fAnimateScale = 1.2,
	}),
	OPTION = {
		nWidth = 22,
		nHeight = 24,
		szImage = 'ui/Image/UICommon/CommonPanel2.UITex',
		nNormalGroup = 57,
		nMouseOverGroup = 58,
		nMouseDownGroup = 59,
		nDisableGroup = 56,
	},
}
if X.UI.IS_GLASSMORPHISM then
	BUTTON_STYLE_CONFIG.DEFAULT = {
		nWidth = 100,
		nHeight = 26,
		nMarginBottom = 0,
		nPaddingTop = 3,
		nPaddingRight = 9,
		nPaddingBottom = 3,
		nPaddingLeft = 9,
		szImage = 'ui\\Image\\UItimate\\UICommon\\Button.UITex',
		nNormalGroup = 14,
		nMouseOverGroup = 15,
		nMouseDownGroup = 16,
		nDisableGroup = 17,
	}
	BUTTON_STYLE_CONFIG.FLAT_RADIUS = {
		nWidth = 100,
		nHeight = 26,
		nMarginBottom = 0,
		nPaddingTop = 0,
		nPaddingRight = 10,
		nPaddingBottom = 0,
		nPaddingLeft = 10,
		szImage = 'ui\\Image\\UItimate\\UICommon\\Plugins.UITex',
		nNormalGroup = 0,
		nMouseOverGroup = 1,
		nMouseDownGroup = 2,
		nDisableGroup = 3,
	}
	BUTTON_STYLE_CONFIG.OPTION = {
		nWidth = 22,
		nHeight = 22,
		szImage = 'ui\\Image\\UItimate\\UICommon\\MainbarPanel.UITex',
		nNormalGroup = 0,
		nMouseOverGroup = 1,
		nMouseDownGroup = 2,
		nDisableGroup = 3,
	}
end
local function GetButtonStyleName(raw)
	local szImage = X.StringLowerW(raw:GetAnimatePath() or '')
	local nNormalGroup = raw:GetAnimateGroupNormal() or -1
	local GetStyleName = X.Get(_G, {X.NSFormatString('{$NS}_Resource'), 'GetWndButtonStyleName'})
	if X.IsFunction(GetStyleName) then
		local eStyle = GetStyleName(szImage, nNormalGroup)
		if eStyle then
			return eStyle
		end
	end
	for e, p in pairs(BUTTON_STYLE_CONFIG) do
		if X.StringLowerW(X.NormalizePath(p.szImage)) == szImage and p.nNormalGroup == nNormalGroup then
			return e
		end
	end
end
local function GetButtonStyleConfig(eButtonStyle)
	if X.IsTable(eButtonStyle)
	and eButtonStyle.szImage
	and eButtonStyle.nNormalGroup
	and eButtonStyle.nMouseOverGroup
	and eButtonStyle.nMouseDownGroup
	and eButtonStyle.nDisableGroup then
		return eButtonStyle
	end
	local GetStyleConfig = X.Get(_G, {X.NSFormatString('{$NS}_Resource'), 'GetWndButtonStyleConfig'})
	return X.IsFunction(GetStyleConfig)
		and GetStyleConfig(eButtonStyle)
		or BUTTON_STYLE_CONFIG[eButtonStyle]
end

local EDIT_BOX_APPEARANCE_CONFIG = {
	DEFAULT = {},
	SEARCH_LEFT = {
		szIconImage = X.PACKET_INFO.FRAMEWORK_ROOT .. 'img/UIComponents.UITex',
		nIconImageFrame = 4,
		nIconWidth = 32,
		nIconHeight = 32,
		nIconAlpha = 180,
		szIconAlign = 'LEFT',
	},
	SEARCH_RIGHT = {
		szIconImage = X.PACKET_INFO.FRAMEWORK_ROOT .. 'img/UIComponents.UITex',
		nIconImageFrame = 4,
		nIconWidth = 32,
		nIconHeight = 32,
		nIconAlpha = 180,
		szIconAlign = 'RIGHT',
	},
}
if X.UI.IS_GLASSMORPHISM then
	EDIT_BOX_APPEARANCE_CONFIG.SEARCH_LEFT = {
		szIconImage = 'ui\\Image\\UItimate\\UICommon\\Button.UITex',
		nIconImageFrame = 121,
		nIconWidth = 20,
		nIconHeight = 20,
		nIconAlpha = 180,
		nIconPaddingTop = 1,
		szIconAlign = 'LEFT',
	}
end

-- TODO: local REGISTERED_COMPONENT = {}

-----------------------------------------------------------
-- my ui common functions
-----------------------------------------------------------
local function ApplyUIArguments(ui, arg)
	if ui and arg then
		-- properties
		if arg.x ~= nil or arg.y  ~= nil then ui:Pos              (arg.x, arg.y                                    ) end
		if arg.alpha              ~= nil then ui:Alpha            (arg.alpha                                       ) end
		if arg.font               ~= nil then ui:Font             (arg.font                                        ) end -- must before color
		if arg.fontScale          ~= nil then ui:FontScale        (arg.fontScale                                   ) end -- must before color
		if arg.color              ~= nil then ui:Color            (arg.color                                       ) end
		if arg.r or arg.g or arg.b       then ui:Color            (arg.r, arg.g, arg.b                             ) end
		if arg.multiline          ~= nil then ui:Multiline        (arg.multiline                                   ) end -- must before :Text()
		if arg.sliderStyle        ~= nil then ui:SliderStyle      (arg.sliderStyle                                 ) end -- must before :Text()
		if arg.textFormatter      ~= nil then ui:Text             (arg.textFormatter                               ) end -- must before :Text()
		if arg.text               ~= nil then ui:Text             (arg.text                                        ) end
		if arg.placeholder        ~= nil then ui:Placeholder      (arg.placeholder                                 ) end
		if arg.oncomplete         ~= nil then ui:Complete         (arg.oncomplete                                  ) end
		if arg.navigate           ~= nil then ui:Navigate         (arg.navigate                                    ) end
		if arg.group              ~= nil then ui:Group            (arg.group                                       ) end
		if arg.tip                ~= nil then ui:Tip              (arg.tip                                         ) end
		if arg.rowTip             ~= nil then ui:RowTip           (arg.rowTip                                      ) end
		if arg.range              ~= nil then ui:Range            (X.Unpack(arg.range)                             ) end
		if arg.value              ~= nil then ui:Value            (arg.value                                       ) end
		if arg.menu               ~= nil then ui:Menu             (arg.menu                                        ) end
		if arg.menuLClick         ~= nil then ui:MenuLClick       (arg.menuLClick                                  ) end
		if arg.menuRClick         ~= nil then ui:MenuRClick       (arg.menuRClick                                  ) end
		if arg.rowMenu            ~= nil then ui:RowMenu          (arg.rowMenu                                     ) end
		if arg.rowMenuLClick      ~= nil then ui:RowMenuLClick    (arg.rowMenuLClick                               ) end
		if arg.rowMenuRClick      ~= nil then ui:RowMenuRClick    (arg.rowMenuRClick                               ) end
		if arg.limit              ~= nil then ui:Limit            (arg.limit                                       ) end
		if arg.scroll             ~= nil then ui:Scroll           (arg.scroll                                      ) end
		if arg.handleStyle        ~= nil then ui:HandleStyle      (arg.handleStyle                                 ) end
		if arg.containerType      ~= nil then ui:ContainerType    (arg.containerType                               ) end
		if arg.buttonStyle        ~= nil then ui:ButtonStyle      (arg.buttonStyle                                 ) end -- must before :Size()
		if arg.editType           ~= nil then ui:EditType         (arg.editType                                    ) end
		if arg.appearance         ~= nil then ui:Appearance       (arg.appearance                                  ) end
		if arg.frameLeftControl   ~= nil then ui:FrameLeftControl (arg.frameLeftControl                            ) end
		if arg.frameRightControl  ~= nil then ui:FrameRightControl(arg.frameRightControl                           ) end
		if arg.visible            ~= nil then ui:Visible          (arg.visible                                     ) end
		if arg.autoVisible        ~= nil then ui:Visible          (arg.autoVisible                                 ) end
		if arg.enable             ~= nil then ui:Enable           (arg.enable                                      ) end
		if arg.autoEnable         ~= nil then ui:Enable           (arg.autoEnable                                  ) end
		if arg.image              ~= nil then
			ui:Image(arg.image, arg.imageFrame, arg.imageOverFrame, arg.imageDownFrame, arg.imageDisableFrame)
		end
		if arg.imageType          ~= nil then ui:ImageType        (arg.imageType                                   ) end
		if arg.icon               ~= nil then ui:Icon             (arg.icon                                        ) end
		if arg.name               ~= nil then ui:Name             (arg.name                                        ) end
		if arg.penetrable         ~= nil then ui:Penetrable       (arg.penetrable                                  ) end
		if arg.draggable          ~= nil then ui:Drag             (arg.draggable                                   ) end
		if arg.dragArea           ~= nil then ui:Drag             (X.Unpack(arg.dragArea)                          ) end
		if arg.dragDropGroup             then ui:DragDropGroup    (arg.dragDropGroup                               ) end
		if arg.columns                   then ui:Columns          (arg.columns                                     ) end
		if arg.sort or arg.sortOrder     then ui:Sort             (arg.sort, arg.sortOrder                         ) end
		if arg.dataSource                then ui:DataSource       (arg.dataSource                                  ) end
		if arg.summary                   then ui:Summary          (arg.summary                                     ) end
		if arg.padding ~= nil            then ui:Padding        (arg.padding, arg.padding, arg.padding, arg.padding) end
		if arg.paddingTop ~= nil or arg.paddingRight ~= nil or arg.paddingBottom ~= nil or arg.paddingLeft ~= nil then
			ui:Padding(arg.paddingTop, arg.paddingRight, arg.paddingBottom, arg.paddingLeft)
		end
		if arg.sliderWidth ~= nil or arg.sliderHeight ~= nil then -- must after :Text() because w/h can be 'auto', must before :Size() because size depends on this
			ui:SliderSize(arg.sliderWidth, arg.sliderHeight)
		end
		if arg.minWidth          ~= nil  then ui:MinWidth         (arg.minWidth                                    ) end
		if arg.minHeight         ~= nil  then ui:MinHeight        (arg.minHeight                                   ) end
		if arg.w ~= nil or arg.h ~= nil  then ui:Size             (arg.w, arg.h                                    ) end -- must after :Text() because w/h can be 'auto'
		if arg.alignHorizontal or arg.alignVertical then -- must after :Size()
			ui:Align(arg.alignHorizontal, arg.alignVertical)
		end
		if arg.anchor             ~= nil then ui:Anchor           (arg.anchor                                      ) end -- must after :Size() :Pos()
		-- event handlers
		if arg.onScroll           ~= nil then ui:Scroll           (arg.onScroll                                    ) end
		if arg.onHover            ~= nil then ui:Hover            (arg.onHover                                     ) end
		if arg.onRowHover         ~= nil then ui:RowHover         (arg.onRowHover                                  ) end
		if arg.onFocus            ~= nil then ui:Focus            (arg.onFocus                                     ) end
		if arg.onBlur             ~= nil then ui:Blur             (arg.onBlur                                      ) end
		if arg.onClick            ~= nil then ui:Click            (arg.onClick                                     ) end
		if arg.onLClick           ~= nil then ui:LClick           (arg.onLClick                                    ) end
		if arg.onMClick           ~= nil then ui:MClick           (arg.onMClick                                    ) end
		if arg.onRClick           ~= nil then ui:RClick           (arg.onRClick                                    ) end
		if arg.onRowClick         ~= nil then ui:RowClick         (arg.onRowClick                                  ) end
		if arg.onRowLClick        ~= nil then ui:RowLClick        (arg.onRowLClick                                 ) end
		if arg.onRowMClick        ~= nil then ui:RowMClick        (arg.onRowMClick                                 ) end
		if arg.onRowRClick        ~= nil then ui:RowRClick        (arg.onRowRClick                                 ) end
		if arg.onCellClick        ~= nil then ui:CellClick        (arg.onCellClick                                 ) end
		if arg.onCellLClick       ~= nil then ui:CellLClick       (arg.onCellLClick                                ) end
		if arg.onCellMClick       ~= nil then ui:CellMClick       (arg.onCellMClick                                ) end
		if arg.onCellRClick       ~= nil then ui:CellRClick       (arg.onCellRClick                                ) end
		if arg.onColorPick        ~= nil then ui:ColorPick        (arg.onColorPick                                 ) end
		if arg.checked            ~= nil then ui:Check            (arg.checked                                     ) end
		if arg.onCheck            ~= nil then ui:Check            (arg.onCheck                                     ) end
		if arg.onChange           ~= nil then ui:Change           (arg.onChange                                    ) end
		if arg.onSpecialKeyDown   ~= nil then ui:OnSpecialKeyDown (arg.onSpecialKeyDown                            ) end
		if arg.onDrag                    then ui:Drag             (arg.onDrag                                      ) end
		if arg.onDragHover               then ui:DragHover        (arg.onDragHover                                 ) end
		if arg.onDrop                    then ui:Drop             (arg.onDrop                                      ) end
		if arg.onSizeChange              then ui:Size             (arg.onSizeChange                                ) end
		if arg.customLayout              then ui:CustomLayout     (arg.customLayout                                ) end
		if arg.onCustomLayout            then ui:CustomLayout     (arg.onCustomLayout, arg.customLayoutPoint       ) end
		if arg.onColumnsChange           then ui:Columns          (arg.onColumnsChange                             ) end
		if arg.onSortChange              then ui:Sort             (arg.onSortChange                                ) end
		if arg.onRemove                  then ui:Remove           (arg.onRemove                                    ) end
		if arg.events             ~= nil then for _, v in ipairs(arg.events      ) do ui:Event       (X.Unpack(v)) end end
		if arg.uiEvents           ~= nil then for _, v in ipairs(arg.uiEvents    ) do ui:UIEvent     (X.Unpack(v)) end end
		if arg.listBox            ~= nil then for _, v in ipairs(arg.listBox     ) do ui:ListBox     (X.Unpack(v)) end end
		if arg.autocomplete       ~= nil then for _, v in ipairs(arg.autocomplete) do ui:Autocomplete(X.Unpack(v)) end end
		-- auto size
		if arg.autoSize                  then ui:AutoSize         ()                                                 end
		if arg.autoWidth                 then ui:AutoWidth        ()                                                 end
		if arg.autoHeight                then ui:AutoHeight       ()                                                 end
	end
	return ui
end
X.UI.ApplyUIArguments = ApplyUIArguments

local GetComponentProp, SetComponentProp -- 组件私有属性 仅本文件内使用
do local l_prop = setmetatable({}, { __mode = 'k' })
	function GetComponentProp(raw, ...)
		if not raw or not l_prop[raw] then
			return
		end
		local prop = l_prop[raw]
		local k = { ... }
		local kc = select('#', ...)
		for i = 1, kc - 1, 1 do
			if not prop[k[i]] then
				return
			end
			prop = prop[k[i]]
		end
		return prop[k[kc]]
	end

	function SetComponentProp(raw, ...)
		if not raw then
			return
		end
		if not l_prop[raw] then
			l_prop[raw] = {}
		end
		local prop = l_prop[raw]
		local ks = { ... } -- { k1, k2, ..., kn, v }
		local kc = select('#', ...) - 1
		local v = ks[kc + 1]
		for i = 1, kc - 1, 1 do
			if not prop[ks[i]] then
				prop[ks[i]] = {}
			end
			prop = prop[ks[i]]
		end
		prop[ks[kc]] = v
	end
end

local GetComponentType, SetComponentType -- 组件名字记录
do local l_type = setmetatable({}, { __mode = 'k' })
	function GetComponentType(raw)
		if not raw then
			return
		end
		return l_type[raw] or raw:GetType()
	end
	function SetComponentType(raw, type)
		if not raw then
			return
		end
		l_type[raw] = type
	end
end

-- 通过组件根节点和目标功能区类型，获取功能UI实例对象。
-- 如：获取“按钮盒”的“按钮”实例、“文本”实例。
local function GetComponentElement(raw, elementType)
	local element
	local componentType = GetComponentType(raw)
	local componentBaseType = raw:GetBaseType()
	if elementType == 'ITEM' then -- 获取 Item 类UI实例
		if componentBaseType ~= 'Wnd' then
			element = raw
		end
	elseif elementType == 'WND' then -- 获取 Wnd 类UI实例
		if componentBaseType == 'Wnd' then
			element = raw
		end
	elseif elementType == 'MAIN_WINDOW' then -- 获取用于主要 Wnd 类功能区、子元素容器UI实例
		if componentType == 'WndFrame' then
			element = raw:Lookup('Wnd_Total') or raw
		elseif componentType == 'WndButtonBox' then
			element = raw:Lookup('WndButton')
		elseif componentType == 'WndScrollWindowBox' then
			element = raw:Lookup('WndContainer_Scroll')
		elseif componentBaseType == 'Wnd' then
			element = raw
		end
	elseif elementType == 'MAIN_HANDLE' then -- 获取用于主要 Item 类功能区、子元素容器UI实例
		if componentType == 'WndScrollHandleBox' then
			element = raw:Lookup('', 'Handle_Padding/Handle_Scroll')
		elseif componentType == 'Handle' or componentType == 'CheckBox' or componentType == 'ColorBox' then
			element = raw
		elseif componentType == 'WndTabs' then
			return
		elseif componentBaseType == 'Wnd' then
			local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
			if wnd then
				element = wnd:Lookup('', '')
			end
		end
	elseif elementType == 'MAIN_CONTAINER' then -- 放置子组件的容器
		if componentType == 'WndFrame' then
			element = GetComponentElement(raw, 'MAIN_WINDOW')
		elseif componentType == 'WndScrollHandleBox' then
			element = GetComponentElement(raw, 'MAIN_HANDLE')
		elseif componentType == 'WndScrollWindowBox' then
			element = GetComponentElement(raw, 'CONTAINER')
		elseif componentType == 'WndTabs' then
			element = raw
		end
	elseif elementType == 'CHECKBOX' then -- 获取复选框UI实例
		if componentType == 'WndCheckBox'
		or componentType == 'WndRadioBox'
		or componentType == 'WndTab'
		or componentType == 'CheckBox' then
			element = raw
		end
	elseif elementType == 'COMBO_BOX' then -- 获取下拉框UI实例
		if componentType == 'WndComboBox' or componentType == 'WndEditComboBox' or componentType == 'WndAutocomplete' then
			element = raw:Lookup('Btn_ComboBox')
		end
	elseif elementType == 'CONTAINER' then -- 获取子元素容器UI实例
		if componentType == 'WndScrollWindowBox' then
			element = raw:Lookup('WndContainer_Scroll')
		elseif componentType == 'WndContainer' then
			element = raw
		elseif componentType == 'WndTabs' then
			element = raw
		end
	elseif elementType == 'EDIT' then -- 获取输入框UI实例
		if componentType == 'WndEdit' then
			element = raw
		elseif componentType == 'WndEditBox' or componentType == 'WndEditComboBox' or componentType == 'WndAutocomplete' then
			element = raw:Lookup('WndEdit_Default')
		end
	elseif elementType == 'BUTTON' then -- 获取按钮UI实例
		if componentType == 'WndButtonBox' then
			local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
			if wnd then
				element = wnd
			end
		elseif componentType == 'WndButton' then
			element = raw
		end
	elseif elementType == 'WEB' then -- 获取浏览器UI实例
		if componentType == 'WndWebPage'
		or componentType == 'WndWebCef' then
			element = raw
		end
	elseif elementType == 'WEB_PAGE' then -- 获取IE浏览器UI实例
		if componentType == 'WndWebPage' then
			element = raw
		end
	elseif elementType == 'WEB_CEF' then -- 获取Chrome浏览器UI实例
		if componentType == 'WndWebCef' then
			element = raw
		end
	elseif elementType == 'SLIDER' then -- 获取拖动条UI实例
		if componentType == 'WndSlider' then
			element = raw:Lookup('WndNewScrollBar_Default')
		end
	elseif elementType == 'TEXT' then -- 获取文本UI实例
		if componentType == 'WndScrollHandleBox' then
			element = raw:Lookup('', 'Handle_Padding/Handle_Scroll/Text_Default')
		elseif componentType == 'WndFrame' then
			element = raw:Lookup('', 'Text_Title') or raw:Lookup('', 'Text_Default')
		elseif componentType == 'WndTab' then
			element = raw:Lookup('', 'Text_WndTab')
		elseif componentType == 'Handle' or componentType == 'CheckBox' or componentType == 'ColorBox' then
			element = raw:Lookup('Text_Default')
		elseif componentType == 'Text' then
			element = raw
		elseif componentBaseType == 'Wnd' then
			local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
			if wnd then
				element = wnd:Lookup('', 'Text_Default')
			end
		end
	elseif elementType == 'PLACEHOLDER' then -- 获取占位文本UI实例
		if componentType == 'Handle' or componentType == 'CheckBox' or componentType == 'ColorBox' then
			element = raw:Lookup('Text_Placeholder')
		elseif componentBaseType == 'Wnd' then
			local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
			if wnd then
				element = wnd:Lookup('', 'Text_Placeholder')
			end
		end
	elseif elementType == 'IMAGE' then -- 获取图片UI实例
		if componentType == 'WndEditBox' or componentType == 'WndComboBox' or componentType == 'WndEditComboBox'
		or componentType == 'WndAutocomplete' or componentType == 'WndScrollHandleBox' or componentType == 'WndScrollWindowBox' then
			element = raw:Lookup('', 'Image_Default')
		elseif componentType == 'Handle' or componentType == 'CheckBox' then
			element = raw:Lookup('Image_Default')
		elseif componentType == 'Image' then
			element = raw
		end
	elseif elementType == 'SHADOW' then -- 获取阴影UI实例
		if componentType == 'ColorBox' then
			element = raw:Lookup('Shadow_Default')
		end
		if componentType == 'Shadow' then
			element = raw
		end
	elseif elementType == 'BOX' then -- 获取游戏盒子UI实例
		if componentType == 'Box' then
			element = raw
		end
	end
	return element
end

-- 显示提示框
-- @param {object} props 配置项
-- @param {string|function} props.render 要提示的纯文字或富文本，或返回前述内容的函数
-- @param {number} props.w 提示框宽度
-- @param {{ x: number; y: number; w: number; h: number }} props.rect 提示框触发区域矩形位置（默认则从 this 上获取）
-- @param {{ x: number; y: number; w: number; h: number }} props.offset 提示框触发区域偏移量
-- @param {X.UI.TIP_HIDE_WAY} props.position 提示框相对于触发区域的位置
-- @param {boolean} props.rich 提示框内容是否为富文本（当 render 为函数时取函数第二返回值）
-- @param {number} props.font 提示框字体（仅在非富文本下有效）
-- @param {number} props.r 提示框文字r（仅在非富文本下有效）
-- @param {number} props.g 提示框文字g（仅在非富文本下有效）
-- @param {number} props.b 提示框文字b（仅在非富文本下有效）
-- @param {X.UI.TIP_HIDE_WAY} props.hide 提示框消失方式
local function OutputAdvanceTip(props, ...)
	if not X.IsTable(props) then
		props = { render = props }
	end
	local tOffset = props.offset or {}
	local nOffsetX = tOffset.x or 0
	local nOffsetY = tOffset.y or 0
	local nOffsetW = tOffset.w or 0
	local nOffsetH = tOffset.h or 0
	local ePosition = props.position or X.UI.TIP_POSITION.FOLLOW_MOUSE
	local nX, nY, nW, nH
	if ePosition == X.UI.TIP_POSITION.FOLLOW_MOUSE then
		nX, nY = Cursor.GetPos()
		nX, nY = nX - 0, nY - 40
		nW, nH = 40, 40
	elseif props.rect then
		nX, nY = props.rect.x, props.rect.y
		nW, nH = props.rect.w, props.rect.h
	end
	if not nX then
		nX = this:GetAbsX()
	end
	if not nY then
		nY = this:GetAbsY()
	end
	if not nW then
		nW = this:GetW()
	end
	if not nH then
		nH = this:GetH()
	end
	nX, nY = nX + nOffsetX, nY + nOffsetY
	nW, nH = nW + nOffsetW, nH + nOffsetH
	if props.type == 'table' then
		local aRow
		if props.rows then
			aRow = {}
			for k, v in pairs(props.rows) do
				aRow[k] = {
					nPaddingTop = v.paddingTop,
					nPaddingBottom = v.paddingBottom,
					szAlignment = v.alignment,
				}
			end
		end
		local aColumn
		if props.columns then
			aColumn = {}
			for k, v in pairs(props.columns) do
				aColumn[k] = {
					nPaddingLeft = v.paddingLeft,
					nPaddingRight = v.paddingRight,
					nMinWidth = v.minWidth,
					szAlignment = v.alignment,
				}
			end
		end
		local aDataSource = props.dataSource
		if X.IsFunction(aDataSource) then
			local bSuccess
			bSuccess, aDataSource = X.ExecuteWithThis(this, aDataSource, ...)
			if not bSuccess then
				return
			end
		end
		X.OutputTableTip({
			aRow = aRow,
			aColumn = aColumn,
			aDataSource = aDataSource,
			nMinWidth = props.minWidth,
			nMaxWidth = props.maxWidth,
			nPaddingTop = props.paddingTop,
			nPaddingBottom = props.paddingBottom,
			nPaddingLeft = props.paddingLeft,
			nPaddingRight = props.paddingRight,
			Rect = {nX, nY, nW, nH},
			nPosType = ePosition,
		})
	else
		local nWidth = props.w or 450
		local bRichText = props.rich
		local szText = props.render
		if X.IsFunction(szText) then
			local bSuccess
			bSuccess, szText, bRichText = X.ExecuteWithThis(this, szText, ...)
			if not bSuccess then
				return
			end
		end
		if X.IsEmpty(szText) then
			return
		end
		if not bRichText then
			szText = GetFormatText(szText, props.font or 136, props.r, props.g, props.b)
		end
		OutputTip(szText, nWidth, {nX, nY, nW, nH}, ePosition)
	end
end

local function HideAdvanceTip(props)
	if not X.IsTable(props) then
		props = { render = props }
	end
	local eHide = props.hide or X.UI.TIP_HIDE_WAY.HIDE
	if eHide ~= X.UI.TIP_HIDE_WAY.HIDE and eHide ~= X.UI.TIP_HIDE_WAY.ANIMATE_HIDE then
		return
	end
	if props.type == 'table' then
		X.HideTableTip(eHide == X.UI.TIP_HIDE_WAY.ANIMATE_HIDE)
	else
		HideTip(eHide == X.UI.TIP_HIDE_WAY.ANIMATE_HIDE)
	end
end

local function InitComponent(raw, szType)
	SetComponentType(raw, szType)
	if szType == 'WndSlider' then
		if X.UI.IS_GLASSMORPHISM then
			X.UI.SetButtonUITex(
				raw:Lookup('WndNewScrollBar_Default/Btn_Slider'),
				'ui\\image\\uitimate\\uicommon\\button.uitex',
				145,
				146,
				147,
				148
			)
			raw:Lookup('', 'Image_BG'):FromUITex('ui\\image\\uitimate\\uicommon\\common.uitex', 11)
		end
		local scroll = raw:Lookup('WndNewScrollBar_Default')
		SetComponentProp(raw, 'bShowPercentage', true)
		SetComponentProp(raw, 'nSliderMin', 0)
		SetComponentProp(raw, 'nSliderMax', 100)
		SetComponentProp(raw, 'nSliderStepVal', 1)
		SetComponentProp(raw, 'onChangeEvents', {})
		SetComponentProp(raw, 'FormatText', function(value, bPercentage)
			if bPercentage then
				return string.format('%.2f%%', value)
			else
				return value
			end
		end)
		SetComponentProp(raw, 'ResponseUpdateScroll', function(bOnlyUI)
			local _this = this
			this = raw
			local nScrollPos = scroll:GetScrollPos()
			local nStepCount = scroll:GetStepCount()
			local nMin = GetComponentProp(raw, 'nSliderMin')
			local nStepVal = GetComponentProp(raw, 'nSliderStepVal')
			local nCurrentValue = nScrollPos * nStepVal + nMin
			local bShowPercentage = GetComponentProp(raw, 'bShowPercentage')
			if bShowPercentage then
				local nMax = GetComponentProp(raw, 'nSliderMax')
				nCurrentValue = math.floor((nCurrentValue * 100 / nMax) * 100) / 100
			end
			local szText = GetComponentProp(raw, 'FormatText')(nCurrentValue, bShowPercentage)
			raw:Lookup('', 'Text_Default'):SetText(szText)
			if not bOnlyUI then
				for _, fn in ipairs(GetComponentProp(raw, 'onChangeEvents')) do
					X.ExecuteWithThis(raw, fn, nCurrentValue)
				end
			end
			this = _this
		end)
		scroll.OnScrollBarPosChanged = function()
			GetComponentProp(raw, 'ResponseUpdateScroll')()
		end
		scroll.OnMouseWheel = function()
			scroll:ScrollNext(-Station.GetMessageWheelDelta() * 2)
			return 1
		end
		scroll:Lookup('Btn_Slider').OnMouseWheel = function()
			scroll:ScrollNext(-Station.GetMessageWheelDelta())
			return 1
		end
	elseif szType == 'WndCheckBox' then
		if X.UI.IS_GLASSMORPHISM then
			X.UI.AdaptComponentAppearance(raw, 'WndCheckBox')
		end
	elseif szType == 'WndRadioBox' then
		if X.UI.IS_GLASSMORPHISM then
			X.UI.AdaptComponentAppearance(raw, 'WndRadioBox')
		end
		X.UI(raw):UIEvent('OnLButtonUp', function()
			if not this:IsEnabled() then
				return
			end
			local group = GetComponentProp(raw, 'group')
			local p = raw:GetParent():GetFirstChild()
			while p do
				if p ~= raw and GetComponentType(p) == 'WndRadioBox' then
					local g = GetComponentProp(p, 'group')
					if g and g == group and p:IsCheckBoxChecked() then
						p:Check(false)
					end
				end
				p = p:GetNext()
			end
		end)
	elseif szType == 'WndComboBox' then
		if X.UI.IS_GLASSMORPHISM then
			X.UI.AdaptComponentAppearance(raw, 'WndComboBox')
		end
	elseif szType == 'WndEditBox' then
		local edt = raw:Lookup('WndEdit_Default')
		edt.OnEditSpecialKeyDown = function()
			local nMessageKey = Station.GetMessageKey()
			local szKey = GetKeyName(nMessageKey)
			local OnSpecialKeyDown = GetComponentProp(raw, 'OnSpecialKeyDown')
			if X.IsFunction(OnSpecialKeyDown) then
				return OnSpecialKeyDown(nMessageKey, szKey)
			end
			if szKey == 'Esc'
			or (szKey == 'Enter' and not edt:IsMultiLine()) then
				Station.SetFocusWindow(edt:GetRoot())
				return 1
			end
		end
		if X.UI.IS_GLASSMORPHISM then
			raw:Lookup('', 'Image_Default'):FromUITex('ui\\Image\\UItimate\\UICommon\\Common.UITex', 0)
		end
	elseif szType == 'WndEditComboBox' then
		if X.UI.IS_GLASSMORPHISM then
			X.UI.AdaptComponentAppearance(raw:Lookup('Btn_ComboBox'))
		end
	elseif szType == 'WndAutocomplete' then
		if X.UI.IS_GLASSMORPHISM then
			X.UI.AdaptComponentAppearance(raw:Lookup('Btn_ComboBox'))
		end
		local edt = raw:Lookup('WndEdit_Default')
		edt.OnSetFocus = function()
			local opt = GetComponentProp(raw, 'autocompleteOptions')
			if opt.disabled or opt.disabledTmp then
				return
			end
			X.UI(raw):Autocomplete('search')
		end
		edt.OnEditChanged = function()
			local opt = GetComponentProp(raw, 'autocompleteOptions')
			if opt.disabled or opt.disabledTmp or Station.GetFocusWindow() ~= this then
				return
			end
			-- placeholder
			local len = this:GetText():len()
			-- min search length
			if len >= opt.minLength then
				-- delay search
				X.DelayCall(opt.delay, function()
					X.UI(raw):Autocomplete('search')
					-- for compatible
					Station.SetFocusWindow(edt)
				end)
			else
				X.UI(raw):Autocomplete('close')
			end
		end
		edt.OnKillFocus = function()
			X.DelayCall(function()
				local wnd = Station.GetFocusWindow()
				local frame = wnd and wnd:GetRoot()
				if not frame or frame:GetName() ~= X.NSFormatString('{$NS}_PopupMenu') then
					X.UI.ClosePopupMenu()
				end
			end)
		end
		edt.OnEditSpecialKeyDown = function() -- TODO: {$NS}_PopupMenu 适配
			local nMessageKey = Station.GetMessageKey()
			local szKey = GetKeyName(nMessageKey)
			if IsPopupMenuOpened() and PopupMenu_ProcessHotkey then
				if szKey == 'Enter'
				or szKey == 'Up'
				or szKey == 'Down'
				or szKey == 'Left'
				or szKey == 'Right' then
					return PopupMenu_ProcessHotkey(szKey)
				end
			else
				local OnSpecialKeyDown = GetComponentProp(raw, 'OnSpecialKeyDown')
				if X.IsFunction(OnSpecialKeyDown) then
					return OnSpecialKeyDown(nMessageKey, szKey)
				end
				if szKey == 'Esc'
				or (szKey == 'Enter' and not edt:IsMultiLine()) then
					Station.SetFocusWindow(edt:GetRoot())
					return 1
				end
			end
		end
		SetComponentProp(raw, 'autocompleteOptions', {
			beforeSearch = nil  , -- @param: text
			beforePopup  = nil  , -- @param: menu
			beforeDelete = nil  , -- @param: szOption
			afterDelete  = nil  , -- @param: szOption

			ignoreCase   = true ,  -- ignore case while matching
			anyMatch     = true ,  -- match any part of option list
			autoFill     = false,  -- auto fill edit with first match (conflict withanyMatch)
			delay        = 0    ,  -- delay time when edit changed
			disabled     = false,  -- disable autocomplete
			minLength    = 0    ,  -- the min length of the searching string
			maxOption    = 0    ,  -- the max number of displayed options (0 means no limitation)
			source       = {}   ,  -- option list
		})
	elseif szType == 'WndListBox' then
		local scroll = raw:Lookup('', 'Handle_Scroll')
		SetComponentProp(raw, 'OnListItemHandleMouseEnter', function()
			SetComponentProp(raw, 'hoverItem', this)
			local bPreventDefault = false
			local data = GetComponentProp(this, 'listboxItemData')
			local onHoverIn = GetComponentProp(raw, 'OnListItemHandleCustomHoverIn')
			if onHoverIn then
				local bStatus, bRet = X.CallWithThis(raw, onHoverIn, data.id, data.text, data.data, not data.selected)
				bPreventDefault = bStatus and bRet == false
			end
			if not bPreventDefault then
				X.UI(this:Lookup('Image_Bg')):FadeIn(100)
			end
		end)
		SetComponentProp(raw, 'OnListItemHandleMouseLeave', function()
			local bPreventDefault = false
			local data = GetComponentProp(this, 'listboxItemData')
			local onHoverOut = GetComponentProp(raw, 'OnListItemHandleCustomHoverOut')
			if onHoverOut then
				local bStatus, bRet = X.CallWithThis(raw, onHoverOut, data.id, data.text, data.data, not data.selected)
				bPreventDefault = bStatus and bRet == false
			end
			if not bPreventDefault then
				X.UI(this:Lookup('Image_Bg')):FadeTo(500,0)
			end
			SetComponentProp(raw, 'hoverItem', nil)
		end)
		SetComponentProp(raw, 'OnListItemHandleLButtonClick', function()
			local data = GetComponentProp(this, 'listboxItemData')
			local onItemLClick = GetComponentProp(raw, 'OnListItemHandleCustomLButtonClick')
			if onItemLClick then
				local bStatus, bRet = X.CallWithThis(raw, onItemLClick, data.id, data.text, data.data, not data.selected)
				if bStatus and bRet == false then
					return
				end
			end
			local opt = GetComponentProp(raw, 'listboxOptions')
			if not data.selected then
				if not opt.multiSelect then
					for i = scroll:GetItemCount() - 1, 0, -1 do
						local hItem = scroll:Lookup(i)
						local data = GetComponentProp(hItem, 'listboxItemData')
						if data.selected then
							hItem:Lookup('Image_Sel'):Hide()
							data.selected = false
						end
					end
				end
				this:Lookup('Image_Sel'):Show()
			else
				this:Lookup('Image_Sel'):Hide()
			end
			data.selected = not data.selected
		end)
		SetComponentProp(raw, 'OnListItemHandleRButtonClick', function()
			local data = GetComponentProp(this, 'listboxItemData')
			local onItemRClick = GetComponentProp(raw, 'OnListItemHandleCustomRButtonClick')
			if onItemRClick then
				local bStatus, bRet = X.CallWithThis(raw, onItemRClick, data.id, data.text, data.data, not data.selected)
				if bStatus and bRet == false then
					return
				end
			end
			if not data.selected then
				local opt = GetComponentProp(raw, 'listboxOptions')
				if not opt.multiSelect then
					for i = scroll:GetItemCount() - 1, 0, -1 do
						local hItem = scroll:Lookup(i)
						local data = GetComponentProp(hItem, 'listboxItemData')
						if data.selected then
							hItem:Lookup('Image_Sel'):Hide()
							data.selected = false
						end
					end
				end
				data.selected = true
				this:Lookup('Image_Sel'):Show()
			end
			local GetMenu = GetComponentProp(raw, 'GetListItemHandleMenu')
			if GetMenu then
				local status, menu = X.CallWithThis(raw, GetMenu, data.id, data.text, data.data, data.selected)
				if status and menu then
					X.UI.PopupMenu(menu)
				end
			end
		end)
		SetComponentProp(raw, 'listboxOptions', { multiSelect = false })
		X.UI.AdaptComponentAppearance(raw:Lookup('Scroll_Default'))
	elseif szType == 'WndScrollHandleBox' then
		X.UI.AdaptComponentAppearance(raw:Lookup('WndScrollBar'))
	elseif szType == 'WndScrollWindowBox' then
		X.UI.AdaptComponentAppearance(raw:Lookup('WndScrollBar'))
	elseif szType == 'WndTable' then
		-- 初始化变量
		SetComponentProp(raw, 'ScrollX', 'auto')
		SetComponentProp(raw, 'SortOrder', 'asc')
		SetComponentProp(raw, 'aColumns', {})
		SetComponentProp(raw, 'aFixedLColumns', {})
		SetComponentProp(raw, 'aFixedRColumns', {})
		SetComponentProp(raw, 'aScrollableColumns', {})
		SetComponentProp(raw, 'nFixedLColumnsWidth', 0)
		SetComponentProp(raw, 'nFixedRColumnsWidth', 0)
		SetComponentProp(raw, 'DataSource', {})
		-- 更新大小
		SetComponentProp(raw, 'UpdateTableRect', function()
			local nRawWidth, nRawHeight = raw:GetSize()
			local hTotal = raw:Lookup('', '')
			local nFixedLWidth = math.min(nRawWidth, GetComponentProp(raw, 'nFixedLColumnsWidth'))
			local nFixedRWidth = math.min(nRawWidth - nFixedLWidth, GetComponentProp(raw, 'nFixedRColumnsWidth'))
			hTotal:SetSize(nRawWidth, nRawHeight)
			hTotal:Lookup('Image_Table_Border'):SetRelPos(-1, -1)
			hTotal:Lookup('Image_Table_Border'):SetSize(nRawWidth + 2, nRawHeight + 2)
			hTotal:Lookup('Image_Table_Background'):SetSize(nRawWidth - 4, nRawHeight - 30)
			hTotal:Lookup('Image_Table_TitleHr'):SetW(nRawWidth - 6)
			-- 左侧固定列
			hTotal:Lookup('Handle_Fixed_L_TableColumns'):SetSize(nFixedLWidth, nRawHeight)
			hTotal:Lookup('Handle_Fixed_L_Scroll_Y_Wrapper'):SetW(nFixedLWidth)
			hTotal:Lookup('Handle_Fixed_L_Scroll_Y_Wrapper'):SetH(nRawHeight - 60)
			hTotal:Lookup('Handle_Fixed_L_Summary'):SetRelX(0)
			hTotal:Lookup('Handle_Fixed_L_Summary'):SetRelY(nRawHeight - 30)
			-- 右侧固定列
			hTotal:Lookup('Handle_Fixed_R_TableColumns'):SetSize(nFixedRWidth, nRawHeight)
			hTotal:Lookup('Handle_Fixed_R_TableColumns'):SetRelX(nRawWidth - nFixedRWidth)
			hTotal:Lookup('Handle_Fixed_R_Scroll_Y_Wrapper'):SetW(nFixedRWidth)
			hTotal:Lookup('Handle_Fixed_R_Scroll_Y_Wrapper'):SetRelX(nRawWidth - nFixedRWidth)
			hTotal:Lookup('Handle_Fixed_R_Scroll_Y_Wrapper'):SetH(nRawHeight - 60)
			hTotal:Lookup('Handle_Fixed_R_Summary'):SetRelX(nRawWidth - nFixedRWidth)
			hTotal:Lookup('Handle_Fixed_R_Summary'):SetRelY(nRawHeight - 30)
			-- 水平滚动列
			hTotal:Lookup('Handle_Scroll_X_Wrapper'):SetRelX(nFixedLWidth)
			hTotal:Lookup('Handle_Scroll_X_Wrapper'):SetSize(nRawWidth - nFixedLWidth - nFixedRWidth, nRawHeight)
			hTotal:Lookup('Handle_Scroll_X_Wrapper/Handle_Scroll_X'):SetH(nRawHeight)
			hTotal:Lookup('Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper'):SetH(nRawHeight - 60)
			hTotal:Lookup('Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Summary'):SetRelY(nRawHeight - 30)
			hTotal:Lookup('Handle_Scroll_X_Wrapper/Handle_Scroll_X'):FormatAllItemPos()
			hTotal:FormatAllItemPos()
			raw:Lookup('Scroll_X'):SetW(nRawWidth)
			raw:Lookup('Scroll_X'):SetRelY(nRawHeight - 10)
			local nMaxScrollXBtnW = X.UI.IS_GLASSMORPHISM and 60 or 200
			raw:Lookup('Scroll_X/Btn_Scroll_X'):SetW(math.min(nMaxScrollXBtnW, math.max(100, nRawWidth / 3)))
			raw:Lookup('Scroll_Y'):SetH(nRawHeight - 32)
			raw:Lookup('Scroll_Y'):SetRelX(nRawWidth - 12)
			raw:Lookup('Scroll_Y/Btn_Scroll_Y'):SetH(math.min(80, math.max(40, (nRawHeight - 10) / 3)))
			GetComponentProp(raw, 'UpdateSummaryVisible')()
			GetComponentProp(raw, 'UpdateTitleColumnsRect')()
			GetComponentProp(raw, 'UpdateContentColumnsWidth')()
			GetComponentProp(raw, 'UpdateSummaryColumnsWidth')()
			GetComponentProp(raw, 'UpdateScrollY')()
		end)
		-- 更新表格水平滚动条
		SetComponentProp(raw, 'UpdateScrollX', function()
			local hWrapper = raw:Lookup('', 'Handle_Scroll_X_Wrapper')
			local hScroll = hWrapper:Lookup('Handle_Scroll_X')
			local nStepCount = hScroll:GetW() - hWrapper:GetW()
			if hWrapper:GetW() > 0 and nStepCount > 0 then
				raw:Lookup('Scroll_X'):Show()
				raw:Lookup('Scroll_X'):SetStepCount(nStepCount)
			else
				raw:Lookup('Scroll_X'):Hide()
			end
		end)
		-- 更新表格垂直滚动条
		SetComponentProp(raw, 'UpdateScrollY', function()
			-- 固定列与滚动列之间垂直方向应该是同步的，区滚动列的滚动高度即可
			local hWrapper = raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper')
			local hScrollableContents = hWrapper:Lookup('Handle_Scroll_Y')
			local nStepCount = hScrollableContents:GetH() - hWrapper:GetH()
			if nStepCount > 0 then
				raw:Lookup('Scroll_Y'):Show()
				raw:Lookup('Scroll_Y'):SetStepCount(nStepCount)
			else
				raw:Lookup('Scroll_Y'):Hide()
			end
		end)
		-- 自适应表头宽高
		SetComponentProp(raw, 'UpdateTitleColumnsRect', function()
			local function UpdateTitleColumnRect(hCol, col, nWidth, nHeight)
				local hContentWrapper = hCol:Lookup('Handle_TableColumn_Content_Wrapper') -- 外部居中层
				local hContent = hContentWrapper:Lookup('Handle_TableColumn_Content') -- 内部文本布局层
				local imgSortTip = hCol:Lookup('Image_TableColumn_SortTip')
				local imgMoveTip = hCol:Lookup('Image_TableColumn_MoveTip')
				local imgAsc = hCol:Lookup('Image_TableColumn_Asc')
				local imgDesc = hCol:Lookup('Image_TableColumn_Desc')
				local imgBreak = hCol:Lookup('Image_TableColumn_Break')
				local nFloatLeft = nWidth >= 150 and 10 or 0
				local nFloatRight = nWidth - nFloatLeft
				local szAlignHorizontal = col.alignHorizontal or 'left'
				hCol:SetW(nWidth)
				hContentWrapper:SetW(nWidth)
				hContent:SetW(99999)
				hContent:FormatAllItemPos()
				hContent:SetSizeByAllItemSize()
				if col.alignVertical == 'top' then
					hContent:SetRelY(0)
				elseif col.alignVertical == 'middle' or col.alignVertical == nil then
					hContent:SetRelY((hContentWrapper:GetH() - hContent:GetH()) / 2)
				elseif col.alignVertical == 'bottom' then
					hContent:SetRelY(hContentWrapper:GetH() - hContent:GetH())
				end
				if szAlignHorizontal == 'left' then
					hContent:SetRelX(5)
				elseif szAlignHorizontal == 'center' then
					hContent:SetRelX((nWidth - hContent:GetW()) / 2)
				elseif szAlignHorizontal == 'right' then
					hContent:SetRelX(nWidth - hContent:GetW() - 5)
				end
				if nWidth <= 80 then
					imgAsc:SetSize(10, 10)
					imgAsc:SetRelPos(nWidth - imgAsc:GetW() - 1, 3)
					imgDesc:SetSize(10, 10)
					imgDesc:SetRelPos(nWidth - imgDesc:GetW() - 1, 3)
					imgSortTip:SetSize(10, 10)
					imgSortTip:SetRelPos(nWidth - imgSortTip:GetW() - 1, 3)
					imgMoveTip:SetSize(10, 10)
					imgMoveTip:SetRelPos(nWidth - imgMoveTip:GetW() - 1, 15)
				elseif szAlignHorizontal == 'left' then
					imgAsc:SetRelX(nFloatRight - imgAsc:GetW())
					imgDesc:SetRelX(nFloatRight - imgDesc:GetW())
					imgSortTip:SetRelX(nFloatRight - imgSortTip:GetW())
					nFloatRight = nFloatRight - imgSortTip:GetW() - 3
					imgMoveTip:SetRelX(nFloatRight - imgMoveTip:GetW())
					nFloatRight = nFloatRight - imgMoveTip:GetW() - 3
				elseif szAlignHorizontal == 'center' then
					imgAsc:SetRelX(nFloatRight - imgAsc:GetW())
					imgDesc:SetRelX(nFloatRight - imgDesc:GetW())
					imgSortTip:SetRelX(nFloatRight - imgSortTip:GetW())
					nFloatRight = nFloatRight - imgSortTip:GetW() - 3
					imgMoveTip:SetRelX(nFloatLeft)
					nFloatLeft = nFloatLeft + imgMoveTip:GetW() + 3
				elseif szAlignHorizontal == 'right' then
					imgAsc:SetRelX(nFloatLeft)
					imgDesc:SetRelX(nFloatLeft)
					imgSortTip:SetRelX(nFloatLeft)
					nFloatLeft = nFloatLeft + imgSortTip:GetW() + 3
					imgMoveTip:SetRelX(nFloatLeft)
					nFloatLeft = nFloatLeft + imgMoveTip:GetW() + 3
				end
				imgBreak:SetRelY(2)
				imgBreak:SetH(nHeight - 3)
				hContentWrapper:FormatAllItemPos()
				hCol:FormatAllItemPos()
			end
			local nRawWidth, nRawHeight = raw:GetSize()
			-- 左侧固定列
			local nX = 0
			local nFixedLWidth = math.min(nRawWidth, GetComponentProp(raw, 'nFixedLColumnsWidth'))
			local aFixedLColumns = GetComponentProp(raw, 'aFixedLColumns')
			local hFixedLColumns = raw:Lookup('', 'Handle_Fixed_L_TableColumns')
			for i, col in ipairs(aFixedLColumns) do
				local hCol = hFixedLColumns:Lookup(i - 1)
				local nWidth = col.width
				hCol:SetRelX(nX)
				nX = nX + nWidth
				hCol:Lookup('Image_TableColumn_Break'):SetRelX(nWidth - 3)
				hCol:Lookup('Image_TableColumn_Break'):Show()
				UpdateTitleColumnRect(hCol, col, nWidth, nRawHeight)
			end
			hFixedLColumns:SetW(nFixedLWidth)
			hFixedLColumns:FormatAllItemPos()
			raw:Lookup('', 'Handle_Fixed_L_Summary'):SetW(nFixedLWidth)
			raw:Lookup('', 'Handle_Fixed_L_Scroll_Y_Wrapper'):SetW(nFixedLWidth)
			-- 右侧固定列
			local nX = 0
			local nFixedRWidth = math.min(nRawWidth - nFixedLWidth, GetComponentProp(raw, 'nFixedRColumnsWidth'))
			local aFixedRColumns = GetComponentProp(raw, 'aFixedRColumns')
			local hFixedRColumns = raw:Lookup('', 'Handle_Fixed_R_TableColumns')
			for i, col in ipairs(aFixedRColumns) do
				local hCol = hFixedRColumns:Lookup(i - 1)
				local nWidth = col.width
				hCol:SetRelX(nX)
				nX = nX + nWidth
				UpdateTitleColumnRect(hCol, col, nWidth, nRawHeight)
			end
			hFixedRColumns:SetRelX(nRawWidth - nFixedRWidth)
			hFixedRColumns:SetW(nFixedRWidth)
			hFixedRColumns:FormatAllItemPos()
			raw:Lookup('', 'Handle_Fixed_R_Summary'):SetRelX(nRawWidth - nFixedRWidth)
			raw:Lookup('', 'Handle_Fixed_R_Summary'):SetW(nFixedRWidth)
			raw:Lookup('', 'Handle_Fixed_R_Scroll_Y_Wrapper'):SetRelX(nRawWidth - nFixedRWidth)
			raw:Lookup('', 'Handle_Fixed_R_Scroll_Y_Wrapper'):SetW(nFixedRWidth)
			-- 水平滚动列
			local aScrollableColumns = GetComponentProp(raw, 'aScrollableColumns')
			local hScrollableColumns = raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_TableColumns')
			local nX = 0
			local nScrollX = GetComponentProp(raw, 'ScrollX')
			if not nScrollX or nScrollX == 'auto' then
				nScrollX = raw:GetW() - nFixedLWidth - nFixedRWidth
			end
			-- 计算各列最终宽度
			local aColWidth = {}
			local nTotalBaseWidth = 0
			local aFlexibleCols = {} -- 弹性列（没有设置width字段的列）
			for i, col in ipairs(aScrollableColumns) do
				local nBaseWidth = col.width or col.minWidth or 0
				aColWidth[i] = nBaseWidth
				nTotalBaseWidth = nTotalBaseWidth + nBaseWidth
				if not col.width then
					table.insert(aFlexibleCols, i)
				end
			end
			-- 计算剩余宽度
			local nExtraWidth = nScrollX - nTotalBaseWidth
			if nExtraWidth > 0 then
				-- 第一步：如果存在非固定宽度列，优先将剩余宽度平均分配给它们
				if #aFlexibleCols > 0 then
					local nAvgExtra = nExtraWidth / #aFlexibleCols
					for _, i in ipairs(aFlexibleCols) do
						aColWidth[i] = aColWidth[i] + nAvgExtra
					end
					nExtraWidth = 0 -- 剩余宽度已分配完
				end
				-- 第二步：收集所有未达到maxWidth的列，检查并处理超出maxWidth的情况
				local aUnmaxedCols = {}
				local nOverflow = 0
				for i, col in ipairs(aScrollableColumns) do
					if col.maxWidth and aColWidth[i] > col.maxWidth then
						nOverflow = nOverflow + (aColWidth[i] - col.maxWidth)
						aColWidth[i] = col.maxWidth
					else
						table.insert(aUnmaxedCols, i)
					end
				end
				-- 加上情况一中未分配的剩余宽度
				nOverflow = nOverflow + nExtraWidth
				-- 第三步：循环将超出部分按原始width比例分配给未达到maxWidth的列
				while nOverflow > 0.01 and #aUnmaxedCols > 0 do
					local nTotalOrigWidth = 0
					for _, i in ipairs(aUnmaxedCols) do
						nTotalOrigWidth = nTotalOrigWidth + (aScrollableColumns[i].minWidth or aScrollableColumns[i].width or 0)
					end
					if nTotalOrigWidth <= 0 then
						break
					end
					local aNextUnmaxedCols = {}
					local nNextOverflow = 0
					for _, i in ipairs(aUnmaxedCols) do
						local col = aScrollableColumns[i]
						local nOrigWidth = col.minWidth or col.width or 0
						local nAddWidth = nOverflow * nOrigWidth / nTotalOrigWidth
						aColWidth[i] = aColWidth[i] + nAddWidth
						if col.maxWidth and aColWidth[i] > col.maxWidth then
							nNextOverflow = nNextOverflow + (aColWidth[i] - col.maxWidth)
							aColWidth[i] = col.maxWidth
						else
							table.insert(aNextUnmaxedCols, i)
						end
					end
					nOverflow = nNextOverflow
					aUnmaxedCols = aNextUnmaxedCols
				end
			elseif nExtraWidth < 0 then
				-- 宽度不足，使用原始宽度，出现滚动条
				nScrollX = nTotalBaseWidth
			end
			-- 应用计算后的宽度
			for i, col in ipairs(aScrollableColumns) do
				local hCol = hScrollableColumns:Lookup(i - 1) -- 外部居中层
				local nWidth = aColWidth[i] or col.width or col.minWidth or 0
				if i == 1 then
					hCol:Lookup('Image_TableColumn_Break'):Hide()
				end
				UpdateTitleColumnRect(hCol, col, nWidth, nRawHeight)
				hCol:SetRelX(nX)
				nX = nX + nWidth
			end
			hScrollableColumns:SetW(nX)
			hScrollableColumns:FormatAllItemPos()
			raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X'):SetW(nX)
			raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper'):SetW(nX)
			raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper/Handle_Scroll_Y'):SetW(nX)
			raw:Lookup('', 'Handle_Scroll_X_Wrapper'):SetRelX(nFixedLWidth)
			raw:Lookup('', 'Handle_Scroll_X_Wrapper'):SetSize(nRawWidth - nFixedLWidth - nFixedRWidth, nRawHeight)
			raw:Lookup('', ''):FormatAllItemPos()
			-- 汇总水平滚动区
			raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Summary'):SetW(nX)
			-- 更新水平滚动条
			GetComponentProp(raw, 'UpdateScrollX')()
		end)
		-- 更新排序函数与表头排序状态显示
		SetComponentProp(raw, 'UpdateSorterStatus', function()
			local szSortKey = GetComponentProp(raw, 'SortKey')
			local szSortOrder = GetComponentProp(raw, 'SortOrder')
			local function UpdateSortStatus(hCol, col)
				local imgAsc = hCol:Lookup('Image_TableColumn_Asc')
				local imgDesc = hCol:Lookup('Image_TableColumn_Desc')
				if szSortKey == col.key and col.sorter then
					local sorter = col.sorter
					if sorter == true then
						sorter = function(a, b)
							if a == b then
								return 0
							end
							return a > b and 1 or -1
						end
					end
					SetComponentProp(raw, 'Sorter', function(r1, r2)
						local v1, v2 = r1[col.key], r2[col.key]
						if szSortOrder == 'asc' then
							return sorter(v1, v2, r1, r2) < 0
						end
						return sorter(v1, v2, r1, r2) > 0
					end)
				end
				imgAsc:SetVisible(szSortKey == col.key and szSortOrder == 'asc')
				imgDesc:SetVisible(szSortKey == col.key and szSortOrder == 'desc')
			end
			SetComponentProp(raw, 'Sorter', nil)
			-- 左侧固定列
			local aFixedLColumns = GetComponentProp(raw, 'aFixedLColumns')
			local hFixedLColumns = raw:Lookup('', 'Handle_Fixed_L_TableColumns')
			for i, col in ipairs(aFixedLColumns) do
				local hCol = hFixedLColumns:Lookup(i - 1)
				UpdateSortStatus(hCol, col)
			end
			-- 右侧固定列
			local aFixedRColumns = GetComponentProp(raw, 'aFixedRColumns')
			local hFixedRColumns = raw:Lookup('', 'Handle_Fixed_R_TableColumns')
			for i, col in ipairs(aFixedRColumns) do
				local hCol = hFixedRColumns:Lookup(i - 1)
				UpdateSortStatus(hCol, col)
			end
			-- 水平滚动列
			local aScrollableColumns = GetComponentProp(raw, 'aScrollableColumns')
			local hScrollableColumns = raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_TableColumns')
			for i, col in ipairs(aScrollableColumns) do
				local hCol = hScrollableColumns:Lookup(i - 1)
				UpdateSortStatus(hCol, col)
			end
		end)
		-- 绘制表头内容
		SetComponentProp(raw, 'DrawColumnsTitle', function()
			local function DrawColumnTitle(hColumns, aColumns)
				hColumns:Clear()
				for i, col in ipairs(aColumns) do
					local hCol = hColumns:AppendItemFromIni(X.PACKET_INFO.UI_COMPONENT_ROOT .. 'WndTable.ini', 'Handle_TableColumn')
					local hContentWrapper = hCol:Lookup('Handle_TableColumn_Content_Wrapper') -- 外部居中层
					local hContent = hContentWrapper:Lookup('Handle_TableColumn_Content') -- 内部文本布局层
					if i == 0 then
						hCol:Lookup('Image_TableColumn_Break'):Hide()
					end
					-- 标题
					local szTitle, bTitleRich = col.title, col.titleRich
					if X.IsFunction(col.title) then
						szTitle, bTitleRich = col.title(col)
					end
					if not bTitleRich then
						szTitle = GetFormatText(szTitle)
					end
					hContent:AppendItemFromString(szTitle)
					-- 事件
					local ui = X.UI(hCol)
					-- 标题 Tip
					if col.titleTip then
						local tipProps = X.Clone(col.titleTip)
						if not X.IsTable(tipProps) then
							tipProps = { render = tipProps }
						end
						if not tipProps.position then
							tipProps.position = X.UI.TIP_POSITION.TOP_BOTTOM
						end
						if not X.IsTable(tipProps.rect) then
							tipProps.rect = {}
						end
						ui:UIEvent('OnItemMouseEnter', function()
							local nX = this:GetAbsX()
							local nW = this:GetW()
							local nRawX = raw:GetAbsX()
							local nOffset = nX < nRawX and nRawX - nX or 0
							tipProps.rect.x = nX + nOffset
							tipProps.rect.w = nW - nOffset
							OutputAdvanceTip(tipProps, col)
						end)
						ui:UIEvent('OnItemMouseLeave', function()
							HideAdvanceTip(tipProps)
						end)
					end
					-- 排序
					if col.sorter then
						ui:UIEvent('OnItemMouseEnter', function()
							if GetComponentProp(raw, 'SortKey') == col.key then
								return
							end
							hCol:Lookup('Image_TableColumn_SortTip'):Show()
						end)
						ui:UIEvent('OnItemMouseLeave', function()
							if not hCol:Lookup('Image_TableColumn_SortTip') then
								return
							end
							hCol:Lookup('Image_TableColumn_SortTip'):Hide()
						end)
						ui:UIEvent('OnItemLButtonClick', function()
							if GetComponentProp(raw, 'SortKey') == col.key then
								SetComponentProp(raw, 'SortOrder', GetComponentProp(raw, 'SortOrder') == 'asc' and 'desc' or 'asc')
							else
								SetComponentProp(raw, 'SortKey', col.key)
							end
							hCol:Lookup('Image_TableColumn_SortTip'):Hide()
							GetComponentProp(raw, 'UpdateSorterStatus')()
							GetComponentProp(raw, 'DrawTableContent')()
							X.SafeCall(GetComponentProp(raw, 'OnSortChange'))
						end)
					end
					-- 拖拽
					if col.draggable then
						ui:UIEvent('OnItemMouseEnter', function()
							hCol:Lookup('Image_TableColumn_MoveTip'):Show()
						end)
						ui:UIEvent('OnItemMouseLeave', function()
							if not hCol:Lookup('Image_TableColumn_MoveTip') then
								return
							end
							hCol:Lookup('Image_TableColumn_MoveTip'):Hide()
						end)
						ui:DragDropGroup(tostring(raw))
						ui:Drag(function()
							local capture = {
								element = raw,
								x = hCol:GetAbsX() - raw:GetAbsX(),
								y = 0,
								w = hCol:GetW(),
								h = raw:GetH(),
							}
							return col, capture
						end)
						ui:DragHover(function()
							local rect = {
								x = hCol:GetAbsX(),
								y = hCol:GetAbsY() + 1,
								w = hCol:GetW(),
								h = raw:GetH() - 2,
							}
							return rect
						end)
						ui:Drop(function(_, c)
							if c == col then
								return
							end
							local aColumns = X.Assign({}, GetComponentProp(raw, 'aColumns'))
							local nFromIndex = math.huge
							for i, v in ipairs(aColumns) do
								if v == c then
									nFromIndex = i
									table.remove(aColumns, i)
									break
								end
							end
							for i, v in ipairs(aColumns) do
								if v == col then
									if nFromIndex <= i then
										i = i + 1
									end
									table.insert(aColumns, i, c)
									break
								end
							end
							X.UI(raw):Columns(aColumns)
							X.SafeCall(GetComponentProp(raw, 'OnColumnsChange'))
						end)
					end
				end
			end
			-- 左侧固定列
			local aFixedLColumns = GetComponentProp(raw, 'aFixedLColumns')
			local hFixedLColumns = raw:Lookup('', 'Handle_Fixed_L_TableColumns')
			DrawColumnTitle(hFixedLColumns, aFixedLColumns)
			-- 右侧固定列
			local aFixedRColumns = GetComponentProp(raw, 'aFixedRColumns')
			local hFixedRColumns = raw:Lookup('', 'Handle_Fixed_R_TableColumns')
			DrawColumnTitle(hFixedRColumns, aFixedRColumns)
			-- 水平滚动列
			local aScrollableColumns = GetComponentProp(raw, 'aScrollableColumns')
			local hScrollableColumns = raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_TableColumns')
			DrawColumnTitle(hScrollableColumns, aScrollableColumns)
			-- 重新计算列宽高、排序状态
			GetComponentProp(raw, 'UpdateTitleColumnsRect')()
			GetComponentProp(raw, 'UpdateSorterStatus')()
		end)
		-- 更新数据行各列宽度（跟随表头）
		SetComponentProp(raw, 'UpdateContentColumnsWidth', function()
			local function UpdateContentColumnsWidth(hContents, hTitleColumns, aColumns)
				for nRowIndex = 0, hContents:GetItemCount() - 1 do
					local hRow = hContents:Lookup(nRowIndex)
					local hRowColumns = hRow:Lookup('Handle_RowColumns')
					local nX = 0
					for nColumnIndex, col in ipairs(aColumns) do
						local nWidth = hTitleColumns:Lookup(nColumnIndex - 1):GetW()
						local hItem = hRowColumns:Lookup(nColumnIndex - 1) -- 外部居中层
						local hItemContent = hItem:Lookup('Handle_ItemContent') -- 内部文本布局层
						hItemContent:SetW(99999)
						hItemContent:FormatAllItemPos()
						hItemContent:SetSizeByAllItemSize()
						hItem:SetRelX(nX)
						hItem:SetW(nWidth)
						if col.alignVertical == 'top' then
							hItemContent:SetRelY(0)
						elseif col.alignVertical == 'middle' or col.alignVertical == nil then
							hItemContent:SetRelY((hItem:GetH() - hItemContent:GetH()) / 2)
						elseif col.alignVertical == 'bottom' then
							hItemContent:SetRelY(hItem:GetH() - hItemContent:GetH())
						end
						if col.alignHorizontal == 'left' or col.alignHorizontal == nil then
							hItemContent:SetRelX(5)
						elseif col.alignHorizontal == 'center' then
							hItemContent:SetRelX((nWidth - hItemContent:GetW()) / 2)
						elseif col.alignHorizontal == 'right' then
							hItemContent:SetRelX(nWidth - hItemContent:GetW() - 5)
						end
						hItem:FormatAllItemPos()
						nX = nX + nWidth
					end
					hRowColumns:SetW(nX)
					hRowColumns:FormatAllItemPos()
					hRow:SetW(nX)
					hRow:Lookup('Image_RowBg'):SetW(nX)
					hRow:Lookup('Image_RowHover'):SetW(nX)
					hRow:Lookup('Image_RowSpliter'):SetW(nX)
					hRow:FormatAllItemPos()
				end
				hContents:SetW(hTitleColumns:GetW())
				hContents:FormatAllItemPos()
			end
			-- 左侧固定列
			local aFixedLColumns = GetComponentProp(raw, 'aFixedLColumns')
			local hFixedLContents = raw:Lookup('', 'Handle_Fixed_L_Scroll_Y_Wrapper/Handle_Fixed_L_Scroll_Y')
			local hFixedLColumns = raw:Lookup('', 'Handle_Fixed_L_TableColumns')
			UpdateContentColumnsWidth(hFixedLContents, hFixedLColumns, aFixedLColumns)
			-- 右侧固定列
			local aFixedRColumns = GetComponentProp(raw, 'aFixedRColumns')
			local hFixedRContents = raw:Lookup('', 'Handle_Fixed_R_Scroll_Y_Wrapper/Handle_Fixed_R_Scroll_Y')
			local hFixedRColumns = raw:Lookup('', 'Handle_Fixed_R_TableColumns')
			UpdateContentColumnsWidth(hFixedRContents, hFixedRColumns, aFixedRColumns)
			-- 水平滚动列
			local aScrollableColumns = GetComponentProp(raw, 'aScrollableColumns')
			local hScrollableContents = raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper/Handle_Scroll_Y')
			local hScrollableColumns = raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_TableColumns')
			UpdateContentColumnsWidth(hScrollableContents, hScrollableColumns, aScrollableColumns)
		end)
		-- 绘制数据行
		SetComponentProp(raw, 'DrawTableContent', function()
			local function DrawContent(hContents, aColumns, aDataSource)
				hContents:Clear()
				local nContentsH = 0
				for nRowIndex, rec in ipairs(aDataSource) do
					local hRow = hContents:AppendItemFromIni(X.PACKET_INFO.UI_COMPONENT_ROOT .. 'WndTable.ini', 'Handle_Row')
					local hRowColumns = hRow:Lookup('Handle_RowColumns')
					hRowColumns:Clear()
					hRow:Lookup('Image_RowBg'):SetVisible(nRowIndex % 2 == 1)
					for nColumnIndex, col in ipairs(aColumns) do
						local xValue = rec[col.key]
						local hItem = hRowColumns:AppendItemFromIni(X.PACKET_INFO.UI_COMPONENT_ROOT .. 'WndTable.ini', col.overflow == 'hidden' and 'Handle_Item_PixelScroll' or 'Handle_Item') -- 外部居中层
						hItem:SetName('Handle_Item')
						local hItemContent = hItem:AppendItemFromIni(X.PACKET_INFO.UI_COMPONENT_ROOT .. 'WndTable.ini', 'Handle_ItemContent') -- 内部文本布局层
						local szXml
						if col.render then
							szXml = col.render(xValue, rec, nRowIndex)
						else
							szXml = GetFormatText(xValue)
						end
						hItemContent:AppendItemFromString(szXml)
						-- 单元格 Tip
						if col.tip then
							local tipProps = X.Clone(col.tip)
							if not X.IsTable(tipProps) then
								tipProps = { render = tipProps }
							end
							if not tipProps.position then
								tipProps.position = X.UI.TIP_POSITION.LEFT_RIGHT
							end
							if not X.IsTable(tipProps.rect) then
								tipProps.rect = {}
							end
							hItem.OnItemMouseIn = function()
								local nX = this:GetAbsX()
								local nW = this:GetW()
								local nRawX = raw:GetAbsX()
								local nOffset = nX < nRawX and nRawX - nX or 0
								tipProps.rect.x = nX + nOffset
								tipProps.rect.w = nW - nOffset
								OutputAdvanceTip(tipProps, xValue, rec, nRowIndex)
							end
							hItem.OnItemMouseOut = function()
								HideAdvanceTip(tipProps)
							end
							hItem:RegisterEvent(X.UI.ITEM_EVENT.MOUSE_ENTER_LEAVE)
						end
						-- 单元格点击
						hItem.OnItemLButtonClick = function()
							local fnAction = GetComponentProp(raw, 'CellLClick')
							if not fnAction then
								X.SafeCallWithThis(hRow, hRow.OnItemLButtonClick)
								return
							end
							X.SafeCall(fnAction, xValue, rec, nRowIndex, col, nColumnIndex)
						end
						hItem:RegisterEvent(X.UI.ITEM_EVENT.L_BUTTON_CLICK)
						hItem.OnItemMButtonClick = function()
							local fnAction = GetComponentProp(raw, 'CellMClick')
							if not fnAction then
								X.SafeCallWithThis(hRow, hRow.OnItemMButtonClick)
								return
							end
							X.SafeCall(fnAction, xValue, rec, nRowIndex, col, nColumnIndex)
						end
						hItem:RegisterEvent(X.UI.ITEM_EVENT.M_BUTTON_CLICK)
						hItem.OnItemRButtonClick = function()
							local fnAction = GetComponentProp(raw, 'CellRClick')
							if not fnAction then
								X.SafeCallWithThis(hRow, hRow.OnItemRButtonClick)
								return
							end
							X.SafeCall(fnAction, xValue, rec, nRowIndex, col, nColumnIndex)
						end
						hItem:RegisterEvent(X.UI.ITEM_EVENT.R_BUTTON_CLICK)
					end
					hRow.OnItemMouseEnter = function()
						local nX, nY = raw:GetAbsX(), this:GetAbsY()
						local nW, nH = raw:GetW(), this:GetH()
						X.SafeCall(GetComponentProp(raw, 'OnRowHover'), true, rec, nRowIndex, { x = nX, y = nY, w = nW, h = nH })
					end
					hRow.OnItemMouseLeave = function()
						local nX, nY = raw:GetAbsX(), this:GetAbsY()
						local nW, nH = raw:GetW(), this:GetH()
						X.SafeCall(GetComponentProp(raw, 'OnRowHover'), false, rec, nRowIndex, { x = nX, y = nY, w = nW, h = nH })
					end
					hRow.OnItemMouseIn = function()
						for _, szPath in ipairs({
							'Handle_Fixed_L_Scroll_Y_Wrapper/Handle_Fixed_L_Scroll_Y',
							'Handle_Fixed_R_Scroll_Y_Wrapper/Handle_Fixed_R_Scroll_Y',
							'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper/Handle_Scroll_Y',
						}) do
							local hL = raw:Lookup('', szPath)
							for i = 0, hL:GetItemCount() - 1 do
								hL:Lookup(i):Lookup('Image_RowHover'):SetVisible(i + 1 == nRowIndex)
							end
						end
					end
					hRow.OnItemMouseOut = function()
						for _, szPath in ipairs({
							'Handle_Fixed_L_Scroll_Y_Wrapper/Handle_Fixed_L_Scroll_Y',
							'Handle_Fixed_R_Scroll_Y_Wrapper/Handle_Fixed_R_Scroll_Y',
							'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper/Handle_Scroll_Y',
						}) do
							local hL = raw:Lookup('', szPath)
							for i = 0, hL:GetItemCount() - 1 do
								local hLI = hL:Lookup(i)
								local hImg = X.IsElement(hLI) and hLI:Lookup('Image_RowHover')
								if X.IsElement(hImg) then
									hImg:Hide()
								end
							end
						end
					end
					hRow.OnItemLButtonClick = function()
						X.SafeCall(GetComponentProp(raw, 'RowLClick'), rec, nRowIndex)
					end
					hRow.OnItemMButtonClick = function()
						X.SafeCall(GetComponentProp(raw, 'RowMClick'), rec, nRowIndex)
					end
					hRow.OnItemRButtonClick = function()
						X.SafeCall(GetComponentProp(raw, 'RowRClick'), rec, nRowIndex)
					end
					nContentsH = nContentsH + hRow:GetH()
				end
				hContents:SetH(nContentsH)
			end
			local aDataSource = GetComponentProp(raw, 'DataSource')
			local Sorter = GetComponentProp(raw, 'Sorter')
			if Sorter then
				local ds = {}
				for _, v in ipairs(aDataSource) do
					table.insert(ds, v)
				end
				table.sort(ds, Sorter)
				aDataSource = ds
			end
			-- 左侧固定列
			local hFixedLContents = raw:Lookup('', 'Handle_Fixed_L_Scroll_Y_Wrapper/Handle_Fixed_L_Scroll_Y')
			local aFixedLColumns = GetComponentProp(raw, 'aFixedLColumns')
			DrawContent(hFixedLContents, aFixedLColumns, aDataSource)
			-- 右侧固定列
			local hFixedRContents = raw:Lookup('', 'Handle_Fixed_R_Scroll_Y_Wrapper/Handle_Fixed_R_Scroll_Y')
			local aFixedRColumns = GetComponentProp(raw, 'aFixedRColumns')
			DrawContent(hFixedRContents, aFixedRColumns, aDataSource)
			-- 水平滚动列
			local hScrollableContents = raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper/Handle_Scroll_Y')
			local aScrollableColumns = GetComponentProp(raw, 'aScrollableColumns')
			DrawContent(hScrollableContents, aScrollableColumns, aDataSource)
			-- 更新列宽、垂直滚动条
			GetComponentProp(raw, 'UpdateContentColumnsWidth')()
			GetComponentProp(raw, 'UpdateScrollY')()
		end)
		-- 更新汇总行
		SetComponentProp(raw, 'UpdateSummaryVisible', function()
			local nHeight = raw:GetH()
			local hTotal = raw:Lookup('', '')
			local summary = GetComponentProp(raw, 'Summary')
			if summary then
				hTotal:Lookup('Handle_Fixed_L_Scroll_Y_Wrapper'):SetH(nHeight - 60)
				hTotal:Lookup('Handle_Fixed_R_Scroll_Y_Wrapper'):SetH(nHeight - 60)
				hTotal:Lookup('Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper'):SetH(nHeight - 60)
				hTotal:Lookup('Handle_Fixed_L_Summary'):Show()
				hTotal:Lookup('Handle_Fixed_R_Summary'):Show()
				hTotal:Lookup('Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Summary'):Show()
			else
				hTotal:Lookup('Handle_Fixed_L_Scroll_Y_Wrapper'):SetH(nHeight - 30)
				hTotal:Lookup('Handle_Fixed_R_Scroll_Y_Wrapper'):SetH(nHeight - 30)
				hTotal:Lookup('Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper'):SetH(nHeight - 30)
				hTotal:Lookup('Handle_Fixed_L_Summary'):Hide()
				hTotal:Lookup('Handle_Fixed_R_Summary'):Hide()
				hTotal:Lookup('Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Summary'):Hide()
			end
			GetComponentProp(raw, 'UpdateScrollY')()
		end)
		-- 更新汇总行各列宽度（跟随表头）
		SetComponentProp(raw, 'UpdateSummaryColumnsWidth', function()
			local function UpdateSummaryColumnWidth(hContents, hColumns, aColumns)
				for nRowIndex = 0, hContents:GetItemCount() - 1 do
					local hRow = hContents:Lookup(nRowIndex)
					local hRowColumns = hRow:Lookup('Handle_RowColumns')
					local nX = 0
					for nColumnIndex, col in ipairs(aColumns) do
						local nWidth = hColumns:Lookup(nColumnIndex - 1):GetW()
						local hItem = hRowColumns:Lookup(nColumnIndex - 1) -- 外部居中层
						local hItemContent = hItem:Lookup('Handle_ItemContent') -- 内部文本布局层
						hItemContent:SetW(99999)
						hItemContent:FormatAllItemPos()
						hItemContent:SetSizeByAllItemSize()
						hItem:SetRelX(nX)
						hItem:SetW(nWidth)
						if col.alignVertical == 'top' then
							hItemContent:SetRelY(0)
						elseif col.alignVertical == 'middle' or col.alignVertical == nil then
							hItemContent:SetRelY((hItem:GetH() - hItemContent:GetH()) / 2)
						elseif col.alignVertical == 'bottom' then
							hItemContent:SetRelY(hItem:GetH() - hItemContent:GetH())
						end
						if col.alignHorizontal == 'left' or col.alignHorizontal == nil then
							hItemContent:SetRelX(5)
						elseif col.alignHorizontal == 'center' then
							hItemContent:SetRelX((nWidth - hItemContent:GetW()) / 2)
						elseif col.alignHorizontal == 'right' then
							hItemContent:SetRelX(nWidth - hItemContent:GetW() - 5)
						end
						hItem:FormatAllItemPos()
						nX = nX + nWidth
					end
					hRowColumns:SetW(nX)
					hRowColumns:FormatAllItemPos()
					hRow:SetW(nX)
					hRow:Lookup('Image_RowBg'):SetW(nX)
					hRow:Lookup('Image_RowHover'):SetW(nX)
					hRow:Lookup('Image_RowSpliter'):SetW(nX)
					hRow:FormatAllItemPos()
				end
				hContents:FormatAllItemPos()
			end
			-- 左侧固定列
			local hFixedLContents = raw:Lookup('', 'Handle_Fixed_L_Summary')
			local hFixedLColumns = raw:Lookup('', 'Handle_Fixed_L_TableColumns')
			local aFixedLColumns = GetComponentProp(raw, 'aFixedLColumns')
			UpdateSummaryColumnWidth(hFixedLContents, hFixedLColumns, aFixedLColumns)
			-- 右侧固定列
			local hFixedRContents = raw:Lookup('', 'Handle_Fixed_R_Summary')
			local hFixedRColumns = raw:Lookup('', 'Handle_Fixed_R_TableColumns')
			local aFixedRColumns = GetComponentProp(raw, 'aFixedRColumns')
			UpdateSummaryColumnWidth(hFixedRContents, hFixedRColumns, aFixedRColumns)
			-- 水平滚动列
			local hScrollableContents = raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Summary')
			local hScrollableColumns = raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_TableColumns')
			local aScrollableColumns = GetComponentProp(raw, 'aScrollableColumns')
			UpdateSummaryColumnWidth(hScrollableContents, hScrollableColumns, aScrollableColumns)
		end)
		-- 绘制汇总行
		SetComponentProp(raw, 'DrawTableSummary', function()
			local function DrawSummaryContents(hContents, aColumns)
				local rec = GetComponentProp(raw, 'Summary')
				hContents:Clear()
				local hRow = hContents:AppendItemFromIni(X.PACKET_INFO.UI_COMPONENT_ROOT .. 'WndTable.ini', 'Handle_Row')
				local hRowColumns = hRow:Lookup('Handle_RowColumns')
				hRowColumns:Clear()
				for nColumnIndex, col in ipairs(aColumns) do
					local hItem = hRowColumns:AppendItemFromIni(X.PACKET_INFO.UI_COMPONENT_ROOT .. 'WndTable.ini', col.overflow == 'hidden' and 'Handle_Item_PixelScroll' or 'Handle_Item') -- 外部居中层
					hItem:SetName('Handle_Item')
					local hItemContent = hItem:AppendItemFromIni(X.PACKET_INFO.UI_COMPONENT_ROOT .. 'WndTable.ini', 'Handle_ItemContent') -- 内部文本布局层
					local szXml
					if X.IsTable(rec) then
						if col.render then
							szXml = col.render(rec[col.key], rec, -1)
						else
							szXml = GetFormatText(rec[col.key])
						end
						hItemContent:AppendItemFromString(szXml)
					end
				end
				hRow.OnItemMouseIn = function()
					for _, szPath in ipairs({
						'Handle_Fixed_L_Summary',
						'Handle_Fixed_R_Summary',
						'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Summary',
					}) do
						local hL = raw:Lookup('', szPath)
						for i = 0, hL:GetItemCount() - 1 do
							hL:Lookup(i):Lookup('Image_RowHover'):SetVisible(i + 1 == 1)
						end
					end
				end
				hRow.OnItemMouseOut = function()
					for _, szPath in ipairs({
						'Handle_Fixed_L_Summary',
						'Handle_Fixed_R_Summary',
						'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Summary',
					}) do
						local hL = raw:Lookup('', szPath)
						for i = 0, hL:GetItemCount() - 1 do
							hL:Lookup(i):Lookup('Image_RowHover'):Hide()
						end
					end
				end
			end
			-- 左侧固定列
			local hFixedLContents = raw:Lookup('', 'Handle_Fixed_L_Summary')
			local aFixedLColumns = GetComponentProp(raw, 'aFixedLColumns')
			DrawSummaryContents(hFixedLContents, aFixedLColumns)
			-- 右侧固定列
			local hFixedRContents = raw:Lookup('', 'Handle_Fixed_R_Summary')
			local aFixedRColumns = GetComponentProp(raw, 'aFixedRColumns')
			DrawSummaryContents(hFixedRContents, aFixedRColumns)
			-- 水平滚动列
			local hScrollableContents = raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Summary')
			local aScrollableColumns = GetComponentProp(raw, 'aScrollableColumns')
			DrawSummaryContents(hScrollableContents, aScrollableColumns)
			-- 更新列宽
			GetComponentProp(raw, 'UpdateSummaryColumnsWidth')()
		end)
		-- 水平滚动条事件绑定
		local scrollX = raw:Lookup('Scroll_X')
		scrollX.OnScrollBarPosChanged = function()
			raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X'):SetRelX(-this:GetScrollPos())
			raw:Lookup('', 'Handle_Scroll_X_Wrapper'):FormatAllItemPos()
		end
		scrollX.OnMouseWheel = function()
			scrollX:ScrollNext(-Station.GetMessageWheelDelta() * 2)
			return 1
		end
		scrollX:Lookup('Btn_Scroll_X').OnMouseWheel = function()
			scrollX:ScrollNext(-Station.GetMessageWheelDelta())
			return 1
		end
		-- 垂直滚动条事件绑定
		local scrollY = raw:Lookup('Scroll_Y')
		scrollY.OnScrollBarPosChanged = function()
			-- 左侧固定列
			raw:Lookup('', 'Handle_Fixed_L_Scroll_Y_Wrapper/Handle_Fixed_L_Scroll_Y'):SetRelY(-this:GetScrollPos())
			raw:Lookup('', 'Handle_Fixed_L_Scroll_Y_Wrapper'):FormatAllItemPos()
			-- 右侧固定列
			raw:Lookup('', 'Handle_Fixed_R_Scroll_Y_Wrapper/Handle_Fixed_R_Scroll_Y'):SetRelY(-this:GetScrollPos())
			raw:Lookup('', 'Handle_Fixed_R_Scroll_Y_Wrapper'):FormatAllItemPos()
			-- 水平滚动列
			raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper/Handle_Scroll_Y'):SetRelY(-this:GetScrollPos())
			raw:Lookup('', 'Handle_Scroll_X_Wrapper/Handle_Scroll_X/Handle_Scroll_Y_Wrapper'):FormatAllItemPos()
		end
		scrollY.OnMouseWheel = function()
			scrollY:ScrollNext(-Station.GetMessageWheelDelta() * 2)
			return 1
		end
		scrollY:Lookup('Btn_Scroll_Y').OnMouseWheel = function()
			scrollY:ScrollNext(-Station.GetMessageWheelDelta())
			return 1
		end
		raw.OnMouseWheel = function()
			if not scrollY:IsVisible() then
				return
			end
			scrollY:ScrollNext(Station.GetMessageWheelDelta() * 10)
			return 1
		end
		X.UI.AdaptComponentAppearance(raw:Lookup('Scroll_X'))
		X.UI.AdaptComponentAppearance(raw:Lookup('Scroll_Y'))
	elseif szType == 'WndPageSet' then
		X.UI.AdaptComponentAppearance(raw:Lookup('', 'Image_TabBg'))
	elseif szType == 'WndTabs' then
		if X.UI.IS_GLASSMORPHISM then
			raw:Lookup('', 'Image_WndTabs_Classic_Bg'):Hide()
			raw:Lookup('', 'Image_WndTabs_Classic_SplitterL'):Hide()
		else
			raw:Lookup('', 'Image_WndTabs_Glassmorphism_Bg'):Hide()
		end
	elseif szType == 'WndTab' then
		if X.UI.IS_GLASSMORPHISM then
			raw:Lookup('', 'Image_WndTab_Splitter'):Hide()
			raw:SetAnimation('ui\\Image\\UItimate\\UICommon\\Button4.UITex', 14, 20, 14, 14, 20, 20, 20, 19, 14, 14)
		end
		X.UI(raw):UIEvent('OnLButtonUp', function()
			if not this:IsEnabled() or not this:IsMouseIn() then
				return
			end
			local group = GetComponentProp(this, 'group')
			local p = this:GetParent():GetFirstChild()
			while p do
				if p ~= this and GetComponentType(p) == 'WndTab' then
					local g = GetComponentProp(p, 'group')
					if g == group and p:IsCheckBoxChecked() then
						p:Check(false)
					end
				end
				p = p:GetNext()
			end
		end)
	elseif szType == 'CheckBox' then
		if X.UI.IS_GLASSMORPHISM then
			raw:Lookup('Image_Default'):FromUITex('ui\\Image\\UItimate\\UICommon\\Button4.UITex', 0)
		end
		local tStateFrame =
			X.UI.IS_GLASSMORPHISM
			and {
				nUnCheckAndEnable = 4,
				nUncheckedAndEnableWhenMouseOver = 5,
				nChecking = 6,
				nUnCheckAndDisable = 7,
				nCheckAndEnable = 0,
				nCheckedAndEnableWhenMouseOver = 1,
				nUnChecking = 2,
				nCheckAndDisable = 3,
			}
			or {
				nUnCheckAndEnable = 5,
				nUncheckedAndEnableWhenMouseOver = 98,
				nChecking = 5,
				nUnCheckAndDisable = 90,
				nCheckAndEnable = 6,
				nCheckedAndEnableWhenMouseOver = 7,
				nUnChecking = 6,
				nCheckAndDisable = 91,
			}
		raw:RegisterEvent(831)
		local function UpdateCheckState(raw)
			if not X.IsElement(raw) then
				return
			end
			local img = raw:Lookup('Image_Default')
			if not X.IsElement(img) then
				return
			end
			if GetComponentProp(raw, 'bDisabled') then
				img:SetFrame(GetComponentProp(raw, 'bChecked') and tStateFrame.nCheckAndDisable or tStateFrame.nUnCheckAndDisable)
				raw:SetAlpha(255)
			elseif GetComponentProp(raw, 'bDown') then
				img:SetFrame(GetComponentProp(raw, 'bChecked') and tStateFrame.nUnChecking or tStateFrame.nChecking)
				raw:SetAlpha(190)
			elseif GetComponentProp(raw, 'bIn') then
				img:SetFrame(GetComponentProp(raw, 'bChecked') and tStateFrame.nCheckedAndEnableWhenMouseOver or tStateFrame.nUncheckedAndEnableWhenMouseOver)
				raw:SetAlpha(255)
			else
				img:SetFrame(GetComponentProp(raw, 'bChecked') and tStateFrame.nCheckAndEnable or tStateFrame.nUnCheckAndEnable)
				raw:SetAlpha(255)
			end
		end
		raw.OnItemMouseIn = function()
			SetComponentProp(raw, 'bIn', true)
			UpdateCheckState(raw)
		end
		raw.OnItemMouseOut = function()
			SetComponentProp(raw, 'bIn', false)
			UpdateCheckState(raw)
		end
		raw.OnItemLButtonDown = function()
			SetComponentProp(raw, 'bDown', true)
			UpdateCheckState(raw)
		end
		raw.OnItemLButtonUp = function()
			SetComponentProp(raw, 'bDown', false)
			UpdateCheckState(raw)
		end
		raw.OnItemLButtonClick = function()
			raw:Check(not GetComponentProp(raw, 'bChecked'))
		end
		raw.Check = function(_, bChecked, eFireType)
			SetComponentProp(raw, 'bChecked', bChecked)
			UpdateCheckState(raw)
			if eFireType == WNDEVENT_FIRETYPE.PREVENT then
				return
			end
			if bChecked then
				if raw.OnCheckBoxCheck then
					raw.OnCheckBoxCheck()
				end
			else
				if raw.OnCheckBoxUncheck then
					raw.OnCheckBoxUncheck()
				end
			end
		end
		raw.IsCheckBoxChecked = function()
			return GetComponentProp(raw, 'bChecked') or false
		end
		raw.Enable = function(_, bEnabled)
			SetComponentProp(raw, 'bDisabled', not bEnabled)
			UpdateCheckState(raw)
		end
		raw.IsEnabled = function()
			return not GetComponentProp(raw, 'bDisabled')
		end
		UpdateCheckState(raw)
	elseif szType == 'Shadow' or szType == 'ColorBox' then
		SetComponentProp(raw, 'OnColorPickCBs', {})
		raw:RegisterEvent(831)
		raw.OnItemLButtonClick = function()
			-- 兼容普通 Shadow 组件，无注册事件不弹框
			if szType == 'Shadow' and #GetComponentProp(raw, 'OnColorPickCBs') == 0 then
				return
			end
			-- 颜色组件，无论是否注册过都弹框
			X.UI.OpenColorPicker(function(r, g, b)
				for _, cb in ipairs(GetComponentProp(raw, 'OnColorPickCBs')) do
					X.CallWithThis(raw, cb, r, g, b)
				end
				X.UI(raw):Color(r, g, b)
			end)
		end
		raw.Enable = function(_, bEnabled)
			SetComponentProp(raw, 'bDisabled', not bEnabled)
		end
		raw.IsEnabled = function()
			return not GetComponentProp(raw, 'bDisabled')
		end
	end
end

-----------------------------------------------------------
-- my ui selectors -- same as jQuery -- by tinymins --
-----------------------------------------------------------
local OO = {}
--
-- self.raws[] : ui element list
--
-- ui object creator
-- same as jQuery.$()
function OO:ctor(mixed)
	local raws = {}
	local oo = {}
	if X.IsTable(mixed) then
		if X.IsTable(mixed.raws) then
			for _, raw in ipairs(mixed.raws) do
				table.insert(raws, raw)
			end
		elseif X.IsElement(mixed) then
			table.insert(raws, mixed)
		else
			for _, raw in ipairs(mixed) do
				if X.IsElement(raw) then
					table.insert(raws, raw)
				end
			end
		end
	elseif X.IsString(mixed) then
		local raw = Station.Lookup(mixed)
		if X.IsElement(raw) then
			table.insert(raws, raw)
		end
	end
	return setmetatable(oo, {
		__index = function(t, k)
			if k == 'raws' then
				return raws
			elseif X.IsNumber(k) then
				if k < 0 then
					k = #raws + k + 1
				end
				return raws[k]
			else
				return OO[k]
			end
		end,
		__newindex = function(t, k, v)
			if X.IsNumber(k) then
				assert(false, 'Elements are readonly!')
			else
				assert(false, X.NSFormatString('{$NS}_UI (class instance) is readonly!'))
			end
		end,
		__tostring = function(t) return X.NSFormatString('{$NS}_UI (class instance)') end,
	})
end

--  del bad raws
-- (self) _checksum()
function OO:_checksum()
	for i, raw in X.ipairs_r(self.raws) do
		if not X.IsElement(raw) then
			table.remove(self.raws, i)
		end
	end
	return self
end

-- add a element to object
-- same as jQuery.add()
function OO:Add(mixed)
	self:_checksum()
	local raws = {}
	for i, raw in ipairs(self.raws) do
		table.insert(raws, raw)
	end
	if X.IsString(mixed) then
		mixed = Station.Lookup(mixed)
	end
	if X.IsElement(mixed) then
		table.insert(raws, mixed)
	end
	if X.IsTable(mixed) and tostring(mixed) == X.NSFormatString('{$NS}_UI (class instance)') then
		for i = 1, mixed:Count() do
			table.insert(raws, mixed[i])
		end
	end
	return X.UI(raws)
end

-- delete elements from object
-- same as jQuery.not()
function OO:Del(mixed)
	self:_checksum()
	local raws = {}
	for i, raw in ipairs(self.raws) do
		table.insert(raws, raw)
	end
	if X.IsString(mixed) then
		-- delete raws those id/class fits filter: mixed
		if string.sub(mixed, 1, 1) == '#' then
			mixed = string.sub(mixed, 2)
			if string.sub(mixed, 1, 1) == '^' then
				-- regexp
				for i, raw in X.ipairs_r(raws) do
					if string.find(raw:GetName(), mixed) then
						table.remove(raws, i)
					end
				end
			else
				-- normal
				for i, raw in X.ipairs_r(raws) do
					if raw:GetName() == mixed then
						table.remove(raws, i)
					end
				end
			end
		elseif string.sub(mixed, 1, 1) == '.' then
			mixed = string.sub(mixed, 2)
			if string.sub(mixed, 1, 1) == '^' then
				-- regexp
				for i, raw in X.ipairs_r(raws) do
					if string.find(GetComponentType(raw), mixed) then
						table.remove(raws, i)
					end
				end
			else
				-- normal
				for i, raw in X.ipairs_r(raws) do
					if GetComponentType(raw) == mixed then
						table.remove(raws, i)
					end
				end
			end
		end
	elseif X.IsElement(mixed) then
		-- delete raws those treepath is the same as mixed
		mixed = table.concat({ mixed:GetTreePath() })
		for i, raw in X.ipairs_r(raws) do
			if table.concat({ raw:GetTreePath() }) == mixed then
				table.remove(raws, i)
			end
		end
	end
	return X.UI(raws)
end

-- filter elements from object
-- same as jQuery.filter()
function OO:Filter(mixed)
	self:_checksum()
	local raws = {}
	for i, raw in ipairs(self.raws) do
		table.insert(raws, raw)
	end
	if X.IsString(mixed) then
		-- delete raws those id/class not fits filter:mixed
		if string.sub(mixed, 1, 1) == '#' then
			mixed = string.sub(mixed, 2)
			if string.sub(mixed, 1, 1) == '^' then
				-- regexp
				for i, raw in X.ipairs_r(raws) do
					if not string.find(raw:GetName(), mixed) then
						table.remove(raws, i)
					end
				end
			else
				-- normal
				for i, raw in X.ipairs_r(raws) do
					if raw:GetName() ~= mixed then
						table.remove(raws, i)
					end
				end
			end
		elseif string.sub(mixed, 1, 1) == '.' then
			mixed = string.sub(mixed, 2)
			if string.sub(mixed, 1, 1) == '^' then
				-- regexp
				for i, raw in X.ipairs_r(raws) do
					if not string.find(GetComponentType(raw), mixed) then
						table.remove(raws, i)
					end
				end
			else
				-- normal
				for i, raw in X.ipairs_r(raws) do
					if GetComponentType(raw) ~= mixed then
						table.remove(raws, i)
					end
				end
			end
		end
	elseif X.IsElement(mixed) then
		-- delete raws those treepath is not the same as mixed
		mixed = table.concat({ mixed:GetTreePath() })
		for i, raw in X.ipairs_r(raws) do
			if table.concat({ raw:GetTreePath() }) ~= mixed then
				table.remove(raws, i)
			end
		end
	end
	return X.UI(raws)
end

-- get parent
-- same as jQuery.parent()
function OO:Parent()
	self:_checksum()
	local raws, hash, path, parent = {}, {}, nil, nil
	for _, raw in ipairs(self.raws) do
		parent = raw:GetParent()
		if parent then
			path = table.concat({ parent:GetTreePath() })
			if not hash[path] then
				table.insert(raws, parent)
				hash[path] = true
			end
		end
	end
	return X.UI(raws)
end

-- fetch children by name
function OO:Fetch(szName, szSubName)
	self:_checksum()
	local raws, parent, el = {}, nil, nil
	for _, raw in ipairs(self.raws) do
		parent = GetComponentElement(raw, 'MAIN_WINDOW')
		el = parent and parent:Lookup(szName)
		if szSubName then
			if el then
				parent = GetComponentElement(el, 'MAIN_HANDLE')
				el = parent and parent:Lookup(szSubName)
			end
		else
			if not el then
				parent = GetComponentElement(raw, 'MAIN_HANDLE')
				el = parent and parent:Lookup(szName)
			end
		end
		if el then
			table.insert(raws, el)
		end
	end
	return X.UI(raws)
end

-- get children
-- same as jQuery.children()
function OO:Children(filter)
	self:_checksum()
	if X.IsString(filter) and string.sub(filter, 1, 1) == '#' and string.sub(filter, 2, 2) ~= '^' then
		local raws, hash, name, child, path = {}, {}, string.sub(filter, 2)
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'MAIN_WINDOW') or raw
			child = raw:Lookup(name)
			if child then
				path = table.concat({ child:GetTreePath() })
				if not hash[path] then
					table.insert(raws, child)
					hash[path] = true
				end
			end
			if raw:GetBaseType() == 'Wnd' then
				child = GetComponentElement(raw, 'MAIN_HANDLE')
				child = child and child:Lookup(name)
				if child then
					path = table.concat({ child:GetTreePath() })
					if not hash[path] then
						table.insert(raws, child)
						hash[path] = true
					end
				end
			end
		end
		return X.UI(raws)
	else
		local raws, hash, child, path = {}, {}, nil, nil
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'MAIN_WINDOW') or raw
			if raw:GetBaseType() == 'Wnd' then
				child = raw:GetFirstChild()
				while child do
					path = table.concat({ child:GetTreePath() })
					if not hash[path] then
						table.insert(raws, child)
						hash[path] = true
					end
					child = child:GetNext()
				end
				local h = GetComponentElement(raw, 'MAIN_HANDLE') or raw:Lookup('', '')
				if h then
					for i = 0, h:GetItemCount() - 1 do
						child = h:Lookup(i)
						path = table.concat({ child:GetTreePath() })
						if not hash[path] then
							table.insert(raws, child)
							hash[path] = true
						end
					end
				end
			elseif raw:GetType() == 'Handle' then
				for i = 0, raw:GetItemCount() - 1 do
					child = raw:Lookup(i)
					path = table.concat({ child:GetTreePath() })
					if not hash[path] then
						table.insert(raws, child)
						hash[path] = true
					end
				end
			end
		end
		return X.UI(raws):Filter(filter)
	end
end

-- find element
-- same as jQuery.find()
function OO:Find(filter)
	self:_checksum()
	local top, raw, ruid, child
	local raws, hash, stack, children = {}, {}, {}, {}
	for _, root in ipairs(self.raws) do
		top = #raws
		table.insert(stack, root)
		while #stack > 0 do
			--### 弹出栈顶元素准备处理
			raw = table.remove(stack, #stack)
			ruid = tostring(raw)
			--### 判断不在结果集中则处理
			if not hash[ruid] then
				--## 将自身加入结果队列
				table.insert(raws, raw)
				hash[ruid] = true
				--## 计算所有子元素并将子元素压栈准备下次循环处理
				--## 注意要逆序压入栈中以保证最终结果是稳定排序的
				if raw:GetBaseType() == 'Wnd' then
					child = raw:Lookup('', '')
					if child then
						for i = 0, child:GetItemCount() - 1 do
							table.insert(children, child:Lookup(i))
						end
					end
					child = raw:GetFirstChild()
					while child do
						table.insert(children, child)
						child = child:GetNext()
					end
					repeat
						child = table.remove(children)
						table.insert(stack, child)
					until not child
				elseif raw:GetType() == 'Handle' then
					for i = 0, raw:GetItemCount() - 1 do
						table.insert(children, raw:Lookup(i))
					end
					repeat
						child = table.remove(children)
						table.insert(stack, child)
					until not child
				end
			end
		end
		-- 因为是求子元素 所以移除第一个压栈的元素（父元素）
		table.remove(raws, top + 1)
	end
	return X.UI(raws):Filter(filter)
end

function OO:Raw(nIndex)
	self:_checksum()
	return self.raws[nIndex or 1]
end

-- filter mouse in component
function OO:PtIn()
	self:_checksum()
	local raws = {}
	local cX, cY = Cursor.GetPos()
	for _, raw in pairs(self.raws) do
		if raw:GetBaseType() == 'Wnd' then
			if raw:PtInItem(cX, cY) then
				table.insert(raws, raw)
			end
		else
			if raw:PtInWindow(cX, cY) then
				table.insert(raws, raw)
			end
		end
	end
	return X.UI(raws)
end

-- each
-- same as jQuery.each(function(){})
-- :Each(UI each_self)  -- you can use 'this' to visit raw element likes jQuery
function OO:Each(fn)
	self:_checksum()
	for _, raw in pairs(self.raws) do
		X.ExecuteWithThis(raw, fn, X.UI(raw))
	end
	return self
end

-- slice -- index starts from 1
-- same as jQuery.slice(selector, pos)
function OO:Slice(startpos, endpos)
	self:_checksum()
	startpos = startpos or 1
	if startpos < 0 then
		startpos = #self.raws + startpos + 1
	end
	endpos = endpos or #self.raws
	if endpos < 0 then
		endpos = #self.raws + endpos + 1
	end
	local raws = {}
	for i = startpos, endpos, 1 do
		table.insert(raws, self.raws[i])
	end
	return X.UI(raws)
end

-- eq
-- same as jQuery.eq(pos)
function OO:Eq(pos)
	if pos then
		return self:Slice(pos, pos)
	end
	return self
end

-- first
-- same as jQuery.first()
function OO:First()
	return self:Slice(1, 1)
end

-- last
-- same as jQuery.last()
function OO:Last()
	return self:Slice(-1, -1)
end

-- get count
function OO:Count()
	self:_checksum()
	return #self.raws
end

-----------------------------------------------------------
-- my ui operation -- same as jQuery -- by tinymins --
-----------------------------------------------------------

-- remove
-- same as jQuery.remove()
-- (void) Instance:Remove()
-- (self) Instance:Remove(function onRemove)
function OO:Remove(onRemove)
	self:_checksum()
	if onRemove then
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'onRemove', onRemove)
		end
	else
		for _, raw in ipairs(self.raws) do
			local onRemove = GetComponentProp(raw, 'onRemove')
			if not onRemove or not onRemove(raw) then
				if raw:GetType() == 'WndFrame' then
					X.UI.CloseFrame(raw)
				elseif raw:GetBaseType() == 'Wnd' then
					raw:Destroy()
				else
					local h = raw:GetParent()
					if h and h:GetType() == 'Handle' then
						h:RemoveItem(raw)
						h:FormatAllItemPos()
					end
				end
			end
		end
		self:_checksum()
	end
	return self
end

local function OnCommonComponentMouseEnter()
	if not this:IsMouseIn() then
		return
	end
	local hText = GetComponentElement(this, 'TEXT')
	if not hText then
		return
	end

	local szText = hText:GetText()
	if X.IsEmpty(szText) then
		return
	end

	local nDisLen = hText:GetTextPosExtent()
	local nLen = X.StringLenW(hText:GetText())
	if nDisLen == nLen then
		return
	end

	local nW = hText:GetW()
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	OutputTip(GetFormatText(szText), 400, { x, y, w, h }, ALW.TOP_BOTTOM)
end
local function OnCommonComponentHover(bIn)
	if bIn then
		OnCommonComponentMouseEnter()
	else
		HideTip()
	end
end

-- xml string
local _tItemXML = {
	['Text'] = '<text>w=150 h=30 valign=1 font=162 autoetc=1 showall=0 </text>',
	['Image'] = '<image>w=100 h=100 </image>',
	['Box'] = '<box>w=48 h=48 eventid=525311 </box>',
	['Shadow'] = '<shadow>w=15 h=15 eventid=277 </shadow>',
	['Handle'] = '<handle>firstpostype=0 w=10 h=10 </handle>',
	['CheckBox'] = '<handle>name="CheckBox" firstpostype=0 w=100 h=28 <image>name="Image_Default" w=28 h=28 path="ui\\Image\\button\\CommonButton_1.UITex" frame=5 </image><text>name="Text_Default" font=162 valign=1 showall=0 x=29 w=71 h=28 </text></handle>',
	['ColorBox'] = '<handle>name="ColorBox" firstpostype=0 w=100 h=28 eventid=277 <shadow>name="Shadow_Default" w=28 h=28 </shadow><text>name="Text_Default" font=162 valign=1 showall=0 x=29 w=71 h=28 </text></handle>',
}
local _nTempWndCount = 0
-- append
-- similar as jQuery.append()
-- Instance:Append(szXml)
-- Instance:Append(szType[, tArg | szName])
function OO:Append(arg0, arg1)
	if not X.IsString(arg0) then
		assert(false, 'UI:Append() need a string as first argument')
	end
	if #arg0 == 0 then
		return
	end
	self:_checksum()

	local ui = X.UI()
	local szComponentName, szXML, tArg
	if arg0:find('%<') then
		szXML = arg0
	else
		szComponentName = arg0
		szXML = _tItemXML[szComponentName]
		if X.IsTable(arg1) then
			tArg = arg1
		elseif X.IsString(arg1) then
			tArg = { name = arg1 }
		end
	end
	if szXML then -- append from xml
		local startIndex, el
		for _, raw in ipairs(self.raws) do
			local h = GetComponentElement(raw, 'MAIN_HANDLE')
			if h then
				startIndex = h:GetItemCount()
				h:AppendItemFromString(szXML)
				h:FormatAllItemPos()
				for i = startIndex, h:GetItemCount() - 1 do
					el = h:Lookup(i)
					if szComponentName then
						el:SetName(szComponentName)
						InitComponent(el, szComponentName)
					end
					ui = ui:Add(el)
				end
			end
		end
	elseif szComponentName then -- append from ini file
		for _, raw in ipairs(self.raws) do
			local parentWnd = GetComponentElement(raw, 'MAIN_WINDOW')
			local parentHandle = GetComponentElement(raw, 'MAIN_HANDLE')
			local szFile = X.PACKET_INFO.UI_COMPONENT_ROOT .. szComponentName .. '.ini'
			local frame = X.UI.OpenFrame(szFile, X.NSFormatString('{$NS}_TempWnd#') .. _nTempWndCount)
			if not frame then
				return X.OutputDebugMessage(X.NSFormatString('{$NS}#UI#Append'), _L('Unable to open ini file [%s]', szFile), X.DEBUG_LEVEL.ERROR)
			end
			_nTempWndCount = _nTempWndCount + 1
			-- start ui append
			raw = nil
			if szComponentName:sub(1, 3) == 'Wnd' then
				if parentWnd then -- KWndWindow
					raw = frame:Lookup(szComponentName)
					if raw then
						InitComponent(raw, szComponentName)
						raw:ChangeRelation(parentWnd, true, true)
						if parentWnd:GetType() == 'WndContainer' then
							parentWnd:FormatAllContentPos()
						end
					end
				end
			else
				if parentHandle then
					raw = parentHandle:AppendItemFromIni(szFile, szComponentName)
					if raw then -- KItemNull
						InitComponent(raw, szComponentName)
						parentHandle:FormatAllItemPos()
					end
				end
			end
			if raw then
				ui = ui:Add(raw)
				X.UI(raw):Hover(OnCommonComponentHover):Change(OnCommonComponentMouseEnter)
			else
				X.OutputDebugMessage(X.NSFormatString('{$NS}#UI#Append'), _L('Can not find wnd or item component [%s:%s]', szFile, szComponentName), X.DEBUG_LEVEL.ERROR)
			end
			X.UI.CloseFrame(frame)
		end
	end
	local tArg = X.Clone(tArg)
	if tArg then
		if not tArg.w then
			tArg.w = 'auto'
		end
		if not tArg.h then
			tArg.h = 'auto'
		end
	end
	if szComponentName == 'WndButton' or szComponentName == 'WndButtonBox' then
		if not tArg.buttonStyle then
			tArg.buttonStyle = 'DEFAULT'
		end
	end
	return ApplyUIArguments(ui, tArg)
end

-- append from ini
-- Instance:AppendFromIni(szIni, szName, bOnlyChild)
function OO:AppendFromIni(szIni, szName, bOnlyChild, tArg)
	if X.IsTable(bOnlyChild) then
		bOnlyChild, tArg = nil, bOnlyChild
	end
	self:_checksum()
	local ui = X.UI()
	for _, raw in ipairs(self.raws) do
		for _, v in ipairs(X.UI.AppendFromIni(raw, szIni, szName, bOnlyChild) or X.CONSTANT.EMPTY_TABLE) do
			ui = ui:Add(v)
		end
	end
	return ApplyUIArguments(ui, tArg)
end

-- clear
-- clear handle
-- (self) Instance:Clear()
function OO:Clear()
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		local h = GetComponentElement(raw, 'MAIN_HANDLE')
		if h then
			h:Clear()
			h:FormatAllItemPos()
		end
		local h = GetComponentElement(raw, 'MAIN_CONTAINER')
		if h then
			h:Clear()
		end
	end
	return self
end

-- remove child item until new line
-- (self) Instance:RemoveItemUntilNewLine()
function OO:RemoveItemUntilNewLine()
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		if raw.Clear then
			raw:Clear()
		end
		raw = GetComponentElement(raw, 'MAIN_HANDLE')
		if raw then
			raw:RemoveItemUntilNewLine()
			raw:FormatAllItemPos()
		end
	end
	return self
end

-----------------------------------------------------------
-- my ui property visitors
-----------------------------------------------------------

-- data set/get
do local l_data = setmetatable({}, { __mode = 'k' })
function OO:Data(key, value)
	self:_checksum()
	if key and value then -- set
		for _, raw in ipairs(self.raws) do
			if not l_data[raw] then
				l_data[raw] = {}
			end
			l_data[raw][key] = value
		end
		return self
	elseif key then -- get
		local raw = self.raws[1]
		if raw then
			return l_data[raw] and l_data[raw][key]
		end
	end
end
end

-- show
function OO:Show()
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		raw:Show()
	end
	return self
end

-- hide
function OO:Hide()
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		raw:Hide()
	end
	return self
end

-- visible
function OO:Visible(bVisible)
	self:_checksum()
	if X.IsBoolean(bVisible) then
		return self:Toggle(bVisible)
	elseif X.IsFunction(bVisible) then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'CHECKBOX') or GetComponentElement(raw, 'MAIN_WINDOW') or raw
			X.BreatheCall(X.NSFormatString('{$NS}_UI_VISIBLE_CHECK#') .. tostring(raw), function()
				if X.IsElement(raw) then
					raw:SetVisible(bVisible())
				else
					return 0
				end
			end)
			raw:SetVisible(bVisible())
		end
	else
		local raw = self.raws[1]
		if raw and raw.IsVisible then
			return raw:IsVisible()
		end
	end
end

-- enable or disable elements
do
local function SetComponentEnable(raw, bEnable)
	-- check if set value equals with current status
	local bEnable = bEnable and true or false
	local bEnabled = GetComponentProp(raw, 'bEnable')
	if bEnabled == nil then
		if raw.IsEnabled then
			bEnabled = raw:IsEnabled()
		else
			bEnabled = true
		end
	end
	if bEnabled == bEnable then
		return
	end
	-- WndTable: set gray filter on header and content
	if GetComponentType(raw) == 'WndTable' then
		local hTotal = raw:Lookup('', '')
		if hTotal then
			hTotal:SetAlpha(bEnable and 255 or 128)
		end
		local scrollX = raw:Lookup('Scroll_X')
		if scrollX then
			scrollX:Enable(bEnable)
		end
		local scrollY = raw:Lookup('Scroll_Y')
		if scrollY then
			scrollY:Enable(bEnable)
		end
	else
		-- make gray
		local txt = GetComponentElement(raw, 'TEXT')
		if txt then
			local r, g, b = txt:GetFontColor()
			local ratio = bEnable and 2.2 or (1 / 2.2)
			if math.max(r, g, b) * ratio > 255 then
				ratio = 255 / math.max(r, g, b)
			end
			txt:SetFontColor(math.ceil(r * ratio), math.ceil(g * ratio), math.ceil(b * ratio))
		end
		-- make gray
		local sha = GetComponentElement(raw, 'SHADOW')
		if sha then
			local r, g, b = sha:GetColorRGB()
			local ratio = bEnable and 2.2 or (1 / 2.2)
			if math.max(r, g, b) * ratio > 255 then
				ratio = 255 / math.max(r, g, b)
			end
			sha:SetColorRGB(math.ceil(r * ratio), math.ceil(g * ratio), math.ceil(b * ratio))
		end
		-- set sub elements enable
		local combo = GetComponentElement(raw, 'COMBO_BOX')
		if combo then
			combo:Enable(bEnable)
		end
		local slider = GetComponentElement(raw, 'SLIDER')
		if slider then
			slider:Enable(bEnable)
		end
		local edit = GetComponentElement(raw, 'EDIT')
		if edit then
			edit:Enable(bEnable)
		end
		-- set enable
		if raw.Enable then
			raw:Enable(bEnable)
		end
	end
	SetComponentProp(raw, 'bEnable', bEnable)
end

function OO:Enable(...)
	self:_checksum()
	local argc = select('#', ...)
	if argc == 1 then
		local bEnable = select(1, ...)
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'CHECKBOX') or GetComponentElement(raw, 'MAIN_WINDOW') or raw
			if X.IsFunction(bEnable) then
				X.BreatheCall(X.NSFormatString('{$NS}_UI_ENABLE_CHECK#') .. tostring(raw), function()
					if X.IsElement(raw) then
						SetComponentEnable(raw, bEnable())
					else
						return 0
					end
				end)
				SetComponentEnable(raw, bEnable())
			else
				SetComponentEnable(raw, bEnable)
			end
		end
		return self
	else
		local raw = self.raws[1]
		local bEnable = GetComponentProp(raw, 'bEnable')
		if bEnable ~= nil then
			return bEnable
		end
		if raw and raw.IsEnabled then
			return raw:IsEnabled()
		end
	end
end
end

-- show/hide raws
function OO:Toggle(bShow)
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		if bShow == false or (bShow == nil and raw:IsVisible()) then
			raw:Hide()
		else
			raw:Show()
		end
	end
	return self
end

-- drag area
-- (self) drag(boolean bEnableDrag) -- enable/disable drag
-- (self) drag(number nX, number y, number w, number h) -- set drag position and area
-- (self) drag(function fnOnDrag, function fnOnDragEnd)-- bind frame/item frag event handle
function OO:Drag(...)
	self:_checksum()
	local argc = select('#', ...)
	local arg0, arg1, arg2, arg3 = ...
	if argc == 0 then
		local raw = self.raws[1]
		if raw and raw:GetType() == 'WndFrame' then
			return raw:IsDragable()
		end
		return
	end
	if argc == 1 then
		if X.IsBoolean(arg0) then
			local bDrag = arg0
			for _, raw in ipairs(self.raws) do
				if raw.EnableDrag then
					raw:EnableDrag(bDrag)
				end
			end
			return self
		end
		if X.IsFunction(arg0) then
			local fnAction = arg0
			for _, raw in ipairs(self.raws) do
				if raw:GetBaseType() == 'Item' then
					raw.OnItemLButtonDrag = function()
						local szDragGroupID = GetComponentProp(raw, 'DragDropGroup')
						local data, capture = fnAction()
						X.UI.OpenDragDrop(this, capture, szDragGroupID, data)
					end
					raw.OnItemLButtonDragEnd = function()
						if not X.UI.IsDragDropOpened() then
							return
						end
						local dropEl, szDragGroupID, xData = X.UI.CloseDragDrop()
						local szDropGroupID = GetComponentProp(dropEl, 'DragDropGroup')
						if szDragGroupID ~= szDropGroupID then
							return
						end
						X.SafeCall(GetComponentProp(dropEl, 'OnDrop'), szDragGroupID, xData)
					end
					raw.OnItemLButtonUp = function()
						-- DragEnd bug fix
						X.DelayCall(50, function()
							if not X.UI.IsDragDropOpened() then
								return
							end
							X.UI.CloseDragDrop()
						end)
					end
					raw:RegisterEvent(X.UI.ITEM_EVENT.L_BUTTON_UP)
					raw:RegisterEvent(X.UI.ITEM_EVENT.L_BUTTON_DRAG)
					raw:RegisterEvent(X.UI.ITEM_EVENT.MOUSE_ENTER_LEAVE)
				end
			end
			return self
		end
	end
	if argc == 2 then
		if X.IsFunction(arg0) or X.IsFunction(arg1) then
			for _, raw in ipairs(self.raws) do
				if raw:GetType() == 'WndFrame' then
					if arg0 then
						X.UI(raw):UIEvent('OnFrameDragSetPosEnd', arg0)
					end
					if arg1 then
						X.UI(raw):UIEvent('OnFrameDragEnd', arg1)
					end
				elseif raw:GetBaseType() == 'Item' then
					if arg0 then
						X.UI(raw):UIEvent('OnItemLButtonDrag', arg0)
					end
					if arg1 then
						X.UI(raw):UIEvent('OnItemLButtonDragEnd', arg1)
					end
				end
			end
			return self
		end
	end
	if argc == 4 then
		if X.IsNumber(arg0) or X.IsNumber(arg1) or X.IsNumber(arg2) or X.IsNumber(arg3) then
			local nX, nY, nW, nH = arg0 or 0, arg1 or 0, arg2, arg3
			for _, raw in ipairs(self.raws) do
				if raw:GetType() == 'WndFrame' then
					raw:SetDragArea(nX, nY, nW or raw:GetW(), nH or raw:GetH())
				end
			end
			return self
		end
	end
end

function OO:DragHover(fnAction)
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		if raw:GetBaseType() == 'Item' then
			SetComponentProp(raw, 'DragHover', fnAction)
			X.UI(raw):UIEvent('OnItemMouseHover', function()
				if not X.UI.IsDragDropOpened() then
					return
				end
				local szDragGroupID = X.UI.GetDragDropData()
				if szDragGroupID == GetComponentProp(raw, 'DragDropGroup') then
					local rect, bAcceptable, eCursor = fnAction()
					X.UI.SetDragDropHoverEl(raw, rect, bAcceptable, eCursor)
				end
			end)
			raw:RegisterEvent(X.UI.ITEM_EVENT.MOUSE_HOVER)
		end
	end
	return self
end

function OO:Drop(fnAction)
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		if raw:GetBaseType() == 'Item' then
			X.UI(raw):UIEvent('OnItemMouseEnter', function()
				if not X.UI.IsDragDropOpened() then
					return
				end
				local szDragGroupID = X.UI.GetDragDropData()
				if szDragGroupID == GetComponentProp(raw, 'DragDropGroup') then
					local rect, bAcceptable, eCursor
					local fnDragHover = GetComponentProp(raw, 'DragHover')
					if fnDragHover then
						rect, bAcceptable, eCursor = fnDragHover()
					end
					X.UI.SetDragDropHoverEl(raw, rect, bAcceptable, eCursor)
				end
			end)
			X.UI(raw):UIEvent('OnItemMouseLeave', function()
				if not X.UI.IsDragDropOpened() then
					return
				end
				local szDragGroupID = X.UI.GetDragDropData()
				if szDragGroupID == GetComponentProp(raw, 'DragDropGroup') then
					X.UI.SetDragDropHoverEl(nil)
				end
			end)
			SetComponentProp(raw, 'OnDrop', function(szDragGroupID, xData)
				X.ExecuteWithThis(raw, fnAction, szDragGroupID, xData)
			end)
			raw:RegisterEvent(X.UI.ITEM_EVENT.MOUSE_HOVER)
			raw:RegisterEvent(X.UI.ITEM_EVENT.MOUSE_ENTER_LEAVE)
		end
	end
end

function OO:DragDropGroup(...)
	self:_checksum()
	if select('#', ...) == 0 then
		for _, raw in ipairs(self.raws) do
			if raw:GetBaseType() == 'Item' then
				return GetComponentProp(raw, 'DragDropGroup')
			end
		end
		return
	else
		local szDragGroupID = ...
		for _, raw in ipairs(self.raws) do
			if raw:GetBaseType() == 'Item' then
				SetComponentProp(raw, 'DragDropGroup', szDragGroupID)
			end
		end
	end
	return self
end

-- get/set ui object text
function OO:Text(arg0, arg1)
	self:_checksum()
	if not X.IsNil(arg0) and not X.IsBoolean(arg0) then
		local componentType, element
		for _, raw in ipairs(self.raws) do
			componentType = GetComponentType(raw)
			if X.IsFunction(arg0) then
				if componentType == 'WndSlider' then
					SetComponentProp(raw, 'FormatText', arg0)
					GetComponentProp(raw, 'ResponseUpdateScroll')(true)
				end
			elseif X.IsTable(arg0) then
				if componentType == 'WndEditBox' or componentType == 'WndAutocomplete' then
					element = GetComponentElement(raw, 'EDIT')
					SetComponentProp(element, 'WNDEVENT_FIRETYPE', arg1)
					for k, v in ipairs(arg0) do
						if v.type == 'text' then
							element:InsertText(v.text)
						else
							element:InsertObj(v.text, v)
						end
					end
				end
			else
				if not X.IsString(arg0) then
					arg0 = tostring(arg0)
				end
				if componentType == 'WndScrollHandleBox' then
					element = GetComponentElement(raw, 'MAIN_HANDLE')
					element:Clear()
					element:AppendItemFromString(GetFormatText(arg0))
					element:FormatAllItemPos()
				elseif componentType == 'Text' then
					raw:SetText(arg0)
					if GetComponentProp(raw, 'bAutoSize') then
						raw:AutoSize()
						raw:GetParent():FormatAllItemPos()
					end
				else
					element = GetComponentElement(raw, 'TEXT')
					if element then
						element:SetText(arg0)
					end
					element = GetComponentElement(raw, 'EDIT')
					if element then
						SetComponentProp(element, 'WNDEVENT_FIRETYPE', arg1)
						element:SetText(arg0)
					end
				end
			end
		end
		return self
	else -- arg0: bStruct
		local raw = self.raws[1]
		if raw then
			raw = GetComponentElement(raw, 'TEXT') or GetComponentElement(raw, 'EDIT') or raw
			if raw then
				if arg0 then
					if raw.GetTextStruct then
						return raw:GetTextStruct()
					elseif raw.GetText then
						return { type = 'text', text = raw:GetText() }
					end
				elseif raw.GetText then
					return raw:GetText()
				end
			end
		end
	end
end

-- get/set ui object text
function OO:Placeholder(szText)
	self:_checksum()
	if szText then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'EDIT')
			if raw then
				raw:SetPlaceholderText(szText)
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			raw = GetComponentElement(raw, 'EDIT')
			if raw then
				return raw:GetPlaceholderText()
			end
		end
	end
end

-- ui autocomplete interface
function OO:Autocomplete(method, arg1, arg2)
	self:_checksum()
	if method == 'option' and (X.IsNil(arg1) or (X.IsString(arg1) and X.IsNil(arg2))) then -- get
		-- try to get its option
		local raw = self.raws[1]
		if raw then
			return X.Clone(GetComponentProp(raw, 'autocompleteOptions'))
		end
	else -- set
		if method == 'option' then
			if X.IsString(arg1) then
				arg1 = {
					[arg1] = arg2
				}
			end
			if X.IsTable(arg1) then
				for _, raw in ipairs(self.raws) do
					if GetComponentType(raw) == 'WndAutocomplete' then
						for k, v in pairs(arg1) do
							SetComponentProp(raw, 'autocompleteOptions', k, v)
						end
					end
				end
			end
		elseif method == 'close' then
			X.UI.ClosePopupMenu()
		elseif method == 'destroy' then
			for _, raw in ipairs(self.raws) do
				raw:Lookup('WndEdit_Default').OnSetFocus = nil
				raw:Lookup('WndEdit_Default').OnKillFocus = nil
			end
		elseif method == 'disable' then
			self:Autocomplete('option', 'disable', true)
		elseif method == 'enable' then
			self:Autocomplete('option', 'disable', false)
		elseif method == 'search' then
			for _, raw in ipairs(self.raws) do
				local opt = GetComponentProp(raw, 'autocompleteOptions')
				if opt then
					local text = arg1 or raw:Lookup('WndEdit_Default'):GetText()
					if X.IsFunction(opt.beforeSearch) then
						X.ExecuteWithThis(raw, opt.beforeSearch, text)
					end
					local needle = opt.ignoreCase and StringLowerW(text) or text
					local aSrc = {}
					-- get matched list
					for _, src in ipairs(opt.source) do
						local haystack = type(src) == 'table' and (src.keyword or tostring(src.text)) or tostring(src)
						if opt.ignoreCase then
							haystack = StringLowerW(haystack)
						end
						local pos = needle == '' and 1 or X.StringFindW(haystack, needle)
						if pos and pos > 0 and not opt.anyMatch then
							pos = nil
						end
						if not pos then
							local aPinyin, aPinyinConsonant = X.Han2Pinyin(haystack)
							if not pos then
								for _, s in ipairs(aPinyin) do
									pos = needle == '' and 1 or X.StringFindW(s, needle)
									if pos and pos > 0 and not opt.anyMatch then
										pos = nil
									end
									if pos then
										break
									end
								end
							end
							if not pos then
								for _, s in ipairs(aPinyinConsonant) do
									pos = needle == '' and 1 or X.StringFindW(s, needle)
									if pos and pos > 0 and not opt.anyMatch then
										pos = nil
									end
									if pos then
										break
									end
								end
							end
						end
						if pos then
							table.insert(aSrc, src)
						end
					end

					-- create menu
					local menu = {}
					for _, src in ipairs(aSrc) do
						local szText, szDisplay, szOption, bDivide, bRichText
						if type(src) == 'table' then
							szText = src.text
							szDisplay = src.display or szText
							bDivide = src.divide or false
							bRichText = src.richtext or false
						else
							szText = tostring(src)
							szDisplay = szText
							bDivide = false
							bRichText = false
						end
						-- max opt limit
						if opt.maxOption > 0 and #menu >= opt.maxOption then
							break
						end
						-- create new opt
						local t
						if bDivide then
							if #menu == 0 or not menu[#menu].bDevide then
								t = X.CONSTANT.MENU_DIVIDER
							end
						else
							t = {
								szOption = szDisplay,
								bRichText = bRichText,
								fnAction = function()
									opt.disabledTmp = true
									raw:Lookup('WndEdit_Default'):SetText(szText)
									if X.IsFunction(opt.afterComplete) then
										opt.afterComplete(raw, opt, text, src)
									end
									X.UI.ClosePopupMenu()
									opt.disabledTmp = nil
								end,
							}
							if opt.beforeDelete or opt.afterDelete then
								t.szIcon = 'ui/Image/UICommon/CommonPanel2.UITex'
								t.nFrame = 49
								t.nMouseOverFrame = 51
								t.nIconWidth = 17
								t.nIconHeight = 17
								t.szLayer = 'ICON_RIGHTMOST'
								t.fnClickIcon = function()
									local bSure = true
									local fnDoDelete = function()
										for i = #opt.source, 1, -1 do
											if opt.source[i] == src then
												table.remove(opt.source, i)
											end
										end
										X.UI(raw):Autocomplete('search')
									end
									if opt.beforeDelete then
										local bSuccess
										bSuccess, bSure = X.ExecuteWithThis(raw, opt.beforeDelete, src)
										if not bSuccess then
											bSure = false
										end
									end
									if bSure ~= false then
										fnDoDelete()
									end
									if opt.afterDelete then
										X.ExecuteWithThis(raw, opt.afterDelete, src)
									end
								end
							end
						end
						if t then
							table.insert(menu, t)
						end
					end
					local nX, nY = raw:GetAbsPos()
					local nW, nH = raw:GetSize()
					menu.szLayer = 'Topmost2'
					menu.nMiniWidth = nW
					menu.nWidth = nW
					menu.x, menu.y = nX, nY + nH
					menu.bDisableSound = true
					menu.bShowKillFocus = true
					menu.nMaxHeight = math.min(select(2, Station.GetClientSize()) - raw:GetAbsY() - raw:GetH(), 600)

					if X.IsFunction(opt.beforePopup) then
						X.ExecuteWithThis(raw, opt.beforePopup, menu)
					end
					-- popup menu
					if #menu > 0 then
						opt.disabledTmp = true
						X.UI.PopupMenu(menu)
						Station.SetFocusWindow(raw:Lookup('WndEdit_Default'))
						opt.disabledTmp = nil
					else
						X.UI.ClosePopupMenu()
					end
				end
			end
		elseif method == 'insert' then
			if X.IsString(arg1) then
				arg1 = { arg1 }
			end
			if X.IsTable(arg1) then
				for _, src in ipairs(arg1) do
					if X.IsString(src) then
						for _, raw in ipairs(self.raws) do
							local opt = GetComponentProp(raw, 'autocompleteOptions')
							for i = #opt.source, 1, -1 do
								if opt.source[i] == src then
									table.remove(opt.source, i)
								end
							end
							table.insert(opt.source, src)
						end
					end
				end
			end
		elseif method == 'delete' then
			if X.IsString(arg1) then
				arg1 = { arg1 }
			end
			if X.IsTable(arg1) then
				for _, src in ipairs(arg1) do
					if X.IsString(src) then
						for _, raw in ipairs(self.raws) do
							local opt = GetComponentProp(raw, 'autocompleteOptions')
							for i=#opt.source, 1, -1 do
								if opt.source[i] == arg1 then
									table.remove(opt.source, i)
								end
							end
						end
					end
				end
			end
		end
		return self
	end
end

-- ui list box interface
-- (get) list:ListBox('option')
-- (set) list:ListBox('option', k, v)
-- (set) list:ListBox('option', {k1=v1, k2=v2})
-- (set) list:ListBox('select', 'all'|'unselected'|'selected')
-- (set) list:ListBox('insert', { id=id, text=text, data=data, index=index, r=r, g=g, b=b })
-- (set) list:ListBox('exchange', 'id'|'index', k1, k2)
-- (set) list:ListBox('update', 'id'|'text', k, { text=szText, data=oData })
-- (set) list:ListBox('update', 'id'|'text', k, {'text', 'data'}, {szText, oData})
-- (set) list:ListBox('delete', 'id'|'text', k)
-- (set) list:ListBox('clear')
-- (set) list:ListBox('onmenu', function(id, text, data, selected) end)
-- (set) list:ListBox('onlclick', function(id, text, data, selected) end)
-- (set) list:ListBox('onrclick', function(id, text, data, selected) end)
-- (set) list:ListBox('onhover', function(id, text, data, selected) end, function(id, text, data, selected) end)
function OO:ListBox(method, arg1, arg2, arg3, arg4)
	self:_checksum()
	if method == 'option' and (X.IsNil(arg1) or (X.IsString(arg1) and X.IsNil(arg2))) then -- get
		-- try to get its option
		local raw = self.raws[1]
		if raw then
			return X.Clone(GetComponentProp(raw, 'listboxOptions'))
		end
	else -- set
		if method == 'option' then
			if X.IsString(arg1) then
				arg1 = {
					[arg1] = arg2
				}
			end
			if X.IsTable(arg1) then
				for _, raw in ipairs(self.raws) do
					for k, v in pairs(arg1) do
						SetComponentProp(raw, 'listboxOptions', k, v)
					end
				end
			end
		elseif method == 'select' then
			local tData = {}
			for _, raw in ipairs(self.raws) do
				if GetComponentType(raw) == 'WndListBox' then
					local hList = raw:Lookup('', 'Handle_Scroll')
					for i = 0, hList:GetItemCount() - 1, 1 do
						local data = GetComponentProp(hList:Lookup(i), 'listboxItemData')
						if arg1 == 'all'
						or (arg1 == 'unselected' and not data.selected)
						or (arg1 == 'selected' and data.selected) then
							table.insert(tData, data)
						end
					end
				end
			end
			return tData
		elseif method == 'insert' then
			local id, text, data, pos, r, g, b, selected = arg1.id, arg1.text, arg1.data, arg1.index, arg1.r, arg1.g, arg1.b, arg1.selected or false
			for _, raw in ipairs(self.raws) do
				if GetComponentType(raw) == 'WndListBox' then
					local hList = raw:Lookup('', 'Handle_Scroll')
					local bExist
					if id then
						for i = hList:GetItemCount() - 1, 0, -1 do
							if hList:Lookup(i).id == id then
								bExist = true
							end
						end
					end
					if not bExist then
						local w, h = hList:GetSize()
						local xml = '<handle>eventid=371 pixelscroll=1 <image>w='..w..' h=25 path="UI/Image/Common/TextShadow.UITex" frame=5 alpha=0 name="Image_Bg" </image><image>w='..w..' h=25 path="UI/Image/Common/TextShadow.UITex" lockshowhide=1 frame=2 name="Image_Sel" </image><text>w='..w..' h=25 valign=1 name="Text_Default" </text></handle>'
						local hItem
						if pos then
							pos = pos - 1 -- C++ count from zero but lua count from one.
							hList:InsertItemFromString(pos, false, xml)
							hItem = hList:Lookup(pos)
						else
							hList:AppendItemFromString(xml)
							hItem = hList:Lookup(hList:GetItemCount() - 1)
						end
						SetComponentProp(hItem, 'listboxItemData', {
							id = id,
							text = text,
							data = data,
							selected = selected,
						})
						hItem:Lookup('Text_Default'):SetText(text)
						if r and g and b then
							hItem:Lookup('Text_Default'):SetFontColor(r, g, b)
						end
						hItem:Lookup('Image_Sel'):SetVisible(selected)
						hItem.OnItemMouseEnter = GetComponentProp(raw, 'OnListItemHandleMouseEnter')
						hItem.OnItemMouseLeave = GetComponentProp(raw, 'OnListItemHandleMouseLeave')
						hItem.OnItemLButtonClick = GetComponentProp(raw, 'OnListItemHandleLButtonClick')
						hItem.OnItemRButtonClick = GetComponentProp(raw, 'OnListItemHandleRButtonClick')
						hList:FormatAllItemPos()
					end
				end
			end
		elseif method == 'exchange' then
			local mode, key1, key2 = arg1, arg2, arg3
			for _, raw in ipairs(self.raws) do
				if GetComponentType(raw) == 'WndListBox' then
					local hList = raw:Lookup('', 'Handle_Scroll')
					local index1, index2
					if mode == 'id' then
						for i = hList:GetItemCount() - 1, 0, -1 do
							if hList:Lookup(i).id == key1 then
								index1 = i
							elseif hList:Lookup(i).id == key2 then
								index2 = i
							end
						end
					elseif mode == 'index' then
						if key1 > 0 and key1 < hList:GetItemCount() + 1 then
							index1 = key1 - 1 -- C++ count from zero but lua count from one.
						end
						if key2 >= 0 and key2 < hList:GetItemCount() + 1 then
							index2 = key2 - 1 -- C++ count from zero but lua count from one.
						end
					end
					if index1 and index2 then
						hList:ExchangeItemIndex(index1, index2)
						hList:FormatAllItemPos()
					end
				end
			end
		elseif method == 'update' then
			local mode, search, argk, argv = arg1, arg2, arg3, arg4
			for _, raw in ipairs(self.raws) do
				if GetComponentType(raw) == 'WndListBox' then
					local hList = raw:Lookup('', 'Handle_Scroll')
					for i = hList:GetItemCount() - 1, 0, -1 do
						local hItem = hList:Lookup(i)
						local data = GetComponentProp(hItem, 'listboxItemData')
						if (mode == 'id' and data.id == search)
						or (mode == 'text' and data.text == search) then
							if argv then
								for i, k in ipairs(argk) do
									if k == 'text' then
										hItem:Lookup('Text_Default'):SetText(argv[i])
									end
									data[k] = argv[i]
								end
							else
								for k, v in ipairs(argk) do
									if k == 'text' then
										hItem:Lookup('Text_Default'):SetText(v)
									end
									data[k] = v
								end
							end
						end
					end
				end
			end
		elseif method == 'delete' then
			local mode, search = arg1, arg2
			for _, raw in ipairs(self.raws) do
				if GetComponentType(raw) == 'WndListBox' then
					local hList = raw:Lookup('', 'Handle_Scroll')
					for i = hList:GetItemCount() - 1, 0, -1 do
						local data = GetComponentProp(hList:Lookup(i), 'listboxItemData')
						if (mode == 'id' and data.id == search)
						or (mode == 'text' and data.text == search) then
							hList:RemoveItem(i)
						end
					end
					hList:FormatAllItemPos()
				end
			end
		elseif method == 'clear' then
			for _, raw in ipairs(self.raws) do
				if GetComponentType(raw) == 'WndListBox' then
					raw:Lookup('', 'Handle_Scroll'):Clear()
				end
			end
		elseif method == 'onmenu' then
			if X.IsFunction(arg1) then
				for _, raw in ipairs(self.raws) do
					if GetComponentType(raw) == 'WndListBox' then
						SetComponentProp(raw, 'GetListItemHandleMenu', arg1)
					end
				end
			end
		elseif method == 'onlclick' then
			if X.IsFunction(arg1) then
				for _, raw in ipairs(self.raws) do
					if GetComponentType(raw) == 'WndListBox' then
						SetComponentProp(raw, 'OnListItemHandleCustomLButtonClick', arg1)
					end
				end
			end
		elseif method == 'onrclick' then
			if X.IsFunction(arg1) then
				for _, raw in ipairs(self.raws) do
					if GetComponentType(raw) == 'WndListBox' then
						SetComponentProp(raw, 'OnListItemHandleCustomRButtonClick', arg1)
					end
				end
			end
		elseif method == 'onhover' then
			if X.IsFunction(arg1) then
				for _, raw in ipairs(self.raws) do
					if GetComponentType(raw) == 'WndListBox' then
						SetComponentProp(raw, 'OnListItemHandleCustomHoverIn', arg1)
					end
				end
			end
			if X.IsFunction(arg2) then
				for _, raw in ipairs(self.raws) do
					if GetComponentType(raw) == 'WndListBox' then
						SetComponentProp(raw, 'OnListItemHandleCustomHoverOut', arg2)
					end
				end
			end
		end
		return self
	end
end

-- get/set table columns
function OO:Columns(aColumns)
	self:_checksum()
	if aColumns then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				if X.IsFunction(aColumns) then
					SetComponentProp(raw, 'OnColumnsChange', function()
						X.ExecuteWithThis(raw, aColumns, GetComponentProp(raw, 'aColumns'))
					end)
				else
					local nFixedLIndex, nFixedRIndex = -1, math.huge
					local aFixedLColumns, aFixedRColumns, aScrollableColumns = {}, {}, {}
					local nFixedLColumnsWidth, nFixedRColumnsWidth = 0, 0
					for nIndex, col in ipairs(aColumns) do
						if col.fixed == true or col.fixed == 'left' then
							if not X.IsNumber(col.width) then
								assert(false, 'fixed column width is required')
							end
							nFixedLColumnsWidth = nFixedLColumnsWidth + col.width
							nFixedLIndex = nIndex
						else
							break
						end
					end
					for nIndex, col in X.ipairs_r(aColumns) do
						if col.fixed == 'right' then
							if not X.IsNumber(col.width) then
								assert(false, 'fixed column width is required')
							end
							nFixedRColumnsWidth = nFixedRColumnsWidth + col.width
							nFixedRIndex = nIndex
						else
							break
						end
					end
					for i = 1, #aColumns do
						if i <= nFixedLIndex then
							table.insert(aFixedLColumns, aColumns[i])
						elseif i >= nFixedRIndex then
							table.insert(aFixedRColumns, aColumns[i])
						else
							table.insert(aScrollableColumns, aColumns[i])
						end
					end
					SetComponentProp(raw, 'aColumns', aColumns)
					SetComponentProp(raw, 'aFixedLColumns', aFixedLColumns)
					SetComponentProp(raw, 'aFixedRColumns', aFixedRColumns)
					SetComponentProp(raw, 'aScrollableColumns', aScrollableColumns)
					SetComponentProp(raw, 'nFixedLColumnsWidth', nFixedLColumnsWidth)
					SetComponentProp(raw, 'nFixedRColumnsWidth', nFixedRColumnsWidth)
					GetComponentProp(raw, 'DrawColumnsTitle')()
					GetComponentProp(raw, 'DrawTableContent')()
					GetComponentProp(raw, 'DrawTableSummary')()
				end
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			if GetComponentType(raw) == 'WndTable' then
				return GetComponentProp(raw, 'aColumns')
			end
		end
	end
end

-- get/set table data source
function OO:DataSource(aDataSource)
	self:_checksum()
	if aDataSource then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				SetComponentProp(raw, 'DataSource', aDataSource)
				GetComponentProp(raw, 'DrawTableContent')()
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			if GetComponentType(raw) == 'WndTable' then
				return GetComponentProp(raw, 'DataSource')
			end
		end
	end
end

-- get/set table summary
function OO:Summary(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local summary = ...
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				SetComponentProp(raw, 'Summary', summary)
				GetComponentProp(raw, 'DrawTableSummary')()
				GetComponentProp(raw, 'UpdateSummaryVisible')()
				GetComponentProp(raw, 'UpdateSummaryColumnsWidth')()
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			if GetComponentType(raw) == 'WndTable' then
				return GetComponentProp(raw, 'Summary')
			end
		end
	end
end

-- get/set table sort
function OO:Sort(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local szSortKey, szSortOrder = ...
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				if X.IsFunction(szSortKey) then
					SetComponentProp(raw, 'OnSortChange', function()
						X.ExecuteWithThis(raw, szSortKey, GetComponentProp(raw, 'SortKey'), GetComponentProp(raw, 'SortOrder'))
					end)
				elseif szSortKey ~= GetComponentProp(raw, 'SortKey') or szSortOrder ~= GetComponentProp(raw, 'SortOrder') then
					SetComponentProp(raw, 'SortKey', szSortKey)
					SetComponentProp(raw, 'SortOrder', szSortOrder)
					GetComponentProp(raw, 'UpdateSorterStatus')()
					GetComponentProp(raw, 'DrawTableContent')()
					X.SafeCall(GetComponentProp(raw, 'OnSortChange'))
				end
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			if GetComponentType(raw) == 'WndTable' then
				return GetComponentProp(raw, 'SortKey'), GetComponentProp(raw, 'SortOrder')
			end
		end
	end
end

-- get/set ui object name
function OO:Name(szText)
	self:_checksum()
	if szText then -- set name
		for _, raw in ipairs(self.raws) do
			raw:SetName(szText)
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw and raw.GetName then
			return raw:GetName()
		end
	end
end

-- get/set ui object group
function OO:Group(szText)
	self:_checksum()
	if szText then -- set group
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'group', szText)
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'group')
		end
	end
end

-- set ui penetrable
function OO:Penetrable(bPenetrable)
	self:_checksum()
	if X.IsBoolean(bPenetrable) then -- set penetrable
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'bPenetrable', bPenetrable)
			if raw.SetMousePenetrable then
				raw:SetMousePenetrable(bPenetrable)
			end
		end
	else
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'bPenetrable')
		end
	end
	return self
end

-- get/set ui alpha
function OO:Alpha(nAlpha)
	self:_checksum()
	if nAlpha then -- set name
		for _, raw in ipairs(self.raws) do
			raw:SetAlpha(nAlpha)
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw and raw.GetAlpha then
			return raw:GetAlpha()
		end
	end
end

-- (self) Instance:FadeTo(nTime, nOpacity, callback)
function OO:FadeTo(nTime, nOpacity, callback)
	self:_checksum()
	if nTime and nOpacity then
		for i, raw in ipairs(self.raws) do
			local ui = self:Eq(i)
			local nStartAlpha = ui:Alpha()
			local nStartTime = GetTime()
			local fnCurrent = function(nStart, nEnd, nTotalTime, nDuringTime)
				return ( nEnd - nStart ) * nDuringTime / nTotalTime + nStart -- 线性模型
			end
			if not ui:Visible() then
				ui:Alpha(0):Toggle(true)
			end
			X.BreatheCall(X.NSFormatString('{$NS}_FADE_') .. tostring(ui[1]), function()
				ui:Show()
				local nCurrentAlpha = fnCurrent(nStartAlpha, nOpacity, nTime, GetTime() - nStartTime)
				ui:Alpha(nCurrentAlpha)
				--[[#DEBUG BEGIN]]
				-- X.OutputDebugMessage('fade', string.format('%d %d %d %d\n', nStartAlpha, nOpacity, nCurrentAlpha, (nStartAlpha - nCurrentAlpha)*(nCurrentAlpha - nOpacity)), X.DEBUG_LEVEL.LOG)
				--[[#DEBUG END]]
				if (nStartAlpha - nCurrentAlpha)*(nCurrentAlpha - nOpacity) <= 0 then
					ui:Alpha(nOpacity)
					if callback then
						X.CallWithThis(raw, callback, ui)
					end
					return 0
				end
			end)
		end
	end
	return self
end

-- (self) Instance:FadeIn(nTime, callback)
function OO:FadeIn(nTime, callback)
	self:_checksum()
	nTime = nTime or 300
	for i, raw in ipairs(self.raws) do
		self:Eq(i):FadeTo(nTime, GetComponentProp(raw, 'nOpacity') or 255, callback)
	end
	return self
end

-- (self) Instance:FadeOut(nTime, callback)
function OO:FadeOut(nTime, callback)
	self:_checksum()
	nTime = nTime or 300
	for i, raw in ipairs(self.raws) do
		local ui = self:Eq(i)
		if ui:Alpha() > 0 then
			SetComponentProp(ui, 'nOpacity', ui:Alpha())
		end
	end
	self:FadeTo(nTime, 0, function()
		local ui = X.UI(this)
		ui:Toggle(false)
		if callback then
			X.CallWithThis(this, callback)
		end
	end)
	return self
end

-- (self) Instance:SlideTo(nTime, nHeight, callback)
function OO:SlideTo(nTime, nHeight, callback)
	self:_checksum()
	if nTime and nHeight then
		for i, raw in ipairs(self.raws) do
			local ui = self:Eq(i)
			local nStartValue = ui:Height()
			local nStartTime = GetTime()
			local fnCurrent = function(nStart, nEnd, nTotalTime, nDuringTime)
				return ( nEnd - nStart ) * nDuringTime / nTotalTime + nStart -- 线性模型
			end
			if not ui:Visible() then
				ui:Height(0):Toggle(true)
			end
			X.BreatheCall(function()
				ui:Show()
				local nCurrentValue = fnCurrent(nStartValue, nHeight, nTime, GetTime()-nStartTime)
				ui:Height(nCurrentValue)
				--[[#DEBUG BEGIN]]
				-- X.OutputDebugMessage('slide', string.format('%d %d %d %d\n', nStartValue, nHeight, nCurrentValue, (nStartValue - nCurrentValue)*(nCurrentValue - nHeight)), X.DEBUG_LEVEL.LOG)
				--[[#DEBUG END]]
				if (nStartValue - nCurrentValue)*(nCurrentValue - nHeight) <= 0 then
					ui:Height(nHeight):Toggle( nHeight ~= 0 )
					if callback then
						X.CallWithThis(raw, callback)
					end
					return 0
				end
			end)
		end
	end
	return self
end

-- (self) Instance:SlideUp(nTime, callback)
function OO:SlideUp(nTime, callback)
	self:_checksum()
	nTime = nTime or 300
	for i, raw in ipairs(self.raws) do
		local ui = self:Eq(i)
		if ui:Height() > 0 then
			SetComponentProp(ui, 'nSlideTo', ui:Height())
		end
	end
	self:SlideTo(nTime, 0, callback)
	return self
end

-- (self) Instance:SlideDown(nTime, callback)
function OO:SlideDown(nTime, callback)
	self:_checksum()
	nTime = nTime or 300
	for i, raw in ipairs(self.raws) do
		self:Eq(i):SlideTo(nTime, GetComponentProp(raw, 'nSlideTo'), callback)
	end
	return self
end

-- (number) Instance:Font()
-- (self) Instance:Font(number nFont)
function OO:Font(nFont)
	self:_checksum()
	if nFont then -- set name
		local element
		for _, raw in ipairs(self.raws) do
			element = GetComponentElement(raw, 'TEXT')
			if element then
				element:SetFontScheme(nFont)
			end
			element = GetComponentElement(raw, 'PLACEHOLDER')
			if element then
				local r, g, b = element:GetFontColor()
				element:SetFontScheme(nFont)
				element:SetFontColor(r, g, b)
			end
			element = GetComponentElement(raw, 'EDIT')
			if element then
				element:SetFontScheme(nFont)
				element:SetSelectFontScheme(nFont)
				local r, g, b = element:GetPlaceholderFontColor()
				element:SetPlaceholderFontScheme(nFont)
				element:SetPlaceholderFontColor(r, g, b)
			end
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw and raw.GetFontScheme then
			return raw:GetFontScheme()
		end
	end
end

-- (number, number, number) Instance:Color()
-- (self) Instance:Color(number r, number g, number b)
function OO:Color(r, g, b)
	self:_checksum()
	if X.IsTable(r) then
		r, g, b = X.Unpack(r)
	end
	if b then
		local element
		for _, raw in ipairs(self.raws) do
			element = GetComponentElement(raw, 'SHADOW')
			if element then
				element:SetColorRGB(r, g, b)
			end
			element = GetComponentElement(raw, 'EDIT') or GetComponentElement(raw, 'TEXT')
			if element then
				if raw.IsEnabled and not raw:IsEnabled() then
					element:SetFontColor(r / 2.2, g / 2.2, b / 2.2)
				else
					element:SetFontColor(r, g, b)
				end
			end
		end
		return self
	else
		local raw, element = self.raws[1], nil
		if raw then
			element = GetComponentElement(raw, 'SHADOW')
			if element then
				return element:GetColorRGB()
			end
			element = --[[GetComponentElement(raw, 'EDIT') or ]]GetComponentElement(raw, 'TEXT')
			if element then
				return element:GetFontColor()
			end
		end
	end
end

-- (self) Instance:ColorPick((r: number r, g: number, b: number) => void)
function OO:ColorPick(cb)
	self:_checksum()
	if X.IsFunction(cb) then
		local element
		for _, raw in ipairs(self.raws) do
			local aOnColorPickCBs = GetComponentProp(raw, 'OnColorPickCBs')
			if aOnColorPickCBs then
				table.insert(aOnColorPickCBs, cb)
			end
		end
	else
		self:LClick()
	end
	return self
end

function OO:DrawEclipse(nX, nY, nMajorAxis, nMinorAxis, nR, nG, nB, nA, dwRotate, dwPitch, dwRad, nAccuracy)
	nR, nG, nB, nA = nR or 255, nG or 255, nB or 255, nA or 255
	dwRotate, dwPitch, dwRad = dwRotate or 0, dwPitch or 0, dwRad or (2 * math.pi)
	nAccuracy = nAccuracy or 32
	local deltaRad = (2 * math.pi) / nAccuracy
	local sha, nX1, nY1, nMajorAxis1, nMinorAxis1, dwRad1, dwRad2, nDis
	for _, raw in ipairs(self.raws) do
		sha = GetComponentElement(raw, 'SHADOW')
		if sha then
			dwRad1 = dwPitch
			dwRad2 = dwPitch + dwRad
			nX1 = nX or (sha:GetW() / 2)
			nY1 = nY or (sha:GetH() / 2)
			nMajorAxis1 = nMajorAxis or nX1
			nMinorAxis1 = nMinorAxis or nY1
			sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
			sha:SetD3DPT(D3DPT.TRIANGLEFAN)
			sha:ClearTriangleFanPoint()
			sha:AppendTriangleFanPoint(nX ,nY, nR, nG, nB, nA)
			sha:Show()
			repeat
				nDis = nMajorAxis * nMinorAxis / math.sqrt(math.pow(nMinorAxis * math.cos(dwRad1 - dwRotate), 2) + math.pow(nMajorAxis * math.sin(dwRad1 - dwRotate), 2))
				sha:AppendTriangleFanPoint(
					nX + nDis * math.cos(dwRad1),
					nY - nDis * math.sin(dwRad1),
					nR, nG, nB, nA
				)
				-- sha:AppendTriangleFanPoint(
				-- 	nX + (nMajorAxis * math.cos(dwRotate) * math.cos(dwRad1 - dwRotate) - nMinorAxis * math.sin(dwRotate) * math.sin(dwRad1 - dwRotate)),
				-- 	nY - (nMinorAxis * math.cos(dwRotate) * math.sin(dwRad1 - dwRotate) + nMajorAxis * math.sin(dwRotate) * math.cos(dwRad1 - dwRotate)),
				-- 	nR, nG, nB, nA
				-- )
				dwRad1 = (dwRad1 < dwRad2 and dwRad1 + deltaRad > dwRad2) and dwRad2 or (dwRad1 + deltaRad)
			until dwRad1 > dwRad2
		end
	end
	return self
end

function OO:DrawCircle(nX, nY, nRadius, nR, nG, nB, nA, dwPitch, dwRad, nAccuracy)
	nR, nG, nB, nA = nR or 255, nG or 255, nB or 255, nA or 255
	dwPitch, dwRad = dwPitch or 0, dwRad or (2 * math.pi)
	nAccuracy = nAccuracy or 32
	local deltaRad = (2 * math.pi) / nAccuracy
	local sha, nX1, nY1, nRadius1, dwRad1, dwRad2
	for _, raw in ipairs(self.raws) do
		sha = GetComponentElement(raw, 'SHADOW')
		if sha then
			dwRad1 = dwPitch
			dwRad2 = dwPitch + dwRad
			nX1 = nX or (sha:GetW() / 2)
			nY1 = nY or (sha:GetH() / 2)
			nRadius1 = nRadius or math.min(nX1, nY1)
			sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
			sha:SetD3DPT(D3DPT.TRIANGLEFAN)
			sha:ClearTriangleFanPoint()
			sha:AppendTriangleFanPoint(nX1, nY1, nR, nG, nB, nA)
			sha:Show()
			repeat
				sha:AppendTriangleFanPoint(nX1 + math.cos(dwRad1) * nRadius1, nY1 - math.sin(dwRad1) * nRadius1, nR, nG, nB, nA)
				dwRad1 = (dwRad1 < dwRad2 and dwRad1 + deltaRad > dwRad2) and dwRad2 or (dwRad1 + deltaRad)
			until dwRad1 > dwRad2
		end
	end
	return self
end

function OO:DrawGwText(szText, nX ,nY, nZ, nR, nG, nB, nA, nFont, fFontScale, fSpacing, aDelta)
	local sha
	for _, raw in ipairs(self.raws) do
		sha = GetComponentElement(raw, 'SHADOW')
		if sha then
			sha:SetTriangleFan(GEOMETRY_TYPE.TEXT)
			sha:ClearTriangleFanPoint()
			sha:AppendTriangleFan3DPoint(
				nX ,nY, nZ,
				nR or 255, nG or 255, nB or 255, nA or 255,
				aDelta or 0, -- fYDelta | {fXDelta, fYDelta, fZDelta, fScreenXDelta, fScreenYDelta}
				nFont or 40,
				szText,
				fSpacing or 0,
				fFontScale or 1
			)
			sha:Show()
		end
	end
	return self
end

function OO:DrawGwCircle(nX, nY, nZ, nRadius, nR, nG, nB, nA, dwPitch, dwRad)
	nRadius, dwPitch, dwRad = nRadius or (64 * 3), dwPitch or 0, dwRad or (2 * math.pi)
	nR, nG, nB, nA = nR or 255, nG or 255, nB or 255, nA or 120
	local sha, dwRad1, dwRad2, nSceneX, nSceneZ, nSceneXD, nSceneZD
	for _, raw in ipairs(self.raws) do
		sha = GetComponentElement(raw, 'SHADOW')
		if sha then
			dwRad1, dwRad2 = dwPitch, dwPitch + dwRad * 1.05 -- 稍微大点 不然整个圈的时候会有个缝
			sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
			sha:SetD3DPT(D3DPT.TRIANGLEFAN)
			sha:ClearTriangleFanPoint()
			sha:AppendTriangleFan3DPoint(nX ,nY, nZ, nR, nG, nB, nA)
			sha:Show()
			nSceneX, nSceneZ, nSceneXD, nSceneZD = Scene_PlaneGameWorldPosToScene(nX, nY)
			repeat
				nSceneXD, nSceneZD = Scene_PlaneGameWorldPosToScene(nX + math.cos(dwRad1) * nRadius, nY + math.sin(dwRad1) * nRadius)
				sha:AppendTriangleFan3DPoint(nX ,nY, nZ, nR, nG, nB, nA, { nSceneXD - nSceneX, 0, nSceneZD - nSceneZ })
				dwRad1 = dwRad1 + math.pi / 16
			until dwRad1 > dwRad2
		end
	end
	return self
end

-- (number) Instance:Left()
-- (self) Instance:Left(number)
function OO:Left(nLeft)
	if nLeft then
		return self:Pos(nLeft, nil)
	else
		local l, t = self:Pos()
		return l
	end
end

-- (number) Instance:Top()
-- (self) Instance:Top(number)
function OO:Top(nTop)
	if nTop then
		return self:Pos(nil, nTop)
	else
		local l, t = self:Pos()
		return t
	end
end

-- (number, number) Instance:Pos()
-- (self) Instance:Pos(nLeft, nTop)
function OO:Pos(nLeft, nTop)
	self:_checksum()
	if X.IsNumber(nLeft) or X.IsNumber(nTop) then
		for _, raw in ipairs(self.raws) do
			local nLeft, nTop = nLeft or raw:GetRelX(), nTop or raw:GetRelY()
			raw:SetRelPos(nLeft, nTop)
			if raw:GetBaseType() == 'Item' then
				raw = raw:GetParent()
				if raw and raw:GetType() == 'Handle' then
					raw:FormatAllItemPos()
				end
			end
		end
		return self
	else
		local szType = 'TOPLEFT'
		if X.IsString(nLeft) then
			szType = nLeft
		end
		local raw = self.raws[1]
		if raw and raw.GetRelPos then
			local nX, nY = raw:GetRelPos()
			if szType == 'TOPRIGHT' or szType == 'BOTTOMRIGHT' then
				nX = nX + self:Width()
			end
			if szType == 'BOTTOMLEFT' or szType == 'BOTTOMRIGHT' then
				nY = nY + self:Height()
			end
			return nX, nY
		end
	end
end

-- 获取列表类型界面组件当前悬停的选项绝对位置和尺寸信息
---@return { x: number, y: number, w: number, h: number } | nil
function OO:HoverItemRect()
	self:_checksum()
	local raw = self.raws[1]
	local hItem = GetComponentProp(raw, 'hoverItem')
	if not hItem then
		return
	end
	local x, y = hItem:GetAbsPos()
	local w, h = hItem:GetSize()
	return { x, y, w, h }
end

-- (self) Instance:Shake(xrange, yrange, maxspeed, time)
function OO:Shake(xrange, yrange, maxspeed, time)
	self:_checksum()
	if xrange and yrange and maxspeed and time then
		local starttime = GetTime()
		local xspeed, yspeed = maxspeed, - maxspeed
		local xhalfrange, yhalfrange = xrange / 2, yrange / 2
		for _, raw in ipairs(self.raws) do
			local ui = X.UI(raw)
			local xoffset, yoffset = 0, 0
			X.RenderCall(tostring(raw) .. ' shake', function()
				if ui:Count() == 0 then
					return 0
				elseif GetTime() - starttime < time then
					local x, y = ui:Pos()
					x, y = x - xoffset, y - yoffset

					xoffset = xoffset + X.Random(xspeed > 0 and 0 or xspeed, xspeed > 0 and xspeed or 0)
					if xoffset < - xhalfrange then
						xoffset = math.min(- xrange - xoffset, xhalfrange)
						xspeed = - xspeed
					elseif xoffset > xhalfrange then
						xoffset = math.max(xrange - xoffset, - xhalfrange)
						xspeed = - xspeed
					end

					yoffset = yoffset + X.Random(yspeed > 0 and 0 or yspeed, yspeed > 0 and yspeed or 0)
					if yoffset < - yhalfrange then
						yoffset =  math.min(- yrange - yoffset, yhalfrange)
						yspeed = - yspeed
					elseif yoffset > yhalfrange then
						yoffset = math.max(yrange - yoffset, - yhalfrange)
						yspeed = - yspeed
					end

					ui:Pos(x + xoffset, y + yoffset)
				else
					local x, y = ui:Pos()
					ui:Pos(x - xoffset, y - yoffset)
					return 0
				end
			end)
		end
	else
		for _, raw in ipairs(self.raws) do
			X.RenderCall(tostring(raw) .. ' shake', false)
		end
	end
end

-- (anchor) Instance:Anchor()
-- (self) Instance:Anchor(anchor)
do
local CENTER = { s = 'CENTER', r = 'CENTER',  x = 0, y = 0 } -- szSide, szRelSide, fOffsetX, fOffsetY
function OO:Anchor(anchor)
	self:_checksum()
	if anchor == 'CENTER' then
		anchor = CENTER
	end
	if X.IsTable(anchor) then
		for _, raw in ipairs(self.raws) do
			if raw:GetType() == 'WndFrame' then
				raw:SetPoint(anchor.s, 0, 0, anchor.r, anchor.x, anchor.y)
				raw:CorrectPos()
			end
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw and raw:GetType() == 'WndFrame' then
			return GetFrameAnchor(raw, anchor)
		end
	end
end
end

-- (number) Instance:Width()
-- (self) Instance:Width(number[, number])
function OO:Width(nWidth)
	if nWidth then
		return self:Size(nWidth, nil)
	else
		local nW = self:Size()
		return nW
	end
end

-- (number) Instance:Height()
-- (self) Instance:Height(number[, number])
function OO:Height(nHeight)
	if nHeight then
		return self:Size(nil, nHeight)
	else
		local _, nH = self:Size()
		return nH
	end
end

local function SetComponentSize(raw, nWidth, nHeight, nInnerWidth, nInnerHeight)
	local componentType = GetComponentType(raw)
	if not nWidth then
		nWidth = raw:GetW()
	end
	if not nHeight then
		nHeight = raw:GetH()
	end
	-- Auto
	local bAutoWidth = nWidth == 'auto'
	local bAutoHeight = nHeight == 'auto'
	if bAutoWidth or bAutoHeight then
		if componentType == 'Text' then
			raw:AutoSize()
			if bAutoWidth then
				nWidth = raw:GetW()
			end
			if bAutoHeight then
				nHeight = raw:GetH()
			end
		elseif componentType == 'Handle' then
			local nW, nH = raw:GetAllItemSize()
			if bAutoWidth then
				nWidth = nW
			end
			if bAutoHeight then
				nHeight = nH
			end
		elseif componentType == 'WndButton'
			or componentType == 'WndButtonBox'
			or componentType == 'WndCheckBox'
			or componentType == 'WndRadioBox'
			or componentType == 'WndComboBox'
			or componentType == 'WndSlider'
			or componentType == 'CheckBox'
			or componentType == 'ColorBox'
		then
			local bWillAffectRaw = componentType == 'WndCheckBox'
				or componentType == 'WndRadioBox'
				or componentType == 'WndComboBox'
			local hText = GetComponentElement(raw, 'TEXT')
			if hText then
				local ui = X.UI(raw)
				local nW, nH, nRawW, nRawH = ui:Size()
				local nTextOriginW, nTextOriginH = hText:GetSize()
				hText:SetSize(1000, 1000)
				hText:AutoSize()
				local nTextW, nTextH = hText:GetSize()
				local nDeltaW = nTextW - nTextOriginW
				local nDeltaH = nTextH - nTextOriginH
				if bAutoWidth then
					if nRawW and bWillAffectRaw then
						nRawW = nRawW + nDeltaW
					end
					nW = nW + nDeltaW
					nWidth, nInnerWidth = nW, nRawW
				end
				if bAutoHeight then
					if nRawH and bWillAffectRaw then
						nRawH = nRawH + nDeltaH
					end
					nH = nH + nDeltaH
					nHeight, nInnerHeight = nH, nRawH
				end
				if componentType == 'WndRadioBox' then
					if bAutoWidth and X.IsNumber(nHeight) then
						nWidth = nHeight + nTextW + 1
					end
				elseif componentType == 'WndCheckBox' then
					if bAutoWidth and X.IsNumber(nHeight) then
						nWidth = nHeight + nTextW + 1
					end
				elseif componentType == 'ColorBox' then
					if bAutoWidth and X.IsNumber(nHeight) then
						nWidth = nHeight + nTextW + 5
					end
				end
				hText:SetSize(nTextOriginW, nTextOriginH)
			end
		elseif componentType == 'WndContainer' then
			local nW, nH = raw:GetAllContentSize()
			if bAutoWidth then
				nWidth = nW
			end
			if bAutoHeight then
				nHeight = nH
			end
		end
	end
	if not X.IsNumber(nWidth) or not X.IsNumber(nHeight) then
		--[[#DEBUG BEGIN]]
		X.OutputDebugMessage(X.PACKET_INFO.NAME_SPACE, 'Set size of ' .. raw:GetName() .. '(' .. GetComponentType(raw) .. ') failed: ' .. X.EncodeLUAData(nWidth) .. ', ' .. X.EncodeLUAData(nHeight), X.DEBUG_LEVEL.ERROR)
		--[[#DEBUG END]]
		return
	end
	-- Set
	local nMinWidth = GetComponentProp(raw, 'minWidth') or 0
	local nMinHeight = GetComponentProp(raw, 'minHeight') or 0
	if nWidth < nMinWidth then
		nWidth = nMinWidth
	end
	if nHeight < nMinHeight then
		nHeight = nMinHeight
	end
	if componentType == 'WndFrame' then
		local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
		local hnd = raw:Lookup('', '')
		local eTheme = GetComponentProp(raw, 'theme')
		-- 处理窗口背景自适应缩放
		local hBgHandle = hnd:Lookup('Handle_GlassmorphismBg')
		if hBgHandle then
			local imgGlassmorphism = hBgHandle:Lookup('Image_GlassmorphismBg_Glass')
			local imgGlassmorphismBg = hBgHandle:Lookup('Image_GlassmorphismBg')
			local imgGlassmorphismTitleBg = hBgHandle:Lookup('Image_GlassmorphismBg_Title')
			local imgGlassmorphismTitleTextureL = hBgHandle:Lookup('Image_GlassmorphismBg_Title_TextureL')
			local imgGlassmorphismTitleTextureR = hBgHandle:Lookup('Image_GlassmorphismBg_Title_TextureR')
			if imgGlassmorphism then
				imgGlassmorphism:SetSize(nWidth, nHeight)
			end
			if imgGlassmorphismBg then
				imgGlassmorphismBg:SetSize(nWidth, nHeight - 33)
			end
			if imgGlassmorphismTitleBg and imgGlassmorphismTitleTextureL and imgGlassmorphismTitleTextureR then
				imgGlassmorphismTitleBg:SetW(nWidth)
				-- imgTitleTextureL
				imgGlassmorphismTitleTextureR:SetRelX(nWidth - imgGlassmorphismTitleTextureR:GetW())
			end
			hBgHandle:FormatAllItemPos()
		end
		local hBgHandle = hnd:Lookup('Handle_ClassicBg_Intact')
		if hBgHandle then
			local imgBgTLConner = hBgHandle:Lookup('Image_ClassicBg_Intact_TLConner')
			local imgBgTRConner = hBgHandle:Lookup('Image_ClassicBg_Intact_TRConner')
			local imgBgTLFlex = hBgHandle:Lookup('Image_ClassicBg_Intact_TLFlex')
			local imgBgTRFlex = hBgHandle:Lookup('Image_ClassicBg_Intact_TRFlex')
			local imgBgTLCenter = hBgHandle:Lookup('Image_ClassicBg_Intact_TLCenter')
			local imgBgTRCenter = hBgHandle:Lookup('Image_ClassicBg_Intact_TRCenter')
			local imgBgBL = hBgHandle:Lookup('Image_ClassicBg_Intact_BL')
			local imgBgBC = hBgHandle:Lookup('Image_ClassicBg_Intact_BC')
			local imgBgBR = hBgHandle:Lookup('Image_ClassicBg_Intact_BR')
			local imgBgCL = hBgHandle:Lookup('Image_ClassicBg_Intact_CL')
			local imgBgCC = hBgHandle:Lookup('Image_ClassicBg_Intact_CC')
			local imgBgCR = hBgHandle:Lookup('Image_ClassicBg_Intact_CR')
			if imgBgTLConner and imgBgTLFlex and imgBgTLCenter
			and imgBgTRConner and imgBgTRFlex and imgBgTRCenter
			and imgBgBL and imgBgBC and imgBgBR and imgBgCL and imgBgCC and imgBgCR then
				local fScale = nWidth < 426 and (nWidth / 426) or 1
				local nTH = 70 * fScale
				local nTConnerW = 213 * fScale
				imgBgTLConner:SetSize(nTConnerW, nTH)
				imgBgTRConner:SetSize(nTConnerW, nTH)
				local nTFlexW = math.max(0, (nWidth - (nWidth >= 674 and 674 or 426)) / 2)
				imgBgTLFlex:SetSize(nTFlexW, nTH)
				imgBgTRFlex:SetSize(nTFlexW, nTH)
				local nTCenterW = nWidth >= 674 and (124 * fScale) or 0
				imgBgTLCenter:SetSize(nTCenterW, nTH)
				imgBgTRCenter:SetSize(nTCenterW, nTH)
				local nBLW, nBRW = math.ceil(124 * fScale), math.ceil(8 * fScale)
				local nBCW, nBH = nWidth - nBLW - nBRW + 1, 85 * fScale -- 不知道为什么差一像素 但是加上就好了
				imgBgBL:SetSize(nBLW, nBH)
				imgBgBC:SetSize(nBCW, nBH)
				imgBgBR:SetSize(nBRW, nBH)
				local nCEdgeW = math.ceil(8 * fScale)
				local nCCW, nCH = nWidth - 2 * nCEdgeW + 1, nHeight - nTH - nBH -- 不知道为什么差一像素 但是加上就好了
				imgBgCL:SetSize(nCEdgeW, nCH)
				imgBgCC:SetSize(nCCW, nCH)
				imgBgCR:SetSize(nCEdgeW, nCH)
				imgBgCL:SetRelY(nTH)
				imgBgBL:SetRelY(nTH + nCH)
				hnd:FormatAllItemPos()
			end
			hBgHandle:FormatAllItemPos()
		end
		local hBgHandle = hnd:Lookup('Handle_ClassicBg_Simple')
		if hBgHandle then
			local imgBg = hBgHandle:Lookup('Image_ClassicBg_Simple')
			local imgBgTitle = hBgHandle:Lookup('Image_ClassicBg_Simple_Title')
			if imgBg then
				imgBg:SetSize(nWidth, nHeight)
			end
			if imgBgTitle then
				imgBgTitle:SetW(nWidth)
			end
		end
		local hBgHandle = hnd:Lookup('Handle_ClassicBg_Float')
		if hBgHandle then
			local shaBg = hBgHandle:Lookup('Shadow_ClassicBg_Float')
			local imgBgTitle = hBgHandle:Lookup('Image_ClassicBg_Float_Title')
			if shaBg then
				shaBg:SetSize(nWidth, nHeight)
			end
			if imgBgTitle then
				imgBgTitle:SetW(nWidth)
			end
		end
		-- 处理窗口其它组件
		local hBtnDrag = raw:Lookup('Btn_Drag')
		if hBtnDrag then
			hBtnDrag:SetRelPos(
				nWidth - hBtnDrag:GetW() + (hBtnDrag.nVisualOffsetX or 0),
				nHeight - hBtnDrag:GetH() + (hBtnDrag.nVisualOffsetY or 0)
			)
		end
		local hDragBg = raw:Lookup('Wnd_DragBg', 'Shadow_DragBg')
		if hDragBg then
			hDragBg:SetSize(nWidth, nHeight)
		end
		local containerL = raw:Lookup('WndContainer_FrameRightControl')
		if containerL then
			containerL:SetW(nWidth - 4)
			containerL:FormatAllContentPos()
		end
		local containerR = raw:Lookup('WndContainer_FrameRightControl')
		if containerR then
			containerR:SetW(nWidth - 4)
			containerR:FormatAllContentPos()
		end
		local nWndY = 0
		if eTheme == X.UI.FRAME_THEME.SIMPLE then
			nWndY = 33
		elseif eTheme == X.UI.FRAME_THEME.FLOAT then
			nWndY = 30
		end
		if wnd then
			wnd:SetRelY(nWndY)
			wnd:SetSize(nWidth, nHeight - nWndY)
			wnd:Lookup('', ''):SetSize(nWidth, nHeight - nWndY)
		end
		local hdb = raw:Lookup('', 'Handle_DBClick')
			or raw:Lookup('Wnd_Total', 'Handle_DBClick')
		if hdb then
			hdb:SetW(nWidth)
		end
		local txtTitle = raw:Lookup('', 'Text_Title')
		if txtTitle then
			txtTitle:SetW(nWidth)
		end
		local txtAuthor = hnd:Lookup('Text_Author')
		if txtAuthor then
			txtAuthor:SetW(nWidth - 31)
			txtAuthor:SetRelY(nHeight - 41)
		end
		hnd:SetSize(nWidth, nHeight)
		raw:SetSize(nWidth, nHeight)
		raw:SetDragArea(0, 0, nWidth, (X.UI.IS_GLASSMORPHISM and eTheme == X.UI.FRAME_THEME.INTACT) and 55 or 33)
		-- 按分类处理其他
		if eTheme == X.UI.FRAME_THEME.SIMPLE then
			local nWidthTitleBtnR = 0
			local p = raw:Lookup('WndContainer_FrameRightControl'):GetFirstChild()
			while p do
				nWidthTitleBtnR = nWidthTitleBtnR + (p:GetSize())
				p = p:GetNext()
			end
		end
		local btnMax = raw:Lookup('CheckBox_Maximize')
		if btnMax then
			btnMax:SetRelX(nWidth - 63)
		end
		local btnClose = raw:Lookup('Btn_Close')
		if btnClose then
			btnClose:SetRelX(nWidth - 35)
		end
		hnd:FormatAllItemPos()
		-- reset position
		local an = GetFrameAnchor(raw)
		raw:SetPoint(an.s, 0, 0, an.r, an.x, an.y)
	elseif componentType == 'WndButton' or componentType == 'WndButtonBox' then
		local btn = GetComponentElement(raw, 'MAIN_WINDOW')
		local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
		local txt = GetComponentElement(raw, 'TEXT')
		local nMarginTop, nMarginRight, nMarginBottom, nMarginLeft = 0, 0, 0, 0 -- 按钮外部边距
		local nPaddingTop, nPaddingRight, nPaddingBottom, nPaddingLeft = 0, 0, 0, 0 -- 按钮内部边距
		local nMarginTopPercent, nMarginRightPercent, nMarginBottomPercent, nMarginLeftPercent = 0, 0, 0, 0 -- 按钮外部百分比边距
		local nPaddingTopPercent, nPaddingRightPercent, nPaddingBottomPercent, nPaddingLeftPercent = 0, 0, 0, 0 -- 按钮内部百分比边距
		local fAnimateScale = 1 -- 按钮动画最大缩放
		local eStyle = GetButtonStyleName(btn)
		local tStyle = GetButtonStyleConfig(eStyle)
		if tStyle then
			nMarginTop = tStyle.nMarginTop or 0
			nMarginRight = tStyle.nMarginRight or 0
			nMarginBottom = tStyle.nMarginBottom or 0
			nMarginLeft = tStyle.nMarginLeft or 0
			nMarginTopPercent = tStyle.nMarginTopPercent or 0
			nMarginRightPercent = tStyle.nMarginRightPercent or 0
			nMarginBottomPercent = tStyle.nMarginBottomPercent or 0
			nMarginLeftPercent = tStyle.nMarginLeftPercent or 0
			nPaddingTop = tStyle.nPaddingTop or 0
			nPaddingRight = tStyle.nPaddingRight or 0
			nPaddingBottom = tStyle.nPaddingBottom or 0
			nPaddingLeft = tStyle.nPaddingLeft or 0
			nPaddingTopPercent = tStyle.nPaddingTopPercent or 0
			nPaddingRightPercent = tStyle.nPaddingRightPercent or 0
			nPaddingBottomPercent = tStyle.nPaddingBottomPercent or 0
			nPaddingLeftPercent = tStyle.nPaddingLeftPercent or 0
			fAnimateScale = tStyle.fAnimateScale or 1
		end
		if txt and (bAutoWidth or bAutoHeight) then
			local nOriginW, nOriginH = txt:GetSize()
			txt:SetSize(1000, 1000)
			txt:AutoSize()
			local nTextW, nTextH = txt:GetSize()
			if fAnimateScale then
				nTextW = nTextW * fAnimateScale
				nTextH = nTextH * fAnimateScale
			end
			if bAutoWidth then
				nWidth = math.max(nTextW + nPaddingLeft + nPaddingRight + nTextW * (nPaddingLeftPercent + nPaddingRightPercent), nMinWidth)
			end
			if bAutoHeight then
				nHeight = math.max(nTextH + nPaddingTop + nPaddingBottom + nTextH * (nPaddingTopPercent + nPaddingBottomPercent), nMinHeight)
			end
			txt:SetSize(nOriginW, nOriginH)
		end
		if tStyle then
			local nTextW = (nWidth - nPaddingLeft - nPaddingRight) / (1 + nPaddingLeftPercent + nPaddingRightPercent)
			local nTextH = (nHeight - nPaddingTop - nPaddingBottom) / (1 + nPaddingTopPercent + nPaddingBottomPercent)
			nMarginTop = nMarginTop + nMarginTopPercent * nTextH
			nMarginRight = nMarginRight + nMarginRightPercent * nTextW
			nMarginBottom = nMarginBottom + nMarginBottomPercent * nTextH
			nMarginLeft = nMarginLeft + nMarginLeftPercent * nTextW
			nPaddingTop = nPaddingTop + nPaddingTopPercent * nTextH
			nPaddingRight = nPaddingRight + nPaddingRightPercent * nTextW
			nPaddingBottom = nPaddingBottom + nPaddingBottomPercent * nTextH
			nPaddingLeft = nPaddingLeft + nPaddingLeftPercent * nTextW
		end
		if componentType == 'WndButtonBox' then
			raw:SetSize(nWidth, nHeight)
			btn:SetRelPos(nMarginLeft, nMarginTop)
		end
		btn:SetSize(nWidth - nMarginLeft - nMarginRight, nHeight - nMarginTop - nMarginBottom)
		if hdl then
			if not txt then
				for i = 0, hdl:GetItemCount() - 1 do
					txt = hdl:Lookup(i)
					if txt:GetType() == 'Text' then
						break
					end
					txt = nil
				end
			end
			hdl:SetRelPos(-nMarginLeft, -nMarginTop)
			hdl:SetAbsPos(btn:GetAbsX() - nMarginLeft, btn:GetAbsY() - nMarginTop) -- 这个 Wnd 的直接 Handle 坐标不刷新问题两年前就报了，没人修，妈的。
			hdl:SetSize(nWidth, nHeight)
			hdl:FormatAllItemPos()
		end
		if txt then
			txt:SetRelPos(nMarginLeft + nPaddingLeft, nMarginTop + nPaddingTop)
			txt:SetSize(nWidth - nMarginLeft - nPaddingLeft - nMarginRight - nPaddingRight, nHeight - nMarginTop - nPaddingTop - nMarginBottom - nPaddingBottom)
			txt:GetParent():FormatAllItemPos()
		end
	elseif componentType == 'WndCheckBox' then
		local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
		local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
		local txt = GetComponentElement(raw, 'TEXT')
		if X.UI.IS_GLASSMORPHISM then
			wnd:SetImagePos(nHeight * 0.1, nHeight * 0.15)
			-- wnd:SetImageRelX()
			-- wnd:SetImageRelY()
			wnd:SetImageSize(nHeight * 0.8, nHeight * 0.8)
			-- wnd:SetImageW()
			-- wnd:SetImageH()
		end
		wnd:SetSize(nHeight, nHeight)
		txt:SetSize(nWidth - nHeight - 1, nHeight - 4)
		txt:SetRelPos(nHeight + 1, 2)
		hdl:SetSize(nWidth, nHeight)
		hdl:FormatAllItemPos()
	elseif componentType == 'WndTabs' then
		raw:SetSize(nWidth, nHeight)
		raw:Lookup('', ''):SetSize(nWidth, nHeight)
		raw:Lookup('', 'Image_WndTabs_Classic_Bg'):SetSize(nWidth - 1, nHeight + 3)
		raw:Lookup('', 'Image_WndTabs_Classic_SplitterL'):SetH(nHeight - 2)
		raw:Lookup('', 'Image_WndTabs_Glassmorphism_Bg'):SetSize(nWidth, nHeight - 3)
	elseif componentType == 'WndTab' then
		raw:SetSize(nWidth, nHeight)
		raw:Lookup('', ''):SetSize(nWidth, nHeight)
		raw:Lookup('', 'Text_WndTab'):SetSize(nWidth, nHeight)
		raw:Lookup('', 'Image_WndTab_Splitter'):SetH(nHeight)
		raw:Lookup('', 'Image_WndTab_Splitter'):SetRelX(nWidth - 1)
		raw:Lookup('', ''):FormatAllItemPos()
	elseif componentType == 'CheckBox' then
		local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
		local img = GetComponentElement(raw, 'IMAGE')
		local txt = GetComponentElement(raw, 'TEXT')
		img:SetSize(nHeight, nHeight)
		txt:SetSize(nWidth - nHeight - 1, nHeight)
		txt:SetRelPos(nHeight + 1, 0)
		hdl:SetSize(nWidth, nHeight)
		hdl:FormatAllItemPos()
	elseif componentType == 'ColorBox' then
		local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
		local sha = GetComponentElement(raw, 'SHADOW')
		local txt = GetComponentElement(raw, 'TEXT')
		sha:SetSize(nHeight - 4, nHeight - 4)
		sha:SetRelPos(2, 2)
		txt:SetSize(nWidth - nHeight - 5, nHeight)
		txt:SetRelPos(nHeight + 5, 0)
		hdl:SetSize(nWidth, nHeight)
		hdl:FormatAllItemPos()
	elseif componentType == 'WndComboBox' then
		local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
		local cmb = GetComponentElement(raw, 'COMBO_BOX')
		local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
		local txt = GetComponentElement(raw, 'TEXT')
		local img = GetComponentElement(raw, 'IMAGE')
		local W, H = wnd:GetSize()
		local nDeltaW, nDeltaH = nWidth - W, nHeight - H
		local w, h = cmb:GetSize()
		cmb:SetRelPos(cmb:GetRelX() + nDeltaW, cmb:GetRelY() + nDeltaH / 2)
		cmb:Lookup('', ''):SetAbsPos(hdl:GetAbsPos())
		cmb:Lookup('', ''):SetSize(nWidth, nHeight)
		wnd:SetSize(nWidth, nHeight)
		hdl:SetSize(nWidth, nHeight)
		img:SetSize(nWidth, nHeight)
		txt:SetSize(txt:GetW() + nDeltaW, nHeight - 4)
		hdl:FormatAllItemPos()
	elseif componentType == 'WndEditComboBox' or componentType == 'WndAutocomplete' then
		local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
		local cmb = GetComponentElement(raw, 'COMBO_BOX')
		local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
		local img = GetComponentElement(raw, 'IMAGE')
		local edt = GetComponentElement(raw, 'EDIT')
		wnd:SetSize(nWidth, nHeight)
		hdl:SetSize(nWidth, nHeight)
		img:SetSize(nWidth, nHeight)
		hdl:FormatAllItemPos()
		local w, h = cmb:GetSize()
		edt:SetSize(nWidth - 10 - w, nHeight - 4)
		if X.UI.IS_GLASSMORPHISM then
			cmb:SetRelPos(nWidth - w - 5, (nHeight - h - 1) / 2 - 1)
		else
			cmb:SetRelPos(nWidth - w - 5, (nHeight - h - 1) / 2 + 1)
		end
	elseif componentType == 'WndRadioBox' then
		local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
		local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
		local txt = GetComponentElement(raw, 'TEXT')
		wnd:SetSize(nHeight, nHeight)
		txt:SetSize(nWidth - nHeight - 1, nHeight)
		txt:SetRelPos(nHeight + 1, 0)
		hdl:SetSize(nWidth, nHeight)
		hdl:FormatAllItemPos()
	elseif componentType == 'WndEditBox' then
		local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
		local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
		local img = GetComponentElement(raw, 'IMAGE')
		local edt = GetComponentElement(raw, 'EDIT')
		local szStyle = GetComponentProp(raw, 'szAppearance')
		local tStyle = EDIT_BOX_APPEARANCE_CONFIG[szStyle] or EDIT_BOX_APPEARANCE_CONFIG['DEFAULT']
		local ico = hdl:Lookup('Image_Icon')
		wnd:SetSize(nWidth, nHeight)
		hdl:SetSize(nWidth, nHeight)
		img:SetSize(nWidth, nHeight)
		if tStyle.szIconImage then
			local nIconW, nIconH, nIconPaddingX = tStyle.nIconWidth, tStyle.nIconHeight, 2
			if nIconH > nHeight then
				nIconW = nIconW * nHeight / nIconH
				nIconH = nHeight
			else
				nIconPaddingX = math.max(nIconPaddingX, (nHeight - nIconH) / 2)
			end
			ico:Show()
			ico:FromUITex(tStyle.szIconImage, tStyle.nIconImageFrame)
			ico:SetAlpha(tStyle.nIconAlpha or 255)
			ico:SetSize(nIconW, nIconH)
			if tStyle.szIconAlign == 'LEFT' then
				ico:SetRelX(nIconPaddingX)
				edt:SetRelX(nIconPaddingX + nIconW)
			else
				ico:SetRelX(nWidth - nIconW)
				edt:SetRelX(4)
			end
			ico:SetRelY((nHeight - nIconH) / 2 + (tStyle.nIconPaddingTop or 0))
			edt:SetSize(nWidth - 4 - nIconPaddingX - nIconW, nHeight - 4)
		else
			ico:Hide()
			edt:SetRelX(4)
			edt:SetSize(nWidth - 8, nHeight - 4)
		end
		hdl:FormatAllItemPos()
	elseif componentType == 'Text' then
		local txt = GetComponentElement(raw, 'TEXT')
		txt:SetSize(nWidth, nHeight)
		txt:GetParent():FormatAllItemPos()
		SetComponentProp(raw, 'bAutoSize', false)
	elseif componentType == 'WndListBox' then
		raw:SetSize(nWidth, nHeight)
		raw:Lookup('Scroll_Default'):SetRelPos(nWidth - 15, 10)
		raw:Lookup('Scroll_Default'):SetSize(15, nHeight - 20)
		raw:Lookup('', ''):SetSize(nWidth, nHeight)
		raw:Lookup('', 'Image_Default'):SetSize(nWidth, nHeight)
		local hList = raw:Lookup('', 'Handle_Scroll')
		hList:SetSize(nWidth - 20, nHeight - 20)
		for i = hList:GetItemCount() - 1, 0, -1 do
			local hItem = hList:Lookup(i)
			hItem:Lookup('Image_Bg'):SetSize(nWidth - 20, 25)
			hItem:Lookup('Image_Sel'):SetSize(nWidth - 20, 25)
			hItem:Lookup('Text_Default'):SetSize(nWidth - 20, 25)
			hItem:FormatAllItemPos()
		end
		hList:FormatAllItemPos()
	elseif componentType == 'WndScrollHandleBox' then
		local nPaddingTop = GetComponentProp(raw, 'nPaddingTop') or 10
		local nPaddingRight = GetComponentProp(raw, 'nPaddingRight') or 15
		local nPaddingBottom = GetComponentProp(raw, 'nPaddingBottom') or 10
		local nPaddingLeft = GetComponentProp(raw, 'nPaddingLeft') or 15
		raw:SetSize(nWidth, nHeight)
		raw:Lookup('', ''):SetSize(nWidth, nHeight)
		raw:Lookup('', 'Image_Default'):SetSize(nWidth, nHeight)
		raw:Lookup('', 'Handle_Padding'):SetRelPos(nPaddingLeft, nPaddingTop)
		raw:Lookup('', 'Handle_Padding'):SetSize(nWidth - nPaddingRight - nPaddingLeft, nHeight - nPaddingTop - nPaddingBottom)
		raw:Lookup('', 'Handle_Padding/Handle_Scroll'):SetSize(nWidth - nPaddingRight - nPaddingLeft, nHeight - nPaddingTop - nPaddingBottom)
		raw:Lookup('', 'Handle_Padding/Handle_Scroll'):FormatAllItemPos()
		raw:Lookup('WndScrollBar'):SetRelPos(nWidth - 15, nPaddingTop)
		raw:Lookup('WndScrollBar'):SetH(nHeight - nPaddingTop - nPaddingBottom)
	elseif componentType == 'WndScrollWindowBox' then
		local nPaddingTop = GetComponentProp(raw, 'nPaddingTop') or 10
		local nPaddingRight = GetComponentProp(raw, 'nPaddingRight') or 15
		local nPaddingBottom = GetComponentProp(raw, 'nPaddingBottom') or 10
		local nPaddingLeft = GetComponentProp(raw, 'nPaddingLeft') or 15
		raw:SetSize(nWidth, nHeight)
		raw:Lookup('', ''):SetSize(nWidth, nHeight)
		raw:Lookup('', 'Image_Default'):SetSize(nWidth, nHeight)
		raw:Lookup('WndContainer_Scroll'):SetRelPos(nPaddingLeft, nPaddingTop)
		raw:Lookup('WndContainer_Scroll'):SetSize(nWidth - nPaddingRight - nPaddingLeft, nHeight - nPaddingTop - nPaddingBottom)
		raw:Lookup('WndContainer_Scroll'):FormatAllContentPos()
		raw:Lookup('WndContainer_Scroll', ''):SetRelPos(nPaddingLeft, nPaddingTop)
		raw:Lookup('WndContainer_Scroll', ''):SetSize(nWidth - nPaddingRight - nPaddingLeft, nHeight - nPaddingTop - nPaddingBottom)
		raw:Lookup('WndContainer_Scroll', ''):FormatAllItemPos()
		raw:Lookup('WndScrollBar'):SetRelPos(nWidth - 15, nPaddingTop)
		raw:Lookup('WndScrollBar'):SetH(nHeight - nPaddingTop - nPaddingBottom)
	elseif componentType == 'WndSlider' then
		local hWnd = GetComponentElement(raw, 'MAIN_WINDOW')
		local hHandle = GetComponentElement(raw, 'MAIN_HANDLE')
		local hSlider = GetComponentElement(raw, 'SLIDER')
		local hText = GetComponentElement(raw, 'TEXT')
		local hBtn = hSlider:Lookup('Btn_Slider')
		local hImage = hHandle:Lookup('Image_BG')
		local nWidth = nWidth or math.max(nWidth, (nInnerWidth or 0) + 5)
		local nHeight = nHeight or math.max(nHeight, (nInnerHeight or 0) + 5)
		local nRawWidth, nRawHeight = hSlider:GetSize()
		local nImageHeight = nRawHeight - 2
		if X.UI.IS_GLASSMORPHISM then
			nRawHeight = nHeight * 0.8
			nImageHeight = 8
			hSlider:SetH(nRawHeight)
			hBtn:SetSize(nRawHeight / 0.75, nRawHeight)
			hBtn:SetAlpha(255)
		end
		hWnd:SetSize(nWidth, nHeight)
		hHandle:SetSize(nWidth, nHeight)
		hText:SetSize(nWidth - nRawWidth - 5, nHeight)
		hSlider:SetRelY((nHeight - nRawHeight) / 2)
		if X.UI.IS_GLASSMORPHISM then
			hImage:SetRelY((nHeight - nImageHeight) / 2)
		else
			hImage:SetRelY((nHeight - nImageHeight) / 2 - 1)
		end
		hImage:SetH(nImageHeight)
		hHandle:FormatAllItemPos()
	elseif componentType == 'WndTable' then
		raw:SetSize(nWidth, nHeight)
		GetComponentProp(raw, 'UpdateTableRect')()
	elseif componentType == 'WndPageSet' then
		local page = raw:GetFirstChild()
		while page do
			if page:GetName() == 'Page_Default' then
				page:SetSize(nWidth - page:GetRelX(), nHeight - page:GetRelY())
			end
			page = page:GetNext()
		end
		local img = raw:Lookup('', 'Image_TabBg')
		if img then
			img:SetW(nWidth)
		end
		raw:SetSize(nWidth, nHeight)
	elseif componentType == 'WndDummyWrapper' then
		raw:SetSize(nWidth, nHeight)
	elseif raw:GetBaseType() == 'Wnd' then
		local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
		local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
		local txt = GetComponentElement(raw, 'TEXT')
		local img = GetComponentElement(raw, 'IMAGE')
		local edt = GetComponentElement(raw, 'EDIT')
		if wnd then wnd:SetSize(nWidth, nHeight) end
		if hdl then hdl:SetSize(nWidth, nHeight) end
		if txt then txt:SetSize(nWidth, nHeight) end
		if img then img:SetSize(nWidth, nHeight) end
		if edt then edt:SetSize(nWidth - 8, nHeight - 4) end
		if hdl then hdl:FormatAllItemPos() end
	else
		local itm = GetComponentElement(raw, 'ITEM') or raw
		itm:SetSize(nWidth, nHeight)
		local h = itm:GetParent()
		if h and h:GetType() == 'Handle' then
			h:FormatAllItemPos()
		end
	end
	local parent = raw:GetParent()
	if parent and parent:GetBaseType() ~= 'Wnd' then
		parent = parent:GetParent()
	end
	if parent then
		local parentComponentType = GetComponentType(parent)
		if parentComponentType == 'WndDummyWrapper' then
			local el = raw
			if el:GetBaseType() == 'Wnd' and raw.IsDummyWnd and raw:IsDummyWnd() then
				el = raw:Lookup('', '') or raw
			end
			local nW, nH = el:GetSize()
			SetComponentSize(parent, nW, nH)
		elseif parentComponentType == 'WndContainer' then
			local bAutoWidth = GetComponentProp(parent, 'AutoWidth')
			local bAutoHeight = GetComponentProp(parent, 'AutoHeight')
			if bAutoWidth or bAutoHeight then
				parent:FormatAllContentPos()
				SetComponentSize(parent, bAutoWidth and 'auto' or nil, bAutoHeight and 'auto' or nil)
			end
		end
	end
	X.ExecuteWithThis(raw, raw.OnSizeChange)
end

-- (number, number) Instance:Size()
-- (self) Instance:Size(nLeft, nTop)
-- (self) Instance:Size(OnSizeChange)
function OO:Size(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local arg0, arg1 = ...
		if X.IsFunction(arg0) then
			for _, raw in ipairs(self.raws) do
				X.UI(raw):UIEvent('OnSizeChange', arg0)
			end
		else
			local nWidth, nHeight = arg0, arg1
			local bAutoWidth = nWidth == 'auto'
			local bStaticWidth = X.IsNumber(nWidth)
			local bAutoHeight = nHeight == 'auto'
			local bStaticHeight = X.IsNumber(nHeight)
			if bAutoWidth then
				nWidth = nil
			end
			if bAutoHeight then
				nHeight = nil
			end
			if X.IsNumber(nWidth) or bAutoWidth or X.IsNumber(nHeight) or bAutoHeight then
				for _, raw in ipairs(self.raws) do
					if bAutoWidth or bStaticWidth then
						SetComponentProp(raw, 'AutoWidth', bAutoWidth)
					end
					if bAutoHeight or bStaticHeight then
						SetComponentProp(raw, 'AutoHeight', bAutoHeight)
					end
					SetComponentSize(raw, bAutoWidth and 'auto' or nWidth, bAutoHeight and 'auto' or nHeight)
				end
			end
		end
		return self
	else
		local raw, w, h = self.raws[1], nil, nil
		if raw then
			if raw.IsDummyWnd and raw:IsDummyWnd() then
				raw = raw:Lookup('', '') or raw
			end
			if raw.GetSize then
				w, h = raw:GetSize()
			end
		end
		return w, h
	end
end

-- (number, number, number, number) Instance:Padding()
-- (self) Instance:Padding(nPaddingTop, nPaddingRight, nPaddingBottom, nPaddingLeft)
function OO:Padding(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local nPaddingTop, nPaddingRight, nPaddingBottom, nPaddingLeft = ...
		if not nPaddingBottom then
			nPaddingBottom = nPaddingTop
		end
		if not nPaddingLeft then
			nPaddingLeft = nPaddingRight
		end
		for _, raw in ipairs(self.raws) do
			if nPaddingTop then
				SetComponentProp(raw, 'nPaddingTop', nPaddingTop)
			end
			if nPaddingRight then
				SetComponentProp(raw, 'nPaddingRight', nPaddingRight)
			end
			if nPaddingBottom then
				SetComponentProp(raw, 'nPaddingBottom', nPaddingBottom)
			end
			if nPaddingLeft then
				SetComponentProp(raw, 'nPaddingLeft', nPaddingLeft)
			end
			SetComponentSize(raw)
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'nPaddingTop'),
				GetComponentProp(raw, 'nPaddingRight'),
				GetComponentProp(raw, 'nPaddingBottom'),
				GetComponentProp(raw, 'nPaddingLeft')
		end
	end
end

-- (number) Instance:PaddingTop()
-- (self) Instance:PaddingTop(nPaddingTop)
function OO:PaddingTop(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local nPaddingTop = ...
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'nPaddingTop', nPaddingTop)
			SetComponentSize(raw)
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'nPaddingTop')
		end
	end
end

-- (number) Instance:PaddingRight()
-- (self) Instance:PaddingRight(nPaddingRight)
function OO:PaddingRight(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local nPaddingRight = ...
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'nPaddingRight', nPaddingRight)
			SetComponentSize(raw)
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'nPaddingRight')
		end
	end
end

-- (number) Instance:PaddingBottom()
-- (self) Instance:PaddingBottom(nPaddingBottom)
function OO:PaddingBottom(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local nPaddingBottom = ...
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'nPaddingBottom', nPaddingBottom)
			SetComponentSize(raw)
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'nPaddingBottom')
		end
	end
end

-- (number) Instance:PaddingLeft()
-- (self) Instance:PaddingLeft(nPaddingLeft)
function OO:PaddingLeft(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local nPaddingLeft = ...
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'nPaddingLeft', nPaddingLeft)
			SetComponentSize(raw)
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'nPaddingLeft')
		end
	end
end

-- (number nW, number nH) Instance:ContainerSize() -- Get container size
function OO:ContainerSize()
	self:_checksum()
	local raw = self.raws[1]
	if raw then
		raw = GetComponentElement(raw, 'MAIN_CONTAINER')
		if raw then
			return raw:GetSize()
		end
	end
end

-- (number nW) Instance:ContainerWidth() -- Get container width
function OO:ContainerWidth()
	return (self:ContainerSize())
end

-- (number nH) Instance:ContainerHeight() -- Get container height
function OO:ContainerHeight()
	return (select(2, self:ContainerSize()))
end

-- (self) Instance:MinSize() -- Get element min size
-- (self) Instance:MinSize(number nW, number nH) -- Set element min size
function OO:MinSize(nW, nH)
	self:_checksum()
	if X.IsNumber(nW) or X.IsNumber(nH) then -- set
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'minWidth', nW)
			SetComponentProp(raw, 'minHeight', nH)
		end
		return self
	elseif X.IsNumber(nW) then -- set
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'minWidth', nW)
		end
		return self
	elseif X.IsNumber(nH) then -- set
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'minHeight', nH)
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'minWidth'), GetComponentProp(raw, 'minHeight')
		end
	end
end

-- (self) Instance:MinWidth() -- Get element min width
-- (self) Instance:MinWidth(number nW) -- Set element min width
function OO:MinWidth(nW)
	self:_checksum()
	if X.IsNumber(nW) then -- set
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'minWidth', nW)
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'minWidth')
		end
	end
end

-- (self) Instance:MinHeight() -- Get element min height
-- (self) Instance:MinHeight(number nH) -- Set element min height
function OO:MinHeight(nH)
	self:_checksum()
	if X.IsNumber(nH) then -- set
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'minHeight', nH)
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'minHeight')
		end
	end
end

-- (self) Instance:ChildrenSize() -- Get element all children size
function OO:ChildrenSize()
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		if GetComponentType(raw) == 'Handle' then
			return raw:GetAllItemSize()
		elseif GetComponentType(raw) == 'WndContainer' then
			return raw:GetAllContentSize()
		end
	end
end

-- Auto set width of element by text
-- (self) Instance:AutoWidth()
function OO:AutoWidth()
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		SetComponentProp(raw, 'AutoWidth', true)
		SetComponentSize(raw, 'auto', nil)
	end
	return self
end

-- Auto set height of element by text
-- (self) Instance:AutoHeight()
function OO:AutoHeight()
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		SetComponentProp(raw, 'AutoHeight', true)
		SetComponentSize(raw, nil, 'auto')
	end
	return self
end

-- (self) Instance:AutoSize() -- resize Text element by autoSize
-- (self) Instance:AutoSize(bool bAutoSize) -- set if Text is autoSize
function OO:AutoSize(arg0, arg1)
	self:_checksum()
	if X.IsNil(arg0) then
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'AutoWidth', true)
			SetComponentProp(raw, 'AutoHeight', true)
			SetComponentSize(raw, 'auto', 'auto')
		end
	elseif X.IsBoolean(arg0) then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'Text' then
				raw.bAutoSize = arg0
			end
		end
	end
	return self
end

-- (self) Instance:SliderSize() -- get slider size
-- (self) Instance:SliderSize(number nWidth, number nHeight) -- set slider size
function OO:SliderSize(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local nWidth, nHeight = ...
		for _, raw in ipairs(self.raws) do
			local componentType = GetComponentType(raw)
			if componentType == 'WndSlider' then
				local hSlider = GetComponentElement(raw, 'SLIDER')
				local hHandle = GetComponentElement(raw, 'MAIN_HANDLE')
				local hText = GetComponentElement(raw, 'TEXT')
				local hButton = hSlider:Lookup('Btn_Slider')
				local hImage = hHandle:Lookup('Image_BG')
				local nOriginWidth, nOriginHeight = hSlider:GetSize()
				if not nWidth then
					nWidth = nOriginWidth
				end
				if not nHeight then
					nHeight = nOriginHeight
				end
				if nWidth ~= nOriginWidth or nHeight ~= nOriginHeight then
					hSlider:SetSize(nWidth, nHeight)
					hSlider:SetRelY(hSlider:GetRelY() - (nHeight - nOriginHeight) / 2)
					local nBtnWidth = math.min(34, nWidth * 0.6)
					local nBtnHeight = nHeight
					if X.UI.IS_GLASSMORPHISM then
						nBtnHeight = nBtnWidth
					end
					hButton:SetSize(nBtnWidth, nHeight)
					hButton:SetRelX((nWidth - nBtnWidth) * hSlider:GetScrollPos() / hSlider:GetStepCount())
					hText:SetRelX(nWidth + 5)
					hImage:SetSize(nWidth, nHeight - 2)
					hImage:SetRelY(hSlider:GetRelY() + 1)
					hHandle:SetW(nWidth + 5 + hText:GetW())
					hHandle:FormatAllItemPos()
				end
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			raw = GetComponentElement(raw, 'SLIDER')
			if raw then
				return raw:GetSize()
			end
		end
	end
end

-- (self) Instance:SliderWidth() -- get slider width
-- (self) Instance:SliderWidth(number nWidth) -- set slider width
function OO:SliderWidth(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local nWidth = ...
		return self:SliderSize(nWidth, nil)
	else
		local nWidth = self:SliderSize()
		return nWidth
	end
end

-- (self) Instance:SliderHeight() -- get slider height
-- (self) Instance:SliderHeight(number nHeight) -- set slider height
function OO:SliderHeight(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local nHeight = ...
		return self:SliderSize(nil, nHeight)
	else
		local _, nHeight = self:SliderSize()
		return nHeight
	end
end

-- (bool) Instance:FrameVisualState() -- get frame visual state
-- (self) Instance:FrameVisualState(X.UI.FRAME_VISUAL_STATE eVisualState) -- set frame visual state
-- (self) Instance:FrameVisualState(function onFrameVisualStateChange) -- set frame visual state change event handler
function OO:FrameVisualState(...)
	self:_checksum()
	local argc = select('#', ...)
	if argc > 0 then -- set
		local arg0 = ...
		if X.IsFunction(arg0) then
			for _, raw in ipairs(self.raws) do
				X.UI(raw):UIEvent('OnFrameVisualStateChange', arg0)
			end
		else
			local eNextVisualState = arg0
			for _, raw in ipairs(self.raws) do
				if GetComponentType(raw) == 'WndFrame' and GetComponentProp(raw, 'eFrameVisualState') ~= eNextVisualState then
					local eCurrentVisualState = GetComponentProp(raw, 'eFrameVisualState') or X.UI.FRAME_VISUAL_STATE.NORMAL
					-- 更新界面按钮状态
					local chkMaximize = raw:Lookup('WndContainer_FrameRightControl/Wnd_Maximize/CheckBox_Maximize')
					if eCurrentVisualState == X.UI.FRAME_VISUAL_STATE.MAXIMIZE then
						if chkMaximize then
							chkMaximize:Check(false, WNDEVENT_FIRETYPE.PREVENT)
						end
					elseif eCurrentVisualState == X.UI.FRAME_VISUAL_STATE.MINIMIZE then
						raw:Lookup('WndContainer_FrameRightControl/Wnd_Minimize/CheckBox_Minimize'):Check(false, WNDEVENT_FIRETYPE.PREVENT)
					end
					-- 恢复默认窗体状态
					if (eNextVisualState == X.UI.FRAME_VISUAL_STATE.MAXIMIZE and eCurrentVisualState == X.UI.FRAME_VISUAL_STATE.MINIMIZE)
					or (eNextVisualState == X.UI.FRAME_VISUAL_STATE.MINIMIZE and eCurrentVisualState == X.UI.FRAME_VISUAL_STATE.MAXIMIZE) then
						X.UI(raw):FrameVisualState(X.UI.FRAME_VISUAL_STATE.NORMAL)
					end
					-- 保存普通窗体大小
					if eCurrentVisualState == X.UI.FRAME_VISUAL_STATE.NORMAL then
						local nW, nH = raw:GetSize()
						SetComponentProp(raw, 'tFrameVisualStateRestoreAnchor', GetFrameAnchor(raw))
						SetComponentProp(raw, 'nFrameVisualStateRestoreWidth', nW)
						SetComponentProp(raw, 'nFrameVisualStateRestoreHeight', nH)
					end
					-- 处理视觉变化
					local wndTotal = raw:Lookup('Wnd_Total')
					local shaBg = raw:Lookup('', 'Shadow_Bg')
					local imgGlassmorphism = raw:Lookup('', 'Handle_GlassmorphismBg/Image_GlassmorphismBg_Glass')
					local imgGlassmorphismBg = raw:Lookup('', 'Handle_GlassmorphismBg/Image_GlassmorphismBg')
					local btnDrag = raw:Lookup('Btn_Drag')
					if eNextVisualState == X.UI.FRAME_VISUAL_STATE.MINIMIZE then -- 最小化
						SetComponentProp(raw, 'eFrameVisualState', eNextVisualState)
						if wndTotal then
							wndTotal:Hide()
						end
						if shaBg then
							shaBg:Hide()
						end
						if imgGlassmorphism then
							imgGlassmorphism:Hide()
						end
						if imgGlassmorphismBg then
							imgGlassmorphismBg:Hide()
						end
						local eTheme = GetComponentProp(raw, 'theme')
						if X.UI.IS_GLASSMORPHISM then
							raw:SetH(33)
							raw:Lookup('', ''):SetH(33)
						elseif eTheme == X.UI.FRAME_THEME.SIMPLE or eTheme == X.UI.FRAME_THEME.FLOAT then
							raw:SetH(30)
							raw:Lookup('', ''):SetH(30)
						elseif eTheme == X.UI.FRAME_THEME.INTACT then
							raw:SetH(54)
							raw:Lookup('', ''):SetH(54)
						end
						if chkMaximize then
							chkMaximize:Enable(false)
						end
						if btnDrag and GetComponentProp(raw, 'bDragResize') then
							btnDrag:Hide()
						end
						X.ExecuteWithThis(raw, raw.OnFrameVisualStateChange, eNextVisualState)
					elseif eNextVisualState == X.UI.FRAME_VISUAL_STATE.NORMAL and eCurrentVisualState == X.UI.FRAME_VISUAL_STATE.MINIMIZE then -- 最小化恢复
						SetComponentProp(raw, 'eFrameVisualState', eNextVisualState)
						if wndTotal then
							wndTotal:Show()
						end
						if shaBg and not X.UI.IS_GLASSMORPHISM then
							shaBg:Show()
						end
						if imgGlassmorphism and X.UI.IS_GLASSMORPHISM then
							imgGlassmorphism:Show()
						end
						if imgGlassmorphismBg and X.UI.IS_GLASSMORPHISM then
							imgGlassmorphismBg:Show()
						end
						raw:SetH(GetComponentProp(raw, 'nFrameVisualStateRestoreHeight'))
						raw:Lookup('', ''):SetH(GetComponentProp(raw, 'nFrameVisualStateRestoreHeight'))
						if chkMaximize then
							chkMaximize:Enable(true)
						end
						if btnDrag and GetComponentProp(raw, 'bDragResize') then
							btnDrag:Show()
						end
						X.ExecuteWithThis(raw, raw.OnFrameVisualStateChange, eNextVisualState)
					elseif eNextVisualState == X.UI.FRAME_VISUAL_STATE.MAXIMIZE then -- 最大化
						SetComponentProp(raw, 'eFrameVisualState', eNextVisualState)
						local nScreenW, nScreeH = Station.GetClientSize()
						X.UI(raw)
							:Pos(0, 0)
							:Drag(false)
							:Size(nScreenW, nScreeH)
							:Event('UI_SCALED', 'FRAME_MAXIMIZE_RESIZE', function()
								local nScreenW, nScreeH = Station.GetClientSize()
								X.UI(raw):Pos(0, 0):Size(nScreenW, nScreeH)
							end)
						if btnDrag and GetComponentProp(raw, 'bDragResize') then
							btnDrag:Hide()
						end
						X.ExecuteWithThis(raw, raw.OnFrameVisualStateChange, eNextVisualState)
					elseif eNextVisualState == X.UI.FRAME_VISUAL_STATE.NORMAL and eCurrentVisualState == X.UI.FRAME_VISUAL_STATE.MAXIMIZE then -- 最大化恢复
						SetComponentProp(raw, 'eFrameVisualState', eNextVisualState)
						X.UI(raw)
							:Event('UI_SCALED', 'FRAME_MAXIMIZE_RESIZE', false)
							:Size(GetComponentProp(raw, 'nFrameVisualStateRestoreWidth'), GetComponentProp(raw, 'nFrameVisualStateRestoreHeight'))
							:Anchor(GetComponentProp(raw, 'tFrameVisualStateRestoreAnchor'))
							:Drag(true)
						if btnDrag and GetComponentProp(raw, 'bDragResize') then
							btnDrag:Show()
						end
						X.ExecuteWithThis(raw, raw.OnFrameVisualStateChange, eNextVisualState)
					end
				end
			end
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw and GetComponentType(raw) == 'WndFrame' then
			return GetComponentProp(raw, 'eFrameVisualState') or X.UI.FRAME_VISUAL_STATE.NORMAL
		end
	end
	return self
end

-- (self) Instance:FrameLeftControl(function[] aControl)
function OO:FrameLeftControl(aControl)
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		if GetComponentType(raw) == 'WndFrame' then
			local hContainer = raw:Lookup('WndContainer_FrameLeftControl')
			if hContainer and aControl then
				for i = hContainer:GetAllContentCount() - 1, 0, -1 do
					local hWnd = hContainer:LookupContent(i)
					if hWnd.bCustom then
						hWnd:Destroy()
					end
				end
				for _, fnRender in ipairs(aControl) do
					local hWnd = X.UI(hContainer):Append('WndWindow', { w = hContainer:GetH(), h = hContainer:GetH() }):Raw()
					hWnd.bCustom = true
					fnRender(hWnd)
				end
				hContainer:FormatAllContentPos()
			end
		end
	end
	return self
end

-- (self) Instance:FrameRightControl(function[] aControl)
function OO:FrameRightControl(aControl)
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		if GetComponentType(raw) == 'WndFrame' then
			local hContainer = raw:Lookup('WndContainer_FrameRightControl')
			if hContainer and aControl then
				for i = hContainer:GetAllContentCount() - 1, 0, -1 do
					local hWnd = hContainer:LookupContent(i)
					if hWnd.bCustom then
						hWnd:Destroy()
					end
				end
				for _, fnRender in ipairs(aControl) do
					local hWnd = X.UI(hContainer):Append('WndWindow', { w = hContainer:GetH(), h = hContainer:GetH() }):Raw()
					hWnd.bCustom = true
					fnRender(hWnd)
				end
				hContainer:FormatAllContentPos()
			end
		end
	end
	return self
end

-- (number) Instance:FontScale()
-- (self) Instance:FontScale(bool nScale)
function OO:FontScale(nScale)
	self:_checksum()
	if X.IsNumber(nScale) then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'TEXT')
			if raw then
				raw:SetFontScale(nScale)
			end
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw then
			raw = GetComponentElement(raw, 'TEXT')
			if raw then
				return raw:GetFontScale()
			end
		end
	end
end

-- (number) Instance:Scroll() -- get current scroll percentage (none scroll will return -1)
-- (self) Instance:Scroll(number nPercentage) -- set scroll percentage
-- (self) Instance:Scroll(function OnScrollBarPosChanged) -- bind scroll event handle
function OO:Scroll(mixed)
	self:_checksum()
	if mixed then -- set
		if X.IsNumber(mixed) then
			for _, raw in ipairs(self.raws) do
				raw = raw:Lookup('WndScrollBar')
				if raw and raw.GetStepCount and raw.SetScrollPos then
					raw:SetScrollPos(raw:GetStepCount() * mixed / 100)
				end
			end
		elseif X.IsFunction(mixed) then
			for _, raw in ipairs(self.raws) do
				local raw = raw:Lookup('WndScrollBar')
				if raw then
					X.UI(raw):UIEvent('OnScrollBarPosChanged', function()
						local nDistance = Station.GetMessageWheelDelta()
						local nScrollPos = raw:GetScrollPos()
						local nStepCount = raw:GetStepCount()
						if nStepCount == 0 then
							mixed(-1, nDistance)
						else
							mixed(nScrollPos * 100 / nStepCount, nDistance)
						end
					end)
				end
			end
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw then
			raw = raw:Lookup('WndScrollBar')
			if raw and raw.GetStepCount and raw.GetScrollPos then
				if raw:GetStepCount() == 0 then
					return -1
				else
					return raw:GetScrollPos() * 100 / raw:GetStepCount()
				end
			end
		end
	end
end

-- (number, number) Instance:Range()
-- (self) Instance:Range(nMin, nMax, nStep)
function OO:Range(nMin, nMax, nStep)
	self:_checksum()
	if X.IsNumber(nMin) and X.IsNumber(nMax) and nMax > nMin then
		nStep = nStep or nMax - nMin
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndSlider' then
				SetComponentProp(raw, 'nSliderMin', nMin)
				SetComponentProp(raw, 'nSliderMax', nMax)
				SetComponentProp(raw, 'nSliderStep', nStep)
				SetComponentProp(raw, 'nSliderStepVal', (nMax - nMin) / nStep)
				GetComponentElement(raw, 'SLIDER'):SetStepCount(nStep)
				GetComponentProp(raw, 'ResponseUpdateScroll')(true)
			end
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw and GetComponentType(raw) == 'WndSlider' then
			nMin = GetComponentProp(raw, 'nSliderMin')
			nMax = GetComponentProp(raw, 'nSliderMax')
			return nMin, nMax
		end
	end
end

-- (number, number) Instance:Value()
-- (self) Instance:Value(nValue)
function OO:Value(nValue)
	self:_checksum()
	if nValue then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndSlider' then
				local nMin = GetComponentProp(raw, 'nSliderMin')
				local nStepVal = GetComponentProp(raw, 'nSliderStepVal')
				GetComponentElement(raw, 'SLIDER'):SetScrollPos((nValue - nMin) / nStepVal)
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw and GetComponentType(raw) == 'WndSlider' then
			local nMin = GetComponentProp(raw, 'nSliderMin')
			local nStepVal = GetComponentProp(raw, 'nSliderStepVal')
			return nMin + GetComponentElement(raw, 'SLIDER'):GetScrollPos() * nStepVal
		end
	end
end


-- (boolean) Instance:Multiline()
-- (self) Instance:Multiline(bMultiLine)
function OO:Multiline(bMultiLine)
	self:_checksum()
	if X.IsBoolean(bMultiLine) then
		local element
		for _, raw in ipairs(self.raws) do
			element = GetComponentElement(raw, 'EDIT')
			if element then
				element:SetMultiLine(bMultiLine)
			end
			element = GetComponentElement(raw, 'TEXT')
			if element then
				element:SetMultiLine(bMultiLine)
				element:GetParent():FormatAllItemPos()
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			raw = GetComponentElement(raw, 'EDIT') or GetComponentElement(raw, 'TEXT')
			if raw then
				return raw:IsMultiLine()
			end
		end
	end
end

-- (self) Instance:Image(szImageAndFrame)
-- (self) Instance:Image(szImage, nFrame)
-- (self) Instance:Image(szImage, nNormalFrame, nOverFrame, nDownFrame, nDisableFrame)
-- (self) Instance:Image(el)
function OO:Image(szImage, nFrame, nOverFrame, nDownFrame, nDisableFrame)
	self:_checksum()
	if X.IsString(szImage) and X.IsNil(nFrame) then
		nFrame = tonumber((string.gsub(szImage, '.*%|(%d+)', '%1')))
		szImage = string.gsub(szImage, '%|.*', '')
	end
	if X.IsString(szImage) then
		szImage = X.StringReplaceW(szImage, '/', '\\')
		if X.IsNumber(nFrame) and X.IsNumber(nOverFrame) and X.IsNumber(nDownFrame) and X.IsNumber(nDisableFrame) then
			for _, raw in ipairs(self.raws) do
				raw = GetComponentElement(raw, 'BUTTON')
				if raw then
					raw:SetAnimatePath(szImage)
					raw:SetAnimateGroupNormal(nFrame)
					raw:SetAnimateGroupMouseOver(nOverFrame)
					raw:SetAnimateGroupMouseDown(nDownFrame)
					raw:SetAnimateGroupDisable(nDisableFrame)
				end
			end
		elseif X.IsString(szImage) and X.IsNumber(nFrame) then
			for _, raw in ipairs(self.raws) do
				local el = GetComponentElement(raw, 'IMAGE')
				if el then
					el:FromUITex(szImage, nFrame)
					el:GetParent():FormatAllItemPos()
				end
				el = GetComponentElement(raw, 'BOX')
				if el then
					el:SetExtentImage(szImage, nFrame)
				end
			end
		else
			for _, raw in ipairs(self.raws) do
				raw = GetComponentElement(raw, 'IMAGE')
				if raw then
					raw:FromTextureFile(szImage)
					raw:GetParent():FormatAllItemPos()
				end
			end
		end
	elseif X.IsElement(szImage) then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'IMAGE')
			if raw then
				if szImage:GetBaseType() == 'Wnd' then
					raw:FromWindow(szImage)
				else
					raw:FromItem(szImage)
				end
			end
		end
	end
	return self
end

-- (self) Instance:Frame(nFrame)
-- (number) Instance:Frame()
function OO:Frame(nFrame)
	self:_checksum()
	if nFrame then
		nFrame = tonumber(nFrame)
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'IMAGE')
			if raw then
				raw:SetFrame(nFrame)
				raw:GetParent():FormatAllItemPos()
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw and GetComponentType(raw) == 'Image' then
			return raw:GetFrame()
		end
	end
end

-- (self) Instance:ImageType(dwType)
function OO:ImageType(dwType)
	self:_checksum()
	if dwType then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'IMAGE')
			if raw then
				raw:SetImageType(dwType)
			end
		end
	else
		local raw = self.raws[1]
		if raw and GetComponentType(raw) == 'Image' then
			return raw:GetImageType()
		end
	end
	return self
end

-- (self) Instance:ItemInfo(...)
-- NOTICE：only for Box
function OO:ItemInfo(...)
	local data = X.Pack(...)
	for _, raw in ipairs(self.raws) do
		raw = GetComponentElement(raw, 'BOX')
		if raw then
			if X.IsEmpty(data) then
				UpdataItemBoxObject(raw)
			else
				local KItemInfo = GetItemInfo(data[2], data[3])
				if KItemInfo and KItemInfo.nGenre == ITEM_GENRE.BOOK and #data == 4 then -- 西山居BUG
					table.insert(data, 4, 99999)
				end
				local res, err, trace = X.XpCall(UpdataItemInfoBoxObject, raw, X.Unpack(data)) -- 防止itemtab不一样
				if not res then
					X.ErrorLog(err, X.NSFormatString('{$NS}#UI:ItemInfo'), trace)
				end
			end
		end
	end
	return self
end

-- (self) Instance:BoxInfo(nType, ...)
-- NOTICE：only for Box
function OO:BoxInfo(nType, ...)
	for _, raw in ipairs(self.raws) do
		raw = GetComponentElement(raw, 'BOX')
		if raw then
			if X.IsEmpty({ ... }) then
				UpdataItemBoxObject(raw)
			else
				local res, err, trace = X.XpCall(UpdateBoxObject, raw, nType, ...) -- 防止itemtab内外网不一样
				if not res then
					X.ErrorLog(err, X.NSFormatString('{$NS}#UI:BoxInfo'), trace)
				end
			end
		end
	end
	return self
end

-- (self) Instance:Icon(dwIcon)
-- (number) Instance:Icon()
-- NOTICE：only for Box
function OO:Icon(dwIconID)
	self:_checksum()
	if X.IsNumber(dwIconID) then
		local element
		for _, raw in ipairs(self.raws) do
			element = GetComponentElement(raw, 'BOX')
			if element then
				element:SetObject(UI_OBJECT_NOT_NEED_KNOWN)
				element:SetObjectIcon(dwIconID)
			end
			element = GetComponentElement(raw, 'IMAGE')
			if element then
				element:FromIconID(dwIconID)
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			raw = GetComponentElement(raw, 'BOX')
			if raw then
				return raw:GetObjectIcon()
			end
		end
	end
end

-- (self) Instance:HandleStyle(dwStyle)
function OO:HandleStyle(dwStyle)
	self:_checksum()
	if dwStyle then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'MAIN_HANDLE')
			if raw then
				raw:SetHandleStyle(dwStyle)
			end
		end
	end
	return self
end

-- (self) Instance:ContainerType(dwType)
function OO:ContainerType(dwType)
	self:_checksum()
	if dwType then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'CONTAINER')
			if raw then
				raw:SetContainerType(dwType)
			end
		end
	end
	return self
end

-- (self) Instance:EditType(dwType)
function OO:EditType(dwType)
	self:_checksum()
	if dwType then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'EDIT')
			if raw then
				raw:SetType(dwType)
			end
		end
	end
	return self
end

-- (self) UI:Limit(nLimit)
function OO:Limit(nLimit)
	self:_checksum()
	if nLimit then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'EDIT')
			if raw then
				raw:SetLimit(nLimit)
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			raw = GetComponentElement(raw, 'EDIT')
			if raw then
				return raw:GetLimit()
			end
		end
	end
end

-- (self) UI:Align(alignHorizontal, alignVertical)
function OO:Align(alignHorizontal, alignVertical)
	self:_checksum()
	if alignVertical or alignHorizontal then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'TEXT')
				or GetComponentElement(raw, 'EDIT')
				or GetComponentElement(raw, 'MAIN_HANDLE')
			if raw then
				if alignHorizontal and raw.SetHAlign then
					raw:SetHAlign(alignHorizontal)
				end
				if alignHorizontal and raw.SetPlaceholderHAlign then
					raw:SetPlaceholderHAlign(alignHorizontal)
				end
				if alignVertical and raw.SetVAlign then
					raw:SetVAlign(alignVertical)
				end
				if alignVertical and raw.SetPlaceholderVAlign then
					raw:SetPlaceholderVAlign(alignVertical)
				end
				if raw.FormatTextForDraw then
					raw:FormatTextForDraw()
				end
			end
		end
		return self
	else -- get
		local raw = self.raws[1]
		if raw then
			raw = GetComponentElement(raw, 'TEXT')
			if raw and raw.GetVAlign and raw.GetHAlign then
				return raw:GetVAlign(), raw:GetHAlign()
			end
		end
	end
end

-- (self) UI:SliderStyle(nSliderStyle)
function OO:SliderStyle(nSliderStyle)
	self:_checksum()
	local bShowPercentage = nSliderStyle == X.UI.SLIDER_STYLE.SHOW_PERCENT
	for _, raw in ipairs(self.raws) do
		if GetComponentType(raw) == 'WndSlider' then
			SetComponentProp(raw, 'bShowPercentage', bShowPercentage)
		end
	end
	return self
end

-- (self) UI:ButtonStyle(eButtonStyle)
function OO:ButtonStyle(...)
	self:_checksum()
	if select('#', ...) == 0 then
		local raw = self.raws[1]
		if raw then
			raw = GetComponentElement(raw, 'BUTTON')
			if raw and raw.GetAnimatePath and raw.GetAnimateGroupNormal then
				return GetButtonStyleName(raw)
			end
		end
	else
		local eButtonStyle = ...
		local tStyle = GetButtonStyleConfig(eButtonStyle) or BUTTON_STYLE_CONFIG.DEFAULT
		local function UpdateButtonBoxFont(raw)
			local btn = GetComponentElement(raw, 'BUTTON')
			local txt = GetComponentElement(raw, 'TEXT')
			if not btn or not txt then
				return
			end
			local nFont = nil
			local r, g, b = txt:GetFontColor()
			if not btn:IsEnabled() then
				nFont = tStyle.nDisableFont
			elseif GetComponentProp(raw, 'bDown') then
				nFont = tStyle.nMouseDownFont
			elseif GetComponentProp(raw, 'bIn') then
				nFont = tStyle.nMouseOverFont
			else
				nFont = tStyle.nNormalFont
			end
			if nFont then
				txt:SetFontScheme(nFont)
				txt:SetFontColor(r, g, b)
			end
		end
		for _, raw in ipairs(self.raws) do
			local btn = GetComponentElement(raw, 'BUTTON')
			if btn then
				btn:SetAnimatePath((X.StringReplaceW(tStyle.szImage, '/', '\\')))
				btn:SetAnimateGroupNormal(tStyle.nNormalGroup)
				btn:SetAnimateGroupMouseOver(tStyle.nMouseOverGroup)
				btn:SetAnimateGroupMouseDown(tStyle.nMouseDownGroup)
				btn:SetAnimateGroupDisable(tStyle.nDisableGroup)
				X.UI(btn)
					:UIEvent('OnMouseIn', 'LIB#UI_BUTTON_EVENT', function()
						SetComponentProp(raw, 'bIn', true)
						UpdateButtonBoxFont(raw)
					end)
					:UIEvent('OnMouseOut', 'LIB#UI_BUTTON_EVENT', function()
						SetComponentProp(raw, 'bIn', false)
						UpdateButtonBoxFont(raw)
					end)
					:UIEvent('OnLButtonDown', 'LIB#UI_BUTTON_EVENT', function()
						SetComponentProp(raw, 'bDown', true)
						UpdateButtonBoxFont(raw)
					end)
					:UIEvent('OnLButtonUp', 'LIB#UI_BUTTON_EVENT', function()
						SetComponentProp(raw, 'bDown', false)
						UpdateButtonBoxFont(raw)
					end)
				SetComponentSize(raw, tStyle.nWidth, tStyle.nHeight)
			end
		end
		return self
	end
end

-- 设置组件外观样式类型
-- @param {string} szAppearance 样式
function OO:Appearance(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local szAppearance = ...
		if X.IsString(szAppearance) then
			for _, raw in ipairs(self.raws) do
				SetComponentProp(raw, 'szAppearance', szAppearance)
				if GetComponentType(raw) == 'WndEditBox' then
					local nW, nH = raw:GetSize()
					SetComponentSize(raw, nW, nH)
				end
			end
		end
		return self
	else
		local raw = self.raws[1]
		if raw then
			return GetComponentProp(raw, 'szAppearance') or 'DEFAULT'
		end
	end
end

-- (self) UI:FormatChildrenPos()
function OO:FormatChildrenPos()
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		if GetComponentType(raw) == 'Handle' then
			raw:FormatAllItemPos()
		elseif GetComponentType(raw) == 'WndContainer' then
			raw:FormatAllContentPos()
		end
	end
	return self
end

-- (self) Instance:BringToTop()
function OO:BringToTop()
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		raw = GetComponentElement(raw, 'WND')
			or GetComponentElement(raw, 'MAIN_WINDOW')
		if raw then
			raw:BringToTop()
		end
	end
	return self
end

-- (self) Instance:BringToBottom()
function OO:BringToBottom()
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		raw = GetComponentElement(raw, 'WND')
			or GetComponentElement(raw, 'MAIN_WINDOW')
		if raw then
			local parent = raw:GetParent()
			if parent then
				local child = parent:GetFirstChild()
				if child then
					raw:ChangeRelation(child, true, false)
				end
			end
		end
	end
	return self
end

-----------------------------------------------------------
-- my ui events handle
-----------------------------------------------------------

-- 绑定Frame的事件
function OO:Event(szEvent, szKey, fnEvent)
	self:_checksum()
	if X.IsFunction(szKey) then
		szKey, fnEvent = nil, szKey
	end
	if X.IsString(szEvent) then
		if X.IsFunction(fnEvent) then -- register
			for _, raw in ipairs(self.raws) do
				if raw:GetType() == 'WndFrame' then
					local events = GetComponentProp(raw, 'onEvents')
					if not events then
						events = {}
						local onEvent = X.IsFunction(raw.OnEvent) and raw.OnEvent
						raw.OnEvent = function(e, ...)
							if onEvent then
								onEvent(e, ...)
							end
							if events[e] then
								for _, p in ipairs(events[e]) do
									p.fnAction(e, ...)
								end
							end
						end
						SetComponentProp(raw, 'events', events)
					end
					if not events[szEvent] then
						raw:RegisterEvent(szEvent)
						events[szEvent] = {}
					end
					if szKey then
						for i, p in X.ipairs_r(events[szEvent]) do
							if p.szKey == szKey then
								table.remove(events[szEvent], i)
							end
						end
					end
					table.insert(events[szEvent], { szKey = szKey, fnAction = fnEvent })
				end
			end
		elseif X.IsString(szKey) and fnEvent == false then -- unregister
			for _, raw in ipairs(self.raws) do
				if raw:GetType() == 'WndFrame' then
					local events = GetComponentProp(raw, 'events')
					if events and events[szEvent] then
						for i, p in X.ipairs_r(events[szEvent]) do
							if p.szKey == szKey then
								table.remove(events[szEvent], i)
							end
						end
					end
				end
			end
		end
	end
	return self
end

-- 绑定ele的UI事件
function OO:UIEvent(szEvent, szKey, fnEvent)
	self:_checksum()
	if X.IsFunction(szKey) then
		szKey, fnEvent = nil, szKey
	end
	if X.IsString(szEvent) then
		if X.IsFunction(fnEvent) then -- register
			for _, raw in ipairs(self.raws) do
				local uiEvents = GetComponentProp(raw, 'uiEvents')
				if not uiEvents then
					uiEvents = {}
					SetComponentProp(raw, 'uiEvents', uiEvents)
				end
				if not uiEvents[szEvent] then
					uiEvents[szEvent] = {}
					local onEvent = X.IsFunction(raw[szEvent]) and raw[szEvent]
					raw[szEvent] = function(...)
						if onEvent then
							onEvent(...)
						end
						local rets = {}
						for _, p in ipairs(uiEvents[szEvent]) do
							local res = X.Pack(p.fnAction(...))
							if X.Len(res) > 0 then
								if X.Len(rets) == 0 then
									rets = res
								--[[#DEBUG BEGIN]]
								else
									X.OutputDebugMessage(
										'UI:UIEvent#' .. szEvent .. ':' .. (p.szKey or 'Unnamed'),
										_L('Set return value failed, cause another hook has alreay take a returnval. [Path] %s', X.UI.GetTreePath(raw)),
										X.DEBUG_LEVEL.WARNING
									)
								--[[#DEBUG END]]
								end
							end
						end
						return X.Unpack(rets)
					end
					-- 特殊控件的一些HOOK
					if szEvent == 'OnEditChanged' and raw.GetText then
						local fnHookEvent = raw[szEvent]
						raw[szEvent] = function(...)
							local nFireType = GetComponentProp(raw, 'WNDEVENT_FIRETYPE') or WNDEVENT_FIRETYPE.AUTO
							local szText = raw:GetText()
							local szLastText = GetComponentProp(raw, 'LAST_TEXT')
							SetComponentProp(raw, 'WNDEVENT_FIRETYPE', nil)
							SetComponentProp(raw, 'LAST_TEXT', szText)
							if nFireType == WNDEVENT_FIRETYPE.PREVENT or (nFireType == WNDEVENT_FIRETYPE.AUTO and szText == szLastText) then
								return
							end
							return fnHookEvent(...)
						end
					end
				end
				table.insert(uiEvents[szEvent], { szKey = szKey, fnAction = fnEvent })
			end
		elseif X.IsString(szKey) and fnEvent == false then -- unregister
			for _, raw in ipairs(self.raws) do
				local uiEvents = GetComponentProp(raw, 'uiEvents')
				if uiEvents and uiEvents[szEvent] then
					for i, p in X.ipairs_r(uiEvents[szEvent]) do
						if p.szKey == szKey then
							table.remove(uiEvents[szEvent], i)
						end
					end
				end
			end
		end
	end
	return self
end

-- 设置 Frame 的 CustomMode 事件
-- (self) Instance:CustomLayout(string szTip)
-- (self) Instance:CustomLayout(function fnOnCustomLayout, string szPointType)
function OO:CustomLayout(arg0, arg1)
	self:_checksum()
	if X.IsString(arg0) then
		self:Filter('.WndFrame')
			:Event('ON_ENTER_CUSTOM_UI_MODE', function() UpdateCustomModeWindow(this, arg0, GetComponentProp(this, 'bPenetrable')) end)
			:Event('ON_LEAVE_CUSTOM_UI_MODE', function() UpdateCustomModeWindow(this, arg0, GetComponentProp(this, 'bPenetrable')) end)
	end
	if X.IsFunction(arg0) then
		self:Filter('.WndFrame')
			:Event('ON_ENTER_CUSTOM_UI_MODE', function() arg0(true , GetFrameAnchor(this, arg1)) end)
			:Event('ON_LEAVE_CUSTOM_UI_MODE', function() arg0(false, GetFrameAnchor(this, arg1)) end)
	end
	return self
end

-- breathe 设置Frame的breathe
-- (self) Instance:Breathe(function fnOnFrameBreathe)
function OO:Breathe(fnOnFrameBreathe)
	self:_checksum()
	if X.IsFunction(fnOnFrameBreathe) then
		for _, raw in ipairs(self.raws) do
			if raw:GetType() == 'WndFrame' then
				X.UI(raw):UIEvent('OnFrameBreathe', fnOnFrameBreathe)
			end
		end
	end
	return self
end

-- 弹出菜单
-- @param {table|function} menu 菜单或返回菜单的函数
function OO:Menu(menu)
	self:Click(function()
		local h = this:GetBaseType() == 'Wnd' and this:Lookup('', '') or this
		local nX, nY = h:GetAbsPos()
		local nW, nH = h:GetSize()
		local m = menu
		if X.IsFunction(m) then
			m = m()
		end
		if not X.IsTable(m) then
			return
		end
		m.x = nX
		m.y = nY + nH
		m.nMiniWidth = nW
		if m.bAlignWidth then
			m.nWidth = nW
		end
		m.bVisibleWhenHideUI = true
		m.szLayer = 'Topmost2'
		X.UI.PopupMenu(m)
	end)
	return self
end

-- 弹出左键菜单
-- @param {table|function} menu 菜单或返回菜单的函数
function OO:MenuLClick(menu)
	self:LClick(function()
		local h = this:Lookup('', '') or this
		local nX, nY = h:GetAbsPos()
		local nW, nH = h:GetSize()
		local m = menu
		if X.IsFunction(m) then
			m = m()
		end
		if not X.IsTable(m) then
			return
		end
		m.x = nX
		m.y = nY + nH
		m.nMiniWidth = nW
		if m.bAlignWidth then
			m.nWidth = nW
		end
		m.bVisibleWhenHideUI = true
		m.szLayer = 'Topmost2'
		X.UI.PopupMenu(m)
	end)
	return self
end

-- 弹出右键菜单
-- @param {table|function} menu 菜单或返回菜单的函数
function OO:MenuRClick(menu)
	self:RClick(function()
		local h = this:Lookup('', '') or this
		local nX, nY = h:GetAbsPos()
		local nW, nH = h:GetSize()
		local m = menu
		if X.IsFunction(m) then
			m = m()
		end
		if not X.IsTable(m) then
			return
		end
		m.x = nX
		m.y = nY + nH
		m.nMiniWidth = nW
		if m.bAlignWidth then
			m.nWidth = nW
		end
		m.bVisibleWhenHideUI = true
		m.szLayer = 'Topmost2'
		X.UI.PopupMenu(m)
	end)
	return self
end

-- 绑定鼠标单击事件，无参数或传入鼠标按键枚举值调用表示触发单击事件
-- same as jQuery.click()
-- @param {function(eButton: X.UI.MOUSE_BUTTON)} fnAction 鼠标单击事件回调函数
function OO:Click(fnClick)
	if X.IsFunction(fnClick) then
		self:LClick(fnClick)
		self:MClick(fnClick)
		self:RClick(fnClick)
	else
		local eButton = fnClick or X.UI.MOUSE_BUTTON.LEFT
		if eButton == X.UI.MOUSE_BUTTON.LEFT then
			self:LClick()
		elseif eButton == X.UI.MOUSE_BUTTON.MIDDLE then
			self:MClick()
		elseif eButton == X.UI.MOUSE_BUTTON.RIGHT then
			self:RClick()
		end
	end
	return self
end

-- 鼠标左键单击事件，无参数调用表示触发单击事件
-- same as jQuery.lclick()
-- @param {function(eButton: X.UI.MOUSE_BUTTON)} fnAction 鼠标单击事件回调函数
function OO:LClick(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local fnClick = ...
		if X.IsFunction(fnClick) then
			for _, raw in ipairs(self.raws) do
				local fnAction = function()
					if X.UI.IsDragDropOpened() or GetComponentProp(raw, 'bEnable') == false then
						return
					end
					X.ExecuteWithThis(raw, fnClick, X.UI.MOUSE_BUTTON.LEFT)
				end
				if GetComponentType(raw) == 'WndScrollHandleBox' then
					X.UI(GetComponentElement(raw, 'MAIN_HANDLE')):UIEvent('OnItemLButtonClick', fnAction)
				else
					local cmb = GetComponentElement(raw, 'COMBO_BOX')
					local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
					local itm = GetComponentElement(raw, 'ITEM')
					local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
					if cmb then
						X.UI(cmb):UIEvent('OnLButtonClick', fnAction)
					elseif wnd then
						X.UI(wnd):UIEvent('OnLButtonClick', fnAction)
					elseif itm then
						itm:RegisterEvent(16)
						X.UI(itm):UIEvent('OnItemLButtonClick', fnAction)
					elseif hdl then
						hdl:RegisterEvent(16)
						X.UI(hdl):UIEvent('OnItemLButtonClick', fnAction)
					end
				end
			end
		end
	else
		for _, raw in ipairs(self.raws) do
			local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
			local itm = GetComponentElement(raw, 'ITEM')
			if wnd and wnd.OnLButtonClick then
				X.CallWithThis(wnd, wnd.OnLButtonClick)
			end
			if itm and itm.OnItemLButtonClick then
				X.CallWithThis(itm, itm.OnItemLButtonClick)
			end
		end
	end
	return self
end

-- 鼠标右键单击事件，无参数调用表示触发单击事件
-- same as jQuery.mclick()
-- @param {function(eButton: X.UI.MOUSE_BUTTON)} fnAction 鼠标单击事件回调函数
	function OO:MClick(...)
		self:_checksum()
		if select('#', ...) > 0 then
			local fnClick = ...
			if X.IsFunction(fnClick) then
				for _, raw in ipairs(self.raws) do
					local fnAction = function()
						if X.UI.IsDragDropOpened() or GetComponentProp(raw, 'bEnable') == false then
							return
						end
						X.ExecuteWithThis(raw, fnClick, X.UI.MOUSE_BUTTON.MIDDLE)
					end
					if GetComponentType(raw) == 'WndScrollHandleBox' then
						X.UI(GetComponentElement(raw, 'MAIN_HANDLE')):UIEvent('OnItemMButtonClick', fnAction)
					else
						local cmb = GetComponentElement(raw, 'COMBO_BOX')
						local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
						local itm = GetComponentElement(raw, 'ITEM')
						local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
						if cmb then
							X.UI(cmb):UIEvent('OnMButtonClick', fnAction)
						elseif wnd then
							X.UI(wnd):UIEvent('OnMButtonClick', fnAction)
						elseif itm then
							itm:RegisterEvent(16)
							X.UI(itm):UIEvent('OnItemMButtonClick', fnAction)
						elseif hdl then
							hdl:RegisterEvent(16)
							X.UI(hdl):UIEvent('OnItemMButtonClick', fnAction)
						end
					end
				end
			end
		else
			for _, raw in ipairs(self.raws) do
				local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
				local itm = GetComponentElement(raw, 'ITEM')
				if wnd and wnd.OnMButtonClick then
					X.CallWithThis(wnd, wnd.OnMButtonClick)
				end
				if itm and itm.OnItemMButtonClick then
					X.CallWithThis(itm, itm.OnItemMButtonClick)
				end
			end
		end
		return self
	end

-- 鼠标右键单击事件，无参数调用表示触发单击事件
-- same as jQuery.rclick()
-- @param {function(eButton: X.UI.MOUSE_BUTTON)} fnAction 鼠标单击事件回调函数
function OO:RClick(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local fnClick = ...
		if X.IsFunction(fnClick) then
			for _, raw in ipairs(self.raws) do
				local fnAction = function()
					if X.UI.IsDragDropOpened() or GetComponentProp(raw, 'bEnable') == false then
						return
					end
					X.ExecuteWithThis(raw, fnClick, X.UI.MOUSE_BUTTON.RIGHT)
				end
				if GetComponentType(raw) == 'WndScrollHandleBox' then
					X.UI(GetComponentElement(raw, 'MAIN_HANDLE')):UIEvent('OnItemRButtonClick', fnAction)
				else
					local cmb = GetComponentElement(raw, 'COMBO_BOX')
					local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
					local itm = GetComponentElement(raw, 'ITEM')
					local hdl = GetComponentElement(raw, 'MAIN_HANDLE')
					if cmb then
						X.UI(cmb):UIEvent('OnRButtonClick', fnAction)
					elseif wnd then
						X.UI(wnd):UIEvent('OnRButtonClick', fnAction)
					elseif itm then
						itm:RegisterEvent(32)
						X.UI(itm):UIEvent('OnItemRButtonClick', fnAction)
					elseif hdl then
						hdl:RegisterEvent(32)
						X.UI(hdl):UIEvent('OnItemRButtonClick', fnAction)
					end
				end
			end
		end
	else
		for _, raw in ipairs(self.raws) do
			local wnd = GetComponentElement(raw, 'MAIN_WINDOW')
			local itm = GetComponentElement(raw, 'ITEM')
			if wnd and wnd.OnRButtonClick then
				X.CallWithThis(wnd, wnd.OnRButtonClick)
			end
			if itm and itm.OnItemRButtonClick then
				X.CallWithThis(itm, itm.OnItemRButtonClick)
			end
		end
	end
	return self
end

-- 行弹出菜单
-- @param {table|function} menu 菜单或返回菜单的函数
function OO:RowMenu(menu)
	self:RowClick(function(...)
		local h = this:Lookup('', '') or this
		local nX, nY = h:GetAbsPos()
		local nW, nH = h:GetSize()
		local m = menu
		if X.IsFunction(m) then
			m = m(...)
		end
		if not X.IsTable(m) then
			return
		end
		m.x = nX
		m.y = nY + nH
		m.nMiniWidth = nW
		if m.bAlignWidth then
			m.nWidth = nW
		end
		m.bVisibleWhenHideUI = true
		m.szLayer = 'Topmost2'
		X.UI.PopupMenu(m)
	end)
	return self
end

-- 行弹出左键菜单
-- @param {table|function} menu 菜单或返回菜单的函数
function OO:RowMenuLClick(menu)
	self:RowLClick(function(...)
		local h = this:Lookup('', '') or this
		local nX, nY = h:GetAbsPos()
		local nW, nH = h:GetSize()
		local m = menu
		if X.IsFunction(m) then
			m = m(...)
		end
		if not X.IsTable(m) then
			return
		end
		m.x = nX
		m.y = nY + nH
		m.nMiniWidth = nW
		if m.bAlignWidth then
			m.nWidth = nW
		end
		m.bVisibleWhenHideUI = true
		m.szLayer = 'Topmost2'
		X.UI.PopupMenu(m)
	end)
	return self
end

-- 行弹出右键菜单
-- @param {table|function} menu 菜单或返回菜单的函数
function OO:RowMenuRClick(menu)
	self:RowRClick(function(...)
		local h = this:Lookup('', '') or this
		local nX, nY = h:GetAbsPos()
		local nW, nH = h:GetSize()
		local m = menu
		if X.IsFunction(m) then
			m = m(...)
		end
		if not X.IsTable(m) then
			return
		end
		m.x = nX
		m.y = nY + nH
		m.nMiniWidth = nW
		if m.bAlignWidth then
			m.nWidth = nW
		end
		m.bVisibleWhenHideUI = true
		m.szLayer = 'Topmost2'
		X.UI.PopupMenu(m)
	end)
	return self
end

-- 行绑定鼠标单击事件
-- @param {function(eButton: X.UI.MOUSE_BUTTON, record: table, index: number)} fnAction 鼠标单击事件回调函数
function OO:RowClick(fnClick)
	if X.IsFunction(fnClick) then
		self:RowLClick(function(...) fnClick(X.UI.MOUSE_BUTTON.LEFT, ...) end)
		self:RowMClick(function(...) fnClick(X.UI.MOUSE_BUTTON.MIDDLE, ...) end)
		self:RowRClick(function(...) fnClick(X.UI.MOUSE_BUTTON.RIGHT, ...) end)
	end
	return self
end

-- 行鼠标左键单击事件
-- @param {function(record: table, index: number)} fnAction 鼠标单击事件回调函数
function OO:RowLClick(fnClick)
	self:_checksum()
	if X.IsFunction(fnClick) then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				local fnAction = function(...)
					if X.UI.IsDragDropOpened() or GetComponentProp(raw, 'bEnable') == false then
						return
					end
					X.ExecuteWithThis(raw, fnClick, ...)
				end
				SetComponentProp(raw, 'RowLClick', fnAction)
			end
		end
	end
	return self
end

-- 行鼠标中键单击事件
-- @param {function(record: table, index: number)} fnAction 鼠标单击事件回调函数
function OO:RowMClick(fnClick)
	self:_checksum()
	if X.IsFunction(fnClick) then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				local fnAction = function(...)
					if X.UI.IsDragDropOpened() or GetComponentProp(raw, 'bEnable') == false then
						return
					end
					X.ExecuteWithThis(raw, fnClick, ...)
				end
				SetComponentProp(raw, 'RowMClick', fnAction)
			end
		end
	end
	return self
end

-- 行鼠标右键单击事件
-- @param {function(record: table, index: number)} fnAction 鼠标单击事件回调函数
function OO:RowRClick(fnClick)
	self:_checksum()
	if X.IsFunction(fnClick) then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				local fnAction = function(...)
					if X.UI.IsDragDropOpened() or GetComponentProp(raw, 'bEnable') == false then
						return
					end
					X.ExecuteWithThis(raw, fnClick, ...)
				end
				SetComponentProp(raw, 'RowRClick', fnAction)
			end
		end
	end
	return self
end

-- 单元格绑定鼠标单击事件
-- @param {function(eButton: X.UI.MOUSE_BUTTON, record: table, index: number)} fnAction 鼠标单击事件回调函数
function OO:CellClick(fnClick)
	if X.IsFunction(fnClick) then
		self:CellLClick(function(...) fnClick(X.UI.MOUSE_BUTTON.LEFT, ...) end)
		self:CellMClick(function(...) fnClick(X.UI.MOUSE_BUTTON.MIDDLE, ...) end)
		self:CellRClick(function(...) fnClick(X.UI.MOUSE_BUTTON.RIGHT, ...) end)
	end
	return self
end

-- 单元格鼠标左键单击事件
-- @param {function(record: table, index: number)} fnAction 鼠标单击事件回调函数
function OO:CellLClick(fnClick)
	self:_checksum()
	if X.IsFunction(fnClick) then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				local fnAction = function(...)
					if X.UI.IsDragDropOpened() or GetComponentProp(raw, 'bEnable') == false then
						return
					end
					X.ExecuteWithThis(raw, fnClick, ...)
				end
				SetComponentProp(raw, 'CellLClick', fnAction)
			end
		end
	end
	return self
end

-- 单元格鼠标中键单击事件
-- @param {function(record: table, index: number)} fnAction 鼠标单击事件回调函数
function OO:CellMClick(fnClick)
	self:_checksum()
	if X.IsFunction(fnClick) then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				local fnAction = function(...)
					if X.UI.IsDragDropOpened() or GetComponentProp(raw, 'bEnable') == false then
						return
					end
					X.ExecuteWithThis(raw, fnClick, ...)
				end
				SetComponentProp(raw, 'CellMClick', fnAction)
			end
		end
	end
	return self
end

-- 单元格鼠标右键单击事件
-- @param {function(record: table, index: number)} fnAction 鼠标单击事件回调函数
function OO:CellRClick(fnClick)
	self:_checksum()
	if X.IsFunction(fnClick) then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				local fnAction = function(...)
					if X.UI.IsDragDropOpened() or GetComponentProp(raw, 'bEnable') == false then
						return
					end
					X.ExecuteWithThis(raw, fnClick, ...)
				end
				SetComponentProp(raw, 'CellRClick', fnAction)
			end
		end
	end
	return self
end

-- complete 加载完成事件
-- :Complete(fnOnComplete) 绑定
function OO:Complete(fnOnComplete)
	self:_checksum()
	if fnOnComplete then
		for _, raw in ipairs(self.raws) do
			local wnd = GetComponentElement(raw, 'WEB_PAGE')
			if wnd then
				X.UI(wnd):UIEvent('OnDocumentComplete', fnOnComplete)
			end
			local wnd = GetComponentElement(raw, 'WEB_CEF')
			if wnd then
				X.UI(wnd):UIEvent('OnWebLoadEnd', fnOnComplete)
			end
		end
	end
	return self
end

-- 鼠标悬停事件
-- same as jQuery.hover()
-- @param {function(bIn: boolean): void} fnAction 鼠标悬停事件响应函数
function OO:Hover(fnAction)
	self:_checksum()
	if fnAction then
		for _, raw in ipairs(self.raws) do
			local wnd = GetComponentElement(raw, 'EDIT') or GetComponentElement(raw, 'MAIN_WINDOW')
			local itm = GetComponentElement(raw, 'ITEM')
			if wnd then
				X.UI(wnd):UIEvent('OnMouseIn', function() fnAction(true) end)
				X.UI(wnd):UIEvent('OnMouseOut', function() fnAction(false) end)
			elseif itm then
				itm:RegisterEvent(256)
				X.UI(itm):UIEvent('OnItemMouseIn', function() fnAction(true) end)
				X.UI(itm):UIEvent('OnItemMouseOut', function() fnAction(false) end)
			end
		end
	end
	return self
end

-- 行鼠标悬停事件
-- @param {function(bIn: boolean): void} fnAction 行鼠标悬停事件响应函数
function OO:RowHover(fnAction)
	self:_checksum()
	if fnAction then
		for _, raw in ipairs(self.raws) do
			if GetComponentType(raw) == 'WndTable' then
				SetComponentProp(raw, 'OnRowHover', fnAction)
			end
		end
	end
	return self
end

-- 鼠标悬停提示
-- @ref OutputAdvanceTip
function OO:Tip(props)
	return self:Hover(
		function(bIn)
			if not bIn then
				HideAdvanceTip(props)
				return
			end
			OutputAdvanceTip(props)
		end
	)
end

-- 行鼠标悬停提示
-- @ref OutputAdvanceTip
function OO:RowTip(props)
	local props = X.Clone(props)
	if not X.IsTable(props) then
		props = { render = props }
	end
	return self:RowHover(
		function(bIn, rec, nIndex, rect)
			if not bIn then
				HideAdvanceTip(props)
				return
			end
			props.rect = rect
			OutputAdvanceTip(props, rec, nIndex)
		end
	)
end

-- --------------------------------------------
-- 绑定复选框状态变化： function(fnAction): self
-- @param {function(bChecked: boolean): void} fnAction 复选框状态变化回调函数
-- @return {self} 返回自身
-- --------------------------------------------
-- 获取是否已勾选： function(): boolean
-- @return {boolean} 返回是否已勾选
-- --------------------------------------------
-- 勾选/取消勾选： function(bool bChecked): self
-- @param {boolean} bChecked 是否勾选
-- @return {self} 返回自身
-- --------------------------------------------
function OO:Check(fnAction, eEventFireType)
	self:_checksum()
	if X.IsFunction(fnAction) then
		for _, raw in ipairs(self.raws) do
			local chk = GetComponentElement(raw, 'CHECKBOX')
			if chk then
				if X.IsFunction(fnAction) then
					X.UI(chk):UIEvent('OnCheckBoxCheck', function() fnAction(true) end)
					X.UI(chk):UIEvent('OnCheckBoxUncheck', function() fnAction(false) end)
				end
			end
		end
		return self
	elseif X.IsBoolean(fnAction) then
		for _, raw in ipairs(self.raws) do
			local chk = GetComponentElement(raw, 'CHECKBOX')
			if chk then
				if eEventFireType then
					chk:Check(fnAction, eEventFireType)
				else
					chk:Check(fnAction)
				end
			end
		end
		return self
	elseif X.IsNil(fnAction) then
		local raw = self.raws[1]
		if raw then
			local chk = GetComponentElement(raw, 'CHECKBOX')
			if chk then
				return chk:IsCheckBoxChecked()
			end
		end
	--[[#DEBUG BEGIN]]
	else
		X.OutputDebugMessage('ERROR UI:Check', 'fnAction: ' .. type(fnAction), X.DEBUG_LEVEL.ERROR)
	--[[#DEBUG END]]
	end
end

-- change 输入框文字变化
-- :Change(fnOnChange) 绑定
-- :Change()   调用处理函数
function OO:Change(fnOnChange)
	self:_checksum()
	if X.IsFunction(fnOnChange) then
		for _, raw in ipairs(self.raws) do
			local edt = GetComponentElement(raw, 'EDIT')
			if edt then
				X.UI(edt):UIEvent('OnEditChanged', function() X.ExecuteWithThis(raw, fnOnChange, edt:GetText()) end)
			end
			if GetComponentType(raw) == 'WndSlider' then
				table.insert(GetComponentProp(raw, 'onChangeEvents'), fnOnChange)
			end
		end
		return self
	else
		for _, raw in ipairs(self.raws) do
			local edt = GetComponentElement(raw, 'EDIT')
			if edt and edt.OnEditChanged then
				X.CallWithThis(edt, edt.OnEditChanged, raw)
			end
			if GetComponentType(raw) == 'WndSlider' then
				local sld = GetComponentElement(raw, 'SLIDER')
				if sld and sld.OnScrollBarPosChanged then
					X.CallWithThis(sld, sld.OnScrollBarPosChanged, raw)
				end
			end
		end
		return self
	end
end

-- 输入框特殊键按下
-- @param {function(nMessageKey: number, szKey: string): number|void} fnOnSpecialKeyDown 绑定的处理函数
function OO:OnSpecialKeyDown(...)
	self:_checksum()
	if select('#', ...) > 0 then
		local fnOnSpecialKeyDown = ...
		if not X.IsFunction(fnOnSpecialKeyDown) then
			fnOnSpecialKeyDown = nil
		end
		for _, raw in ipairs(self.raws) do
			SetComponentProp(raw, 'OnSpecialKeyDown', fnOnSpecialKeyDown)
		end
	end
	return self
end

function OO:Navigate(szURL)
	self:_checksum()
	for _, raw in ipairs(self.raws) do
		raw = GetComponentElement(raw, 'WEB')
		if raw then
			raw:Navigate(szURL)
		end
	end
	return self
end

-- focus （输入框）获得焦点 -- 好像只有输入框能获得焦点
-- :Focus(fnOnSetFocus) 绑定
-- :Focus()   使获得焦点
function OO:Focus(fnOnSetFocus)
	self:_checksum()
	if fnOnSetFocus then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'EDIT')
			if raw then
				X.UI(raw):UIEvent('OnSetFocus', function()
					X.CallWithThis(raw, fnOnSetFocus)
				end)
			end
		end
		return self
	else
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'EDIT')
			if raw then
				Station.SetFocusWindow(raw)
				break
			end
		end
		return self
	end
end

-- blur （输入框）失去焦点
-- :Blur(fnOnKillFocus) 绑定
-- :Blur()   使获得焦点
function OO:Blur(fnOnKillFocus)
	self:_checksum()
	if fnOnKillFocus then
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'EDIT')
			if raw then
				X.UI(raw):UIEvent('OnKillFocus', function() X.ExecuteWithThis(raw, fnOnKillFocus) end)
			end
		end
		return self
	else
		for _, raw in ipairs(self.raws) do
			raw = GetComponentElement(raw, 'EDIT')
			if raw then
				Station.SetFocusWindow()
				break
			end
		end
		return self
	end
end

-------------------------------------
-- UI object class
-------------------------------------
setmetatable(X.UI, {
	__call = function (t, ...) return OO:ctor(...) end,
	__tostring = function(t) return X.NSFormatString('{$NS}_UI (class prototype)') end,
})
X.RegisterEvent(X.NSFormatString('{$NS}_BASE_LOADING_END'), function()
	X.NSLock(X.UI, X.NSFormatString('{$NS}_UI (class prototype)'), {
		__call = function (t, ...) return OO:ctor(...) end,
	})
end)

-- TODO: 重构，注册组件
-- function X.UI.RegisterComponent(GetComponent)
-- 	local szComponentName, Component = GetComponent(ComponentBase, GetComponentProp, SetComponentProp)
-- 	for k, v in pairs(Component) do
-- 		if not OO[k] then
-- 			OO[k] = function(self, ...)
-- 				for _, raw in ipairs(self.raws) do
-- 					local fnAction = REGISTERED_COMPONENT[GetComponentType(raw)]
-- 					if fnAction then
-- 						fnAction = fnAction[k]
-- 					end
-- 					local res = X.Pack(fnAction(raw, ...))
-- 					if X.Len(res) > 0 then
-- 						return X.Unpack(res)
-- 					end
-- 				end
-- 				return self
-- 			end
-- 		end
-- 	end
-- 	REGISTERED_COMPONENT[szComponentName] = Component
-- end

---------------------------------------------------
-- 窗体操作
---------------------------------------------------

---@class UI_CreateFrame_Options @创建窗体参数
---@field level '"Normal" | "Lowest" | "Topmost" | "Normal1" | "Lowest1" | "Topmost1" | "Normal2" | "Lowest2" | "Topmost2"' @层级
---@field theme X.UI.FRAME_THEME @窗体样式
---@field esc boolean @是否注册全局ESC关闭窗体
---@field close boolean @是否显示关闭按钮
---@field minimize boolean @是否允许最小化
---@field maximize boolean @是否允许最大化
---@field minWidth number @最小宽度
---@field minHeight number @最小高度
---@field resize boolean @是否允许拖拽改变大小
---@field alpha number @窗体透明度
---@field anchor FrameAnchor @窗体位置
---@field onSettingsClick function @设置按钮回调，不传不显示
---@field onFrameVisualStateChange function @窗体最大最小化状态发生变化时回调

-- 创建窗体
---@param szName string @要创建的窗体名字
---@param opt? UI_CreateFrame_Options @参数
function X.UI.CreateFrame(szName, opt)
	if not X.IsTable(opt) then
		opt = {}
	end
	if not (
		opt.level == 'Normal'  or opt.level == 'Lowest'  or opt.level == 'Topmost'  or
		opt.level == 'Normal1' or opt.level == 'Lowest1' or opt.level == 'Topmost1' or
		opt.level == 'Normal2' or opt.level == 'Lowest2' or opt.level == 'Topmost2'
	) then
		opt.level = 'Normal'
	end
	if not opt.theme then
		opt.theme = X.UI.FRAME_THEME.INTACT
	end
	-- calc ini file path
	local szIniFile = X.PACKET_INFO.UI_COMPONENT_ROOT .. 'WndFrame.ini'
	if opt.theme == X.UI.FRAME_THEME.EMPTY then
		szIniFile = X.PACKET_INFO.UI_COMPONENT_ROOT .. 'WndFrameEmpty.ini'
	end

	-- close and reopen exist frame
	local frm = Station.SearchFrame(szName)
	if frm then
		X.UI.CloseFrame(frm)
	end
	frm = X.UI.OpenFrame(szIniFile, szName)
	if opt.theme == X.UI.FRAME_THEME.INTACT then
		frm:Lookup('', 'Image_Icon'):FromUITex(X.PACKET_INFO.LOGO_IMAGE, X.PACKET_INFO.LOGO_MAIN_FRAME)
	end
	frm:ChangeRelation(opt.level)
	if frm:Lookup('', 'Text_Title') then
		frm:Lookup('', 'Text_Title'):SetText('')
	end
	if frm:Lookup('', 'Text_Author') then
		frm:Lookup('', 'Text_Author'):SetText('')
	end
	frm:Show()
	local ui = X.UI(frm)
	local function RemoveFrame()
		if X.UI(frm):Remove():Count() == 0 then
			PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
			return true
		end
		return false
	end
	-- init frame
	if opt.esc then
		X.RegisterEsc(
			'Frame_Close_' .. szName,
			function() return true end,
			function()
				if RemoveFrame() then
					X.RegisterEsc('Frame_Close_' .. szName, false)
				end
			end
		)
	end
	SetComponentProp(frm, 'theme', opt.theme)
	if opt.theme == X.UI.FRAME_THEME.SIMPLE then
		SetComponentProp(frm, 'minWidth', opt.minWidth or 100)
		SetComponentProp(frm, 'minHeight', opt.minHeight or 50)
	elseif opt.theme == X.UI.FRAME_THEME.FLOAT then
		SetComponentProp(frm, 'minWidth', opt.minWidth or 100)
		SetComponentProp(frm, 'minHeight', opt.minHeight or 50)
	elseif opt.theme == X.UI.FRAME_THEME.INTACT then
		SetComponentProp(frm, 'minWidth', opt.minWidth or 128)
		SetComponentProp(frm, 'minHeight', opt.minHeight or 160)
	end
	if opt.theme ~= X.UI.FRAME_THEME.EMPTY then
		-- 琉璃风格
		if X.UI.IS_GLASSMORPHISM then
			frm:Lookup('', 'Handle_ClassicBg_Intact'):Hide()
			frm:Lookup('', 'Handle_ClassicBg_Simple'):Hide()
			frm:Lookup('', 'Handle_ClassicBg_Float'):Hide()
			frm:Lookup('', 'Text_Title'):SetRelY(0)
			frm:Lookup('WndContainer_FrameRightControl'):SetRelY(0)
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Close/Btn_Close'):SetSize(30, 30)
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Close/Btn_Close'):SetRelPos(-7, 2)
			X.UI.SetButtonUITex(
				frm:Lookup('WndContainer_FrameRightControl/Wnd_Close/Btn_Close'),
				'ui\\Image\\UItimate\\UICommon\\Button.UITex',
				35,
				36,
				37,
				38
			)
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Maximize/CheckBox_Maximize'):SetRelY(7)
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Maximize/CheckBox_Maximize'):SetAlpha(255)
			X.UI.SetCheckBoxUITex(
				frm:Lookup('WndContainer_FrameRightControl/Wnd_Maximize/CheckBox_Maximize'),
				'ui\\Image\\Common\\DialogueLabel.UITex',
				32,
				33,
				33,
				32,
				35,
				34,
				34,
				32
			)
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Minimize/CheckBox_Minimize'):SetAlpha(255)
			X.UI.SetCheckBoxUITex(
				frm:Lookup('WndContainer_FrameRightControl/Wnd_Minimize/CheckBox_Minimize'),
				'ui\\Image\\UItimate\\UICommon\\Button.UITex',
				177,
				178,
				179,
				180,
				177,
				178,
				179,
				180
			)
			X.UI.SetButtonUITex(
				frm:Lookup('Btn_Drag'),
				'ui\\Image\\UItimate\\UICommon\\Button.UITex',
				141,
				142,
				143,
				144
			)
		elseif opt.theme == X.UI.FRAME_THEME.INTACT then
			frm:Lookup('', 'Handle_GlassmorphismBg'):Hide()
			frm:Lookup('', 'Handle_ClassicBg_Simple'):Hide()
			frm:Lookup('', 'Handle_ClassicBg_Float'):Hide()
		elseif opt.theme == X.UI.FRAME_THEME.SIMPLE then
			frm:Lookup('', 'Handle_GlassmorphismBg'):Hide()
			frm:Lookup('', 'Handle_ClassicBg_Intact'):Hide()
			frm:Lookup('', 'Handle_ClassicBg_Float'):Hide()
		elseif opt.theme == X.UI.FRAME_THEME.FLOAT then
			frm:Lookup('', 'Handle_GlassmorphismBg'):Hide()
			frm:Lookup('', 'Handle_ClassicBg_Intact'):Hide()
			frm:Lookup('', 'Handle_ClassicBg_Simple'):Hide()
		end
		if not X.UI.IS_GLASSMORPHISM and (opt.theme == X.UI.FRAME_THEME.SIMPLE or opt.theme == X.UI.FRAME_THEME.FLOAT) then
			frm:Lookup('', 'Text_Title'):SetRelY(0)
			frm:Lookup('WndContainer_FrameLeftControl'):SetRelY(0)
			frm:Lookup('WndContainer_FrameRightControl'):SetRelY(0)
		end
		-- left control buttons
		if not opt.onSettingsClick then
			frm:Lookup('WndContainer_FrameLeftControl/Wnd_Setting'):Destroy()
		else
			frm:Lookup('WndContainer_FrameLeftControl/Wnd_Setting/Btn_Setting').OnLButtonClick = opt.onSettingsClick
		end
		-- right control buttons
		if opt.close == false then
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Close'):Destroy()
		else
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Close/Btn_Close').OnLButtonClick = function()
				RemoveFrame()
			end
		end
		if not opt.maximize then
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Maximize'):Destroy()
		else
			local hDBClick = frm:Lookup('', 'Handle_DBClick')
				or frm:Lookup('Wnd_Total', 'Handle_DBClick')
			hDBClick.OnItemLButtonDBClick = function()
				frm:Lookup('WndContainer_FrameRightControl/Wnd_Maximize/CheckBox_Maximize'):ToggleCheck()
			end
			frm:Lookup('WndContainer_FrameLeftControl').OnLButtonDBClick = function()
				frm:Lookup('WndContainer_FrameRightControl/Wnd_Maximize/CheckBox_Maximize'):ToggleCheck()
			end
			frm:Lookup('WndContainer_FrameRightControl').OnLButtonDBClick = function()
				frm:Lookup('WndContainer_FrameRightControl/Wnd_Maximize/CheckBox_Maximize'):ToggleCheck()
			end
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Maximize/CheckBox_Maximize').OnCheckBoxCheck = function()
				X.UI(frm):FrameVisualState(X.UI.FRAME_VISUAL_STATE.MAXIMIZE)
			end
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Maximize/CheckBox_Maximize').OnCheckBoxUncheck = function()
				X.UI(frm):FrameVisualState(X.UI.FRAME_VISUAL_STATE.NORMAL)
			end
		end
		if not opt.minimize then
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Minimize'):Destroy()
		else
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Minimize/CheckBox_Minimize').OnCheckBoxCheck = function()
				X.UI(frm):FrameVisualState(X.UI.FRAME_VISUAL_STATE.MINIMIZE)
			end
			frm:Lookup('WndContainer_FrameRightControl/Wnd_Minimize/CheckBox_Minimize').OnCheckBoxUncheck = function()
				X.UI(frm):FrameVisualState(X.UI.FRAME_VISUAL_STATE.NORMAL)
			end
		end
		if opt.onFrameVisualStateChange then
			X.UI(frm):UIEvent('OnFrameVisualStateChange', opt.onFrameVisualStateChange)
		end
		-- drag resize button
		local hBtnDrag = frm:Lookup('Btn_Drag')
		if not opt.resize then
			hBtnDrag:Hide()
		else
			SetComponentProp(frm, 'bDragResize', true)
			if X.UI.IS_GLASSMORPHISM then
				hBtnDrag.nVisualOffsetX = 0
				hBtnDrag.nVisualOffsetY = 0
			elseif opt.theme == X.UI.FRAME_THEME.INTACT then
				hBtnDrag.nVisualOffsetX = -8
				hBtnDrag.nVisualOffsetY = -8
			elseif opt.theme == X.UI.FRAME_THEME.SIMPLE then
				hBtnDrag.nVisualOffsetX = -1
				hBtnDrag.nVisualOffsetY = -1
			elseif opt.theme == X.UI.FRAME_THEME.FLOAT then
				hBtnDrag.nVisualOffsetX = 0
				hBtnDrag.nVisualOffsetY = 0
			end
			hBtnDrag.OnMouseEnter = function()
				Cursor.Switch(CURSOR.LEFTTOP_RIGHTBOTTOM)
			end
			hBtnDrag.OnMouseLeave = function()
				Cursor.Switch(CURSOR.NORMAL)
			end
			hBtnDrag.OnDragButton = function()
				local nX, nY = Station.GetMessagePos()
				local nClientW, nClientH = Station.GetClientSize()
				local nFrameX, nFrameY = frm:GetRelPos()
				local nW, nH = nX - nFrameX + this.nOffsetX, nY - nFrameY + this.nOffsetY
				nW = math.min(nW, nClientW - nFrameX) -- frame size should not larger than client size
				nH = math.min(nH, nClientH - nFrameY)
				nW = math.max(nW, GetComponentProp(frm, 'minWidth') or 0) -- frame size must larger than its min size
				nH = math.max(nH, GetComponentProp(frm, 'minHeight') or 0)
				this:SetRelPos(nW - this:GetW(), nH - this:GetH())
				frm:Lookup('Wnd_DragBg', 'Shadow_DragBg'):SetSize(nW - this.nVisualOffsetX, nH - this.nVisualOffsetY)
			end
			hBtnDrag.OnDragButtonBegin = function()
				-- 由于开始拖拽位置不可能完全是按钮右下角，所以需要记录按下时相对于按钮右下角的偏移，让拖拽手感更加平滑
				local nX, nY = Station.GetMessagePos()
				this.nOffsetX = this:GetAbsX() + this:GetW() - nX
				this.nOffsetY = this:GetAbsY() + this:GetH() - nY
				frm:Lookup('Wnd_DragBg'):Show()
				frm:Lookup('', ''):Hide()
				frm:Lookup('Wnd_Total'):Hide()
				frm:Lookup('WndContainer_FrameLeftControl'):Hide()
				frm:Lookup('WndContainer_FrameRightControl'):Hide()
			end
			hBtnDrag.OnDragButtonEnd = function()
				frm:Lookup('Wnd_DragBg'):Hide()
				frm:Lookup('', ''):Show()
				frm:Lookup('Wnd_Total'):Show()
				frm:Lookup('WndContainer_FrameLeftControl'):Show()
				frm:Lookup('WndContainer_FrameRightControl'):Show()
				local nW = this:GetRelX() + this:GetW() - this.nVisualOffsetX
				local nH = this:GetRelY() + this:GetH() - this.nVisualOffsetY
				nW = math.max(nW, GetComponentProp(frm, 'minWidth') or 0)
				nH = math.max(nH, GetComponentProp(frm, 'minHeight') or 0)
				X.UI(frm):Size(nW, nH)
			end
			hBtnDrag:RegisterLButtonDrag()
		end
		frm:Lookup('WndContainer_FrameLeftControl'):FormatAllContentPos()
		frm:Lookup('WndContainer_FrameRightControl'):FormatAllContentPos()
	end
	if not opt.anchor and not (opt.x and opt.y) then
		opt.anchor = { s = 'CENTER', r = 'CENTER', x = 0, y = 0 }
	end
	if not opt.w then
		opt.w = frm:GetW()
	end
	if not opt.h then
		opt.h = frm:GetH()
	end
	return ApplyUIArguments(ui, opt)
end

---打开窗口，可以规避游戏退出时创建界面带来的虚拟机异常问题
---@param szPath string @INI文件路径
---@param szName string @窗口名称
---@return userdata | nil @打开成功返回窗口句柄，打开失败返回 nil
function X.UI.OpenFrame(szPath, szName)
	if X.IsGameExiting() then
		return
	end
	if not szName then
		szName = szPath:gsub('.*/', ''):gsub('.*\\', ''):gsub('%.ini$', '')
	end
	return Wnd.OpenWindow(szPath, szName)
end

---关闭窗口
function X.UI.CloseFrame(...)
	return Wnd.CloseWindow(...)
end

--[[#DEBUG BEGIN]]X.ReportModuleLoading(MODULE_PATH, 'FINISH')--[[#DEBUG END]]
