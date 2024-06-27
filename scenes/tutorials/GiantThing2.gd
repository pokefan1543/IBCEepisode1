extends RigidBody



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func start_dialog():
	var dialog = Dialogic.start("tutorial2")
	dialog.pause_mode = PAUSE_MODE_PROCESS
	get_parent().add_child(dialog)
	dialog.connect("timeline_end",self,"end_dialog")
	get_tree().paused = true

func end_dialog(data):
	get_tree().paused = false
