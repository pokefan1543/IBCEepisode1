extends Node

var vsync = true
var fullscreen = true
var boomer = true
var current_scene = null
var Pulse = false
var mouse_sense = 0.1
var enemies = 0
var stormcloudshotgun = false
var defeats = 0
var itemCount = 0
var time = 0.0
var railgun = false
var par = 300
var shotgun = false
var pulseammo = 100
var currammo = 0
var bullets = 100
var boltammo = 0
var level = 0
var maxLevel = 10
var maxHealth = 100
var shells = 0
var filter = false
var upgradeShotNum = 0
var upgrade = false
var tutorial = false
var speedMult = 1 
var ammoMult = 1
var damageMult = 1
var xp = 0
var enterLevel = ""
func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
func _physics_process(delta):
	if pulseammo < 0:
		pulseammo = 0
	if boltammo < 0:
		boltammo = 0
	if shells < 0:
		boltammo = 0
	if level == 1:
		maxHealth = 105
	if level == 2:
		speedMult = 1.1
	if level == 3:
		damageMult = 1.5
	if level == 4:
		ammoMult == 1.1
	if level == 5:
		maxHealth = 122.5
	if level == 6:
		maxHealth = 150
	if level == 7:
		speedMult = 1.5
	if level == 8:
		damageMult = 2
	if level == 9:
		ammoMult == 1.5
	if level == 10:
		maxHealth = 300
var level2unlocked = false
var level3unlocked = false
var level4unlocked = false
var level5unlocked = false
var level6unlocked = false
var level7unlocked = false
var level8unlocked = false
var level10unlocked = false
var level11unlocked = false
var level12unlocked = false
var level13unlocked = false
var level14unlocked = false
var level15unlocked = false
var level16unlocked = false
