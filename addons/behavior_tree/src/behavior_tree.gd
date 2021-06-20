class_name BehaviorTree, "res://addons/behavior_tree/icons/bt.svg" 
extends Node

# This is your main node. Put one of these at the root of the scene and start adding BTNodes.
# A Behavior Tree only accepts ONE entry point (so one child), for example a BTSequence or a BTSelector.

@export var is_active: bool = false
@export var _blackboard: NodePath
@export var _agent: NodePath
@export_enum("Idle", "Physics") var sync_mode: int
@export var debug: bool = false

var tick_result

@onready var agent = get_node(_agent) as Node
@onready var blackboard = get_node(_blackboard) as Blackboard
@onready var bt_root = get_child(0) as BTNode



func _ready() -> void:
	assert(get_child_count() == 1, "A Behavior Tree can only have one entry point.")
	bt_root.propagate_call("connect", ["tree_aborted", Callable(self, "abort")])
	start()


func _process(delta: float) -> void:
	if not is_active:
		set_process(false)
		return
	
	if debug:
		print()
	
	set_process(false)
	tick_result = await bt_root.tick(agent, blackboard)
	set_process(true)
	


func _physics_process(delta: float) -> void:
	if not is_active:
		set_physics_process(false)
		return
	
	if debug:
		print()
	
	set_process(false)
	tick_result = await bt_root.tick(agent, blackboard)
	set_process(true)


func start() -> void:
	if not is_active:
		return
	
	match sync_mode:
		0:
			set_physics_process(false)
			set_process(true)
		1:
			set_process(false)
			set_physics_process(true)


func abort() -> void:
	is_active = false
