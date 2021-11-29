extends Control

onready var wsserver = $WebsocketServer

func _ready() -> void:
	# (^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)
	var ips = IP.get_local_addresses()
	$ConnectionContainer.visible = true
	$ConnectionContainer/VBoxContainer/GridContainer/LocalIP.text = IP.get_local_addresses()[0]
	$VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/LocalIP.text = IP.get_local_addresses()[0]
	
	for child in $VBoxContainer/ButtonContainer/GridContainer.get_children():
		child.connect("pressed", self, "on_btn_pressed", [child.id])
	
######### WEBSOCKET SERVER #########
func _on_WebsocketServer_client_connected(id) -> void:
	$VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer3/ClientStatus.text = str(id)

func on_btn_pressed(id):
	wsserver.send(wsserver.id, str(id))

######### CONNECTION PANEL #########
func _on_ConnectionBtn_pressed() -> void:
	wsserver.port = int($ConnectionContainer/VBoxContainer/GridContainer/Port.text)
	if wsserver.start():
		$VBoxContainer/MarginContainer/HBoxContainer/ServerStatus.text = "RUNNING"
		$ConnectionContainer.visible = false
	else:
		$VBoxContainer/MarginContainer/HBoxContainer/ServerStatus.text = "STOPPED"

