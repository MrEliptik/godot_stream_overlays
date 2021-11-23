extends Control

onready var wsserver = $WebsocketServer

func _ready() -> void:
	$ConnectionContainer.visible = true
	$ConnectionContainer/VBoxContainer/HBoxContainer2/LocalIP.text = IP.get_local_addresses()[0]
	$ButtonContainer/VBoxContainer/HBoxContainer/HBoxContainer2/LocalIP.text = IP.get_local_addresses()[0]
	
	
	
######### WEBSOCKET SERVER #########
func _on_WebsocketServer_client_connected(id) -> void:
	$ButtonContainer/VBoxContainer/HBoxContainer/ClientStatus.text = str(id)

func _on_Button_pressed() -> void:
	wsserver.send(wsserver.id, "0")

######### CONNECTION PANEL #########
func _on_ConnectionBtn_pressed() -> void:
	wsserver.port = int($ConnectionContainer/VBoxContainer/HBoxContainer/Port.text)
	if wsserver.start():
		$ButtonContainer/VBoxContainer/HBoxContainer/ServerStatus.text = "RUNNING"
		$ConnectionContainer.visible = false
	else:
		$ButtonContainer/VBoxContainer/HBoxContainer/ServerStatus.text = "STOPPED"

