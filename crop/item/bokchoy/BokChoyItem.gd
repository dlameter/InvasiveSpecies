extends CropItem

const gust: PackedScene = preload("res://crop/effect/BokChoyGust.tscn")

func throw(player: Player, dir: Vector2):
	var gust_but_actually = gust.instantiate()
	player.spawn_location.add_child(gust_but_actually, true)
	gust_but_actually.position = global_position
	gust_but_actually.global_rotation = dir.angle()


func hold(_player: Player):
	queue_free()


func let_go():
	queue_free()
