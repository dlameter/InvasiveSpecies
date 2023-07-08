# TODO: Handle Pellet Collisions
extends CropMatrixEntry

var puff = preload("res://dandelion_puff.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _hitByPellet():
	if stage == Stage.PLANT || true:
		for i in range(randi() % 3 + 2):
			var puffButActually = puff.instantiate()
			puffButActually.velocity = Vector2(randi() % 100 - 50,randi() % 100 - 50)
			puffButActually.lifetime = 2
			#puffButActually.owner_id = null
			puffButActually.global_position = global_position
			get_parent().add_child(puffButActually)
		wilt()
	
# TODO: Crop becomes inactive, but remains occupying spot
func wilt():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_anything_pressed():
		_hitByPellet()
	pass
	

	
