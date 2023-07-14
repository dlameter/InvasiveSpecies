extends Node


var upnp: UPNP


func _ready():
	upnp = UPNP.new()
	upnp.discover()

	# gets public IP of current computer, disabling for internet safety
	# %DisplayPublicIP.text = " " + upnp.query_external_address()
	
	%EndScreen.hide()
	AutoloadState.connect("game_won_by", game_end)
	%StartMenu.connect("start_server", _on_host_button_pressed)
	%StartMenu.connect("join_server", _on_join_button_pressed)


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
	%Menu.hide()
	%EndScreen.hide()
	if multiplayer.is_server():
		AutoloadState.connect("lobby_full", start_game)
		AutoloadState.connect("close_server", disconnect_multiplayer)
		change_level.call_deferred(load("res://lobby.tscn"))


func start_game():
	%Menu.hide()
	%EndScreen.hide()
	
	if AutoloadState.is_connected("lobby_full", start_game):
		AutoloadState.disconnect("lobby_full", start_game)
	
	if AutoloadState.is_connected("close_server", disconnect_multiplayer):
		AutoloadState.disconnect("close_server", disconnect_multiplayer)
	
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
	%EndScreen.show()
	%YouWon.visible = multiplayer.get_unique_id() == winner_id
	%YouLost.visible = multiplayer.get_unique_id() != winner_id
	$DisconnectTimer.start()


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
	
	%Menu.show()
	%EndScreen.hide()
	if %Level.get_child_count() > 0:
		%Level.get_child(0).free()
