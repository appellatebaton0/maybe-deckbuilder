@tool
@abstract class_name FancyButton extends BaseButton
## A fancy button with support for tweening w/ changes in state.

signal state_changed(to:STATE)

enum STATE {UNSELECTED, SELECTED, PRESSED}
var button_state:STATE
func set_state(to:STATE):
	button_state = to
	
	state_changed.emit(to)
	_state_changed(to)
func set_state_no_signal(to:STATE):
	button_state = to

func update_state():
	var new_state:STATE = button_state
	
	if button_pressed: new_state = STATE.PRESSED
	elif  has_focus(): new_state = STATE.SELECTED
	
	if button_state != new_state:
		set_state(new_state)

var tween:Tween
func restart_tween(override:Tween = null) -> Tween:
	if tween and tween.is_running(): tween.kill()
	
	tween = create_tween() if not override else override
	
	return tween

func _ready() -> void:
	mouse_entered.connect(set_state.bind(STATE.SELECTED))
	mouse_exited .connect(set_state.bind(STATE.UNSELECTED))
	focus_exited .connect(set_state.bind(STATE.UNSELECTED))
	
	set_state(STATE.UNSELECTED)

func _process(_delta: float) -> void: if not Engine.is_editor_hint():
	update_state()

@warning_ignore("unused_parameter")
func _state_changed(to:STATE) -> void: pass
