extends State
# Airborne: jumping, falling, wall sliding, wall kicking, double jumping and diving.

var player : FPSController
var dash_cooldown_timer : Timer

const DIVE_FALL_ACCEL := 80.0     # extra downward accel while diving, on top of gravity
const DIVE_MAX_FALL_SPEED := 90.0 # terminal fall speed while diving (normal max is player.max_fall_speed)

func Enter():
	player = $"../.."
	dash_cooldown_timer = $"../../DashCooldown"
	player.diving = false

func Physics_Update(delta: float):
	# Landing. Requiring vy <= 0 means the tick you take off can never count as a landing.
	if player.is_on_floor() and player.velocity.y <= 0.5:
		player.refill_air_moves()
		# Bhop (Quake 1 rules, see FPSController.ground_jump_requested): jump pressed just
		# before landing, or pressed and held since you last let go of it, fires on the landing
		# tick itself, before any friction runs, so you keep all your speed.
		if player.ground_jump_requested():
			player.do_jump(player.wants_dash_jump())
			player.air_move(delta)
			return
		player.ground_move(delta)
		if player.has_move_input():
			Transitioned.emit(self, "Running")
		else:
			Transitioned.emit(self, "Idle")
		return

	# Gravity, variable jump height, Quake 1 air acceleration (strafe-jumping), X-style air
	# control when you're not strafe-jumping, and surf. See FPSController.air_move
	player.air_move(delta)

	if player.death2:
		return

	# Jump in the air: wall kick first, then a late (coyote) jump, then the double jump.
	# Holding dash (or having just dashed) gives the dash version. An unused press stays buffered for landing.
	var jumped := false
	if player.jump_requested():
		if player.near_wall():
			player.do_wall_kick(player.wants_dash_jump())
			jumped = true
		elif player.can_coyote_jump():
			player.do_jump(player.wants_dash_jump())
			jumped = true
		elif Globals.legupgrade and player.jumpnum < 1:
			player.jumpnum += 1
			player.do_jump(player.wants_dash_jump())
			jumped = true

	# Air dash: once per airtime (refilled on landing, and on wall touch in controls()).
	# Checked after jumps, so dash + jump together gives a dash jump / dash kick, not an air dash.
	if not jumped and player.dash_just_pressed() and dash_cooldown_timer.time_left == 0.0 and not player.AirDashUsed:
		Transitioned.emit(self, "Dashing")
		return

	# Wall slide: holding into a wall while falling slows the fall, and, like X,
	# grabbing a wall ends dash momentum.
	if player.is_wall_sliding():
		player.velocity.y = maxf(player.velocity.y, -player.wall_slide_speed)
		player.air_momentum = player.speed

	# Dive: fast-fall until landing or a jump. player.diving is what kickDamageArea checks.
	if Input.is_action_just_pressed("dive") and not player.diving:
		player.diving = true
		player.jump_rising = false
	if player.diving:
		player.velocity.y = maxf(player.velocity.y - DIVE_FALL_ACCEL * delta, -DIVE_MAX_FALL_SPEED)

func Exit():
	pass
