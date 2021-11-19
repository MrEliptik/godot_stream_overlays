extends Control

var chat = null

onready var gift = $Gift

func _ready() -> void:
	pass

func bot_test(cmd_info : CommandInfo) -> void:
	print(cmd_info)
	gift.chat("TEST OK!: " + cmd_info.sender_data.user)
	
func _on_Gift_chat_message(sender_data, message) -> void:
	print(sender_data.user + ": "+ message)

func _on_ChatConnection_connect_pressed(nick_text, auth_text) -> void:
	gift.connect_to_twitch()
	yield(gift, "twitch_connected")
	print("CONNECTED!")
	gift.authenticate_oauth(nick_text, auth_text)
	if(yield(gift, "login_attempt") == false):
		print("Invalid username or token.")
		return
	print("AUTHENTICATED")
	
	gift.join_channel("mreliptik")
	gift.add_command("test", self, "bot_test")
