extends SceneTree
## Real-project app theme checks: the AppTheme autoload installs the brand theme
## everywhere (including under CanvasLayer), every standard control type resolves
## brand styles and a visible focus ring, targets and text meet minimum sizes, and
## every text/background pair the theme uses meets WCAG 2.1 AA contrast.

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	_check_responsive_sizing()
	_check_installed()
	await _check_canvas_layer_inheritance()
	_check_control_types()
	await _check_target_sizes()
	_check_text_sizes()
	_check_contrast()
	print("APP_THEME_FAILURES=", failures)
	quit(1 if failures else 0)

func _check_installed() -> void:
	var default_theme := ThemeDB.get_default_theme()
	var normal := default_theme.get_stylebox("normal", "Button") as StyleBoxFlat
	check(normal != null and normal.bg_color == GameVisualStyle.GAME_SURFACE,
		"AppTheme merges the brand Button style into the engine default theme")
	check(default_theme.default_font == GameVisualStyle.SUPPORTING_FONT,
		"the brand body font is the default font everywhere")
	var loader := root.get_node_or_null(^"/root/SceneLoader")
	check(loader != null and loader.get(&"loading_screen_path") == "res://scenes/loading_screen/loading_screen.tscn",
		"the scene loader uses the branded loading screen")

func _check_canvas_layer_inheritance() -> void:
	var layer := CanvasLayer.new()
	root.add_child(layer)
	var label := Label.new()
	layer.add_child(label)
	await process_frame
	check(label.get_theme_color("font_color") == GameVisualStyle.TEXT_PRIMARY,
		"a Label under a CanvasLayer resolves the brand text color")
	layer.queue_free()

func _check_control_types() -> void:
	var theme := GameVisualStyle.get_theme()
	for type in ["Button", "OptionButton", "MenuButton", "CheckBox", "CheckButton", "LineEdit",
			"TabContainer", "TabBar", "Tree", "ItemList", "HSlider", "VSlider", "VScrollBar",
			"HScrollBar", "PopupMenu", "Panel", "PanelContainer", "ProgressBar", "TooltipPanel",
			"RichTextLabel", "Window", "AcceptDialog"]:
		check(not theme.get_stylebox_list(type).is_empty() or not theme.get_color_list(type).is_empty(),
			"%s has brand styles in the app theme" % type)
	for type in ["Button", "OptionButton", "MenuButton", "CheckBox", "CheckButton", "LineEdit", "Tree", "ItemList"]:
		var focus := theme.get_stylebox("focus", type) as StyleBoxFlat
		check(focus != null and focus.border_color == GameVisualStyle.ARROW_HOVER and not focus.draw_center,
			"%s focus is a visible ember ring" % type)
	for type in ["TabContainer", "TabBar"]:
		var tab_focus := theme.get_stylebox("tab_focus", type) as StyleBoxFlat
		check(tab_focus != null and tab_focus.border_color == GameVisualStyle.ARROW_HOVER,
			"%s tab focus is a visible ember ring" % type)
	for icon in ["checked", "unchecked", "radio_checked", "radio_unchecked"]:
		check(theme.has_icon(icon, "CheckBox"), "CheckBox has a light-theme %s icon" % icon)
	for icon in ["checked", "unchecked"]:
		check(theme.has_icon(icon, "CheckButton"), "CheckButton has a light-theme %s icon" % icon)
	check(theme.has_icon("grabber", "HSlider") and theme.has_icon("arrow", "OptionButton"),
		"slider grabber and dropdown arrow use brand icons")
	for variation in GameVisualStyle.LEVEL_CARD_ACCENTS:
		var card := theme.get_stylebox("normal", variation) as StyleBoxFlat
		check(theme.get_type_variation_base(variation) == &"Button" and card != null
			and card.border_color == GameVisualStyle.LEVEL_CARD_ACCENTS[variation] and card.border_width_left == 6,
			"%s is a Button card with its accent edge" % variation)
	for role in [&"HeroTitle", &"HeroAccent", &"HeroTagline", &"LevelGroupHeader"]:
		check(theme.get_type_variation_base(role) != &"", "%s role exists" % role)
	for role in [&"GameHeading", &"SecondaryHeading", &"InterfaceLabel", &"SupportingText",
			&"NumericText", &"SuccessText", &"PrimaryButton", &"SecondaryButton", &"GameSurface"]:
		check(theme.get_type_variation_base(role) != &"", "existing %s role is preserved" % role)

func _check_target_sizes() -> void:
	var host := Control.new()
	host.theme = GameVisualStyle.get_theme()
	root.add_child(host)
	var targets: Array[Control] = []
	for variation in [&"", &"PrimaryButton", &"SecondaryButton", &"LevelCardRust", &"LevelGroupHeader"]:
		var button := Button.new()
		button.text = "Play"
		button.theme_type_variation = variation
		targets.append(button)
	var option := OptionButton.new()
	option.add_item("Fullscreen")
	targets.append(option)
	var box := CheckBox.new()
	box.text = "Mute"
	targets.append(box)
	var toggle := CheckButton.new()
	toggle.text = "Vsync"
	targets.append(toggle)
	var line := LineEdit.new()
	line.text = "Name"
	targets.append(line)
	targets.append(HSlider.new())
	for target in targets:
		host.add_child(target)
	await process_frame
	for target in targets:
		var label := "%s%s" % [target.get_class(), (" (%s)" % target.theme_type_variation) if target.theme_type_variation != &"" else ""]
		check(target.get_combined_minimum_size().y >= GameVisualStyle.MIN_TARGET_HEIGHT,
			"%s is at least %d px tall (got %.1f)" % [label, GameVisualStyle.MIN_TARGET_HEIGHT, target.get_combined_minimum_size().y])
	host.queue_free()

func _check_text_sizes() -> void:
	var theme := GameVisualStyle.get_theme()
	check(theme.default_font_size >= 18, "default body text is at least 18 px")
	for type in ["Button", "Label", "CheckBox", "LineEdit", "PopupMenu", "TooltipLabel", "TabContainer"]:
		var size := theme.get_font_size("font_size", type) if theme.has_font_size("font_size", type) else theme.default_font_size
		check(size >= 18, "%s text is at least 18 px" % type)
	check(theme.get_font_size("font_size", &"HeroTitle") >= 64, "the menu title is at least 64 px")

func _check_contrast() -> void:
	var S := GameVisualStyle
	var body_pairs := [
		["primary text on cream", S.TEXT_PRIMARY, S.GAME_BACKGROUND],
		["primary text on surface", S.TEXT_PRIMARY, S.GAME_SURFACE],
		["secondary text on cream", S.TEXT_SECONDARY, S.GAME_BACKGROUND],
		["secondary text on surface", S.TEXT_SECONDARY, S.GAME_SURFACE],
		["primary text on hover tint", S.TEXT_PRIMARY, S.EMBER_50],
		["primary text on pressed", S.TEXT_PRIMARY, S.INK_100],
		["text on rust primary", S.TEXT_ON_ACCENT, S.GAME_ACCENT],
		["tagline on hero ink", S.HERO_SUPPORTING, S.HERO_BACKGROUND],
		["tooltip text", S.TEXT_ON_ACCENT, S.TOOLTIP_BACKGROUND],
		["success score on surface", S.GAME_SUCCESS, S.GAME_SURFACE],
		["secondary text over the menu backdrop motif", S.TEXT_SECONDARY, MenuBackdrop.COLOR],
		["primary text over the menu backdrop motif", S.TEXT_PRIMARY, MenuBackdrop.COLOR],
	]
	for pair in body_pairs:
		var ratio := _contrast(pair[1], pair[2])
		check(ratio >= 4.5, "%s meets 4.5:1 (%.2f)" % [pair[0], ratio])
	var large_pairs := [
		["hero title on ink", S.HERO_TEXT, S.HERO_BACKGROUND],
		["ember accent word on ink", S.HERO_ACCENT, S.HERO_BACKGROUND],
		["ember focus ring on cream", S.ARROW_HOVER, S.GAME_BACKGROUND],
		["ember focus ring on surface", S.ARROW_HOVER, S.GAME_SURFACE],
		["rust group header hover on cream", S.GAME_ACCENT, S.GAME_BACKGROUND],
	]
	for pair in large_pairs:
		var ratio := _contrast(pair[1], pair[2])
		check(ratio >= 3.0, "%s meets 3:1 (%.2f)" % [pair[0], ratio])

static func _contrast(a: Color, b: Color) -> float:
	var la := _luminance(a)
	var lb := _luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)

static func _luminance(c: Color) -> float:
	return 0.2126 * _linear(c.r) + 0.7152 * _linear(c.g) + 0.0722 * _linear(c.b)

static func _linear(v: float) -> float:
	return v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4)

func _check_responsive_sizing() -> void:
	var policy = load("res://scripts/presentation/responsive_layout.gd")
	for css in [Vector2i(360, 580), Vector2i(390, 784), Vector2i(412, 855), Vector2i(915, 352)]:
		check(policy.base_size(css, true) == css, "touch content uses CSS-sized logical units at %s" % css)
	check(policy.base_size(Vector2i(1920, 1080), false) == Vector2i(1280, 720), "wide desktop keeps its established design scale")
	check(policy.base_size(Vector2i.ZERO, true) == Vector2i.ZERO, "zero CSS size is ignored rather than replacing a usable layout")
