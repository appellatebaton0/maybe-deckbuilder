class_name CardTraitCategory extends Resource
## A resource that stores the trait of a Card.

## All the currently-existing categories.
static var all_categories:Array[CardTraitCategory]
## All the currently-existing traits.
static var all_traits:Array[CardTrait]
## Create a bunch of categories with the given information for each packed into a dictionary.
## With the intent that the traits will all be initialized by one big const dictionary when the
## game starts, via some autoload.
static func bulk_create_categories(dataset:Array[Dictionary]) -> Array[CardTraitCategory]:
	
	var response:Array[CardTraitCategory] = []
	
	for item in dataset:
		if not (item.has("name") and item.has("color") and item.has("traits")): continue
		
		var new_name   := item["name"] as String
		var new_color  := item["color"] as Color
		var new_traits := item["traits"] as Dictionary[String, Color]
		
		response += [CardTraitCategory.new(new_name, new_color, new_traits)]
	
	return response

## These don't need to be functions, but I'm making them in case I need to 
## change how this comparison works in the future.
## Whether two categories are the same.
static func compare_categories(a:CardTraitCategory, b:CardTraitCategory): return a.name == b.name
## Whether two traits are the same.
static func compare_traits(a:CardTrait, b:CardTrait): return a.name == b.name

## The name of the category
var name:String
## The color of the category
var color:Color
## The traits belonging to this category.
var traits:Array[CardTrait]

class CardTrait:
	## The name of the trait
	var name:String
	## The color of the trait
	var color:Color
	## The category this trait belongs to.
	var category:CardTraitCategory
	
	func _init(set_name:String, set_color:Color, set_category:CardTraitCategory):
		name  = set_name
		color = set_color
		category = set_category

func _init(new_name:String, new_color:Color, new_traits:Dictionary[String, Color] = {}) -> void:
	
	name  = new_name
	color = new_color
	
	for key in new_traits:
		traits += [CardTrait.new(key, new_traits[key], self)]
	
	all_categories += [self]
	all_traits     += traits
