extends Control

var is_paused = false setget set_is_paused

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		$quit.hide()
		self.is_paused = !is_paused
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("fire2"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_down():
	self.is_paused = false


func _on_Button2_button_down():
	get_tree().change_scene("res://scenes/real_levels/level_select.tscn")


func _on_quit_button_down():
	#$Options.hide()
	#$quit.hide()
	$Options/ConfirmationDialog.show()
	$Options.quit = true 

func _on_Button3_button_down():
	$Options.show()
	$Options.quit = false
	$quit.show()


func _on_Options_quit():
	$quit.hide()
