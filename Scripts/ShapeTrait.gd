@tool
class_name ShapeTrait extends Trait
## Each shape has a trait based on it. This is that trait.

@export var shape:Shape

func _get_name() -> String: return shape.name if shape else name
func _get_color() -> Color: return shape.color if shape else color

func _init(set_shape:Shape = shape) -> void:
	
	shape = set_shape
	
	all_traits     += [self]
