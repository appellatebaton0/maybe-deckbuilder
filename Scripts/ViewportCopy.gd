class_name ViewportCopy extends SubViewport
## Copies a source SubViewport to this SubViewport.

@export var source:SubViewport
func _ready() -> void: world_2d = source.world_2d
