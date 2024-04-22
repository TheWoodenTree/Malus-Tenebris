shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise;

void fragment() {
	vec4 noiseTex = texture(noise, UV);
	vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (tex.r < 0.01) {
		COLOR = noiseTex;
	}
}