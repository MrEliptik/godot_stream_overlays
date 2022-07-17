extends Node

export var save_path : String = "user://avatar_users.json"

var user = {
	"username":"",
	"color":"",
	"join_overlay":false,
	"display_chat":true,
}

var users = []

func _ready() -> void:
	pass
	
func is_viewer_joining(username: String):
	for u in users:
		if u["username"] == username:
			if u["join_overlay"]: return true
			return false
	return false
	
func is_viewer_display_chat(username: String):
	for u in users:
		if u["username"] == username:
			if u["display_chat"]: return true
			return false
	return false
	
func get_user_color(username: String):
	for u in users:
		if u["username"] == username:
			return u["color"]
	
func create_user(username: String, color: Color, join_overlay: bool):
	var new_user = user.duplicate()
	new_user["username"] = username
	new_user["color"] = color
	new_user["join_overlay"] = join_overlay
	users.append(new_user)
	
func update_user(username: String, color, join_overlay):
	for u in users:
		if u["username"] == username:
			if color:
				u["color"] = color
			if join_overlay:
				u["join_overlay"] = join_overlay
			return

func user_exist(username: String) -> bool:
	for u in users:
		if username == u["username"]: return true
	return false
	
func save_users():
	var file = File.new()
	file.open(save_path, File.WRITE)
	file.store_var(users)
	file.close()
	
func load_users():
	var file = File.new()
	file.open(save_path, File.READ)
	users = file.get_var()
