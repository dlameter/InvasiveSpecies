class_name CropItem extends Node2D

# Interface functions

func handle_fire(_player: Player, _delta: float, _dir: Vector2):
	assert(false, "handle_fire should be implemented in the subclass")


func handle_dig(_player: Player, _delta: float, _dir: Vector2):
	assert(false, "handle_dig should be implemented in the subclass")


# Internals
var the_player: Player = null


func attach_player(player: Player):
	the_player = player


func dettach_player():
	the_player = null
