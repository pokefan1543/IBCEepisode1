extends CharacterBody3D
var path = []
var path_node = 0
var cur_path_idx = 0
var target = null
var velocity = Vector3.ZERO
var speed = 100
var enemyhealth = 200
var damage = 5
var snap
@onready var nav = get_parent()
const ACCEL_DEFAULT = 7
var movement = Vector3()
var shoot = false
var enemyspotted = false
enum {
	IDLE,
	ALERT,
	CHASE,
	SHOOT,
	HURT,
	DIE
}

var state = IDLE
@onready var Shootsound = $AudioStreamPlayer
@onready var playerhurtsound = $PLAYERHURT
const TURN_SPEED = 5
var gravity_direction = Vector3()
@onready var raycast = $RayCast3D
@onready var pulseball = preload("res://scenes/PulseBall.tscn")
@onready var eyes = $Eyes
@onready var Death = $Chaospawndeath
@onready var accel = ACCEL_DEFAULT
@onready var shoottimer = $Shoottimer
@onready var agent : NavigationAgent3D = $NavigationAgent3D
var enemy_max_speed = 20
var direction
var gravity = 100
var threshold = .1
@onready var player = $"../../FPS"
var enemy = self
var enemy_following = false
var gravity_direction_and_speed = -100
var up_vector3 = Vector3(0, 1, 0)

func _physics_process(_delta):
	$muzzleflash.hide()
	if enemy_following == true:
		set_velocity(Vector3(min(player.position.x - self.position.x, enemy_max_speed), 0,  min(player.position.z - self.position.z, enemy_max_speed)))
		set_up_direction(up_vector3)
		move_and_slide()
func _process(_delta):
	match state:
		IDLE:
			speed = 0
		ALERT:
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg_to_rad(-eyes.rotation.y * TURN_SPEED))
			rotate_x(deg_to_rad(-eyes.rotation.x * TURN_SPEED))
			rotate_z(deg_to_rad(-eyes.rotation.z * TURN_SPEED))
			accel = ACCEL_DEFAULT
			enemy_following = true
	if enemyhealth <= 0:
		Death.play()
		var deathcount = 0
		while deathcount != 100:
			deathcount += 1
			print("dying")
		if deathcount == 100: 
			queue_free()

func _on_sightrange_body_entered(body):
		if body.is_in_group("player"):
			state = ALERT
			target = body
			$ALERTSOUND.play(0.001)
			enemyspotted = true
			shoottimer.start()
			if body.health == 0:
				shoottimer.stop()

func _on_Shoottimer_timeout():
	print("ship has shot")
	shoot = true
	$muzzleflash.show()
	if raycast.is_colliding():
		var hit = raycast.get_collider()
		$Timer.start()
		print("ship's raycast hited something")
		if hit.is_in_group("player"):
			print("ship's raycast hits player")
			if target.health != 0 and target.health != -1:
				target.health -= damage
				playerhurtsound.play(0.0001)
				print("player has ", target.health, " health left")
				print("enemy hit player")
			if target.health == -1 or target.health == 0:
					state = IDLE
					shoottimer.stop()
					state = IDLE
					shoottimer.stop()
					Shootsound.stop()
					$Timer.start()
					$ALERTSOUND.stop()
					print("I need to stop")	
		if target.health != 0 and target.health != -1:
			Shootsound.play()
	else:
		$Timer.start()
func _on_Timer_timeout():
	shoot = false
