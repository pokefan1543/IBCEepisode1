extends Node2D

func _ready():
	var dialog = Dialogic.start("letter2")
	add_child(dialog)

func _physics_process(delta):
	if Input.is_action_just_pressed("dash"): #"Dash" is the f key
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M1.tscn")
	if Input.is_action_just_pressed("Q"):
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select.tscn")
		
