@tool
class_name PulseEffectPolygon2D extends Polygon2D
## Creates a pulse-fade effect for a source polygon.

@export var pulse_length := 0.5
@export var pulse_width := 2.7
var _current_width := 0.0

@export_tool_button("Test Pulse") var test_pulse = pulse
@export_tool_button("Inherit Source") var inherit_source = func():
	set_source_polygon(polygon)
@export_tool_button("Show Source") var show_source = func():
	polygon = _source_polygon

## The polygon the effect is for.
@export_storage var _source_polygon:PackedVector2Array:set = set_source_polygon
func set_source_polygon(new_value:PackedVector2Array):
	_source_polygon = new_value

## Allows for easy runtime creation of the effect for a polygon via PulseEffectPolygon2D.new()
func _init(source_polygon:Polygon2D = null) -> void: if source_polygon != null:
	source_polygon.add_child(self)
	set_source_polygon(source_polygon.polygon)

var tween:Tween
func restart_tween() -> void:
	if tween and tween.is_running(): tween.kill()
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

func pulse():
	restart_tween()
	
	## Does *just a little* lerping for the reset, so it's not as harsh.
	## RESET:
	tween.tween_property(self, "self_modulate:a", 0.0, 0.05)
	tween.parallel().tween_callback(_regen_width.bind(0.0))
	
	tween.tween_callback(func(): self_modulate.a = 1.0)
	
	## Do the actual pulse.
	tween.tween_property(self, "self_modulate:a",    0.0,         pulse_length)
	tween.parallel().tween_method(_regen_width, 0.0, pulse_width, pulse_length)
	

func _regen_width(new_width:float) -> void:
	polygon = Geometry2D.offset_polygon(_source_polygon, new_width)[0]
	_current_width = new_width
