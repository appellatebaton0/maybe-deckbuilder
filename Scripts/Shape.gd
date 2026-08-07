@tool
class_name Shape extends Resource
## A category of shape the player can obtain.

## The name of the shape.
@export var name:String
func plural() -> String:
	return name + ("s" if name.right(1) != "s" else "es")

## The color of the shape.
@export var color:Color

## The traits pertaining to this shape.
@export var _traits:Array[Trait]
func get_traits() -> Array[Trait]:
	
	var shape_trait:ShapeTrait = load(resource_path.replace("Shapes", "Traits"))
	
	return _traits + [shape_trait]
	

## The, well. Shape of the shape. Should fit in a 1x1 square (so it can be scaled later.)
@export var shape:PackedVector2Array
func get_shape(scale := 1.0) -> PackedVector2Array:
	if scale == 1.: return shape.duplicate()
	
	var response := shape.duplicate()
	
	for i in response.size(): response[i] *= scale
	
	return response

## How many coins [x] of this shape is worth. I.e, the possible trades that can
## be made from this shape to coins.
@export var transaction_values:Dictionary[int, int]

## Gets the best possible transaction for a given amount of this shape.
## Higher numbers of shapes should always be more, so there's no need to support
## letting the player choose a kind of transaction.
func get_best_transaction(for_amount:int):
	
	var best_amount := -1
	
	for key in transaction_values:
		if for_amount >= key:
			best_amount = max(key, best_amount)
	
	return {
		"expense": best_amount, # How many out of the amount given is spent. 
		"profit": transaction_values[best_amount] # How many coins are gained.
	}
	
	
