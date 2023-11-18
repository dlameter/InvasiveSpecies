extends RigidBody2D


var puff = preload("res://crop/dandelion_puff.tscn")

func dandyBurst():
	if not is_multiplayer_authority():
		return;

	for i in range(randi() % 6 + 2):
		var puffButActually = puff.instantiate()
		puffButActually.set_axis_velocity(Vector2(randi() % 100 - 50,randi() % 100 - 50))
		puffButActually.lifetime = 2
		puffButActually.position = position
		get_parent().add_child(puffButActually, true)


func _physics_process(delta):
	if is_multiplayer_authority():
		if linear_velocity.length_squared() < 1:
			dandyBurst()
			queue_free()


func launch(direction: Vector2, speed: float):
	if is_multiplayer_authority():
		linear_velocity = direction * speed
