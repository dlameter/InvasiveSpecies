class_name CropPlot extends Node2D

@export var crop: Crop = null

signal crop_fully_grown(CropPlot)

func _ready():
	set_crop(crop)

func get_crop() -> Crop:
	return crop

func set_crop(new_crop: Crop) -> Crop:
	var old_crop = crop
	if old_crop:
		old_crop.disconnect("fully_grown", propogate_fully_grown)
	
	crop = new_crop
	if crop:
		if crop.get_parent():
			crop.get_parent().remove_child.call_deferred(crop)
		
		crop.position = position
		get_parent().add_child.call_deferred(crop, true)
		crop.connect("fully_grown", propogate_fully_grown)
	
	return old_crop

func propogate_fully_grown(_crop: Crop):
	emit_signal("crop_fully_grown", self)
