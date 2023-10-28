class_name DandelionItem extends CropItem


const projectile: PackedScene = preload("res://projectile/dandelion/DandelionGrenade.tscn")


func throw(player: Player, dir: Vector2):
	if is_multiplayer_authority():
		var instance = projectile.instantiate()
		instance.add_collision_exception_with(player)
		instance.global_position = global_position
		player.spawn_location.add_child(instance, true)
		instance.launch(dir, 700)
		queue_free()


func hold(_player: Player):
	pass


func let_go():
	pass
