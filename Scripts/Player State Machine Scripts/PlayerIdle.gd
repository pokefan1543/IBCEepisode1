extends State
class_name PlayerIdle

var player : FPSController
var dash_cooldown_timer : Timer

func Enter():
	player = $"../.."
	dash_cooldown_timer = $"../../DashCooldown"
	player.refill_air_moves() # grounded: air dash, double jump and dive recharge

func Physics_Update(delta: float):
	# Walked off a ledge: start falling this tick, Airborne takes over next tick
	if not player.is_on_floor():
		player.air_move(delta)
		Transitioned.emit(self, "Airborne")
		return

	# Jump (tap, or hold with auto_bhop). Air physics this tick, so the jump skips friction.
	if player.try_jump():
		player.air_move(delta)
		Transitioned.emit(self, "Airborne")
		return

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer.time_left == 0.0 and not player.death2:
		Transitioned.emit(self, "Dashing")
		return

	# No input, so this is friction only: leftover speed slides to a stop, Quake style
	player.ground_move(delta)

	if player.has_move_input():
		Transitioned.emit(self, "Running")

func Exit():
	pass
