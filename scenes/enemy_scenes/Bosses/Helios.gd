extends KinematicBody

var path = []
var path_node = 0
var cur_path_idx = 0
var target = null
var speed = 5
var enemyhealth = 4000
var damage = 1
var attacktoggle = false
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
var strike = false
var state = IDLE
const TURN_SPEED = 2.2
var gravity_vec = Vector3()
onready var gore = preload("res://scenes/Guts.tscn")
onready var eyes = $Eyes
onready var Key = preload("res://scenes/IsorropiaKey3.tscn")
onready var accel = ACCEL_DEFAULT
var enemy_max_speed = 5000
var direction
var death = false
onready var raycast = $RayCast
onready var SunBeamD = $SunBeamD
signal freeze
var gravity = 100
var backwards = true
var threshold = .1
onready var player = $"../../FPS"
var enemy = self
var charge = false
var enemy_following3 = false
var enemy_following = false
var gravity_direction_and_speed = -100
var enemy_following2 = false
var up_vector3 = Vector3(0, 1, 0)
var velocity = Vector3.FORWARD * speed
func _physics_process(delta):
	if shoot == true:
		$SpotLightF.show()
		$Spatial/Helios/AnimationPlayer.play("default")
		if raycast.is_colliding():
			var hit2 = raycast.get_collider()
			if hit2.is_in_group("Player"):
				target.health -= damage
				$playerhurt.play(0.0001)
				print("player has ", target.health, " health left")
				print("enemy hit player")
			if target.health != 0 and target.health != -1:
				$Shootsound.play()
	if strike == true:
		$SpotLightD.show()
		if SunBeamD.is_colliding():
			var hit = SunBeamD.get_collider()
			if hit.is_in_group("Player"):
				target.health -= damage
				$playerhurt.play(0.0001)
				print("player has ", target.health, " health left")
				print("enemy hit player")
			if target.health != 0 and target.health != -1:
				$Shootsound.play()
	#if attacktoggle != false:
		#print("attacktoggle == true")
	#if attacktoggle != true:
		#print("attacktoggle == false"))
	if shoot == false:
		$SpotLightF.hide()
	if strike == false:
		$SpotLightD.hide()
	if enemyhealth != 100:
		$Healthbar/s/ProgressBar.value = enemyhealth
	if enemyhealth == 100:
		$Healthbar/s/ProgressBar.value = enemyhealth
	if shoot == false:
		$SpotLightF.hide()
	if enemy_following == true and backwards == false:
		move_and_slide(Vector3(min(target.translation.x - self.translation.x, enemy_max_speed), gravity_direction_and_speed, min(target.translation.z - self.translation.z, enemy_max_speed)), up_vector3)
	if enemy_following == true and backwards == true:
		move_and_slide(Vector3(min(target.translation.x - self.translation.x, enemy_max_speed), gravity_direction_and_speed, -min(target.translation.z - self.translation.z, enemy_max_speed)), up_vector3)
	if enemy_following and not is_on_floor():
		backwards = false
		move_and_slide(Vector3(min(player.translation.x - self.translation.x, enemy_max_speed), gravity_direction_and_speed, min(player.translation.z - self.translation.z, enemy_max_speed)), up_vector3)
func _ready():
	$SpotLightF.hide()
	$SpotLightD.hide()
	$Healthbar/s/ProgressBar.max_value = 4000
func _process(delta):
	match state:
		IDLE:
			speed = 0
		ALERT:
			if backwards == false:
				eyes.look_at(target.global_transform.origin, Vector3.DOWN)
				rotate_y(-deg2rad(eyes.rotation.y * TURN_SPEED))
			if backwards == true:
				self.rotation.y = 180
			if enemy_following2:
				self.translation.z = target.translation.z
				self.translation.y = target.translation.y + 100
				self.translation.x = target.translation.x
			if enemy_following3:
				self.translation.y = target.translation.y + 100
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
		$Spatial/Helios.queue_free()
		$CollisionShape.queue_free()
		get_tree().change_scene("res://scenes/real_levels/level_select.tscn")

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



func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		target = body
		state = ALERT
		target = body
		enemyspotted = true


func _on_backwardsTimer_timeout():
	if attacktoggle == false:
		shoot = true
		backwards = false
		$backwardsTimer.stop()
		print("Backwards Timer Timed Out")
		$shootTimer.start()


func _on_shootTimer_timeout():
	if attacktoggle == false:
		shoot = false
		enemy_following2 = true
		enemy_following = false
		print("Shoot Timer Timed Out")
		$SpotLightF.hide()
		$Shootsound.stop()
		$teleportTimer.start()
		attacktoggle = true


func _on_Arearsdtgf_body_entered(body):
	if body.is_in_group("player"):
		if attacktoggle == false and shoot != true and strike != true:
			backwards = true
			target = body
			print("Area Body Sensed")
			$backwardsTimer.start()


func _on_strikeTimer_timeout():
	if attacktoggle == true:
		strike = false
		enemy_following = true
		$SpotLightD.hide()
		self.translation.z = -371.362
		self.translation.y = 28.387
		self.translation.x = 5.455
		enemy_following3 = false
		print("striketimer timed out")
		attacktoggle = false
		enemy_following2 = false
		backwards = true
		$backwardsTimer.start()
		$shootTimer.stop()
		$teleportTimer.stop()
		$strikeTimer.stop()

func _on_teleportTimer_timeout():
	if attacktoggle == true:
		strike = true
		$shootTimer.stop()
		$backwardsTimer.stop()
		print("teleport timer timed out")
		$teleportTimer.stop()
		enemy_following3 = true
		enemy_following2 = false
		$strikeTimer.start()
