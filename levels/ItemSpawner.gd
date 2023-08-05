extends Node2D


@export var thing: PackedScene
@export var delay: float = 10


@onready var spawn_slot := $SpawnSlot
@onready var timer := $Timer


func _ready():
	set_process(false)
	if not is_multiplayer_authority():
		return
	
	timer.timeout.connect(_spawn_thing)
	spawn_slot.child_exiting_tree.connect(_start_timer_adapter)
	
	if spawn_slot.get_child_count() < 1:
		_spawn_thing()
	else:
		_start_timer()


func _spawn_thing():
	print("spawning")
	var instance = thing.instantiate()
	spawn_slot.add_child(instance, true)


func _start_timer_adapter(_garbage):
	_start_timer()


func _start_timer():
	timer.start(delay)
