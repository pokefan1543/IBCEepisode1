extends Control

var imageNum = 0
@onready var KleoFinal = preload("res://assets/AmazingArt/KleoFinal.png")
@onready var KleoOriginal  = preload("res://assets/AmazingArt/KleoDrawing.jpg")
@onready var KleoSprite = preload("res://assets/sprites/Kleopatra.png")
@onready var KleoSprite1 = preload("res://assets/sprites/KleopatraOld.png")
@onready var Options = preload("res://music/Options.wav")
@onready var Title = preload("res://music/Title.wav")
@onready var E1M1 = preload("res://music/E1M1.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	$OptionButton.add_item("Title Song", 1)
	$OptionButton.add_item("Options Song", 0)
	$OptionButton.add_item("E1M1", 2)
func _physics_process(delta):
	$Number.text = str(imageNum)
	$OptionButton.text = str($OptionButton.selected)
	if imageNum == 1:
		$ImageTitle.text = "Kleopatra's Design (Final)"
		$Author.text = "By: Claire Houser"
		$TextureRect.scale.x = 0.5
		$TextureRect.scale.y = 0.5
		$TextureRect.texture = KleoFinal
	if imageNum == 0:
		$ImageTitle.text = "Kleopatra's Design (Original)"
		$Author.text = "By: Noah Lanier"
		$TextureRect.scale.x = 0.179
		$TextureRect.scale.y = 0.179
		$TextureRect.texture = KleoOriginal
	if imageNum == 2:
		$ImageTitle.text = "Kleopatra's Sprite2D (Original)"
		$Author.text = "By: Claire Houser"
		$TextureRect.scale.x = 0.43
		$TextureRect.scale.y = 0.43
		$TextureRect.texture = KleoSprite1
	if imageNum == 3:
		$ImageTitle.text = "Kleopatra's Sprite2D (Final)"
		$Author.text = "By: Claire Houser"
		$TextureRect.scale.x = 0.5
		$TextureRect.scale.y = 0.5
		$TextureRect.texture = KleoSprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button2_button_down():
	if imageNum != 3:
		imageNum += 1
	$sound.play()


func _on_Button3_button_down():
	if imageNum != 0:
		imageNum -= 1
	$sound.play()


func _on_Quit_button_down():
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")


func _on_Button4_button_down():
	$AudioStreamPlayer.play()
	if $OptionButton.selected == 1:
		$AudioStreamPlayer.stream = Title
	if $OptionButton.selected == 0:
		$AudioStreamPlayer.stream = Options
	if $OptionButton.selected == 2:
		$AudioStreamPlayer.stream = E1M1

func _on_Button5_button_down():
	$AudioStreamPlayer.stop()
	if $OptionButton.selected == 1:
		$AudioStreamPlayer.stream = Title
	if $OptionButton.selected == 0:
		$AudioStreamPlayer.stream = Options
	if $OptionButton.selected == 2:
		$AudioStreamPlayer.stream = E1M1


func _on_Codex_button_down():
	$StartingCodexes/Codex.start_dialog()


func _on_Codex7_button_down():
	$E1M2Codexes/Codex7.start_dialog()


func _on_Codex8_button_down():
	$E1M2Codexes/Codex8.start_dialog()


func _on_Codex9_button_down():
	$E1M2Codexes/Codex9.start_dialog()


func _on_Codex2_button_down():
	$StartingCodexes/Codex2.start_dialog()


func _on_Codex3_button_down():
	$StartingCodexes/Codex3.start_dialog()


func _on_Codex4_button_down():
	$E1M1Codexes/Codex4.start_dialog()


func _on_Codex5_button_down():
	$E1M1Codexes/Codex5.start_dialog()


func _on_Codex6_button_down():
	$E1M1Codexes/Codex6.start_dialog()
