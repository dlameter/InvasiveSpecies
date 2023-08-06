class_name Crop extends StaticBody2D

enum Stage {
	SEED,
	SPROUT,
	PLANT
}

@export var stage: Stage
@export var growth_time: float = 0.0
@export var sprout_delay: float = 2.0
@export var plant_delay: float = sprout_threshold + 3.0

var sprout_threshold: float
var plant_threshold: float

signal fully_grown(Crop)

@onready var seed_sprite = $SeedSprite
@onready var sprout_sprite = $SproutSprite
@onready var plant_sprite = $PlantSprite 

# Called when the node enters the scene tree for the first time.
func _ready():
	sprout_threshold = sprout_delay
	plant_threshold = sprout_delay + plant_delay
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		return
	
	stage = Stage.SEED
	handle_stage_visuals()

func _process(delta):
	growth_time += delta
	
	if growth_time >= sprout_threshold and stage == Stage.SEED:
		transition_to_sprout()
	if growth_time >= plant_threshold and stage == Stage.SPROUT:
		transition_to_plant()

func transition_to_sprout():
	stage = Stage.SPROUT
	handle_stage_visuals()

func transition_to_plant():
	stage = Stage.PLANT
	handle_stage_visuals()
	emit_signal("fully_grown", self)

func handle_stage_visuals():
	seed_sprite.visible = stage == Stage.SEED
	sprout_sprite.visible = stage == Stage.SPROUT
	plant_sprite.visible = stage == Stage.PLANT

func get_watered(amount: float):
	growth_time += amount
