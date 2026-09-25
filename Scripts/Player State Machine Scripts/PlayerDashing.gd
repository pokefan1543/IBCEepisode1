extends State
class_name PlayerDashing

var player : FPSController
var duration_timer : Timer  # time left in the dash
var cooldown_timer : Timer  # time before another dash can start
var started_on_floor := false

const DASH_SPEED := 50.0            # same as the old dash (speed = 50); walk speed is 20
const DASH_WALL_KICK_SPEED := 30.0  # horizontal push when you jump off a wall out of a dash

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
	# Spend the air dash when an airborne dash STARTS, so a ground dash off a ledge
	# never costs it and landing mid-dash never refunds it
	if not started_on_floor:
		player.AirDashUsed = true
	player.dashing = true
	player.diving = false
	duration_timer.start()
	_apply_dash_velocity() # this tick, so the dash has no one-frame delay

	# TODO: dash SFX/VFX/FOV hook (fview["DASH"] is already defined on the player)

func Physics_Update(_delta: float):
	# Dash-jump: jump out of a ground dash, keeping dash speed horizontally
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = player.jump_velocity
		_finish_dash("Airborne")
		return

	# Dash-wall-kick: a stronger kick off a wall
	if Input.is_action_just_pressed("jump") and player.is_on_wall():
		var kick := player.get_wall_normal() * DASH_WALL_KICK_SPEED
		kick.y = player.jump_velocity
		player.velocity = kick
		_finish_dash("Airborne")
		return

	# A ground dash that runs off a ledge ends there and you fall with dash speed, like X
	if started_on_floor and not player.is_on_floor():
		_finish_dash("Airborne")
		return

	# Letting go of dash ends it early
	if not Input.is_action_pressed("dash"):
		_finish_dash()
		return

	_apply_dash_velocity()

# Flat, fixed-speed burst toward your input (or where you're looking with no input).
# Gravity is off for the dash's duration: an air dash hovers, like X's.
func _apply_dash_velocity():
	var dir : Vector3 = player.update_wish_dir()
	if dir == Vector3.ZERO:
		dir = -player.head.global_transform.basis.z # the head turns with the mouse, not the body
		dir.y = 0.0
	dir = dir.normalized()
	player.velocity.x = dir.x * DASH_SPEED
	player.velocity.z = dir.z * DASH_SPEED
	player.velocity.y = 0.0

func _on_dash_duration_timeout():
	_finish_dash()

func _finish_dash(next_state := ""):
	if not player.dashing:
		return # already finished (timer and button release on the same tick)
	player.dashing = false
	duration_timer.stop()
	cooldown_timer.start()

	# No friction or speed cap applies in the air, so dash speed carries into Airborne
	if next_state == "":
		if not player.is_on_floor():
			next_state = "Airborne"
		elif player.has_move_input():
			next_state = "Running"
		else:
			next_state = "Idle"

	Transitioned.emit(self, next_state)

func Exit():
	if player:
		player.dashing = false
