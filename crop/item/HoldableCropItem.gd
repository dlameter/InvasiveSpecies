class_name HoldableCropItem
extends CropItem


# Interface functions

func throw(_player: Player, _dir: Vector2):
	assert(false, "throw should be implemented in the subclass")


func hold(_player: Player):
	assert(false, "hold should be implemented in the subclass")


func let_go():
	assert(false, "let_go should be implemented in the subclass")


# perhaps firing while holding a plant does a bash?
func bash(_player: Player):
	assert(false, "bash is not implemented")


# Events needed: dig, dig_hold, dig_pos update, 


# Internal

var dig_threshold = 4
@export var dig_delay = dig_threshold
@export var dig_hold: float = 0.0
@export var dig_hold_threshold: float = 0.5

enum DigState {
	IDLE,
	WAIT_FOR_RELEASE,
	HOLD_VS_THROW,
	THROW_PLANT,
	HOLD_PLANT,
	UNHOLD_PLANT
}
@export var current_dig_state: DigState = DigState.IDLE


func dig_state_to_function(state: DigState) -> Callable:
	match state:
		DigState.WAIT_FOR_RELEASE:
			return wait_for_release
		DigState.HOLD_VS_THROW:
			return block_vs_throw
		DigState.THROW_PLANT:
			return throw_plant
		DigState.HOLD_PLANT:
			return hold_plant
		DigState.UNHOLD_PLANT:
			return unhold_plant
		_:
			return dig_idle


func _ready():
	dig_delay = dig_threshold


func _physics_process(delta):
	handle_digging(delta)


func handle_fire(_player: Player, _delta: float, _dir: Vector2):
	assert(false, "handle_fire should be implemented in the subclass")


func handle_dig(player: Player, delta: float, dir: Vector2):
	print("dig received, ", dir)


var max_event_depth = 10

func handle_digging(delta: float):
	dig_delay += delta
	
	if is_multiplayer_authority():
		var depth = 0
		while depth < max_event_depth:
			var next_dig_state = dig_state_to_function(current_dig_state).call(delta)
			if next_dig_state == current_dig_state:
				break
			current_dig_state = next_dig_state
			depth += 1


func dig_idle(_delta: float) -> DigState:
	if the_player.input.dig_pos != Vector2.ZERO:
		return DigState.HOLD_VS_THROW
	
	return DigState.IDLE


func wait_for_release(_delta: float) -> DigState:
	if the_player.input.dig_pos != Vector2.ZERO:
		return DigState.WAIT_FOR_RELEASE
	
	return DigState.IDLE


func block_vs_throw(delta: float) -> DigState:
	if the_player.input.dig_pos == Vector2.ZERO:
		return DigState.THROW_PLANT
	elif dig_hold >= dig_hold_threshold:
		dig_hold = 0
		return DigState.HOLD_PLANT
	
	dig_hold += delta
	
	return DigState.HOLD_VS_THROW


func throw_plant(_delta: float) -> DigState:
	throw(the_player, the_player.input.dig_pos)
	return DigState.WAIT_FOR_RELEASE


func hold_plant(_delta: float) -> DigState:
	hold(the_player)
	return DigState.UNHOLD_PLANT


func unhold_plant(_delta: float) -> DigState:
	if the_player.input.dig_pos == Vector2.ZERO:
		let_go()
		return DigState.IDLE
	else:
		return DigState.UNHOLD_PLANT


