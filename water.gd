extends CharacterBody2D

const SPEED = 300.0
var direction: float = 0

func _ready():
	set_direction(0)

func set_direction(new_dir: float):
	velocity = Vector2.from_angle(new_dir) * SPEED

func _physics_process(delta):
	move_and_slide()
