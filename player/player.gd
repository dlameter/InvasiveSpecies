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
	
	handle_firing(self, delta)
	handle_movement(self, delta)
	handle_use_item(self)
	
	# TODO: probably need a limit on distance :)
	handle_digging(self, delta)
	
	current_water = clampf(current_water, 0.0, MAX_WATER)
	if current_water > 0:
		current_water -= delta
	
	move_and_slide()


func handle_movement(player: Player, _delta: float):
	if player.input.direction:
		var speed_modifier = player.SPEED
		if player.current_water >= player.water_threshold:
			speed_modifier = speed_modifier * 0.33
		
		player.velocity = player.input.direction * speed_modifier
	else:
		player.velocity = Vector2()


func handle_firing(player: Player, delta: float):
	if player.input.firing and player.is_multiplayer_authority():
		if player.current_item and player.current_item.has_method("fire") and player.current_item.fire(player.input.mouse_pos):
			pass # do nothing
		else:
			# extract firing to watercan object
			player.delay += delta
			if player.delay >= player.threshold:
				player.delay = 0
				player.water_gun.fire(player)
	else:
		player.delay = player.threshold


func handle_digging(player: Player, delta: float):
	player.dig_delay += delta
	if player.input.dig_pos != Vector2.ZERO and player.is_multiplayer_authority():
		var point_query_params := PhysicsPointQueryParameters2D.new()
		point_query_params.collision_mask = player.dig_collision_mask
		point_query_params.position = player.input.dig_pos
		point_query_params.collide_with_areas = true
		point_query_params.collide_with_bodies = false
		
		player.input.clear_dig.rpc()
		
		if player.dig_delay > player.dig_threshold:
			var collisions = player.get_world_2d().direct_space_state.intersect_point(point_query_params)
			for collision in collisions:
				if collision.collider and collision.collider is CropPlot:
					var crop = collision.collider.set_crop(null)
					if crop:
						crop.queue_free()
						player.dig_delay = 0


func handle_use_item(player: Player):
	if player.input.use_item and player.items.get_child_count() > 0 and player.is_multiplayer_authority():
		print("use up item")
		var item = player.items.get_child(0)
		if item and item is InstaGrow:
			if item.enabled:
				item.activate(player)


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
