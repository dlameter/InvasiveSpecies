@tool
extends Node2D


@export var radius: float = 1.0:
	set(value):
		radius = value
		if Engine.is_editor_hint():
			queue_redraw()


@export var point_count: int = 120


func _draw():
	draw_arc(Vector2.ZERO, radius, 0, TAU, point_count, Color.RED)
