extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var timer = false

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.health -= 10
		$hurt.play()
func _physics_process(delta):
	if timer == false:
		var forward_dir = global_transform.basis.z.normalized()
		global_translate(forward_dir * 1 * delta)
		$Timer.start()
	else:
		var forward_dir = global_transform.basis.z.normalized()
		global_translate(forward_dir * -1 * delta)
		$Timer2.start()
func _on_colls_body_entered(body):
	if body.is_in_group("player"):
		body.health -= 10
		$hurt.play()
	if body.is_in_group("yo"):
		body.health -= 10
		$hurt.play()


func _on_Timer_timeout():
	timer = true


func _on_Timer2_timeout():
	timer = false
