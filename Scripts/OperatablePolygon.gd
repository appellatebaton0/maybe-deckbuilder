@tool
class_name OperatablePolygon extends RegularPolygon
## A RegularPolygon with some extra tools for performing Geometry2D Operations.

@export var operation := Geometry2D.PolyBooleanOperation.OPERATION_UNION
@export var with:Polygon2D
@export_tool_button("Operate") var operate := func():
	
	if not with: return
	
	var results := _perform_operation(mass_offset(polygon, global_position), mass_offset(with.polygon, with.global_position))
	
	
	for result in results:
		create_polygon(mass_offset(result, -global_position))
	
	#queue_free()

enum TYPES {TRANSLATE, SCALE, ROTATE}
@export var transformation := TYPES.TRANSLATE
@export var amount:Variant
@export_tool_button("Transform") var trans := func():
	
	var new_polygon:PackedVector2Array = polygon
	
	match transformation:
		TYPES.TRANSLATE:
			if amount is Vector2:
				for i in new_polygon.size():
					new_polygon[i] += amount
		TYPES.SCALE:
			if amount is float:
				for i in new_polygon.size():
					new_polygon[i] *= amount
		TYPES.ROTATE:
			if amount is float:
				for i in new_polygon.size():
					new_polygon[i] = new_polygon[i].rotated(deg_to_rad(amount))
	
	polygon = new_polygon

func mass_offset(a:PackedVector2Array, offset:Vector2) -> PackedVector2Array:
	for i in a.size(): a[i] = a[i] + offset
	return a

## Creates a polygon in this polygon's place with a set of polygons. Copies position, parent, color, etc.
const copy_properties:Array[StringName] = ["global_position", "color"]
func create_polygon(from_polygon:PackedVector2Array) -> Polygon2D:
	
	var new := Polygon2D.new()
	
	new.polygon = from_polygon
	
	add_sibling(new)
	
	# Show up in the scenetree.
	new.owner = owner
	new.scene_file_path = scene_file_path
	new.name = name
	
	for property in copy_properties:
		new.set(property, get(property))
	
	return new

func _perform_operation(a:PackedVector2Array, b:PackedVector2Array, o:Geometry2D.PolyBooleanOperation = operation) -> Array[PackedVector2Array]:
	
	var response:Array[PackedVector2Array]
	
	const operation_functions:Dictionary[Geometry2D.PolyBooleanOperation, StringName] = {
		Geometry2D.OPERATION_UNION:        &"merge_polygons",
		Geometry2D.OPERATION_INTERSECTION: &"intersect_polygons",
		Geometry2D.OPERATION_XOR:          &"exclude_polygons",
		Geometry2D.OPERATION_DIFFERENCE:   &"clip_polygons",
	}
	
	print(a, " v ", b, " \n-> ", operation_functions[o])
	
	response = Geometry2D.call(operation_functions[o], a, b)
	print(response)
	
	return response
