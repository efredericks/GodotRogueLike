extends Node2D


signal pc_attacked(message)

const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")
const RemoveObject := preload("res://scene/main/RemoveObject.gd")
const Schedule := preload("res://scene/main/Schedule.gd")

var _new_GroupName := preload("res://library/GroupName.gd").new()

var _ref_DungeonBoard: DungeonBoard
var _ref_RemoveObject: RemoveObject
var _ref_Schedule: Schedule

func chat(group_name: String, x: int, y: int) -> void:
	var _song = ["\\m/ SLAYERRRR! \\m/",\
	"Trapped in purgatory", \
	"A lifeless subject, alive", \
	"Awaiting reprisal", \
	"Death will be their acquisition", \
	"The sky is turning red", \
	"Return to power draws near", \
	"Fall into me, the skies crimson tears", \
	"Abolish the rules made of stone", \
	"Pierced from below", \
	"Souls of my treacherous past", \
	"Betrayed by many", \
	"Now ornaments dripping above", \
	"Awaiting the hour of reprisal", \
	"Your time slips away", \
	"Raining blood from a lacerated sky", \
	"Bleeding its horror", \
	"Creating my structure", \
	"Now shall I reign in blood!"]

	if not _ref_DungeonBoard.has_sprite(group_name, x, y):
		return

	if (group_name == _new_GroupName.VAMPIRE):
		var current_sprite = _ref_DungeonBoard.get_sprite(group_name, x, y)
		var _name: String = current_sprite.get_meta("char_name")
		var _song_index: int = current_sprite.get_meta("chat_index")
		print(_song_index, len(_song))
		var _msg = "{0}: {1}".format([_name, _song[_song_index]])
		_song_index += 1
		if _song_index > len(_song)-1:
			_song_index = 0
		current_sprite.set_meta("chat_index", _song_index)
		_ref_Schedule.end_turn()
		emit_signal("pc_attacked", _msg)

func attack(group_name: String, x: int, y: int) -> void:
	if not _ref_DungeonBoard.has_sprite(group_name, x, y):
		return

	var current_sprite = _ref_DungeonBoard.get_sprite(group_name, x, y)
	var _name: String = current_sprite.get_meta("char_name")
	var _hp: int = current_sprite.get_meta("hp")
	_hp -= 1
	current_sprite.set_meta("hp", _hp)

	var _msg: String = ""
	if (_hp <= 0):
		_msg = "You kill {0}.".format([_name])
		_ref_RemoveObject.remove(group_name, x, y)
	else:
		_msg = "You hurt {0}. [{1}]".format([_name, _hp]) 

	_ref_Schedule.end_turn()
	emit_signal("pc_attacked", _msg)

#func attack(group_name: String, x: int, y: int) -> void:
#	if not _ref_DungeonBoard.has_sprite(group_name, x, y):
#		return
#
#	var current_sprite = _ref_DungeonBoard.get_sprite(group_name, x, y)
#	var _name: String = current_sprite.get_meta("char_name")
#	var _hp: int = current_sprite.get_meta("hp")
#	_hp -= 1
#
#	_ref_RemoveObject.remove(group_name, x, y)
#	emit_signal("pc_attacked", "You kill Urist McRogueliker! :(")
#	_ref_Schedule.end_turn()

	#var current_sprite = _ref_DungeonBoard.get_sprite(group_name, x, y)
	#var _name: String = current_sprite.get_meta("char_name")
	#var _hp: int = current_sprite.get_meta("hp")
	#_hp -= 1
#
#	var _msg: String = ""
#	if (_hp <= 0):
#		_ref_RemoveObject.remove(group_name, x, y)
#	#emit_signal("pc_attacked", "You kill Urist McRogueliker! :(")
#		emit_signal("pc_attacked", "You kill " + _name + " :(")
#	else:
#		current_sprite.set_meta("hp", _hp)
#		emit_signal("pc_attacked", "You hurt " + _name + " for 1 point")
#	_ref_Schedule.end_turn()
