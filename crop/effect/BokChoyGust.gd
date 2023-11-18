extends Area2D


func _ready():
	if is_multiplayer_authority():
		$Timer.timeout.connect(queue_free)
		body_entered.connect(handle_enter)


func handle_enter(node: PhysicsBody2D):
	if node is CharacterBody2D:
		node.velocity = 200 * Vector2(0, 1)
	pass


func handle_character_body_enter(node: CharacterBody2D):
	pass
