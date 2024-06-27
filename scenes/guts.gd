extends RigidBody

var SPEED = 30
var random = RandomNumberGenerator.new()
var number = random.randi_range(0, 2)
var forward_dir = null
var numbanumber = number * random.randi_range(2, 12 )
# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	$Timer.start()
	random.randomize()
	$gut.play()
	numbanumber = number * random.randi_range(2, 12)
	number = random.randi_range(0, 2)
	if number == 0:
		forward_dir = global_transform.basis.z * numbanumber
	elif number == 1:
		forward_dir = global_transform.basis.y * numbanumber
	elif number == 2:
		forward_dir = global_transform.basis.x * numbanumber
func _physics_process(delta):
	global_translate(forward_dir * SPEED * delta)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free()
