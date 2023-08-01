class_name Player extends CharacterBody2D

@onready var input := $PlayerInput
@onready var water_gun := $WaterGun
@onready var items := $Items


@export var player := 1 :
	set(id):
		player = id
		$PlayerInput.set_multiplayer_authority(id)

@export var spawn_location: Node:
	set (value):
		spawn_location = value
		$WaterGun.bullet_destination = value

@export_flags_2d_physics var dig_collision_mask = 0b1

const SPEED = 350

var delay = 0
var threshold = 0.05


var dig_threshold = 4
@export var dig_delay = dig_threshold :
	set(value):
		dig_delay = value
		if dig_delay < dig_threshold:
			$DigBar.show()
		else:
			$DigBar.hide()
		
		$DigBar.value = dig_delay


@export var current_water := 0.0 :
	set(value):
		current_water = value
		if value <= 0.0:
			$WaterBar.hide()
		else:
			$WaterBar.show()
		
		$WaterBar.value = value


var water_threshold := 6.0
const MAX_WATER := 10.0

@export var state := PlayerState.new()


signal current_item_changed(Item)

var current_item: InstaGrow = null:
	set(value):
		current_item = value
		current_item_changed.emit(value)


func _ready():
	if items.get_child_count() > 0 and items.get_child(0) is InstaGrow:
		current_item = items.get_child(0)
	
	items.child_entered_tree.connect(handle_item_added)
	items.child_exiting_tree.connect(handle_item_removed)
	
	if is_multiplayer_authority():
		items.add_child(load("res://insta_grow.tscn").instantiate(), true)
	
	dig_delay = dig_threshold
	current_water = 0
	$WaterBar.max_value = MAX_WATER
	$DigBar.max_value = dig_threshold
	if input.is_multiplayer_authority():
		$Camera2D.make_current()


func _physics_process(delta):
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	
	if input.mouse_pos:
		water_gun.look_at(input.mouse_pos)
	
	# need a switch here based on player mode (change functionality when state is transplanting)
	state.handle_firing(self, delta)
	
	state.handle_movement(self, delta)
	
	# need a switch here to disable if in active item mode (change functionality when state is transplanting)
	state.handle_use_item(self)
	
	# TODO: probably need a limit on distance :)
	# need a switch here based on player mode (change functionality when state is transplanting)
	state.handle_digging(self, delta)
	
	current_water = clampf(current_water, 0.0, MAX_WATER)
	if current_water > 0:
		current_water -= delta
	
	move_and_slide()


func handle_item_added(node: Node):
	if node and node is InstaGrow:
		current_item = node
	else:
		node.queue_free()


func handle_item_removed(node: Node):
	if node and node == current_item:
		current_item = null


func get_watered():
	current_water += 1
