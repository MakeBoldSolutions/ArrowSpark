extends Node

func _ready():
	GlobalState.open()
	AppSettings.set_from_config_and_window(get_window())
	if GlobalState.save_blocked:
		_show_save_recovery.call_deferred()
	elif Config.save_blocked:
		_show_settings_recovery.call_deferred()

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
			if Config.save_blocked:
				_show_settings_recovery.call_deferred()
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

func _show_settings_recovery() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Settings could not be loaded"
	dialog.dialog_text = "Your original settings are safe. Continue with temporary settings, or back them up and reset. After resetting, restart the game to apply defaults."
	dialog.ok_button_text = "Back up and reset"
	dialog.cancel_button_text = "Continue with temporary settings"
	dialog.confirmed.connect(_reset_unreadable_settings)
	dialog.visibility_changed.connect(func():
		if not dialog.visible:
			dialog.queue_free()
	)
	add_child(dialog)
	dialog.popup_centered()

func _reset_unreadable_settings() -> void:
	var result = Config.reset_unreadable_config()
	var notice = AcceptDialog.new()
	if result == OK:
		notice.title = "Settings reset"
		notice.dialog_text = "Your original settings were backed up. Restart the game to apply defaults."
	else:
		notice.title = "Settings could not be reset"
		notice.dialog_text = "Your original settings were preserved or backed up. Changes remain temporary. Check disk space and file permissions."
	notice.visibility_changed.connect(func():
		if not notice.visible:
			notice.queue_free()
	)
	add_child(notice)
	notice.popup_centered()
