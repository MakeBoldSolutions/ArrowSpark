class_name GameVisualStyle
extends RefCounted
## Shared presentation vocabulary. Rule classes never depend on this resource.

const GAME_BACKGROUND := Color("f8f6f2")
const GAME_SURFACE := Color("ffffff")
const ARROW_NORMAL := Color("1e1e1e")
const ARROW_HOVER := Color("c6620c")
const GAME_ACCENT := Color("982407")
const GAME_SUCCESS := Color("2f6f4c")
const TEXT_PRIMARY := Color("1e1e1e")
const TEXT_SECONDARY := Color("56544f")
const TEXT_ON_ACCENT := Color("f8f6f2")
const CRITICAL := Color("a8321a")
const SURFACE_BORDER := Color("ddd9d0")
const SPACING := [4, 8, 12, 16, 24, 32, 48]
const RADIUS_SMALL := 6
const RADIUS_LARGE := 10
const BORDER_WIDTH := 1
const SHADOW_OFFSET := Vector2(0, 4)
const SHADOW_SIZE := 12
const SHADOW_COLOR := Color(30.0 / 255.0, 30.0 / 255.0, 30.0 / 255.0, 0.08)
const BODY_WIDTH := 0.14
const HEAD_TIP := 0.30
const HEAD_BASE := -0.06
const HEAD_HALF_WIDTH := 0.22
const BODY_END := -0.02
const SINGLE_TAIL := -0.30
const HOVER_DURATION := 0.12
const BLOCKED_SCALE := 1.10
const HEADING_FONT = preload("res://assets/fonts/be_vietnam_pro/BeVietnamPro-ExtraBold.ttf")
const SECONDARY_HEADING_FONT = preload("res://assets/fonts/be_vietnam_pro/BeVietnamPro-Bold.ttf")
const UI_FONT = preload("res://resources/fonts/inter_tight_semibold.tres")
const SUPPORTING_FONT = preload("res://resources/fonts/inter_tight_regular.tres")
const NUMERIC_FONT = preload("res://resources/fonts/inter_tight_numeric.tres")
# Resource dependency retains both complete OFL notices in exported packs too.
const FONT_LICENSES = preload("res://resources/fonts/font_licenses.tres")

static var _theme: Theme

static func get_theme() -> Theme:
	if _theme != null:
		return _theme
	_theme = Theme.new()
	_theme.default_font = SUPPORTING_FONT
	_theme.default_font_size = 20
	_theme.set_color("font_color", "Label", TEXT_PRIMARY)
	_set_label_role(&"GameHeading", HEADING_FONT, 32, TEXT_PRIMARY)
	_set_label_role(&"SecondaryHeading", SECONDARY_HEADING_FONT, 24, TEXT_PRIMARY)
	_set_label_role(&"InterfaceLabel", UI_FONT, 20, TEXT_PRIMARY)
	_set_label_role(&"SupportingText", SUPPORTING_FONT, 16, TEXT_SECONDARY)
	_set_label_role(&"NumericText", NUMERIC_FONT, 20, TEXT_PRIMARY)
	_set_label_role(&"SuccessText", NUMERIC_FONT, 20, GAME_SUCCESS)
	_set_button_role(&"PrimaryButton", GAME_ACCENT, TEXT_ON_ACCENT)
	_set_button_role(&"SecondaryButton", GAME_SURFACE, TEXT_PRIMARY)
	_theme.set_type_variation(&"GameSurface", &"PanelContainer")
	var panel := _surface(GAME_SURFACE, RADIUS_LARGE)
	panel.shadow_color = SHADOW_COLOR
	panel.shadow_offset = SHADOW_OFFSET
	panel.shadow_size = SHADOW_SIZE
	_theme.set_stylebox("panel", "GameSurface", panel)
	_theme.set_constant("separation", "VBoxContainer", SPACING[2])
	_theme.set_constant("separation", "HBoxContainer", SPACING[2])
	return _theme

static func _set_label_role(role: StringName, font: Font, font_size: int, color: Color) -> void:
	_theme.set_type_variation(role, &"Label")
	_theme.set_font("font", role, font)
	_theme.set_font_size("font_size", role, font_size)
	_theme.set_color("font_color", role, color)

static func _surface(color: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = SURFACE_BORDER
	box.set_border_width_all(BORDER_WIDTH)
	box.set_corner_radius_all(radius)
	box.content_margin_left = SPACING[3]
	box.content_margin_right = SPACING[3]
	box.content_margin_top = SPACING[2]
	box.content_margin_bottom = SPACING[2]
	return box

static func _set_button_role(role: StringName, background: Color, foreground: Color) -> void:
	_theme.set_type_variation(role, &"Button")
	_theme.set_font("font", role, UI_FONT)
	_theme.set_font_size("font_size", role, 20)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		_theme.set_color(state, role, foreground)
	_theme.set_stylebox("normal", role, _surface(background, RADIUS_SMALL))
	var hover := _surface(background, RADIUS_SMALL)
	hover.border_color = ARROW_HOVER
	_theme.set_stylebox("hover", role, hover)
	var pressed := _surface(background, RADIUS_SMALL)
	pressed.border_color = GAME_ACCENT
	_theme.set_stylebox("pressed", role, pressed)
	var focus := _surface(Color.TRANSPARENT, RADIUS_SMALL)
	focus.draw_center = false
	focus.border_color = ARROW_HOVER
	focus.set_border_width_all(2)
	focus.set_expand_margin_all(3)
	_theme.set_stylebox("focus", role, focus)
