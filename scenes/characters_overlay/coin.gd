extends RigidBody2D

export var bronze: StreamTexture = preload("res://visuals/objects/coins/coin_bronze.png")
export var silver: StreamTexture = preload("res://visuals/objects/coins/coin_silver.png")
export var gold: StreamTexture = preload("res://visuals/objects/coins/coin_gold.png")
export var diamond: StreamTexture = preload("res://visuals/objects/coins/coin_diamond.png")

var value: float = 100.0
var type

enum COIN_TYPE {BRONZE, SILVER, GOLD, DIAMOND}

var type_values = {
	COIN_TYPE.BRONZE: {"image": bronze, "value": 100.0},
	COIN_TYPE.SILVER: {"image": silver, "value": 250.0},
	COIN_TYPE.GOLD: {"image": gold, "value": 500.0},
	COIN_TYPE.DIAMOND: {"image": diamond, "value": 1000.0}
}

func _ready() -> void:
	randomize()
	choose_value()
	
func choose_value() -> void:
#	type = randi()%COIN_TYPE.size()
	var rand = randf()
	if rand < 0.5:
		type = COIN_TYPE.BRONZE
	elif rand >= 0.5 and rand < 0.8:
		type = COIN_TYPE.SILVER
	elif rand >= 0.8 and rand < 0.95:
		type = COIN_TYPE.GOLD
	elif rand >= 0.95:
		type = COIN_TYPE.DIAMOND
		 
	$Sprite.texture = type_values[type]["image"]
	value = type_values[type]["value"]
	
func push(impulse: Vector2) -> void:
	apply_central_impulse(impulse)

func _on_Coin_body_entered(body: Node) -> void:
	if not body.is_in_group("Characters"): return
	body.add_xp(type_values[type]["value"])
	queue_free()
