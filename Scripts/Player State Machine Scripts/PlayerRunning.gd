extends State
class_name PlayerRunning

var player : FPSController
var dash_cooldown_timer : Timer

func Enter():
	player = $"../.."
	dash_cooldown_timer = $"../../DashCooldown"
	player.refill_air_moves() # landing can go straight to Running, skipping Idle

func Physics_Update(delta: float):
	# Ran off a ledge: keep your speed and start falling this tick
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

	# Running is what moves you on the ground: Quake friction + acceleration toward wish_dir
	player.ground_move(delta)

	if not player.has_move_input():
		Transitioned.emit(self, "Idle")

func Exit():
	pass
