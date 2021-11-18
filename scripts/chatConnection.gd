extends Control

export(NodePath) onready var connect_btn = get_node(connect_btn) as Button
export(NodePath) onready var connect_cred_btn = get_node(connect_cred_btn) as Button
export(NodePath) onready var connect_cred_del_btn = get_node(connect_cred_del_btn) as Button
export(NodePath) onready var save_session = get_node(save_session) as CheckBox
export(NodePath) onready var save_check = get_node(save_check) as CheckBox
export(NodePath) onready var nick_line = get_node(nick_line) as LineEdit
export(NodePath) onready var oauth = get_node(oauth) as LineEdit


signal connect_pressed(nick_text, auth_text)

var credentials_manager = CredentialsManager.new()

func _ready() -> void:
	credentials_manager.load_all_credentials()
	#preloads the user if a session file exists
	if credentials_manager.load_session():
		nick_line.text = credentials_manager.user_name
		_on_NickLine_text_changed(nick_line.text)


func _on_ConnectBtn_pressed() -> void:
	if save_check.pressed == true:
		credentials_manager.save_credentials(nick_line.text, oauth.text)
	session_check()
	emit_signal("connect_pressed", nick_line.text, oauth.text)


func _on_ConnectCredBtn_pressed() -> void:
	session_check()
	var array = credentials_manager.read_credentials(nick_line.text) as PoolByteArray
	emit_signal("connect_pressed", nick_line.text, array.get_string_from_utf8())


func _on_ConnectDeleteCredBtn_pressed() -> void:
	connect_cred_btn.disabled = true
	connect_cred_del_btn.disabled = true
	connect_cred_del_btn.hide()
	credentials_manager.remove_credentials(nick_line.text)


func _on_AuthLine_text_changed(new_text: String) -> void:
	if new_text == "":
		connect_btn.disabled = true
	else:
		connect_btn.disabled = false


func _on_NickLine_text_changed(new_text: String) -> void:
	if new_text in credentials_manager.credentials:
		connect_cred_btn.disabled = false
		connect_cred_del_btn.disabled = false
		connect_cred_del_btn.show()
	else:
		connect_cred_del_btn.hide()
		connect_cred_btn.disabled = true
		connect_cred_del_btn.disabled = true


func session_check() -> void:
	if save_session.pressed == true:
		credentials_manager.save_session(nick_line.text)
	else:
		credentials_manager.remove_last_session()
