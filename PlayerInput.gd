extends MultiplayerSynchronizer

@export var mouse_pos := Vector2()
@export var direction := Vector2()
@export var firing := false

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(delta):
	mouse_pos = get_viewport().get_mouse_position()
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	firing = Input.is_action_pressed("fire")
