extends State
class_name PlayerAirborne

var player : FPSController
var dash_cooldown_timer : Timer
var first_frame : bool # true on the first tick after takeoff (see Physics_Update)

const WALL_KICK_SPEED := 15.0     # horizontal push off a wall-kick; tune to taste
const DIVE_FALL_ACCEL := 80.0     # extra downward accel while diving, on top of gravity
const DIVE_MAX_FALL_SPEED := 60.0 # terminal fall speed while diving

func Enter():
	player = $"../.."
	dash_cooldown_timer = $"../../DashCooldown"
	first_frame = true
	player.diving = false

func Physics_Update(delta: float):
	# Landing
	if not first_frame and player.is_on_floor():
		player.refill_air_moves()
		# Bhop: re-jump on the landing tick itself, before any friction runs, and stay
		# Airborne. With auto_bhop, holding jump chains hops with zero speed loss.
		if player.try_jump():
			player.air_move(delta)
			first_frame = true
			return
		player.ground_move(delta)
		if player.has_move_input():
			Transitioned.emit(self, "Running")
		else:
			Transitioned.emit(self, "Idle")
		return

	# The tick right after takeoff is physics only. The jump press that launched you
	# must not also count as a double jump, wall-kick or air dash.
	if first_frame:
		first_frame = false
		player.air_move(delta)
		return

	# Air dash: once per airtime (refilled on landing, and on wall touch in controls())
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer.time_left == 0.0 and not player.AirDashUsed and not player.death2:
		Transitioned.emit(self, "Dashing")
		return

	# Gravity + Quake air strafing + surf
	player.air_move(delta)

	if player.death2:
		return

	if Input.is_action_just_pressed("jump"):
		if player.is_on_wall():
			# Wall-kick (also cancels a dive). Set after air_move so nothing alters it this tick.
			var kick := player.get_wall_normal() * WALL_KICK_SPEED
			kick.y = player.jump_velocity
			player.velocity = kick
			player.diving = false
		elif Globals.legupgrade and player.jumpnum < 1:
			# Double jump from the leg upgrade ("You can jump twice now!"). Keeps horizontal speed.
			player.jumpnum += 1
			player.velocity.y = player.jump_velocity
			player.diving = false

	# Dive: fast-fall until landing or a wall-kick. player.diving is what kickDamageArea checks.
	if Input.is_action_just_pressed("dive") and not player.diving:
		player.diving = true
	if player.diving:
		player.velocity.y = maxf(player.velocity.y - DIVE_FALL_ACCEL * delta, -DIVE_MAX_FALL_SPEED)

func Exit():
	pass
