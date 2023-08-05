class_name Item
extends Node2D

# signal to emit when an external property has changed on the item
signal changed

# visual value used to show current item
@export var icon: Texture2D = null
# visual value used to show a special cursor on the player's UI
@export var cursor: Node = null
# if true the item should be taking events from the player's regular inputs
@export var active = false
# if true it means that the item can be "use"d
@export var enabled = false


# handler for use action on the item
func activate(activating_player: Player):
	pass


# returns true if the event should be captured by this handler
func fire(selected_position: Vector2) -> bool:
	return false
