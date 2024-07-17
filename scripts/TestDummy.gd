extends KinematicBody
var path = []
var cur_path_idx = 0
var target = null
var velocity = Vector3.ZERO
var speed = 10
var enemyhealth = 50
var damage = 5
var snap
onready var gore = preload("res://scenes/Guts.tscn")
onready var bullets = preload("res://scenes/bullets.tscn")
onready var nav = get_parent()
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
onready var Shootsound = $AudioStreamPlayer
onready var playerhurtsound = $PLAYERHURT
const TURN_SPEED = 2
var gravity_vec = Vector3()
onready var raycast = $RayCast
onready var eyes = $Eyes
onready var Death = $Chaospawndeath
onready var accel = ACCEL_DEFAULT
onready var shoottimer = $Shoottimer
onready var agent : NavigationAgent = $NavigationAgent
var enemy_max_speed = 20
var direction
var shoot2 = false
var shoot = false
var gravity = 100
var threshold = .1
var dead = false
var death = false
var kicked = false
onready var player = $"../../FPS"
onready var timer = $Timer
var enemy = self
var enemy_following = false
var gravity_direction_and_speed = -50
var up_vector3 = Vector3(0, 1, 0)
var shootime = 0

func _physics_process(delta):
	if enemy_following == true and shoot != true and death != true:
		$walk.show()
		$shoot.hide()
		$idle.hide()
		$walk/RootNode/AnimationPlayer.play("mixamo.com")
		move_and_slide(Vector3(min(player.translation.x - self.translation.x, enemy_max_speed), gravity_direction_and_speed, min(player.translation.z - self.translation.z, enemy_max_speed)), up_vector3)
func _process(delta):
	match state:
		IDLE:
			speed = 0
		ALERT:
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(eyes.rotation.y * TURN_SPEED))
			accel = ACCEL_DEFAULT
			
		DEATH:
			enemy_following = false
	if enemyhealth <= 0 and death == false:
		state = DEATH
		enemy_following = false
		death = true
		Death.play()
		$Shoottimer.stop()
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
			shoottimer.start()
			enemy_following = true
			if body.health == 0:
				shoottimer.stop()

func _on_Shoottimer_timeout():
	print("enemy has shot")
	shoot = true
	$shoot/RootNode/AnimationPlayer.play("mixamo.com")
	$walk.hide()
	$shoot.show()
	if raycast.is_colliding() and enemy_following == true:
		var hit = raycast.get_collider()
		timer.start()
		if hit.is_in_group("player"):
			if target.health != 0 or target.health == -1:
				target.health -= damage
				playerhurtsound.play(0.0001)
				print("player has ", target.health, " health left")
				print("enemy hit player")
			if target.health == -1:
					state = IDLE
					shoottimer.stop()
					state = IDLE
					shoottimer.stop()
					Shootsound.stop()
					timer.start()
					$ALERTSOUND.stop()
					print("I need to stop")	
		if target.health != 0 and target.health != -1:
			Shootsound.play()
	else:
		timer.start()

func _on_Timer2_timeout():
	dead = true
	set_collision_layer_bit(2, false)
	set_collision_layer_bit(1, false)
	set_collision_layer_bit(3, false)
	set_collision_mask_bit(1, false)
	set_collision_mask_bit(1, false)
	set_collision_mask_bit(3, false)
	self.translation.x = 10000
	remove_from_group("enemy")
	$sightrange.hide()

func _on_deathTimer_timeout():
	var g = gore.instance()
	var b = bullets.instance()
	var g1 = gore.instance()
	var g2 = gore.instance()
	var g3 = gore.instance()
	var g4 = gore.instance()
	var g5 = gore.instance()
	var g6 = gore.instance()
	self.add_child(g)
	b.set_as_toplevel(true)
	self.add_child(b)
	b.set_as_toplevel(true)
	self.add_child(g1)
	self.add_child(g2)
	self.add_child(g3)
	self.add_child(g4)
	self.add_child(g5)
	self.add_child(g6)
	$walk.queue_free()
	$shoot.queue_free()
	dead = true
	$Timer2.start()
	remove_from_group("enemy")
	$sightrange.hide()
	$deathTimer.stop()
	$CollisionShape.queue_free()
	$Timer3.start()
func _on_Timer_timeout():
	shoot = false
	
func _on_sightrange_body_exited(body):
	shoot2 = true
	shoottimer.stop()
	
func _ready():
	Globals.enemies += 1


func _on_Timer3_timeout():
	Globals.defeats += 1
	print("Globals.defeats for testdummy:")
	print(Globals.defeats)
	queue_free()
