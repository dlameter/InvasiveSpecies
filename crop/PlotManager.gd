extends Node2D

@export var crop_plot_scene: PackedScene
@export var plot_width: int
@export var plot_height: int
@export var crop_plot_width: int
@export var crop_plot_height: int

@onready var crop_plot_destination = $CropPlots

var crop_plots: Array[CropPlot]

func _ready():
	if not is_multiplayer_authority():
		return
	
	crop_plots = []
	for i in range(plot_width * plot_height):
		var new_crop_plot = crop_plot_scene.instantiate()
		new_crop_plot.global_position = global_position + Vector2((i % plot_width) * crop_plot_width, (i / plot_width) * crop_plot_height)
		crop_plots.append(new_crop_plot)
		crop_plot_destination.add_child(new_crop_plot, true)

func get_plot(x: int, y: int) -> CropPlot:
	if _in_bounds(x, y):
		return crop_plots[_to_plot_index(x, y)]
	else:
		return null

func random_plot() -> CropPlot:
	return crop_plots[randi_range(0, plot_width * plot_height)]

func _to_plot_index(x: int, y: int) -> int:
	return x * plot_width + y

func _in_bounds(x: int, y: int) -> bool:
	return x > 0 and x < crop_plot_width and y > 0 and y < plot_height
