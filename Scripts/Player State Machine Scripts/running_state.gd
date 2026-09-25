extends State
# Running: on the ground with movement input. Quake acceleration and friction.

var player : FPSController
var dash_cooldown_timer : Timer

func Enter():
	player = $"../.."
	dash_cooldown_timer = $"../../DashCooldown"
	player.refill_air_moves() # landing can go straight to Running, skipping Idle

func Physics_Update(delta: float):
	# Ran off a ledge: keep your speed as air momentum (coyote time still allows a jump)
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

	player.ground_move(delta)

	if not player.has_move_input():
		Transitioned.emit(self, "Idle")

func Exit():
	pass
