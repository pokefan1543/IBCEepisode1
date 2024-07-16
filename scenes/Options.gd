extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Vsync.grab_focus()
	$VBoxContainer2/Master.value = AudioServer.get_bus_volume_db(0)
	$VBoxContainer2/Soundfx.value = AudioServer.get_bus_volume_db(1)
	$VBoxContainer2/Music.value = AudioServer.get_bus_volume_db(2)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Fullscreen_toggled(button_pressed):
	Globals.fullscreen = button_pressed
	if Globals.fullscreen == true:
		OS.window_fullscreen = true
		OS.window_borderless = true
	else:
		OS.window_fullscreen = false
		OS.window_borderless = false


func _on_Vsync_toggled(button_pressed):
	Globals.vsync = button_pressed
	if Globals.vsync == true:
		OS.vsync_enabled = true
	else:
		OS.vsync_enabled = false


func _on_Master_value_changed(value):
	volume(0, value)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)


func _on_Music_value_changed(value):
	volume(2, value)


func _on_Soundfx_value_changed(value):
	volume(1, value)


func _on_Button4_pressed():
	print("ACESSED TITLE SCREEN")
	get_tree().change_scene("res://scenes/TitleScreen.tscn")


func _on_Button_pressed():
	$AudioStreamPlayer2.play()
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		$AudioStreamPlayer3.play()
	if Globals.boomer == true:
		$VBoxContainer/Boomer.pressed = true
	if Globals.boomer == false:
		$VBoxContainer/Boomer.pressed = false
	if Globals.fullscreen == false:
		$VBoxContainer/Fullscreen.pressed = false
	else:
		$VBoxContainer/Fullscreen.pressed = true
	if Globals.vsync == false:
		$VBoxContainer/Vsync.pressed = false
	if Globals.vsync == true:
		$VBoxContainer/Vsync.pressed = true
	$sense2.text = str(Globals.mouse_sense)

func _on_Boomer_toggled(button_pressed):
	if button_pressed == true:
		Globals.boomer = true
	else:
		Globals.boomer = false


func _on_Button_button_down():
	get_tree().change_scene("res://scenes/Gallery.tscn")


func _on_sense_value_changed(value):
	Globals.mouse_sense = value


func _on_Control_focus_entered():
	$AudioStreamPlayer.play()
