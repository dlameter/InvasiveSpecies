extends Crop


func _ready():
	sprout_delay = 10
	plant_delay = 10
	fully_grown.connect(spawn_itembox)
	super._ready()


func spawn_itembox():
	var itembox = load("res://item/ItemBox.tscn").instantiate()
	get_parent().add_child(itembox)
	itembox.position = position
