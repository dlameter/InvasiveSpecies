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

@export var starting_item: PackedScene

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
	
	if is_multiplayer_authority() and starting_item:
		items.add_child(starting_item.instantiate(), true)
	
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


func handle_digging(delta: float):
	dig_delay += delta
	if input.dig_pos != Vector2.ZERO and is_multiplayer_authority():
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


func handle_use_item():
	if input.use_item and items.get_child_count() > 0 and is_multiplayer_authority():
		print("use up item")
		var item = items.get_child(0)
		if item and item is InstaGrow:
			if item.enabled:
				item.activate(self)


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
