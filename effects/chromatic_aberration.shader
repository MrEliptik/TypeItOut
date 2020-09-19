shader_type canvas_item;

uniform bool apply = true;
uniform float amount = 0.3;
uniform sampler2D offset_texture : hint_white;

void fragment()
{
	vec4 texture_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
	if (apply) {
		float adjusted_amount = amount * texture(offset_texture, UV).r / 100.0;
		color.r = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + adjusted_amount, SCREEN_UV.y)).r;
		color.g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
		color.b = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - adjusted_amount, SCREEN_UV.y)).b
	}
	else{
		color = texture(SCREEN_TEXTURE, SCREEN_UV)
	}
	COLOR = color;
}