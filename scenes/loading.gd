extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.

func _physics_process(delta):
	if Globals.enterLevel == "1":
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M1.tscn")
	if Globals.enterLevel == "2":
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M2.tscn")
	if Globals.enterLevel == "3":
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M3.tscn")
	if Globals.enterLevel == "4":
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M4.tscn")
	if Globals.enterLevel == "5":
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M5.tscn")
	if Globals.enterLevel == "6":
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M6.tscn")
	if Globals.enterLevel == "7":
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M7scn")
	if Globals.enterLevel == "8":
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M8.tscn")
