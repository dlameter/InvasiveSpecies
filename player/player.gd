class_name Player 
extends CharacterBody2D

@onready var input := $PlayerInput


@export var player := 1 :
	set(id):
		player = id
		$PlayerInput.set_multiplayer_authority(id)


@export var spawn_location: Node:
	set (value):
		spawn_location = value


const SPEED = 350


func _ready():
	item_setup()
	dig_setup()
	plant_setup()

	if input.is_multiplayer_authority():
		$Camera2D.make_current()


func _physics_process(delta):
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	
	handle_firing(delta)
	handle_movement(delta)
	handle_use_item()
	
	# TODO: probably need a limit on distance :)
	handle_digging(delta)
	
	current_water = clampf(current_water, 0.0, MAX_WATER)
	if current_water > 0:
		current_water -= delta
	
	move_and_slide()


func handle_movement(_delta: float):
	if input.direction:
		var speed_modifier = SPEED
		if current_water >= water_threshold:
			speed_modifier = speed_modifier * 0.33
		
		velocity = input.direction * speed_modifier
	else:
		velocity = Vector2()


func handle_firing(delta: float):
	if input.firing and is_multiplayer_authority():
		if current_item and current_item.has_method("fire"):
			current_item.fire(input.mouse_pos)


## Dig code


@export_flags_2d_physics var dig_collision_mask = 0b1


var dig_threshold = 4
@export var dig_delay = dig_threshold :
	set(value):
		dig_delay = value
		if dig_delay < dig_threshold:
			$DigBar.show()
		else:
			$DigBar.hide()
		
		$DigBar.value = dig_delay

@export var dig_hold: float = 0.0
@export var dig_hold_threshold: float = 0.5

enum DigState {
	IDLE,
	DIG_PLANT,
	WAIT_FOR_RELEASE,
	HOLD_VS_THROW,
	THROW_PLANT,
	HOLD_PLANT,
	UNHOLD_PLANT
}
@export var current_dig_state: DigState = DigState.IDLE


func dig_state_to_function(state: DigState) -> Callable:
	match state:
		DigState.DIG_PLANT:
			return dig_plant
		DigState.WAIT_FOR_RELEASE:
			return wait_for_release
		DigState.HOLD_VS_THROW:
			return block_vs_throw
		DigState.THROW_PLANT:
			return throw_plant
		DigState.HOLD_PLANT:
			return hold_plant
		DigState.UNHOLD_PLANT:
			return unhold_plant
		_:
			return dig_idle


func dig_setup():
	dig_delay = dig_threshold
	$DigBar.max_value = dig_threshold


var max_event_depth = 10

func handle_digging(delta: float):
	dig_delay += delta
	if !is_multiplayer_authority():
		return
	
	var depth = 0
	while depth < max_event_depth:
		var next_dig_state = dig_state_to_function(current_dig_state).call(delta)
		if next_dig_state == current_dig_state:
			break
		current_dig_state = next_dig_state
		depth += 1


func dig_idle(_delta: float) -> DigState:
	if input.dig_pos != Vector2.ZERO:
		if current_plant:
			return DigState.HOLD_VS_THROW
		elif dig_delay > dig_threshold:
			return DigState.DIG_PLANT
	
	return DigState.IDLE


func dig_plant(delta: float) -> DigState:
	var point_query_params := PhysicsPointQueryParameters2D.new()
	point_query_params.collision_mask = dig_collision_mask
	point_query_params.position = input.dig_pos
	point_query_params.collide_with_areas = true
	point_query_params.collide_with_bodies = false
	
	var collisions = get_world_2d().direct_space_state.intersect_point(point_query_params)
	for collision in collisions:
		if collision.collider and collision.collider is CropPlot:
			var crop = collision.collider.set_crop(null)
			if crop:
				var crop_item = crop.pick()
				if crop_item:
					add_plant(crop_item)
				crop.queue_free()
				dig_delay = 0
	
	return DigState.WAIT_FOR_RELEASE


func wait_for_release(_delta: float) -> DigState:
	if input.dig_pos != Vector2.ZERO:
		return DigState.WAIT_FOR_RELEASE
	return DigState.IDLE


func block_vs_throw(delta: float) -> DigState:
	if input.dig_pos == Vector2.ZERO:
		dig_hold = 0
		return DigState.THROW_PLANT
	elif dig_hold >= dig_hold_threshold:
		dig_hold = 0
		return DigState.HOLD_PLANT
	
	dig_hold += delta
	
	return DigState.HOLD_VS_THROW


func throw_plant(_delta: float) -> DigState:
	handle_throw_plant()
	return DigState.WAIT_FOR_RELEASE


func hold_plant(_delta: float) -> DigState:
	handle_hold_plant()
	return DigState.UNHOLD_PLANT


func unhold_plant(_delta: float) -> DigState:
	if input.dig_pos == Vector2.ZERO:
		handle_let_go_of_plant()
		return DigState.IDLE
	else:
		return DigState.UNHOLD_PLANT


## Item code


@export var starting_item: PackedScene
@onready var items := $Items
signal current_item_changed(Item)


var current_item: Item = null:
	set(value):
		current_item = value
		current_item_changed.emit(value)


func item_setup():
	if items.get_child_count() > 0 and items.get_child(0) is Item:
		current_item = items.get_child(0)
	
	items.child_entered_tree.connect(handle_item_added)
	items.child_exiting_tree.connect(handle_item_removed)
	
	if is_multiplayer_authority() and starting_item:
		items.add_child(starting_item.instantiate(), true)


func handle_use_item():
	if input.use_item and items.get_child_count() > 0 and is_multiplayer_authority():
		var item = items.get_child(0)
		if item and item is Item:
			print("item use")
			if item.enabled:
				print("activating")
				item.activate(self)


func can_take_item():
	return items.get_child_count() < 1


func add_item(node: Item):
	items.add_child(node)


func handle_item_added(node: Node):
	if node and node is Item:
		current_item = node
	else:
		node.queue_free()


func handle_item_removed(node: Node):
	if node and node == current_item:
		current_item = null


## Plant code


@export var starting_plant: PackedScene
@onready var plants := $PlantContainer
signal current_plant_changed(CropItem)


var current_plant: CropItem = null:
	set(value):
		current_plant = value
		current_plant_changed.emit(value)


func plant_setup():
	if plants.get_child_count() > 0 and plants.get_child(0) is Item:
		current_plant = plants.get_child(0)
	
	plants.child_entered_tree.connect(handle_plant_added)
	plants.child_exiting_tree.connect(handle_plant_removed)
	
	if is_multiplayer_authority() and starting_plant:
		plants.add_child(starting_plant.instantiate(), true)


func handle_throw_plant():
	if current_plant and is_multiplayer_authority():
		var plant_item = current_plant
		if plant_item is CropItem:
			plant_item.throw(self, (input.mouse_pos - global_position).normalized())


func handle_hold_plant():
	if is_multiplayer_authority() and current_plant and current_plant is CropItem:
		current_plant.hold(self)


func handle_let_go_of_plant():
	if is_multiplayer_authority() and current_plant and current_plant is CropItem:
		current_plant.let_go()


func can_take_plant():
	return plants.get_child_count() < 1


func add_plant(node: CropItem):
	plants.add_child(node)


func handle_plant_added(node: Node):
	if node and node is CropItem:
		current_plant = node
	else:
		node.queue_free()


func handle_plant_removed(node: Node):
	if node and node == current_plant:
		current_plant.let_go()
		current_plant = null


## Water code


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


func water_setup():
	current_water = 0
	$WaterBar.max_value = MAX_WATER


func get_watered(amount: float):
	current_water += amount
