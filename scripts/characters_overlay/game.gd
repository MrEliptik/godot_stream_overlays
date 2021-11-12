extends Node2D

export var character_scene: PackedScene = preload("res://scenes/characters_overlay/character.tscn")
export var channel_name: String = "mreliptik"

onready var http_request = $HTTPRequest
onready var characters = $Characters

func _ready() -> void:
	$Polygon2D.polygon = $StaticBody2D.global_transform.xform($StaticBody2D/CollisionPolygon2D.polygon)
	get_tree().get_root().set_transparent_background(true)
	get_twitch_viewers()
	
func spawn_viewers(viewers):
	for viewer in viewers:
		var instance = character_scene.instance()
		characters.call_deferred("add_child", instance)
		yield(instance, "ready")
		instance.set_username(viewer)
		instance.global_position = Vector2(rand_range(40, 1800), 1080/2)

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
