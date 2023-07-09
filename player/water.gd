extends CharacterBody2D

const SPEED = 300.0
var direction: float = 0

@export var velocity_proxy: Vector2 : 
	set(value):
		velocity = value
	get:
		return velocity

func _ready():
	set_direction(0)

func set_direction(new_dir: float, initial_velocity: Vector2 = Vector2.ZERO):
	velocity = (Vector2.from_angle(new_dir) * SPEED) + initial_velocity

func _physics_process(delta):
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() and collision.get_collider().has_method("get_watered"):
			collision.get_collider().get_watered()
			die()
			break

func die():
	queue_free()
