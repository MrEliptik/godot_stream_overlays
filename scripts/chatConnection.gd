extends Control

signal connect_pressed(nick_text, auth_text)

func _ready() -> void:
	pass

func _on_ConnectBtn_pressed() -> void:
	emit_signal("connect_pressed", $MarginContainer/VBoxContainer/NickLine.text, $MarginContainer/VBoxContainer/AuthLine.text)
