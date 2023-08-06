extends Item


enum ItemState {
	INACTIVE,
	SELECTING_AREA,
	DONE
}


@export var rain_cloud_scene: PackedScene

var player: Player = null

@export var state = ItemState.INACTIVE:
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


func _ready():
	hide()
	if not is_multiplayer_authority():
		return
	
	state = ItemState.INACTIVE


func activate(activating_player: Player):
	if state == ItemState.INACTIVE:
		player = activating_player
		state = ItemState.SELECTING_AREA


func fire(selected_position: Vector2) -> bool:
	if state == ItemState.SELECTING_AREA:
		var rain_cloud = rain_cloud_scene.instantiate()
		player.spawn_location.add_child(rain_cloud, true)
		rain_cloud.global_position = selected_position
		
		state = ItemState.DONE
		queue_free()
		return true
	return false
