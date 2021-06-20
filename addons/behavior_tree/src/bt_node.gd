class_name BTNode, "res://addons/behavior_tree/icons/btnode.svg" 
extends Node

# Base class from which every node in the behavior tree inherits. 
# You don't usually need to instance this node directly.
# To define your behaviors, use and extend BTLeaf instead.

enum BTNodeState {
	FAILURE,
	SUCCESS,
	RUNNING,
}

# (Optional) Emitted after a tick() call. True is success, false is failure. 
signal tick_done(result)

# Emitted if abort_tree is set to true
signal tree_aborted()

# Turn this off to make the node fail at each tick.
@export var is_active: bool = true 

# Turn this on to print the name of the node at each tick.
@export var debug: bool = false 

# Turn this on to abort the tree after completion.
@export var abort_tree: bool

var state: int:
	set = set_state



func _ready():
	if is_active:
		succeed()
	else:
		push_warning("Deactivated BTNode '" + str(name) + "', path: '" + str(get_path()) + "'")
		fail()


### OVERRIDE THE FOLLOWING FUNCTIONS ###
# You just need to implement them. DON'T CALL THEM MANUALLY.

func _pre_tick(agent: Node, blackboard: Blackboard) -> void:
	pass


# This is where the core behavior goes and where the node state is changed.
# You must return either succeed() or fail() (check below), not just set the state.
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	return succeed()


func _post_tick(agent: Node, blackboard: Blackboard, result: bool) -> void:
	pass

### DO NOT OVERRIDE ANYTHING FROM HERE ON ###



### BEGIN: RETURN VALUES ###

# Your _tick() must return one of the following functions.

# Return this to set the state to success.
func succeed() -> bool:
	state = BTNodeState.SUCCESS
	return true


# Return this to set the state to failure.
func fail() -> bool:
	state = BTNodeState.FAILURE
	return false


# Return this to match the state to another state.
func set_state(rhs: int) -> bool:
	match rhs:
		BTNodeState.SUCCESS:
			state = BTNodeState.SUCCESS
			return true
		BTNodeState.FAILURE:
			state = BTNodeState.FAILURE
			return false
		BTNodeState.RUNNING:
			state = BTNodeState.RUNNING
			return false
	
	assert(false, "Invalid BTNodeState assignment. Can only set to success or failure.")
	return false

### END: RETURN VALUES ###



# Don't call this.
func run():
	state = int(BTNodeState.RUNNING)


# You can use the following to recover the state of the node
func succeeded() -> bool:
	return state == int(BTNodeState.SUCCESS)


func failed() -> bool:
	return state == int(BTNodeState.FAILURE)


func running() -> bool:
	return state == int(BTNodeState.RUNNING)


# Or this, as a string.
func get_state() -> String:
	if succeeded():
		return "success"
	elif failed():
		return "failure"
	else:
		return "running"


# Again, DO NOT override this. 
func tick(agent: Node, blackboard: Blackboard) -> bool:
	if not is_active:
		return fail()
	
	if running():
		return false
	
	if debug:
		print(name)
	
	# Do stuff before core behavior
	_pre_tick(agent, blackboard)
	
	run() 
	
	assert(running(), "BTNode execution was suspended but it's not running. Did you succeed() or fail() before yield?")
	var result = await _tick(agent, blackboard)
	assert(not running(), "BTNode execution was completed but it's still running. Did you forget to return succeed() or fail()?") 
	
	# Do stuff after core behavior depending on the result
	_post_tick(agent, blackboard, result)
	
	# Notify completion and new state (i.e. the result of the execution)
	emit_signal("tick_done", result)
	
	# Queue tree abortion at the end of current tick
	if abort_tree:
		emit_signal("tree_aborted")
	
	return result
