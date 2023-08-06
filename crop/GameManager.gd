extends Node

@export var player1_plot_manager: PlotManager
@export var player2_plot_manager: PlotManager

signal game_won(int)

var crops: Array = [
	{ "probability": 0.11, "crop": preload("res://crop/item_crop.tscn") },
	{ "probability": 0.545, "crop": preload("res://crop/dandelion_crop_stop.tscn") },
	{ "probability": 1.0, "crop": preload("res://crop/crop.tscn") }
]

var winner := -1

func _ready():
	if not get_multiplayer_authority() == multiplayer.get_unique_id():
		return
	
	$PlantTimer.start()
	if player1_plot_manager:
		player1_plot_manager.connect("plot_filled", declare_winner.bind(2))
	if player2_plot_manager:
		player2_plot_manager.connect("plot_filled", declare_winner.bind(1))


func plant():
	var roll = randf_range(0.0, 1.0)
	var crop_template = null
	for prob in crops:
		if prob["probability"] >= roll:
			crop_template = prob["crop"]
			break
	
	if player1_plot_manager:
		plant_in_plot(crop_template.instantiate(), player1_plot_manager)
	if player2_plot_manager:
		plant_in_plot(crop_template.instantiate(), player2_plot_manager)


func plant_in_plot(crop: Crop, plot: PlotManager):
	plot.set_random_free_plot(crop)


func declare_winner(winner_id: int):
	if winner > 0:
		return
	winner = winner_id
	emit_signal("game_won", winner_id)
