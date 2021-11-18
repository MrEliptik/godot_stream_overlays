extends HBoxContainer

signal button_pressed()

export var connected_color: Color
export var disconnected_color: Color

enum STATUS {
	CONNECTED,
	DISCONNECTED
}

func _ready() -> void:
	pass

func _on_Button_pressed() -> void:
	emit_signal("button_pressed")
	
func set_status(status):
	match status:
		STATUS.CONNECTED:
			$Button.text = "DISCONNECT"
			$Panel.get_stylebox("panel").bg_color = connected_color
		STATUS.DISCONNECTED:
			$Panel.get_stylebox("panel").bg_color = disconnected_color
			$Button.text = "CONNECT"
