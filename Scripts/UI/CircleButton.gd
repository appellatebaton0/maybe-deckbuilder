@tool
class_name CircleButton extends FancyButton

@onready var outer_polygon:RegularPolygon = $CircleButton
@onready var pulse_effect:PulseEffectPolygon2D = $CircleButton/PulseEffectPolygon2D

func _state_changed(to:STATE) -> void:
	
	match to:
		STATE.SELECTED:
			if has_focus(): return
			
			restart_tween().set_parallel()
			
			tween.tween_method(func(a):
				outer_polygon.outer_radius_modifiers = {2: a}
				pulse_effect.set_source_polygon(outer_polygon.polygon)
				, outer_polygon.outer_radius_modifiers[2], 3.5, 0.3)
			tween.tween_property(outer_polygon, "rotation_degrees", outer_polygon.rotation_degrees + 30, 0.3)
		STATE.UNSELECTED:
			if has_focus(): return
			
			restart_tween().set_parallel()
			
			
			tween.tween_method(func(a):
				outer_polygon.outer_radius_modifiers = {2: a}
				pulse_effect.set_source_polygon(outer_polygon.polygon)
				, outer_polygon.outer_radius_modifiers[2], 0.0, 0.3)
			tween.parallel().tween_property(outer_polygon, "rotation_degrees", outer_polygon.rotation_degrees + 30, 0.3)
		
			await tween.finished
		
		STATE.PRESSED:
			
			#pulse_effect.set_source_polygon(outer_polygon.polygon)
			pulse_effect.pulse()
		
		pass
