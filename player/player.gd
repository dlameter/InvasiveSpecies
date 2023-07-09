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

@export_flags_2d_physics var dig_collision_mask = 0b1

const SPEED = 350

var delay = 0
var threshold = 0.05

@export var current_water = 0
var water_threshold = 20
const MAX_WATER = 25

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
			$WaterGun.fire(self)
	else:
		delay = threshold

	if input.direction:
		var speed_modifier = SPEED
		if current_water >= water_threshold:
			speed_modifier = speed_modifier * 0.33
		
		velocity = input.direction * speed_modifier
	else:
		velocity = Vector2()
	
	# TODO: probably need a limit on distance :)
	if input.dig_pos != Vector2.ZERO and is_multiplayer_authority():
		var point_query_params := PhysicsPointQueryParameters2D.new()
		point_query_params.collision_mask = dig_collision_mask
		point_query_params.position = input.dig_pos
		point_query_params.collide_with_areas = true
		point_query_params.collide_with_bodies = false
		
		input.dig_pos = Vector2.ZERO
		
		var collisions = get_world_2d().direct_space_state.intersect_point(point_query_params)
		for collision in collisions:
			if collision.collider and collision.collider is CropPlot:
				clear_crop_plot.rpc_id(1, collision.collider)
	
	if current_water > MAX_WATER:
		current_water = MAX_WATER
	current_water -= delta
	move_and_slide()


@rpc("call_local")
func clear_crop_plot(crop_plot: CropPlot):
	var crop = crop_plot.set_crop(null)
	if crop:
		crop.queue_free()


func get_watered():
	current_water += 1
