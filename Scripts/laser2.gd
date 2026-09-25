extends Node3D
 
var distance
	
func _process(delta):
	# Check for a raycast collision.
	if $RayCast3D.get_collider(): 
		# Calculating the distance between the laser and a collision point.
		distance = transform.origin.distance_to($RayCast3D.get_collision_point())
		# Scaler is scaling to the collision point.
		$Scaler.scale.z = distance /2
	else:
		# If the raycast is not colliding  with anything then the Scaler's scale is long as the raycast length.
		$Scaler.scale.z = $RayCast3D.target_position.z
