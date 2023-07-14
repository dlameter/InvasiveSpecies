extends Control


signal start_server(int)
signal join_server(String, int)

func _ready():
	# host signals
	%HostButton.connect("pressed", emit_start_server)
	
	# join signals
	%JoinButton.connect("pressed", emit_join_server)

func emit_start_server():
	emit_signal("start_server", int(%HostPort.text))

func emit_join_server():
	emit_signal("join_server", %JoinAddress.text, int(%JoinPort.text))
