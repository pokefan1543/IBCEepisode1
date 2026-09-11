extends State

var enemy_max_speed = 10
var gravity_direction_and_speed = -50
const TURN_SPEED = 2
var enemy : CharacterBody3D
var eyes : Node3D
var target = null
var RoF = true #true if rising, false is falling
var VarTurning = 0 #Helps make the pawn zig-zag side to side
var turn = false

func Enter():
	#identify key nodes for this scripts function
	enemy = $"../.."
	target = enemy.target
	eyes = enemy.eyes
	if enemy.is_avoiding == true:
		enemy_max_speed = 1
		enemy.Timer1.start()
	if enemy.is_avoiding == false:
		enemy_max_speed = 10
	#print("Entered Running State")#TEST

func Physics_Update(_delta: float):
	if VarTurning == 30:
		RoF = false
	if enemy.kicked == true:
		Transitioned.emit(self, "Death")
	if VarTurning == -30:
		RoF = true
	if VarTurning != 30 and RoF == true:
		VarTurning += 5
	elif VarTurning != -30 and RoF == false:
		VarTurning += -5
	eyes.look_at(target.global_transform.origin, Vector3.UP)
	if turn == false:
		enemy.rotate_y(deg_to_rad((-eyes.rotation.y * TURN_SPEED)+VarTurning))
		enemy.set_velocity(Vector3(-min(target.position.x - enemy.position.x, enemy_max_speed) + VarTurning, gravity_direction_and_speed, -min(target.position.z - enemy.position.z, enemy_max_speed) + VarTurning))
	if enemy.is_on_wall() and turn == false:
		turn = true
	if enemy.is_on_wall() and turn == true:
		turn = false
	if turn == true:
		enemy.rotate_y(deg_to_rad((eyes.rotation.y * TURN_SPEED)+VarTurning))
		enemy.set_velocity(Vector3(min(target.position.x - enemy.position.x, enemy_max_speed) + VarTurning, gravity_direction_and_speed, min(target.position.z - enemy.position.z, enemy_max_speed) + VarTurning))
	enemy.set_up_direction(Vector3.UP)
	enemy.move_and_slide()
	if enemy.death == true:
		Transitioned.emit(self,"Death")

func Exit():
	pass


func _on_timer_timeout() -> void:
	Transitioned.emit(self,"Running")
