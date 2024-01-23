shader_type fog;

uniform sampler2D noise;
uniform float noise_scale = 1.0;

void fog() {
	float noise_x_tex = texture(noise, mod(UVW.xz + TIME * 0.05, 1.0) * noise_scale).x;
	float noise_y_tex = texture(noise, mod(UVW.xy + TIME * 0.05, 1.0) * noise_scale).x;
	float noise_z_tex = texture(noise, mod(UVW.yz + TIME * 0.05, 1.0) * noise_scale).x;
	
	DENSITY = pow(noise_x_tex, 2.0) * pow(noise_y_tex, 2.0) * pow(noise_z_tex, 2.0) * 1.0;
	DENSITY *= step(0.0, -SDF);
	ALBEDO = vec3(1.0, 0.0, 0.0);
}
