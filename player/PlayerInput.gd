extends MultiplayerSynchronizer

@export var mouse_pos := Vector2.ZERO
@export var direction := Vector2.ZERO
@export var firing := false
@export var dig_pos := Vector2.ZERO

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(_delta):
	mouse_pos = get_parent().get_global_mouse_position()
	direction = Input.get_vector("left", "right", "up", "down")
	firing = Input.is_action_pressed("fire")
	if Input.is_action_just_pressed("dig"):
		dig_pos = get_parent().get_global_mouse_position()
