@tool 
class_name RegularPolygon extends Polygon2D
## Provides tools for making a regular polygon, with several available modifications

@export var code:String
@export_tool_button("Load Code") var load_code := func(): create_from_code(code)

@export_tool_button("Regenerate") var regen_button := generate

@export_group("Outer", "outer_")
## The number of points on this polygon.
@export_range(3,500,1.0) var outer_vertices := 3:
	set(to):
		outer_vertices = to
		generate()
		_generate_code()

@export var outer_radius := 0.0: ## The outer radius of this polygon.
	set(to):
		outer_radius = to
		generate()
		_generate_code()
@export var outer_radius_modifiers:Dictionary[int, float]: ## Any modifiers to the radius. Formatted as [every n points], [radius modification]
	set(to):
		outer_radius_modifiers = to
		generate()
		_generate_code()

@export_group("Inner", "inner_")
## The number of points on this polygon.
@export_range(3,500,1.0) var inner_vertices := 3:
	set(to):
		inner_vertices = to
		generate()
		_generate_code()

@export var inner_radius := 0.0: ## The inner radius of this polygon. If <=0, is not hollow.
	set(to):
		inner_radius = to
		generate()
		_generate_code()
@export var inner_radius_modifiers:Dictionary[int, float]: ## Any modifiers to the radius. Formatted as [every n points], [radius modification]
	set(to):
		inner_radius_modifiers = to
		generate()
		_generate_code()

func _generate_code() -> String: 
	
	## Not gonna bother making this encoded at ALL. Literally just text, pretty much.
	var new_code:String = str(outer_vertices) + ":" + str(outer_radius) + ":"
	
	for key in outer_radius_modifiers:
		new_code += str(key) + "," + str(outer_radius_modifiers[key]) + "|"
	
	new_code += "-" + str(inner_vertices) + ":" + str(inner_radius) + ":"
	
	for key in inner_radius_modifiers:
		new_code += str(key) + "," + str(inner_radius_modifiers[key]) + "|"
	
	code = new_code
	
	return new_code
func create_from_code(use_code:String) -> void: 
	print("USING ", use_code)
	
	var to_be_set := ["outer_vertices", "outer_radius", "inner_vertices", "inner_radius"]
	var in_outer := true
	
	var i = 0
	var cache:String = ""
	while i < use_code.length():
		
		var character := use_code[i]
		
		print(cache, " / ", character)
		
		match character:
			":":
				var write_property:String = to_be_set.pop_front()
				set(write_property, float(cache))
				
				cache = ""
			"|":
				var split := cache.split(",")
				
				var modulo:int = int(split[0])
				var amount:float = float(split[1])
				
				(outer_radius_modifiers if in_outer else inner_radius_modifiers)[modulo] = amount
				cache = ""
			"-":
				in_outer = false
				cache = ""
			_:
				cache += character
		
		i+=1
	
	code = use_code
	
	
	

func _init(use_code:String = "") -> void:
	if use_code != "": create_from_code(use_code)

func generate():
	
	# The inner radius has to be (0 <= inner radius < outer_radius)
	if inner_radius < 0 or inner_radius >= outer_radius: return
	
	var new_points:Array[Vector2]
	
	if inner_radius <= 0: 
		# No inner polygon, just make the new points the outer points.
		new_points = make_points_for(outer_radius, outer_vertices, outer_radius_modifiers)
	else:
		var outer_points:Array[Vector2] = make_points_for(outer_radius, outer_vertices, outer_radius_modifiers)
		var inner_points:Array[Vector2] = make_points_for(inner_radius, inner_vertices, inner_radius_modifiers)
		
		# Put each array's first array at the end as well. [0,1,2] -> [0,1,2,0]
		outer_points.append(outer_points.front())
		inner_points.append(inner_points.front())
		
		inner_points.reverse()
		
		# The new polygon is just the two arrays added together
		new_points = outer_points + inner_points
	
	# Update the polygon.
	set("polygon", new_points)

func make_points_for(radius:float, vertices:int, modifiers:Dictionary[int, float]) -> Array[Vector2]:
	var points:Array[Vector2]
	
	# For each vertice.
	for i in vertices:
			# Get the angle of this point
			var angle := deg_to_rad((360.0 / vertices) * i)
			
			# Stored in a seperate variable so the modifiers don't affect the radius.
			var distance := radius
			
			# Apply Modulo Modifiers.
			for modifier in modifiers:              # Check for each modifier,
				if i % modifier == 0:               # If the remainder is 0,
					distance += modifiers[modifier] # Apply the modifier.
			
			# Create the point and add it to the new array.
			var new_point := Vector2.from_angle(angle) * distance
			points.append(new_point)
	
	return points
