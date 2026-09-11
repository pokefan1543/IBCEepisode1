extends State

var player : CharacterBody3D
var head : Node3D
var dash_cooldown_timer : Timer

func Enter():
	#identify key nodes for this scripts function
	player = $"../.."
	head = $"../../Head"
	dash_cooldown_timer = $"../../DashCooldown"
	player.gravity = 15
	player.velocity.y = 0 #halt vertical momentum, as player is now grounded #FIXME is this line necessary?
	player.AirDashUsed = false # Refill air dash, as player is now grounded
	
	#print("Entered Running State")#TEST

func Physics_Update(delta: float):
	# Get desired (wished) direction of movement from player input
	var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
	var wish_dir = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# Adjust velocity based on player input
	if not Input.is_action_pressed("dash"):
		player.dashing = false 
	if (player.velocity.x != 0 or player.velocity.z != 0) and player.is_on_wall():
		player.velocity.y = player.velocity.y / 2
		player.velocity.x = player.velocity.x / 2
		player.velocity.z = player.velocity.z / 2
	player.velocity.x = wish_dir.x * player.speed
	player.velocity.z = wish_dir.z * player.speed 
	
	# start falling if player leaves ground without jumping (expect this command to run from running off a ledge)
	if not player.is_on_floor():
		Transitioned.emit(self, "Airborne")
		return
	
	# Dash
	if Input.is_action_pressed("dash"):
		player.dashing = true
		
	# Jump and transition to airborne if player jumps/wallkicks
	if Input.is_action_just_pressed("jump") and (player.is_on_floor()):
		player.jumping = true
		player.velocity.y = player.jump
		Transitioned.emit(self, "Airborne")
		return
	if Input.is_action_just_pressed("jump") and (player.is_on_wall()):
		player.jumping = true
		player.velocity = player.get_wall_normal() * player.wallKickRecoil 
		player.velocity.y = player.jump
		Transitioned.emit(self, "Airborne")
		return
	# Transition to the idle state if the player isnt pressing any movement keys
	if not (Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		Transitioned.emit(self, "Idle")
		return
	
	# Transition to the dashing state if the player presses dash key and dash is not on cooldown
	if Input.is_action_just_pressed("dash") and (dash_cooldown_timer.time_left == 0.0):
		Transitioned.emit(self, "Dashing")
		return


func Exit():
	pass
