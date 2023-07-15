extends Node


var upnp: UPNP

@onready var start_menu := %StartMenu
@onready var level := %Level
@onready var disconnect_timer = $DisconnectTimer


func _ready():
	upnp = UPNP.new()
	upnp.discover()

	# gets public IP of current computer, disabling for internet safety
	# %DisplayPublicIP.text = " " + upnp.query_external_address()
	
	AutoloadState.connect("game_won_by", game_end)
	start_menu.connect("start_server", _on_host_button_pressed)
	start_menu.connect("join_server", _on_join_button_pressed)
	start_menu.show_main_menu()


# Server
func _on_host_button_pressed(host_port: int):
	# Port mapping for online multiplayer
	var result = upnp.add_port_mapping(host_port)
	if result != UPNP.UPNP_RESULT_SUCCESS:
		print("Failed to expose port ", host_port, " through UPNP")
	
	# Start server
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(host_port, 1)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server")
		return
	
	multiplayer.multiplayer_peer = peer
	start_lobby()


# Client
func _on_join_button_pressed(address: String, port: int):
	# Connect client
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(start_lobby)
	multiplayer.server_disconnected.connect(server_offline)


func start_lobby():
	start_menu.hide_all()
	if multiplayer.is_server():
		AutoloadState.connect("lobby_full", start_game)
		AutoloadState.connect("close_server", disconnect_multiplayer)
		change_level.call_deferred(load("res://lobby.tscn"))


func start_game():
	start_menu.hide_all()
	
	if AutoloadState.is_connected("lobby_full", start_game):
		AutoloadState.disconnect("lobby_full", start_game)
	
	if AutoloadState.is_connected("close_server", disconnect_multiplayer):
		AutoloadState.disconnect("close_server", disconnect_multiplayer)
	
	if multiplayer.is_server():
		change_level.call_deferred(load("res://levels/level.tscn"))


func change_level(scene: PackedScene):
	# Remove old level if any.
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	
	# Add new level.
	level.add_child(scene.instantiate())


func call_rpc_game_end(winner_id: int):
	game_end.rpc(winner_id)


func game_end(winner_id: int):
	start_menu.show_end_screen(multiplayer.get_unique_id() == winner_id)
	disconnect_timer.start()


func disconnect_multiplayer():
	call_deferred("disconnect_multiplayer_actual")


func disconnect_multiplayer_actual():
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		server_offline()
		if multiplayer.is_server():
			for peer in multiplayer.get_peers():
				multiplayer.multiplayer_peer.disconnect_peer(peer)
			multiplayer.multiplayer_peer.close()


func server_offline():
	if multiplayer.connected_to_server.is_connected(start_lobby):
		multiplayer.connected_to_server.disconnect(start_lobby)
	if multiplayer.server_disconnected.is_connected(server_offline):
		multiplayer.server_disconnected.disconnect(server_offline)
	if AutoloadState.is_connected("lobby_full", start_game):
		AutoloadState.disconnect("lobby_full", start_game)
	if AutoloadState.is_connected("close_server", disconnect_multiplayer):
		AutoloadState.disconnect("close_server", disconnect_multiplayer)
	
	start_menu.show_main_menu()
	if level.get_child_count() > 0:
		level.get_child(0).free()
