extends Control


@onready var match_end_screen := %MatchEndScreen
@onready var win_label = %YouWon
@onready var lose_label = %YouLost


func show_match_end_screen(winner: bool):
	_show_state(match_end_screen.name)
	win_label.visible = winner
	lose_label.visible = !winner


func _show_state(state_name: String):
	for child in get_children():
		child.hide()
	
	get_node(state_name).show()
	show()
