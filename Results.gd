extends Control

var dDisplay = 0
var iDisplay = 0
var tDisplay = 0.0
var lDisplay = 0
var tallyReady = false
var score = 0
var sDisplay = 0
var timerstart = false
var timerstart2 = false
var xp = 0
var Nscore = 0
var click = false

func _ready():
	print("Globals.defeats:")
	print(Globals.defeats)
	print("Globals.enemies")
	print(Globals.enemies)
	print("Globals.itemCount")
	print(Globals.itemCount)
	$Container/ProgressBar.value = Globals.xp
	
func _physics_process(delta):
	$defeatsText3.text = str(Globals.enemies)
	$defeatsText.text = str(dDisplay)
	$itemsText.text = str(iDisplay)
	$timeText.text = str(tDisplay)
	$score2.text = str(sDisplay)
	$Container/Level.text = str(Globals.level)
	$Container/ProgressBar.max_value = Globals.level * 500 + 500
	$Container/nextLevel.text = str(Globals.level + 1)
	if click == true and Input.is_action_just_pressed("fire"):
		Globals.itemCount = 0
		Globals.enemies = 0
		Globals.defeats = 0
		Globals.time = 0
		get_tree().change_scene_to_file("res://scenes/real_levels/level_select.tscn")
	if $Container/ProgressBar.value == $Container/ProgressBar.max_value:
		$Container/ProgressBar.value = 0
		print(Globals.level)
		Globals.level += 1
		if Globals.level == 1:
			$TextEdit.text += "You now have 105 health instead of 100!"
		if Globals.level == 2:
			$TextEdit.text += "You now are 1.1x faster!"
		if Globals.level == 3:
			$TextEdit.text += "You now have a damage multiplier of 1.5x!"
		if Globals.level == 4:
			$TextEdit.text += "You now have a ammo pickup multiplier of 1.1x!"
		if Globals.level == 5:
			$TextEdit.text += "You now have 122.5 health instead of 105!"
		if Globals.level == 6:
			$TextEdit.text += "You now have 150 health instead of 122.5!"
		if Globals.level == 7:
			$TextEdit.text += "You are now 1.5x faster!"
		if Globals.level == 8:
			$TextEdit.text += "You now have a damage multiplier of 2x!"
		if Globals.level == 9:
			$TextEdit.text += "You now have a ammo pickup multiplier of 1.5x!"
		if Globals.level == 10:
			$TextEdit.text += "You now have 300 health instead of 300!"
	if tallyReady == true and score == 0:
		if Globals.time < Globals.par and Globals.time != 0:
			$TextEdit.text += "You beat the par! +500 points! "
			score += 500
		if Globals.defeats == Globals.enemies:
			$TextEdit.text += "You defeated every enemy! +500 points! "
			score += 500
		score += Globals.defeats
		$TextEdit.text += "You have gained "
		$TextEdit.text += str(Globals.defeats)
		$TextEdit.text += " points from defeats. "
		score += Globals.itemCount
		$TextEdit.text += "You have gained "
		$TextEdit.text += str(Globals.itemCount)
		$TextEdit.text += " points from collecting items. "
	$Timer.start()
	if timerstart == true:
		print("timerstart == true")
		$Timer2.start()
		timerstart2 = true
		timerstart = false
		print(timerstart)
func _on_Timer_timeout():
	if click != true:
		if dDisplay != Globals.defeats:
			dDisplay += 1
			$Timer.start()
			$AudioStreamPlayer2.play()
		elif iDisplay != Globals.itemCount:
			iDisplay += 1
			$Timer.start()
			$AudioStreamPlayer3.play()
		elif tDisplay < Globals.time:
			tDisplay += 20
			$Timer.start()
			$AudioStreamPlayer.play()
		elif tallyReady != true and score == 0:
			tallyReady = true
			tDisplay = int(Globals.time)
			$Timer.stop()
		elif sDisplay != score and score != 0:
			tallyReady = false
			sDisplay += 1
			Nscore = score
			$Timer.start()
			$AudioStreamPlayer.play()
			$AudioStreamPlayer.play()
			$AudioStreamPlayer3.play()
		elif Nscore != 0:
			Nscore -= 1
			$AudioStreamPlayer4.play()
			$Container/ProgressBar.value += 1
			Globals.xp = $Container/ProgressBar.value
			$Timer.start()
		elif timerstart == false and timerstart2 == false:
			timerstart = true
			print("timerstart = true")

func _on_Timer2_timeout():
	$Click.show()
	click = true
