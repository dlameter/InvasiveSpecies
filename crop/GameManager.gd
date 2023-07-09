extends Node

@export var plot_managers: Array[PlotManager]

var crops := [
	preload("res://crop/crop.tscn")
]

func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		$PlantTimer.start()

func plant():
	var crop_template = crops.pick_random()
	for plot_manager in plot_managers:
		plant_in_plot(crop_template.instantiate(), plot_manager)

func plant_in_plot(crop: Crop, plot: PlotManager):
	plot.set_random_free_plot(crop)
