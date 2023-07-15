extends Node2D

var player_1_id := -1
var player_2_id := -1

@onready var game_menu := %InGameMenu
@onready var disconnect_timer := %DisconnectTimer


@export var winner := -1:
	set(value):
		winner = value
		if winner > 0:
			show_match_end_ui(winner)


func _ready():
	game_menu.hide()
	
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1, true)


func _exit_tree():
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED or not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int, first = false):
	var character = preload("res://player/player.tscn").instantiate()
	character.name = str(id)
	character.player = id
	character.spawn_location = $Players
	if first:
		character.global_position = %Player1Spawn.global_position
		player_1_id = id
	else:
		character.global_position = %Player2Spawn.global_position
		player_2_id = id
	$Players.add_child(character, true)


func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()


func set_winner(winner_player: int):
	var winner_id = player_1_id
	if winner_player != 1:
		winner_id = player_2_id
	
	winner = winner_id


func show_match_end_ui(winner_id: int):
	game_menu.show_match_end_screen(multiplayer.multiplayer_peer.get_unique_id() == winner_id)
	disconnect_timer.start()


func disconnect_from_game():
	AutoloadState.emit_close_server()
