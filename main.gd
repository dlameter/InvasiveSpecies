extends Node

@export var player : PackedScene
@export var map : PackedScene

# Port mapping for online multiplayer
func _ready():
	var upnp = UPNP.new()
	upnp.discover()
	var result = upnp.add_port_mapping(9999)
	%DisplayPublicIP.text = " " + upnp.query_external_address()
	%EndScreen.hide()
	AutoloadState.connect("game_won_by", game_end)

# Server
func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9999, 1)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server")
		return
	
	multiplayer.multiplayer_peer = peer
	start_game()

# Client
func _on_join_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(%To.text, 9999)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	
	multiplayer.multiplayer_peer = peer
	
	print("joining with id ", multiplayer.get_unique_id())

	multiplayer.connected_to_server.connect(start_game)
	multiplayer.server_disconnected.connect(server_offline)

func start_game():
	%Menu.hide()
	%EndScreen.hide()
	if multiplayer.is_server():
		change_level.call_deferred(load("res://levels/level.tscn"))

func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	
	# Add new level.
	level.add_child(scene.instantiate())

func call_rpc_game_end(winner_id: int):
	game_end.rpc(winner_id)

func game_end(winner_id: int):
	print("got winner id: ", winner_id, " at client: ", multiplayer.get_unique_id())
	%EndScreen.show()
	%YouWon.visible = multiplayer.get_unique_id() == winner_id
	%YouLost.visible = multiplayer.get_unique_id() != winner_id
	$DisconnectTimer.start()

func disconnect_multiplayer():
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		multiplayer.multiplayer_peer.close()
	server_offline()

func server_offline():
	%Menu.show()
	%EndScreen.hide()
	if %Level.get_child(0):
		%Level.get_child(0).queue_free()
