extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var dialog = Dialogic.start("letter3")
	add_child(dialog)

func _physics_process(delta):
	if Input.is_action_just_pressed("dash"):
		get_tree().change_scene("res://scenes/real_levels/E1M2.tscn")
	if Input.is_action_just_pressed("Q"):
		get_tree().change_scene("res://scenes/real_levels/level_select.tscn")
		
