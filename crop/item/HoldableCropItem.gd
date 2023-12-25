class_name HoldableCropItem
extends CropItem


func throw(_player: Player, _dir: Vector2):
	assert(false, "throw should be implemented in the subclass")


func hold(_player: Player):
	assert(false, "hold should be implemented in the subclass")


func let_go():
	assert(false, "let_go should be implemented in the subclass")


# perhaps firing while holding a plant does a bash?
func bash(_player: Player):
	assert(false, "bash is not implemented")
