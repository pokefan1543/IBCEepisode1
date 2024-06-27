extends HBoxContainer

signal change_button_pressed

func initialize(action_name, key, can_change):
	$Action.text = action_name.capitalize()
	$Key.text = OS.get_scancode_string(key)
	$ChangeButton.disabled = not can_change

func update_key(scancode):
	$Key.text = "%s Key" % scancode.as_text()

func _on_ChangeButton_pressed():
	emit_signal('change_button_pressed')
	print("change key button pressed")
