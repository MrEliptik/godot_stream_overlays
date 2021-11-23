extends Node

signal new_data(data)

# The URL we will connect to
#export var websocket_url = "ws://192.168.31.216:9090"
export var websocket_url = "ws://192.168.31.30:9090"

# Our WebSocketClient instance
var client = WebSocketClient.new()

func _ready() -> void:
	print("About to connect to server..")
	# Connect base signals to get notified of connection open, close, and errors.
	client.connect("connection_closed", self, "_closed")
	client.connect("connection_error", self, "_closed")
	client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	client.connect("data_received", self, "_on_data")
	
func connect_to_server(ip: String, port: String) -> bool:
	# Initiate connection to the given URL.
	var err = client.connect_to_url("ws://"+ip+":"+port)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	print("Connected to server")
	return true
	
func _process(delta: float) -> void:
	client.poll()
		
func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	#client.get_peer(1).put_packet("Test packet".to_utf8())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var data = client.get_peer(1).get_packet().get_string_from_utf8()
	print("Got data from server: ", data)
	emit_signal("new_data", data)
#	var json_res = JSON.parse(data)

#	print(json_res)
#	json_res.result["type"]
