shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform bool is_wet = false;
uniform float most_wetness_height = 0.25;
uniform float least_wetness_height = 0.5;
uniform vec4 water_color: source_color;
uniform sampler2D roughness_map;
uniform sampler2D displace_map;
varying vec3 uv1_triplanar_pos;
uniform float uv1_blend_sharpness;
varying vec3 uv1_power_normal;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


void vertex() {
	vec3 normal = MODEL_NORMAL_MATRIX * NORMAL;
	TANGENT = vec3(0.0, 0.0, -1.0) * abs(normal.x);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.y);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.z);
	TANGENT = inverse(MODEL_NORMAL_MATRIX) * normalize(TANGENT);
	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(normal.x);
	BINORMAL += vec3(0.0, 0.0, -1.0) * abs(normal.y);
	BINORMAL += vec3(0.0, 1.0, 0.0) * abs(normal.z);
	BINORMAL = inverse(MODEL_NORMAL_MATRIX) * normalize(BINORMAL);
	uv1_power_normal = pow(abs(normal), vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0f)).xyz * uv1_scale + uv1_offset;
	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}


vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}


void fragment() {
	float displace_height = 1.0;
	if (is_wet) {
		displace_height = triplanar_texture(displace_map, uv1_power_normal, uv1_triplanar_pos).r;
		bool is_pixel_wet = displace_height < least_wetness_height;
		if (is_pixel_wet) {
			displace_height = (displace_height - most_wetness_height) / (least_wetness_height - most_wetness_height);
			displace_height = pow(displace_height, 3.0);
		}
		else {
			displace_height = 1.0;
		}
	}
	float roughness = dot(triplanar_texture(roughness_map, uv1_power_normal, uv1_triplanar_pos), vec4(0.0));
	ALBEDO = water_color.rgb;
	ROUGHNESS = displace_height;
	METALLIC = displace_height;
	ALPHA = 1.0 - displace_height;
}