extends Node2D

@export var water := preload("res://player/water.tscn")
var bullet_destination: Node2D

func fire(player: CharacterBody2D):
	var instance = water.instantiate()
	instance.global_position = $FirePos.global_position
	instance.add_collision_exception_with(player)
	get_parent().get_parent().add_child(instance, true)
	instance.set_direction(global_rotation, player.velocity)
