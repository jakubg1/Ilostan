extends Node

onready var main = get_node("/root/Main")
onready var vehicleList = get_node("/root/Main/VehicleList")
onready var typing = get_node("/root/Main/Typing")

var fileName = ""
var justSaved = false
var error = 0

func _ready():
	newFile(date(1950, 1, 1))

func close():
	get_tree().quit()

func newFile(date):
	fileName = ""
	justSaved = false
	main.vehicles.clear()
	main.world["date"] = date

func saveFile(path):
	print("Save " + path)
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_string(to_json(main.world) + "\n" + to_json(main.vehicles))
	file.close()
	fileName = path
	justSaved = true

func loadFile(path):
	print("Load " + path)
	var file = File.new()
	file.open(path, file.READ)
	var world = parse_json(file.get_line())
	var vehicles = parse_json(file.get_line())
	file.close()
	if world == null || vehicles == null:
		error = 1
		return
	main.world = world
	main.vehicles = vehicles
	fileName = path
	justSaved = true

func composePath(directories):
	var path = ""
	for i in range(directories.size()):
		var directory = directories[i]
		path = pathJump(path, directory)
	return path

func decomposePath(path):
	var directories = path.split("/")
	if directories[-1] == "":
		directories.remove(directories.size() - 1)
	return directories

func pathJump(path, directory, endSlash = true):
	if directory == "..":
		if path != "":
			var directories = decomposePath(path)
			directories.remove(directories.size() - 1)
			path = composePath(directories)
	else:
		path += directory
		if endSlash:
			path += "/"
	return path

func fileList(path):
	var dir = Directory.new()
	var files = {}
	if path == "":
		for i in range(dir.get_drive_count()):
			var drive = dir.get_drive(i)
			files[drive] = true
		return files
	if dir.open(path) == OK:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			if file != ".":
				files[file] = dir.current_is_dir()
		return files
	else:
		return {"..":true}

func fileNameValid(name):
	var forbiddenChars = ["\\", "/", ":", "*", "?", "\"", "<", ">", "|"]
	var forbiddenNames = ["con", "aux", "nul", "prn", "com0", "com1", "com2", "com3", "com4", "com5", "com6", "com7", "com8", "com9", "lpt0", "lpt1", "lpt2", "lpt3", "lpt4", "lpt5", "lpt6", "lpt7", "lpt8", "lpt9"]
	if forbiddenNames.has(name.to_lower()):
		return false
	for i in range(len(name)):
		var character = name[i]
		if forbiddenChars.has(character):
			return false
	return true

func lineCount(string):
	return string.split("\n").size()

func boxChar(up, right, down, left):
	if up:
		if right:
			if down:
				if left:
					return "\u253c"
				else:
					return "\u251c"
			else:
				if left:
					return "\u2534"
				else:
					return "\u2514"
		else:
			if down:
				if left:
					return "\u2524"
				else:
					return "\u2502"
			else:
				if left:
					return "\u2518"
				else:
					return "\u2575"
	else:
		if right:
			if down:
				if left:
					return "\u252c"
				else:
					return "\u250c"
			else:
				if left:
					return "\u2500"
				else:
					return "\u2576"
		else:
			if down:
				if left:
					return "\u2510"
				else:
					return "\u2577"
			else:
				if left:
					return "\u2574"
				else:
					return " "

func addFollowingZeros(number, totalLength):
	number = str(number)
	if len(number) < totalLength:
		for i in range(totalLength - len(number)):
			number = "0" + number
	return number

func random(from, to):
	from = int(from)
	to = int(to)
	randomize()
	return (randi() % ((to - from) + 1)) + from

func progRandom(from, to, number):
	if number < from:
		return false
	if number >= to:
		return true
	return random(0, to - number) == 0

func daysNumber(y, m):
	y = int(y)
	m = int(m)
	while m > 12:
		m -= 12
		y += 1
	var months = [4, 6, 9, 11] # months with 30 days
	if m == 2:
		if y % 4 == 0 && (y % 100 != 0 || y % 400 == 0):
			return 29
		return 28
	if months.has(m):
		return 30
	return 31

func date(y, m, d):
	return {"y": y, "m": m, "d": d}

func dateToText(date):
	if date == null:
		return "--.--.----"
	return addFollowingZeros(date["d"], 2) + "." + addFollowingZeros(date["m"], 2) + "." + addFollowingZeros(date["y"], 4)

func dateAdd(date1, date2):
	var date = date1.duplicate()
	date["y"] += date2["y"]
	date["m"] += date2["m"]
	date["d"] += date2["d"]
	while date["d"] > daysNumber(date["y"], date["m"]):
		date["d"] -= daysNumber(date["y"], date["m"])
		date["m"] += 1
	while date["m"] > 12:
		date["m"] -= 12
		date["y"] += 1
	while date["d"] < 1:
		date["m"] -= 1
		date["d"] += daysNumber(date["y"], date["m"])
	while date["m"] < 1:
		date["y"] -= 1
		date["m"] += 12
	return date

func dateEqual(date1, date2):
	# true if date1 == date2
	return date1["y"] == date2["y"] && date1["m"] == date2["m"] && date1["d"] == date2["d"]

func dateGreater(date1, date2):
	# true if date1 > date2
	if date1["y"] > date2["y"]:
		return true
	if date1["y"] < date2["y"]:
		return false
	if date1["m"] > date2["m"]:
		return true
	if date1["m"] < date2["m"]:
		return false
	if date1["d"] > date2["d"]:
		return true
	if date1["d"] < date2["d"]:
		return false
	return false