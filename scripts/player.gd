class_name Player
extends CharacterBody2D

signal health_changed(current: float, max_hp: float)
signal xp_changed(xp: int, xp_required: int)
signal leveled_up(new_level: int)
signal died

@export var stats: PlayerStats

var hp: float
var level: int = 1
var xp: int = 0

var _dead := false

@onready var weapon: Weapon = $Weapon
@onready var pickup_area: Area2D = $PickupArea
@onready var _pickup_shape: CollisionShape2D = $PickupArea/CollisionShape2D


func _ready() -> void:
	if stats == null:
		stats = PlayerStats.new()
	hp = stats.max_hp
	weapon.stats = stats
	pickup_area.area_entered.connect(_on_pickup_area_entered)
	update_pickup_radius()
	health_changed.emit(hp, stats.max_hp)
	xp_changed.emit(xp, xp_required())


## Resizes the pickup-radius area to match `stats.pickup_radius`. Call after
## an upgrade changes the radius so the new value takes effect immediately.
func update_pickup_radius() -> void:
	var circle := _pickup_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = stats.pickup_radius


func _on_pickup_area_entered(area: Area2D) -> void:
	if area is XpPickup:
		area.attract_to(self)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * stats.move_speed
	move_and_slide()

	if stats.hp_regen > 0.0 and hp < stats.max_hp and not _dead:
		hp = minf(hp + stats.hp_regen * delta, stats.max_hp)
		health_changed.emit(hp, stats.max_hp)


func take_damage(amount: float) -> void:
	if _dead:
		return
	var final_damage := maxf(amount - stats.armor, 1.0)
	hp -= final_damage
	health_changed.emit(hp, stats.max_hp)
	if hp <= 0.0:
		_dead = true
		died.emit()


func heal(amount: float) -> void:
	hp = minf(hp + amount, stats.max_hp)
	health_changed.emit(hp, stats.max_hp)


func gain_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_required():
		xp -= xp_required()
		level += 1
		leveled_up.emit(level)
	xp_changed.emit(xp, xp_required())


func xp_required() -> int:
	return 10 + level * 5
