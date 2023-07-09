extends Node

@export var player1_plot_manager: PlotManager
@export var player2_plot_manager: PlotManager

signal game_won(int)

var crops := [
	preload("res://crop/crop.tscn")
]

var winner := -1

func _ready():
	if not get_multiplayer_authority() == multiplayer.get_unique_id():
		return
	
	$PlantTimer.start()
	if player1_plot_manager:
		player1_plot_manager.connect("plot_filled", declare_winner.bind(1))
	if player2_plot_manager:
		player2_plot_manager.connect("plot_filled", declare_winner.bind(2))

func plant():
	var crop_template = crops.pick_random()
	
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
