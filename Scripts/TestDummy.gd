extends CharacterBody3D
var target = null
var velocity2 = Vector3.ZERO
var speed = 10
var enemyhealth = 50
var startinghealth = 50
var damage = 5
var snap

@onready var gore = preload("res://Scenes/Guts.tscn")
@onready var bullets = preload("res://Scenes/bullets.tscn")
@onready var health = preload("res://Scenes/medicboxsmall.tscn")
@onready var nav = get_parent()
const ACCEL_DEFAULT = 7
var movement = Vector3()
@onready var idle = $idle
@onready var Shootsound = $AudioStreamPlayer
@onready var playerhurtsound = $PLAYERHURT
const TURN_SPEED = 2
var gravity_direction = Vector3()
@onready var eyes = $Eyes
@onready var raycast = $ShootingRayCast
@onready var ALERTSOUND = $ALERTSOUND
@onready var Death = $Chaospawndeath
@onready var scream = $PAWNSCREAM
@onready var accel = ACCEL_DEFAULT
@onready var Timer1 = $Timer
@onready var shootTimer = $shootTimer
@onready var touch = $Touch
@onready var agent : NavigationAgent3D = $NavigationAgent3D
var direction
var collider = null
var is_avoiding = false
var shoot2 = false
var shoot = false
var gravity = 100
var threshold = .1
var dead = false
var death = false
var kicked = false
var enemy = self
var enemy_following = false
var up_vector3 = Vector3(0, 1, 0)
var shootime = 0
var pain1 = false

func pain():
	$PAWNHURT.play()
	
func _physics_process(delta):
	remove_from_group("map")
	if pain1 == true:
		$PAWNHURT.play()
		pain1 = false
		pain1 = false
		
func _process(delta):
	if enemyhealth <= 0 and death == false:
		Death.play()
		death = true 
	if kicked == true and dead == false:
		enemyhealth = 0
		$deathTimer.wait_time = 0.01
		$deathTimer.start()
		kicked = false
		
func _ready():
	Globals.enemies += 1
