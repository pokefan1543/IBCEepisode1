extends Button

func _ready():
	Globals.tutorial = true
# Called when the node enters the scene tree for the first time.
func start_dialog():
	if Globals.level8unlocked == true:
		var dialog = Dialogic.start("Kleocodex")
		dialog.pause_mode = PAUSE_MODE_PROCESS
		get_parent().add_child(dialog)
		dialog.connect("timeline_end",self,"end_dialog")
		get_tree().paused = true

func end_dialog(_data):
	get_tree().paused = false
