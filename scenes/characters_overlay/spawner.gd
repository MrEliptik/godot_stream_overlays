extends Node2D

export var bomb: PackedScene = preload("res://scenes/characters_overlay/bomb.tscn")
export var box_coin: PackedScene = preload("res://scenes/characters_overlay/box_coin.tscn")

enum BOX_TYPE {BOMB, COIN}

func _ready() -> void:
	randomize()
#	$Timer.start(rand_range(1, 6))
	$Timer.start(rand_range(50, 600))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("spawn_bomb"):
		spawn_bomb_box(get_global_mouse_position())
	if Input.is_action_just_pressed("spawn_coins"):
		spawn_coin_box(get_global_mouse_position())

func spawn_bomb_box(pos: Vector2) -> void:
	var inst = bomb.instance()
	get_parent().add_child(inst)
	inst.global_position = pos
	inst.rotation_degrees = rand_range(0, 360)
	
func spawn_coin_box(pos: Vector2) -> void:
	var inst = box_coin.instance()
	get_parent().add_child(inst)
	inst.global_position = pos
	inst.rotation_degrees = rand_range(0, 360)

func spawn_random_box(pos=null) -> void:
	var type = randi()%BOX_TYPE.size()
	if pos == null:
		pos = Vector2(rand_range(100, 1500), -150)
	match type:
		BOX_TYPE.BOMB:
			spawn_bomb_box(pos)
		BOX_TYPE.COIN:
			spawn_coin_box(pos)

func _on_Timer_timeout() -> void:
	spawn_random_box()
#	$Timer.start(rand_range(1, 6))
	$Timer.start(rand_range(50, 600))
