extends Area2D


func _ready():
	if is_multiplayer_authority():
		$Timer.timeout.connect(queue_free)
