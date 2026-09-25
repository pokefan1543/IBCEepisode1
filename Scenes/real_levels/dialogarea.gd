extends Area3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func start_dialog():
	var dialog = Dialogic.start("RevekkaTalksToHerself")
	get_parent().add_child(dialog)
