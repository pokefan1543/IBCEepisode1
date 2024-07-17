extends KinematicBody

#Variables
var speed = 20
const ACCEL_DEFAULT = 15
const ACCEL_AIR = 25
signal grounded
export (PackedScene) var trail = null
onready var accel = ACCEL_DEFAULT
var shooting = false
var gravity = 15
var dashnum = 0
var diving = false
var ground = true
var death = false
var health = Globals.maxHealth
var M9_fire = true
var counter = 3
var shotgundamage = 10
var spread = 5
var shotgun_fire = true
var stormfire = true
var jump = 12
var dashcooldown = 0
var damage = 25
var jumping = false
var cam_accel = 40
var in_air = false
var dashing = false
var mouse_sense = Globals.mouse_sense
var snap
var soundnum = 0
var upgradeShotNum = 0
var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()
var max_health = Globals.maxHealth
var current_weapon = 1
var leanRight = false
var leanLeft = false
export var BallSpeed: int = 50
var freeze = false
var Ball = preload("res://scenes/PulseBall.tscn")
var railgunfire = true #boolean if the railgun can fire
const ADS_LERP = 20
var raildamage = 0
var fview = {"Default": 118, "ADS": 50, "ADSSCOPE": 10, "DASH": 138}
#These are the variables to check if the player has the weapons in the game
#--------------------------------------------------------------------------
signal death
signal loading
signal pause
#--------------------------------------------------------------------------
#Onready vars
onready var head = $Head
onready var _Camera = get_viewport().get_camera()
onready var _Viewport = get_viewport().get_size()
onready var camera = $Head/Camera
onready var hand = $Head/Camera/hand
onready var anim_player = $Head/Camera/hand/AnimationPlayer
onready var raycast = $Head/Camera/hand/CrosshairRayCast
onready var Chaospawnhurt = $ChaosPawnHurt
onready var text_timer = $text_timer
onready var coll = $CollisionShape
onready var ray = $Head/Camera/hand/CrosshairRayCast
onready var PulseRifle = $Head/Camera/hand/M9PulseRifleHR
onready var AxelBuster = $Head/Camera/hand/Buster
onready var pulseball = preload("res://scenes/PulseBall.tscn")
onready var tazerball = preload("res://scenes/Tazerball.tscn")
onready var aimcast2 = $Head/Camera/hand/CrosshairRayCast
onready var pulsesound = $Head/Camera/hand/pulsefire
onready var ray_container = $Head/Camera/hand/ShotgunRayContainer
onready var shotgunmodel = $Head/Camera/hand/shotgun
onready var stormcloud = $Head/Camera/hand/Stormcloud
onready var Crosshair = $Head/Camera/hand/CrosshairRayCast
onready var flash = $Head/Camera/hand/Stormcloud/stormflash
onready var stormmuzzle1 = $Head/Camera/hand/muzzlestorm
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
							r.cast_to.x = rand_range(spread, -spread)
							r.cast_to.y = rand_range(spread, -spread)
							if r.is_colliding():
								if r.get_collider().is_in_group("enemy"):
									health += 0.2
									r.get_collider().enemyhealth -= shotgundamage * Globals.damageMult
									if r.get_collider().is_in_group("Chaospawn"):
										Chaospawnhurt.play(0.001)
									if r.get_collider().is_in_group("fiend"):
										$fiendhurt.play()
						if counter == 3 and not Input.is_action_pressed("fire"):
							$Head/Camera/hand/shotgun/shotgun_timer.start()
						$muzzletimer.start(0.1)
						$Head/Camera/hand/shotgun/shotgun.play(0.0001)
						$Head/Camera/hand/shotgun/muzzleflash.show()
						anim_player.play("shotgunfire")
						$Head/Camera/hand/shotgun/shotgun_timer.start()
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
								r.cast_to.x = rand_range(spread, -spread)
								r.cast_to.y = rand_range(spread, -spread)
								if r.is_colliding():
									if r.get_collider().is_in_group("enemy"):
										health += 0.2
										r.get_collider().enemyhealth -= shotgundamage * Globals.damageMult
									if r.get_collider().is_in_group("Chaospawn"):
										Chaospawnhurt.play(0.001)
									if r.get_collider().is_in_group("fiend"):
										$fiendhurt.play()
						$blast.play(0.0001)
						$muzzletimer.start(0.1)
						$Head/Camera/hand/shotgun/muzzleflash.show()
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
									r.cast_to.x = rand_range(spread, -spread)
									r.cast_to.y = rand_range(spread, -spread)
									if r.is_colliding():
										if r.get_collider().is_in_group("enemy"):
											health += 0.2
											r.get_collider().enemyhealth -= shotgundamage * Globals.damageMult
										if r.get_collider().is_in_group("Chaospawn"):
											Chaospawnhurt.play(0.001)
										if r.get_collider().is_in_group("fiend"):
											$fiendhurt.play()
							$blast.play(0.0001)
							$muzzletimer.start(0.1)
							$Head/Camera/hand/shotgun/muzzleflash2.show()
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
									r.cast_to.x = rand_range(spread, -spread)
									r.cast_to.y = rand_range(spread, -spread)
									if r.is_colliding():
										if r.get_collider().is_in_group("enemy"):
											health += 0.2
											r.get_collider().enemyhealth -= shotgundamage * Globals.damageMult
										if r.get_collider().is_in_group("Chaospawn"):
											Chaospawnhurt.play(0.001)
										if r.get_collider().is_in_group("fiend"):
											$fiendhurt.play()
							$blast.play(0.0001)
							$muzzletimer.start(0.1)
							$Head/Camera/hand/shotgun/muzzleflash3.show()
	if Globals.stormcloudshotgun == true:
		if current_weapon == 3:
			if Globals.shells > 0 and stormfire == true:
				if Input.is_action_just_pressed("fire"):
					Globals.shells -= 12
					if aimcast2.is_colliding():
						var t = tazerball.instance()
						stormmuzzle1.add_child(t)
						t.look_at(aimcast2.get_collision_point(), Vector3.UP)
						t.shoot = true
					else:
						var t = tazerball.instance()
						stormmuzzle1.add_child(t)
						t.look_at(-transform.basis.y, Vector3.UP)
						t.shoot = true
					$muzzletimer.start(0.1)
					$Head/Camera/hand/Stormcloud/stormflash.show()
					$Head/Camera/hand/tazerfire.play(0.001)
					stormfire = false
					$Head/Camera/hand/Stormcloud/stormtimer.start()
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
						raildamage == 100
				if Input.is_action_just_released("fire"):
					Globals.boltammo -= 1
					anim_player.stop()
					anim_player.play("Railgunfire")
					shooting = true
					$Head/Camera/hand/railgun/laser/Scaler.show()
					if $Head/Camera/hand/railgun/laser/RayCast.is_colliding():
						#maybe use $Head/Camera/hand/railgun/RayCast instead
						var target = $Head/Camera/hand/railgun/laser/RayCast.get_collider()
						if target.is_in_group("enemy"):
							health += 0.2
							target.enemyhealth -= 500 * Globals.damageMult
						if target.is_in_group("Chaospawn"):
							Chaospawnhurt.play(0.001)
						if target.is_in_group("fiend"):
							$fiendhurt.play()
					$muzzletimer.start(0.1)
					#railgunfire = false\
					raildamage = 0
					$Head/Camera/hand/Buster/muzzleflash.show()
					$Head/Camera/hand/railgun/railtimer.start()
					$Head/Camera/hand/railgun/railgunfire.play(0.001)
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
		Globals.currammo = Globals.bullets
	else:
		AxelBuster.visible = false
	if current_weapon == 6:
		$Head/Camera/hand/railgun.visible = true
	else:
		$Head/Camera/hand/railgun.visible = false
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
					var b = pulseball.instance()
					$Head/Camera/hand/M9PulseRifleHR/muzzle.add_child(b)
					b.look_at(Crosshair.get_collision_point(), Vector3.UP)
					b.shoot = true
				$muzzletimer.start(0.1)
				$Head/Camera/hand/M9PulseRifleHR/muzzleflash.show()
				$Head/Camera/hand/M9PulseRifleHR/m9_timer.start()
				pulsesound.play(0.001)
				anim_player.play("M9Fire")
				M9_fire = false
	if Input.is_action_pressed("fire") and Globals.upgrade == true:
		if current_weapon == 1:
			shooting = true
			Globals.upgradeShotNum += 1
			$Healthbar2/s/Console.add_text(" " + str(Globals.upgradeShotNum))
			if Globals.upgradeShotNum > 2500:
				Globals.upgrade = false
			if raycast.is_colliding():
				var target = raycast.get_collider()
				if target.is_in_group("enemy"):
					health += 0.2
					target.enemyhealth -= 5 * Globals.damageMult
				if target.is_in_group("Chaospawn"):
					Chaospawnhurt.play(0.001)
				if target.is_in_group("fiend"):
					$fiendhurt.play()
			$muzzletimer.start(0.1)
			$Head/Camera/hand/Buster/muzzleflash.show()
			$firesound.play(0.001)
			anim_player.play("XBusterFire")
	if Input.is_action_just_pressed("fire") and Globals.upgrade == false:
		if Globals.bullets != 0:
			if current_weapon == 1:
				shooting = true
				Globals.bullets -= 1
				if raycast.is_colliding():
					var target = raycast.get_collider()
					if target.is_in_group("enemy"):
						health += 0.2
						target.enemyhealth -= damage * Globals.damageMult
					if target.is_in_group("Chaospawn"):
						Chaospawnhurt.play(0.001)
					if target.is_in_group("fiend"):
						$fiendhurt.play()
				$muzzletimer.start(0.1)
				$Head/Camera/hand/Buster/muzzleflash.show()
				while soundnum == 0:
					$firesound.play(0.001)
					soundnum = 1
				anim_player.play("XBusterFire")
func _ready():
	randomize()
	$Head/Camera/hand/Buster/muzzleflash.hide()
	$Head/Camera/hand/railgun/laser/Scaler.hide()
	$Head/Camera/hand/shotgun/muzzleflash.hide()
	$Head/Camera/hand/Stormcloud/stormflash.hide()
	$Head/Camera/hand/M9PulseRifleHR/muzzleflash.hide()
	get_tree().paused = false
	for r in ray_container.get_children():
		r.cast_to.x = rand_range(spread, -spread)
		r.cast_to.y = rand_range(spread, -spread)
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)		
func dash(delta):
	if Input.is_action_just_pressed("dash"):
		dashing = true
		dashnum = 0 
		while dashnum != 150 and speed != 100 and in_air == false and not is_on_wall():
			speed += 0.008
			dashing = true
			in_air = false
			dashnum += 1
			_Camera.fov = lerp(_Camera.fov, fview["DASH"], ADS_LERP * delta)
			$dash.play()
			move_and_slide_with_snap(movement, snap, Vector3.UP)
		if dashnum == 250:
			_Camera.fov = lerp(_Camera.fov, fview["Default"], ADS_LERP * delta)
		if is_on_floor():
			in_air = false
			emit_signal("grounded")
			if Input.is_action_just_pressed("jump"):
					speed = 100
					in_air = true
					move_and_slide_with_snap(movement, snap, Vector3.UP)
		if not is_on_floor():
			if not is_on_wall():
				speed = 100
				move_and_slide_with_snap(movement, snap, Vector3.UP)
		if in_air == false and dashnum == 250:
			dashnum = 0
			speed = 20
			in_air = false
			dashing = false
			
func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
func crosshair():
	if Crosshair.is_colliding():
		var target = Crosshair.get_collider()
		if target.is_in_group("enemy"):
			$Control/EnemyPopUp.popup()
		if target.is_in_group("switch"):
			$Control/SwitchPopUp.popup()
	else:
		$Control/SwitchPopUp.hide()
		$Control/EnemyPopUp.hide()
func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if(Input.is_action_just_pressed("escape") and Input.MOUSE_MODE_CAPTURED):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("fire2"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform

func _physics_process(delta):
	#get keyboard input
	if not Input.is_action_pressed("fire"):
		shooting = false
	if not Input.is_action_just_pressed("fire"):
		shooting = false
	if anim_player.is_playing() == false:
		shooting = false
	if Globals.boomer == true:
		$ColorRect.show()
	else:
		$ColorRect.hide()
	if Globals.shells < 0:
		Globals.shells = 0
	if Globals.bullets < 0:
		Globals.bullets = 0
	if Globals.boltammo < 0:
		Globals.boltammo = 0
	if freeze != true:
		if death != true:
			fire()
			crosshair()
			weapon_select()
			fire_shotgun()
			dash(delta)
		if health != Globals.maxHealth:
			$Healthbar/s/ProgressBar.value = health
		if health == Globals.maxHealth:
			$Healthbar/s/ProgressBar.value = health
		if Input.is_action_just_pressed("abort"):
			emit_signal("death")
			death = true
		if health == 0 or health == -2 or health == -3 or health == -4 or health == -4 or health == -4 or health ==-5 or health == -6 or health == -7 or health == -8 or health == -9 or health == -10 or health < -1:
			emit_signal("death")
			death = true
			health = -1
		if Globals.upgrade != true:
			$Healthbar2/s/Ammocounter/Ammonum.text = str(Globals.currammo)
		else:
			$Healthbar2/s/Ammocounter/Ammonum.text = "∞"
		#movement below
		direction = Vector3.ZERO
		var h_rot = global_transform.basis.get_euler().y
		var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
		if Input.is_action_just_pressed("fire2"):
			anim_player.play("RESET")
		if h_input and dashing != true:
			if not speed == 30 * Globals.speedMult and speed < 30 * Globals.speedMult:
				speed += 10
			#if not Input.is_action_pressed("fire") and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
				#anim_player.queue("Weaponsway")
		elif h_input and f_input and dashing != true:
			if not speed == 30 * Globals.speedMult and speed < 30 * Globals.speedMult:
				speed += 10
			#if not Input.is_action_pressed("fire") and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
		elif f_input and not h_input and dashing != true:
			speed = 20
			#if not Input.is_action_pressed("fire") and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
		elif dashing != true:
			speed = 20
			#if not Input.is_action_pressed("fire") and shooting == false and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
		#jumping and gravity
		if Input.is_action_pressed("move_right") and leanLeft != true and leanRight != true:
			anim_player.play("Lean_Right")
			leanRight = true
		if Input.is_action_pressed("move_left") and leanLeft != true and leanRight != true:
			anim_player.play("Lean_Left")
			leanLeft = true
		if not Input.is_action_pressed("move_left"):
			if not Input.is_action_pressed("move_right") and leanRight == true:
				leanRight = false
		if not Input.is_action_pressed("move_right"):
			if not Input.is_action_pressed("move_left") and leanLeft == true:
				leanLeft = false
		if is_on_floor():
			snap = -get_floor_normal()
			accel = ACCEL_DEFAULT
			dashing = false
			jumping = false
			gravity_vec = Vector3.ZERO
		elif is_on_wall():
			accel = ACCEL_DEFAULT
		else:
			snap = Vector3.DOWN
			accel = ACCEL_AIR
			gravity_vec += Vector3.DOWN * gravity * delta
			
		if Input.is_action_just_pressed("jump") and is_on_floor():
			snap = Vector3.ZERO
			jumping = true
			if not speed == 60 * Globals.speedMult and not speed > 60 * Globals.speedMult and dashing != true:
				speed += 10
				jumping = true
			gravity_vec = Vector3.UP * jump
		if Input.is_action_just_pressed("jump") and is_on_wall():
			gravity_vec = Vector3.UP * jump * 2
			speed == speed*-1
			$AudioStreamPlayer3.play()
			jumping = true
		if is_on_floor() and ground == true:
			$AudioStreamPlayer2.play()
			ground = false
			diving = false
			gravity = 15
		if not is_on_floor() and Input.is_action_just_pressed("dive"):
			diving = true
			gravity_vec = Vector3.DOWN * jump * 50
			speed == speed*-100000
		if not is_on_floor():
			ground = true
		elif not Input.is_action_just_pressed("jump"):
			snap = Vector3.DOWN
			accel = ACCEL_AIR
			gravity_vec += Vector3.DOWN * gravity * delta
		#make it move
		velocity = velocity.linear_interpolate(direction * speed, accel * delta)
		movement = velocity + gravity_vec
		
		move_and_slide_with_snap(movement, snap, Vector3.UP)
		

func _on_muzzletimer_timeout():
	soundnum = 0
	$Head/Camera/hand/Buster/muzzleflash.hide()
	$Head/Camera/hand/shotgun/muzzleflash.hide()
	$Head/Camera/hand/shotgun/muzzleflash2.hide()
	$Head/Camera/hand/shotgun/muzzleflash3.hide()
	$Head/Camera/hand/Stormcloud/stormflash.hide()
	$Head/Camera/hand/railgun/laser/Scaler.hide()
	$Head/Camera/hand/M9PulseRifleHR/muzzleflash.hide()

func _on_Deathscreen_reset():
	health = Globals.maxHealth

func _on_FPS_death():
	speed = 0

func _on_Area_body_entered(body):
	Globals.itemCount += 1
	if body.is_in_group("Tut"):
		print("Tut is detected")
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
		$Healthbar2/s/Console.add_text(" Abtained 25 .50 American Eagle rounds ")
		$clip.play()
	if body.is_in_group("medbox"):
		if health != Globals.maxHealth:
			health += 25
			text_timer.start()
			$Healthbar2/s/Console.add_text(" Abtained 25 health ")
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
	get_tree().change_scene("res://scenes/real_levels/E1M1.tscn")
	$Healthbar2/s/Console.add_text(" Entered Level E1M1 ")



func _on_EndofLevel_area_entered(area):
	if Globals.level2unlocked == true:
		get_tree().change_scene("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M1 ")


func _on_Level2_area_entered(area):
	if Globals.level2unlocked == true:
		print("entered E1M2")
		get_tree().change_scene("res://scenes/real_levels/E1M2.tscn")
		$Healthbar2/s/Console.add_text(" Entered Level E1M2 ")
	else:
		$Healthbar2/s/Console.add_text(" Sorry, you can't enter E1M2 yet ")

func _on_end_area_entered(area):
	if Globals.level3unlocked == true:
		get_tree().change_scene("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M2 ")


func _on_lava_body_entered(body):
	health = 0




func _on_endit_body_entered(body):
	if Globals.level4unlocked == true:
		get_tree().change_scene("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M3 ")


func _on_level4quit_body_entered(body):
	if Globals.level5unlocked == true:
		get_tree().change_scene("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M5 ")
		
func _on_Area_area_entered(area):
	get_tree().change_scene("res://scenes/tutorials/tut1.tscn")


func _on_death_area_entered(area):
	health = 0


func _on_railtimer_timeout():
	railgunfire = true



func _on_level5exitarea_area_entered(area):
	if Globals.level6unlocked == true:
		get_tree().change_scene("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M5 ")
	


func _on_bossend_body_entered(body):
	if Globals.level7unlocked == true:
		get_tree().change_scene("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M6 ")


func _on_Ikenga_freeze():
	freeze = !freeze


func _on_kickDamageArea_body_entered(body):
	if diving == true:
		if body.is_in_group("enemy"):
			print("Divekiced enemy")
			body.enemyhealth -= damage * 2 * Globals.damageMult
			if body.is_in_group("Chaospawn"):
				Chaospawnhurt.play(0.001)
			if body.is_in_group("fiend"):
				$fiendhurt.play()
			if body.is_in_group("dummy"):
				body.kicked = true


func _on_exitarea3_body_entered(body):
	if Globals.level8unlocked == true:
		get_tree().change_scene("res://scenes/Score_Screen.tscn")
		$Healthbar2/s/Console.add_text(" Completed Level E1M8 ")




func _on_burst_timer_timeout():
	shotgun_fire = true


func _on_manihate_area_entered(area):
	get_tree().change_scene("res://scenes/tutorials/tut2.5.tscn")
