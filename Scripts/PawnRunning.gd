extends State

var enemy_max_speed = 20
var gravity_direction_and_speed = -50
const TURN_SPEED = 2
var enemy : CharacterBody3D
var eyes : Node3D
var target = null

func Enter():
	#identify key nodes for this scripts function
	enemy = $"../.."
	target = enemy.target
	eyes = enemy.eyes
	enemy.is_avoiding = false
	#print("Entered Running State")#TEST

func Physics_Update(_delta: float):
	eyes.look_at(target.global_transform.origin, Vector3.UP)
	enemy.rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED))
	enemy.set_velocity(Vector3(min(target.position.x - enemy.position.x, enemy_max_speed), gravity_direction_and_speed, min(target.position.z - enemy.position.z, enemy_max_speed)))
	enemy.set_up_direction(Vector3.UP)
	enemy.move_and_slide()
	if enemy.kicked == true:
		Transitioned.emit(self, "Death")
		
	if enemy.enemyhealth <= enemy.startinghealth / 2:
		enemy.scream.play()
		Transitioned.emit(self, "Retreating")
		
	if enemy.raycast.is_colliding():
		if enemy.raycast.get_collider().is_in_group("player"):
			Transitioned.emit(self, "Attack")

func Exit():
	pass


func _on_touch_body_entered(body):
	if body.is_in_group("enemy"):
		enemy.is_avoiding = true
		enemy.target = enemy.get_collider()
		Transitioned.emit(self, "Retreating")
