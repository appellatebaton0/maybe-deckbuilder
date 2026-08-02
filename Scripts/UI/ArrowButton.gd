@tool
class_name ArrowButton extends BaseButton

enum STATE {UNSELECTED, SELECTED, PRESSED}
var button_state := STATE.UNSELECTED:
	set(to):
		button_state = to
		
		match to:
			STATE.PRESSED:
				effect.pulse()
		
func set_button_state(to:STATE):
	button_state = to
func update_state():
	var new_state:STATE
	
	if button_pressed: new_state = STATE.PRESSED
	elif  has_focus(): new_state = STATE.SELECTED
	
	if button_state != new_state:
		button_state = new_state

@onready var effect:PulseEffectPolygon2D = $PulseEffectPolygon2D

var tween:Tween
func restart_tween(override:Tween = null) -> void:
	if tween and tween.is_running(): tween.kill()
	
	tween = create_tween() if not override else override

func _ready() -> void:
	
	mouse_entered.connect(func(): button_state = STATE.SELECTED)
	mouse_exited .connect(func(): button_state = STATE.UNSELECTED)
	focus_exited .connect(func(): button_state = STATE.UNSELECTED)

func _process(_delta: float) -> void:
	update_state()
