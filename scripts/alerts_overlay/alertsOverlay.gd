extends Node2D

onready var alerts = ["play_confetti"]

onready var wsclient = $WebsocketClient

func _ready() -> void:
	get_tree().get_root().set_transparent_background(true)
	$CanvasLayer/ConnectionContainer.visible = true
	
func play_confetti():
	$Confetti.emitting = true

func _on_WebsocketClient_new_data(data) -> void:
	print(data)
	match data:
		"0":
			play_confetti()

func _on_ConnectionBtn_pressed() -> void:
	if wsclient.connect_to_server(
		$CanvasLayer/ConnectionContainer/VBoxContainer/HBoxContainer2/ServerIP.text, 
		$CanvasLayer/ConnectionContainer/VBoxContainer/HBoxContainer/Port.text):
		print("CONNECTED")
		$CanvasLayer/ConnectionContainer.visible = false
