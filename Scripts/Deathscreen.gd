extends Control
var currentlevel = "res://scenes/real_levels/E1M1.tscn"



func _on_FPS_death():
	$Timer.start()
	#print("please play video")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	
	get_tree().paused = true
	get_window().always_on_top = (false)
	OS.alert("Magnus-1A has been destoryed.", "Fatal Error")
	get_tree().paused = false
	get_window().always_on_top = (true)
	get_window().mode = Window.MODE_MINIMIZED if (false) else Window.MODE_WINDOWED
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
	#$Popup.popup()
	#$Popup/VideoPlayer.play()
	#if $Popup/VideoPlayer.is_playing():
		#$Popup/VideoPlayer/AcceptDialog.popup()



func _on_AcceptDialog_custom_action(action):
	if action == "Quit":
		$Popup.popup()
		$Popup/VideoStreamPlayer.play()
		if $Popup/VideoStreamPlayer.is_playing():
			$Popup/VideoStreamPlayer/AcceptDialog.popup()


func _on_AcceptDialog_confirmed():
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")


func _on_Timer_timeout():
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
