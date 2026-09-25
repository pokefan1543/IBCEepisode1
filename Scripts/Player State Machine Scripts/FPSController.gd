class_name FPSController
extends CharacterBody3D

# HOW MOVEMENT WORKS NOW
# The state machine drives movement. Each tick, the active state (Idle / Running /
# Airborne / Dashing) sets this tick's velocity by calling the movement toolkit
# below (ground_move, air_move, do_jump, do_wall_kick...). Then this script's _physics_process runs
# move_and_slide(). _ready() sets process_physics_priority so this node always
# runs AFTER the StateMachine, so states never lag a frame behind.

#Variables
var AirDashUsed = false #Used to track whether air dash is used so that player can only dash once in the air
var DashorSlide = true #true == dash; false == slide
signal grounded
signal dash_move(kind: String) # "dash", "air_dash", "dash_jump", "dash_wall_kick": hook extra SFX/VFX/animations here
@export var trail: PackedScene = null
var Gunfire = false
var shooting = false
var death2 = false
var is_on_map = true
var health = Globals.maxHealth
var M9_fire = true
var counter = 3
var shotgundamage = 10
var spread = 5
var shotgun_fire = true
var stormfire = true
var damage = 25
var dashing = false # true while in the Dashing state (shown on $Label2)
var diving = false # true while diving; kickDamageArea reads this to deal kick damage
var mouse_sense : float = Globals.mouse_sense
var soundnum = 0
var jumpnum = 0 # air jumps used since landing (double jump with the leg upgrade)
var parry = false
var upgradeShotNum = 0
var max_health = Globals.maxHealth
var current_weapon = 1
var leanRight = false
var leanLeft = false
var freeze = false
var instance
var railgunfire = true #boolean if the railgun can fire
const ADS_LERP = 20
var raildamage = 0
#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
const BOB_SPEED_SCALE = 0.35 # slows the bob to suit this game's speed scale (walk speed 20)
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
var fview = {"Default": 118, "ADS": 50, "ADSSCOPE": 10, "DASH": 138}

#---------------------------------------------------------------------------
# MOVEMENT SETTINGS: Mega Man X4 platforming + Quake 1 momentum
# Every value is tunable in the Inspector. Mega Man X reference (TASVideos data):
# walk 1.5 px/f, dash 3.5 px/f (2.33x walk), jump 5.0 px/f, gravity 0.25 px/f^2,
# terminal fall 5.75 px/f (1.15x jump). Releasing jump makes X start falling at once.
@export_group("Ground (Quake friction)")
@export var speed := 30.0 # run speed
@export var ground_accel := 10.0
@export var ground_decel := 10.0 # below this speed friction stops you at a fixed rate
@export var ground_friction := 4.0
@export_group("Jump (Mega Man X)")
@export var jump_velocity := 40.0
@export var gravity := 60.0
@export var max_fall_speed := 46.0 # X falls at most 1.15x his jump speed
@export var jump_cut_velocity := 0.0 # releasing jump while rising caps upward speed to this; 0 = X: you start falling right away
@export var min_jump_hold := 0.08 # a tap still gives at least this much rise (seconds)
@export var jump_buffer_time := 0.1 # a jump pressed this long before landing still fires on landing (fair bhop timing)
@export var coyote_time := 0.08 # you can still jump this long after running off a ledge
@export var auto_bhop := false # false = Quake 1 "don't pogo stick": you must let go of jump once between jumps. true = holding jump re-jumps forever
@export_group("Air control")
@export var air_control := 1200.0 # how fast your air speed changes toward your target (speed units/s); high = complete air control
@export var air_turn_rate := 30.0 # how fast you turn in the air (radians/s); turns keep your full speed
@export var air_reverse_angle := 135.0 # input more than this many degrees from your motion flips you around, X-style, keeping your speed
@export var air_release_brake := 1200.0 # how fast you stop in the air when you let go of movement (X-style full stop, ~4 frames even from dash speed). 0 = Quake drift: momentum keeps going
@export_group("Bunny hopping (Quake 1)")
# Straight from Quake 1 (id Software, WinQuake/sv_user.c + QuakeC PlayerJump):
#  - SV_AirAccelerate: in the air, the speed you can add toward your wish direction is capped at
#    30 (out of 320 max speed), but it's added at sv_accelerate * full wishspeed, and nothing caps
#    total speed. Strafing while turning the mouse the same way keeps your wish direction nearly
#    perpendicular to your velocity, so every tick adds a little speed: strafe-jumping.
#  - Jump fires on the landing frame before friction (QuakeWorld pmove order), so a hop timed on
#    landing loses nothing. FL_JUMPRELEASED: let go of jump once between jumps (no pogo stick);
#    press and hold it before you land and it fires the instant you touch down.
#  - Ground friction 4, stopspeed 100/320, accelerate 10: your ground settings above already match.
@export var q1_air_cap_ratio := 0.09375 # Quake 1's 30 / 320: max speed added toward your wish direction in the air, as a fraction of run speed
@export var q1_air_accelerate := 10.0 # sv_accelerate
@export var strafe_jump_hold := 0.12 # after your last strafe+turn input, Quake air physics stay on this long (smooths over frames without mouse movement)
@export_group("Dash (Mega Man X)")
@export var dash_speed := 67.0 # base dash speed: 2.2x run speed, close to X's 2.33x
@export var dash_min_boost := 10.0 # a dash is always at least this much faster than run speed AND than the speed you dashed from (so dashing out of a fast bhop still speeds you up)
@export var dash_ramp_time := 0.05 # time to reach full dash speed; a few frames makes the start smooth instead of a hard snap
@export var dash_floor_snap := 1.0 # stronger floor snap during a ground dash so it follows downhill slopes at dash speed instead of launching off the lip
@export var release_ends_dash := true # like a jump: let go of dash and the dash (ground or air) stops and drops to run speed. Hold it for the full dash and its speed carries
@export var dash_jump_window := 0.15 # X4: "press Dash, then Jump soon after". A jump this soon after a ground dash ends is still a dash jump
@export_group("Dash feedback")
@export var dash_fov_kick := 20.0 # FOV widens by up to this much as you go from run speed to dash speed (fview DASH - Default); 0 = off
@export var dash_fov_punch := 4.0 # small extra "pop" of FOV the moment a dash / air dash starts, easing out
@export var dash_jump_fov_punch := 0.0 # extra pop on dash jumps; 0 keeps dash jump FOV the same as the dash so it doesn't look slower
@export var fov_attack := 20.0 # how fast FOV widens (fast, so the dash reads instantly)
@export var fov_smoothing := 6.0 # how fast FOV returns to normal
@export var speed_lines := false # screen-edge speed lines while you're moving at dash speed (dashing, dash jumping, carried air dash)
@export var speed_lines_color := Color(1, 1, 1, 0.55)
@export var dash_sound : AudioStream # optional: plays when a dash / air dash starts
@export var dash_jump_sound : AudioStream # optional: plays on a dash jump / dash wall kick / dash double jump
@export_group("Walls (Mega Man X)")
@export var wall_slide_speed := 15.0 # max fall speed while holding into a wall
@export var wall_kick_speed := 20.0 # push away from the wall during a normal kick
@export var dash_wall_kick_speed := 45.0 # push away during a dash kick (hold dash while kicking)
@export var wall_kick_lock_time := 0.1 # steering is off this long after a kick, so the push happens before you can steer back
@export var wall_grace_time := 0.1 # a jump this soon after touching a wall still kicks
@export_group("")

var wish_dir := Vector3.ZERO
var input_vec := Vector2.ZERO
var air_momentum := 30.0 # horizontal speed you can steer at in the air; dashes, bhops and strafing raise it
var jump_rising := false # true while rising from a player jump (variable height applies)
var _jump_timer := 0.0
var _jumped_since_floor := false
var _time_since_floor := 0.0
var _time_since_wall := 1000.0
var _last_wall_normal := Vector3.ZERO
var _air_lock := 0.0
var _jump_buffer := 0.0
var _jump_was_down := false
var _dash_was_down := false
var _dash_fresh := false
var _polled_frame := -1
var _last_yaw := 0.0
var _jump_released := true # Quake 1 FL_JUMPRELEASED
var _strafe_jump_timer := 0.0
var strafe_jumping := false # true while you're strafe-jumping (Quake 1 air physics in charge)
var _dash_jump_timer := 0.0
@onready var _base_fov : float = $Head/Camera3D.fov
var _fov_punch := 0.0
var _speed_lines_rect : ColorRect
var _speed_lines_amount := 0.0
var _sfx : AudioStreamPlayer
#These are the variables to check if the player has the weapons in the game
#--------------------------------------------------------------------------
signal death
signal loading
signal pause
#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
#Onready vars
@onready var head = $Head
@onready var _Camera = get_viewport().get_camera_3d()
@onready var _Viewport = get_viewport().get_size()
@onready var camera = $Head/Camera3D
@onready var _camera_base_pos : Vector3 = $Head/Camera3D.position
@onready var hand = $Head/Camera3D/hand
@onready var anim_player = $Head/Camera3D/hand/AnimationPlayer
@onready var raycast = $Head/Camera3D/hand/CrosshairRayCast
@onready var Chaospawnhurt = $ChaosPawnHurt
@onready var text_timer = $text_timer
@onready var coll = $CollisionShape3D
@onready var ray = $Head/Camera3D/hand/CrosshairRayCast
@onready var PulseRifle = $Head/Camera3D/hand/M9PulseRifleHR
@onready var AxelBuster = $Head/Camera3D/hand/Buster
@onready var pulseball = preload("res://Scenes/pulse_ball.tscn")
@onready var tazerball = preload("res://Scenes/Tazerball.tscn")
@onready var aimcast2 = $Head/Camera3D/hand/CrosshairRayCast
@onready var pulsesound = $Head/Camera3D/hand/pulsefire
@onready var ray_container = $Head/Camera3D/hand/ShotgunRayContainer
@onready var shotgunmodel = $Head/Camera3D/hand/shotgun
@onready var stormcloud = $Head/Camera3D/hand/Stormcloud
@onready var Crosshair = $Head/Camera3D/hand/CrosshairRayCast
@onready var flash = $Head/Camera3D/hand/Stormcloud/stormflash
@onready var stormmuzzle1 = $Head/Camera3D/hand/muzzlestorm
#---------------------------------------------------------------------------
func fire_shotgun():
	if Globals.shotgun == true:
		if current_weapon == 2:
			if Globals.shells > 0:
				if not Input.is_action_pressed("fire2"):
					if Input.is_action_just_pressed("fire") and shotgun_fire == true:
						if anim_player.is_playing():
							anim_player.play("shotgunfire")
						Globals.shells -= 1
						for r in ray_container.get_children():
							r.target_position.x = randf_range(spread, -spread)
							r.target_position.y = randf_range(spread, -spread)
							if r.is_colliding():
								if r.get_collider().is_in_group("enemy"):
									r.get_collider().enemyhealth -= shotgundamage * Globals.damageMult
									if r.get_collider().is_in_group("Chaospawn"):
										Chaospawnhurt.play(0.001)
									if r.get_collider().is_in_group("fiend"):
										$fiendhurt.play()
						if counter == 3 and not Input.is_action_pressed("fire"):
							$Head/Camera3D/hand/shotgun/shotgun_timer.start()
						$muzzletimer.start(0.1)
						$Head/Camera3D/hand/shotgun/shotgun.play(0.0001)
						$Head/Camera3D/hand/shotgun/muzzleflash.show()
						anim_player.play("shotgunfire")
						$Head/Camera3D/hand/shotgun/shotgun_timer.start()
						shotgun_fire = false
				if Input.is_action_pressed("altfire"):
					if Input.is_action_just_pressed("fire") and shotgun_fire == true:
						anim_player.play("ShotgunBlast")
						if anim_player.is_playing() and shotgun_fire == true:
							counter -= 1
							$Healthbar2/s/Console.add_text(" " + str(counter))
							if counter <= 0:
								counter = 3
								shotgun_fire = false
								$burst_timer.start()
							Globals.shells -= 1
							for r in ray_container.get_children():
								r.target_position.x = randf_range(spread, -spread)
								r.target_position.y = randf_range(spread, -spread)
								if r.is_colliding():
									if r.get_collider().is_in_group("enemy"):
										r.get_collider().enemyhealth -= shotgundamage * Globals.damageMult
									if r.get_collider().is_in_group("Chaospawn"):
										Chaospawnhurt.play(0.001)
									if r.get_collider().is_in_group("fiend"):
										$fiendhurt.play()
						$blast.play(0.0001)
						$muzzletimer.start(0.1)
						$Head/Camera3D/hand/shotgun/muzzleflash.show()
						if counter == 2:
							anim_player.play("ShotgunBlast")
							if anim_player.is_playing() and shotgun_fire == true:
								counter -= 1
								$Healthbar2/s/Console.add_text(" " + str(counter))
								if counter <= 0:
									counter = 3
									shotgun_fire = false
									$burst_timer.start()
								Globals.shells -= 1
								for r in ray_container.get_children():
									r.target_position.x = randf_range(spread, -spread)
									r.target_position.y = randf_range(spread, -spread)
									if r.is_colliding():
										if r.get_collider().is_in_group("enemy"):
											r.get_collider().enemyhealth -= shotgundamage * Globals.damageMult
										if r.get_collider().is_in_group("Chaospawn"):
											Chaospawnhurt.play(0.001)
										if r.get_collider().is_in_group("fiend"):
											$fiendhurt.play()
							$blast.play(0.0001)
							$muzzletimer.start(0.1)
							$Head/Camera3D/hand/shotgun/muzzleflash2.show()
						if counter == 1:
							anim_player.play("ShotgunBlast")
							if anim_player.is_playing() and shotgun_fire == true:
								counter -= 1
								$Healthbar2/s/Console.add_text(" " + str(counter))
								if counter <= 0:
									counter = 3
									shotgun_fire = false
									$burst_timer.start()
								Globals.shells -= 1
								for r in ray_container.get_children():
									r.target_position.x = randf_range(spread, -spread)
									r.target_position.y = randf_range(spread, -spread)
									if r.is_colliding():
										if r.get_collider().is_in_group("enemy"):
											r.get_collider().enemyhealth -= shotgundamage * Globals.damageMult
										if r.get_collider().is_in_group("Chaospawn"):
											Chaospawnhurt.play(0.001)
										if r.get_collider().is_in_group("fiend"):
											$fiendhurt.play()
							$blast.play(0.0001)
							$muzzletimer.start(0.1)
							$Head/Camera3D/hand/shotgun/muzzleflash3.show()
	if Globals.stormcloudshotgun == true:
		if current_weapon == 3:
			if Globals.shells > 0 and stormfire == true:
				if Input.is_action_just_pressed("fire"):
					Globals.shells -= 12
					if aimcast2.is_colliding():
						var t = tazerball.instantiate()
						stormmuzzle1.add_child(t)
						t.look_at(aimcast2.get_collision_point(), Vector3.UP)
						t.shoot = true
					else:
						var t = tazerball.instantiate()
						stormmuzzle1.add_child(t)
						t.look_at(-transform.basis.y, Vector3.UP)
						t.shoot = true
					$muzzletimer.start(0.1)
					$Head/Camera3D/hand/Stormcloud/stormflash.show()
					$Head/Camera3D/hand/tazerfire.play(0.001)
					stormfire = false
					$Head/Camera3D/hand/Stormcloud/stormtimer.start()
					anim_player.play("Stormcloud_fire")
	if Globals.railgun == true:
		if current_weapon == 6:
			if Globals.boltammo > 0:
				if Input.is_action_pressed("fire"):
					$muzzletimer.start()
					while soundnum == 0:
						soundnum = 1
					$charge.play(0.01)
					raildamage += 25
					anim_player.play("charge")
					if raildamage == 1000:
						raildamage = 100
				if Input.is_action_just_released("fire"):
					Globals.boltammo -= 1
					anim_player.stop()
					anim_player.play("Railgunfire")
					shooting = true
					$Head/Camera3D/hand/railgun/laser/Scaler.show()
					if $Head/Camera3D/hand/railgun/laser/RayCast3D.is_colliding():
						#maybe use $Head/Camera/hand/railgun/RayCast instead
						var target = $Head/Camera3D/hand/railgun/laser/RayCast3D.get_collider()
						if target.is_in_group("enemy"):
							target.enemyhealth -= 500 * Globals.damageMult
						if target.is_in_group("Chaospawn"):
							Chaospawnhurt.play(0.001)
						if target.is_in_group("fiend"):
							$fiendhurt.play()
					$muzzletimer.start(0.1)
					#railgunfire = false\
					raildamage = 0
					$Head/Camera3D/hand/Buster/muzzleflash.show()
					$Head/Camera3D/hand/railgun/railtimer.start()
					$Head/Camera3D/hand/railgun/railgunfire.play(0.001)
func weapon_select():
	if Input.is_action_just_pressed("1"):
		current_weapon = 1
	elif Input.is_action_just_pressed("2") and Globals.shotgun == true:
		current_weapon = 2
	elif Input.is_action_just_pressed("3") and Globals.Pulse == true:
		current_weapon = 4
	elif Input.is_action_just_pressed("4") and Globals.stormcloudshotgun == true:
		current_weapon = 3
	elif Input.is_action_just_pressed("5") and Globals.railgun == true:
		current_weapon = 6	
	if current_weapon == 1:
		AxelBuster.visible = true
		Globals.currammo = Globals.bullets
	else:
		AxelBuster.visible = false
	if current_weapon == 6:
		$Head/Camera3D/hand/railgun.visible = true
	else:
		$Head/Camera3D/hand/railgun.visible = false
	if current_weapon == 2:
		ray_container.visible = true
		shotgunmodel.visible = true
		Globals.currammo = Globals.shells
	else:
		ray_container.visible = false
		shotgunmodel.visible = false
		
	if current_weapon == 3 and Globals.stormcloudshotgun == true:
		stormcloud.visible = true
		Globals.currammo = Globals.shells
		
	else: 
		stormcloud.visible = false
		
	if current_weapon == 4 and Globals.Pulse == true:
		PulseRifle.visible = true
		Globals.currammo = Globals.pulseammo
	else: 
		PulseRifle.visible = false
	if current_weapon == 6 and Globals.railgun == true:
		Globals.currammo = Globals.boltammo
	
func fire():
	if Input.is_action_pressed("fire") and M9_fire == true:
		if Globals.pulseammo > 0:
			if current_weapon == 4:
				shooting = true
				Globals.pulseammo -= 1
				if Crosshair.is_colliding():
					var b = pulseball.instantiate()
					$Head/Camera3D/hand/M9PulseRifleHR/muzzle.add_child(b)
					b.look_at(Crosshair.get_collision_point(), Vector3.UP)
					b.shoot = true
				$muzzletimer.start(0.1)
				$Head/Camera3D/hand/M9PulseRifleHR/muzzleflash.show()
				$Head/Camera3D/hand/M9PulseRifleHR/m9_timer.start()
				pulsesound.play(0.001)
				anim_player.play("M9Fire")
				M9_fire = false
	if Input.is_action_pressed("fire") and Gunfire == false and Globals.armupgrade == true and Globals.upgrade == false:
		if current_weapon == 1 and Globals.bullets != 0:
			shooting = true
			Globals.bullets -= 1
			
			$muzzletimer.start(0.1)
			$Head/Camera3D/hand/Buster/Guntimer.start()
			$Head/Camera3D/hand/Buster/muzzleflash.show()
			$firesound.play(0.001)
			anim_player.play("XBusterFire")
			Gunfire = true
	if Input.is_action_pressed("fire") and Globals.upgrade == true:
		if current_weapon == 1:
			shooting = true
			Globals.upgradeShotNum += 1
			$Healthbar2/s/Console.add_text(" Powerup Ammo Left: " + str(2000 - Globals.upgradeShotNum))
			if Globals.upgradeShotNum > 2000:
				Globals.upgrade = false
			if raycast.is_colliding():
				var target = raycast.get_collider()
				if target.is_in_group("enemy"):
					target.enemyhealth -= 5 * Globals.damageMult
				if target.is_in_group("Chaospawn"):
					Chaospawnhurt.play(0.001)
				if target.is_in_group("fiend"):
					$fiendhurt.play()
			$muzzletimer.start(0.1)
			$Head/Camera3D/hand/Buster/muzzleflash.show()
			$firesound.play(0.001)
			anim_player.play("XBusterFire")
	if Input.is_action_just_pressed("fire") and Globals.upgrade == false and Globals.armupgrade == false:
		if Globals.bullets != 0:
			if current_weapon == 1:
				shootProj(Globals.bullets, pulseball, raycast, 5, 50)
				$muzzletimer.start(0.1)
				$Head/Camera3D/hand/Buster/muzzleflash.show()

				anim_player.play("XBusterFire")
#-------------------------------------------------------------------------------				
func shootProj(ammo, proj, raycaster, damage, speed):
	shooting = true
	ammo -= 1
	instance = proj.instantiate()
	instance.position = raycaster.global_position
	instance.basis = raycaster.global_transform.basis
	instance.DAMAGE = damage
	instance.SPEED = speed 
	instance.playerP = true 
	get_parent().add_child(instance)
#-------------------------------------------------------------------------------
func _ready():
	# Run this node's _physics_process AFTER the StateMachine child (default priority 0),
	# so the active state sets velocity first and move_and_slide() uses it the same tick.
	process_physics_priority = 1
	_setup_dash_feedback()
	#randomize()
	$Head/Camera3D/hand/Buster/muzzleflash.hide()
	$Head/Camera3D/hand/railgun/laser/Scaler.hide()
	$Head/Camera3D/hand/shotgun/muzzleflash.hide()
	$Head/Camera3D/hand/Stormcloud/stormflash.hide()
	$Head/Camera3D/hand/M9PulseRifleHR/muzzleflash.hide()
	get_tree().paused = false
	for r in ray_container.get_children():
		r.target_position.x = randf_range(spread, -spread)
		r.target_position.y = randf_range(spread, -spread)
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# camera controls
	if (event is InputEventAction):
		if Input.is_action_just_pressed("escape"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if (event is InputEventMouseButton):
		if Input.is_action_just_pressed("fire"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if (event is InputEventJoypadMotion):
		var input_dir = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
		# Apply rotation using delta for frame-rate independence
		# Rotate Pivot Y for Left/Right (Yaw)
		head.rotate_y(-input_dir.x * mouse_sense)
		camera.rotate_x(-input_dir.y * mouse_sense) #FIXME consider adjusting sensitivity settings so we don't need to reduce it here
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if (event is InputEventMouseMotion) and (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		#var mouseInput : Vector2#OLD CODE HERE
		#mouseInput.x += event.relative.x
		#mouseInput.y += event.relative.y
		#camera.rotation_degrees.y -= mouseInput.x * mouse_sense
		#head.rotation_degrees.x -= mouseInput.y * mouse_sense
		head.rotate_y(-event.relative.x * mouse_sense)
		camera.rotate_x(-event.relative.y * mouse_sense) #FIXME consider adjusting sensitivity settings so we don't need to reduce it here
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func controls(delta):
	#get keyboard input
	#if Input.is_action_just_pressed("parry"):
		#if parry == false:
		#	$touch/CSGSphere3D.show()
		#	emit_signal("parry")
		#	$ParryTimer.start()
		#	parry = true
	if is_on_wall():
		AirDashUsed = false
	if not Input.is_action_pressed("fire"):
		shooting = false
	if not Input.is_action_just_pressed("fire"):
		shooting = false
	#if Globals.boomer == true:#FIXME something with this code causes an error, so I commented it out for now; still, it needs fixing
		#$ColorRect.show()#FIXME got an error here
	#else:
		#$ColorRect.hide()
	if Globals.shells < 0:
		Globals.shells = 0
	if Globals.bullets < 0:
		Globals.bullets = 0
	if Globals.boltammo < 0:
		Globals.boltammo = 0
	if freeze != true:
		if death2 != true:
			fire()
			weapon_select()
			fire_shotgun()
		if health != Globals.maxHealth:
			$Healthbar/s/ProgressBar.value = health
			print(health)
		if health == Globals.maxHealth:
			$Healthbar/s/ProgressBar.value = health
		#if Input.is_action_just_pressed("abort"):
			#emit_signal("death")
			#health = -1
			#death2 = true
		if health <= 0:
			emit_signal("death")
			death2 = true
			health = -1
		if Globals.upgrade != true:
			$Healthbar2/s/Ammocounter/Ammonum.text = str(Globals.currammo)
		else:
			$Healthbar2/s/Ammocounter/Ammonum.text = str(Globals.currammo)

#---------------------------------------------------------------------------------
# MOVEMENT TOOLKIT
# The states call these to set this tick's velocity; move_and_slide() in
# _physics_process then does the moving. _ready() sets process_physics_priority
# so this node always runs AFTER the StateMachine.

## Reads the jump and dash buttons once per physics tick. A fresh press goes into the jump buffer,
## so a press slightly before landing (or touching a wall) still counts.
func _poll_input() -> void:
	var frame := Engine.get_physics_frames()
	if frame == _polled_frame:
		return
	_polled_frame = frame
	# Edge-detected here (not with is_action_just_pressed) so each press counts exactly once,
	# no matter which state reads it or when
	# (just_pressed also catches a release + re-press inside one tick, e.g. mashing wall kicks)
	var jump_down := Input.is_action_pressed("jump")
	if (Input.is_action_just_pressed("jump") or (jump_down and not _jump_was_down)) and not death2:
		_jump_buffer = maxf(jump_buffer_time, 0.001)
	_jump_was_down = jump_down
	if not jump_down:
		_jump_released = true
	var dash_down := Input.is_action_pressed("dash")
	_dash_fresh = (Input.is_action_just_pressed("dash") or (dash_down and not _dash_was_down)) and not death2
	_dash_was_down = dash_down

## Reads movement input into wish_dir. Mouse look turns $Head (not the body),
## so movement is relative to the head's facing. Zero while dead.
func update_wish_dir() -> Vector3:
	_poll_input()
	input_vec = Vector2.ZERO
	if not death2:
		input_vec = Input.get_vector("left", "right", "up", "down")
	wish_dir = head.global_transform.basis * Vector3(input_vec.x, 0.0, input_vec.y)
	wish_dir.y = 0.0
	return wish_dir

func has_move_input() -> bool:
	return update_wish_dir() != Vector3.ZERO

## True if a jump press is waiting to be used (fresh or buffered).
func jump_requested() -> bool:
	_poll_input()
	return _jump_buffer > 0.0

## Ground version, Quake 1 rules: a fresh/buffered press, or jump held down as long as you let go
## of it at least once since your last jump (FL_JUMPRELEASED). So you can press and hold jump
## before landing and it fires on the landing frame; holding it from the last jump does nothing
## unless auto_bhop is on.
func ground_jump_requested() -> bool:
	if jump_requested():
		return true
	return not death2 and Input.is_action_pressed("jump") and (_jump_released or auto_bhop)

## True only on the tick dash was pressed.
func dash_just_pressed() -> bool:
	_poll_input()
	return _dash_fresh

## A jump or wall kick is the dash version if you're dashing, holding dash, or a ground
## dash ended within dash_jump_window. So "dash, release, jump" works, and so does
## holding dash and pressing jump over and over to chain dash jumps.
func wants_dash_jump() -> bool:
	return dashing or dash_held() or _dash_jump_timer > 0.0

## Called by the Dashing state when a ground dash ends, to open the dash-jump window.
func open_dash_jump_window() -> void:
	_dash_jump_timer = dash_jump_window

func time_since_floor() -> float:
	return _time_since_floor

func dash_held() -> bool:
	return not death2 and Input.is_action_pressed("dash")

func near_wall() -> bool:
	return _time_since_wall <= wall_grace_time and not is_on_floor()

func can_coyote_jump() -> bool:
	return not _jumped_since_floor and _time_since_floor <= coyote_time

func _h_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()

## Jump (ground, coyote or double). The dash version raises your air momentum to dash
## speed, like X's dash jump, and it lasts until you land or grab a wall.
func do_jump(dash_version: bool) -> void:
	_jump_buffer = 0.0
	_jump_released = false
	_dash_jump_timer = 0.0
	_jumped_since_floor = true
	jump_rising = true
	_jump_timer = 0.0
	diving = false
	velocity.y = jump_velocity
	air_momentum = maxf(speed, _h_speed())
	if dash_version:
		dash_feedback("dash_jump")
		air_momentum = maxf(air_momentum, dash_speed)
		update_wish_dir()
		if wish_dir != Vector3.ZERO:
			var burst := wish_dir.normalized() * air_momentum
			velocity.x = burst.x
			velocity.z = burst.z

## X's wall kick: a short push away from the wall plus a full jump. Steering is locked for
## wall_kick_lock_time so the push happens; after that, holding toward the wall brings you
## back higher up, so repeated kicks climb. The dash version pushes harder and gives you dash
## momentum afterwards.
func do_wall_kick(dash_version: bool) -> void:
	_jump_buffer = 0.0
	_jump_released = false
	_dash_jump_timer = 0.0
	_jumped_since_floor = true
	jump_rising = true
	_jump_timer = 0.0
	diving = false
	if dash_version:
		dash_feedback("dash_wall_kick")
	var push := dash_wall_kick_speed if dash_version else wall_kick_speed
	velocity = Vector3(_last_wall_normal.x * push, jump_velocity, _last_wall_normal.z * push)
	_air_lock = wall_kick_lock_time
	air_momentum = maxf(dash_speed if dash_version else speed, push)
	_time_since_wall = 1000.0

## Left the ground without jumping (ran off a ledge, or a dash ended in the air).
## Whatever speed you had becomes your air momentum.
func begin_fall() -> void:
	jump_rising = false
	air_momentum = maxf(speed, _h_speed())

## How fast a dash goes when started at `entry_speed`: at least dash_speed, and always at least
## dash_min_boost faster than both run speed and the speed you dashed from. So a dash is always
## faster than normal movement, including a fast bhop.
func dash_target_speed(entry_speed: float) -> float:
	return maxf(dash_speed, maxf(speed, entry_speed) + dash_min_boost)

## Letting go of dash early: like releasing jump, the dash's extra speed is cut. You drop back to
## the speed you had before the dash (or run speed if that was slower), never below it.
func cut_dash_speed(entry_speed: float) -> void:
	var h := Vector2(velocity.x, velocity.z).limit_length(maxf(speed, entry_speed))
	velocity.x = h.x
	velocity.z = h.y

## Refills everything that recharges on touching the ground.
func refill_air_moves() -> void:
	AirDashUsed = false
	jumpnum = 0
	diving = false

## Ground movement, Quake 1 SV_UserFriction then SV_Accelerate. Speed above `speed` (from a
## dash or bhop) bleeds off gradually instead of snapping.
func ground_move(delta: float) -> void:
	update_wish_dir()
	var cur_speed := Vector2(velocity.x, velocity.z).length() # Quake 1 measures horizontal speed
	if cur_speed > 0.0:
		var control := maxf(cur_speed, ground_decel)
		var drop := control * ground_friction * delta
		velocity *= maxf(cur_speed - drop, 0.0) / cur_speed

	var dir := wish_dir.normalized()
	var wish_speed := speed * wish_dir.length()
	var add_speed_till_cap := wish_speed - velocity.dot(dir)
	if add_speed_till_cap > 0.0:
		var accel_speed := minf(ground_accel * delta * wish_speed, add_speed_till_cap)
		velocity += accel_speed * dir

	_headbob_effect(delta)

## Air movement.
## Vertical: gravity, X's terminal fall speed, and variable jump height.
## Horizontal, two layers:
##  1. Quake 1 air acceleration (SV_AirAccelerate), always on. This is what makes strafe-jumping
##     and bunny hopping gain speed.
##  2. Mega Man X control, on whenever you're NOT strafe-jumping: you steer toward wish_dir at
##     your full air momentum, so you can reverse a dash jump at dash speed and turn with the
##     mouse while holding forward without losing speed. It switches off while you strafe into a
##     mouse turn, because it would line your velocity up with your input and erase the angle
##     Quake 1 needs to gain speed.
func air_move(delta: float) -> void:
	update_wish_dir()

	if jump_rising:
		_jump_timer += delta
		if velocity.y <= 0.0:
			jump_rising = false
		elif not Input.is_action_pressed("jump") and _jump_timer >= min_jump_hold:
			velocity.y = minf(velocity.y, jump_cut_velocity)
			jump_rising = false
	velocity.y -= gravity * delta
	if not diving:
		velocity.y = maxf(velocity.y, -max_fall_speed)

	var h := Vector2(velocity.x, velocity.z)
	var dir := Vector2(wish_dir.x, wish_dir.z).normalized()
	var tilt := minf(wish_dir.length(), 1.0)

	# Strafe-jumping = holding a strafe key and turning the mouse the same way (mouse right turns
	# the head to negative yaw, so strafe right + turn right means opposite signs)
	var turn := wrapf(head.global_rotation.y - _last_yaw, -PI, PI)
	if input_vec.x != 0.0 and absf(turn) > 0.0005 and signf(input_vec.x) == -signf(turn):
		_strafe_jump_timer = strafe_jump_hold
	strafe_jumping = _strafe_jump_timer > 0.0 and input_vec.x != 0.0
	_strafe_jump_timer = maxf(_strafe_jump_timer - delta, 0.0)

	# Layer 1: Quake 1 SV_AirAccelerate, scaled to this game's units
	if dir != Vector2.ZERO and _air_lock <= 0.0:
		var wishspeed := speed * tilt
		var wishspd := minf(wishspeed, speed * q1_air_cap_ratio)
		var addspeed := wishspd - h.dot(dir)
		if addspeed > 0.0:
			h += dir * minf(q1_air_accelerate * wishspeed * delta, addspeed)

	# Anything that made you faster (strafe-jumping, surf, knockback, dashes) becomes steerable momentum
	air_momentum = maxf(air_momentum, h.length())

	# Layer 2: Mega Man X control
	if _air_lock > 0.0:
		_air_lock -= delta # wall-kick push: no steering for a moment
	elif strafe_jumping:
		pass # pure Quake 1 while strafe-jumping
	elif dir != Vector2.ZERO:
		# Stick tilt scales normal air speed, but not carried dash momentum: with dash momentum
		# any tilt steers at full momentum, so a dash jump is exactly as fast as the dash
		# (the ground dash ignores tilt too). Blends in over the first few units of extra speed.
		var extra := clampf((air_momentum - speed) / maxf(0.25 * (dash_speed - speed), 0.001), 0.0, 1.0)
		var target_speed := air_momentum * lerpf(tilt, 1.0, extra)
		var cur := h.length()
		var ang := h.angle_to(dir) if cur > 0.5 else 0.0
		if cur <= 0.5 or absf(ang) > deg_to_rad(air_reverse_angle):
			# From a standstill, or a turn-around: go straight to the new direction (X flips instantly)
			h = h.move_toward(dir * target_speed, air_control * delta)
		else:
			# Turning: rotate your velocity toward the input at full speed, so turns never cost speed
			var rot := clampf(ang, -air_turn_rate * delta, air_turn_rate * delta)
			h = h.rotated(rot).normalized() * move_toward(cur, target_speed, air_control * delta)
	elif air_release_brake > 0.0:
		# No movement input: stop, like X. Your air momentum is kept, so pressing a direction
		# again before you land picks your dash / bhop speed right back up (X's dash jump works
		# the same way). Landing without input ends it.
		h = h.move_toward(Vector2.ZERO, air_release_brake * delta)
	velocity.x = h.x
	velocity.z = h.y

	if is_on_wall():
		# Floating mode is much less jittery for surfing. Switch into it on steep ramps
		# and back to grounded on anything else (walls or floors).
		var wall_normal := get_wall_normal()
		var is_wall_vertical := absf(wall_normal.dot(Vector3.UP)) < 0.1
		if is_surface_too_steep(wall_normal) and not is_wall_vertical:
			motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(wall_normal, 1, delta) # allows surf

## X's wall slide: falling while holding into a wall.
func is_wall_sliding() -> bool:
	if not is_on_wall() or is_on_floor() or velocity.y > 0.0 or diving or wish_dir == Vector3.ZERO:
		return false
	var n := get_wall_normal()
	if absf(n.y) > 0.3:
		return false # a ramp, not a wall
	return wish_dir.normalized().dot(n) < -0.3

func clip_velocity(normal: Vector3, overbounce: float, _delta: float) -> void:
	# Strafing into a ramp + gravity: remove the part of velocity going into the surface,
	# so you slide along it instead of stopping. That is surfing.
	var backoff := velocity.dot(normal) * overbounce
	if backoff >= 0: return # already moving away from the surface (prevents sticking to ceilings)
	velocity -= normal * backoff
	var adjust := velocity.dot(normal)
	if adjust < 0.0:
		velocity -= normal * adjust

func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > floor_max_angle

func _headbob_effect(delta: float) -> void:
	var h_speed := Vector2(velocity.x, velocity.z).length()
	t_bob += delta * minf(h_speed, speed * 1.5) * BOB_SPEED_SCALE
	camera.position = _camera_base_pos + Vector3(
		cos(t_bob * BOB_FREQ * 0.5) * BOB_AMP,
		sin(t_bob * BOB_FREQ) * BOB_AMP,
		0
	)

func _push_away_rigid_bodies():
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			var velocity_diff_in_push_dir = velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			const MY_APPROX_MASS_KG = 80.0
			var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			if mass_ratio < 0.25:
				continue # don't push things 4x heavier than us
			push_dir.y = 0
			var push_force = mass_ratio * 5.0
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)

## Bookkeeping after each move: floor/wall timers (coyote time, wall-kick grace), jump buffer, turn tracking.
func _after_move(delta: float) -> void:
	if is_on_floor():
		_time_since_floor = 0.0
		_jumped_since_floor = false
		diving = false
	else:
		_time_since_floor += delta
	if is_on_wall() and absf(get_wall_normal().y) < 0.3:
		_last_wall_normal = Vector3(get_wall_normal().x, 0.0, get_wall_normal().z).normalized()
		_time_since_wall = 0.0
	else:
		_time_since_wall += delta
	_jump_buffer = maxf(_jump_buffer - delta, 0.0)
	_dash_jump_timer = maxf(_dash_jump_timer - delta, 0.0)
	_last_yaw = head.global_rotation.y

## Dash feedback: a sound, an FOV burst and the dash_move signal at the moment a dash
## move starts. The dash states and do_jump/do_wall_kick call this.
func dash_feedback(kind: String) -> void:
	var is_jump := kind == "dash_jump" or kind == "dash_wall_kick"
	_fov_punch = maxf(_fov_punch, dash_jump_fov_punch if is_jump else dash_fov_punch)
	var stream : AudioStream = dash_jump_sound if is_jump else dash_sound
	if stream and _sfx:
		_sfx.stream = stream
		_sfx.play()
	dash_move.emit(kind)

func _setup_dash_feedback() -> void:
	_sfx = AudioStreamPlayer.new()
	_sfx.name = "DashSFX"
	add_child(_sfx)
	if not speed_lines:
		return
	# Full-screen speed-line overlay, drawn above the 3D view but below the HUD (layer -1)
	var layer := CanvasLayer.new()
	layer.name = "SpeedLines"
	layer.layer = -1
	add_child(layer)
	_speed_lines_rect = ColorRect.new()
	_speed_lines_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_speed_lines_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = Shader.new()
	mat.shader.code = SPEED_LINES_SHADER
	mat.set_shader_parameter("line_color", speed_lines_color)
	_speed_lines_rect.material = mat
	_speed_lines_rect.visible = false
	layer.add_child(_speed_lines_rect)

const SPEED_LINES_SHADER := """
shader_type canvas_item;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 0.55);

float hash(float n) { return fract(sin(n) * 43758.5453123); }

void fragment() {
	vec2 uv = UV - vec2(0.5);
	uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x; // keep lines radial on wide screens
	float r = length(uv);
	float cell = (atan(uv.y, uv.x) / TAU + 0.5) * 110.0;
	float id = floor(cell);
	float rnd = hash(id);
	// each line flickers on and off at random, re-rolled 14 times a second
	float on = step(0.45, hash(id * 3.7 + floor(TIME * 14.0 + rnd * 5.0)));
	float width = 0.12 + 0.2 * rnd;
	float thin = 1.0 - smoothstep(0.0, width, abs(fract(cell) - 0.5));
	// lines start further out when intensity is low, reaching inward as it rises
	float inner = mix(0.62, 0.30, intensity) + rnd * 0.12;
	float radial = smoothstep(inner, inner + 0.22, r);
	COLOR = vec4(line_color.rgb, line_color.a * thin * on * radial * intensity);
}
"""

## Speed feedback every rendered frame: FOV eases wider with speed above run speed (plus the
## burst from dash_feedback), and speed lines show while you're going dash speed.
func _process(delta: float) -> void:
	var over := clampf((_h_speed() - speed) / maxf(dash_speed - speed, 0.001), 0.0, 1.0)
	# While dashing it's always full dash level (even during the ramp-up), so the dash, the
	# air dash and the dash jump that follows all share the same FOV and speed lines
	var level := 1.0 if dashing else over
	_fov_punch = lerpf(_fov_punch, 0.0, 1.0 - exp(-6.0 * delta))
	if dash_fov_kick > 0.0 or _fov_punch > 0.01:
		var target := _base_fov + maxf(dash_fov_kick, 0.0) * level + _fov_punch
		var rate := fov_attack if target > camera.fov else fov_smoothing
		camera.fov = lerpf(camera.fov, target, 1.0 - exp(-rate * delta))
	if _speed_lines_rect:
		# Lines only near dash speed, full strength at dash speed and while dashing
		var want := 1.0 if dashing else smoothstep(0.5, 1.0, over)
		var lrate := fov_attack if want > _speed_lines_amount else fov_smoothing
		_speed_lines_amount = lerpf(_speed_lines_amount, want, 1.0 - exp(-lrate * delta))
		_speed_lines_rect.visible = _speed_lines_amount > 0.01
		_speed_lines_rect.material.set_shader_parameter("intensity", _speed_lines_amount)

func _physics_process(delta):
	# The active state has already set this tick's velocity (see _ready).
	_poll_input()
	controls(delta)
	_push_away_rigid_bodies()
	move_and_slide()
	_after_move(delta)
	$Label2.text = str(dashing)
	$Label4.text = str(AirDashUsed)
#---------------------------------------------------------------------------------

func _on_muzzletimer_timeout():
	soundnum = 0
	$Head/Camera3D/hand/Buster/muzzleflash.hide()
	$Head/Camera3D/hand/shotgun/muzzleflash.hide()
	$Head/Camera3D/hand/shotgun/muzzleflash2.hide()
	$Head/Camera3D/hand/shotgun/muzzleflash3.hide()
	$Head/Camera3D/hand/Stormcloud/stormflash.hide()
	$Head/Camera3D/hand/railgun/laser/Scaler.hide()
	$Head/Camera3D/hand/M9PulseRifleHR/muzzleflash.hide()

func _on_Deathscreen_reset():
	health = Globals.maxHealth

func _on_FPS_death():
	speed = 0
	#$AudioStreamPlayer.play()
func _on_stormtimer_timeout():
	stormfire = true

func _on_text_timer_timeout():
	$Healthbar2/s/Console.clear()

func _on_shotgun_timer_timeout():
	shotgun_fire = true

func _on_m9_timer_timeout():
	M9_fire = true


func _on_Level1_area_entered(area):
	get_tree().change_scene_to_file("res://scenes/real_levels/E1M1.tscn")
	$Healthbar2/s/Console.add_text(" Entered Level E1M1 ")



func _on_EndofLevel_area_entered(area):
	if Globals.level2unlocked == true:
		get_tree().change_scene_to_file("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M1 ")


func _on_Level2_area_entered(area):
	if Globals.level2unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M2.tscn")
		$Healthbar2/s/Console.add_text(" Entered Level E1M2 ")
	else:
		$Healthbar2/s/Console.add_text(" Sorry, you can't enter E1M2 yet ")

func _on_end_area_entered(area):
	if Globals.level3unlocked == true:
		get_tree().change_scene_to_file("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M2 ")


func _on_lava_body_entered(body):
	health = 0




func _on_endit_body_entered(body):
	if Globals.level4unlocked == true:
		get_tree().change_scene_to_file("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M3 ")


func _on_level4quit_body_entered(body):
	if Globals.level5unlocked == true:
		get_tree().change_scene_to_file("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M5 ")
		
func _on_Area_area_entered(area):
	get_tree().change_scene_to_file("res://scenes/tutorials/tut1.tscn")


func _on_death_area_entered(area):
	health = 0


func _on_railtimer_timeout():
	railgunfire = true



func _on_level5exitarea_area_entered(area):
	if Globals.level6unlocked == true:
		get_tree().change_scene_to_file("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M5 ")
	


func _on_bossend_body_entered(body):
	if Globals.level7unlocked == true:
		get_tree().change_scene_to_file("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M6 ")


func _on_Ikenga_freeze():
	freeze = !freeze


func _on_kickDamageArea_body_entered(body):
	if diving == true:
		if body.is_in_group("enemy"):
			body.enemyhealth -= damage * 3 * Globals.damageMult
			if body.is_in_group("Chaospawn"):
				Chaospawnhurt.play(0.001)
			if body.is_in_group("fiend"):
				$fiendhurt.play()
			if body.is_in_group("dummy"):
				body.kicked = true


func _on_exitarea3_body_entered(body):
	if Globals.level8unlocked == true:
		get_tree().change_scene_to_file("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M8 ")




func _on_burst_timer_timeout():
	shotgun_fire = true


func _on_manihate_area_entered(area):
	get_tree().change_scene_to_file("res://scenes/tutorials/tut2.5.tscn")




func _on_Guntimer_timeout():
	Gunfire = false


func _on_dashTimer_timeout():
	pass # old dash timer, unused now (DashDuration/DashCooldown replaced it); safe to delete with the $dashTimer node


func _on_touch_body_entered(body):
	Globals.itemCount += 1
	if body.is_in_group("Tut"):
		body.start_dialog()
	if body.is_in_group("Non"):
		body.start_dialog()
	if body.is_in_group("pulse") :
		Globals.Pulse = true
		body.queue_free()
		text_timer.start()
		$ching.play()
		Globals.pulseammo += 100 * Globals.ammoMult
		$Healthbar2/s/Console.add_text(" Abtained a M9A4 Red Ranger ")
	if body.is_in_group("shotgun") :
		Globals.shotgun = true
		text_timer.start()
		body.queue_free()
		Globals.shells += 12 * Globals.ammoMult
		$ching.play()
		$Healthbar2/s/Console.add_text(" Abtained a Holy-Land Tek Bethlehem Shotgun ")
	if body.is_in_group("railgunfloor") :
		Globals.railgun = true
		text_timer.start()
		body.queue_free()
		Globals.boltammo += 10 * Globals.ammoMult
		$ching.play()
		$Healthbar2/s/Console.add_text(" Abtained a Esbjornson Europa Soldier ")
	if body.is_in_group("railgun") :
		Globals.railgun = true
		text_timer.start()
		body.queue_free()
		Globals.boltammo += 10 * Globals.ammoMult
		$ching.play()
		$Healthbar2/s/Console.add_text(" Abtained a Esbjornson Europa Soldier ")
	if body.is_in_group("stormcloudshotgun") :
		Globals.stormcloudshotgun = true
		body.queue_free()
		Globals.shells += 12 * Globals.ammoMult
		text_timer.start()
		$ching.play()
		$Healthbar2/s/Console.add_text(" Abtained a Maxfield Stormcloud Shotgun ")
	if body.is_in_group("shell"):
		Globals.shells += 12 * Globals.ammoMult
		text_timer.start()
		$Healthbar2/s/Console.add_text(" Abtained 12 Shotgun Shells ")
		body.queue_free()
		$clip.play()
	if body.is_in_group("redammo"):
		Globals.pulseammo += 100 * Globals.ammoMult
		text_timer.start()
		$Healthbar2/s/Console.add_text(" Abtained 12 Shotgun Shells ")
		body.queue_free()
		$clip.play()
	if body.is_in_group("boltammo"):
		Globals.boltammo += 5 * Globals.ammoMult
		text_timer.start()
		$Healthbar2/s/Console.add_text(" Abtained 5 bolts ")
		body.queue_free()
		$clip.play()
	if body.is_in_group("bullets"):
		body.queue_free()
		Globals.bullets += 25 * Globals.ammoMult
		text_timer.start()
		$Healthbar2/s/Console.add_text(" Abtained 25 .50 Eagle rounds ")
		$clip.play()
	if body.is_in_group("medbox"):
		if health != Globals.maxHealth and health < Globals.maxHealth:
			health += 25
			text_timer.start()
			$Healthbar2/s/Console.add_text(" Abtained 25 health ")
			body.queue_free()
			$healthup.play()
	if body.is_in_group("medboxsmall"):
		if health != Globals.maxHealth:
			health += 2
			text_timer.start()
			$Healthbar2/s/Console.add_text(" Abtained 2 health ")
			body.queue_free()
			$healthup.play()
	if body.is_in_group("level2key"):
		Globals.level2unlocked = true
		text_timer.start()
		health = Globals.maxHealth
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level3key"):
		Globals.level3unlocked = true
		text_timer.start()
		health = Globals.maxHealth
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level4key"):
		Globals.level4unlocked = true
		text_timer.start()
		health = Globals.maxHealth
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level5key"):
		Globals.level5unlocked = true
		text_timer.start()
		health = Globals.maxHealth
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level6key"):
		Globals.level6unlocked = true
		text_timer.start()
		health = Globals.maxHealth
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level7key"):
		Globals.level7unlocked = true
		text_timer.start()
		health = Globals.maxHealth
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level8key"):
		Globals.level8unlocked = true
		text_timer.start()
		health = Globals.maxHealth
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("upgrade"):
		Globals.upgrade = true
		text_timer.start()
		health = Globals.maxHealth
		$Healthbar2/s/Console.add_text(" Got a Magnus-Buster Powerup! ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("armupgrade"):
		Globals.armupgrade = true
		Globals.upgrade = true
		text_timer.start()
		health = Globals.maxHealth
		$Healthbar2/s/Console.add_text(" Got the Magnus-Buster Upgrade! You can now shoot full auto all the time!")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("legupgrade"):
		Globals.legupgrade = true
		text_timer.start()
		health = Globals.maxHealth
		$Healthbar2/s/Console.add_text(" Got the Feet Upgrade! You can jump twice now!")
		$AudioStreamPlayer.play()
		body.queue_free()
		body.queue_free()


func _on_ParryTimer_timeout():
	pass # Replace with function body.


func _on_kick_damage_area_body_entered(body: Node3D) -> void:
	if diving == true:
		if body.is_in_group("enemy"):
			body.enemyhealth -= damage * 2 * Globals.damageMult
			if body.is_in_group("Chaospawn"):
				Chaospawnhurt.play(0.001)
			if body.is_in_group("fiend"):
				$fiendhurt.play()
			if body.is_in_group("dummy"):
				body.kicked = true
