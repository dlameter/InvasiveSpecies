class_name	CropMatrixEntry extends Node

enum Stage {SEED, SPROUT, BUD, PLANT}

var growth: float
var stage: Stage
var sproutThreshold: float
var budThreshold: float
var plantThreshold: float

func _init(Crop: CropMatrixEntry):
	growth = Crop.growth
	stage = Crop.stage
	sproutThreshold = Crop.sproutThreshold
	budThreshold = Crop.budThreshold
	plantThreshold = Crop.budThreshold
	pass
	
func _randomCrop():
	pass

func _seedToSprout():
	pass
	
# Things to happen when plant is reaches bud threshold
func _sproutToBud():
	pass
	
# Thing to happen when plant is done growing
func _budToPlant():
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	growth = growth + delta
	if (stage == Stage.SEED && growth >= sproutThreshold):
		_seedToSprout()
	if (stage == Stage.SPROUT && growth >= budThreshold):
		_sproutToBud()
	if (stage == Stage.BUD && growth >= plantThreshold):
		_budToPlant()
	
	pass
