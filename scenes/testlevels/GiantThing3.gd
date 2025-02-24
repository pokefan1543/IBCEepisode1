extends RigidBody3D

func start_dialog():
	var dialog = Dialogic.start("tutorial3")
	dialog.process_mode = PROCESS_MODE_ALWAYS
	get_parent().add_child(dialog)
	dialog.connect("timeline_end", Callable(self, "end_dialog"))
	get_tree().paused = true

func end_dialog(data):
	get_tree().paused = false
