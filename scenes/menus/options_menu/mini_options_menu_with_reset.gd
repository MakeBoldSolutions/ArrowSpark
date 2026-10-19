extends MiniOptionsMenu

func _on_reset_game_control_reset_confirmed():
	GlobalState.reset()

func _ready() -> void:
	super._ready()
	resized.connect(_reflow)
	_reflow.call_deferred()

func _reflow() -> void:
	if is_node_ready():
		ResponsiveLayout.fit_options(self, ResponsiveLayout.compact(get_viewport_rect().size))
