extends LineEdit

var typing = false

func _ready():
	pass

func start():
	text = ""
	grab_focus()
	typing = true

func end():
	release_focus()
	typing = false

func textChanged(newText):
	System.vehicleList.refresh()