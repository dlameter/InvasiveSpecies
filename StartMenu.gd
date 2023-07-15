extends Control


signal start_server(int)
signal join_server(String, int)

@onready var win_label = %YouWon
@onready var lose_label = %YouLost


func _ready():
	%HostButton.connect("pressed", emit_start_server)
	%JoinButton.connect("pressed", emit_join_server)


func emit_start_server():
	emit_signal("start_server", int(%HostPort.text))


func emit_join_server():
	emit_signal("join_server", %JoinAddress.text, int(%JoinPort.text))


func hide_all():
	hide()


func show_main_menu():
	show_state(%Menu.name)


func show_end_screen(winner: bool):
	show_state(%EndScreen.name)
	win_label.visible = winner
	lose_label.visible = !winner


func show_state(state_name: String):
	for child in get_children():
		child.hide()
	
	get_node(state_name).show()
	show()
