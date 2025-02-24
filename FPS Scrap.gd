extends CharacterBody3D

var direction = Vector3()
var speed = 20
var dashing = false

func _physics_process(delta):
#movement below
		direction = Vector3.ZERO
		var h_rot = global_transform.basis.get_euler().y
		var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		var mf = Input.is_action_pressed("move_forward")  
		var mb = Input.is_action_pressed("move_backward")
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
		if (mf or mb) and dashing == false:
			if not speed == 30 * Globals.speedMult and speed < 30 * Globals.speedMult:
				speed += 10
			#if not Input.is_action_pressed("fire") and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
				#anim_player.queue("Weaponsway")
		elif h_input and (mf or mb) and dashing == false:
			if not speed == 30 * Globals.speedMult and speed < 30 * Globals.speedMult:
				speed += 10
			#if not Input.is_action_pressed("fire") and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
		elif (mf or mb) and not h_input and dashing == false:
			speed = 20
			#if not Input.is_action_pressed("fire") and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
		elif dashing == false:
			speed = 20
			#if not Input.is_action_pressed("fire") and shooting == false and not Input.is_action_just_released("fire") and not Input.is_action_just_pressed("fire") and not Input.is_action_pressed("fire2") and not Input.is_action_just_released("fire2") and not Input.is_action_just_pressed("fire2"):
		#jumping and gravity
		#if Input.is_action_pressed("move_right") and leanLeft != true and leanRight != true:
			#anim_player.play("Lean_Right")
			#leanRight = true
		#if Input.is_action_pressed("move_left") and leanLeft != true and leanRight != true:
			#anim_player.play("Lean_Left")
			#leanLeft = true
		#if not Input.is_action_pressed("move_left"):
		#	if not Input.is_action_pressed("move_right") and leanRight == true:
				#leanRight = false
		#if not Input.is_action_pressed("move_right"):
		#	if not Input.is_action_pressed("move_left") and leanLeft == true:
		#		leanLeft = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
