extends Node

signal game_won_by(int)
signal lobby_full
signal close_server
signal change_level(PackedScene)

func game_won(winner_id: int):
	emit_signal("game_won_by", winner_id)

func lobby_is_full():
	emit_signal("lobby_full")

func emit_close_server():
	emit_signal("close_server")

func emit_change_level(new_level: PackedScene):
	emit_signal("change_level", new_level)
