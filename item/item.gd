class_name Item extends Node

var player: Player = null


func _init(new_player: Player):
	player = new_player


func activate():
	if not is_multiplayer_authority():
		return
	
	# hook into player to change state to transplanting
	player.item = null
	player.spawn_location.add_child(self)
	player.state = TransplantingPlayerState.new()
	
	# set timer for 10 seconds, once complete change player state back and delete self
	var timer := Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_reset_player)
	timer.start(10)
	
	add_child(timer)


func _reset_player():
	player.state = PlayerState.new()
	queue_free()
