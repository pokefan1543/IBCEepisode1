extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var save = SaveGame.new()
var balls = false
var quit = false
signal quit 
# Called when the node enters the scene tree for the first time.
func _ready():
	$ConfirmationDialog.add_button("Don't Save",true,"nosave")
	$VBoxContainer/Vsync.grab_focus()
	$VBoxContainer/Boomer.pressed = Globals.boomer
	$VBoxContainer/Invert.pressed = Globals.inverted
	$VBoxContainer/Vsync.pressed = Globals.vsync
	$VBoxContainer/Fullscreen.pressed = Globals.fullscreen
	$VBoxContainer2/Master.value = AudioServer.get_bus_volume_db(0)
	$VBoxContainer2/Soundfx.value = AudioServer.get_bus_volume_db(1)
	$VBoxContainer2/Music.value = AudioServer.get_bus_volume_db(2)
	Globals.inverted = $VBoxContainer/Invert.pressed
	Globals.masterS = AudioServer.get_bus_volume_db(0)
	Globals.soundFX = AudioServer.get_bus_volume_db(1)
	Globals.music = AudioServer.get_bus_volume_db(2)
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
		OS.window_size = Vector2(640,480)
		OS.window_borderless = false


func _on_Vsync_toggled(button_pressed):
	Globals.vsync = button_pressed
	OS.vsync_enabled = button_pressed


func _on_Master_value_changed(value):
	volume(0, value)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)


func _on_Music_value_changed(value):
	volume(2, value)


func _on_Soundfx_value_changed(value):
	volume(1, value)


func _on_Button4_pressed():
	$ConfirmationDialog.show()


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
	$sense2.text = str(Globals.mouse_sense)
	
func _on_Boomer_toggled(button_pressed):
	if button_pressed == true:
		Globals.boomer = true
	else:
		Globals.boomer = false



func _on_sense_value_changed(value):
	Globals.mouse_sense = value

func _on_Invert_toggled(button_pressed):
	Globals.inverted = button_pressed


func _on_ConfirmationDialog_confirmed():
	if quit == false:
		save.write_savesettings()
		$AudioStreamPlayer.stop()
		get_tree().change_scene("res://scenes/TitleScreen.tscn")
	if quit == true:
		save.write_savesettings()
		emit_signal("quit")
		self.hide()


func _on_ConfirmationDialog_custom_action(action):
	if action == "nosave":
		if quit == false:
			$AudioStreamPlayer.stop()
			get_tree().change_scene("res://scenes/TitleScreen.tscn")
		if quit == true:
			emit_signal("quit")
			self.hide()
