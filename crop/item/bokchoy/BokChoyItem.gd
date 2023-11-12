extends CropItem

func throw(_player: Player, _dir: Vector2):
	queue_free()


func hold(_player: Player):
	queue_free()


func let_go():
	queue_free()
