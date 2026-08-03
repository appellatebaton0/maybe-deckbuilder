shader_type canvas_item;

uniform vec2 multiplier = vec2(384, 288);
uniform float time_scale = 1.0;
uniform vec3 line_color : source_color;

void fragment() {
	
	if (int((UV.x * multiplier.x) + (UV.y * multiplier.y) - (TIME * time_scale)) % 2 == 1)
	{
		COLOR.rgb = line_color;
	}
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
