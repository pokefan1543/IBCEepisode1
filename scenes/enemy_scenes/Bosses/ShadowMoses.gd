extends KinematicBody
var path = []
var cur_path_idx = 0
var target = null
var velocity = Vector3.ZERO
var speed = 10
var enemyhealth = 5000
var damage = 10
var snap
var attack = false
var burstNum = 0
var charge2 = false
var charge = false
onready var gore = preload("res://scenes/Guts.tscn")
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
onready var Shootsound = $Buster/muzzleflash/firesound
onready var playerhurtsound = $PLAYERHURT
const TURN_SPEED = 0.4
var gravity_vec = Vector3()
onready var eyes = $Eyes
onready var Death = $Chaospawndeath
onready var accel = ACCEL_DEFAULT
onready var shoottimer = $shoottimer
onready var agent : NavigationAgent = $NavigationAgent
var enemy_max_speed = 50
var direction
var shoot = false
var gravity = 100
var threshold = .1
var death = false
var kicked = false
onready var player = $"../../FPS"
onready var timer = $Timer
var enemy = self
var enemy_following = false
var gravity_direction_and_speed = -10
var up_vector3 = Vector3(0, 1, 0)
var shootime = 0

func move_to_target(delta):
	look_at(-target.global_transform.origin, Vector3.UP)
	var direction = (target.transform.origin - transform.origin.normalized())
	move_and_slide(-direction * speed * delta, Vector3.UP)
func move_to_target2(delta):
	print("move to target 2")
	look_at(-target.global_transform.origin, Vector3.UP)
	var direction = (target.transform.origin - transform.origin.normalized())
	move_and_slide(direction * speed * delta, Vector3.UP)
func _physics_process(delta):
	if rotation.x != 0:
		rotation.x = 0
	if enemyhealth != 100:
		$Healthbar/s/ProgressBar.value = enemyhealth
	if enemyhealth == 100:
		$Healthbar/s/ProgressBar.value = enemyhealth
	if charge2 == true and enemy_following == true:
		move_to_target2(delta)
	if charge == true and enemy_following == true:
		move_to_target(delta)
		$ShadowMosesAnimated/AnimationPlayer.play("Armature|mixamocom|Layer0")
	if enemy_following == true and shoot != true and charge == false:
		$ShadowMosesAnimated/AnimationPlayer.play("Armature|mixamocom|Layer0")
		move_and_slide(Vector3(min(player.translation.x - self.translation.x, enemy_max_speed), gravity_direction_and_speed, min(player.translation.z - self.translation.z, enemy_max_speed)), up_vector3)
func _process(delta):
	match state:
		IDLE:
			speed = 0
		ALERT:
			$Eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(-deg2rad(eyes.rotation.y * TURN_SPEED))
			accel = ACCEL_DEFAULT
			
		DEATH:
			enemy_following = false
	if enemyhealth <= 0 and death == false:
		Globals.level14unlocked = true
		get_tree().change_scene("res://scenes/real_levels/level_select2.tscn")

func _on_freezetimer_timeout():
	if enemyhealth > 0 and death == false:
		$unfreezetimer.start()
		charge = true
		speed = 125

func _on_unfreezetimer_timeout():
	speed = 0
	charge2 = false
	charge = false

func _on_SightRange_body_entered(body):
	if body.is_in_group("player"):
		state = ALERT
		target = body
		enemyspotted = true
		$shoottimer.start()
		enemy_following = true
		if body.health == 0:
			shoottimer.stop()

func _on_shoottimer_timeout():
	print("enemy has shot")
	shoot = true
	$Buster/muzzleflash.show()
	$Buster2/muzzleflash.show()
	$Buster3/muzzleflash.show()
	$Buster4/muzzleflash.show()
	$muzzletimer.start(0.1)
	if $Buster/RayCast.is_colliding():
		var hit = $Buster/RayCast.get_collider()
		if hit.is_in_group("player"):
			if player.health != 0 or player.health != -1:
				player.health -= damage
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
	if $Buster2/RayCast.is_colliding():
		var hit = $Buster2/RayCast.get_collider()
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
	if $Buster3/RayCast.is_colliding():
		var hit = $Buster3/RayCast.get_collider()
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
	if $Buster4/RayCast.is_colliding():
		var hit = $Buster4/RayCast.get_collider()
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
	$shoottimer.start()


func _on_muzzletimer_timeout():
	$Buster/muzzleflash.hide()
	$Buster2/muzzleflash.hide()
	$Buster3/muzzleflash.hide()
	$Buster4/muzzleflash.hide()


func _on_dasharea_body_entered(body):
	print("dasharea entered")
	$unfreezetimer.start()
	charge = true
	speed = 125

func _on_d_body_entered(body):
	if body.is_in_group("player"):
		print("Bitearea entered")
		speed = 125
		attack = true
		charge2 = true
		$unfreezetimer.start()


func _on_d2_body_entered(body):
	print("Bitearea2 entered")
	speed = 125
	attack = true
	charge2 = true
	$unfreezetimer.start()


func _on_Selfdamagearea_body_entered(body):
	if body.is_in_group("player") and attack == true:
		print("Bitearea entered")
		speed = 125
		body.health -= 25
		attack = false
		charge2 = true
		$unfreezetimer.start()
