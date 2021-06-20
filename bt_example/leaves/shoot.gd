extends BTLeaf

func _tick(agent: Node, _blackboard: Blackboard) -> bool:
	assert("ammo" in agent)
	
	if agent.ammo <= 0:
		print("No ammo!")
		return fail()
	
	await get_tree().create_timer(.4, false).timeout
	agent.ammo -= 1
	
	return succeed()
