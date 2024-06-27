extends Control

var play = false

func _ready():
	get_tree().paused = false
	Globals.tutorial = false
	$Timer.start()
	$Button2.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$AnimationPlayer.play("logo")
	$AudioStreamPlayer.play()
	
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
