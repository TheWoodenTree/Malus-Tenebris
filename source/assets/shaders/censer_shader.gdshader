// NOTE: Shader automatically converted from Godot Engine 4.5.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform float smokeHeight : hint_range(0.0, 1.0) = 1.0;
uniform float timeOffset = 0.0;

uniform vec4 albedo : source_color;
uniform sampler2D noise;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;

	// Billboard Mode: Y-Billboard
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			vec4(normalize(cross(vec3(0.0, 1.0, 0.0), MAIN_CAM_INV_VIEW_MATRIX[2].xyz)), 0.0),
			vec4(0.0, 1.0, 0.0, 0.0),
			vec4(normalize(cross(MAIN_CAM_INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
			MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	ALBEDO = albedo.rgb;

	// Scroll UVs upward to make smoke rise
	vec2 scrolledUV = UV;
	scrolledUV.y -= (TIME + timeOffset) * 0.01; // Smoke rises

	// Create wave distortion that increases toward top
	float waveAmount = (1.0 - UV.y) * 0.15;
	float xOffset = sin((TIME + timeOffset) * 3.0 + scrolledUV.y * 16.0) * waveAmount;

	// Apply horizontal wave offset
	scrolledUV.x += xOffset;

	// Calculate alpha based on distance from center using the DISTORTED UV
	float smokeThickness = clamp((1.0 - UV.y) * 0.1, 0.01, 0.1);
	float xCenterDist = abs(scrolledUV.x - 0.5);
	float clampedDist = clamp(xCenterDist, 0.001, smokeThickness);
	float normCenterDist = clampedDist / smokeThickness;
	float heightMultiplier = clamp((UV.y - (1.0 - smokeHeight)) * 0.25, 0.0, 1.0);
	ALPHA = (1.0 - pow(normCenterDist, 2.0)) * heightMultiplier;
}
