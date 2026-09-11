extends State

var enemy_max_speed = 0
var gravity_direction_and_speed = -50
const TURN_SPEED = 2
var enemy : CharacterBody3D
var eyes : Node3D
var shootTimer : Timer 
var raycasta : RayCast3D
var target = null
var instance = null
var shootCount = 0
var canShoot = true
@onready var pulseball = preload("res://Scenes/pulse_ball.tscn")

func Enter():
	#identify key nodes for this scripts function
	enemy = $"../.."
	target = enemy.target
	shootCount = 0
	shootTimer = enemy.shootTimer 
	eyes = enemy.eyes
	raycasta = enemy.raycast
	#print("Entered Running State")#TEST

func Physics_Update(_delta: float):
	eyes.look_at(target.global_transform.origin, Vector3.UP)
	enemy.rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED))
	enemy.set_velocity(Vector3(min(target.position.x - enemy.position.x, enemy_max_speed), gravity_direction_and_speed, min(target.position.z - enemy.position.z, enemy_max_speed)))
	enemy.set_up_direction(Vector3.UP)
	enemy.move_and_slide()
	
	if enemy.kicked == true:
		Transitioned.emit(self, "Death")
	
	if canShoot == true:
		shootProj(pulseball, raycasta, 5, 50)
		shootCount += 1
		canShoot = false
	shootTimer.start()
	
	if enemy.enemyhealth <= enemy.startinghealth / 2:
		enemy.scream.play()
		Transitioned.emit(self, "Retreating")
		
	if shootCount >= 3:
		Transitioned.emit(self, "Running")
		
func shootProj(proj, raycaster, damage, speed):
	instance = proj.instantiate()
	instance.position = raycaster.global_position
	instance.basis = raycaster.global_transform.basis
	instance.DAMAGE = damage
	instance.SPEED = speed 
	instance.playerP = false
	get_parent().get_parent().get_parent().add_child(instance)

func Exit():
	pass


func _on_shoot_timer_timeout() -> void:
	canShoot = true
