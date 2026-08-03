@tool
class_name BumperButton extends FancyButton

@onready var bump := $Polygon2D
@onready var body := $Polygon2D2
@onready var pulse_effect := $Polygon2D/PulseEffectPolygon2D
@onready var pulse_effect2 := $Polygon2D2/PulseEffectPolygon2D

func _state_changed(to:STATE) -> void:
	match to:
		STATE.SELECTED:
			#if tween and tween.is_running(): await tween.finished
			restart_tween()
			tween.tween_property(body, "color:s", 0.5, 0.1)
			
			await tween.finished
			
			restart_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_property(bump, "position:x", -35, 0.3)
			tween.tween_interval(0.1)
			tween.tween_property(bump, "position:x", -30, 0.3)
			tween.tween_interval(0.1)
			
		STATE.UNSELECTED:
			#if tween and tween.is_running(): await tween.finished
			restart_tween().set_parallel() 
			tween.tween_property(bump, "position:x", -27, 0.4)
			tween.tween_property(body, "color:s", 0.3, 0.1)
			#tween.tween_property(body, "scale:x", 1.0, 0.1)
		STATE.PRESSED:
			#pulse_effect.pulse()
			pulse_effect2.pulse()
			restart_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).set_parallel()
			#tween.tween_property(body, "scale:x", 0.95, 0.1)
			tween.tween_property(bump, "position:x", -24, 0.1)
			#tween.tween_property(bump, "position:x", -27, 0.1)1
