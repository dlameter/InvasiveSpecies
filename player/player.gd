class_name Player 
extends CharacterBody2D

@onready var input := $PlayerInput
@onready var water_gun := $WaterGun


@export var player := 1 :
	set(id):
		player = id
		$PlayerInput.set_multiplayer_authority(id)


@export var spawn_location: Node:
	set (value):
		spawn_location = value
		$WaterGun.bullet_destination = value


const SPEED = 350

var delay = 0
var threshold = 0.05


func _ready():
	item_setup()
	dig_setup()
	water_setup()
	plant_setup()

	if input.is_multiplayer_authority():
		$Camera2D.make_current()


func _physics_process(delta):
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	
	if input.mouse_pos:
		water_gun.look_at(input.mouse_pos)
	
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
		if current_item and current_item.has_method("fire") and current_item.fire(input.mouse_pos):
			pass # do nothing
		else:
			# extract firing to watercan object
			delay += delta
			if delay >= threshold:
				delay = 0
				water_gun.fire(self)
	else:
		delay = threshold


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


func dig_setup():
	dig_delay = dig_threshold
	$DigBar.max_value = dig_threshold


func handle_digging(delta: float):
	dig_delay += delta
	if input.dig_pos != Vector2.ZERO and is_multiplayer_authority():
		if current_plant:
			handle_throw_plant()
			input.clear_dig.rpc()
			return
		
		var point_query_params := PhysicsPointQueryParameters2D.new()
		point_query_params.collision_mask = dig_collision_mask
		point_query_params.position = input.dig_pos
		point_query_params.collide_with_areas = true
		point_query_params.collide_with_bodies = false
		
		input.clear_dig.rpc()
		
		if dig_delay > dig_threshold:
			var collisions = get_world_2d().direct_space_state.intersect_point(point_query_params)
			for collision in collisions:
				if collision.collider and collision.collider is CropPlot:
					var crop = collision.collider.set_crop(null)
					if crop:
						crop.queue_free()
						dig_delay = 0


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
			plant_item.throw(self, (global_position - input.mouse_pos).normalized())


func handle_block_plant():
	if current_plant and is_multiplayer_authority():
		var plant_item = current_plant
		# perhaps this should just tell the plant item when blocking has been started and when it has ended
		if plant_item is CropItem:
			plant_item.block(self, self)


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
