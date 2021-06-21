class_name BTAlways, "res://addons/behavior_tree/icons/btalways.svg"
extends BTDecorator

# Executes the child and always either succeeds or fails.

@export_enum("Fail", "Succeed") var always_what: int = 0

@onready var return_func: String = "fail" if always_what == 0 else "succeed"



func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result = await bt_child.tick(agent, blackboard)
	
	return call(return_func)
	
# Should this be implicit?
func _ready():
	super._ready()
