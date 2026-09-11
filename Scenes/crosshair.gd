extends Control

var zoom = false

var mouse_mov 
var mouse_mov2 
var sway_threshold = 5
var sway_lerp = 5
@export var sway_left : Vector2
@export var sway_right : Vector2
@export var sway_normal : Vector2
@export var sway_up : Vector2
@export var sway_down : Vector2

func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative.x
		mouse_mov2 = -event.relative.y
		
func _process(delta):
		if mouse_mov != null:
			if mouse_mov > sway_threshold:
				$Face2.position = $Face2.position.lerp(sway_left, sway_lerp * delta)
			if mouse_mov < sway_threshold:
				$Face2.position = $Face2.position.lerp(sway_right, sway_lerp * delta)
			else:
				$Face2.position = $Face2.position.lerp(sway_normal, sway_lerp * delta)
		if mouse_mov2 != null:
			if mouse_mov2 > sway_threshold:
				$Face2.position = $Face2.position.lerp(sway_up, sway_lerp * delta)
			if mouse_mov2 < sway_threshold:
				$Face2.position = $Face2.position.lerp(sway_down, sway_lerp * delta)
			else:
				$Face2.position = $Face2.position.lerp(sway_normal, sway_lerp * delta)
				
#func _physics_process(delta):
	#if Input.is_action_just_pressed("fire2") and zoom != true:
		#$AnimationPlayer.play("Crosshairzoom")
		#zoom = true
	#if Input.is_action_just_released("fire2") and zoom == true:
		#$AnimationPlayer.play("Crosshairzoomout")
		#zoom = false
