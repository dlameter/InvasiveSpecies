extends Node

signal game_won_by(int)

func game_won(winner_id: int):
	emit_signal("game_won_by", winner_id)
