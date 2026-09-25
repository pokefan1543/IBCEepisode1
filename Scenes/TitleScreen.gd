extends Control

#var save = SaveGame.new()
var play = false
var diff = false 

@onready var diffbutts = $VBoxContainer2/normal

func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout
	Engine.time_scale = 1.0

func _ready():
	diff = false
	$ColorRect.hide()
	$VBoxContainer.show()
	$VBoxContainer2.hide()
	$DifT.hide()
	$TextureRect.show()
	$AnimationPlayer.play("logo")
	frameFreeze(1, 2.0)
	get_tree().paused = false
	Globals.itemCount = 0
	Globals.enemies = 0
	Globals.defeats = 0
	Globals.time = 0
#	save.load_savesettings()
	if Globals.fullscreen == true:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
		get_window().borderless = true
	else:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (false) else Window.MODE_WINDOWED
		get_window().size = Vector2(640,480)
		get_window().borderless = false
	$VBoxContainer/Button2.grab_focus()
	Globals.tutorial = false
	$Timer.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_Button2_button_down():
	$VBoxContainer.hide()
	$TextureRect.hide()
	$AudioStreamPlayer.play()
	$ColorRect.show()
	diff = true
	$DifT.show()
	$VBoxContainer2.show()
func _on_Button3_button_down():
	print("quit")
	$AudioStreamPlayer.play()
	get_tree().quit()

func _on_Timer_timeout():
	play = true

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		$AudioStreamPlayer3.play()
	if diff == true and (Input.is_action_pressed("escape") or (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not diffbutts.pressed)):
		$ColorRect.hide()
		$VBoxContainer.show()
		$VBoxContainer2.hide()
		$DifT.hide()
		$TextureRect.show()
		diff = false

func _on_Button4_button_down():
	$VBoxContainer.hide()
	$TextureRect.hide()
	$AudioStreamPlayer.play()
	$ColorRect.show()
	$DifT.show()
	$options.show()


func _on_Button5_button_down():
	get_tree().change_scene_to_file("res://scenes/Gallery.tscn")


func _on_normal_button_down():
	get_tree().change_scene_to_file("res://scenes/real_levels/E1M1.tscn")
