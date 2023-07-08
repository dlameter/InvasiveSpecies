extends Node2D

const size = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	var cropMatrix=[]
	for x in range(size):
		cropMatrix[x]=[]
		for y in range(size):
			cropMatrix[x][y]= CropMatrixEntry.new()
			
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
