extends Node2D


signal loading(msg)
signal sprite_created(new_sprite)
signal flip_map(id)

const Player := preload("res://sprite/PC.tscn")
const Dwarf := preload("res://sprite/Dwarf.tscn")
const Vampire := preload("res://sprite/Vampire.tscn")
const Wall := preload("res://sprite/Wall.tscn")
const ArrowX := preload("res://sprite/ArrowX.tscn")
const ArrowY := preload("res://sprite/ArrowY.tscn")
const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")

const Floor := preload("res://sprite/Floor.tscn")
const Tree := preload("res://sprite/Tree.tscn")
const Water := preload("res://sprite/Water.tscn")
const Roof := preload("res://sprite/Roof.tscn")
const City := preload("res://sprite/City.tscn")


var _ref_DungeonBoard: DungeonBoard

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_GroupName := preload("res://library/GroupName.gd").new()
var _new_InputName := preload("res://library/InputName.gd").new()

const RemoveObject := preload("res://scene/main/RemoveObject.gd")
var _ref_RemoveObject: RemoveObject


var _names = ["Wobb Sniggleplatz", "Wobb Dinglepuff", "Lemmy Persnickerdoodle", "Urist McDwarfFace", "Vampy Vampoir"]
var _city_names = ["Westeros", "Easteros", "Northeros", "Chatham"]

var iterations: int = 20000
var neighbors: int = 4
var ground_chance: int = 48
var min_cave_size: int = 80
var caves = []
var dungeon_floor = []

var sub_floor = []

enum _GENERATORS {NORMAL, CA, SIMPLEX}
export var GENERATOR = _GENERATORS.CA

export var octaves = 4
export var period = 20.0
export var persistence = 0.8

func _ready() -> void:
	# _rng.seed = 123
	_new_ConvertCoord._rng.randomize()

	# Setup temp array for CA
	for i in range(_new_DungeonSize.MAX_X):
		dungeon_floor.append([])
		for j in range(_new_DungeonSize.MAX_Y):
			dungeon_floor[i].append(-1)

	for i in range(20):
		sub_floor.append([])
		for j in range(20):
			sub_floor[i].append(_new_GroupName.FLOOR)

func loading(msg) -> void:
	pass

func _flipMap(id) -> void:
	pass
#	_ref_DungeonBoard._clear()
	#var to_remove = []
	#for i in range(_new_DungeonSize.MAX_X):
	#	for j in range(_new_DungeonSize.MAX_Y):
	#		for grp in [_new_GroupName.FLOOR, _new_GroupName.WALL, _new_GroupName.TREE, _new_GroupName.ROOF, _new_GroupName.WATER]:
	#			#print(grp,i,j)
	#			if _ref_DungeonBoard.has_sprite(grp, i, j):
	#				to_remove.append(Vector3(grp, i, j))
#
#	print("here 1")
#	for tr in to_remove:
#		print("removing {0} {1} {2}".format([tr[0],tr[1],tr[2]]))
#		_ref_RemoveObject.remove(tr[0],tr[1],tr[2])
#	print("here 2")

#	for grp in [_new_GroupName.FLOOR, _new_GroupName.WALL, _new_GroupName.TREE, _new_GroupName.ROOF, _new_GroupName.WATER]:
#		var nodes = get_tree().get_nodes_in_group(grp)
#		for n in nodes:
#			n.queue_free()
#	if id == 1:
#		_SubFloor_create_sprites()
#	else:
#		_CA_create_sprites()

	#print("here 3")

#	if not _ref_DungeonBoard.has_sprite(group_name, x, y):
#		return

#	var current_sprite = _ref_DungeonBoard.get_sprite(group_name, x, y)
#	var _name: String = current_sprite.get_meta("char_name")
#	var _hp: int = current_sprite.get_meta("hp")
#	_hp -= 1
#	current_sprite.set_meta("hp", _hp)
#
#	var _msg: String = ""
#	if (_hp <= 0):
#		_msg = "You kill {0}.".format([_name])
#		_ref_RemoveObject.remove(group_name, x, y)

#
#func remove(group_name: String, x: int, y: int) -> void:

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(_new_InputName.INIT_WORLD):

		emit_signal("loading", "Loading...")

		if GENERATOR == _GENERATORS.CA:
			_init_CA()
		elif GENERATOR == _GENERATORS.SIMPLEX:
			_init_Simplex()
		else:
			_init_floor()
			_init_wall()

		#_init_cities_and_paths()

		_init_dwarf()
		_init_vampire()
		_init_indicator()

		_init_PC()

		set_process_unhandled_input(false)
		
		emit_signal("loading", "Loading complete.")

# Randomly place a few cities and ensure there's a walking path between them
func _init_cities_and_paths() -> void:
	var num_cities: int = _new_ConvertCoord._rng.randi_range(2,4)
	#var cities = []

	for _i in range(num_cities):
		var _x: int = _new_ConvertCoord._rng.randi_range(2,_new_DungeonSize.MAX_X-2)
		var _y: int = _new_ConvertCoord._rng.randi_range(2,_new_DungeonSize.MAX_Y-2)
		dungeon_floor[_x][_y] = _new_GroupName.CITY
	return


# https://docs.godotengine.org/en/stable/classes/class_opensimplexnoise.html
func _init_Simplex() -> void:
	randomize()
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()



	# Initialize as open
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			var _n = noise.get_noise_2d(i,j) #_new_GroupName.FLOOR

			# Make this cleaner later
			if _n <= 0.0:
				dungeon_floor[i][j] = _new_GroupName.FLOOR
			elif _n < 0.10:
				dungeon_floor[i][j] = _new_GroupName.WALL
			elif _n <= 0.30:
				dungeon_floor[i][j] = _new_GroupName.WATER
			elif _n <= 0.70:
				dungeon_floor[i][j] = _new_GroupName.TREE
			else:
				dungeon_floor[i][j] = _new_GroupName.ROOF

	_init_cities_and_paths()

	_CA_create_sprites() # Same func to create sprites from the 2D array


# https://abitawake.com/news/articles/procedural-generation-with-godot-creating-caves-with-cellular-automata
func _init_CA() -> void:
	## TBD: update to use local _rng
	_CA_clear()
	_CA_fill_roof()
	_CA_random_ground()
	_CA_dig_caves()
	_CA_get_caves()
	_CA_connect_caves()

	_CA_create_sprites()
	#print("They're digging a wall to Isengard")

func _SubFloor_create_sprites() -> void:
	for i in range(20):
		#print(dungeon_floor[i])
		for j in range(20):
			if sub_floor[i][j] == _new_GroupName.FLOOR:
				_create_sprite(Floor, _new_GroupName.FLOOR, i, j)
			elif sub_floor[i][j] == _new_GroupName.ROOF:
				_create_sprite(Roof, _new_GroupName.ROOF, i, j)
			elif sub_floor[i][j] == _new_GroupName.WATER:
				_create_sprite(Water, _new_GroupName.WATER, i, j)
			elif sub_floor[i][j] == _new_GroupName.TREE:
				_create_sprite(Tree, _new_GroupName.TREE, i, j)
			else:
				_create_sprite(Wall, _new_GroupName.WALL, i, j)

func _CA_create_sprites() -> void:

	for i in range(_new_DungeonSize.MAX_X):
		#print(dungeon_floor[i])
		for j in range(_new_DungeonSize.MAX_Y):
			if dungeon_floor[i][j] == _new_GroupName.FLOOR:
				_create_sprite(Floor, _new_GroupName.FLOOR, i, j)
			elif dungeon_floor[i][j] == _new_GroupName.ROOF:
				_create_sprite(Roof, _new_GroupName.ROOF, i, j)
			elif dungeon_floor[i][j] == _new_GroupName.WATER:
				_create_sprite(Water, _new_GroupName.WATER, i, j)
			elif dungeon_floor[i][j] == _new_GroupName.TREE:
				_create_sprite(Tree, _new_GroupName.TREE, i, j)
			elif dungeon_floor[i][j] == _new_GroupName.CITY:
				_create_sprite(City, _new_GroupName.CITY, i, j)
			else:
				_create_sprite(Wall, _new_GroupName.WALL, i, j)
			#get_node("/root/MainScene/CanvasLayer/MainGUI/MainHBox/Modeline")._on_Loading("Loading {0}".format([j]))
			#emit_signal("loading", "Loading {0}.".format([j]))


func _CA_clear() -> void:
	pass

func _CA_fill_roof() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			dungeon_floor[i][j] = _new_GroupName.ROOF
			#_create_sprite(Floor, _new_GroupName.ROOF, i, j)

func _CA_chance(num):
	if randi() * 100 <= num:
		return true
	else:
		return false
func _CA_choose(choices):
	var rand_index: int = randi() % choices.size()
	return choices[rand_index]

func _CA_random_ground() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			if _CA_chance(ground_chance):
				dungeon_floor[i][j] = _new_GroupName.FLOOR
				#_create_sprite(Floor, _new_GroupName.FLOOR, i, j)

func _CA_dig_caves() -> void:
	for _i in range(iterations):
		var _x = floor(_new_ConvertCoord._rng.randi_range(1, _new_DungeonSize.MAX_X-2))
		var _y = floor(_new_ConvertCoord._rng.randi_range(1, _new_DungeonSize.MAX_Y-2))

		if _CA_check_nearby(_x, _y) > neighbors:
			dungeon_floor[_x][_y] = _new_GroupName.FLOOR

func _CA_check_nearby(_x, _y):
	var count = 0
	if dungeon_floor[_x][_y-1]   == _new_GroupName.ROOF:  count += 1
	if dungeon_floor[_x][_y+1]   == _new_GroupName.ROOF:  count += 1
	if dungeon_floor[_x-1][_y]   == _new_GroupName.ROOF:  count += 1
	if dungeon_floor[_x+1][_y]   == _new_GroupName.ROOF:  count += 1
	if dungeon_floor[_x+1][_y+1] == _new_GroupName.ROOF:  count += 1
	if dungeon_floor[_x+1][_y-1] == _new_GroupName.ROOF:  count += 1
	if dungeon_floor[_x-1][_y+1] == _new_GroupName.ROOF:  count += 1
	if dungeon_floor[_x-1][_y-1] == _new_GroupName.ROOF:  count += 1
	return count

	## ADD DIAG
	## ADD SPRITE SCENES

func _CA_get_caves() -> void:
	caves = []

	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			if dungeon_floor[i][j] == _new_GroupName.FLOOR:
				_CA_flood_fill(i, j)

	for cave in caves:
		for t in cave:
			t = _new_GroupName.FLOOR

func _CA_flood_fill(t_x, t_y):
	var cave = []
	var to_fill = [Vector2(t_x, t_y)]
	while to_fill:
		var t = to_fill.pop_back()

		if !cave.has(t):
			cave.append(t)
			t = _new_GroupName.ROOF

		# check adjacent
		var north = Vector2(t_x, t_y-1)
		var south = Vector2(t_x, t_y+1)
		var east = Vector2(t_x+1, t_y)
		var west = Vector2(t_x-1, t_y)

		for dir in [north,south,east,west]:
			if dungeon_floor[dir[0]][dir[1]] == _new_GroupName.FLOOR:
				if !to_fill.has(dir) and !cave.has(dir):
					to_fill.append(dir)

	if cave.size() >= min_cave_size:
		caves.append(cave)


func _CA_connect_caves() -> void:
	var prev_cave = null
	var tunnel_caves = caves.duplicate()

	for cave in tunnel_caves:
		if prev_cave:
			var new_point = _CA_choose(cave)
			var prev_point = _CA_choose(prev_cave)

			if new_point != prev_point:
				_CA_create_tunnel(new_point, prev_point, cave)

		prev_cave = cave

func _CA_create_tunnel(point1, point2, cave) -> void:
	var max_steps = 500
	var steps = 0
	var drunk_x = point2[0]
	var drunk_y = point2[1]

	while steps < max_steps and !cave.has(Vector2(drunk_x, drunk_y)):
		steps += 1

		var n = 1.0
		var s = 1.0
		var e = 1.0
		var w = 1.0
		var weight = 1

		if drunk_x < point1.x:
			e += weight
		elif drunk_x > point1.x:
			w += weight
		if drunk_y < point1.y:
			s += weight
		elif drunk_y > point1.y:
			n += weight

		var total = n + s + e + w
		n /= total
		s /= total
		e /= total
		w /= total

		var dx
		var dy
		var choice = randf()
		if 0 <= choice and choice < n:
			dx = 0
			dy = -1
		elif n <= choice and choice < (n+s):
			dx = 0
			dy = 1
		elif (n+s) <= choice and choice < (n+s+e):
			dx = 1
			dy = 0
		else:
			dx = -1
			dy = 0

		if (2 < drunk_x + dx and drunk_x + dx < _new_DungeonSize.MAX_X-2) and \
		 (2 < drunk_y + dy and drunk_y + dy < _new_DungeonSize.MAX_Y-2):
			drunk_x += dx
			drunk_y += dy

			if dungeon_floor[drunk_x][drunk_y] == _new_GroupName.ROOF:
				dungeon_floor[drunk_x][drunk_y] = _new_GroupName.FLOOR

				dungeon_floor[drunk_x+1][drunk_y] = _new_GroupName.FLOOR
				dungeon_floor[drunk_x+1][drunk_y+1] = _new_GroupName.FLOOR



func _init_vampire() -> void:
	var vampire: int = _new_ConvertCoord._rng.randi_range(3, 6)
	var x: int
	var y: int

	while vampire > 0:
		x = _new_ConvertCoord._rng.randi_range(1, _new_DungeonSize.MAX_X - 1)
		y = _new_ConvertCoord._rng.randi_range(1, _new_DungeonSize.MAX_Y - 1)

		if _ref_DungeonBoard.has_sprite(_new_GroupName.WALL, x, y) \
				or _ref_DungeonBoard.has_sprite(_new_GroupName.DWARF, x, y) \
				or _ref_DungeonBoard.has_sprite(_new_GroupName.VAMPIRE, x, y):
			continue
		_create_sprite(Vampire, _new_GroupName.VAMPIRE, x, y)
		vampire -= 1

func _init_dwarf() -> void:
	var dwarf: int = _new_ConvertCoord._rng.randi_range(3, 6)
	var x: int
	var y: int

	while dwarf > 0:
		x = _new_ConvertCoord._rng.randi_range(1, _new_DungeonSize.MAX_X - 1)
		y = _new_ConvertCoord._rng.randi_range(1, _new_DungeonSize.MAX_Y - 1)

		if _ref_DungeonBoard.has_sprite(_new_GroupName.WALL, x, y) \
				or _ref_DungeonBoard.has_sprite(_new_GroupName.DWARF, x, y) \
				or _ref_DungeonBoard.has_sprite(_new_GroupName.VAMPIRE, x, y):
			continue
		_create_sprite(Dwarf, _new_GroupName.DWARF, x, y)
		dwarf -= 1


func _init_PC() -> void:
	var _x: int = 1#_new_ConvertCoord._rng.randi_range(1, _new_DungeonSize.MAX_X - 1)
	var _y: int = 1#_new_ConvertCoord._rng.randi_range(1, _new_DungeonSize.MAX_Y - 1)
	#var done: bool = false

#	while not done:
#		if dungeon_floor[_x][_y] == _new_GroupName.FLOOR:
#			done = true
		#if not _ref_DungeonBoard.has_sprite(_new_GroupName.WALL, _x, _y) \
		#		and not _ref_DungeonBoard.has_sprite(_new_GroupName.DWARF, _x, _y) \
		#		and not _ref_DungeonBoard.has_sprite(_new_GroupName.VAMPIRE, _x, _y):
#				done = true
	_create_sprite(Player, _new_GroupName.PC, _x, _y)#1, 1)#0, 0)


func _init_floor() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			_create_sprite(Floor, _new_GroupName.FLOOR, i, j)


func _init_wall() -> void:
	var shift: int = 2
	var min_x: int = _new_DungeonSize.CENTER_X - shift
	var max_x: int = _new_DungeonSize.CENTER_X + shift + 1
	var min_y: int = _new_DungeonSize.CENTER_Y - shift
	var max_y: int = _new_DungeonSize.CENTER_Y + shift + 1

	for i in range(min_x, max_x):
		for j in range(min_y, max_y):
			_create_sprite(Wall, _new_GroupName.WALL, i, j)

func _init_indicator() -> void:
	_create_sprite(ArrowX, _new_GroupName.ARROW, 0, 12,
			-_new_DungeonSize.ARROW_MARGIN)
	_create_sprite(ArrowY, _new_GroupName.ARROW, 5, 0,
			0, -_new_DungeonSize.ARROW_MARGIN)


func _create_sprite(prefab: PackedScene, group: String, x: int, y: int,
		x_offset: int = 0, y_offset: int = 0) -> void:

	var new_sprite: Sprite = prefab.instance() as Sprite
	new_sprite.position = _new_ConvertCoord.index_to_vector(
			x, y, x_offset, y_offset)
	new_sprite.add_to_group(group)
 

	# Init dwarf characteristics
	if (group == _new_GroupName.DWARF):
		new_sprite.set_meta("hp", randi() % 10)
		new_sprite.set_meta("char_name", _names[randi() % _names.size()])
	# Init vamp characteristics
	elif (group == _new_GroupName.VAMPIRE):
		new_sprite.set_meta("hp", randi() % 5)
		new_sprite.set_meta("chat_index", 0)
		new_sprite.set_meta("char_name", _names[randi() % _names.size()])
	elif (group == _new_GroupName.CITY): #TBD - unique city names
		new_sprite.set_meta("city_name", _city_names[randi() % _city_names.size()])
	else:
		pass

	add_child(new_sprite)
	emit_signal("sprite_created", new_sprite)
