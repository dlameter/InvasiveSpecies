extends Node

signal close_server
signal change_level(PackedScene)


func emit_close_server():
	emit_signal("close_server")


func emit_change_level(new_level: PackedScene):
	emit_signal("change_level", new_level)
