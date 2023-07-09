class_name CropPlot extends Node2D

@export var crop: Crop = null

func _ready():
	set_crop(crop)

func get_crop() -> Crop:
	return crop

func set_crop(new_crop: Crop):
	var old_crop = crop
	
	if new_crop:
		crop.global_position = global_position
		add_child(crop, true)
	
	crop = new_crop
	
