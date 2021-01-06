extends Node2D


signal pc_moved(message)
signal flip_map(id)

const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")
const Schedule := preload("res://scene/main/Schedule.gd")
const InitWorld := preload("res://scene/main/InitWorld.gd")


const PC_ATTACK: String = "PCAttack"
const RELOAD_GAME: String = "ReloadGame"

var _ref_DungeonBoard: DungeonBoard
var _ref_Schedule: Schedule

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_InputName := preload("res://library/InputName.gd").new()
var _new_GroupName := preload("res://library/GroupName.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()

const RemoveObject := preload("res://scene/main/RemoveObject.gd")
var _ref_RemoveObject: RemoveObject

var _pc: Sprite
var _move_inputs: Array = [
	_new_InputName.MOVE_LEFT,
	_new_InputName.MOVE_RIGHT,
	_new_InputName.MOVE_UP,
	_new_InputName.MOVE_DOWN,
	_new_InputName.MOVE_UP_LEFT,
	_new_InputName.MOVE_UP_RIGHT,
	_new_InputName.MOVE_DOWN_LEFT,
	_new_InputName.MOVE_DOWN_RIGHT,
	_new_InputName.WAIT,
	_new_InputName.EXIT,
	_new_InputName.FLIP,
	_new_InputName.FLIP_BACK,
]


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	var source: Array = _new_ConvertCoord.vector_to_array(_pc.position)
	var target: Array

	if _is_move_input(event):
		target = _get_new_position(event, source)
		_try_move(target[0], target[1])
	elif _is_reload_input(event):
		get_node(RELOAD_GAME).reload()


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_GroupName.PC):
		_pc = new_sprite
		set_process_unhandled_input(true)


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_GroupName.PC):
		set_process_unhandled_input(true)
	# print("{0}: Start turn.".format([current_sprite.name]))


func _is_reload_input(event: InputEvent) -> bool:
	if event.is_action_pressed(_new_InputName.RELOAD):
		return true
	return false


func _is_move_input(event: InputEvent) -> bool:
	for m in _move_inputs:
		if event.is_action_pressed(m):
			return true
	return false


func _try_move(x: int, y: int) -> void:
	if not _ref_DungeonBoard.is_inside_dungeon(x, y):
		emit_signal("pc_moved", "You cannot leave the map.")
# EMF - temp
#	elif _ref_DungeonBoard.has_sprite(_new_GroupName.WALL, x, y):
#		emit_signal("pc_moved", "You bump into wall.")
	elif _ref_DungeonBoard.has_sprite(_new_GroupName.CITY, x, y):
		var _s = _ref_DungeonBoard.get_sprite(_new_GroupName.CITY, x, y)
		emit_signal("pc_moved", "The breathtaking city of {0}.".format([_s.get_meta("city_name")]))
	elif _ref_DungeonBoard.has_sprite(_new_GroupName.DWARF, x, y):
		set_process_unhandled_input(false)
		get_node(PC_ATTACK).attack(_new_GroupName.DWARF, x, y)
	elif _ref_DungeonBoard.has_sprite(_new_GroupName.VAMPIRE, x, y):
		set_process_unhandled_input(false)
		#get_node(PC_ATTACK).attack(_new_GroupName.VAMPIRE, x, y)
		get_node(PC_ATTACK).chat(_new_GroupName.VAMPIRE, x, y)
	else:
		set_process_unhandled_input(false)
		_pc.position = _new_ConvertCoord.index_to_vector(x, y)
		_ref_Schedule.end_turn()


func _get_new_position(event: InputEvent, source: Array) -> Array:
	var x: int = source[0]
	var y: int = source[1]

	if event.is_action_pressed(_new_InputName.MOVE_LEFT):
		x -= 1
	elif event.is_action_pressed(_new_InputName.MOVE_RIGHT):
		x += 1
	elif event.is_action_pressed(_new_InputName.MOVE_UP):
		y -= 1
	elif event.is_action_pressed(_new_InputName.MOVE_DOWN):
		y += 1
	elif event.is_action_pressed(_new_InputName.MOVE_DOWN_RIGHT):
		x += 1
		y += 1
	elif event.is_action_pressed(_new_InputName.MOVE_DOWN_LEFT):
		x -= 1
		y += 1
	elif event.is_action_pressed(_new_InputName.MOVE_UP_LEFT):
		x -= 1
		y -= 1
	elif event.is_action_pressed(_new_InputName.MOVE_UP_RIGHT):
		x += 1
		y -= 1
	elif event.is_action_pressed(_new_InputName.WAIT):
		pass
	elif event.is_action_pressed(_new_InputName.EXIT):
		get_tree().quit()

	elif event.is_action_pressed(_new_InputName.FLIP):
		emit_signal("flip_map", 1)
		#print("FLIPPING MAP")
		#var to_remove = []
		#for i in range(_new_DungeonSize.MAX_X):
		#	for j in range(_new_DungeonSize.MAX_Y):
		#		for grp in [_new_GroupName.FLOOR, _new_GroupName.WALL, _new_GroupName.TREE, _new_GroupName.ROOF, _new_GroupName.WATER]:
		#			print(grp,i,j)
		#			if _ref_DungeonBoard.has_sprite(grp, i, j):
		#				to_remove.append(Vector3(grp, i, j))
#
		#for tr in to_remove:
		#	_ref_RemoveObject.remove(tr[0],tr[1],tr[2])
	elif event.is_action_pressed(_new_InputName.FLIP_BACK):
		emit_signal("flip_map", 0)

	return [x, y]
