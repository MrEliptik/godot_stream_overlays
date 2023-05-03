extends KinematicBody2D

var gravity := 5.0
#var speed := 500.0
var speed := 100.0
var jump_force := 500.0
var max_speed := 150.0
var min_speed := 0.0
var velocity := Vector2.ZERO
var username: String = ""
var color: Color
var level: int = 0.0
var experience: float = 0.0
var level_threshold: float = 2000.0

var initial_pos: Vector2

enum direction {
	RIGHT,
	LEFT,
	NONE
}

var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.ZERO]

var avatars = []
var attached_to_mouse: bool = false

onready var username_label = $GridContainer/Username
onready var lvl_label = $GridContainer/Lvl

func _ready() -> void:
	randomize()
	$Message.visible = false
#	set_random_color()
	load_avatars()
	var idx = randi()%avatars.size()
	$BasicAvatar.texture = avatars[idx]
	
func _physics_process(delta: float) -> void:
	if attached_to_mouse:
		global_position = get_global_mouse_position()
		return
	
	if not is_on_floor():
		velocity.y += gravity

	velocity = move_and_slide_with_snap(velocity, Vector2.UP, Vector2.UP, true, 4, deg2rad(60), true)
	
func load_avatars():
	var path = "res://visuals/avatars"
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break # break the while loop when get_next() returns ""
		file_name = file_name.replace('.import', '') # <--- remove the .import
		if file_name.ends_with(".png"):
			avatars.append(ResourceLoader.load(path + "/" + file_name))
	dir.list_dir_end()
	
func reset():
	global_position = initial_pos
	
func say(msg: String):
	$Message.text = msg
	$Message.visible = true
	$Message/MessageTimer.start()
	
func jump():
	velocity.y = -jump_force
	$AnimationPlayer.play("jump")

func set_level(level_val: int) -> void:
	level = level_val
	lvl_label.text = str(level_val)

func set_speed(speed: float):
	speed = clamp(speed, min_speed, max_speed)

func set_color(color: Color):
	$BasicAvatar.modulate = color
	self.color = color

func set_random_color():
	color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))
	$BasicAvatar.modulate = color

func set_username(username):
	username_label.text = username
	self.username = username
	
func set_username_visibility(visibility: bool) -> void:
	$GridContainer.visible = visibility

func add_xp(value) -> void:
	experience += value
	if experience > (level+1) * level_threshold:
		level += 1
		set_level(level)
		jump()
	Globals.users.update_user(username, null, true, $GridContainer.visible, level, experience)
	Globals.users.save_users()

func push(impulse: Vector2) -> void:
	velocity += impulse * 0.1

func _on_Timer_timeout() -> void:
	$Timer.start(rand_range(4, 10))
	var new_dir = directions[int(rand_range(0, directions.size()))]
	if new_dir != Vector2.ZERO: 
		$AnimationPlayer.play("move")
	else:
		$AnimationPlayer.play("idle")
	velocity.x = new_dir.x * speed

func _on_MessageTimer_timeout() -> void:
	$Message.visible = false

func _on_VisibilityNotifier2D_viewport_exited(viewport: Viewport) -> void:
	reset()

func _on_PickingArea_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != BUTTON_LEFT: return
	attached_to_mouse = event.is_pressed()
