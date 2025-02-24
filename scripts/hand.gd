extends Node3D

const ADS_LERP = 20

var mouse_mov 
var mouse_mov2 
var sway_threshold = 5
var sway_lerp = 5

@export var camera_path : NodePath
var camera : Camera3D
@export var sway_left : Vector3
@export var sway_right : Vector3
@export var sway_normal : Vector3
@export var sway_up : Vector3
@export var sway_down : Vector3
@export var default_position : Vector3
@export var ads_position : Vector3
@export var buster_position : Vector3
@export var shotgun_position : Vector3
@export var shotgun_aim_position : Vector3
@export var rifle_aim_position : Vector3
@export var rifle_position : Vector3
@export var railgun_position : Vector3
@export var railgun_aim_position : Vector3
var fview = {"Default": 118, "ADS": 50, "ADSSCOPE": 10}

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node(camera_path)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative.x
		mouse_mov2 = -event.relative.y
func _process(delta):
		if mouse_mov != null:
			if mouse_mov > sway_threshold:
				rotation = rotation.lerp(sway_left, sway_lerp * delta)
			if mouse_mov < sway_threshold:
				rotation = rotation.lerp(sway_right, sway_lerp * delta)
			else:
				rotation = rotation.lerp(sway_normal, sway_lerp * delta)
		if mouse_mov2 != null:
			if mouse_mov2 > sway_threshold:
				rotation = rotation.lerp(sway_up, sway_lerp * delta)
			if mouse_mov2 < sway_threshold:
				rotation = rotation.lerp(sway_down, sway_lerp * delta)
			else:
				rotation = rotation.lerp(sway_normal, sway_lerp * delta)
		if Input.is_action_pressed("altfire") and $Buster.visible != true and $shotgun.visible != true and $M9PulseRifleHR.visible != true and $railgun.visible != true:
			rotation = rotation.lerp(sway_normal, 20 * delta)
			transform.origin = transform.origin.lerp(ads_position, ADS_LERP * delta)
		elif $Buster.visible != true:
			transform.origin = transform.origin.lerp(default_position, ADS_LERP * delta)
		elif $shotgun.visible == true and Input.is_action_just_released("altfire"):
			transform.origin = transform.origin.lerp(shotgun_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, float(fview["Default"]), ADS_LERP * delta)
		elif $M9PulseRifleHR.visible == true and not Input.is_action_pressed("altfire"):
			transform.origin = transform.origin.lerp(rifle_position, ADS_LERP * delta)
		elif $railgun.visible == true:
			transform.origin = transform.origin.lerp(railgun_position, ADS_LERP * delta)
		else:
			transform.origin = transform.origin.lerp(buster_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, float(fview["Default"]), ADS_LERP * delta)
		if Input.is_action_pressed("altfire") and $Buster.visible != true and $shotgun.visible == true and $railgun.visible != true and $M9PulseRifleHR.visible != true:
			rotation = rotation.lerp(sway_normal, 20 * delta)
			transform.origin = transform.origin.lerp(shotgun_aim_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, float(fview["ADSSCOPE"]), ADS_LERP * delta)
		elif $shotgun.visible == true and not Input.is_action_pressed("altfire"):
			transform.origin = transform.origin.lerp(shotgun_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, float(fview["Default"]), ADS_LERP * delta)
		if Input.is_action_pressed("altfire") and $Buster.visible != true and $M9PulseRifleHR.visible == true and $shotgun.visible != true and $railgun.visible != true:
			rotation = rotation.lerp(sway_normal, 20 * delta)
			transform.origin = transform.origin.lerp(rifle_aim_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, float(fview["ADSSCOPE"]), ADS_LERP * delta)
			$M9PulseRifleHR/MeshInstance3D.hide()
			$M9PulseRifleHR/muzzleflash.hide()
			$scope/scopepop.show()
		if not Input.is_action_pressed("altfire") and $M9PulseRifleHR.visible == true and not Input.is_action_pressed("dash"):
			$scope/scopepop.hide()
			transform.origin = transform.origin.lerp(rifle_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, float(fview["Default"]), ADS_LERP * delta)
			$M9PulseRifleHR/MeshInstance3D.show()
		if Input.is_action_pressed("altfire") and $M9PulseRifleHR.visible == false and $Buster.visible != true and $shotgun.visible != true and $railgun.visible != false:
			rotation = rotation.lerp(sway_normal, 20 * delta)
			transform.origin = transform.origin.lerp(railgun_aim_position, ADS_LERP * delta)
		if Input.is_action_pressed("altfire"): 
			transform.origin = transform.origin.lerp(buster_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, float(fview["ADS"]), ADS_LERP * delta)
		if Input.is_action_just_released("dash"):
			camera.fov = lerp(camera.fov, float(fview["Default"]), ADS_LERP * delta)
