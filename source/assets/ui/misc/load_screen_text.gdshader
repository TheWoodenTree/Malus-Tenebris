shader_type canvas_item;

void vertex() {
	VERTEX.y = VERTEX.y + 1.5 * floor(sin(UV.x * 12.0 + TIME * 4.0) * 2.0);
	//VERTEX.y = VERTEX.y + sin(UV.x * 12.0 + TIME * 4.0) * 10.0;
}
