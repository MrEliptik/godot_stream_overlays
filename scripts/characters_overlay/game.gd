extends Node2D

export var character_scene: PackedScene = preload("res://scenes/characters_overlay/character.tscn")
export var channel_name: String = "mreliptik"

onready var http_request = $HTTPRequest
onready var characters = $Characters

onready var gift = $Gift

var credentials = null

func _ready() -> void:
	# Connecting to twitch with the websocket, no credentials required
	gift.connect_to_twitch()
	yield(gift, "twitch_connected")
	print("CONNECTED!")
	
	credentials = read_crendentials()
	
	$Polygon2D.polygon = $StaticBody2D.global_transform.xform($StaticBody2D/CollisionPolygon2D.polygon)
	get_tree().get_root().set_transparent_background(true)
#	get_twitch_viewers()

func test():
	print("pretty terrible")
	"clearly right now if i'm typing fast enough it's horrible"

func read_crendentials() -> Dictionary:
	var credentials = {"username": "", "oauth": ""}
	var file = File.new()
	file.open("res://twitch_credentials.txt", File.READ)

	var index = 0
	while not file.eof_reached(): # iterate through all lines until the end of file is reached
		var line = file.get_line()
		if index == 0:
			credentials["username"] = line
		elif index == 1:
			credentials["oauth"] = line
			
		index += 1

	file.close()
	
	return credentials
	
func spawn_viewers(viewers):
	var children = $Characters.get_children()
	var viewer_names = []
	for child in children:
		viewer_names.append(child.username)
		
	for viewer in viewers:
		if viewer in viewer_names: continue
		var instance = character_scene.instance()
		characters.call_deferred("add_child", instance)
		yield(instance, "ready")
		instance.set_username(viewer)
		instance.global_position = Vector2(rand_range(40, 1800), 1080/2)
		
func despawn_viewers(viewers):
	var children = $Characters.get_children()
	var viewer_names = []
	for child in children:
		viewer_names.append(child.username)
		
	for viewer in viewers:
		if !viewer in viewer_names: continue
		var idx = viewer_names.find(viewer)
		if idx == -1: continue
		$Characters.get_child(idx).call_deferred("queue_free")

func get_twitch_viewers():
	# Perform a GET request. The URL below returns JSON as of writing.
	var url = "https://tmi.twitch.tv/group/user/{channel}/chatters".format({"channel":channel_name})
	print(url)
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var response = parse_json(body.get_string_from_utf8())
	var viewers = response.get("chatters").get("viewers")
	print(viewers)
	spawn_viewers(viewers)

func on_viewer_join(cmd_info : CommandInfo):
	spawn_viewers([cmd_info.sender_data.user])
	
func on_viewer_leave(cmd_info : CommandInfo):
	despawn_viewers([cmd_info.sender_data.user])

func _on_ChatConnection_connect_pressed(nick_text, auth_text) -> void:
	if credentials["username"] != "" && credentials["oauth"] != "":
		gift.authenticate_oauth(credentials["username"], credentials["oauth"])
	else:
		gift.authenticate_oauth(nick_text, auth_text)
	if(yield(gift, "login_attempt") == false):
		print("Invalid username or token.")
		return
	print("AUTHENTICATED")
	$CanvasLayer/ChatConnection.visible = false
	
	gift.join_channel("mreliptik")
#	gift.add_command("test", self, "bot_test")
	gift.add_command("join", self, "on_viewer_join")
	gift.add_command("leave", self, "on_viewer_leave")

func _on_Gift_whisper_message(sender_data, message) -> void:
	print(sender_data.user + ": " + message)

func _on_Gift_chat_message(sender_data, message) -> void:
	pass
