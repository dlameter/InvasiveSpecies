extends Area2D

@onready var stop_timer := $Timer

var crop_plots: Dictionary
var players: Dictionary


func _ready():
	if not is_multiplayer_authority():
		set_process(false)
		return
	
	stop_timer.timeout.connect(queue_free)
	stop_timer.start()


func _process(delta):
	for crop_plot in crop_plots.keys():
		var crop: Crop = crop_plot.get_crop()
		if crop:
			crop.get_watered()
	
	for player in players.keys():
		player.get_watered()


func _on_area_entered(area):
	if area is CropPlot:
		crop_plot_enter(area)


func _on_area_exited(area):
	if area is CropPlot:
		crop_plot_exit(area)


func _on_body_entered(body):
	if body is Player:
		player_enter(body)


func _on_body_exited(body):
	if body is Player:
		player_exit(body)


func player_enter(player: Player):
	if not players.has(player):
		players[player] = true


func player_exit(player: Player):
	players.erase(player)


func crop_plot_enter(crop_plot: CropPlot):
	if not crop_plots.has(crop_plot):
		crop_plots[crop_plot] = true


func crop_plot_exit(crop_plot: CropPlot):
	crop_plots.erase(crop_plot)
