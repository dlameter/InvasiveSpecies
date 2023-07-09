class_name Crop extends Node2D

enum Stage {
	SEED,
	SPROUT,
	PLANT
}

@export var stage: Stage

@onready var seed_sprite = $SeedSprite
@onready var sprout_sprite = $SproutSprite
@onready var plant_sprite = $PlantSprite 

@onready var sprout_timer = $SproutTimer
@onready var plant_timer = $PlantTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	
	stage = Stage.SEED
	handle_stage_visuals()
	sprout_timer.start()

func transition_to_sprout():
	stage = Stage.SPROUT
	handle_stage_visuals()
	plant_timer.start()

func transition_to_plant():
	stage = Stage.PLANT
	handle_stage_visuals()

func handle_stage_visuals():
	seed_sprite.visible = stage == Stage.SEED
	sprout_sprite.visible = stage == Stage.SPROUT
	plant_sprite.visible = stage == Stage.PLANT
