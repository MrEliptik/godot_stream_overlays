tool
extends EditorPlugin

export var editor_button_scene: PackedScene = preload("res://addons/ridiculous_coding/editor_button.tscn")

var shake = 0.0
var shake_intensity = 0.0
var timer = 0.0
var last_key = ""
var pitch_increase := 0.0
const PITCH_DECREMENT := 2.0

const Boom = preload("boom.tscn")
const Blip = preload("blip.tscn")
const Newline = preload("newline.tscn")

enum EFFECT_TYPE {
	SHAKE,
	TYPING,
	NEW_LINE,
	BOOM
}

##### WEBSOCKET STUFF
# The port we will listen to
const PORT = 9080
# Our WebSocketServer instance
var server: WebSocketServer = WebSocketServer.new()

var btn = null
var id = null

func _enter_tree():
	btn = editor_button_scene.instance()
	add_control_to_container(CONTAINER_TOOLBAR, btn)
	if btn.connect("pressed", self, "on_server_connect_pressed") != OK:
		print("ERROR CONNECTING BUTTON")
	
	var editor = get_editor_interface()
	var script_editor = editor.get_script_editor()
	script_editor.connect("editor_script_changed", self, "editor_script_changed")
	start_wss_server()

func _exit_tree():
	print("exit tree")
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_container(CONTAINER_TOOLBAR, btn)
	# Erase the control from the memory.
	btn.free()

var editors = {}
func get_all_text_editors(parent : Node):
	for child in parent.get_children():
		if child.get_child_count():
			get_all_text_editors(child)
			
		if child is TextEdit:
			editors[child] = { "text": child.text, "line": child.cursor_get_line() }
			
			if child.is_connected("cursor_changed", self, "cursor_changed"):
				child.disconnect("cursor_changed", self, "cursor_changed")
			child.connect("cursor_changed", self, "cursor_changed", [child])
				
			if child.is_connected("text_changed", self, "text_changed"):
				child.disconnect("text_changed", self, "text_changed")
			child.connect("text_changed", self, "text_changed", [child])

			if child.is_connected("gui_input", self, "gui_input"):
				child.disconnect("gui_input", self, "gui_input")
			child.connect("gui_input", self, "gui_input")


func gui_input(event):
	# Get last key typed
	if event is InputEventKey and event.pressed:
		event = event as InputEventKey
		last_key = OS.get_scancode_string(event.get_scancode_with_modifiers())
		

func editor_script_changed(script):
	var editor = get_editor_interface()
	var script_editor = editor.get_script_editor()
	
	editors.clear()
	get_all_text_editors(script_editor)


func _process(delta):
	var editor = get_editor_interface()
	
#	print(server.is_listening())
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	if server.is_listening():
		server.poll()
	
#	if shake > 0:
#		shake -= delta
#		editor.get_base_control().rect_position = Vector2(rand_range(-shake_intensity,shake_intensity), rand_range(-shake_intensity,shake_intensity))
#	else:
#		editor.get_base_control().rect_position = Vector2.ZERO
#
	timer += delta
#	if (pitch_increase > 0.0):
#		pitch_increase -= delta * PITCH_DECREMENT


func shake(duration, intensity):
	if shake > 0:
		return
		
	shake = duration
	shake_intensity = intensity
	
	
func cursor_changed(textedit):
	var editor = get_editor_interface()
	
	if not editors.has(textedit):
		# For some reason the editor instances all change
		# when the file is saved so you need to reload them
		editors.clear()
		get_all_text_editors(editor.get_script_editor())
		
	editors[textedit]["line"] = textedit.cursor_get_line()


func text_changed(textedit : TextEdit):
	var editor = get_editor_interface()
	var settings = editor.get_editor_settings()
	
	if not editors.has(textedit):
		# For some reason the editor instances all change
		# when the file is saved so you need to reload them
		editors.clear()
		get_all_text_editors(editor.get_script_editor())
		
	# Get line and character count
	var line = textedit.cursor_get_line()
	var column = textedit.cursor_get_column()
	
	# Compensate for tab size
	var tab_size = settings.get_setting("text_editor/indent/size")
	var line_text = textedit.get_line(line).substr(0,column)
	column += line_text.count("\t") * (tab_size - 1)
	
	# Compensate for scroll
	var vscroll = textedit.scroll_vertical
	var hscroll = textedit.scroll_horizontal
	
	# When you are scrolled to the bottom of a file
	# and you delete some lines from the bottom using Ctrl+X
	# then the vscroll can go down without changing the visible
	# scroll position. That throws off the calculation because
	# we're calculating the position from the lower position but
	# visually the position hasn't moved. By setting vscroll
	# to the new actual position, the editor moves the visible
	# lines to remove the gap. It changes the editor behavior
	# slightly for a better result.
	textedit.scroll_vertical = vscroll
	
	# Compensate for line spacing
	var line_spacing = settings.get_setting("text_editor/theme/line_spacing")
	
	# Load editor font
	var font : DynamicFont = DynamicFont.new()
	font.font_data = load(settings.get_setting("interface/editor/code_font"))
	font.size = settings.get_setting("interface/editor/code_font_size")
	var fontsize = font.get_string_size(" ")
	
	# Compute caret position
	var pos = Vector2()
	pos.x = (column) * (fontsize.x) - hscroll + 100
#	pos.y = (line-vscroll) * (fontsize.y+line_spacing-2) + 16
	pos.y = (line+1-vscroll) * (fontsize.y+line_spacing-2) + 16

	if editors.has(textedit):
		# Deleting
		if timer > 0.1 and len(textedit.text) < len(editors[textedit]["text"]):
			timer = 0.0
			
			# Draw the thing
#			var thing = Boom.instance()
#			thing.position = pos
#			thing.destroy = true
#			thing.last_key = last_key
#			textedit.add_child(thing)

			var data = {"type":var2str(EFFECT_TYPE.BOOM), "pos": var2str(pos+textedit.rect_global_position), "last_key": last_key}
			send(id, JSON.print(data))
			
			# Shake
			shake(0.2, 10)

		# Typing
		if timer > 0.02 and len(textedit.text) >= len(editors[textedit]["text"]):
			timer = 0.0
			
			var data = {"type":var2str(EFFECT_TYPE.TYPING), "pos": var2str(pos+textedit.rect_global_position), "last_key": last_key}
			send(id, JSON.print(data))

			# Draw the thing
#			var thing = Blip.instance()
#			thing.pitch_increase = pitch_increase
#			pitch_increase += 1.0
#			thing.position = pos
#			thing.destroy = true
#			thing.last_key = last_key
#			textedit.add_child(thing)
			
			# Shake
			shake(0.05, 5)
			
		# Newline
		if textedit.cursor_get_line() != editors[textedit]["line"]:
			var data = {"type":var2str(EFFECT_TYPE.NEW_LINE), "pos": var2str(pos+textedit.rect_global_position)}
			send(id, JSON.print(data))
#			# Draw the thing
#			var thing = Newline.instance()
#			thing.position = pos
#			thing.destroy = true
#			textedit.add_child(thing)
			
			# Shake
			shake(0.05, 5)

	editors[textedit]["text"] = textedit.text
	editors[textedit]["line"] = textedit.cursor_get_line()

###### WEBSCOCKETS STUFF
func start_wss_server():
	# Connect base signals to get notified of new client connections,
	# disconnections, and disconnect requests.
	server.connect("client_connected", self, "_connected")
	server.connect("client_disconnected", self, "_disconnected")
	server.connect("client_close_request", self, "_close_request")
	# This signal is emitted when not using the Multiplayer API every time a
	# full packet is received.
	# Alternatively, you could check get_peer(PEER_ID).get_available_packets()
	# in a loop for each connected peer.
	server.connect("data_received", self, "_on_data")

func send(id, data):
#	if !id: return
	if !server.has_peer(id): return
	server.get_peer(id).put_packet(data.to_utf8())
	
func on_server_connect_pressed():
	if server.is_listening():
		server.stop()
		btn.set_connection_status(btn.STATUS.DISCONNECTED)
		return
		
	# Start listening on the given port.
	var err = server.listen(PORT)
	if err != OK:
		print("Unable to start server")
		set_process(false)
		btn.set_connection_status(btn.STATUS.DISCONNETED)
	btn.set_connection_status(btn.STATUS.CONNECTED)

func _connected(id, proto):
	# This is called when a new peer connects, "id" will be the assigned peer id,
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	print("Client %d connected with protocol: %s" % [id, proto])
	self.id = id

func _close_request(id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _disconnected(id, was_clean = false):
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
