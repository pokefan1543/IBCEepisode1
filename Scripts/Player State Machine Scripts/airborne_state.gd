extends State
class_name PlayerAirborne #FIXME this line is leftover from my notes but I'm not sure what it's for. May want to remove this is we can.

var player : CharacterBody3D
var head : Node3D
var jumping = false
var fall = false
var first_frame : bool #Used to track whether this is the first frame after leaving the ground
var dash_cooldown_timer : Timer

func Enter():
	#identify important nodes for this script's processing
	player = $"../.."
	head = $"../../Head"
	dash_cooldown_timer = $"../../DashCooldown"
	player.gravity = 15
	fall = false
	first_frame = true
	if player.dashing != true:
		player.AirDashUsed = false 
	
	#print("Entered Airborne State")#TEST


func Physics_Update(delta: float):
	if Input.is_action_pressed("jump") and player.velocity.y == 0:
		fall = true
	if player.velocity.y == 0:
		fall = true 
	if fall == true and player.gravity <= 25 and player.diving == false:
		player.gravity += 1
	if not Input.is_action_pressed("jump") and (not player.is_on_floor()):
		if player.jumping != false:
			player.velocity.y = 0
			player.jumping = false 
		player.velocity.y -= player.gravity * delta
	
	# Behavior when not dashing
	if player.dashing != true:
		# Get desired (wished) direction of movement from player input
		var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
		var wish_dir = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		#adjust speed based on player input and gravity
		player.velocity.x = wish_dir.x * player.speed
		player.velocity.z = wish_dir.z * player.speed 
		player.velocity.y -= player.gravity * delta
		
	# Behavior when dashing
	if player.dashing == true:
		# Get desired (wished) direction of movement from player input
		var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
		var wish_dir = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		#adjust speed based on player input and gravity
		player.velocity.x = wish_dir.x * player.speed * 3
		player.velocity.z = wish_dir.z * player.speed * 3
		player.velocity.y -= player.gravity * delta
		
	# Behavior when dashing stops on wall
	if player.is_on_wall() and not Input.is_action_pressed("dash"):
		player.dashing = false 
		
	if (player.velocity.x != 0 or player.velocity.z != 0) and player.is_on_wall():
		player.velocity.y = player.velocity.y / 2
		player.velocity.x = player.velocity.x / 2
		player.velocity.z = player.velocity.z / 2
	#Behavior when dashing starts on a wall
	if player.is_on_wall() and Input.is_action_pressed("dash"):
		player.dashing = true 
	
	# Wallkick
	if Input.is_action_just_pressed("jump") and (player.is_on_wall()):
		if player.dashing == false: 
			player.velocity = player.get_wall_normal() * player.wallKickRecoil
		else: 
			player.velocity = player.get_wall_normal() * player.wallKickRecoil * (player.dashMultiplier - 0.5)
		player.velocity.y = player.jump
		
	# Dive 
	if Input.is_action_just_pressed("dive"):
		player.diving = true
		player.gravity = 200
	
	if first_frame:
		#if this is the first frame since player left the floor, don't check for landing yet so that player still has a chance to rise off ground from jump
		first_frame = false
	else:
		# Based on whether or not player is inputting direction, transition to Idle or Running state upon landing
		if player.is_on_floor():
			if player.dashing == true:
				player.dashing = false
			if (Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down")):
				Transitioned.emit(self, "Running")
				return
			else:
				Transitioned.emit(self, "Idle")
				return
	
	# Transition to the dashing state if the player presses dash key, dash isn't on cooldown, and air dash hasn't been spent yet
	if Input.is_action_just_pressed("dash") and (dash_cooldown_timer.time_left == 0.0) and not player.AirDashUsed:
		Transitioned.emit(self, "Dashing")
		return
	
func Exit():
	pass
