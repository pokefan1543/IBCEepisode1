extends Control

var play = false
var save = SaveGame.new()

func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	yield(get_tree().create_timer(duration * timeScale), "timeout")
	Engine.time_scale = 1.0
	
func _ready():
	$AnimationPlayer.play("logo")
	frameFreeze(1, 2.0)
	get_tree().paused = false
	Globals.itemCount = 0
	Globals.enemies = 0
	Globals.defeats = 0
	Globals.time = 0
	if Globals.fullscreen == true:
		OS.window_fullscreen = true
		OS.window_borderless = true
	else:
		OS.window_fullscreen = false
		OS.window_size = Vector2(640,480)
		OS.window_borderless = false
	$Button2.grab_focus()
	Globals.tutorial = false
	$Timer.start()
	save.load_savesettings()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_Button2_button_down():
	$AudioStreamPlayer.play()
	get_tree().change_scene("res://scenes/episode_select.tscn")
	$AudioStreamPlayer.play()
	
func _on_Button3_button_down():
	print("quit")
	$AudioStreamPlayer.play()
	get_tree().quit()

func _on_Timer_timeout():
	play = true

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		$AudioStreamPlayer3.play()

func _on_Button4_button_down():
	get_tree().change_scene("res://scenes/Options.tscn")


func _on_Button5_button_down():
	get_tree().change_scene("res://scenes/Gallery.tscn")
