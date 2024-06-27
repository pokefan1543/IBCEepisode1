extends KinematicBody
var path = []
var path_node = 0
var cur_path_idx = 0
var target = null
var velocity = Vector3.ZERO
var speed = 200
var enemyhealth = 200
var damage = 5
var snap
onready var nav = get_parent()
const ACCEL_DEFAULT = 7
var movement = Vector3()
onready var eyes = $Eyes
var shoot = false
var enemyspotted = false
var accel = 0
enum {
	IDLE,
	ALERT,
	CHASE,
	SHOOT,
	HURT,
	DIE
}

var state = IDLE
const TURN_SPEED = 2
var gravity_vec = Vector3()
var enemy_max_speed = 200
var direction
var gravity = 100
var threshold = .1
onready var player = $"../../FPS"
var enemy = self
var charge = false
var enemy_following = false
var gravity_direction_and_speed = -100
var up_vector3 = Vector3(0, 1, 0)

func _physics_process(_delta):
	if enemy_following == true:
		move_and_slide(Vector3(min(player.translation.x - self.translation.x, enemy_max_speed), gravity_direction_and_speed, min(player.translation.z - self.translation.z, enemy_max_speed)), up_vector3)
func _process(_delta):
	match state:
		IDLE:
			speed = 0
		ALERT:
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(-eyes.rotation.y * TURN_SPEED))
			accel = ACCEL_DEFAULT
			enemy_following = true
	if enemyhealth <= 0:
		var deathcount = 0
		while deathcount != 100:
			deathcount += 1
			print("dying")
		if deathcount == 100: 
			Globals.defeats += 1
			queue_free()

func _on_sightrange_body_entered(body):
		if body.is_in_group("player"):
			state = ALERT
			target = body
			enemyspotted = true

func _on_Timer_timeout():
	$rawr.play()
	$Timer.start()
	if is_on_floor() and not is_on_ceiling() or is_on_wall():	
		gravity_direction_and_speed = 100000
		$Timer2.start()
		enemy_max_speed = 10000000000000000
		speed = 500
		move_and_slide(Vector3(min(player.translation.x - self.translation.x, enemy_max_speed), gravity_direction_and_speed, min(player.translation.z - self.translation.z, enemy_max_speed)), up_vector3)


func _on_BITEAREA_body_entered(body):
	if body.is_in_group("player"):
			state = ALERT
			target = body
			enemyspotted = true
			body.health -= 25


func _on_Timer2_timeout():
	gravity_direction_and_speed = -100
	enemy_max_speed = 200

func _ready():
	Globals.enemies += 1
