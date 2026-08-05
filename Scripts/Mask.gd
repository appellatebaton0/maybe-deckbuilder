@tool
extends Node

@onready var parent := get_parent()

func _process(delta: float) -> void: if parent:
	set("position", parent.get("global_position"))
