class_name FPSController
extends CharacterBody3D

#Variables
var DashorSlide = true #true == dash; false == slide
var speed := 20
const ACCEL_DEFAULT = 15
const ACCEL_AIR = 25
signal grounded
@export var trail: PackedScene = null
@onready var accel = ACCEL_DEFAULT
var Gunfire = false
var shooting = false
var gravity = 15
var dashnum = false
var dashpress = false
var wish_dir := Vector3.ZERO
var dashingtime = true
var diving = false
var ground = true
var death2 = false
var is_on_map = true 
var health = Globals.maxHealth
var M9_fire = true
var counter = 3
var shotgundamage = 10
var spread = 5
var shotgun_fire = true
var stormfire = true
var jump = 16
var autoBHOP = true
var dashcooldown = 0
var damage = 25
var jumping = false
var cam_accel = 40
var in_air = false
var dashing = false
var mouse_sense : float = Globals.mouse_sense
var snap
var soundnum = 0
var jumpnum = 0
var parry = false
var upgradeShotNum = 0
var max_health = Globals.maxHealth
var current_weapon = 1
var leanRight = false
var leanLeft = false
@export var BallSpeed: int = 50
var freeze = false
var Ball = preload("res://scenes/PulseBall.tscn")
var railgunfire = true #boolean if the railgun can fire
const ADS_LERP = 20
var raildamage = 0
#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
var fview = {"Default": 118, "ADS": 50, "ADSSCOPE": 10, "DASH": 138}
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
@onready var hand = $Head/Camera3D/hand
@onready var anim_player = $Head/Camera3D/hand/AnimationPlayer
@onready var raycast = $Head/Camera3D/hand/CrosshairRayCast
@onready var Chaospawnhurt = $ChaosPawnHurt
@onready var text_timer = $text_timer
@onready var coll = $CollisionShape3D
@onready var ray = $Head/Camera3D/hand/CrosshairRayCast
@onready var PulseRifle = $Head/Camera3D/hand/M9PulseRifleHR
@onready var AxelBuster = $Head/Camera3D/hand/Buster
@onready var pulseball = preload("res://scenes/PulseBall.tscn")
@onready var tazerball = preload("res://scenes/Tazerball.tscn")
@onready var aimcast2 = $Head/Camera3D/hand/CrosshairRayCast
@onready var pulsesound = $Head/Camera3D/hand/pulsefire
@onready var ray_container = $Head/Camera3D/hand/ShotgunRayContainer
@onready var shotgunmodel = $Head/Camera3D/hand/shotgun
@onready var stormcloud = $Head/Camera3D/hand/Stormcloud
@onready var Crosshair = $Head/Camera3D/hand/CrosshairRayCast
@onready var flash = $Head/Camera3D/hand/Stormcloud/stormflash
@onready var stormmuzzle1 = $Head/Camera3D/hand/muzzlestorm
#---------------------------------------------------------------------------
func dash(delta):
	if DashorSlide == true:
		if is_on_floor() == true and not Input.is_action_pressed("dash"):
			dashing = false
			dashnum = false
			dashpress = false
			$dashTimer.stop()
		if Input.is_action_pressed("dash"):
			if dashpress == false and dashingtime == true:
				dashing = true
			if Input.is_action_just_pressed("jump") and is_on_floor() == true:
				dashing = true
				dashingtime = true 
				$dashTimer.start()
		if Input.is_action_just_pressed("dash"):
			dashing = true
			dashingtime = true
			dashpress = true
			$dashTimer.start()
		if is_on_floor() == true and dashing == true:
			speed = 50
			
			move_and_slide()
			# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
			set_up_direction(Vector3.UP)
			move_and_slide()
		if dashingtime == false and is_on_floor():
			dashing = false
		if is_on_floor() == true:
			emit_signal("grounded")
		if dashing == true or dashnum == true:
			if not is_on_wall() and not is_on_floor():
				speed = 50
				# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
				set_up_direction(Vector3.UP)
				move_and_slide()
			#elif is_on_floor() == true and dashing == false and dashnum == true:
				#speed -= 20
				#if speed == 20:
					#dashnum = false
					#dashpress = false
#--------------------------------------------------------------------------------------------------------------------------
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
			if raycast.is_colliding():
				var target = raycast.get_collider()
				if target.is_in_group("enemy"):
					target.enemyhealth -= 5 * Globals.damageMult
				if target.is_in_group("Chaospawn"):
					Chaospawnhurt.play(0.001)
				if target.is_in_group("fiend"):
					$fiendhurt.play()
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
				shooting = true
				Globals.bullets -= 1
				if raycast.is_colliding():
					var target = raycast.get_collider()
					if target.is_in_group("enemy"):
						target.enemyhealth -= damage * Globals.damageMult
					if target.is_in_group("Chaospawn"):
						Chaospawnhurt.play(0.001)
					if target.is_in_group("fiend"):
						$fiendhurt.play()
				$muzzletimer.start(0.1)
				$Head/Camera3D/hand/Buster/muzzleflash.show()
				while soundnum == 0:
					$firesound.play(0.001)
					soundnum = 1
				anim_player.play("XBusterFire")
				
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
#-------------------------------------------------------------------------------
func _ready():
	#randomize()
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("fire"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
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
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouseInput : Vector2
		mouseInput.x += event.relative.x
		mouseInput.y += event.relative.y
		camera.rotation_degrees.y -= mouseInput.x * mouse_sense
		head.rotation_degrees.x -= mouseInput.y * mouse_sense

func controls(delta):
	#get keyboard input
	if Input.is_action_just_pressed("parry"):
		if parry == false:
			$touch/CSGSphere3D.show()
			emit_signal("parry")
			$ParryTimer.start()
			parry = true
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
		if death2 != true:
			fire()
			controls(delta)
			crosshair()
			weapon_select()
			fire_shotgun()
			dash(delta)
		if health != Globals.maxHealth:
			$Healthbar/s/ProgressBar.value = health
			print(health)
		if health == Globals.maxHealth:
			$Healthbar/s/ProgressBar.value = health
		if Input.is_action_just_pressed("abort"):
			emit_signal("death")
			death2 = true
		if health == 0 or health == -2 or health == -3 or health == -4 or health == -4 or health == -4 or health ==-5 or health == -6 or health == -7 or health == -8 or health == -9 or health == -10 or health < -1:
			emit_signal("death")
			death2 = true
			health = -1
		if Globals.upgrade != true:
			$Healthbar2/s/Ammocounter/Ammonum.text = str(Globals.currammo)
		else:
			$Healthbar2/s/Ammocounter/Ammonum.text = str(Globals.currammo)

func _handle_air_physics(delta) -> void:
	self.velocity.y -= gravity * delta
	self.velocity.x = wish_dir.x * speed
	self.velocity.z = wish_dir.z * speed

func _handle_ground_physics(delta) -> void:
	self.velocity.x = wish_dir.x * speed
	self.velocity.z = wish_dir.z * speed 
			
func _physics_process(delta):
	var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
	wish_dir = (self.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			self.velocity.y = jump
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
	if is_on_wall() and Input.is_action_just_pressed("jump", true):
		self.velocity.y = jump
	
	move_and_slide()
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
			body.enemyhealth -= damage * 2 * Globals.damageMult
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
	dashingtime = false


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
		$Healthbar2/s/Console.add_text(" Abtained 25 .50 American Eagle rounds ")
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
