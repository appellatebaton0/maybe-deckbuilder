class_name Trait extends Resource
## A resource that stores the trait of a Card.

## All the currently-existing traits.
static var all_traits:Array[Trait]

## This doesn't need to be a function, but I'm making it in case I need to 
## change how this comparison works in the future.
## Whether two traits are the same.
static func compare_traits(a:Trait, b:Trait): return a.name == b.name

## The name of the trait
@export var name:String:get = _get_name
func _get_name() -> String: return name
## The color of the trait
@export var color:Color:get = _get_color
func _get_color() -> Color: return color

func _init(new_name:String, new_color:Color) -> void:
	
	name  = new_name
	color = new_color
	
	all_traits     += [self]
