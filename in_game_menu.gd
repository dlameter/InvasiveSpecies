extends Control


@onready var match_end_screen := %MatchEndScreen
@onready var win_label = %YouWon
@onready var lose_label = %YouLost


func hide_all():
	for child in get_children():
		child.hide()


func show_match_end_screen(winner: bool):
	_show_state(match_end_screen.name)
	win_label.visible = winner
	lose_label.visible = !winner


func show_player_ui(player: Player):
	var player_text = "missing"
	if player:
		player_text = player.name
	print("show_player_ui: got ", player_text, " on peer ", multiplayer.multiplayer_peer.get_unique_id())
	$PlayerUI.player = player
	show()


func _show_state(state_name: String):
	get_node(state_name).show()
	show()
