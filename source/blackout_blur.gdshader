shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float blurAmount = 0.0;
uniform float colorScale = 1.0;

void fragment() {
	vec4 tex = textureLod(SCREEN_TEXTURE, SCREEN_UV, blurAmount);
	COLOR = vec4(tex.r * colorScale, tex.g * colorScale, tex.b * colorScale, 1.0);
}
