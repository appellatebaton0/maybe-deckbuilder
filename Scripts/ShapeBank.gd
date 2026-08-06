class_name ShapeBank extends Resource
## Stores and manages the ins-and-outs of shapes.

signal added_shape   (shape:Shape, amount:int)
signal removed_shape (shape:Shape, amount:int)
signal changed_amount(shape:Shape, amount:int)

const SHAPE_PATH := "res://Assets/Resources/Shapes/"

#region Statics

## Stores the shapes to stop having to load them all every time they're asked for.
## This can safely be used in place of get_shapes within this class, since for an
## instance of ShapeBank to exist, _shapes has to be initializes.
static var _shapes:Array[Shape]
## Used to safely + easily get all the types of shape in the game.
static func get_shapes() -> Array[Shape]:
	if _shapes.size() > 0: return _shapes
	
	## Load the shapes into the _shapes array.
	
	var dir := DirAccess.open(SHAPE_PATH)
	var results:Array[Shape]
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				
				var file := load(SHAPE_PATH + file_name)
				
				if file is Shape: results.append(file)
				
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	_shapes = results
	return results

func _init() -> void:
	## Initialize the shapes.
	if _shapes.size() <= 0: get_shapes()

#endregion

## The amount of each shape.
var _contents:Dictionary[Shape, int]

## And then we push out some functions for reading/writing the contents w/o direct access.
func get_contents() -> Dictionary[Shape, int]: return _contents.duplicate()

func add_shape(shape:Shape, amount:int) -> void:
	
	if amount < 0: # No negative numbers -> remove instead.
		remove_shape(shape, abs(amount))
		return
	
	if not _contents.has(shape):
		_contents[shape] = amount
		return
	
	_contents[shape] = max(_contents[shape] + amount, 0)
	
	added_shape   .emit(shape, amount)
	changed_amount.emit(shape, amount)

func remove_shape(shape:Shape, amount:int) -> void:
	
	if amount < 0: # No negative numbers -> add instead.
		add_shape(shape, abs(amount))
		return
	
	if not _contents.has(shape):
		_contents[shape] = 0
		return
	
	# Make sure the change won't make it negative.
	amount = mini(amount, _contents[shape])
	
	_contents[shape] -= amount
	
	removed_shape .emit(shape, amount)
	changed_amount.emit(shape, amount)

## Get the max number of coins that could be gained from the bank.
## Specify a shape to get the value just for that shape. 
func get_worth(shape:Shape = null) -> int:
	
	if shape != null: return shape.get_best_transaction(_contents[shape])
	
	var total := 0
	
	for item in _contents:
		total += item.get_best_transaction(_contents[item])
	
	return total
