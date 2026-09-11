extends State
class_name PlayerDashing #FIXME this line is leftover from my notes but I'm not sure what it's for. May want to remove this is we can.

var player : CharacterBody3D
var head : Node3D
var duration_timer : Timer #This timer tracks the remaining time in the dash
var cooldown_timer : Timer #This timer tracks the remaining time in the cooldown between dashes


func Enter(): # identify player node in scene so that its physics data and other variables can be later manipulated by this node
	#identify important nodes for this script's processing
	player = $"../.."
	head = $"../../Head"
	duration_timer = $"../../DashDuration"
	cooldown_timer = $"../../DashCooldown"
	#print("Entered Dashing State")
	
	#Halt vertical motion so that player hovers while dashing #FIXME should this be here or in the physics update function?
	player.velocity.y = 0 
	
	#Start timer as dash begins
	duration_timer.start()
	
	#FIXME Insert special effects for dashing (e.g. sound effects, screen effects, etc)


# end dash when duration timer ends
func _on_dash_duration_timeout() -> void:
	if not player.is_on_floor():
		end_dash1()
	if player.is_on_floor() or player.is_on_wall():
		end_dash()

func Physics_Update(delta: float):
	player.dashing = true
	# Get desired (wished) direction of movement from player input
	var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
	var wish_dir = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Adjust speed based on player input
	player.velocity.x = wish_dir.x * player.speed * player.dashMultiplier 
	player.velocity.z = wish_dir.z * player.speed * player.dashMultiplier
	
	# Dash jump
	if Input.is_action_just_pressed("jump") and (player.is_on_floor()):
		player.jumping = true
		player.velocity.y = player.jump
		Transitioned.emit(self, "Airborne")
		return
		
	# Dash wall kick 
	if Input.is_action_just_pressed("jump") and (player.is_on_wall()):
		player.jumping = true
		player.velocity = player.get_wall_normal() * player.wallKickRecoil * (player.dashMultiplier - 0.5)
		player.velocity.y = player.jump 
		Transitioned.emit(self, "Airborne")
		return
	if (player.velocity.x != 0 or player.velocity.z != 0) and player.is_on_wall():
		player.velocity.y = player.velocity.y / 2
		player.velocity.x = player.velocity.x / 2
		player.velocity.z = player.velocity.z / 2
	# End dash when not pressing dash button
	if not Input.is_action_pressed("dash"):
		end_dash()

# This function is called when the dash is to end, either by timeout or early halt by player command
func end_dash():
	# Halt timer to ensure this function doesn't get double-called (I'm not sure if that could actually happen but just to be safe)
	duration_timer.stop()
	player.dashing = false
	# Start Cooldown Timer to Stop Raw Spamming (give a little pause between dashes)
	# The other scripts in this state machine will refuse to start a dash if this timer is still going/if dash is on cooldown
	cooldown_timer.start()
	
	# Transition to airborne state if player ends dash in air
	if not player.is_on_floor():
		player.AirDashUsed = true #if dash ends in air, empty airdash so that player can't dash again until they land
		Transitioned.emit(self, "Airborne")
		return
	
	# Transition to running state if ends dash on ground while holding a movement key
	elif (Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		Transitioned.emit(self, "Running")
	
	# Transition to idle state if player ends dash on ground while not holding any movement keys
	else:
		Transitioned.emit(self, "Idle")
		return
		
func end_dash1():
	# Halt timer to ensure this function doesn't get double-called (I'm not sure if that could actually happen but just to be safe)
	duration_timer.stop()
	
	# Start Cooldown Timer to Stop Raw Spamming (give a little pause between dashes)
	# The other scripts in this state machine will refuse to start a dash if this timer is still going/if dash is on cooldown
	cooldown_timer.start()
	
	# Transition to airborne state if player ends dash in air
	if not player.is_on_floor():
		player.AirDashUsed = true
		player.dashing = true
		Transitioned.emit(self, "Airborne")
		return

func Exit():
	pass
