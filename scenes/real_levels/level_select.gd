extends Control
var play = false
func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	yield(get_tree().create_timer(duration * timeScale), "timeout")
	Engine.time_scale = 1.0
func _ready():
	$AnimationPlayer.play("Anim")
	frameFreeze(1, 2.0)
	get_tree().paused = false
	Globals.itemCount = 0
	Globals.enemies = 0
	Globals.defeats = 0
	Globals.time = 0
	$quit.grab_focus()
	Globals.tutorial = false
	$Timer.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$VideoPlayer.play()
	$vidtim.start()
func _physics_process(delta):
	$Container/Level.text = str(Globals.level)
	$Container/ProgressBar.max_value = Globals.level * 500 + 500
	$Container/nextLevel.text = str(Globals.level + 1)
	$Container/ProgressBar.value = Globals.xp
	if $Popup/cheat.text == "asteroid":
		Globals.level4unlocked = true
		$AudioStreamPlayer.play()
		$Popup.hide()
	if $Popup/cheat.text == "military":
		Globals.level2unlocked = true
		$AudioStreamPlayer.play()
		$Popup.hide()
	if $Popup/cheat.text == "hangar":
		Globals.level3unlocked = true
		$AudioStreamPlayer.play()
		$Popup.hide()
	if $Popup/cheat.text == "base":
		Globals.level5unlocked = true
		$AudioStreamPlayer.play()
		$Popup.hide()
	if $Popup/cheat.text == "miniboss":
		Globals.level6unlocked = true
		$AudioStreamPlayer.play()
		$Popup.hide()
	if $Popup/cheat.text == "platforms":
		Globals.level7unlocked = true
		$AudioStreamPlayer.play()
		$Popup.hide()
	if $Popup/cheat.text == "boss":
		Globals.level8unlocked = true
		$AudioStreamPlayer.play()
		$Popup.hide()
	#quit
	if play == true: 
		if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			$bruh.play()
		if Input.is_action_just_pressed("Q") or Input.is_action_just_pressed("escape"):
			print("ACESSED TITLE SCREEN")
			get_tree().change_scene("res://scenes/TitleScreen.tscn")
		if Input.is_action_just_pressed("cheat"):
			$Popup.show()


func _on_Button_pressed():
	print("entered E1M1")
	Globals.enterLevel = "1"
	get_tree().change_scene("res://scenes/loading.tscn")



func _on_quit_pressed():
	print("ACESSED TITLE SCREEN")
	get_tree().change_scene("res://scenes/episode_select.tscn")


func _on_Button3_pressed():
	if Globals.level3unlocked == true:
		print("entered E1M3")
		Globals.enterLevel = "3"
		get_tree().change_scene("res://scenes/loading.tscn")
	else:
		$buzzer.play()


func _on_Button4_pressed():
	if Globals.level4unlocked == true:
		print("entered E1M4")
		Globals.enterLevel = "4"
		get_tree().change_scene("res://scenes/loading.tscn")
	else:
		$buzzer.play()


func _on_cheaterbutton_pressed():
	$Popup.show()

func _on_Button5_pressed():
	if Globals.level5unlocked == true:
		print("entered E1M5")
		Globals.enterLevel = "5"
		get_tree().change_scene("res://scenes/loading.tscn")
	else:
		$buzzer.play()


func _on_Button6_pressed():
	if Globals.level6unlocked == true:
		print("entered E1M6")
		Globals.enterLevel = "6"
		get_tree().change_scene("res://scenes/loading.tscn")
	else:
		$buzzer.play()


func _on_Button7_pressed():
	if Globals.level7unlocked == true:
		print("entered E1M7")
		Globals.enterLevel = "7"
		get_tree().change_scene("res://scenes/loading.tscn")
	else:
		$buzzer.play()


func _on_Button8_pressed():
	if Globals.level8unlocked == true:
		print("entered E1M8")
		Globals.enterLevel = "8"
		get_tree().change_scene("res://scenes/loading.tscn")
	else:
		$buzzer.play()


func _on_Timer_timeout():
	play = true



func _on_vidtim_timeout():
	$VideoPlayer.play()
	$vidtim.start()


func _on_Button2_pressed():
	if Globals.level2unlocked == true:
		print("entered E1M2")
		Globals.enterLevel = "2"
		get_tree().change_scene("res://scenes/loading.tscn")


func _on_tutorialbutton_button_down():
	get_tree().change_scene("res://scenes/tutorials/Introtut.tscn")


func _on_objectivebutton_button_down():
	var dialog = Dialogic.start("object")
	dialog.pause_mode = PAUSE_MODE_PROCESS
	get_parent().add_child(dialog)
	dialog.connect("timeline_end",self,"end_dialog")
	get_tree().paused = true
