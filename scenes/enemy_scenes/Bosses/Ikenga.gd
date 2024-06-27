extends KinematicBody

var path = []
var path_node = 0
var cur_path_idx = 0
var target = null
var speed = 10
var enemyhealth = 3000
var damage = 5
var snap
onready var nav = get_parent()
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
	DEATH
}

var state = IDLE
const TURN_SPEED = 2
var gravity_vec = Vector3()
onready var raycast = $RayCast
onready var gore = preload("res://scenes/Guts.tscn")
onready var eyes = $Eyes
onready var Key = preload("res://scenes/IsorropiaKey2.tscn")
onready var accel = ACCEL_DEFAULT
onready var agent : NavigationAgent = $NavigationAgent
var enemy_max_speed = 5000
var direction
var death = false
signal freeze
var gravity = 100
var threshold = .1
onready var player = $"../../FPS"
var enemy = self
var charge = false
var enemy_following = false
var gravity_direction_and_speed = -100
var up_vector3 = Vector3(0, 1, 0)
var velocity = Vector3.FORWARD * speed
func _physics_process(delta):
	if enemyhealth != 100:
		$Healthbar/s/ProgressBar.value = enemyhealth
	if enemyhealth == 100:
		$Healthbar/s/ProgressBar.value = enemyhealth
	if charge == true and enemy_following == true:
		move_to_target(delta)
	if enemy_following == true and charge == false:
		move_and_slide(Vector3(min(player.translation.x - self.translation.x, enemy_max_speed), gravity_direction_and_speed, min(player.translation.z - self.translation.z, enemy_max_speed)), up_vector3)
func _process(_delta):
	match state:
		IDLE:
			speed = 0
		ALERT:
			if is_on_wall():
				eyes.look_at(-target.global_transform.origin, Vector3.DOWN)
				speed = -500
				charge = false
			if charge == false:
				eyes.look_at(target.global_transform.origin, Vector3.DOWN)
				rotate_y(deg2rad(-eyes.rotation.y * TURN_SPEED))
			accel = ACCEL_DEFAULT
			enemy_following = true
		DEATH:
			enemy_following = false
	if enemyhealth <= 0 and death == false:
		state = DEATH
		var key = Key.instance()
		self.add_child_below_node(player, key)
		gravity_direction_and_speed = 0
		enemy_max_speed = 0
		enemy_following = false
		death = true
		speed = 0
		$Ikenga.queue_free()
		$CollisionShape.queue_free()
		$freezetimer.stop()
		$Timer.start()
func _on_SightRange_body_entered(body):
	if body.is_in_group("player"):
			target = body
			state = ALERT
			target = body
			enemyspotted = true

func move_to_target(delta):
	look_at(-target.global_transform.origin, Vector3.UP)
	var direction = (target.transform.origin - transform.origin.normalized())
	move_and_slide(direction * speed * delta, Vector3.UP)
func _on_freezetimer_timeout():
	if enemyhealth > 0 and death == false:
		$unfreezetimer.start()
		charge = true
		speed = 100000
		frameFreeze(0.01, 2.0)
	
func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	yield(get_tree().create_timer(duration * timeScale), "timeout")
	Engine.time_scale = 1.0
		  


func _on_unfreezetimer_timeout():
	speed = 0
	charge = false
