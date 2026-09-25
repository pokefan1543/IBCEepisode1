extends State
# Dashing: X's dash.
# Ground dash: ramps to dash speed over a few frames and follows the floor, so slopes
#   and small bumps don't cut it short.
# Air dash: instant, flat hover.
# A dash is always faster than normal movement: at least dash_speed, and at least
# dash_min_boost faster than run speed and than the speed you dashed from (see
# FPSController.dash_target_speed), so dashing out of a fast bunny hop still speeds you up.
# Like a jump, the dash is variable: let go of dash and it stops right away, dropping back
# to the speed you had before it. Hold it for the full dash and its speed carries (a full
# air dash keeps its speed as you fall).
# Jump out of it (or soon after it ends) for a dash jump, off a wall for a dash wall kick,
# or mid-air with the leg upgrade for a dash double jump.

var player : FPSController
var duration_timer : Timer  # time left in the dash
var cooldown_timer : Timer  # time before another dash can start
var started_on_floor := false
var cur_speed := 0.0        # ramps up to target_speed
var entry_speed := 0.0      # horizontal speed when the dash started
var target_speed := 0.0     # this dash's speed: player.dash_target_speed(entry_speed)
var dash_dir := Vector3.ZERO
var saved_snap := -1.0

func _ready():
	# Connected in code so it always exists. The guard means it's fine if it's also wired in the editor.
	var timer : Timer = $"../../DashDuration"
	if not timer.timeout.is_connected(_on_dash_duration_timeout):
		timer.timeout.connect(_on_dash_duration_timeout)

func Enter():
	player = $"../.."
	duration_timer = $"../../DashDuration"
	cooldown_timer = $"../../DashCooldown"

	started_on_floor = player.is_on_floor()
	# Spend the air dash when an air dash STARTS, so a ground dash off a ledge
	# never costs it and landing mid-dash never refunds it
	if not started_on_floor:
		player.AirDashUsed = true
	player.dashing = true
	player.diving = false
	if started_on_floor:
		saved_snap = player.floor_snap_length
		player.floor_snap_length = maxf(saved_snap, player.dash_floor_snap)
	player.jump_rising = false
	# Ground dash starts from the speed you already have and ramps up (smooth, no dip out of a run).
	# Air dash is instant full speed, like X's.
	entry_speed = Vector2(player.velocity.x, player.velocity.z).length()
	target_speed = player.dash_target_speed(entry_speed) # always faster than how you were moving
	cur_speed = entry_speed
	if not started_on_floor:
		cur_speed = target_speed
	dash_dir = _input_dir()
	duration_timer.start()
	_apply_dash_velocity(get_physics_process_delta_time()) # this tick, so there's no one-frame delay
	# Sound + FOV burst + dash_move signal (assign dash_sound on the player to hear it)
	player.dash_feedback("dash" if started_on_floor else "air_dash")

func Physics_Update(delta: float):
	if player.jump_requested() and not player.death2:
		# Dash jump. Uses the floor timer, so a jump right after a bump or a slope lip still counts.
		if player.is_on_floor() or (started_on_floor and player.can_coyote_jump()):
			player.do_jump(true)
			_finish_dash("Airborne")
			return
		# Dash wall kick (air dash into a wall, then jump)
		if player.near_wall():
			player.do_wall_kick(true)
			_finish_dash("Airborne")
			return
		# Dash double jump
		if Globals.legupgrade and player.jumpnum < 1:
			player.jumpnum += 1
			player.do_jump(true)
			_finish_dash("Airborne")
			return

	# A ground dash that really runs off a ledge (not just a bump) ends there,
	# and you fall with dash speed, like X
	if started_on_floor and player.time_since_floor() > player.coyote_time:
		_finish_dash("Airborne")
		return

	# Letting go of dash stops the dash (ground or air), like letting go of jump
	if not Input.is_action_pressed("dash") and player.release_ends_dash:
		player.cut_dash_speed(entry_speed) # back to your pre-dash speed, never below it
		_finish_dash()
		return

	_apply_dash_velocity(delta)

func _input_dir() -> Vector3:
	var dir : Vector3 = player.update_wish_dir()
	if dir == Vector3.ZERO:
		dir = -player.head.global_transform.basis.z # no input: dash where you're looking
		dir.y = 0.0
	return dir.normalized()

# Burst toward your input. Speed ramps up over dash_ramp_time for a smooth start.
func _apply_dash_velocity(delta: float):
	# Steer with input, but keep the last direction if you let go of the stick mid-dash
	if player.has_move_input():
		dash_dir = _input_dir()
	var ramp_rate := target_speed / maxf(player.dash_ramp_time, 0.001)
	cur_speed = move_toward(cur_speed, target_speed, ramp_rate * delta)

	var v := dash_dir * cur_speed
	if not started_on_floor:
		# Air dash: flat hover, gravity off
		player.velocity = Vector3(v.x, 0.0, v.z)
	elif player.is_on_floor():
		# Ground dash: on downhill slopes, run along the slope at full speed so you stay
		# glued to the ground instead of launching off. Uphill and flat, stay horizontal
		# (Godot slides you up slopes itself). Also keeps the capsule rolling over a
		# ledge lip from getting nudged upward, which would turn off the floor snap.
		var along := v.slide(player.get_floor_normal())
		if along.y < 0.0 and along.length() > 0.001:
			player.velocity = along.normalized() * cur_speed
		else:
			player.velocity = Vector3(v.x, 0.0, v.z)
	else:
		# Ground dash over a small bump: keep speed, let gravity bring you back down
		player.velocity.x = v.x
		player.velocity.z = v.z
		player.velocity.y -= player.gravity * delta

func _on_dash_duration_timeout():
	_finish_dash()

func _finish_dash(next_state := ""):
	if not player.dashing:
		return # already finished (timer and button release on the same tick)
	player.dashing = false
	duration_timer.stop()
	cooldown_timer.start()

	if next_state == "":
		if not player.is_on_floor():
			next_state = "Airborne"
		elif player.has_move_input():
			next_state = "Running"
		else:
			next_state = "Idle"

	if next_state == "Airborne" and not player.jump_rising:
		# Dash ended in the air without a jump (air dash ran out, or you dashed off a ledge):
		# its full speed becomes air momentum, so it carries as you fall
		player.begin_fall()
	elif next_state != "Airborne":
		# Ground dash ended: a jump in the next moment is still a dash jump
		player.open_dash_jump_window()

	Transitioned.emit(self, next_state)

func Exit():
	if player:
		player.dashing = false
		if saved_snap >= 0.0:
			player.floor_snap_length = saved_snap # back to your scene's value
			saved_snap = -1.0
