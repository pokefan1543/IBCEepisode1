extends RigidBody3D

var shoot = false

const DAMAGE = 50
const SPEED = 70
@onready var ray_container = $Ray

var spread = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	
func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * SPEED * delta)



func _on_Area_body_entered(body):
	if body.is_in_group("enemy"):
		body.enemyhealth -= DAMAGE
		print("enemy hit by ball")


func _on_colls_body_entered(body):
	if body.is_in_group("enemy"):
		body.enemyhealth -= DAMAGE
		print("enemy hit by collision")
		if body.is_in_group("Chaospawn"):
			$chaospawnhurt.play()
		if body.is_in_group("fiend"):
			$fiendhurt.play()
	if body.is_in_group("player"):
		print("bruh")
	if body.is_in_group("yo"):
		print("bruh")
	else:
		queue_free()
