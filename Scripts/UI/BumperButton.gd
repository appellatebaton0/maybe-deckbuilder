@tool
class_name BumperButton extends FancyButton

@onready var bump := $Polygon2D
@onready var body := $Polygon2D2
@onready var pulse_effect := $Polygon2D/PulseEffectPolygon2D

func _state_changed(to:STATE) -> void:
	match to:
		STATE.SELECTED:
			restart_tween().set_parallel() 
			tween.tween_property(bump, "position:x", -35, 0.1)
			#tween.tween_property(body, "scale:x", 1.05, 0.1)
		STATE.UNSELECTED:
			restart_tween().set_parallel() 
			tween.tween_property(bump, "position:x", -27, 0.1)
			#tween.tween_property(body, "scale:x", 1.0, 0.1)
		STATE.PRESSED:
			pulse_effect.pulse()
			restart_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).set_parallel()
			#tween.tween_property(body, "scale:x", 0.95, 0.1)
			tween.tween_property(bump, "position:x", -24, 0.1)
			#tween.tween_property(bump, "position:x", -27, 0.1)
