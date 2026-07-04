class_name CameraRig
extends Camera2D

## Follow camera with mouse-wheel zoom: scroll up to zoom in, down to zoom out.
## Zoom eases toward a target value for a smooth feel and is clamped between
## `zoom_min` and `zoom_max`. Higher zoom = closer view.

@export var zoom_min := 0.5
@export var zoom_max := 3.0
## Zoom change applied per wheel notch.
@export var zoom_step := 0.1
## How quickly the current zoom eases toward the target (higher = snappier).
@export var zoom_speed := 12.0

var _target_zoom := 1.0


func _ready() -> void:
	_target_zoom = zoom.x


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = clampf(_target_zoom + zoom_step, zoom_min, zoom_max)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = clampf(_target_zoom - zoom_step, zoom_min, zoom_max)


func _process(delta: float) -> void:
	var t := clampf(zoom_speed * delta, 0.0, 1.0)
	var z := lerpf(zoom.x, _target_zoom, t)
	zoom = Vector2(z, z)
