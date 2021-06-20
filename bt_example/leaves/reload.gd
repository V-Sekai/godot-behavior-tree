extends BTLeaf

func _tick(agent: Node, _blackboard: Blackboard) -> bool:
	assert("ammo" in agent)
	
	await get_tree().create_timer(2, false).timeout
	agent.ammo = agent.max_ammo
	return succeed()
