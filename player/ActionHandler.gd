class_name ActionHandler extends Resource


var ui_icon: Sprite2D
var callable: Callable
var cursor_sprite: Sprite2D = null


func _init(new_ui_icon, new_callable, new_cursor_sprite):
	ui_icon = new_ui_icon
	callable = new_callable
	cursor_sprite = new_cursor_sprite
