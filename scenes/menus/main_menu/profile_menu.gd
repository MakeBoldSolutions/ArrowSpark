extends Control
## Player Profile sub-menu of the main menu: the player's name, a short summary of
## what they have finished and how they have played, an honest note about where
## the profile lives, and a confirmed way to delete it. The profile itself is
## PlayerProfile; this scene only shows and edits it. It is built from code like
## the Level Select content, so keyboard and gamepad focus follow the Control tree.

## Emitted after the profile changed in a way the main menu shows (deleted), so the
## menu can refresh Continue.
signal profile_changed

const MAX_COLUMN_WIDTH := 460.0

var _column: VBoxContainer
var _name_edit: LineEdit
var _name_status: Label
var _summary: Label
var _notice: Label
var _delete_button: Button
var _confirm: ConfirmationDialog

func _ready() -> void:
	var scroll := ScrollContainer.new()
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	_column = VBoxContainer.new()
	_column.add_theme_constant_override("separation", 12)
	center.add_child(_column)

	_column.add_child(_label("Player Profile", &"SecondaryHeading"))
	_column.add_child(_label("Your name", &"SupportingText"))
	_name_edit = LineEdit.new()
	_name_edit.max_length = PlayerProfile.MAX_NAME_LENGTH
	_name_edit.placeholder_text = PlayerProfile.DEFAULT_NAME
	_name_edit.tooltip_text = "Your name on this device. Press Enter to save it."
	_name_edit.text_submitted.connect(_commit_name)
	_name_edit.focus_exited.connect(_commit_name_on_focus_lost)
	_column.add_child(_name_edit)
	_name_status = _label("", &"SupportingText")
	_column.add_child(_name_status)

	_summary = _label("", &"")
	_column.add_child(_summary)
	_column.add_child(_label(_storage_note(), &"SupportingText"))
	_notice = _label("", &"SupportingText")
	_column.add_child(_notice)

	_delete_button = Button.new()
	_delete_button.text = "Delete Profile"
	_delete_button.theme_type_variation = &"SecondaryButton"
	_delete_button.focus_mode = Control.FOCUS_ALL
	_delete_button.pressed.connect(_on_delete_pressed)
	_column.add_child(_delete_button)

	_confirm = ConfirmationDialog.new()
	_confirm.title = "Delete profile?"
	_confirm.dialog_text = "Delete your profile from this %s? Your name, finished levels, best scores and statistics will be removed. This cannot be undone." % _place_word()
	_confirm.ok_button_text = "Delete"
	_confirm.cancel_button_text = "Keep"
	_confirm.confirmed.connect(_on_delete_confirmed)
	_confirm.canceled.connect(_on_delete_canceled)
	add_child(_confirm)

	resized.connect(_reflow)
	_reflow.call_deferred()
	refresh()

func _label(text: String, variation: StringName) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.focus_mode = Control.FOCUS_NONE
	if variation != &"":
		label.theme_type_variation = variation
	return label

static func _place_word() -> String:
	return "browser" if OS.has_feature("web") else "device"

static func _storage_note() -> String:
	if OS.has_feature("web"):
		return "Your profile is kept in this browser only and is never sent anywhere. It does not follow you to another device or browser, and clearing this site's data removes it."
	return "Your profile is kept on this device only and is never sent anywhere. It does not follow you to another device."

## Rereads the profile and updates every line shown.
func refresh() -> void:
	if not is_node_ready():
		return
	PlayerProfile.ensure_loaded()
	if not _name_edit.has_focus():
		_name_edit.text = PlayerProfile.display_name()
	var stats := PlayerProfile.stats()
	var earned := PlayerProfile.earned_score()
	var possible := PlayerProfile.possible_score()
	var possible_finished := PlayerProfile.possible_score_on_finished()
	_summary.text = "Complete: %d%%\nLevels finished: %d of %d\nScore: %d of %d possible (%d%%)\nScore on finished levels: %d of %d (%d%%)\nAttempts finished: %d\nMistakes: %d\nOpen Move assists: %d" % [
		roundi(PlayerProfile.completion_fraction() * 100.0),
		PlayerProfile.finished_count(), PuzzleCatalog.count(),
		earned, possible, _percent(earned, possible),
		earned, possible_finished, _percent(earned, possible_finished),
		stats["attempts"], stats["mistakes"], stats["open_move_assists"]]
	_notice.text = PlayerProfile.load_notice()
	_notice.visible = not _notice.text.is_empty()

static func _percent(part: int, whole: int) -> int:
	return roundi(100.0 * part / whole) if whole > 0 else 0

func _commit_name_on_focus_lost() -> void:
	_commit_name(_name_edit.text)

func _commit_name(requested: String) -> void:
	var current := PlayerProfile.display_name()
	var stored := PlayerProfile.set_display_name(requested)
	_name_edit.text = stored
	_name_status.text = "Name saved." if stored != current else ""

func _on_delete_pressed() -> void:
	_delete_button.disabled = true
	_confirm.popup_centered()

func _on_delete_confirmed() -> void:
	# Leave the name field first: losing focus commits its text, which must not
	# re-save the old name after the profile is deleted.
	_name_edit.release_focus()
	PlayerProfile.reset()
	_name_status.text = "Profile deleted."
	_delete_button.disabled = false
	refresh()
	profile_changed.emit()
	_delete_button.grab_focus()

func _on_delete_canceled() -> void:
	_delete_button.disabled = false
	_delete_button.grab_focus()

## Focus the name field when the menu opens, as Level Select focuses its first
## entry: the inherited sub-menu mechanism does not move focus itself.
func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree() and is_node_ready():
		_name_status.text = ""
		refresh()
		call_deferred("_grab_initial_focus")

func _grab_initial_focus() -> void:
	if is_visible_in_tree():
		_name_edit.grab_focus()

func _reflow() -> void:
	if not is_node_ready():
		return
	_column.custom_minimum_size.x = clampf(size.x - 28.0, 0.0, MAX_COLUMN_WIDTH)
