extends Node

func _ready():
	GlobalState.open()
	AppSettings.set_from_config_and_window(get_window())
	if GlobalState.save_blocked:
		_show_save_recovery.call_deferred()

func _show_save_recovery() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Saved progress could not be loaded"
	dialog.dialog_text = "Your original save is safe. Continue without saving, or back it up and reset progress."
	dialog.ok_button_text = "Back up and reset"
	dialog.cancel_button_text = "Continue without saving"
	dialog.confirmed.connect(_reset_unreadable_save)
	dialog.visibility_changed.connect(func():
		if not dialog.visible:
			dialog.queue_free()
	)
	add_child(dialog)
	dialog.popup_centered()

func _reset_unreadable_save() -> void:
	var result = GlobalState.reset()
	if result != OK:
		var notice = AcceptDialog.new()
		notice.title = "Progress could not be saved"
		notice.dialog_text = "The reset could not be completed. Your original save was preserved or backed up. Check available disk space and file permissions."
		notice.confirmed.connect(notice.queue_free)
		add_child(notice)
		notice.popup_centered()
