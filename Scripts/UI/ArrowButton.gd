@tool
class_name ArrowButton extends FancyButton

@onready var effect:PulseEffectPolygon2D = $Polygon2D/PulseEffectPolygon2D
@onready var polygon := $Polygon2D

func _state_changed(to:STATE):
	
	print(to)
	match to:
		STATE.PRESSED:
			effect.pulse()
		STATE.SELECTED:
			restart_tween()
			
			tween.tween_property(polygon, "color:s", 0.25, 0.2)
			tween.parallel().tween_property(polygon, "position:x", 0.0, 0.1)
			
			if effect.tween and effect.tween.is_running() and effect.tween.get_loops_left() != -1:
				print("waiting. ", effect.tween.get_loops_left())
				await effect.tween.finished
				print("finished")
			
			effect.restart_tween()
			
			print("tweening in modulate.")
		
			effect.tween.tween_property(effect, "self_modulate:a", 0.4, 0.3)
			effect._regen_width(1.4)
			
			
		STATE.UNSELECTED:
			
			print("canceling")
			
			effect.kill_tween()
			effect.self_modulate.a = 0
			
			restart_tween()
			
			tween.tween_property(polygon, "color:s", 0.5, 0.2)
			
			await tween.finished
			restart_tween(create_tween().set_trans(Tween.TRANS_SINE))
			
			tween.tween_property(polygon, "position:x", 3.0, 0.5)
			tween.tween_property(polygon, "position:x", 0.0, 0.5)
			tween.tween_interval(0.4)
			
			tween.set_loops()
