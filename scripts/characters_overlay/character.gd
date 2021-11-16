extends KinematicBody2D

var gravity := 200.0
var speed = 1500.0
var velocity := Vector2.ZERO
var username: String = ""

enum direction {
	RIGHT,
	LEFT,
	NONE
}

var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.ZERO]

func _ready() -> void:
	randomize()
	set_random_color()
	
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
func set_random_color():
	$Polygon2D.color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))

func set_username(username):
	$Username.text = username
	self.username = username

func _on_Timer_timeout() -> void:
	$Timer.start(rand_range(4, 10))
	var new_dir = directions[int(rand_range(0, directions.size()))]
	print(new_dir)
	if new_dir != Vector2.ZERO: 
		$AnimationPlayer.play("move")
	else:
		$AnimationPlayer.play("idle")
	velocity.x = new_dir.x * speed
