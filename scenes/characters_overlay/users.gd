extends Node

export var save_path : String = "user://avatar_users.json"

var user = {
	"username":"",
	"color":"",
	"join_overlay":true,
	"display_username":false,
	"display_chat":true,
	"level":0,
	"experience":0.0
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

func is_viewer_showing_username(username: String):
	for u in users:
		if u["username"] == username:
			if u["display_username"]: return true
			return false
	return false
	
func get_viewer_level(username: String) -> int:
	for u in users:
		if u["username"] == username:
			if u.has("level"): return u["level"]
		return 0
	return 0
	
func get_viewer_experience(username: String) -> float:
	for u in users:
		if u["username"] == username:
			if u.has("experience"): return u["experience"]
		return 0.0
	return 0.0
	
func get_user_color(username: String):
	for u in users:
		if u["username"] == username:
			return u["color"]
	
func create_user(username: String, color: Color, join_overlay: bool, display_username: bool):
	var new_user = user.duplicate()
	new_user["username"] = username
	new_user["color"] = color
	new_user["join_overlay"] = join_overlay
	new_user["display_username"] = display_username
	new_user["level"] = 0
	new_user["level_experience"] = 0.0
	users.append(new_user)
	
func update_user(username: String, color, join_overlay: bool, display_username, level: int=-1, experience: float=-1.0):
	for u in users:
		if u["username"] == username:
			if color:
				u["color"] = color
			if join_overlay:
				u["join_overlay"] = join_overlay
			if display_username != null:
				u["display_username"] = display_username
			if level != -1:
				u["level"] = level
			if experience != -1.0:
				u["experience"] = experience
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
