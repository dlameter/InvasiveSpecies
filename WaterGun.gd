extends Node2D

@export var bullet: PackedScene
var bullet_destination: Node2D

func fire():
	var instance = bullet.instantiate()
	get_parent().get_parent().add_child(instance)
	
	instance.set_direction(global_rotation)
	instance.global_position = $FirePos.global_position
