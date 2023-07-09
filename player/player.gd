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

@export var dig_delay = 3 :
	set(value):
		dig_delay = value
		if dig_delay < dig_threshold:
			$DigBar.show()
		else:
			$DigBar.hide()
		
		$DigBar.value = dig_delay

var dig_threshold = 3

@export var current_water := 0.0 :
	set(value):
		current_water = value
		if value <= 0.0:
			$WaterBar.hide()
		else:
			$WaterBar.show()
		
		$WaterBar.value = value

var water_threshold := 6.0
const MAX_WATER := 10.0

func _ready():
	dig_delay = dig_threshold
	current_water = 0
	$WaterBar.max_value = MAX_WATER
	$DigBar.max_value = dig_threshold
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
	dig_delay += delta
	if input.dig_pos != Vector2.ZERO and is_multiplayer_authority():
		var point_query_params := PhysicsPointQueryParameters2D.new()
		point_query_params.collision_mask = dig_collision_mask
		point_query_params.position = input.dig_pos
		point_query_params.collide_with_areas = true
		point_query_params.collide_with_bodies = false
		
		input.clear_dig.rpc()
		
		if dig_delay > dig_threshold:
			var collisions = get_world_2d().direct_space_state.intersect_point(point_query_params)
			for collision in collisions:
				if collision.collider and collision.collider is CropPlot:
					var crop = collision.collider.set_crop(null)
					if crop:
						crop.queue_free()
						dig_delay = 0
	
	current_water = clampf(current_water, 0.0, MAX_WATER)
	if current_water > 0:
		current_water -= delta
	
	move_and_slide()


func get_watered():
	current_water += 1
