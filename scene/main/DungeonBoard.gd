extends Node2D

var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_GroupName := preload("res://library/GroupName.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()

# <string_group_name, <int_column, array_sprite>>
var _sprite_dict: Dictionary


func _ready() -> void:
	_init_dict()

#func _clear() -> void:
#	_sprite_dict.clear()


func is_inside_dungeon(x: int, y: int) -> bool:
	return (x > -1) and (x < _new_DungeonSize.MAX_X) \
			and (y > -1) and (y < _new_DungeonSize.MAX_Y)

func has_sprite(group_name: String, x: int, y: int) -> bool:
	return get_sprite(group_name, x, y) != null

func get_sprite(group_name: String, x: int, y: int) -> Sprite:
	if not is_inside_dungeon(x, y):
		return null
	return _sprite_dict[group_name][x][y]
#	if _sprite_dict.has(group_name) and _sprite_dict[group_name].has(x) and _sprite_dict[group_name][x].has(y):
#		return _sprite_dict[group_name][x][y]
#	else:
#		return null

func move_sprite(current_sprite: Sprite, old_x: int, old_y: int, new_x: int, new_y: int):
	var group: String = ""
	if current_sprite.is_in_group(_new_GroupName.DWARF):
		group = _new_GroupName.DWARF
	elif current_sprite.is_in_group(_new_GroupName.VAMPIRE):
		group = _new_GroupName.VAMPIRE
	else:
		return

	_sprite_dict[group][new_x][new_y] = current_sprite
	_sprite_dict[group][old_x][old_y] = null 


#func move_sprite(group_name: String, old_x: int, old_y: int, new_x: int, new_y: int) -> void:
#	if not _sprite_dict[group_name][old_x][old_y]:
#		_sprite_dict[group_name][new_x][new_y] = _sprite_dict[group_name][old_x][old_y]
#		_sprite_dict[group_name][old_x][old_y] = null
#	return


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	var pos: Array
	var group: String

	if new_sprite.is_in_group(_new_GroupName.DWARF):
		group = _new_GroupName.DWARF
	elif new_sprite.is_in_group(_new_GroupName.WALL):
		group = _new_GroupName.WALL
	elif new_sprite.is_in_group(_new_GroupName.VAMPIRE):
		group = _new_GroupName.VAMPIRE
	elif new_sprite.is_in_group(_new_GroupName.CITY):
		group = _new_GroupName.CITY
	else:
		return

	pos = _new_ConvertCoord.vector_to_array(new_sprite.position)
	_sprite_dict[group][pos[0]][pos[1]] = new_sprite


func _on_RemoveObject_sprite_removed(_sprite: Sprite, group_name: String,
		x: int, y: int) -> void:
	_sprite_dict[group_name][x][y] = null


func _init_dict() -> void:
	var groups = [_new_GroupName.DWARF, _new_GroupName.VAMPIRE, _new_GroupName.WALL, _new_GroupName.CITY]

	for g in groups:
		_sprite_dict[g] = {}
		for x in range(_new_DungeonSize.MAX_X):
			_sprite_dict[g][x] = []
			_sprite_dict[g][x].resize(_new_DungeonSize.MAX_Y)
