extends KinematicBody
var path = []
var path_node = 0
var cur_path_idx = 0
var target = null
var velocity = Vector3.ZERO
var speed = 10
var enemyhealth = 200
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
var shoot2 = false
var state = IDLE
onready var Shootsound = $AudioStreamPlayer
onready var playerhurtsound = $PLAYERHURT
const TURN_SPEED = 2
var gravity_vec = Vector3()
onready var raycast = $RayCast
onready var gore = preload("res://scenes/Guts.tscn")
onready var eyes = $Eyes
onready var Death = $Chaospawndeath
onready var accel = ACCEL_DEFAULT
onready var shoottimer = $Shoottimer
onready var agent : NavigationAgent = $NavigationAgent
var enemy_max_speed = 60
var direction
var death = false
var gravity = 100
var threshold = .1
onready var player = $"../../FPS"

var enemy = self
var enemy_following = false
var gravity_direction_and_speed = -50
var up_vector3 = Vector3(0, 1, 0)

func _ready():
	Globals.enemies += 1

func _physics_process(_delta):
	if enemy_following == true:
		move_and_slide(Vector3(min(player.translation.x - self.translation.x, enemy_max_speed), gravity_direction_and_speed, min(player.translation.z - self.translation.z, enemy_max_speed)), up_vector3)
		move_and_slide(Vector3(min(player.translation.x - self.translation.x, enemy_max_speed), gravity_direction_and_speed, min(player.translation.z - self.translation.z, enemy_max_speed)), up_vector3)
		$Chaossolideranimated/AnimationPlayer.play("mixamo.com")
		$muzzleflash.hide()
func _process(_delta):
	match state:
		IDLE:
			speed = 0
		ALERT:
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(-eyes.rotation.y * TURN_SPEED))
			accel = ACCEL_DEFAULT
			enemy_following = true
		DEATH:
			enemy_following = false
	if enemyhealth <= 0 and death == false:
		state = DEATH
		enemy_following = false
		death = true
		Death.play()
		$Shoottimer.stop()
		$deathTimer.start()

func _on_Shoottimer_timeout():
	if shoot2 == true:
		shoot = true
		$muzzleflash.show()
		if raycast.is_colliding():
			$Timer.start()
			var hit = raycast.get_collider()
			if hit.is_in_group("Player"):
				if target.health != 0 and target.health != -1:
					target.health -= damage
					playerhurtsound.play(0.0001)
			if target.health != 0 and target.health != -1:
				Shootsound.play()
		else:
			$Timer.start()
func _on_Timer_timeout():
	shoot = false


func _on_Timer2_timeout():
	$Chaossolideranimated.show()
	Globals.defeats += 1
	$muzzleflash.show()
	queue_free()

func _on_deathTimer_timeout():
	$Chaossolideranimated.hide()
	$muzzleflash.hide()
	$CollisionShape2.hide()
	$Timer2.start()
	$deathTimer.stop()




func _on_sightrange_body_entered(body):
	if body.is_in_group("player"):
		state = ALERT
		target = body
		$ALERTSOUND.play(0.001)
		enemyspotted = true
		shoottimer.start()
		shoot2 = true
		enemy_following = true
		if body.health == 0:
			shoottimer.stop()


func _on_sightrange_body_exited(body):
	if body.is_in_group("player"):
		shoot2 = false
		shoottimer.stop()
