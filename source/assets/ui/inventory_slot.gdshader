shader_type canvas_item;

uniform int num_slots = 3;

varying vec2 world_pos;


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0, 1.0)).xy;
}

void fragment() {
	if (world_pos.x < (254.0 - (36.0 * float(num_slots))) || world_pos.x > (258.0 + (36.0 * float(num_slots)))) {
		COLOR.a = 0.0;
	}
}