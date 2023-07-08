extends CharacterBody2D

@export var player := 1 :
	set(id):
		player = id
		$PlayerInput.set_multiplayer_authority(id)

@onready var input = $PlayerInput

var spawn_location: Node:
	set (value):
		spawn_location = value
		$WaterGun.bullet_destination = value

var delay = 0
var threshold = 5

func _ready():
	$Authority.visible = input.is_multiplayer_authority()

func _physics_process(delta):
	if input.mouse_pos:
		$WaterGun.look_at(input.mouse_pos)
	
	if input.firing:
		delay += delta
		if delay >= threshold:
			delay = 0
			$WaterGun.fire()
	else:
		delay = threshold

	if input.direction:
		velocity = input.direction * 500
	else:
		velocity = Vector2()

	move_and_slide()
