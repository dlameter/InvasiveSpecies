class_name PlayerState extends Resource


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
		if not player.fire_action:
			# extract firing to watercan object
			player.delay += delta
			if player.delay >= player.threshold:
				player.delay = 0
				player.water_gun.fire(player)
		else:
			player.fire_action.callable.call(player.items.get_child(0), player.input.mouse_pos)
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
