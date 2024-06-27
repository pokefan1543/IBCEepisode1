extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var dialog = Dialogic.start("Brief")
	add_child(dialog)

func _physics_process(delta):
	if Input.is_action_just_pressed("dash"):
		get_tree().change_scene("res://scenes/real_levels/level_select.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
