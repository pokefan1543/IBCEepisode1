extends CharacterBody3D
var path = []
var cur_path_idx = 0
var target = null
var velocity2 = Vector3.ZERO
var speed = 10
var enemyhealth = 50
var damage = 10
var snap
@onready var gore = preload("res://scenes/Guts.tscn")
@onready var bullets = preload("res://scenes/bullets.tscn")
@onready var nav = get_parent()
const ACCEL_DEFAULT = 7
var movement = Vector3()
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
@onready var Shootsound = $AudioStreamPlayer
@onready var playerhurtsound = $PLAYERHURT
const TURN_SPEED = 2
var gravity_direction = Vector3()
@onready var accel = ACCEL_DEFAULT
var enemy_max_speed = 20
var direction
var shoot2 = false
var shoot = false
var gravity = 100
var threshold = .1
var dead = false
var death = false
var kicked = false
@onready var player = $"../../FPS"
@onready var timer = $Timer
var enemy = self
var enemy_following = false
var gravity_direction_and_speed = -50
var up_vector3 = Vector3(0, 1, 0)
var shootime = 0

func _process(delta):
	if enemyhealth <= 0 and death == false:
		state = DEATH
		enemy_following = false
		death = true
		if kicked == false:
			$deathTimer.start()
	if kicked == true and dead == false:
		enemyhealth = 0
		$deathTimer.wait_time = 0.01
		$deathTimer.start()
		kicked = false
func _on_sightrange_body_entered(body):
		if body.is_in_group("player"):
			state = ALERT
			target = body
			shoot2 = true
			$ALERTSOUND.play(0.001)
			enemyspotted = true
			enemy_following = true

func _on_Timer2_timeout():
	dead = true
	set_collision_layer_value(2, false)
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(3, false)
	remove_from_group("enemy")
	$CollisionShape3D.hide()
	$Timer.start()

func _on_deathTimer_timeout():
	dead = true
	$Timer2.start()
	remove_from_group("enemy")
	$CollisionShape3D.hide()
	$deathTimer.stop()

func _on_Timer_timeout():
	queue_free()
