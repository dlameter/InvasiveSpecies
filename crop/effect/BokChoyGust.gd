extends Area2D


var pointing_direction: Vector2
var gust_power: float = 500


func _enter_tree():
	$AnimationPlayer.play("push")
	if is_multiplayer_authority():
		$Timer.timeout.connect(queue_free)


func _ready():
	if is_multiplayer_authority():
		body_entered.connect(handle_enter)


func point_in(dir: Vector2):
	global_rotation = dir.angle()
	pointing_direction = dir.normalized()


func handle_enter(node: PhysicsBody2D):
	if node is CharacterBody2D:
		node.velocity = 200 * Vector2(0, 1)
	elif node is RigidBody2D:
		node.apply_impulse(pointing_direction * gust_power)


func handle_character_body_enter(node: CharacterBody2D):
	pass
