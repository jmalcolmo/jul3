class_name XpPickup
extends Area2D

## Dropped XP gem. Collected on contact with the player. Once the player's
## pickup radius reaches it (see Player.PickupArea), `attract_to` is called and
## the gem homes toward the player until collected.

@export var xp_value := 4
## Speed (px/sec) the gem flies toward the player once within pickup range.
@export var attract_speed := 340.0

var _target: Node2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if is_instance_valid(_target):
		global_position = global_position.move_toward(_target.global_position, attract_speed * delta)


## Begin homing toward `target`. Called by the player's pickup radius area.
func attract_to(target: Node2D) -> void:
	_target = target


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("gain_xp"):
		body.gain_xp(xp_value)
		queue_free()
