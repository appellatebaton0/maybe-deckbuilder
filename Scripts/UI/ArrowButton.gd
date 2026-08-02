class_name ArrowButton extends Polygon2D

var tween:Tween
func restart_tween(override:Tween = null) -> void:
	if tween and tween.is_running(): tween.kill()
	
	tween = create_tween() if not override else override
