extends RichTextLabel

onready var world = System.world
onready var vehicles = System.vehicles
var chars = {
#	"0,0": {
#		"char": 'a',
#		"color": null,
#		"meta": null
#	}
}
var maxChars = Vector2(0, 0)
var mode = {
	"mode":"list",
	"page":0,
	"aboutTo":""
}

func _ready():
	set_process(true)

func _process(delta):
	rect_size = get_viewport_rect().size
	var oldMaxChars = maxChars
	maxChars = Vector2(floor(rect_size[0] / 8), floor(rect_size[1] / 17))
	if oldMaxChars != maxChars:
		refresh()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if mode["mode"] == "list" && mode["aboutTo"] == "":
			metaClicked("close")

func refresh():
	eraseScreen()
	
	## INTERFACE
	var menuHeight = 4
	putText(Vector2(0, 0), "ILOSTAN v.[TEST]", Color(0.0, 1.0, 1.0))
	var fileName = System.fileName
	if fileName == "":
		fileName = "(Nowy plik)"
	putText(Vector2(0, 1), "Plik: " + fileName, Color(0.0, 1.0, 1.0))
	if System.justSaved:
		putText(Vector2(len(fileName) + 8, 1), "Zapisane!", Color(0.5, 1.0, 0.5))
	else:
		putText(Vector2(len(fileName) + 8, 1), "Niezapisane!", Color(1.0, 1.0, 0.5))
	if mode["mode"] != "file" && mode["mode"] != "dateJump":
		if !mode.has("aboutTo") || mode["aboutTo"] == "":
			putText(Vector2(0, 2), ">Nowy<", Color(0.5, 0.5, 1.0), "mode_file_new")
			putText(Vector2(9, 2), ">Otwórz<", Color(0.5, 0.5, 1.0), "mode_file_load")
			putText(Vector2(20, 2), ">Zapisz<", Color(0.5, 0.5, 1.0), "file_save")
			putText(Vector2(31, 2), ">Zapisz jako<", Color(0.5, 0.5, 1.0), "mode_file_save")
			putText(Vector2(47, 2), ">Koniec<", Color(0.5, 0.5, 1.0), "close")
			putText(Vector2(maxChars[0] - 61, 2), System.dateToText(System.world["date"]), Color(0.5, 0.5, 1.0))
			putText(Vector2(maxChars[0] - 48, 2), ">Nowy dzień<", Color(0.5, 0.5, 1.0), "day_next")
			putText(Vector2(maxChars[0] - 33, 2), ">Skocz do dnia...<", Color(0.5, 0.5, 1.0), "mode_dateJump")
			putText(Vector2(maxChars[0] - 12, 2), ">Wiadomości<", Color(0.5, 0.5, 1.0))
		else:
			putYesNo(Vector2(0, 2), "Niezapisane zmiany. Zapisać?", "mode_acceptAboutTo", "mode_denyAboutTo", "mode_cancelAboutTo")
	if System.error > 0:
		var text = "BŁĄD " + str(System.error)
		if System.errorTexts.has(str(System.error)):
			text += ": " + System.errorTexts[str(System.error)]
		putText(Vector2(0, 3), text, Color(1.0, 0.0, 0.0))
	
	if mode["mode"] == "file":
		## NEW MENU
		if mode["type"] == "new":
			putText(Vector2(0, menuHeight), "Nowy plik...", Color(1.0, 0.75, 0.5))
			putText(Vector2(4, menuHeight + 2), "Data początkowa:", Color(1.0, 1.0, 0.0))
			putDateController(Vector2(4, menuHeight + 4))
			putText(Vector2(4, menuHeight + 8), ">Anuluj<", Color(1.0, 0.5, 0.5), "mode_list")
			putText(Vector2(15, menuHeight + 8), ">Gotowe<", Color(0.5, 1.0, 0.5), "file_new")
		else:
			## SAVE/LOAD MENU
			if mode["type"] == "load":
				putText(Vector2(0, menuHeight), "Otwórz plik...", Color(1.0, 0.75, 0.5))
			if mode["type"] == "save":
				putText(Vector2(0, menuHeight), "Zapisz plik...", Color(1.0, 0.75, 0.5))
			putText(Vector2(0, menuHeight + 1), "Ścieżka: " + mode["path"], Color(1.0, 1.0, 0.0))
			putText(Vector2(len(mode["path"]) + 12, menuHeight + 1), ">Wybór woluminu<", Color(1.0, 1.0, 0.0), "file_drive")
			var fileList = System.fileList(mode["path"])
			var deletedKeys = 0
			for i in range(fileList.size()):
				var key = fileList.keys()[i - deletedKeys]
				if !fileList[key] && key.split(".")[-1] != "ilo":
					fileList.erase(key)
					deletedKeys += 1
			var recordsPerPage = max(maxChars[1] - (menuHeight + 5), 1)
			if mode["type"] == "save":
				recordsPerPage = max(maxChars[1] - (menuHeight + 7), 1)
			var pageCount = ceil(float(fileList.size()) / recordsPerPage)
			mode["page"] = min(mode["page"], pageCount - 1)
			var firstRecord = mode["page"] * recordsPerPage
			for i in range(firstRecord, firstRecord + recordsPerPage):
				if i >= fileList.size():
					break
				var key = fileList.keys()[i]
				var pos = Vector2(4, menuHeight + ((i - firstRecord) + 3))
				if fileList[key]:
					putText(pos, key + "/", Color(1.0, 1.0, 1.0), "file_jump_" + key)
				else:
					if mode["type"] == "load":
						putText(pos, key, Color(0.0, 1.0, 1.0), "file_open_" + key)
					if mode["type"] == "save":
						putText(pos, key, Color(0.0, 1.0, 1.0), "file_hint_" + key)
			
			## PAGES
			putText(Vector2(0, maxChars[1] - 1), ">Anuluj<", Color(1.0, 0.5, 0.5), "mode_list")
			if mode["type"] == "save":
				mode["name"] = System.typing.text
				if mode["overwriteAlert"]:
					putYesNo(Vector2(0, maxChars[1] - 3), "Plik istnieje. Nadpisać?", "file_saveAs_" + mode["name"], "file_saveDeny")
				else:
					putText(Vector2(0, maxChars[1] - 3), "Nazwa pliku: " + mode["name"] + "_", Color(1.0, 1.0, 0.0))
				if System.fileNameValid(mode["name"]) && mode["path"] != "":
					putText(Vector2(11, maxChars[1] - 1), ">Zapisz<", Color(0.5, 1.0, 0.5), "file_saveQueue_" + mode["name"])
				else:
					putText(Vector2(11, maxChars[1] - 1), ">Zapisz<", Color(0.5, 0.5, 0.5))
			putPageController(pageCount)
	
	if mode["mode"] == "dateJump":
		## DATE JUMP WINDOW
		putText(Vector2(0, menuHeight), "Skocz do dnia...", Color(1.0, 0.75, 0.5))
		putText(Vector2(4, menuHeight + 2), "UWAGA! Funkcja może nie działać poprawnie przy cofaniu się w czasie!", Color(1.0, 1.0, 0.0))
		putText(Vector2(4, menuHeight + 3), "Duże przeskoki mogą spowodować chwilowe zawieszenie się programu!", Color(1.0, 1.0, 0.0))
		putDateController(Vector2(4, menuHeight + 5))
		putText(Vector2(4, menuHeight + 9), ">Anuluj<", Color(1.0, 0.5, 0.5), "mode_list")
		putText(Vector2(15, menuHeight + 9), ">Gotowe<", Color(0.5, 1.0, 0.5), "day_jump")
	
	if mode["mode"] == "list":
		## VEHICLE LIST
		putText(Vector2(0, menuHeight), "Lista pojazdów", Color(1.0, 0.75, 0.5))
		if vehicles.empty():
			putText(Vector2(4, menuHeight + 2), "Wygląda na to, że tutaj nic nie ma... :(", Color(1.0, 0.5, 0.5))
			putText(Vector2(4, menuHeight + 4), "Otwórz jakiś plik lub dodaj nowy pojazd!", Color(0.0, 1.0, 1.0))
		else:
			var data = [
			{"data":[{"text":"Pojazd","color":Color(1.0, 1.0, 0.0),"meta":null}], "width":12},
			{"data":[{"text":"Stan","color":Color(1.0, 1.0, 0.0),"meta":null}], "width":10},
			{"data":[{"text":"Ost. napr.","color":Color(1.0, 1.0, 0.0),"meta":null}], "width":10},
			{"data":[{"text":"Ost. P3","color":Color(1.0, 1.0, 0.0),"meta":null}], "width":10},
			{"data":[{"text":"Ost. P4","color":Color(1.0, 1.0, 0.0),"meta":null}], "width":10},
			{"data":[{"text":"Ost. P5","color":Color(1.0, 1.0, 0.0),"meta":null}], "width":10},
			{"data":[{"text":"Wyg. dop.","color":Color(1.0, 1.0, 0.0),"meta":null}], "width":10},
			{"data":[{"text":"Uwagi","color":Color(1.0, 1.0, 0.0),"meta":null}], "width":maxChars[0] - 92},
			{"data":[{"text":"Szczegóły","color":Color(1.0, 1.0, 0.0),"meta":null}], "width":10}
			]
			var tableHeight = maxChars[1] - (menuHeight + 3)
			var recordsPerPage = max(floor((tableHeight - 3) / 2.0), 1)
			var pageCount = ceil(float(vehicles.size()) / recordsPerPage)
			mode["page"] = min(mode["page"], pageCount - 1)
			var firstRecord = mode["page"] * recordsPerPage
			for i in range(firstRecord, firstRecord + recordsPerPage):
				if i >= vehicles.size():
					break
				var key = vehicles.keys()[i]
				var vehicle = vehicles[key]
				for j in range(data.size()):
					var label = ""
					var labelColor = null
					var labelMeta = null
					if j == 0:
						label = key
					if j == 1:
						if System.dateGreater(world["date"], vehicle["production"]):
							if vehicle["status"]["repair"] == 0:
								if vehicle["status"]["broken"]:
									label = "Nieczynny"
									labelColor = Color(1.0, 0.5, 0.5)
								else:
									label = "Czynny"
									labelColor = Color(0.5, 1.0, 0.5)
							else:
								if vehicle["status"]["pending"]:
									label += "O"
								label += "P" + str(vehicle["status"]["repair"] + 2)
								if vehicle["status"]["modernizing"]:
									label += "+M"
								labelColor = Color(1.0, 1.0, 0.5)
						else:
							label = "Niewyprod."
							labelColor = Color(0.5, 0.5, 0.5)
					if j == 2:
						if vehicle["repairsNumber"]["p3"] == 0 && vehicle["repairsNumber"]["p4"] == 0 && vehicle["repairsNumber"]["p5"] == 0:
							label = "-"
						else:
							if vehicle["repairsNumber"]["p5"] > 0:
								label += str(vehicle["repairsNumber"]["p5"])
							if vehicle["repairsNumber"]["p4"] == 0:
								label += "P5"
							else:
								label += "P4/" + str(vehicle["repairsNumber"]["p4"])
							if vehicle["repairsNumber"]["p3"] > 0:
								label += "+" + str(vehicle["repairsNumber"]["p3"]) + "xP3"
					if j == 3:
						if vehicle["repairs"]["p3"].size() > 0:
							label = System.dateToText(vehicle["repairs"]["p3"][-1]["date"])
						else:
							label = System.dateToText(null)
					if j == 4:
						if vehicle["repairs"]["p4"].size() > 0:
							label = System.dateToText(vehicle["repairs"]["p4"][-1]["date"])
						else:
							label = System.dateToText(null)
					if j == 5:
						if vehicle["repairs"]["p5"].size() > 0:
							label = System.dateToText(vehicle["repairs"]["p5"][-1]["date"])
						else:
							label = System.dateToText(null)
					if j == 6:
						label = System.dateToText(vehicle["nextRepair"])
						if vehicle["nextRepair"] != null:
							if System.dateGreater(vehicle["nextRepair"], world["date"]):
								labelColor = Color(0.5, 1.0, 0.5)
							else:
								labelColor = Color(1.0, 0.5, 0.5)
					if j == 7:
						label = "brak"
					if j == 8:
						label = ">Zobacz!<"
						labelMeta = "mode_details_" + key
					data[j]["data"].append({"text":label,"color":labelColor,"meta":labelMeta})
			putTable(Vector2(0, menuHeight + 1), data)
			
			## PAGES
			putPageController(pageCount)
	refreshScreen()
	
	if mode["mode"] == "details":
		print(mode)

func refreshScreen():
	clear()
	for i in range(maxChars[1]):
		for j in range(maxChars[0]):
			var pos = str(j) + "," + str(i)
			if chars.has(pos):
				var character = chars[pos]
				if character["color"] != null:
					push_color(character["color"])
				if character["meta"] != null:
					push_meta(character["meta"])
				add_text(character["char"])
				if character["color"] != null:
					pop()
				if character["meta"] != null:
					pop()
			else:
				add_text(" ")
		newline()

func posToString(pos):
	return str(pos[0]) + "," + str(pos[1])

func eraseScreen():
	chars.clear()
	refreshScreen()

func eraseChar(pos):
	chars.erase(posToString(pos))

func putChar(pos, character, color = null, meta = null):
	chars[posToString(pos)] = {
		"char": character,
		"color": color,
		"meta": meta
	}

func putText(pos, text, color = null, meta = null, restrW = 0, restrH = 0):
	text = text.split("\n")
	for i in range(text.size()):
		if restrH > 0 and restrH == i:
			break
		var line = text[i]
		for j in range(len(line)):
			if restrW > 0 and restrW == j:
				break
			putChar(pos + Vector2(j, i), line[j], color, meta)

func putRectangle(pos, size, character, filled = false, color = null):
	for i in range(size[1]):
		for j in range(size[0]):
			var newPos = pos + Vector2(j, i)
			if filled || (newPos[0] == pos[0] || newPos[1] == pos[1] || newPos[0] == (pos[0] + size[0]) - 1 || newPos[1] == (pos[1] + size[1]) - 1):
				putChar(newPos, character, color)

func putTable(pos, data, color = null):
	var widths = []
	var heights = []
	for i in range(data.size()):
		var column = data[i]
		widths.append(column["width"])
		for j in range(column["data"].size()):
			var cell = column["data"][j]["text"]
			if i == 0:
				heights.append(System.lineCount(cell))
			else:
				heights[j] = max(heights[j], System.lineCount(cell))
	var globalWidths = [pos[0]]
	for i in range(widths.size()):
		var width = widths[i]
		globalWidths.append(globalWidths[-1] + (width + 1))
	var globalHeights = [pos[1]]
	for i in range(heights.size()):
		var height = heights[i]
		globalHeights.append(globalHeights[-1] + (height + 1))
	for i in range(globalWidths.size()):
		var width = globalWidths[i]
		for j in range((globalHeights[-1] - globalHeights[0]) + 1):
			var charPos = Vector2(width, globalHeights[0] + j)
			var up = charPos[1] != globalHeights[0]
			var right = charPos[0] != globalWidths[-1]
			var down = charPos[1] != globalHeights[-1]
			var left = charPos[0] != globalWidths[0]
			var cross = globalHeights.has(charPos[1])
			putChar(charPos, System.boxChar(up, right && cross, down, left && cross), color)
	for i in range(globalHeights.size()):
		var height = globalHeights[i]
		for j in range((globalWidths[-1] - globalWidths[0]) + 1):
			var charPos = Vector2(globalWidths[0] + j, height)
			var up = charPos[1] != globalHeights[0]
			var right = charPos[0] != globalWidths[-1]
			var down = charPos[1] != globalHeights[-1]
			var left = charPos[0] != globalWidths[0]
			var cross = globalWidths.has(charPos[0])
			putChar(charPos, System.boxChar(up && cross, right, down && cross, left), color)
	for i in range(data.size()):
		var column = data[i]
		var columnWidth = column["width"]
		for j in range(column["data"].size()):
			var cell = column["data"][j]
			var cellPos = Vector2(globalWidths[i] + 1, globalHeights[j] + 1)
			putText(cellPos, cell["text"], cell["color"], cell["meta"], columnWidth)

func putYesNo(pos, text, yMeta, nMeta, cMeta = null):
	putText(pos, text, Color(1.0, 1.0, 0.0))
	putText(pos + Vector2(len(text) + 3, 0), ">Tak<", Color(0.5, 1.0, 0.5), yMeta)
	putText(pos + Vector2(len(text) + 11, 0), ">Nie<", Color(1.0, 0.5, 0.5), nMeta)
	if cMeta != null:
		putText(pos + Vector2(len(text) + 19, 0), ">Anuluj<", Color(1.0, 1.0, 0.5), cMeta)

func putDateController(pos):
	putText(pos + Vector2(0, 0), "Rok:", Color(1.0, 1.0, 0.0))
	putText(pos + Vector2(0, 1), "Miesiąc:", Color(1.0, 1.0, 0.0))
	putText(pos + Vector2(0, 2), "Dzień:", Color(1.0, 1.0, 0.0))
	putText(pos + Vector2(15, 0), System.addFollowingZeros(mode["date"]["y"], 4))
	putText(pos + Vector2(16, 1), System.addFollowingZeros(mode["date"]["m"], 2))
	putText(pos + Vector2(16, 2), System.addFollowingZeros(mode["date"]["d"], 2))
	putText(pos + Vector2(10, 0), "10", Color(1.0, 0.5, 0.5), "date_y_-10")
	putText(pos + Vector2(13, 0), "-", Color(1.0, 0.5, 0.5), "date_y_-1")
	putText(pos + Vector2(20, 0), "+", Color(0.5, 1.0, 0.5), "date_y_1")
	putText(pos + Vector2(22, 0), "10", Color(0.5, 1.0, 0.5), "date_y_10")
	putText(pos + Vector2(13, 1), "-", Color(1.0, 0.5, 0.5), "date_m_-1")
	putText(pos + Vector2(20, 1), "+", Color(0.5, 1.0, 0.5), "date_m_1")
	putText(pos + Vector2(13, 2), "-", Color(1.0, 0.5, 0.5), "date_d_-1")
	putText(pos + Vector2(20, 2), "+", Color(0.5, 1.0, 0.5), "date_d_1")
	

func putPageController(pageCount):
	var pageText = "Strona " + str(mode["page"] + 1) + " / " + str(pageCount)
	var pageTextY = maxChars[1] - 1
	putText(Vector2(maxChars[0] - (len(pageText) + 3), pageTextY), pageText)
	if mode["page"] > 0:
		putText(Vector2(maxChars[0] - (len(pageText) + 6), pageTextY), "<<", Color(1.0, 1.0, 0.0), "page_" + str(mode["page"] - 1))
	else:
		putText(Vector2(maxChars[0] - (len(pageText) + 6), pageTextY), "<<", Color(0.5, 0.5, 0.5))
	if mode["page"] < pageCount - 1:
		putText(Vector2(maxChars[0] - 2, pageTextY), ">>", Color(1.0, 1.0, 0.0), "page_" + str(mode["page"] + 1))
	else:
		putText(Vector2(maxChars[0] - 2, pageTextY), ">>", Color(0.5, 0.5, 0.5))

func metaClicked(meta):
	meta = meta.split("_")
	if meta[0] == "close":
		if System.justSaved || mode["aboutTo"] != "":
			System.close()
		else:
			mode["aboutTo"] = "close"
	if meta[0] == "mode":
		System.typing.end()
		if meta[1] == "list":
			mode = {"mode":"list", "page":0, "aboutTo":""}
		if meta[1] == "acceptAboutTo":
			var aboutTo = mode["aboutTo"]
			metaClicked("file_save")
			if mode["mode"] == "list":
				metaClicked(mode["aboutTo"])
			else:
				mode["aboutTo"] = aboutTo
		if meta[1] == "denyAboutTo":
			metaClicked(mode["aboutTo"])
		if meta[1] == "cancelAboutTo":
			mode["aboutTo"] = ""
		if meta[1] == "details":
			mode = {"mode":"details", "vehicle":meta[2]}
		if meta[1] == "file":
			if (meta[2] == "save" || System.justSaved) || mode["aboutTo"] != "":
				if meta[2] == "new":
					mode = {"mode":"file", "type":meta[2], "date":System.date(1950, 1, 1)}
				else:
					mode = {"mode":"file", "type":meta[2], "path":System.pathJump(System.fileName, ".."), "name":"", "page":0, "overwriteAlert":false}
					if meta[2] == "save":
						System.typing.start()
			else:
				mode["aboutTo"] = "mode_file_" + meta[2]
		if meta[1] == "dateJump":
			mode = {"mode":"dateJump", "date":world["date"]}
	if meta[0] == "page":
		mode["page"] = int(meta[1])
	if meta[0] == "day":
		if meta[1] == "next":
			System.nextDay()
		if meta[1] == "jump":
			System.jumpToDay(mode["date"])
			metaClicked("mode_list")
	if meta[0] == "date":
		var amount = int(meta[2])
		if meta[1] == "y":
			mode["date"] = System.dateAdd(mode["date"], System.date(amount, 0, 0))
		if meta[1] == "m":
			mode["date"] = System.dateAdd(mode["date"], System.date(0, amount, 0))
		if meta[1] == "d":
			mode["date"] = System.dateAdd(mode["date"], System.date(0, 0, amount))
	if meta[0] == "file":
		var file = ""
		for i in range(meta.size() - 2):
			if i > 0:
				file += "_"
			file += meta[i + 2]
		if meta[1] == "drive":
			mode["path"] = ""
		if meta[1] == "jump":
			mode["path"] = System.pathJump(mode["path"], file)
		if meta[1] == "hint":
			file = file.split(".")
			file.remove(file.size() - 1)
			var fileName = ""
			for i in range(file.size()):
				if i > 0:
					fileName += "."
				fileName += file[i]
			System.typing.text = fileName
		if meta[1] == "new":
			System.newFile(mode["date"])
			metaClicked("mode_list")
		if meta[1] == "open":
			System.loadFile(System.pathJump(mode["path"], file, false))
			metaClicked("mode_list")
		if meta[1] == "save":
			if System.fileName == "":
				metaClicked("mode_file_save")
			else:
				System.saveFile(System.fileName)
		if meta[1] == "saveAs":
			System.saveFile(System.pathJump(mode["path"], file + ".ilo", false))
			if !mode.has("aboutTo") || mode["aboutTo"] == "":
				metaClicked("mode_list")
			else:
				metaClicked(mode["aboutTo"])
		if meta[1] == "saveQueue":
			if System.fileList(mode["path"]).has(file + ".ilo"):
				mode["overwriteAlert"] = true
			else:
				metaClicked("file_saveAs_" + file)
		if meta[1] == "saveDeny":
			mode["overwriteAlert"] = false
	refresh()