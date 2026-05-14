shader_type canvas_item;

void vertex() {
	VERTEX.y -= (sin(TIME * 5.0) * 2.0) - 2.0;
}

void fragment() {
	COLOR.a -= (sin(TIME * 4.0) * 0.35) + 0.35;
}
