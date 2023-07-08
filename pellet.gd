extends Node2D

@export var velocity = Vector2(0,0)
@export var owner_id = 0 # valid ids are the mask layers, so 1-32
@export var lifetime = 10 # life expectancy of the pellet, used with delta
var timelife = 0

func _ready():
	#set collision mask to ignore owner
	if (owner_id > 0 and owner_id <= 32):
		$Area2D.set_collision_mask_value(owner_id, false)


func _process(delta):
	timelife += delta
	if (timelife >= lifetime):
		queue_free()
	
	transform = transform.translated(velocity*delta)
	
