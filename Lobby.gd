extends Node2D

@export var players := {}

func _ready():
	# We only need to track players on the server.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)

func add_player(id: int):
	players[id] = true
	if players.size() >= 2:
		AutoloadState.emit_change_level(load("res://levels/level.tscn"))

func del_player(id: int):
	players.erase(id)

func close_server():
	AutoloadState.emit_close_server()
