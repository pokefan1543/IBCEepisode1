extends State
# Idle: on the ground with no movement input. Friction slides you to a stop.

var player : FPSController
var dash_cooldown_timer : Timer

func Enter():
	player = $"../.."
	dash_cooldown_timer = $"../../DashCooldown"
	player.refill_air_moves() # grounded: air dash, double jump and dive recharge

func Physics_Update(delta: float):
	# Walked or slid off a ledge: start falling this tick (coyote time still allows a jump)
	if not player.is_on_floor():
		player.begin_fall()
		player.air_move(delta)
		Transitioned.emit(self, "Airborne")
		return

	# Jump. Dashing, holding dash, or having just dashed makes it a dash jump.
	if player.ground_jump_requested():
		player.do_jump(player.wants_dash_jump())
		player.air_move(delta) # air physics this tick, so the jump skips friction (bhop)
		Transitioned.emit(self, "Airborne")
		return

	if player.dash_just_pressed() and dash_cooldown_timer.time_left == 0.0:
		Transitioned.emit(self, "Dashing")
		return

	player.ground_move(delta) # no input, so this is friction only

	if player.has_move_input():
		Transitioned.emit(self, "Running")

func Exit():
	pass
