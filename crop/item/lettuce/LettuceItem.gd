class_name LettuceItem extends CropItem

@export var water := preload("res://player/water.tscn")

@onready var item_sprite := $Sprite2D
@onready var block_location: Node2D = $BlockingLocation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const projectile: PackedScene = preload("res://player/water.tscn")

var attached_player: Player = null
@export var delay: float = 0.0
var threshold = 0.05


func _ready():
	state = InternalState.IDLE
	set_physics_process(is_multiplayer_authority())


func _physics_process(delta):
	if state == InternalState.HELD && attached_player && attached_player.input.mouse_pos:
		look_at(attached_player.input.mouse_pos)
		delay += delta
		if delay >= threshold:
			delay = 0
			fire(attached_player)
	elif rotation != 0:
		rotation = 0


func fire(player: CharacterBody2D):
	var instance = water.instantiate()
	instance.global_position = block_location.global_position
	instance.add_collision_exception_with(player)
	player.get_parent().add_child(instance, true)
	instance.set_direction(global_rotation, player.velocity)
	animation_player.play("squeezing")


func throw(player: Player, _dir: Vector2):
	print('throwing crop item')
	if is_multiplayer_authority():
		var instance = projectile.instantiate()
		instance.add_collision_exception_with(player)
		var direction: Vector2 = player.input.mouse_pos - player.global_position
		instance.global_position = global_position
		instance.water_amount *= 10
		player.spawn_location.add_child(instance, true)
		instance.set_direction(direction.angle(), player.velocity)
		queue_free()


func hold(player: Player):
	print("start holding plant")
	state = InternalState.HELD
	attached_player = player


func let_go():
	print("let go of plant")
	state = InternalState.IDLE
	attached_player = null


enum InternalState {
	IDLE,
	HELD
}
@export var state: InternalState = InternalState.IDLE:
	set (value):
		print("prev ", state, " new ", value)
		if state != value:
			handle_state_change(value)
		state = value


func handle_state_change(new_state: InternalState):
	match new_state:
		InternalState.HELD:
			item_sprite.position = block_location.position
		InternalState.IDLE:
			item_sprite.position = Vector2.ZERO


# perhaps firing while holding a plant does a bash?
func bash(_player: Player):
	pass
