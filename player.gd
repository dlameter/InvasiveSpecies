extends CharacterBody2D

@export var player := 1 :
	set(id):
		player = id
		$PlayerInput.set_multiplayer_authority(id)

@onready var input = $PlayerInput

@export var spawn_location: Node:
	set (value):
		spawn_location = value
		$WaterGun.bullet_destination = value

const SPEED = 350

var delay = 0
var threshold = 0.05

func _ready():
	$Authority.visible = input.is_multiplayer_authority()
	if input.is_multiplayer_authority():
		$Camera2D.make_current()

func _physics_process(delta):
	if input.mouse_pos:
		$WaterGun.look_at(input.mouse_pos)
	
	if input.firing and is_multiplayer_authority():
		# extract firing to watercan object
		delay += delta
		if delay >= threshold:
			delay = 0
			$WaterGun.fire()
	else:
		delay = threshold

	if input.direction:
		velocity = input.direction * SPEED
	else:
		velocity = Vector2()

	move_and_slide()
