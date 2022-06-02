shader_type canvas_item;

uniform float threshold : hint_range(0.0, 1.0) = 0.75;
uniform vec4 replacement_color : hint_color = vec4(0.98, 0.81, 0.32, 1.0);

void fragment()
{
	vec4 init_color = texture(TEXTURE, UV);
	init_color.rgb = vec3((init_color.r + init_color.g + init_color.b) / 3.0);
	
	if (init_color.r < threshold)
	{
		if (init_color.a == 1.0)
			init_color.rgb = mix(init_color.rgb, replacement_color.rgb, init_color.r);
	}
	else
	{
		init_color.rgb = replacement_color.rgb;
	}
	
	COLOR = init_color;
}
