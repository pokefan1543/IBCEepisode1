extends Node

#total screen variables
var itemCount = 0
var time = 0.0
var par = 300
var defeats = 0
var enemies = 0

#weapon variables
var shotgun = false
var railgun = false
var Pulse = false
var stormcloudshotgun = false

#ammo variables
var pulseammo = 100
var currammo = 0
var bullets = 100
var boltammo = 0
var shells = 0

#option variables
var filter = false
var mouse_sense = 0.03
var inverted = false
var vsync = true
var fullscreen = false
var boomer = true
var masterS = -7
var soundFX = 0.067261
var music = 0

#Keybinding variables
var keyBind = 0
#var f1 = InputEventAction.new()
#f1.set_action("fd")
#var f_key = f2
var b1 = InputEventAction.new()
#var b2 = b1.set_action("bd")
#var b_key = b2
var l1 = InputEventAction.new()
#var l2 = l1.set_action("ld")
#var l_key = l2
var r1 = InputEventAction.new()
#var r2 = r1.set_action("rd") 
var r_key = null
var dive1 = InputEventAction.new()
#var dive2 = dive1.set_action("dived")
var dive_key = null
var dash1 = InputEventAction.new()
#var dash2 = dash1.set_action("dashd")
var dash_key = null
var j1 = InputEventAction.new()
#var j2 = j1.set_action("jd")
var j_key = null

#armor upgrade variables
var legupgrade = false
var upgrade = false
var armupgrade = false
var headupgrade = false
var bodyupgrade = false

#XP, leveling up, and other upgrade variables
var speedMult = 1 
var ammoMult = 1
var damageMult = 1
var xp = 0
var upgradeShotNum = 0
var level = 0
var maxLevel = 10
var maxHealth = 100

#variables to track how much of the game that player has progressed 
var level2unlocked = false
var level3unlocked = false
var level4unlocked = false
var level5unlocked = false
var level6unlocked = false
var level7unlocked = false
var level8unlocked = false

#other variables
var tutorial = false
var enterLevel = ""
var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
func _physics_process(delta):
#If statements to make sure the ammo variables do not go into the negatives
	if pulseammo < 0:
		pulseammo = 0
	if boltammo < 0:
		boltammo = 0
	if shells < 0:
		boltammo = 0
#If statements to add level up upgrades
	if level == 1:
		maxHealth = 105
	if level == 2:
		speedMult = 1.1
	if level == 3:
		damageMult = 1.5
	if level == 4:
		ammoMult = 1.1
	if level == 5:
		maxHealth = 122.5
	if level == 6:
		maxHealth = 150
	if level == 7:
		speedMult = 1.5
	if level == 8:
		damageMult = 2
	if level == 9:
		ammoMult = 1.5
	if level == 10:
		maxHealth = 300
