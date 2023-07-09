extends Node2D

func _ready():
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
	if not multiplayer.is_server():
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
	else:
		character.global_position = %Player2Spawn.global_position
	$Players.add_child(character, true)

func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()

func print_winner(winner: int):
	print("winner was: ", winner)
