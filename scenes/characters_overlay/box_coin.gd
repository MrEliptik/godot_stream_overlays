extends RigidBody2D

export var coin: PackedScene = preload("res://scenes/characters_overlay/coin.tscn")
export var coin_nb: float = 10.0

var exploded: bool = false

func _ready() -> void:
	randomize()
	coin_nb = randi()%15+1

func explode() -> void:
	if exploded: return
	exploded = true
	for i in range(coin_nb):
		# Make sur its pointing towards the sky
		$RotPoint.rotation -= rotation
		$RotPoint.look_at(Vector2.UP)
		# Get a random rotation from here
		$RotPoint.rotation_degrees = rand_range(-150.0, -20.0)
		
		var inst = coin.instance()
		get_parent().add_child(inst)
		inst.global_position = $RotPoint/Position2D.global_position
		inst.apply_central_impulse($RotPoint/Position2D.global_transform.x * 300.0)

	queue_free()

func push(impulse: Vector2) -> void:
	apply_central_impulse(impulse)
	explode()

func _on_BoxCoin_body_entered(body: Node) -> void:
	if not body.is_in_group("Characters"): return
	explode()
