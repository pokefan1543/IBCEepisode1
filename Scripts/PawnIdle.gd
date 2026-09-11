extends State
var enemy : CharacterBody3D
var eyes : Node3D
var target = null

func Enter():
	enemy = $"../.."
	target = enemy.target
	eyes = enemy.eyes

func _physics_process(delta: float) -> void:
	if enemy.kicked == true:
		Transitioned.emit(self, "Death")
	
func _on_sightrange_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = body
		enemy.target = target 
		enemy.ALERTSOUND.play(0.001)
		Transitioned.emit(self, "Running")
