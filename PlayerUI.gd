extends Control


@onready var dig_bar := %DigBar


@export var player: Player:
	set(value):
		player = value
		_hook_in_player(player)


func _hook_in_player(new_player: Player):
	print("_hook_in_player peer ", multiplayer.multiplayer_peer.get_unique_id(), ": got max dig of ", new_player.dig_threshold)
	dig_bar.max_value = new_player.dig_threshold
	show()


func _process(_delta):
	if player:
		dig_bar.value = player.dig_delay
