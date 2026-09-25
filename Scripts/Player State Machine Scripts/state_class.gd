extends Node
class_name State

signal Transitioned # Connected to the on_child_transition function in StateMachine.gd

# blank functions common to all states; these are overwritten with state-specific commands in each individual state's script
func Enter(): # Called when the state first becomes active
	pass

func Exit(): # Called as the state becomes inactive
	pass

func Update(_delta: float): # Standard update function called every frame
	pass

func Physics_Update(_delta : float): # Standard physics update function called every physics frame
	pass
