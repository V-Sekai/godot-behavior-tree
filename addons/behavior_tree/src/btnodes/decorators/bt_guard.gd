class_name BTGuard, "res://addons/behavior_tree/icons/btguard.svg"
extends BTDecorator

# Can lock the whole branch below itself. The lock happens either after the child ticks, 
# or after any other BTNode ticks. Then it stays locked for a given time, or until another
# specified BTNode ticks. You can set all this from the inspector.
# If you don't specify a locker, the lock_if variable will be based on the child.
# If you don't specify an unlocker, the unlock_if variable is useless and only the lock_time will 
# be considered, and viceversa.
# You can also choose to lock permanently or to lock on startup.
#
# A locked BTGuard will always return fail().

@export var start_locked: bool = false
@export var permanent: bool = false
@export var _locker: NodePath
@export_enum("Failure", "Success", "Always") var lock_if: int
@export var _unlocker: NodePath
@export_enum("Failure", "Success") var unlock_if: int
@export var lock_time: float = 0.05

var locked: bool = false

@onready var unlocker: BTNode = get_node_or_null(_unlocker)
@onready var locker: BTNode = get_node_or_null(_locker)



func _ready():
	super._ready()
	
	if start_locked:
		await lock()
	
	if locker:
		locker.connect("tick_done", Callable(self, "_on_locker_tick"))


func _on_locker_tick(_result):
	await check_lock(locker)
	set_state(locker.state)

func _unlocker_tick_done(_result) -> bool:
	unlocker.disconnect("tick_done", Callable(self, "_unlocker_tick_done"))
	return bool(_result)

func lock():
	locked = true
	
	if debug:
		print(str(name) + " locked for " + str(lock_time) + " seconds")
	
	if permanent:
		return
	elif unlocker:
		while locked:
			var result: Variant = await unlocker.tick_done
			if result == bool(unlock_if):
				locked = false
	else:
		await get_tree().create_timer(lock_time, false).timeout
		locked = false
	
	if debug:
		print(str(name) + " unlocked")


func check_lock(current_locker: BTNode):
	if ((lock_if == 2 and not current_locker.running()) 
	or ( lock_if == 1 and current_locker.succeeded()) 
	or ( lock_if == 0 and current_locker.failed())):
		await lock()


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if locked:
		return fail()
	return await super._tick(agent, blackboard)


func _post_tick(agent: Node, blackboard: Blackboard, result: bool) -> void:
	if not locker:
		await check_lock(bt_child)


