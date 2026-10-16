class_name ControlTheme
extends RefCounted
## Brand styling for the engine's standard control types, added to the shared
## GameVisualStyle theme. Every type is set explicitly because the app theme is
## merged into the engine default theme, where each type has its own dark entry.
## Existing GameVisualStyle roles and variations are never changed here.

const S := preload("res://scripts/presentation/game_visual_style.gd")
const ICON_CHECKBOX_ON = preload("res://assets/ui/checkbox_checked.svg")
const ICON_CHECKBOX_OFF = preload("res://assets/ui/checkbox_unchecked.svg")
const ICON_RADIO_ON = preload("res://assets/ui/radio_checked.svg")
const ICON_RADIO_OFF = preload("res://assets/ui/radio_unchecked.svg")
const ICON_TOGGLE_ON = preload("res://assets/ui/toggle_on.svg")
const ICON_TOGGLE_OFF = preload("res://assets/ui/toggle_off.svg")
const ICON_GRABBER = preload("res://assets/ui/slider_grabber.svg")
const ICON_GRABBER_HIGHLIGHT = preload("res://assets/ui/slider_grabber_highlight.svg")
const ICON_ARROW_DOWN = preload("res://assets/ui/arrow_down.svg")
const ICON_ARROW_RIGHT = preload("res://assets/ui/arrow_right.svg")

## Vertical padding that brings a 20 px text line to the 48 px minimum target.
const _TARGET_PAD := 12

static func apply(theme: Theme) -> void:
	_apply_text(theme)
	for type in [&"Button", &"OptionButton", &"MenuButton"]:
		_apply_button(theme, type, S.GAME_SURFACE, S.TEXT_PRIMARY)
	theme.set_icon("arrow", "OptionButton", ICON_ARROW_DOWN)
	theme.set_constant("arrow_margin", "OptionButton", S.SPACING[2])
	_apply_toggles(theme)
	_apply_panels(theme)
	_apply_tabs(theme)
	_apply_sliders(theme)
	_apply_scrollbars(theme)
	_apply_line_edit(theme)
	_apply_popup(theme)
	_apply_lists(theme)
	_apply_dialogs(theme)
	_apply_progress(theme)
	_apply_hero_roles(theme)
	_apply_level_select_roles(theme)

static func _apply_text(theme: Theme) -> void:
	theme.set_color("font_color", "Label", S.TEXT_PRIMARY)
	theme.set_color("default_color", "RichTextLabel", S.TEXT_PRIMARY)
	theme.set_font("normal_font", "RichTextLabel", S.SUPPORTING_FONT)
	theme.set_font("bold_font", "RichTextLabel", S.SECONDARY_HEADING_FONT)
	# The brand faces ship without italics; emphasis uses weight instead of a faux slant.
	theme.set_font("italics_font", "RichTextLabel", S.UI_FONT)
	theme.set_font("bold_italics_font", "RichTextLabel", S.SECONDARY_HEADING_FONT)
	theme.set_font_size("normal_font_size", "RichTextLabel", 20)
	theme.set_font_size("bold_font_size", "RichTextLabel", 20)
	theme.set_stylebox("separator", "HSeparator", _line(S.SURFACE_BORDER, 1, false))
	theme.set_stylebox("separator", "VSeparator", _line(S.SURFACE_BORDER, 1, true))
	theme.set_stylebox("panel", "TooltipPanel", _box(S.TOOLTIP_BACKGROUND, S.RADIUS_SMALL, S.TOOLTIP_BACKGROUND))
	theme.set_color("font_color", "TooltipLabel", S.TEXT_ON_ACCENT)
	theme.set_font("font", "TooltipLabel", S.SUPPORTING_FONT)
	theme.set_font_size("font_size", "TooltipLabel", 18)

## Light surface button: hover tints ember, press darkens one step with a 1 px
## nudge, focus draws the ember ring outside the bounds. 48 px tall at 20 px text.
static func _apply_button(theme: Theme, type: StringName, background: Color, foreground: Color) -> void:
	theme.set_font("font", type, S.UI_FONT)
	theme.set_font_size("font_size", type, 20)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		theme.set_color(state, type, foreground)
	theme.set_color("font_disabled_color", type, S.INK_500)
	theme.set_stylebox("normal", type, _box(background, S.RADIUS_SMALL, S.SURFACE_BORDER))
	theme.set_stylebox("hover", type, _box(S.EMBER_50, S.RADIUS_SMALL, S.ARROW_HOVER))
	var pressed := _box(S.INK_100, S.RADIUS_SMALL, S.GAME_ACCENT)
	pressed.content_margin_top = _TARGET_PAD + 1
	pressed.content_margin_bottom = _TARGET_PAD - 1
	theme.set_stylebox("pressed", type, pressed)
	theme.set_stylebox("hover_pressed", type, pressed)
	theme.set_stylebox("disabled", type, _box(S.CREAM_DEEP, S.RADIUS_SMALL, S.SURFACE_BORDER))
	theme.set_stylebox("focus", type, _focus())

static func _apply_toggles(theme: Theme) -> void:
	for type in [&"CheckBox", &"CheckButton"]:
		theme.set_font("font", type, S.SUPPORTING_FONT)
		theme.set_font_size("font_size", type, 20)
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
			theme.set_color(state, type, S.TEXT_PRIMARY)
		theme.set_color("font_disabled_color", type, S.INK_500)
		var plain := _empty()
		theme.set_stylebox("normal", type, plain)
		theme.set_stylebox("pressed", type, plain)
		theme.set_stylebox("disabled", type, plain)
		var hover := _box(S.EMBER_50, S.RADIUS_SMALL, S.EMBER_50)
		theme.set_stylebox("hover", type, hover)
		theme.set_stylebox("hover_pressed", type, hover)
		theme.set_stylebox("focus", type, _focus())
		theme.set_constant("h_separation", type, S.SPACING[2])
	for state in ["checked", "checked_disabled"]:
		theme.set_icon(state, "CheckBox", ICON_CHECKBOX_ON)
	for state in ["unchecked", "unchecked_disabled"]:
		theme.set_icon(state, "CheckBox", ICON_CHECKBOX_OFF)
	for state in ["radio_checked", "radio_checked_disabled"]:
		theme.set_icon(state, "CheckBox", ICON_RADIO_ON)
	for state in ["radio_unchecked", "radio_unchecked_disabled"]:
		theme.set_icon(state, "CheckBox", ICON_RADIO_OFF)
	for state in ["checked", "checked_disabled", "checked_mirrored", "checked_disabled_mirrored"]:
		theme.set_icon(state, "CheckButton", ICON_TOGGLE_ON)
	for state in ["unchecked", "unchecked_disabled", "unchecked_mirrored", "unchecked_disabled_mirrored"]:
		theme.set_icon(state, "CheckButton", ICON_TOGGLE_OFF)

static func _apply_panels(theme: Theme) -> void:
	var surface := _box(S.GAME_SURFACE, S.RADIUS_LARGE, S.SURFACE_BORDER)
	theme.set_stylebox("panel", "Panel", surface)
	theme.set_stylebox("panel", "PanelContainer", surface)
	theme.set_stylebox("panel", "ScrollContainer", _empty())

static func _apply_tabs(theme: Theme) -> void:
	for type in [&"TabContainer", &"TabBar"]:
		theme.set_font("font", type, S.UI_FONT)
		theme.set_font_size("font_size", type, 20)
		theme.set_color("font_selected_color", type, S.TEXT_PRIMARY)
		theme.set_color("font_hovered_color", type, S.TEXT_PRIMARY)
		theme.set_color("font_unselected_color", type, S.TEXT_SECONDARY)
		theme.set_color("font_disabled_color", type, S.INK_400)
		var selected := _tab(S.GAME_SURFACE, S.GAME_ACCENT)
		theme.set_stylebox("tab_selected", type, selected)
		theme.set_stylebox("tab_unselected", type, _tab(Color.TRANSPARENT, Color.TRANSPARENT))
		theme.set_stylebox("tab_hovered", type, _tab(S.EMBER_50, S.ARROW_HOVER))
		theme.set_stylebox("tab_disabled", type, _tab(Color.TRANSPARENT, Color.TRANSPARENT))
		theme.set_stylebox("tab_focus", type, _focus())
	theme.set_stylebox("panel", "TabContainer", _box(S.GAME_SURFACE, S.RADIUS_LARGE, S.SURFACE_BORDER))
	theme.set_stylebox("tabbar_background", "TabContainer", _empty())

static func _tab(background: Color, underline: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = underline
	box.border_width_bottom = 3
	box.corner_radius_top_left = S.RADIUS_SMALL
	box.corner_radius_top_right = S.RADIUS_SMALL
	box.content_margin_left = S.SPACING[3]
	box.content_margin_right = S.SPACING[3]
	box.content_margin_top = _TARGET_PAD
	box.content_margin_bottom = _TARGET_PAD
	return box

## Track and fill are thin lines centred in a 48 px tall hit area.
static func _apply_sliders(theme: Theme) -> void:
	for pair in [[&"HSlider", false], [&"VSlider", true]]:
		var type: StringName = pair[0]
		var vertical: bool = pair[1]
		theme.set_stylebox("slider", type, _track(S.SURFACE_BORDER, vertical))
		theme.set_stylebox("grabber_area", type, _track(S.EMBER_300, vertical))
		theme.set_stylebox("grabber_area_highlight", type, _track(S.ARROW_HOVER, vertical))
		theme.set_icon("grabber", type, ICON_GRABBER)
		theme.set_icon("grabber_highlight", type, ICON_GRABBER_HIGHLIGHT)
		theme.set_icon("grabber_disabled", type, ICON_GRABBER)

## The slider draws its style across the full widget height (the 48 px target), so the
## visible 6 px track is pulled in from both sides with negative expand margins.
static func _track(color: Color, vertical: bool) -> StyleBoxFlat:
	var track := StyleBoxFlat.new()
	track.bg_color = color
	track.set_corner_radius_all(3)
	var pad := S.MIN_TARGET_HEIGHT / 2.0
	var inset := -(pad - 3.0)
	if vertical:
		track.content_margin_left = pad
		track.content_margin_right = pad
		track.expand_margin_left = inset
		track.expand_margin_right = inset
	else:
		track.content_margin_top = pad
		track.content_margin_bottom = pad
		track.expand_margin_top = inset
		track.expand_margin_bottom = inset
	return track

static func _apply_scrollbars(theme: Theme) -> void:
	for type in [&"VScrollBar", &"HScrollBar"]:
		var track := _box(S.CREAM_DEEP, 4, S.CREAM_DEEP)
		_set_margins(track, 2)
		theme.set_stylebox("scroll", type, track)
		theme.set_stylebox("scroll_focus", type, track)
		theme.set_stylebox("grabber", type, _grip(S.INK_300))
		theme.set_stylebox("grabber_highlight", type, _grip(S.INK_400))
		theme.set_stylebox("grabber_pressed", type, _grip(S.INK_500))

static func _grip(color: Color) -> StyleBoxFlat:
	var box := _box(color, 4, color)
	_set_margins(box, 4)
	return box

static func _apply_line_edit(theme: Theme) -> void:
	theme.set_font("font", "LineEdit", S.SUPPORTING_FONT)
	theme.set_font_size("font_size", "LineEdit", 20)
	theme.set_color("font_color", "LineEdit", S.TEXT_PRIMARY)
	theme.set_color("font_placeholder_color", "LineEdit", S.TEXT_SECONDARY)
	theme.set_color("caret_color", "LineEdit", S.GAME_ACCENT)
	theme.set_color("selection_color", "LineEdit", S.EMBER_100)
	theme.set_stylebox("normal", "LineEdit", _box(S.GAME_SURFACE, S.RADIUS_SMALL, S.INK_300))
	theme.set_stylebox("read_only", "LineEdit", _box(S.CREAM_DEEP, S.RADIUS_SMALL, S.SURFACE_BORDER))
	theme.set_stylebox("focus", "LineEdit", _focus())

static func _apply_popup(theme: Theme) -> void:
	var panel := _box(S.GAME_SURFACE, S.RADIUS_SMALL, S.SURFACE_BORDER)
	panel.shadow_color = S.SHADOW_COLOR
	panel.shadow_offset = S.SHADOW_OFFSET
	panel.shadow_size = S.SHADOW_SIZE
	_set_margins(panel, S.SPACING[1])
	theme.set_stylebox("panel", "PopupMenu", panel)
	# Room for the popup's own scrollbar, which overlays the item column on long lists.
	theme.set_constant("item_end_padding", "PopupMenu", S.SPACING[5])
	theme.set_stylebox("panel", "PopupPanel", panel)
	theme.set_stylebox("hover", "PopupMenu", _box(S.EMBER_50, 4, S.EMBER_50))
	theme.set_stylebox("separator", "PopupMenu", _line(S.SURFACE_BORDER, 1, false))
	theme.set_font("font", "PopupMenu", S.SUPPORTING_FONT)
	theme.set_font_size("font_size", "PopupMenu", 20)
	theme.set_color("font_color", "PopupMenu", S.TEXT_PRIMARY)
	theme.set_color("font_hover_color", "PopupMenu", S.TEXT_PRIMARY)
	theme.set_color("font_accelerator_color", "PopupMenu", S.TEXT_SECONDARY)
	theme.set_color("font_disabled_color", "PopupMenu", S.INK_400)
	theme.set_color("font_separator_color", "PopupMenu", S.TEXT_SECONDARY)
	theme.set_constant("v_separation", "PopupMenu", S.SPACING[3])
	theme.set_icon("checked", "PopupMenu", ICON_CHECKBOX_ON)
	theme.set_icon("unchecked", "PopupMenu", ICON_CHECKBOX_OFF)
	theme.set_icon("radio_checked", "PopupMenu", ICON_RADIO_ON)
	theme.set_icon("radio_unchecked", "PopupMenu", ICON_RADIO_OFF)
	theme.set_icon("submenu", "PopupMenu", ICON_ARROW_RIGHT)

static func _apply_lists(theme: Theme) -> void:
	var surface := _box(S.GAME_SURFACE, S.RADIUS_SMALL, S.SURFACE_BORDER)
	var selected := _box(S.EMBER_50, 4, S.EMBER_50)
	for type in [&"Tree", &"ItemList"]:
		theme.set_stylebox("panel", type, surface)
		theme.set_stylebox("focus", type, _focus())
		theme.set_stylebox("selected", type, selected)
		theme.set_stylebox("selected_focus", type, selected)
		theme.set_stylebox("cursor", type, _focus())
		theme.set_stylebox("cursor_unfocused", type, _empty())
		theme.set_font("font", type, S.SUPPORTING_FONT)
		theme.set_font_size("font_size", type, 20)
		theme.set_color("font_color", type, S.TEXT_PRIMARY)
		theme.set_color("font_selected_color", type, S.TEXT_PRIMARY)
		theme.set_color("font_hovered_color", type, S.TEXT_PRIMARY)
		theme.set_color("guide_color", type, S.SURFACE_BORDER)
	theme.set_stylebox("hovered", "ItemList", selected)
	theme.set_stylebox("title_button_normal", "Tree", _box(S.CREAM_DEEP, 0, S.SURFACE_BORDER))
	theme.set_stylebox("title_button_hover", "Tree", _box(S.EMBER_50, 0, S.SURFACE_BORDER))
	theme.set_stylebox("title_button_pressed", "Tree", _box(S.INK_100, 0, S.SURFACE_BORDER))
	theme.set_color("title_button_color", "Tree", S.TEXT_PRIMARY)
	theme.set_color("children_hl_line_color", "Tree", S.SURFACE_BORDER)
	theme.set_color("parent_hl_line_color", "Tree", S.INK_300)
	theme.set_icon("arrow", "Tree", ICON_ARROW_DOWN)
	theme.set_icon("arrow_collapsed", "Tree", ICON_ARROW_RIGHT)
	theme.set_icon("checked", "Tree", ICON_CHECKBOX_ON)
	theme.set_icon("unchecked", "Tree", ICON_CHECKBOX_OFF)

static func _apply_dialogs(theme: Theme) -> void:
	var frame := _box(S.GAME_SURFACE, S.RADIUS_LARGE, S.SURFACE_BORDER)
	frame.shadow_color = S.SHADOW_COLOR
	frame.shadow_offset = S.SHADOW_OFFSET
	frame.shadow_size = S.SHADOW_SIZE
	frame.expand_margin_top = 36
	theme.set_stylebox("embedded_border", "Window", frame)
	theme.set_stylebox("embedded_unfocused_border", "Window", frame)
	theme.set_font("title_font", "Window", S.SECONDARY_HEADING_FONT)
	theme.set_font_size("title_font_size", "Window", 20)
	theme.set_color("title_color", "Window", S.TEXT_PRIMARY)
	theme.set_stylebox("panel", "AcceptDialog", _box(S.GAME_SURFACE, S.RADIUS_LARGE, S.GAME_SURFACE))

static func _apply_progress(theme: Theme) -> void:
	theme.set_stylebox("background", "ProgressBar", _box(S.SURFACE_BORDER, S.RADIUS_SMALL, S.SURFACE_BORDER))
	theme.set_stylebox("fill", "ProgressBar", _box(S.GAME_ACCENT, S.RADIUS_SMALL, S.GAME_ACCENT))
	theme.set_color("font_color", "ProgressBar", S.TEXT_PRIMARY)
	theme.set_font("font", "ProgressBar", S.NUMERIC_FONT)
	theme.set_font_size("font_size", "ProgressBar", 18)

## Menu hero: large display title, ember accent word, quiet tagline on ink.
static func _apply_hero_roles(theme: Theme) -> void:
	_label_role(theme, &"HeroTitle", S.HEADING_FONT, S.TITLE_FONT_SIZE, S.HERO_TEXT)
	_label_role(theme, &"HeroAccent", S.HEADING_FONT, S.TITLE_FONT_SIZE, S.HERO_ACCENT)
	_label_role(theme, &"HeroTagline", S.UI_FONT, 24, S.HERO_SUPPORTING)

static func _apply_level_select_roles(theme: Theme) -> void:
	for variation in S.LEVEL_CARD_ACCENTS:
		var accent: Color = S.LEVEL_CARD_ACCENTS[variation]
		theme.set_type_variation(variation, &"Button")
		theme.set_stylebox("normal", variation, _card(S.GAME_SURFACE, accent))
		theme.set_stylebox("hover", variation, _card(S.EMBER_50, accent))
		var pressed := _card(S.INK_100, accent)
		pressed.content_margin_top = _TARGET_PAD + 1
		pressed.content_margin_bottom = _TARGET_PAD - 1
		theme.set_stylebox("pressed", variation, pressed)
		theme.set_stylebox("focus", variation, _focus())
	theme.set_type_variation(&"LevelGroupHeader", &"Button")
	theme.set_font("font", &"LevelGroupHeader", S.SECONDARY_HEADING_FONT)
	theme.set_font_size("font_size", &"LevelGroupHeader", 24)
	var header := _empty()
	header.content_margin_top = _TARGET_PAD
	header.content_margin_bottom = _TARGET_PAD
	theme.set_stylebox("normal", &"LevelGroupHeader", header)
	theme.set_stylebox("pressed", &"LevelGroupHeader", header)
	theme.set_stylebox("hover_pressed", &"LevelGroupHeader", header)
	theme.set_stylebox("hover", &"LevelGroupHeader", header)
	theme.set_stylebox("focus", &"LevelGroupHeader", _focus())
	theme.set_color("font_hover_color", &"LevelGroupHeader", S.GAME_ACCENT)
	theme.set_color("font_hover_pressed_color", &"LevelGroupHeader", S.GAME_ACCENT)

## A card whose 6 px left edge carries the group accent in every state. StyleBoxFlat
## has a single border color, so the state color shows in the background instead.
static func _card(background: Color, accent: Color) -> StyleBoxFlat:
	var box := _box(background, S.RADIUS_SMALL, accent)
	box.border_width_top = 0
	box.border_width_right = 0
	box.border_width_bottom = 0
	box.border_width_left = 6
	box.content_margin_left = S.SPACING[3] + 6
	box.shadow_color = S.SHADOW_COLOR
	box.shadow_offset = Vector2(0, 1)
	box.shadow_size = 3
	return box

static func _label_role(theme: Theme, role: StringName, font: Font, font_size: int, color: Color) -> void:
	theme.set_type_variation(role, &"Label")
	theme.set_font("font", role, font)
	theme.set_font_size("font_size", role, font_size)
	theme.set_color("font_color", role, color)

static func _box(background: Color, radius: int, border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(S.BORDER_WIDTH)
	box.set_corner_radius_all(radius)
	box.content_margin_left = S.SPACING[3]
	box.content_margin_right = S.SPACING[3]
	box.content_margin_top = _TARGET_PAD
	box.content_margin_bottom = _TARGET_PAD
	return box

static func _empty() -> StyleBoxEmpty:
	var box := StyleBoxEmpty.new()
	box.content_margin_left = S.SPACING[1]
	box.content_margin_right = S.SPACING[1]
	box.content_margin_top = _TARGET_PAD
	box.content_margin_bottom = _TARGET_PAD
	return box

static func _focus() -> StyleBoxFlat:
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = S.ARROW_HOVER
	focus.set_border_width_all(2)
	focus.set_corner_radius_all(S.RADIUS_SMALL)
	focus.set_expand_margin_all(3)
	return focus

static func _line(color: Color, thickness: int, vertical: bool) -> StyleBoxLine:
	var line := StyleBoxLine.new()
	line.color = color
	line.thickness = thickness
	line.vertical = vertical
	return line

static func _set_margins(box: StyleBox, value: float) -> void:
	box.content_margin_left = value
	box.content_margin_right = value
	box.content_margin_top = value
	box.content_margin_bottom = value
