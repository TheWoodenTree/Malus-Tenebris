shader_type canvas_item;

uniform float alpha_mult = 0.0;

void vertex() {
	VERTEX.y += (sin(TIME * 4.0) * 5.0);
}

void fragment() {
	//COLOR.a -= (sin(TIME * 5.0) * 0.25) + 0.25;
	COLOR.a *= alpha_mult;
}