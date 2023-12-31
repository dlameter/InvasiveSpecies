@tool
class_name InstaGrow extends Item

enum ItemState {
	INACTIVE,
	SELECTING_AREA,
	DONE
}

@export_flags_2d_physics var collision_mask = 0b1
@export var max_crops: int
@export var physics_shape: Shape2D:
	set(value):
		if Engine.is_editor_hint() and physics_shape:
			physics_shape.changed.disconnect(queue_redraw)
		physics_shape = value
		if Engine.is_editor_hint() and physics_shape:
			physics_shape.changed.connect(queue_redraw)


@export var state: = ItemState.INACTIVE:
	set(value):
		if value == ItemState.SELECTING_AREA:
			cursor = $MouseSprite
			active = true
			enabled = false
		else:
			active = false
			cursor = null
			enabled = true
		if state != value:
			changed.emit()
		state = value


var player: Player = null


func _draw():
	if Engine.is_editor_hint() and physics_shape:
		physics_shape.draw(self.get_canvas_item(), Color.RED)


func _ready():
	state = ItemState.INACTIVE
	
	if not Engine.is_editor_hint():
		hide()


# handler for use action on the item
func activate(activating_player: Player):
	if state == ItemState.INACTIVE:
		player = activating_player
		state = ItemState.SELECTING_AREA


# returns true if the event should be captured by this handler
func fire(selected_position: Vector2) -> bool:
	if state == ItemState.SELECTING_AREA:
		var shape_transform := Transform2D(player.global_transform)
		shape_transform.origin = selected_position
		
		var physics_query = PhysicsShapeQueryParameters2D.new()
		physics_query.shape = physics_shape
		physics_query.collision_mask = collision_mask
		physics_query.transform = shape_transform
		physics_query.collide_with_areas = true
		physics_query.collide_with_bodies = false
		
		# todo change to grow instead of removal
		var crop_plots: Dictionary = {}
		var collisions := player.get_world_2d().direct_space_state.intersect_shape(physics_query)
		for collision in collisions:
			if collision.collider and collision.collider is CropPlot:
				crop_plots[collision.collider] = true
		
		
		if crop_plots.size() > max_crops:
			var crops_removed = 0;
			while crop_plots.size() > 0 and crops_removed < max_crops:
				var random_plot = crop_plots.keys().pick_random()
				crop_plots.erase(random_plot)
				
				var crop = random_plot.set_crop(null)
				if crop:
					crops_removed += 1
					crop.queue_free()
				
		else:
			for crop_plot in crop_plots.keys():
				var crop = crop_plot.set_crop(null)
				if crop:
					crop.queue_free()
		
		state = ItemState.DONE
		queue_free()
		return true
	return false
