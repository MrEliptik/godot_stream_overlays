tool
extends Button

export var connected_color: Color
export var disconnected_color: Color

enum STATUS {
	CONNECTED,
	DISCONNECTED
}

func _ready() -> void:
	pass
	
func set_connection_status(status):
	match status:
		STATUS.CONNECTED:
			text = "STOP"
			get_stylebox("normal").bg_color = connected_color
		STATUS.DISCONNECTED:
			get_stylebox("normal").bg_color = disconnected_color
			text = "LISTEN"
