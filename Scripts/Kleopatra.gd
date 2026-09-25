extends CharacterBody3D

#Variables
var jump = 50
var gravity = 80
var speed = 70
var duck = false
var death = false
const ACCEL_DEFAULT = 15
const ACCEL_AIR = 25
var burston = false
@export var trail: PackedScene = null
var highjump = false
@onready var accel = ACCEL_DEFAULT
var dashnum = 0
var diving = false
var ground = true
var health = 100
var M9_fire = true
var counter = 3
var shotgundamage = 10
var spread = 5
var shotgun_fire = true
var stormfire = true
var dashcooldown = 0
var enter2 = false
var damage = 25
var jumping = false
var cam_accel = 40
var in_air = false
var burstnum = 0
var dashing = false
var mouse_sense = 0.1
var snap 
var soundnum = 0
var upgradeShotNum = 0
var direction = Vector3()
var velocity = Vector3()
var gravity_direction = Vector3()
var movement = Vector3()
var max_health = 100
var current_weapon = 1
var leanRight = false
var leanLeft = false
var enter = false
@export var BallSpeed: int = 50
var freeze = false
var Ball = preload("res://scenes/PulseBall.tscn")
var railgunfire = true #boolean if the railgun can fire
const ADS_LERP = 20
var raildamage = 0
var enter3 = false
var fview = {"Default": 118, "ADS": 50, "ADSSCOPE": 10, "DASH": 179}
#These are the variables to check if the player has the weapons in the game
#--------------------------------------------------------------------------
signal death
signal loading
signal pause
#--------------------------------------------------------------------------
#Onready vars
@onready var head = $CollisionShape3D/Head
@onready var _Camera = get_viewport().get_camera_3d()
@onready var _Viewport = get_viewport().get_size()
@onready var camera = $CollisionShape3D/Head/Camera3D
@onready var hand = $CollisionShape3D/Head/Camera3D/hand
@onready var anim_player = $CollisionShape3D/Head/Camera3D/hand/AnimationPlayer
@onready var raycast = $CollisionShape3D/Head/Camera3D/hand/Buster/RayCast3D
@onready var Chaospawnhurt = $ChaosPawnHurt
@onready var text_timer = $text_timer
@onready var coll = $CollisionShape3D
@onready var ray = $CollisionShape3D/Head/Camera3D/hand/Buster/RayCast3D
@onready var PulseRifle = $CollisionShape3D/Head/Camera3D/hand/M9PulseRifleHR
@onready var AxelBuster = $CollisionShape3D/Head/Camera3D/hand/Buster
@onready var pulseball = preload("res://scenes/PulseBall.tscn")
@onready var tazerball = preload("res://scenes/Tazerball.tscn")
@onready var aimcast2 = $CollisionShape3D/Head/Camera3D/hand/Stormcloud/RayCast3D
@onready var pulsesound = $CollisionShape3D/Head/Camera3D/hand/pulsefire
@onready var ray_container = $CollisionShape3D/Head/Camera3D/hand/ShotgunRayContainer
@onready var shotgunmodel = $CollisionShape3D/Head/Camera3D/hand/shotgun
@onready var stormcloud = $CollisionShape3D/Head/Camera3D/hand/Stormcloud
@onready var flash = $CollisionShape3D/Head/Camera3D/hand/Stormcloud/stormflash
@onready var stormmuzzle1 = $CollisionShape3D/Head/Camera3D/hand/muzzlestorm
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
									r.get_collider().enemyhealth -= shotgundamage
									if r.get_collider().is_in_group("Chaospawn"):
										Chaospawnhurt.play(0.001)
									if r.get_collider().is_in_group("fiend"):
										$fiendhurt.play()
						if counter == 3 and not Input.is_action_pressed("fire"):
							$CollisionShape3D/Head/Camera3D/hand/shotgun/shotgun_timer.start()
						$muzzletimer.start(0.1)
						$CollisionShape3D/Head/Camera3D/hand/shotgun/shotgun.play(0.0001)
						$CollisionShape3D/Head/Camera3D/hand/shotgun/muzzleflash.show()
						anim_player.play("shotgunfire")
						$CollisionShape3D/Head/Camera3D/hand/shotgun/shotgun_timer.start()
						shotgun_fire = false
				if Input.is_action_pressed("fire2"):
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
										r.get_collider().enemyhealth -= shotgundamage
									if r.get_collider().is_in_group("Chaospawn"):
										Chaospawnhurt.play(0.001)
									if r.get_collider().is_in_group("fiend"):
										$fiendhurt.play()
						$blast.play(0.0001)
						$muzzletimer.start(0.1)
						$CollisionShape3D/Head/Camera3D/hand/shotgun/muzzleflash.show()
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
											r.get_collider().enemyhealth -= shotgundamage
										if r.get_collider().is_in_group("Chaospawn"):
											Chaospawnhurt.play(0.001)
										if r.get_collider().is_in_group("fiend"):
											$fiendhurt.play()
							$blast.play(0.0001)
							$muzzletimer.start(0.1)
							$CollisionShape3D/Head/Camera3D/hand/shotgun/muzzleflash.show()
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
											r.get_collider().enemyhealth -= shotgundamage
										if r.get_collider().is_in_group("Chaospawn"):
											Chaospawnhurt.play(0.001)
										if r.get_collider().is_in_group("fiend"):
											$fiendhurt.play()
							$blast.play(0.0001)
							$muzzletimer.start(0.1)
							$CollisionShape3D/Head/Camera3D/hand/shotgun/muzzleflash.show()
	if Globals.stormcloudshotgun == true:
		if current_weapon == 3:
			if Globals.shells > 0 and stormfire == true:
				if Input.is_action_just_pressed("fire"):
					Globals.shells -= 1
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
					$CollisionShape3D/Head/Camera3D/hand/Stormcloud/stormflash.show()
					$CollisionShape3D/Head/Camera3D/hand/tazerfire.play(0.001)
					stormfire = false
					$CollisionShape3D/Head/Camera3D/hand/Stormcloud/stormtimer.start()
					anim_player.play("Stormcloud_fire")
					
	if Globals.railgun == true:
		if current_weapon == 6:
			if Globals.boltammo > 0:
				if Input.is_action_pressed("fire"):
					$muzzletimer.start()
					while soundnum == 0:
						$firesound.play(0.001)
						soundnum = 1
					$charge.play(0.01)
					raildamage += 25
					anim_player.play("charge")
					if raildamage == 1000:
						raildamage == 100
				if Input.is_action_just_released("fire"):
					Globals.boltammo -= 1
					anim_player.play("Railgunfire")
					$CollisionShape3D/Head/Camera3D/hand/railgun/laser/Scaler.show()
					if $CollisionShape3D/Head/Camera3D/hand/railgun/laser/RayCast3D.is_colliding():
						#maybe use $Head/Camera/hand/railgun/RayCast instead
						var target = $CollisionShape3D/Head/Camera3D/hand/railgun/laser/RayCast3D.get_collider()
						if target.is_in_group("enemy"):
							target.enemyhealth -= 500
						if target.is_in_group("Chaospawn"):
							Chaospawnhurt.play(0.001)
						if target.is_in_group("fiend"):
							$fiendhurt.play()
					$muzzletimer.start(0.1)
					#railgunfire = false\
					raildamage = 0
					$CollisionShape3D/Head/Camera3D/hand/Buster/muzzleflash.show()
					$CollisionShape3D/Head/Camera3D/hand/railgun/railtimer.start()
					$CollisionShape3D/Head/Camera3D/hand/railgun/railgunfire.play(0.001)
func weapon_select():
	if Input.is_action_just_pressed("AxelBuster"):
		current_weapon = 1
	elif Input.is_action_just_pressed("Shotgun") and Globals.shotgun == true:
		current_weapon = 2
	elif Input.is_action_just_pressed("M9PulseRifle") and Globals.Pulse == true:
		current_weapon = 4
	elif Input.is_action_just_pressed("Stormcloud") and Globals.stormcloudshotgun == true:
		current_weapon = 3
	elif Input.is_action_just_pressed("Railgun") and Globals.railgun == true:
		current_weapon = 6	
	if current_weapon == 1:
		AxelBuster.visible = true
	else:
		AxelBuster.visible = false
	if current_weapon == 6:
		$CollisionShape3D/Head/Camera3D/hand/railgun.visible = true
	else:
		$CollisionShape3D/Head/Camera3D/hand/railgun.visible = false
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
				Globals.pulseammo -= 1
				if $Head/Camera3D/hand/M9PulseRifleHR/RayCast3D.is_colliding():
					var b = pulseball.instantiate()
					$Head/Camera3D/hand/M9PulseRifleHR/muzzle.add_child(b)
					b.look_at($Head/Camera3D/hand/M9PulseRifleHR/RayCast3D.get_collision_point(), Vector3.UP)
					b.shoot = true
					

				$muzzletimer.start(0.1)
				$Head/Camera3D/hand/M9PulseRifleHR/muzzleflash.show()
				$Head/Camera3D/hand/M9PulseRifleHR/m9_timer.start()
				pulsesound.play(0.001)
				anim_player.play("M9Fire")
				M9_fire = false
	if Input.is_action_pressed("fire") and Globals.upgrade == true:
		if current_weapon == 1:
			Globals.upgradeShotNum += 1
			$Healthbar2/s/Console.add_text(" " + str(Globals.upgradeShotNum))
			if Globals.upgradeShotNum > 2500:
				Globals.upgrade = false
			if raycast.is_colliding():
				var target = raycast.get_collider()
				if target.is_in_group("enemy"):
					target.enemyhealth -= 5
				if target.is_in_group("Chaospawn"):
					Chaospawnhurt.play(0.001)
				if target.is_in_group("fiend"):
					$fiendhurt.play()
			$muzzletimer.start(0.1)
			$CollisionShape3D/Head/Camera3D/hand/Buster/muzzleflash.show()
			$firesound.play(0.001)
			anim_player.play("KBusterFire", -1, 100)
	if Input.is_action_just_pressed("fire") and Globals.upgrade == false:
		if current_weapon == 1:
			burstnum = 0
			if raycast.is_colliding():
				var target = raycast.get_collider()
				if target.is_in_group("enemy"):
					target.enemyhealth -= damage
				if target.is_in_group("Chaospawn"):
					Chaospawnhurt.play(0.001)
				if target.is_in_group("fiend"):
					$fiendhurt.play()
			$muzzletimer.start(0.1)
			$CollisionShape3D/Head/Camera3D/hand/Buster/muzzleflash.show()
			while soundnum == 0:
				$firesound.play(0.001)
				soundnum = 1
			anim_player.play("KBusterFire")
			$CollisionShape3D/Head/Camera3D/hand/Buster/burstTimer.start()
func _ready():
	randomize()
	get_tree().paused = false
	#for r in ray_container.get_children():
		#r.cast_to.x = rand_range(spread, -spread)
		#r.cast_to.y = rand_range(spread, -spread)
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)			
func dash(delta):
	if is_on_ceiling():
		anim_player.play("Slide")
		duck = true
	if not is_on_ceiling() and duck == true and not Input.is_action_pressed("dash"):
		duck = false
		anim_player.play("RESET")
	if Input.is_action_just_released("dash") and highjump != true:
		anim_player.play("RESET")
		duck = false
	if Input.is_action_just_pressed("dash") and is_on_floor():
		dashing = true
		$Healthbar2/s/Console.add_text(" Slide Thrusters Activated ")
		text_timer.start()
		dashnum = 0 
		duck = true
		anim_player.play("Slide")
		while dashnum != 100 and speed != 100 and not is_on_wall() and in_air == false:
			speed += 0.1
			dashing = true
			in_air = false
			dashnum += 1
			diving = true
			#_Camera.fov = lerp(_Camera.fov, fview["DASH"], ADS_LERP * delta)
			$dash.play()
			set_velocity(movement)
			# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
			set_up_direction(Vector3.UP)
			move_and_slide()
		if is_on_floor():
			in_air = false
			if Input.is_action_just_pressed("jump"):
					speed = 100
					in_air = true
					set_velocity(movement)
					# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
					set_up_direction(Vector3.UP)
					move_and_slide()
		if not is_on_floor():
			speed = 70
		if in_air == false and dashnum == 200:
			dashnum = 0
			speed = 70
			diving = false
			in_air = false
			dashing = false
func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	
func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if (Globals.filter == false):
		$filterblock.hide()
	if (Globals.filter == true):
		$filterblock.show()
	if(Input.is_action_just_pressed("escape") and Input.MOUSE_MODE_CAPTURED):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("fire2"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
		camera.set_as_top_level(true)
		camera.global_transform.origin = camera.global_transform.origin.lerp(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_top_level(false)
		camera.global_transform = head.global_transform
func _physics_process(delta):
	#get keyboard input
	if Globals.shells < 0:
		Globals.shells = 0
	if freeze != true:
		if death != true:
			fire()
			weapon_select()
			fire_shotgun()
			dash(delta)
		if health != 100:
			$Healthbar/s/ProgressBar.value = health
		if health == 100:
			$Healthbar/s/ProgressBar.value = health
		if Input.is_action_just_pressed("abort"):
			emit_signal("death")
			death = true
		if health == 0 or health == -2 or health == -3 or health == -4 or health == -4 or health == -4 or health ==-5 or health == -6 or health == -7 or health == -8 or health == -9 or health == -10 or health < -1:
			emit_signal("death")
			death = true
			health = -1
		if current_weapon != 1:
			$Healthbar2/s/Ammocounter/Ammonum.text = str(Globals.currammo)
		else:
			$Healthbar2/s/Ammocounter/Ammonum.text = "∞"
		#movement below
		direction = Vector3.ZERO
		var h_rot = global_transform.basis.get_euler().y
		var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
		if h_input and dashing != true:
			if not Input.is_action_pressed("fire") and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
				anim_player.queue("Weaponsway")
		elif h_input and f_input and dashing != true:
			if not Input.is_action_pressed("fire") and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
				anim_player.queue("Weaponsway")
		elif f_input and not h_input and dashing != true and highjump != true:
			speed = 70
			if not Input.is_action_pressed("fire") and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
				anim_player.queue("Weaponsway")
		elif dashing != true and highjump != true:
			speed = 70
			if not Input.is_action_pressed("fire") and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
				anim_player.stop()
		#jumping and gravity
		if Input.is_action_pressed("move_right"):
			camera.rotation.z = -0.1
			leanRight = true
		elif Input.is_action_pressed("move_left"):
			camera.rotation.z = 0.1
			leanLeft = true
		if not Input.is_action_pressed("move_right") and leanRight == true:
			camera.rotation.z = 0
			leanRight = false
		elif not Input.is_action_pressed("move_left") and leanLeft == true:
			camera.rotation.z = 0
			leanLeft = false
		if is_on_floor():
			snap = -get_floor_normal()
			accel = ACCEL_DEFAULT
			dashing = false
			jumping = false
			gravity_direction = Vector3.ZERO
		elif is_on_wall():
			accel = ACCEL_DEFAULT
		else:
			snap = Vector3.DOWN
			accel = ACCEL_AIR
			gravity_direction += Vector3.DOWN * gravity * delta
		if is_on_floor() and Input.is_action_just_pressed("action2"):
			diving = true
			snap = Vector3.ZERO
			jumping = true
			gravity_direction += Vector3.UP * jump * 3
			speed = 0
			$HighJumpSound.play(0.001)
			highjump = true
			$Healthbar2/s/Console.add_text(" High Jump Activated ")
			text_timer.start()
		if highjump == true:
			if Input.is_action_just_pressed("dash"):
				dashing = true
				$Healthbar2/s/Console.add_text(" Dash Out of High Jump Activated ")
				text_timer.start()
				dashnum = 0
				in_air = true
				snap = Vector3.DOWN
				highjump = false
				while dashnum != 100 and speed != 100 and not is_on_wall() and in_air == true:
					speed += 0.1
					dashing = true
					in_air = false
					dashnum += 1
					_Camera.fov = lerp(_Camera.fov, fview["DASH"], ADS_LERP * delta)
					$dash.play()
					set_velocity(movement)
					# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
					set_up_direction(Vector3.DOWN)
					move_and_slide()
				if is_on_floor():
					in_air = false
					if Input.is_action_just_pressed("jump"):
						speed = 70
						in_air = true
						set_velocity(movement)
						# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
						set_up_direction(Vector3.DOWN)
						move_and_slide()
				if not is_on_floor():
					if not is_on_wall():
						speed = 70
						set_velocity(movement)
						# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
						set_up_direction(Vector3.DOWN)
						move_and_slide()
				if in_air == false and dashnum == 200:
					dashnum = 0
					speed = 70
					in_air = false
					dashing = false
		if Input.is_action_just_pressed("jump") and is_on_floor():
			snap = Vector3.ZERO
			jumping = true
			if not speed == 60 and not speed > 60 and dashing != true:
				speed += 10
				jumping = true
			gravity_direction = Vector3.UP * jump
		if Input.is_action_just_pressed("jump") and is_on_wall():
			gravity_direction = Vector3.UP * jump
			if speed != 120 or speed <= 120:
				speed += 10
			rotation.y += 180
			$AudioStreamPlayer3.play()
			jumping = true
		if is_on_floor() and ground == true:
			$AudioStreamPlayer2.play()
			ground = false
			diving = false
			highjump = false
		if not is_on_floor() and Input.is_action_just_pressed("dive"):
			diving = true
			gravity_direction = Vector3.DOWN * jump * 50
			speed == speed*-100000
		if not is_on_floor():
			ground = true
		elif not Input.is_action_just_pressed("jump"):
			snap = Vector3.DOWN
			accel = ACCEL_AIR
			gravity_direction += Vector3.DOWN * gravity * delta
		#make it move
		velocity = velocity.lerp(direction * speed, accel * delta)
		movement = velocity + gravity_direction
		
		set_velocity(movement)
		# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
		set_up_direction(Vector3.UP)
		move_and_slide()

func _on_muzzletimer_timeout():
	soundnum = 0
	$CollisionShape3D/Head/Camera3D/hand/Buster/muzzleflash.hide()
	$CollisionShape3D/Head/Camera3D/hand/shotgun/muzzleflash.hide()
	$CollisionShape3D/Head/Camera3D/hand/Stormcloud/stormflash.hide()
	$CollisionShape3D/Head/Camera3D/hand/railgun/laser/Scaler.hide()
	$CollisionShape3D/Head/Camera3D/hand/M9PulseRifleHR/muzzleflash.hide()

func _on_Deathscreen_reset():
	health = 100

func _on_FPS_death():
	speed = 0

func _on_Area_body_entered(body):
	if body.is_in_group("NPC"):
		body.start_dialog()
	if body.is_in_group("pulse") :
		Globals.Pulse = true
		body.queue_free()
		text_timer.start()
		$ching.play()
		Globals.pulseammo += 100
		$Healthbar2/s/Console.add_text(" Abtained a M9A4 Red Ranger ")
	if body.is_in_group("shotgun") :
		Globals.shotgun = true
		text_timer.start()
		body.queue_free()
		Globals.shells += 12
		$ching.play()
		$Healthbar2/s/Console.add_text(" Abtained a Holy-Land Tek Bethlehem Shotgun ")
	if body.is_in_group("railgunfloor") :
		Globals.railgun = true
		text_timer.start()
		body.queue_free()
		Globals.boltammo += 10
		$ching.play()
		$Healthbar2/s/Console.add_text(" Abtained a Esbjornson Europa Soldier ")
	if body.is_in_group("railgun") :
		Globals.railgun = true
		text_timer.start()
		body.queue_free()
		Globals.boltammo += 10
		$ching.play()
		$Healthbar2/s/Console.add_text(" Abtained a Esbjornson Europa Soldier ")
	if body.is_in_group("stormcloudshotgun") :
		Globals.stormcloudshotgun = true
		body.queue_free()
		Globals.shells += 12
		text_timer.start()
		$ching.play()
		$Healthbar2/s/Console.add_text(" Abtained a Maxfield Stormcloud Shotgun ")
	if body.is_in_group("shell"):
		Globals.shells += 12
		text_timer.start()
		$Healthbar2/s/Console.add_text(" Abtained 12 Shotgun Shells ")
		body.queue_free()
		$clip.play()
	if body.is_in_group("redammo"):
		Globals.pulseammo += 100
		text_timer.start()
		$Healthbar2/s/Console.add_text(" Abtained 12 Shotgun Shells ")
		body.queue_free()
		$clip.play()
	if body.is_in_group("boltammo"):
		Globals.boltammo += 5
		text_timer.start()
		$Healthbar2/s/Console.add_text(" Abtained 5 bolts ")
		body.queue_free()
		$clip.play()
	if body.is_in_group("medbox"):
		health += 25
		text_timer.start()
		$Healthbar2/s/Console.add_text(" Abtained 25 health ")
		body.queue_free()
		$healthup.play()
	if body.is_in_group("level2key"):
		Globals.level2unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level3key"):
		Globals.level3unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level4key"):
		Globals.level4unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level5key"):
		Globals.level5unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level6key"):
		Globals.level6unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level7key"):
		Globals.level7unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level8key"):
		Globals.level8unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level10key"):
		Globals.level10unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level11key"):
		Globals.level11unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level12key"):
		Globals.level12unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("level13key"):
		Globals.level13unlocked = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("enter"):
		enter = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("enter3"):
		enter3 = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Abtained a Isorropian Energy Prism, this completely heals you. ")
		$AudioStreamPlayer.play()
		body.queue_free()
	if body.is_in_group("upgrade"):
		Globals.upgrade = true
		text_timer.start()
		health = 100
		$Healthbar2/s/Console.add_text(" Got the Axel-Buster Upgrade! ")
		$AudioStreamPlayer.play()
		body.queue_free()
func _on_stormtimer_timeout():
	stormfire = true

func _on_text_timer_timeout():
	$Healthbar2/s/Console.clear()
	print("cleared text")

func _on_shotgun_timer_timeout():
	shotgun_fire = true

func _on_m9_timer_timeout():
	M9_fire = true


func _on_Level1_area_entered(area):
	print("entered E1M1")
	get_tree().change_scene_to_file("res://scenes/real_levels/E1M1.tscn")
	$Healthbar2/s/Console.add_text(" Entered Level E1M1 ")



func _on_EndofLevel_area_entered(area):
	if Globals.level2unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M1 ")


func _on_Level2_area_entered(area):
	if Globals.level2unlocked == true:
		print("entered E1M2")
		get_tree().change_scene_to_file("res://scenes/real_levels/E1M2.tscn")
		$Healthbar2/s/Console.add_text(" Entered Level E1M2 ")
	else:
		$Healthbar2/s/Console.add_text(" Sorry, you can't enter E1M2 yet ")

func _on_end_area_entered(area):
	if Globals.level3unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M2 ")


func _on_lava_body_entered(body):
	health = 0




func _on_endit_body_entered(body):
	if Globals.level4unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M3 ")


func _on_level4quit_body_entered(body):
	if Globals.level5unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M5 ")
		
func _on_Area_area_entered(area):
	get_tree().change_scene_to_file("res://scenes/tutorials/tut1.tscn")


func _on_death_area_entered(area):
	health = 0


func _on_railtimer_timeout():
	railgunfire = true



func _on_level5exitarea_area_entered(area):
	if Globals.level6unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M5 ")
	


func _on_bossend_body_entered(body):
	if Globals.level7unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M6 ")


func _on_Ikenga_freeze():
	freeze = !freeze


func _on_kickDamageArea_body_entered(body):
	if diving == true:
		if body.is_in_group("enemy"):
			print("Divekiced enemy")
			body.enemyhealth -= damage * 2
			if body.is_in_group("Chaospawn"):
				Chaospawnhurt.play(0.001)
			if body.is_in_group("fiend"):
				$fiendhurt.play()
			if body.is_in_group("dummy"):
				body.kicked = true


func _on_exitarea3_body_entered(body):
	if Globals.level8unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M8 ")




func _on_burst_timer_timeout():
	shotgun_fire = true


func _on_burstTimer_timeout():
	if current_weapon == 1:
		if burstnum != 5:
			burstnum += 1
			if raycast.is_colliding():
				var target = raycast.get_collider()
				if target.is_in_group("enemy"):
					target.enemyhealth -= damage
				if target.is_in_group("Chaospawn"):
					var rand=RandomNumberGenerator.new()
					var randnum = rand.randi_range(1,3)
					if randnum == 1:
						Chaospawnhurt.play(0.001)
					if randnum == 2:
						$ChaosPawnHurt2.play(0.001)
					if randnum == 3:
						$ChaosPawnHurt2.play(0.001)
				if target.is_in_group("Chaossoldier"):
					var rand=RandomNumberGenerator.new()
					var randnum = rand.randi_range(1,3)
					if randnum == 1:
						$ChaosSoldierHurt.play(0.001)
					if randnum == 2:
						$ChaosSoldierHurt2.play(0.001)
					if randnum == 3:
						$ChaosSoldierHurt3.play(0.001)
				if target.is_in_group("fiend"):
					$fiendhurt.play()
			$muzzletimer.start(0.1) 
			$CollisionShape3D/Head/Camera3D/hand/Buster/muzzleflash.show()
			while soundnum == 0:
				$firesound.play(0.001)
				soundnum = 1
			anim_player.play("KBusterFire", -1, 10)
			$CollisionShape3D/Head/Camera3D/hand/Buster/muzzleflash/firesound.play()
		else:
			$CollisionShape3D/Head/Camera3D/hand/Buster/burstTimer.stop()
	else:
		$CollisionShape3D/Head/Camera3D/hand/Buster/burstTimer.stop()


func _on_enter_body_entered(body):
	if enter == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/E2M2part2.tscn")


func _on_enter2_body_entered(body):
	if Globals.level11unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select2.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E2M2 ")


func _on_Exitlevelsast_body_entered(body):
	if Globals.level12unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select2.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E2M3 ")


func _on_enter4_body_entered(body):
	if enter3 == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/E2M4part2.tscn")


func _on_exitlevel4_body_entered(body):
	if Globals.level13unlocked == true:
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select2.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E2M4 ")


func _on_superccolexcit_body_entered(body):
	if Globals.level10unlocked == true: 
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select2.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E2M1 ")


func _on_Level6exityourmom_body_entered(body):
	if Globals.level14unlocked == true: 
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select2.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E2M6 ")
