class_name BTRepeat, "res://addons/behavior_tree/icons/btrepeat.svg"
extends BTDecorator

# Executes child "iterations" times and returns the last state and tick result
 
@export_range(0, 999) var times_to_repeat: int = 1
@export var frequency: float



func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result
	
	for i in times_to_repeat:
		result = await bt_child.tick(agent, blackboard)
	
		await get_tree().create_timer(frequency, false).timeout
	
	return set_state(bt_child.state)
