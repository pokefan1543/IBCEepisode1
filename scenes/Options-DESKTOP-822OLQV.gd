extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var balls = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Vsync.grab_focus()
	$VBoxContainer2/Master.value = AudioServer.get_bus_volume_db(0)
	$VBoxContainer2/Soundfx.value = AudioServer.get_bus_volume_db(1)
	$VBoxContainer2/Music.value = AudioServer.get_bus_volume_db(2)
	Globals.inverted = $VBoxContainer/Invert.pressed
	Globals.fullscreen = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Fullscreen_toggled(button_pressed):
	Globals.fullscreen = button_pressed
	if Globals.fullscreen == true:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
		get_window().borderless = true
	else:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (false) else Window.MODE_WINDOWED
		get_window().size = Vector2(640,480)
		get_window().borderless = false


func _on_Vsync_toggled(button_pressed):
	Globals.vsync = button_pressed
	if Globals.vsync == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (true) else DisplayServer.VSYNC_DISABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (false) else DisplayServer.VSYNC_DISABLED)


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
	$AudioStreamPlayer.stop()
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")


func _on_Button_pressed():
	$AudioStreamPlayer2.play()
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		$AudioStreamPlayer3.play()
	if Globals.boomer == true:
		$VBoxContainer/Boomer.button_pressed = true
	if Globals.boomer == false:
		$VBoxContainer/Boomer.button_pressed = false
	if Globals.fullscreen == false:
		$VBoxContainer/Fullscreen.button_pressed = false
	else:
		$VBoxContainer/Fullscreen.button_pressed = true
	if Globals.vsync == false:
		$VBoxContainer/Vsync.button_pressed = false
	if Globals.vsync == true:
		$VBoxContainer/Vsync.button_pressed = true
	$sense2.text = str(Globals.mouse_sense)
	
func _on_Boomer_toggled(button_pressed):
	if button_pressed == true:
		Globals.boomer = true
	else:
		Globals.boomer = false


func _on_Button_button_down():
	get_tree().change_scene_to_file("res://scenes/Gallery.tscn")


func _on_sense_value_changed(value):
	Globals.mouse_sense = value

func _on_Invert_toggled(button_pressed):
	Globals.inverted = button_pressed
