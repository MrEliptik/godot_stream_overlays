extends Button

export var id = 0

func _ready() -> void:
	if text == "BUTTON 1":
		text = "BUTTON " + str(id+1)
