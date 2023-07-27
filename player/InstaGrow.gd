@tool
class_name InstaGrow extends Node2D

var player: Player = null

@export var enabled = true

@export var physics_shape: Shape2D:
	set(value):
		if Engine.is_editor_hint() and physics_shape:
			physics_shape.changed.disconnect(queue_redraw)
		physics_shape = value
		if Engine.is_editor_hint() and physics_shape:
			physics_shape.changed.connect(queue_redraw)

@export_flags_2d_physics var collision_mask = 0b1
@export var mouse_sprite: Sprite2D = null


func _draw():
	if Engine.is_editor_hint() and physics_shape:
		physics_shape.draw(self.get_canvas_item(), Color.RED)


func _exit_tree():
	if player and player.fire_handler == select_area:
		player.fire_handler = Callable()


func activate(activating_player: Player):
	player = activating_player
	activating_player.fire_handler = select_area
	mouse_sprite = $MouseSprite
	enabled = false


func select_area(selected_position: Vector2):
	player.fire_handler = Callable()
	var shape_transform := Transform2D(player.global_transform)
	shape_transform.origin = selected_position
	
	var physics_query = PhysicsShapeQueryParameters2D.new()
	physics_query.shape = physics_shape
	physics_query.collision_mask = collision_mask
	physics_query.transform = shape_transform
	physics_query.collide_with_areas = true
	physics_query.collide_with_bodies = false
	
	# todo change to grow instead of removal
	var collisions := player.get_world_2d().direct_space_state.intersect_shape(physics_query)
	for collision in collisions:
		if collision.collider and collision.collider is CropPlot:
			var crop = collision.collider.set_crop(null)
			if crop:
				crop.queue_free()
				player.dig_delay = 0
	
	queue_free()
