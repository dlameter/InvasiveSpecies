extends Node2D

@export var velocity = Vector2(0,0)
@export var owner_id = 0 # valid ids are the mask layers, so 1-32
@export var lifetime = 10 # life expectancy of the pellet, used with delta
var timelife = 0

@onready var plant = preload("res://crop/dandelion_crop.tscn")

func _ready():
	#set collision mask to ignore owner
	if (owner_id > 0 and owner_id <= 32):
		$Area2D.set_collision_mask_value(owner_id, false)
	
	set_process(is_multiplayer_authority())
	if is_multiplayer_authority():
		$Area2D.connect("area_entered", process_area)


func _process(delta):
	timelife += delta
	if (timelife >= lifetime):
		queue_free()
	
	transform = transform.translated(velocity*delta)
	

func process_area(area: Area2D):
	if area and area is CropPlot:
		var crop_plot: CropPlot = area
		if crop_plot.set_if_empty(plant.instantiate()):
			queue_free()
		

