extends Node2D

const size: int = 7
const chanceOfRandomPlant: float = 0.05
var cropMatrix=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(size):
		cropMatrix[x]=[]
		for y in range(size):
			cropMatrix[x][y] = null
			
	pass # Replace with function body.
func place(x: int, y: int, CropMatrixEntry):
	cropMatrix[x][y] = CropMatrixEntry
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	pass
