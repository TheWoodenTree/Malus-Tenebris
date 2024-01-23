shader_type spatial;

uniform sampler2D noise;


void vertex() {
	float offset = texture(noise, UV * vec2(-0.2, -0.1)).r * UV.x;
	VERTEX.y += offset * 0.5;
}
