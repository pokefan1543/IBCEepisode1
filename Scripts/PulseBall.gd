extends Node3D

var DAMAGE = 5
var SPEED = 50 #Speed is how fast the projectile moves
var playerP = true #playerP stands for "playerProjectile?"
#playerP determines if the projectile is fired from the player or not. 
#If the projectile is from a player, it will not damage the player. Otherwise it will damage the player.


func _process(delta):
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	
func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if playerP == true: 
		if body.is_in_group("enemy"):
			body.enemyhealth -= DAMAGE
			body.pain()
		if not body.is_in_group("player"):
			queue_free()
	else: 
		if body.is_in_group("enemy"):
			body.enemyhealth -= DAMAGE
			body.pain()
		if body.is_in_group("player"):
			body.health -= DAMAGE
		if not body.is_in_group("player") and not body.is_in_group("enemy"):
			queue_free()
