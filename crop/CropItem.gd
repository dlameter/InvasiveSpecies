class_name CropItem extends Node2D


# returns an item created to be thrown
func throw(_dir: Vector2) -> Node2D:
	print('throwing crop item')
	return null


# returns true if the block was handled by the weed item
func block(_node: Node) -> bool:
	return false


func rip_up(_player: Player):
	pass
