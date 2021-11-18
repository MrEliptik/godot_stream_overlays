extends Resource
class_name CredentialsManager


export var user_name : String
export var oauth_token : PoolByteArray

var crypto = Crypto.new()
var key := CryptoKey.new()

var _path := "user://"
var _folder := "secure"
var _appendix := "_cred"
var _file_type := ".res"					#.tres for text format and .res for binary format
var _session_file := "last_session.res"

var credentials : Dictionary


func _init() -> void:
	_load_key(_path.plus_file(_folder))


func _load_key(folder_path : String) -> void:
	#checks if folder with key and certificate exists if not creates it again
	if !folder_path.empty():
		var directory = Directory.new()

		if directory.open(folder_path) == OK:
			directory.list_dir_begin()
			var file_name = directory.get_next()

	#iterating over every file_name found
			while file_name != "":
				if !directory.current_is_dir():
					if file_name.ends_with(".key"):
						key.load(folder_path.plus_file(file_name))

				file_name = directory.get_next()
		else:
			var err = directory.make_dir_recursive(folder_path)
			if err != OK:
				print("Error %i, making folder in : %s" % [err, folder_path])
			else:
				_generate_key(folder_path)


func _generate_key(folder_path : String) -> void:
	# using the example script of Crypto class doc to generate keys

	# Generate new RSA key.
	key = crypto.generate_rsa(4096)
	# Save key and certificate in the user folder.
	key.save(folder_path.plus_file("/generated.key"))


func _encrypt_credentials(data : String) -> PoolByteArray:
	# Encryption
	var encrypted = crypto.encrypt(key, data.to_utf8())
	return encrypted


func _decrypt_credentials(data) -> PoolByteArray:
	# Decryption
	var decrypted = crypto.decrypt(key, data)
	return decrypted


func load_all_credentials() -> void:
	var directory = Directory.new()

	if directory.open(_path) == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()

		while file_name != "":
			if !directory.current_is_dir():
				if file_name.ends_with(str(_appendix+_file_type)):
					var cred = ResourceLoader.load(_path.plus_file(file_name))
					credentials[cred.user_name] = [cred.oauth_token, _path.plus_file(file_name)]
			file_name = directory.get_next()


func save_credentials(user:String, oauth:String) -> void:
	user_name = user
	oauth_token = _encrypt_credentials(oauth)
	ResourceSaver.save(_path.plus_file(user+_appendix+_file_type), self)


func read_credentials(user:String) -> PoolByteArray:
	var data = credentials[user][0]
	return _decrypt_credentials(data)


func remove_credentials(user:String) -> void:
	var directory = Directory.new()
	if user != "":
		directory.remove(credentials[user][1])
		credentials.erase(user)


func load_session() -> bool:
	if !_path.empty() and !_session_file.empty():
		var last_session = ResourceLoader.load(_path.plus_file(_session_file)) as CredentialsManager
		if last_session and !last_session.user_name.empty():
			user_name = last_session.user_name
			return true
	return false


func save_session(user:String) -> void:
	if !_path.empty() and !_session_file.empty():
		user_name = user
		oauth_token = []
		ResourceSaver.save(_path.plus_file(_session_file), self)


func remove_last_session() -> void:
	if !_path.empty() and !_session_file.empty():
		var directory = Directory.new()
		directory.remove(_path.plus_file(_session_file))
