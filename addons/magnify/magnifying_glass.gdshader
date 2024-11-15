shader_type canvas_item;

uniform float zoom;
uniform float alpha;
uniform vec2 offset;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void fragment()
{
	if (zoom < 1.01)
		discard;
	
	vec2 tiling = vec2(1.0 / zoom, 1.0 / zoom);
	vec2 uv = SCREEN_UV * tiling;
	uv += offset * (vec2(1, 1) - tiling);
	
	vec4 color = texture(screen_texture, uv);
	color.a = alpha;
	COLOR = color;
}