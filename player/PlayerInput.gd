extends MultiplayerSynchronizer

@export var mouse_pos := Vector2.ZERO
@export var direction := Vector2.ZERO
@export var firing := false
@export var dig_pos := Vector2.ZERO
@export var use_item := false

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(_delta):
	mouse_pos = get_parent().get_global_mouse_position()
	direction = Input.get_vector("left", "right", "up", "down")
	firing = Input.is_action_pressed("fire")
	use_item = Input.is_action_pressed("use_item")
	
	if Input.is_action_pressed("dig"):
		dig_pos = get_parent().get_global_mouse_position()
	elif dig_pos != Vector2.ZERO:
		dig_pos = Vector2.ZERO

@rpc("any_peer", "call_local", "reliable")
func clear_dig():
	if multiplayer.get_remote_sender_id() == 1:
		dig_pos = Vector2.ZERO
