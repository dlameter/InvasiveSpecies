class_name CropPlot extends Node2D

@export var crop: Crop = null

func _ready():
	set_crop(crop)

func get_crop() -> Crop:
	return crop

func set_crop(new_crop: Crop) -> Crop:
	var old_crop = crop
	
	crop = new_crop
	if new_crop:
		
		
		if crop.get_parent():
			crop.get_parent().remove_child.call_deferred(crop)
		
		crop.position = position
		get_parent().add_child.call_deferred(crop, true)
	
	return old_crop
