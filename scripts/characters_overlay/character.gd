extends KinematicBody2D

var gravity := 200.0
var speed := 600.0
var jump_force := 600.0
var max_speed := 1500.0
var min_speed := 0.0
var velocity := Vector2.ZERO
var username: String = ""
var color: Color

var initial_pos: Vector2

enum direction {
	RIGHT,
	LEFT,
	NONE
}

var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.ZERO]

func _ready() -> void:
	randomize()
	$Message.visible = false
	set_random_color()
	
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
func reset():
	global_position = initial_pos
	
func say(msg: String):
	$Message.text = msg
	$Message.visible = true
	$Message/MessageTimer.start()
	
func jump():
	velocity.y = -jump_force
	$AnimationPlayer.play("jump")
	
func set_speed(speed: float):
	speed = clamp(speed, min_speed, max_speed)
	print(speed)

func set_color(color: Color):
	$BasicAvatar.modulate = color
	self.color = color

func set_random_color():
	color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))
	$BasicAvatar.modulate = color

func set_username(username):
	$Username.text = username
	self.username = username

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
