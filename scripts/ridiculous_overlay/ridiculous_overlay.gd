extends Node2D

export var window_title: String = "Ridiculous overlay"

var shake = 0.0
var shake_intensity = 0.0
var timer = 0.0
var last_key = ""
var pitch_increase := 0.0
const PITCH_DECREMENT := 2.0

const Boom = preload("res://addons/ridiculous_coding/boom.tscn")
const Blip = preload("res://addons/ridiculous_coding/blip.tscn")
const Newline = preload("res://addons/ridiculous_coding/newline.tscn")

# The URL we will connect to
export var websocket_url = "ws://192.168.31.216:9080"

enum EFFECT_TYPE {
	SHAKE,
	TYPING,
	NEW_LINE,
	BOOM
}

# Our WebSocketClient instance
var client = WebSocketClient.new()

func _ready() -> void:
	OS.set_window_title(window_title)
	get_tree().get_root().set_transparent_background(true)
	create_wss()

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	client.poll()
	
	if shake > 0:
		shake -= delta
#		editor.get_base_control().rect_position = Vector2(rand_range(-shake_intensity,shake_intensity), rand_range(-shake_intensity,shake_intensity))
	else:
		pass
#		editor.get_base_control().rect_position = Vector2.ZERO

	timer += delta
	if (pitch_increase > 0.0):
		pitch_increase -= delta * PITCH_DECREMENT
		
func shake(duration, intensity):
	if shake > 0:
		return
		
	shake = duration
	shake_intensity = intensity

func typing(pos, last_key):
	# Draw the thing
	var thing = Blip.instance()
	thing.pitch_increase = pitch_increase
	pitch_increase += 1.0
	thing.position = pos
	thing.destroy = true
	thing.last_key = last_key
	add_child(thing)
	
	# Shake
	shake(0.05, 5)
	
func new_line(pos):
	# Draw the thing
	var thing = Newline.instance()
	thing.position = pos
	thing.destroy = true
	add_child(thing)
	
func boom(pos, last_key):
	var thing = Boom.instance()
	thing.position = pos
	thing.destroy = true
	thing.last_key = last_key
	add_child(thing)
	
###### WEBSOCKET STUFF
func create_wss():
	# Connect base signals to get notified of connection open, close, and errors.
	client.connect("connection_closed", self, "_closed")
	client.connect("connection_error", self, "_closed")
	client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	client.connect("data_received", self, "_on_data")
	
	# Initiate connection to the given URL.
	var err = client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	
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
#	print("Got data from server: ", data)
	var json_res = JSON.parse(data)

	match str2var(json_res.result["type"]):
		EFFECT_TYPE.BOOM:
			boom(str2var(json_res.result["pos"]), json_res.result["last_key"])
		EFFECT_TYPE.NEW_LINE:
			new_line(str2var(json_res.result["pos"]))
		EFFECT_TYPE.SHAKE:
			pass
		EFFECT_TYPE.TYPING:
			typing(str2var(json_res.result["pos"]), json_res.result["last_key"])
	

