extends Crop


func _ready():
	sprout_delay = 10
	plant_delay = 10
	
	if is_multiplayer_authority():
		fully_grown.connect(spawn_itembox)
	
	super._ready()


func spawn_itembox(_garbage):
	var itembox = load("res://item/ItemBox.tscn").instantiate()
	add_child(itembox, true)
	itembox.position = Vector2.ZERO
