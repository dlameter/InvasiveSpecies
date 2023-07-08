extends Node2D

@export var bullet: PackedScene
var bullet_destination: Node2D

func fire():
	var instance = bullet.instantiate()
	instance.global_position = $FirePos.global_position
	get_parent().get_parent().add_child(instance, true)
	instance.set_direction(global_rotation)
