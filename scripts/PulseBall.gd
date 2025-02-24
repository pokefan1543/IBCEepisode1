extends RigidBody3D

var shoot = false

const DAMAGE = 20
const SPEED = 50



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	
func _physics_process(_delta):
	if shoot == true:
		apply_impulse(-transform.basis.z * SPEED, transform.basis.z)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body.is_in_group("enemy"):
		body.enemyhealth -= DAMAGE
		print("enemy hit by collision")
		if body.is_in_group("Chaospawn"):
			$ChaosPawnHurt3.play()
		if body.is_in_group("Chaossoldier"):
			$ChaosSoldierHurt.play()
		if body.is_in_group("fiend"):
			$fiendhurt.play()
	elif body.is_in_group("player"):
		print("bruh")
	elif body.is_in_group("yo"):
		print("bruh")
	else:
		queue_free()


func _on_Area2_body_entered(body):
	if body.is_in_group("enemy"):
		body.enemyhealth -= DAMAGE
		print("enemy hit by collision")
		if body.is_in_group("Chaospawn"):
			$ChaosPawnHurt3.play()
		if body.is_in_group("Chaossoldier"):
			$ChaosSoldierHurt.play()
		if body.is_in_group("fiend"):
			$fiendhurt.play()
	elif body.is_in_group("player"):
		print("bruh")
	elif body.is_in_group("yo"):
		print("bruh")
