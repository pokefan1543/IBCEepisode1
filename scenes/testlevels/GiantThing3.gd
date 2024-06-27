extends RigidBody

func start_dialog():
	var dialog = Dialogic.start("tutorial3")
	dialog.pause_mode = PAUSE_MODE_PROCESS
	get_parent().add_child(dialog)
	dialog.connect("timeline_end",self,"end_dialog")
	get_tree().paused = true

func end_dialog(data):
	get_tree().paused = false
