@tool
extends Node2D


@export var radius: float = 1.0:
	set(value):
		radius = value
		if Engine.is_editor_hint():
			queue_redraw()


@export var color: Color = Color.RED:
	set(value):
		color = value
		if Engine.is_editor_hint():
			queue_redraw()


func _draw():
	draw_circle(Vector2.ZERO, radius, color)
