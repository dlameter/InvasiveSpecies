extends Area2D


@export var item: PackedScene


func _body_enter(body: Node2D):
	print("item body entered")
	if not is_multiplayer_authority():
		return
	
	print("checking if player can take item: ", body, " is player? ", body is Player, " can take item? ", body.can_take_item() if body is Player else false)
	if body is Player and body.can_take_item():
		print("player taking item")
		body.add_item(item.instantiate())
		
		die.rpc()


@rpc("call_local")
func die():
	queue_free()


func _ready():
	set_process(false)
