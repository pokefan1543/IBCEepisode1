extends Node

@export var initial_state : State #Allow the developer to specify an state that Axel-1 has applied automatically upon entering the scene

var current_state: State #Tracks which state is currently active
var states : Dictionary = {} #Records all possible player states in the state machine




func _ready(): 
	for child in get_children():# On startup, scan the scene and make note of all the States in the State Machine
		if child is State:
			states[child.name.to_lower()] = child #add node to states dictionary
			child.Transitioned.connect(on_child_transition) #set up a signal connection for State nodes to trade "active" status on request
	
	if initial_state: #if an initial state is specified by the developer, apply it on startup
		initial_state.Enter()
		current_state = initial_state



# Run the Update() function of whatever state is currently active
func _process(delta):
	if current_state: #Error handling for when current_state is NULL
		current_state.Update(delta)



# Run the Physics_Update() function of whatever state is currently active
func _physics_process(delta): 
	if current_state: #Error handling for when current_state is NULL
		current_state.Physics_Update(delta)



# This function is called by state childrens' scripts via signal when the active state calls to trade its "active" status with another state
func on_child_transition(state, new_state_name):
	if state != current_state: # error handling if the state requesting transition is not the active state in the state machine
		return
	
	var new_state = states.get(new_state_name.to_lower()) #get new state from dictionary
	if !new_state: #error handling if new state not found in dictionary
		return
	
	if current_state: #exit current state
		current_state.Exit()
	
	new_state.Enter() #enter new state
	
	current_state = new_state #record current state as the new state we're entering
