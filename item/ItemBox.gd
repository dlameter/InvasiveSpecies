extends Area2D


@export var items: Array[PackedScene]

var taken := false


func _body_enter(body: Node2D):
	if not is_multiplayer_authority():
		return
	
	if not taken and body is Player and body.can_take_item():
		taken = true
		body.add_item(items.pick_random().instantiate())
		
		die.rpc()


@rpc("call_local")
func die():
	if is_multiplayer_authority():
		queue_free()


func _ready():
	set_process(false)
