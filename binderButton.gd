extends Button

export var action: String = "move_left" 
var save = SaveGame.new()

func _ready():
	save.load_savesettings()
	set_process_unhandled_key_input(false)
	#print("Globals.dash_key")
	#print(Globals.dash_key)
	#if action == "move_left":
		#InputMap.action_erase_events(action)
		#InputMap.action_add_event(action, Globals.l_key)
	#if action == "move_right":
		#InputMap.action_erase_events(action)
		#InputMap.action_add_event(action, Globals.r_key)
	#if action == "move_forward":
		#InputMap.action_erase_events(action)
		#InputMap.action_add_event(action, Globals.f_key) 
	#if action == "move_backward":
		#InputMap.action_erase_events(action)
		#InputMap.action_add_event(action, Globals.b_key)
	#if action == "jump":
		#InputMap.action_erase_events(action)
		#InputMap.action_add_event(action, Globals.j_key)
	#if action == "dash":
		#InputMap.action_erase_events(action)
		#InputMap.action_add_event(action, Globals.dash_key)
	#if action == "dive":
		#InputMap.action_erase_events(action)
		#InputMap.action_add_event(action, Globals.dive_key)
	display_key()

func display_key():
	text = "%s" % InputMap.get_action_list(action)[0].as_text()

func _unhandled_key_input(event):
	remap_key(event)
	pressed = false

func remap_key(event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	#if action == "move_left":
	#	Globals.l_key = event
	#if action == "move_right":
	#	Globals.r_key = event
	#if action == "move_forward":
	#	Globals.f_key = event
	#if action == "move_backward":
	#	Globals.b_key = event
	#if action == "jump":
	#	Globals.j_key = event
	#if action == "dash":
	#	Globals.dash_key = event
	#if action == "dive":
		#Globals.dive_key = event
	text = "%s" % event.as_text()

func _on_binderButton_toggled(button_pressed):
	set_process_unhandled_key_input(button_pressed)
	if button_pressed:
		text = "..."
	else:
		display_key()
