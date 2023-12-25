class_name DandelionItem extends HoldableCropItem


const projectile: PackedScene = preload("res://projectile/dandelion/DandelionGrenade.tscn")
const seed: PackedScene = preload("res://crop/dandelion_puff.tscn")

@onready var image = $Sprite2D

enum State {
	IDLE,
	SHAKING
}

@export var state: State = State.IDLE
@export var seeds_left : float = 0.0
@export var shaking_time : float = 0.0
var shake_free_time : float = 0.7

var shaking_player : Player = null

func _ready():
	seeds_left = 5 + randi() % 4


func _physics_process(delta):
	if state == State.SHAKING:
		rotation = randf()
	elif rotation != 0:
		rotation = 0


func _process(delta):
	if is_multiplayer_authority():
		if seeds_left <= 0:
			queue_free()
		
		if state == State.SHAKING:
			shaking_time += delta
			
			if shaking_time > shake_free_time && seeds_left > 0 && shaking_player != null:
				shaking_time = 0.0
				seeds_left -= 1
				drop_seed(shaking_player, (shaking_player.input.mouse_pos - shaking_player.global_position).normalized())
				
		elif shaking_time != 0.0:
			shaking_time = 0.0


func drop_seed(player: Player, dir: Vector2):
	var puffButActually = seed.instantiate()
	puffButActually.set_axis_velocity(50 * dir)
	puffButActually.lifetime = 2
	player.spawn_location.add_child(puffButActually, true)
	puffButActually.position = global_position


func throw(player: Player, dir: Vector2):
	if is_multiplayer_authority():
		var instance = projectile.instantiate()
		instance.add_collision_exception_with(player)
		instance.global_position = global_position
		player.spawn_location.add_child(instance, true)
		instance.launch(dir, 700)
		queue_free()


func hold(player: Player):
	if is_multiplayer_authority():
		state = State.SHAKING
		shaking_player = player


func let_go():
	if is_multiplayer_authority():
		state = State.IDLE
		shaking_player = null
