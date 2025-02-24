extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var play = false
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	frameFreeze(1, 2.0)
	get_tree().paused = false
	$Button2.grab_focus()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout
	Engine.time_scale = 1.0
	
func _on_Button2_button_down():
	$AudioStreamPlayer.play()
	get_tree().change_scene_to_file("res://scenes/real_levels/level_select.tscn")
	#$AudioStreamPlayer.play()
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		$AudioStreamPlayer2.play()

func _on_Button6_button_down():
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")


func _on_Button5_button_down():
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")

func _on_Button3_button_down():
	$AudioStreamPlayer.play()
	get_tree().change_scene_to_file("res://scenes/real_levels/level_select2.tscn")
	$AudioStreamPlayer.play()
