extends Control


@onready var dig_bar := %DigBar


@export var player: Player:
	set(value):
		player = value
		_hook_in_player(player)


var cursor_sprite: Sprite2D = null


func _hook_in_player(new_player: Player):
	print("_hook_in_player peer ", multiplayer.multiplayer_peer.get_unique_id(), ": got max dig of ", new_player.dig_threshold)
	dig_bar.max_value = new_player.dig_threshold
	player_fire_action_change_handler(new_player.fire_action)
	new_player.fire_action_changed.connect(player_fire_action_change_handler)
	show()


func _process(_delta):
	if player:
		dig_bar.value = player.dig_delay
		
		if cursor_sprite:
			print("mouse tracker: ", get_viewport().get_visible_rect())
			var position_relative_to_camera = player.input.mouse_pos - get_viewport().get_camera_2d().global_position
			var global_to_viewport = (get_viewport().global_canvas_transform * get_viewport().get_camera_2d().get_canvas_transform())
			
			cursor_sprite.global_position = global_to_viewport * player.input.mouse_pos
			print("sprite position: ", cursor_sprite.global_position)


func player_fire_action_change_handler(action_handler: ActionHandler):
	if not action_handler:
		if cursor_sprite:
			cursor_sprite.queue_free()
		cursor_sprite = null
	else:
		if action_handler.cursor_sprite:
			if cursor_sprite:
				cursor_sprite.queue_free()
			cursor_sprite = action_handler.cursor_sprite.duplicate()
			$MouseTracker.add_child(cursor_sprite)
