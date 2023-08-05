extends Control


@onready var dig_bar := %DigBar
@onready var item_icon := %ItemIcon


@export var player: Player:
	set(value):
		player = value
		_hook_in_player(player)

var item: InstaGrow = null
var cursor_sprite: Node2D = null


func _hook_in_player(new_player: Player):
	dig_bar.max_value = new_player.dig_threshold
	player_item_change_handler(new_player.current_item)
	new_player.current_item_changed.connect(player_item_change_handler)
	show()


func _process(_delta):
	if player:
		dig_bar.value = player.dig_delay
		
		if cursor_sprite and get_viewport().get_camera_2d():
			var global_to_viewport = (get_viewport().global_canvas_transform * get_viewport().get_camera_2d().get_canvas_transform())
			cursor_sprite.global_position = global_to_viewport * player.input.mouse_pos


func player_item_change_handler(new_item: InstaGrow):
	if not new_item:
		if item:
			item.changed.disconnect(item_change_handler)
			item = null
		if cursor_sprite:
			cursor_sprite.queue_free()
			cursor_sprite = null
		item_icon.texture = null
	else:
		if item:
			item.changed.disconnect(item_change_handler)
		item = new_item
		item_change_handler()
		item.changed.connect(item_change_handler)


func item_change_handler():
	if item.cursor:
		if cursor_sprite:
			cursor_sprite.queue_free()
		cursor_sprite = item.cursor.duplicate()
		$MouseTracker.add_child(cursor_sprite)
	elif cursor_sprite:
		cursor_sprite.queue_free()
		cursor_sprite = null
	
	if item.icon:
		item_icon.texture = item.icon
	else:
		item_icon.texture = null
