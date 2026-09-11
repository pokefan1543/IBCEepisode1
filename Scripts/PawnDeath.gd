extends State 

var enemy : CharacterBody3D
var eyes : Node3D
var target = null
var raycast1 : RayCast3D

func Enter():
	#identify key nodes for this scripts function
	enemy = $"../.."
	target = enemy.target
	eyes = enemy.eyes
	raycast1 = enemy.raycast
	Globals.defeats += 1

func Physics_Update(_delta: float):
	if enemy.dead != true:
		#var h = enemy.health.instantiate()
		var b = enemy.bullets.instantiate()
		b.position = raycast1.global_position
		b.basis = raycast1.global_transform.basis
		#h.position = raycast1.global_position
		#h.basis = raycast1.global_transform.basis
		self.add_child(b)
		#self.add_child(h)
		enemy.idle.hide()
		Globals.defeats += 1
		enemy.dead = true 
