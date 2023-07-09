extends Crop

var puff = preload("res://crop/dandelion_puff.tscn")

func dandyBurst(_unused):
	if not is_multiplayer_authority():
		return;

	for i in range(randi() % 3 + 2):
		var puffButActually = puff.instantiate()
		puffButActually.velocity = Vector2(randi() % 100 - 50,randi() % 100 - 50)
		puffButActually.lifetime = 2
		#puffButActually.owner_id = null
		puffButActually.position = position
		get_parent().add_child(puffButActually, true)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	sprout_delay = 5
	plant_delay = 5
	connect("fully_grown", dandyBurst)
	super._ready()

