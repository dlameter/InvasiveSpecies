class_name CropItem extends Node2D


const projectile: PackedScene = preload("res://player/water.tscn")


# returns an item created to be thrown
func throw(player: Player, _dir: Vector2):
	print('throwing crop item')
	if is_multiplayer_authority():
		var instance = projectile.instantiate()
		instance.add_collision_exception_with(player)
		var direction: Vector2 = player.input.mouse_pos - player.global_position
		instance.global_position = global_position
		instance.water_amount *= 10
		player.spawn_location.add_child(instance, true)
		instance.set_direction(direction.angle(), player.velocity)
		queue_free()

# returns true if the block was handled by the weed item
func block(_player: Player, _node: Node) -> bool:
	return false


func rip_up(_player: Player):
	pass
