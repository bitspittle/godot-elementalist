shader_type canvas_item;

uniform vec3 color_range_start = vec3(0.3, 0.3, 0.3);
uniform vec3 color_range_end = vec3(1.0, 1.0, 1.0);
uniform vec4 color_modulate = vec4(1.0, 0.0, 1.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	if (
		(tex_color.r >= color_range_start.r && tex_color.r <= color_range_end.r) 
	&& (tex_color.g >= color_range_start.g && tex_color.g <= color_range_end.g)
	&& (tex_color.b >= color_range_start.b && tex_color.b <= color_range_end.b)) {
		COLOR = tex_color * color_modulate;
	}
	else {
		COLOR = tex_color
	}
}