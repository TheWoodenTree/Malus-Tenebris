shader_type spatial;

uniform int parent_room_global_rot = 0;
uniform float def_scale = 0.005;
uniform float metallic : hint_range(0.0, 1.0) = 1.0;
uniform float specular : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 speed_scale;
uniform sampler2D noise;

vec2 pan_uv(vec2 uv, float scale) {
	return uv + TIME * scale;
}

void fragment() {
	vec4 noise_text1 = texture(noise, pan_uv(vec2(UV.x, UV.y), def_scale / speed_scale.x));
	vec4 noise_text2 = texture(noise, pan_uv(vec2(UV.x + 0.5, UV.y), -def_scale / speed_scale.x));
	vec4 noise_text3 = texture(noise, pan_uv(vec2(-UV.y, UV.x), def_scale / speed_scale.x));
	vec4 noise_text4 = texture(noise, pan_uv(vec2(-UV.y + 0.5, UV.x), -def_scale / speed_scale.x));
	
	vec4 mixed_noise = noise_text1 * noise_text2 * noise_text3 * noise_text4;
	mixed_noise = pow(mixed_noise, vec4(0.65)) * 100.0;
	
	vec4 final = color + mixed_noise * (color + 0.0);
	ALBEDO = final.rgb;
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
}
