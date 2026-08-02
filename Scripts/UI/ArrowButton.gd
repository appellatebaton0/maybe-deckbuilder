@tool
class_name ArrowButton extends BaseButton

@onready var effect:PulseEffectPolygon2D = $Polygon2D/PulseEffectPolygon2D
@onready var polygon := $Polygon2D


enum STATE {UNSELECTED, SELECTED, PRESSED}
var button_state:STATE
func set_state(to:STATE):
	button_state = to
	
	match to:
		STATE.PRESSED:
			effect.pulse()
		STATE.SELECTED:
			restart_tween()
			
			tween.tween_property(polygon, "color:s", 0.25, 0.2)
			tween.parallel().tween_property(polygon, "position:x", 0.0, 0.1)
			
			if effect.tween and effect.tween.is_running():
				await effect.tween.finished
				
			effect.restart_tween()
		
			effect.tween.tween_property(effect, "self_modulate:a", 0.4, 0.3)
			effect._regen_width(1.4)
			
			
		STATE.UNSELECTED:
			
			effect.self_modulate.a = 0
			
			restart_tween()
			
			tween.tween_property(polygon, "color:s", 0.5, 0.2)
			
			await tween.finished
			restart_tween(create_tween().set_trans(Tween.TRANS_SINE))
			
			tween.tween_property(polygon, "position:x", 3.0, 0.5)
			tween.tween_property(polygon, "position:x", 0.0, 0.5)
			tween.tween_interval(0.4)
			
			tween.set_loops()
func set_state_no_update(to:STATE):
	button_state = to

func update_state():
	var new_state:STATE = button_state
	
	if button_pressed: new_state = STATE.PRESSED
	elif  has_focus(): new_state = STATE.SELECTED
	
	if button_state != new_state:
		set_state(new_state)

var tween:Tween
func restart_tween(override:Tween = null) -> void:
	if tween and tween.is_running(): tween.kill()
	
	tween = create_tween() if not override else override

func _ready() -> void:
	mouse_entered.connect(set_state.bind(STATE.SELECTED))
	mouse_exited .connect(set_state.bind(STATE.UNSELECTED))
	focus_exited .connect(set_state.bind(STATE.UNSELECTED))
	
	set_state(STATE.UNSELECTED)

func _process(_delta: float) -> void: if not Engine.is_editor_hint():
	update_state()
