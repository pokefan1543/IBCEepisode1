extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("high", 1)
	add_item("medium", 2)
	add_item("low", 3)

#func _physics_process(delta):
	#if get_selected_id(1):

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
