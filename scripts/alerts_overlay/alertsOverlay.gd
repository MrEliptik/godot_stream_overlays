extends Node2D

export var window_title: String = "Alerts overlay"

onready var alerts = ["play_confetti"]

onready var wsclient = $WebsocketClient

func _ready() -> void:
	OS.set_window_title(window_title)
	get_tree().get_root().set_transparent_background(true)
	$CanvasLayer/ConnectionContainer.visible = true
	
func play_confetti():
	$Confetti.emitting = true

func _on_WebsocketClient_new_data(data) -> void:
	print(data)
	match data:
		"0":
			play_confetti()
		"1":
			$Overlays/AspectRatioContainer/ShockedPenguin.play_video()
		"2":
			$Overlays/AspectRatioContainer2/ClappingUlysses.play_video()
		"3":
			$Overlays/AspectRatioContainer3/HomerRevenge.play_video()

func _on_ConnectionBtn_pressed() -> void:
	if wsclient.connect_to_server(
		$CanvasLayer/ConnectionContainer/VBoxContainer/GridContainer/ServerIP.text, 
		$CanvasLayer/ConnectionContainer/VBoxContainer/GridContainer/Port.text):
		print("CONNECTED")
		$CanvasLayer/ConnectionContainer.visible = false
