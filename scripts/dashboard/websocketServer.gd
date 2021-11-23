extends Node

signal client_connected(id)
signal client_disconnected(id)

# The port we will listen to
var port = 9090
# Our WebSocketServer instance
var server: WebSocketServer = WebSocketServer.new()

var id = null

func _ready() -> void:
	server.connect("client_connected", self, "_connected")
	server.connect("client_disconnected", self, "_disconnected")
	server.connect("client_close_request", self, "_close_request")
	# This signal is emitted when not using the Multiplayer API every time a
	# full packet is received.
	# Alternatively, you could check get_peer(PEER_ID).get_available_packets()
	# in a loop for each connected peer.
	server.connect("data_received", self, "_on_data")
	
func _process(delta: float) -> void:
	server.poll()
	
func start() -> bool:
	# Start listening on the given port.
	var err = server.listen(port)
	if err != OK:
		print("Unable to start server")
		return false
	print("SERVER RUNNING")
	return true
	
func send(id, data):
	if !id: return
	if !server.has_peer(id): return
	server.get_peer(id).put_packet(data.to_utf8())

func _connected(id, proto):
	# This is called when a new peer connects, "id" will be the assigned peer id,
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	print("Client %d connected with protocol: %s" % [id, proto])
	self.id = id
	emit_signal("client_connected", self.id)

func _close_request(id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _disconnected(id, was_clean = false):
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	self.id = null
	emit_signal("client_disconnected", id)
