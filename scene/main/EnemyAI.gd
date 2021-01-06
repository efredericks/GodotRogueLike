extends Node2D


signal enemy_warned(message)

const Schedule := preload("res://scene/main/Schedule.gd")
const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")

var _ref_Schedule: Schedule
var _new_GroupName := preload("res://library/GroupName.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _ref_DungeonBoard: DungeonBoard

var _pc: Sprite


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if not current_sprite.is_in_group(_new_GroupName.DWARF) and not current_sprite.is_in_group(_new_GroupName.VAMPIRE):
		return
	#if not current_sprite.is_in_group(_new_GroupName.VAMPIRE):
	#	return

	# Near PC --> attack if enemy, chat if not
	# Vampires are friendly, dwarves are not

	if _pc_is_close(_pc, current_sprite):
		if current_sprite.is_in_group(_new_GroupName.VAMPIRE) or current_sprite.is_in_group(_new_GroupName.DWARF):
			var _name = current_sprite.get_meta("char_name")
			var _hp = current_sprite.get_meta("hp")
			emit_signal("enemy_warned", "{0} is scared! [{1}]".format([_name, _hp]))
			#emit_signal("enemy_warned", "Vampy McVamparoo is scared!")
#		elif current_sprite.is_in_group(_new_GroupName.CITY):
#			var _city_name = current_sprite.get_meta("_city_name")
#			emit_signal("enemy_warned", "The breathtaking city of {0}".format([_city_name]))
		#else:
		#  emit_signal("enemy_warned", "Urist McRogueliker is scared!")


	# Enemy AI
	if (_new_ConvertCoord._rng.randf() > 0.8): # Move!
		var source: Array = _new_ConvertCoord.vector_to_array(current_sprite.position)
		var _old_x: int = source[0]
		var _old_y: int = source[1]
		# 0 1 2
		# 3 4 5
		# 6 7 8
		var _movedir: int = _new_ConvertCoord._rng.randi_range(0,8)
		if _movedir == 0:
			source[0] -= 1
			source[1] -= 1
		elif _movedir == 1:
			source[1] -= 1
		elif _movedir == 2:
			source[0] += 1
			source[1] -= 1
		elif _movedir == 3:
			source[0] -= 1
		elif _movedir == 4:
			pass
		elif _movedir == 5:
			source[0] += 1
		elif _movedir == 6:
			source[0] -= 1
			source[1] += 1
		elif _movedir == 7:
			source[1] += 1
		else:
			source[0] += 1
			source[1] += 1

		if _NPC_try_move(source[0], source[1]):
			var group: String = ""
			current_sprite.position = _new_ConvertCoord.index_to_vector(source[0], source[1])
			_ref_DungeonBoard.move_sprite(current_sprite, _old_x, _old_y, source[0], source[1])

	_ref_Schedule.end_turn()


func _NPC_try_move(x: int, y: int) -> bool:
	if not _ref_DungeonBoard.is_inside_dungeon(x, y):
		return false
#	elif _ref_DungeonBoard.has_sprite(_new_GroupName.WALL, x, y):
#		return false
	elif _ref_DungeonBoard.has_sprite(_new_GroupName.DWARF, x, y):
		return false
		#set_process_unhandled_input(false)
		#get_node(PC_ATTACK).attack(_new_GroupName.DWARF, x, y)
	elif _ref_DungeonBoard.has_sprite(_new_GroupName.VAMPIRE, x, y):
		return false
		#set_process_unhandled_input(false)
		#get_node(PC_ATTACK).attack(_new_GroupName.VAMPIRE, x, y)
	else:
		return true


"""
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

	return [x, y]


"""

func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_GroupName.PC):
		_pc = new_sprite


func _pc_is_close(source: Sprite, target: Sprite) -> bool:
	var source_pos: Array = _new_ConvertCoord.vector_to_array(source.position)
	var target_pos: Array = _new_ConvertCoord.vector_to_array(target.position)
	var delta_x: int = abs(source_pos[0] - target_pos[0]) as int
	var delta_y: int = abs(source_pos[1] - target_pos[1]) as int

	return delta_x + delta_y < 2
