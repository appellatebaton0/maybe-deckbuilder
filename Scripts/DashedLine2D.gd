@tool
class_name DashedLine2D extends Line2D
## A Line2D with added/replaced functionality to make dotted/dashed lines.

## 'Stole' a bit of my own code from a PixelLine2D script; coulda just used that,
## But I figure we can get more resource-efficient than it was.

# The goal is to allow for specifying a dash length and dash spacing/count, and turn the
# points of a Line2D into a dashed line with those parameters.

## The line is made up of sample points (circles). Set this low to get dotted lines,
## and high for full lines. If it's not high enough, you'll get a LOT of stray pixels.
enum SAMPLE_METHOD {COUNT, DISTANCE}
@export_group("Sampling", "sample_")
@export var sample_method := SAMPLE_METHOD.DISTANCE:
	set(to):
		sample_method = to
		queue_redraw()
@export var sample_count := 15:
	set(to):
		sample_count = maxi(to, 1)
		queue_redraw()
@export var sample_distance := 1.:
	set(to):
		sample_distance = maxf(to, 1.)
		queue_redraw()
@export var sample_length := 1.:
	set(to):
		sample_length = maxf(to, 1.)
		queue_redraw()

## The width of the line. Had to be separate from the Line2D width for *reasons*
@export var line_width := 10.:
	set(to):
		line_width = maxf(to, 0.001)
		queue_redraw()

func _ready() -> void: width = 0. # The aforementioned *reasons*. Gotta hide the original line.

func _draw() -> void:
	
	## Get the point samples, and the bounding rects  
	var sample_set := get_sample_set()
	#var color_set  := get_color_set(sample_set)
	
	for point_set in sample_set:
		
		## Turning the line into a polygon and drawing that,
		## instead of just draw_polyline(point_set, default_color, line_width)
		## This's because draw_polyline doesn't round ends and joins like you can 
		## as seen below, leading to funky stuff at sharp angles. No thanks.
		
		draw_colored_polygon(Geometry2D.offset_polyline(point_set, line_width / 2., Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)[0], default_color)
		
		#for i in point_set.size():
			#var color = Color.WEB_GREEN if i == 0 else Color.AQUA
			#
			#draw_circle(point_set[i], line_width / 2, color)


func get_color_set(for_sample_set:Array[Vector2]) -> Array[Color]:
	
	var result:Array[Color] = []
	var samples := for_sample_set.size()
	
	## There's no gradient, so this is unnecessary. Just use the default color.
	if not gradient:
		for i in samples: result += [default_color]
	else:
		for i in samples:
			var t := i / float(samples)
			
			result += [gradient.sample(t)]
	
	return result

## Get the dashes to be drawn, as an array of sets of points that represent the dashes.
func get_sample_set(sample_dist:float = sample_distance, line_points := points) -> Array[Array]:
	
	var response:Array[Array] = []
	
	var distance := 0.
	var distance_set := get_distance_set()
	var sum_distance := 0.
	for dist in distance_set: sum_distance += dist
	
	if sample_method == SAMPLE_METHOD.COUNT: sample_dist = sum_distance / sample_count
	if sample_dist <= 0: return [] ## The sample_dist equalling 0 == infinite while loop.
	
	while distance < sum_distance:
		var new_set:Array[Vector2] = []
		
		var sample_len := minf(sample_length, sum_distance - distance - 0.01) 
		var distances:Array[float] = [distance, distance + sample_len]
		
		var i := 0
		var b := 0
		while i < distances.size() - 1:
			b+=1 # Failsafe
			if b>100:
				print("D:")
				break
		
			var a_dist := distances[i]
			var b_dist := distances[i+1]
			
			var a_index := index_from_distance(a_dist, distance_set)
			var b_index := index_from_distance(b_dist, distance_set)
			
			i += 1
			
			#if response.size() > 0:
				#print(a_index, " v ", b_index)
				#print(distance, " <-> ", distance + sample_len)
				#print(distance_from_index(b_index, distance_set))
			
			if a_index != b_index:
				var new_dist := distance_from_index(b_index, distance_set)
				if new_dist <= distance + sample_len and new_dist >= distance and not distances.has(new_dist):
					distances.insert(i, new_dist)
					i = 0
				if distances.size() > 100: # failsafe
					break
				
		
		for dist in distances:
			new_set.append(sample_line_d(dist, line_points, distance_set))
		
		response += [new_set]
		
		distance += sample_dist
	
	var last_point := sample_line_d(sum_distance, line_points, distance_set)
	if response.back().has(last_point): response[response.size() - 1].erase(last_point)
	
	return response

## Turns a given distance and a distance into the index of the dist. For example,
## A set of [1.0, 2.0, 3.0, 5.0, 3.0] and a D of 7.0 would return 2, the last element whose
## sum up to its index is less than D.
func index_from_distance(d:float, distance_set:Array[float]) -> int:
	
	var try_distance := 0.0
	
	for i in distance_set.size():
		try_distance += distance_set[i]
		if d <= try_distance: return i
	
	return distance_set.size() - 1
## Turns an index in a distance set to a sum of it and its predecessors, aka the distance
## to the specified point in total, from the set of the distances between points.
func distance_from_index(i:int, distance_set:Array[float]) -> float:
	
	var total := 0.
	
	for j in distance_set.size():
		if j >= i: break
		total += distance_set[j]
	
	return total
	

## Returns an array of floats - the distance from the point in that index to the next point.
## As such, this array is size [for_points.size() - 1]
func get_distance_set(for_points := points) -> Array[float]: 
	
	var result:Array[float] = []

	for i in for_points.size() - 1:
		result += [for_points[i].distance_to(for_points[i + 1])]
	
	return result
## Samples from the line by a D value, ranging from 0.0 to the total length of the line.
## The 'distances' value being a parameter allows for it to be calculated once ahead of time and passed
## When doing a lot of sampling, but it just auto-calculates if not provided.
func sample_line_d(d:float, line_points := points, distances := get_distance_set(line_points)) -> Vector2: 
	
	# Numbers below or at 0 are just the first point.
	if d <= 0: return line_points[0] 
	
	## Ehm... walk along the line by the distance? Pretty straightforwards...
	
	## The length of the line is just the sum of the distances between each point.
	var line_length := 0. 
	for distance in distances: line_length += distance
	
	# Number above or at the line's length are just the last point.
	if d >= line_length: return line_points[line_points.size() - 1] 
	
	var point_index := 0 # Like in sample_line_t, this is the points the point is between.
	
	# Figure out the point index. 
	# If the distance is more than the distance between two points, we know
	# it's not between those two. Subtract the distance between the two points,
	# and move on to the next two points.
	while d > distances[point_index]:
		d -= distances[point_index]
		point_index += 1
	
	# Now we've got our A & B via point_index, and D as the distance between them.
	var a := line_points[point_index]
	var b := line_points[point_index + 1]
	
	# We could do a + a.direction_to(b) * d, but I like this better.
	# Turn D into a T value by dividing it by the dist between the points.
	d /= distances[point_index]
	# Then we're back to just lerp(a,b,t) (or lerp(a,b,d) in this case)
	return lerp(a,b,d)

## Samples from the line by a T value, ranging 0.0 to 1.0.
func sample_line_t(t:float, line_points := points) -> Vector2:
	
	## Sampling from 2 points is just lerp(a,b,t).
	## Sampling from more is just using T to determine
	## which two points to lerp, and what the new T value is.
	
	## A T of 1. makes the index point_size, which makes b invalid.
	## We'll just call it out here, and save a hassle.
	if t == 1.: return line_points[line_points.size() - 1]
	
	## Turn the T into the aforementioned points and new T (T2)
	var point_size := line_points.size() - 1
	var index      := floori(t * point_size)
	var t2         := wrapf(t * point_size, 0.0, 1.)
	
	var a := line_points[index]
	var b := line_points[index + 1]
	
	return lerp(a, b, t2)
 
