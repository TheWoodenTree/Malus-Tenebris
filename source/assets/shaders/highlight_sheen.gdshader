shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform bool enableSheen = false;
uniform float sheenMaxCamDist = 7.5;
uniform sampler2D whiteTex;


void fragment() {
	float newAlpha = 0.0;

	if (enableSheen) {
		// Black magic mask
		float mask = floor(mod(TIME * floor(mod(TIME, 2)), 2));
		vec4 tex = texture(whiteTex, SCREEN_UV + TIME + 0.5) * mask;
		newAlpha = tex.r;
		//newAlpha = sin(2.0 * PI * TIME) / 2.0 + 0.5;
	}
	ALPHA = newAlpha;
}
