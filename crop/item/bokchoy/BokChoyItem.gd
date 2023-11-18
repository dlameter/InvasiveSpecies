extends CropItem

const gust: PackedScene = preload("res://crop/effect/BokChoyGust.tscn")

@onready var gust_location = $GustLocation 

func throw(player: Player, dir: Vector2):
	look_at(player.input.mouse_pos)
	var gust_but_actually = gust.instantiate()
	player.spawn_location.add_child(gust_but_actually, true)
	gust_but_actually.position = gust_location.global_position
	gust_but_actually.point_in(dir)


func hold(_player: Player):
	queue_free()


func let_go():
	queue_free()
