extends Spatial

const ADS_LERP = 20

var mouse_mov 
var mouse_mov2 
var sway_threshold = 5
var sway_lerp = 5

export var camera_path : NodePath
var camera : Camera
export var sway_left : Vector3
export var sway_right : Vector3
export var sway_normal : Vector3
export var sway_up : Vector3
export var sway_down : Vector3
export var default_position : Vector3
export var ads_position : Vector3
export var buster_position : Vector3
export var shotgun_position : Vector3
export var shotgun_aim_position : Vector3
export var rifle_aim_position : Vector3
export var rifle_position : Vector3
export var railgun_position : Vector3
export var railgun_aim_position : Vector3
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
				rotation = rotation.linear_interpolate(sway_left, sway_lerp * delta)
			if mouse_mov < sway_threshold:
				rotation = rotation.linear_interpolate(sway_right, sway_lerp * delta)
			else:
				rotation = rotation.linear_interpolate(sway_normal, sway_lerp * delta)
		if mouse_mov2 != null:
			if mouse_mov2 > sway_threshold:
				rotation = rotation.linear_interpolate(sway_up, sway_lerp * delta)
			if mouse_mov2 < sway_threshold:
				rotation = rotation.linear_interpolate(sway_down, sway_lerp * delta)
			else:
				rotation = rotation.linear_interpolate(sway_normal, sway_lerp * delta)
		if Input.is_action_pressed("fire2") and $Buster.visible != true and $shotgun.visible != true and $M9PulseRifleHR.visible != true and $railgun.visible != true:
			rotation = rotation.linear_interpolate(sway_normal, 20 * delta)
			transform.origin = transform.origin.linear_interpolate(ads_position, ADS_LERP * delta)
		elif $Buster.visible != true:
			transform.origin = transform.origin.linear_interpolate(default_position, ADS_LERP * delta)
		elif $shotgun.visible == true and Input.is_action_just_released("fire2"):
			transform.origin = transform.origin.linear_interpolate(shotgun_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, fview["Default"], ADS_LERP * delta)
		elif $M9PulseRifleHR.visible == true and not Input.is_action_pressed("fire2"):
			transform.origin = transform.origin.linear_interpolate(rifle_position, ADS_LERP * delta)
		elif $railgun.visible == true:
			transform.origin = transform.origin.linear_interpolate(railgun_position, ADS_LERP * delta)
		else:
			transform.origin = transform.origin.linear_interpolate(buster_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, fview["Default"], ADS_LERP * delta)
		if Input.is_action_pressed("fire2") and $Buster.visible != true and $shotgun.visible == true and $railgun.visible != true and $M9PulseRifleHR.visible != true:
			rotation = rotation.linear_interpolate(sway_normal, 20 * delta)
			transform.origin = transform.origin.linear_interpolate(shotgun_aim_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, fview["ADSSCOPE"], ADS_LERP * delta)
		elif $shotgun.visible == true and not Input.is_action_pressed("fire2"):
			transform.origin = transform.origin.linear_interpolate(shotgun_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, fview["Default"], ADS_LERP * delta)
		if Input.is_action_pressed("fire2") and $Buster.visible != true and $M9PulseRifleHR.visible == true and $shotgun.visible != true and $railgun.visible != true:
			rotation = rotation.linear_interpolate(sway_normal, 20 * delta)
			transform.origin = transform.origin.linear_interpolate(rifle_aim_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, fview["ADSSCOPE"], ADS_LERP * delta)
			$M9PulseRifleHR/MeshInstance.hide()
			$M9PulseRifleHR/muzzleflash.hide()
			$scope/scopepop.show()
		if not Input.is_action_pressed("fire2") and $M9PulseRifleHR.visible == true and not Input.is_action_pressed("dash"):
			$scope/scopepop.hide()
			transform.origin = transform.origin.linear_interpolate(rifle_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, fview["Default"], ADS_LERP * delta)
			$M9PulseRifleHR/MeshInstance.show()
		if Input.is_action_pressed("fire2") and $M9PulseRifleHR.visible == false and $Buster.visible != true and $shotgun.visible != true and $railgun.visible != false:
			rotation = rotation.linear_interpolate(sway_normal, 20 * delta)
			transform.origin = transform.origin.linear_interpolate(railgun_aim_position, ADS_LERP * delta)
		if Input.is_action_pressed("fire2"): 
			transform.origin = transform.origin.linear_interpolate(buster_position, ADS_LERP * delta)
			camera.fov = lerp(camera.fov, fview["ADS"], ADS_LERP * delta)
		if Input.is_action_just_released("dash"):
			camera.fov = lerp(camera.fov, fview["Default"], ADS_LERP * delta)
