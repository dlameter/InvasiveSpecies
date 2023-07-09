class_name PlotManager extends Node2D

@export var crop_plot_scene: PackedScene
@export var plot_width: int
@export var plot_height: int
@export var crop_plot_width: int
@export var crop_plot_height: int

signal plot_filled

@onready var crop_plot_destination = $CropPlots

var crop_plots: Array[CropPlot]

# all of these are used as sets
var all_plots: Dictionary
var free_plots: Dictionary
var finished_plots: Dictionary


func _ready():
	if not multiplayer.is_server():
		return
	
	all_plots = {}
	free_plots = {}
	finished_plots = {}
	crop_plots = []
	for i in range(plot_width * plot_height):
		var new_crop_plot = crop_plot_scene.instantiate()
		new_crop_plot.position = Vector2((i % plot_width) * crop_plot_width, (i / plot_width) * crop_plot_height)
		
		crop_plots.append(new_crop_plot)
		all_plots[new_crop_plot] = true
		free_plots[new_crop_plot] = true
		new_crop_plot.connect("crop_fully_grown", register_finished_crop_plot)
		
		crop_plot_destination.add_child(new_crop_plot, true)
		


func get_crop(x: int, y: int) -> Crop:
	if _in_bounds(x, y):
		return crop_plots[_to_plot_index(x, y)].get_crop()
	else:
		return null


func set_crop(x: int, y: int, crop: Crop) -> Crop:
	if _in_bounds(x, y):
		var crop_plot = crop_plots[_to_plot_index(x, y)]
		if crop:
			free_plots.erase(crop_plot)
			finished_plots.erase(crop_plot)
		else:
			free_plots[crop_plot] = true
			finished_plots.erase(crop_plot)
			
		return crop_plot.set_crop(crop)
	else:
		return null


func set_random_free_plot(crop: Crop) -> bool:
	if free_plots.size() == 0:
		return false
	if not crop:
		return true
	
	var crop_plot = free_plots.keys().pick_random()
	free_plots.erase(crop_plot)
	crop_plot.set_crop(crop)
	
	return true


func random_plot() -> CropPlot:
	return crop_plots[randi_range(0, (plot_width * plot_height) - 1)]


func register_finished_crop_plot(crop_plot: CropPlot):
	finished_plots[crop_plot] = true
	if finished_plots.size() == all_plots.size():
		emit_signal("plot_filled")


func _to_plot_index(x: int, y: int) -> int:
	return x * plot_width + y


func _in_bounds(x: int, y: int) -> bool:
	return x > 0 and x < crop_plot_width and y > 0 and y < plot_height
