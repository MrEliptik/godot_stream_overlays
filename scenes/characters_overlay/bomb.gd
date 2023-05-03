extends RigidBody2D

var push_force: float = 7500.0
var push_force_coin: float = 2000.0

var exploding: bool = false

func _ready() -> void:
	pass 

func explode() -> void:
	if exploding: return
	exploding = true
	$MainAnim.play("explode")
	
func explosion_push() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	# Get all the bodies inside the area and push them
	var bodies = $ExplosionArea.get_overlapping_bodies()
	for body in bodies:
		if not body.has_method("push"): continue
		var push_vec = (body.global_position - global_position).normalized() * push_force
		if body.is_in_group("Coins"):
			push_vec = (body.global_position - global_position).normalized() * push_force_coin
		body.push(push_vec)
		
func push(impulse: Vector2) -> void:
	apply_central_impulse(impulse)

func _on_MainAnim_animation_finished(anim_name: String) -> void:
	if anim_name == "explode":
		queue_free()

func _on_Bomb_body_entered(body: Node) -> void:
	explode()
