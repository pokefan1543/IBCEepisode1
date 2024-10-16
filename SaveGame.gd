class_name SaveGame
extends Reference 

const SAVE_GAME_PATH: = "user://save.json"
const OPTION_SAVE_PATH = "user://settings.json"

var version := 1

var _file := File.new()
var _file2 := File.new()

func save_exists() -> bool:
	return _file.file_exists(SAVE_GAME_PATH)

func write_savesettings() -> void:
	var error := _file2.open(OPTION_SAVE_PATH, File.WRITE)
	if error != OK:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [OPTION_SAVE_PATH, error])
		return
	var data:= {
		"master": Globals.masterS,
		"mouse": Globals.mouse_sense,
		"soundFX": Globals.soundFX,
		"music": Globals.music,	
		"left": Globals.l_key,
		"right": Globals.r_key,
		"backward": Globals.b_key,
		"forward": Globals.f_key,
		"boomer": Globals.boomer,
		"inverted": Globals.inverted,
		"jump": Globals.j_key,
		"dash": Globals.dash_key,
		"dive": Globals.dive_key,
		"vsync": Globals.vsync,	
		"fullscreen": Globals.fullscreen,	
		"filter": Globals.filter,
	}
	var json_string := JSON.print(data)
	_file2.store_string(json_string)
	_file2.close()
	
func write_savegame() -> void:
	var error := _file.open(SAVE_GAME_PATH, File.WRITE)
	if error != OK:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [SAVE_GAME_PATH, error])
		return
	var data:= {
		"level2unlocked": Globals.level2unlocked,
		"level3unlocked": Globals.level3unlocked,
		"level4unlocked": Globals.level4unlocked,
		"level5unlocked": Globals.level5unlocked,	
		"level6unlocked": Globals.level6unlocked,	
		"level7unlocked": Globals.level7unlocked,	
		"level8unlocked": Globals.level8unlocked,
		"legupgrade": Globals.legupgrade,
		"armupgrade": Globals.armupgrade,
		"headupgrade": Globals.headupgrade,
		"bodyupgrade": Globals.bodyupgrade,
		"xp": Globals.xp,
		"stormcloud": Globals.stormcloudshotgun,
		"shotgun": Globals.shotgun,
		"Pulse": Globals.Pulse,
		"level": Globals.level,
		"shells": Globals.shells,
		"bolts": Globals.boltammo,
		"currammo": Globals.currammo,
		"bullets": Globals.bullets,
		"railgun": Globals.railgun, 
		"upgradeShotNum": Globals.upgradeShotNum, 
		"upgrade": Globals.upgrade
	}
	var json_string := JSON.print(data)
	_file.store_string(json_string)
	_file.close()
	 
func load_savegame() -> void:
	var error := _file.open(SAVE_GAME_PATH, File.READ)
	if error != OK:
		printerr("Could not open the file %s. Aborting load operation. Error code %s" % [SAVE_GAME_PATH, error])
		return 
		
	var content := _file.get_as_text()
	_file.close()
	
	var data: Dictionary = JSON.parse(content).result
	Globals.level2unlocked = data.level2unlocked
	Globals.level3unlocked = data.level3unlocked
	Globals.level4unlocked = data.level4unlocked
	Globals.level5unlocked = data.level5unlocked
	Globals.level6unlocked = data.level6unlocked
	Globals.level7unlocked = data.level7unlocked
	Globals.level8unlocked = data.level8unlocked
	Globals.xp = data.xp
	Globals.shotgun = data.shotgun
	Globals.Pulse = data.Pulse
	Globals.railgun = data.railgun
	Globals.stormcloudshotgun = data.stormcloud
	Globals.legupgrade = data.legupgrade
	Globals.armupgrade = data.armupgrade
	Globals.bodyupgrade = data.bodyupgrade
	Globals.headupgrade = data.headupgrade
	Globals.upgrade = data.upgrade
	Globals.shells = data.shells
	Globals.boltammo = data.bolts
	Globals.bullets = data.bullets
	Globals.upgradeShotNum = data.upgradeShotNum
	Globals.currammo = data.currammo

func load_savesettings() -> void:
	var error := _file2.open(OPTION_SAVE_PATH, File.READ)
	if error != OK:
		printerr("Could not open the file %s. Aborting load operation. Error code %s" % [SAVE_GAME_PATH, error])
		return 
		
	var content := _file2.get_as_text()
	_file2.close()
	
	var data: Dictionary = JSON.parse(content).result
	Globals.masterS = data.master
	Globals.fullscreen = data.fullscreen
	Globals.soundFX = data.soundFX
	Globals.dash_key = data.dash
	Globals.dive_key = data.dive
	Globals.l_key = data.left
	Globals.r_key = data.right
	Globals.f_key = data.forward
	Globals.b_key = data.backward
	Globals.music = data.music
	Globals.boomer = data.boomer
	Globals.vsync = data.vsync
	Globals.mouse_sense = data.mouse
	Globals.filter = data.filter 
	Globals.inverted = data.inverted
