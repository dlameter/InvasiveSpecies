extends CharacterBody2D

const SPEED = 300.0
var direction: float = 0

@export var water_amount: float = 0.5
@export var velocity_proxy: Vector2 : 
	set(value):
		velocity = value
	get:
		return velocity


func _ready():
	set_direction(0)
	if is_multiplayer_authority():
		$DeathTimer.start()


func set_direction(new_dir: float, initial_velocity: Vector2 = Vector2.ZERO):
	velocity = (Vector2.from_angle(new_dir) * SPEED) + initial_velocity


func _physics_process(_delta):
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	
	move_and_slide()
	
	if is_multiplayer_authority():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() and collision.get_collider().has_method("get_watered"):
				collision.get_collider().get_watered(water_amount)
				die()
				break


func die():
	queue_free()
