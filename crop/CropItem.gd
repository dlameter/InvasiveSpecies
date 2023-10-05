class_name CropItem extends Node


# returns an item created to be thrown
func throw(dir: Vector2) -> Node2D:
	return null


# returns true if the block was handled by the weed item
func block(node: Node) -> bool:
	return false


func rip_up(player: Player):
	pass
