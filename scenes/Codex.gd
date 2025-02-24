extends Button

func _ready():
	Globals.tutorial = true
# Called when the node enters the scene tree for the first time.
func start_dialog():
	var dialog = Dialogic.start("codex1")
	dialog.process_mode = PROCESS_MODE_ALWAYS
	get_parent().add_child(dialog)
	dialog.connect("timeline_end", Callable(self, "end_dialog"))
	get_tree().paused = true

func end_dialog(_data):
	get_tree().paused = false
