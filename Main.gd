extends Node2D

var world = {
	"date": System.date(1950, 1, 1)
}
var vehicles = {}
#var vehicles = {
#	"EN57-1659": {
#		"production": System.date(1986, 12, 17),
#		"repairs": {
#			"p3": [],
#			"p4": [],
#			"p5": []
#		},
#		"repairsNumber": {
#			"p3": 0,
#			"p4": 0,
#			"p5": 0
#		},
#		"nextRepair": null,
#		"status": {
#			"broken": false,
#			"repair": 0,
#			"pending": false,
#			"modernizing": false
#		},
#		"repairTime": 0,
#		"repairTimes": {
#			"p3": [30, 60],
#			"p4": [30, 90],
#			"p5": [60, 120]
#		},
#		"repairPendingTimes": {
#			"p3": [10, 30],
#			"p4": [15, 60],
#			"p5": [15, 60]
#		},
#		"nextRepairTime": System.date(0, 18, 0),
#		"repairAmounts": {
#			"p4": [1, 1],
#			"p5": [5, 10]
#		}
#	}
#}

func _ready():
	pass
	#while world["date"]["y"] < 2018 or world["date"]["m"] < 8:
	#	nextDay()

func nextDay():
	world["date"] = System.dateAdd(world["date"], System.date(0, 0, 1))
	if world["date"]["m"] == 1 && world["date"]["d"] == 1:
		print(world["date"]["y"])
	for key in vehicles.keys():
		var vehicle = vehicles[key] # only reference!!!
		var produced = System.dateGreater(world["date"], vehicle["production"])
		if produced:
			if vehicle["status"]["repair"] == 0:
				var needRepair = System.dateEqual(world["date"], vehicle["nextRepair"])
				if needRepair:
					var repairLevel = 1
					if System.progRandom(vehicle["repairAmounts"]["p4"][0], vehicle["repairAmounts"]["p4"][1], vehicle["repairsNumber"]["p3"]):
						repairLevel = 2
					if repairLevel == 2 and System.progRandom(vehicle["repairAmounts"]["p5"][0], vehicle["repairAmounts"]["p5"][1], vehicle["repairsNumber"]["p4"]):
						repairLevel = 3
					vehicle["status"]["repair"] = repairLevel
					vehicle["status"]["pending"] = true
#					print(System.dateToText(world["date"]))
#					print("Waiting for " + textRepairLevel(repairLevel))
			else:
				vehicle["repairTime"] += 1
			if vehicle["status"]["repair"] != 0:
				var level = textRepairLevel(vehicle["status"]["repair"])
				if vehicle["status"]["pending"]:
					if System.progRandom(vehicle["repairPendingTimes"][level][0], vehicle["repairPendingTimes"][level][1], vehicle["repairTime"]):
						vehicle["status"]["pending"] = false
						vehicle["repairTime"] = 0
#						print(System.dateToText(world["date"]))
#						print("Started " + level)
				if !vehicle["status"]["pending"]:
					if System.progRandom(vehicle["repairTimes"][level][0], vehicle["repairTimes"][level][1], vehicle["repairTime"]):
						vehicle["repairs"][level].append({"date":world["date"], "modernized":vehicle["status"]["modernizing"]})
						vehicle["repairsNumber"][level] += 1
						for i in range(vehicle["status"]["repair"] - 1):
							vehicle["repairsNumber"][textRepairLevel(i + 1)] = 0
						vehicle["status"]["repair"] = 0
						vehicle["status"]["modernizing"] = false
						vehicle["repairTime"] = 0
						vehicle["nextRepair"] = System.dateAdd(world["date"], vehicle["nextRepairTime"])
#						print(System.dateToText(world["date"]))
#						print("Ended " + level)
#						print(key + ": " + str(vehicle["repairsNumber"]))
		else:
			var justProduced = System.dateEqual(world["date"], vehicle["production"])
			if justProduced:
				vehicle["nextRepair"] = System.dateAdd(world["date"], vehicle["nextRepairTime"])
#				print(System.dateToText(world["date"]))
#				print("Produced!")

func textRepairLevel(level):
	var levels = ["p3", "p4", "p5"]
	return levels[level - 1]