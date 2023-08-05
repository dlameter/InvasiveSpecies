extends Area2D


@export var item: PackedScene


func _body_enter(body: Node2D):
	if not is_multiplayer_authority():
		return
	
	if body is Player and body.can_take_item():
		body.add_item(item.instantiate())
		
		die.rpc()


@rpc("call_local")
func die():
	queue_free()


func _ready():
	set_process(false)
