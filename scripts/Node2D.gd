extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var dialog = Dialogic.start("letter")
	add_child(dialog)

func _physics_process(_delta):
	if Input.is_action_just_pressed("dash"):
		get_tree().change_scene_to_file("res://scenes/DialogScenes/brief.tscn")
	if Input.is_action_just_pressed("T"):
		get_tree().change_scene_to_file("res://scenes/tutorials/Introtut.tscn")
