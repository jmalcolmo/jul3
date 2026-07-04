class_name Arena
extends Node2D

## Rectangular play field enclosed by static walls, centered on the origin.
## Change `map_size` to resize the arena; the floor, border outline, and
## collision walls are all rebuilt from it on load. Drop-in world boundary:
## the player and enemies must include `wall_layer` in their collision mask.

@export var map_size := Vector2(4000, 4000)
@export var wall_thickness := 80.0
@export var floor_color := Color(0.11, 0.11, 0.14)
@export var border_color := Color(0.35, 0.4, 0.55)
@export var border_width := 6.0
## Physics layer the walls occupy (defaults to layer 5, "walls").
@export_flags_2d_physics var wall_layer := 16


func _ready() -> void:
	_build_floor()
	_build_border()
	_build_walls()


func _corners() -> PackedVector2Array:
	var half := map_size * 0.5
	return PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y),
	])


func _build_floor() -> void:
	var floor_poly := Polygon2D.new()
	floor_poly.color = floor_color
	floor_poly.polygon = _corners()
	floor_poly.z_index = -100
	add_child(floor_poly)


func _build_border() -> void:
	var line := Line2D.new()
	line.closed = true
	line.width = border_width
	line.default_color = border_color
	line.points = _corners()
	line.z_index = -99
	add_child(line)


func _build_walls() -> void:
	var half := map_size * 0.5
	var t := wall_thickness
	# Each entry: [center, size]. Walls overlap at the corners so there is no gap.
	var walls := [
		[Vector2(0.0, -half.y - t * 0.5), Vector2(map_size.x + t * 2.0, t)], # top
		[Vector2(0.0, half.y + t * 0.5), Vector2(map_size.x + t * 2.0, t)],  # bottom
		[Vector2(-half.x - t * 0.5, 0.0), Vector2(t, map_size.y + t * 2.0)], # left
		[Vector2(half.x + t * 0.5, 0.0), Vector2(t, map_size.y + t * 2.0)],  # right
	]
	for entry in walls:
		var body := StaticBody2D.new()
		body.collision_layer = wall_layer
		body.collision_mask = 0
		body.position = entry[0]
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = entry[1]
		shape.shape = rect
		body.add_child(shape)
		add_child(body)
