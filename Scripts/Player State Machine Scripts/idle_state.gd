extends State
class_name PlayerIdle #FIXME this line is leftover from my notes but I'm not sure what it's for. May want to remove this is we can.

var player : CharacterBody3D
var dash_cooldown_timer : Timer

func Enter():
	#identify key nodes for this scripts function
	player = $"../.."
	dash_cooldown_timer = $"../../DashCooldown"
	player.gravity = 15
	player.velocity.y = 0 #halt vertical momentum, as player is now grounded #FIXME is this line necessary?
	player.AirDashUsed = false # Refill air dash, as player is now grounded
	
	#print("Entered Idle State")#TEST

func Physics_Update(delta: float):
	# start falling if player leaves ground without jumping (here in the idle state, expect this from sliding off a ledge)
	if not player.is_on_floor():
		Transitioned.emit(self, "Airborne")
		return
	if not Input.is_action_pressed("dash"):
		player.dashing = false 
	# Change y velocity and transition to airborne if player jumps
	if Input.is_action_just_pressed("jump") and (player.is_on_floor()):
		player.jumping = true
		player.velocity.y = player.jump
		Transitioned.emit(self, "Airborne")
		return
	if (player.velocity.x != 0 or player.velocity.z != 0) and player.is_on_wall():
		player.velocity.y = player.velocity.y / 2
		player.velocity.x = player.velocity.x / 2
		player.velocity.z = player.velocity.z / 2
	if Input.is_action_just_pressed("jump") and (player.is_on_wall()):
		player.jumping = true
		player.velocity = player.get_wall_normal() * player.wallKickRecoil 
		player.velocity.y = player.jump
		Transitioned.emit(self, "Airborne")
		return
	# Transition to the running state if the player presses any movement key
	if (Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		Transitioned.emit(self, "Running")
		return
	
	# Transition to the dashing state if the player presses dash key and dash is not on cooldown
	if Input.is_action_just_pressed("dash") and (dash_cooldown_timer.time_left == 0.0):
		Transitioned.emit(self, "Dashing")
		return


func Exit():
	pass
