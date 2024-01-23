shader_type canvas_item;

uniform float alpha = 1.0;

uniform vec4 vigColor : source_color;
uniform float vigMultiplier = 0.2;
uniform float vigMultiplierOffset = 0.75;
uniform float vigSoftness = 3;

uniform sampler2D noise;

uniform float darkestThreshold = 0.06;
uniform float darkThreshold = 0.125;
uniform float lightThreshold = 0.175;
uniform float lighterThreshold = 0.8;

uniform float contrast;

uniform vec4 darkestColor : source_color = vec4(0.078, 0.024, 0.059, 1.0);
uniform vec4 darkColor : source_color = vec4(0.243, 0.067, 0.067, 1.0);
uniform vec4 lightColor : source_color = vec4(0.431, 0.145, 0.078, 1.0);
uniform vec4 lighterColor : source_color = vec4(0.639, 0.235, 0.047, 1.0);
uniform vec4 lightestColor : source_color = vec4(0.812, 0.518, 0.294, 1.0);


bool rgb_less_than(vec3 color, float threshold)
{
	bool smaller;
	if (color.r >= threshold)
		smaller = false;
	else if (color.g >= threshold)
		smaller = false;
	else if (color.b >= threshold)
		smaller = false;
	else
		smaller = true;
	return smaller;
}


vec4 retroColor(vec3 textCol)
{
	vec4 darkest = darkestColor;// * hueShift;
	vec4 dark = darkColor;// * hueShift;
	vec4 light = lightColor;// * hueShift;
	vec4 lighter = lighterColor;// * hueShift;
	vec4 lightest = lightestColor;// * hueShift;
	
	if (rgb_less_than(textCol, darkestThreshold))
		return darkest;
	else if (rgb_less_than(textCol, darkThreshold))
		return dark;
	else if (rgb_less_than(textCol, lightThreshold))
		return light;
	else if (rgb_less_than(textCol, lighterThreshold))
		return lighter;
	else
		return lightest;
}


void fragment() {
	vec4 noiseTex = texture(noise, UV + TIME);
	float val = distance(UV, vec2(0.5));
	vec4 test = texture(TEXTURE, UV);//* (sin(TIME * 0.5) + 1.0) / 8.0 + 0.75
	test.rgb *= smoothstep(vigMultiplier * (sin(TIME * 1.0) + 1.0) / 8.0 + vigMultiplierOffset, vigSoftness, val);
	//COLOR = test;//vec4(test.rgb, smoothstep(vigMultiplier, vigSoftness, val));
	
	vec3 textCol = test.rgb;
	
	vec4 darkest = darkestColor;// * hueShift;
	vec4 dark = darkColor;// * hueShift;
	vec4 light = lightColor;// * hueShift;
	vec4 lighter = lighterColor;// * hueShift;
	vec4 lightest = lightestColor;// * hueShift;
	
	vec4 filteredCol;
	
	if (rgb_less_than(textCol, darkestThreshold))
		filteredCol = darkestColor;
	else if (rgb_less_than(textCol, darkThreshold))
		filteredCol = darkColor;
	else if (rgb_less_than(textCol, lightThreshold))
		filteredCol = lightColor;
	else if (rgb_less_than(textCol, lighterThreshold))
		filteredCol = lighterColor;
	else
		filteredCol = lightestColor;
		
	filteredCol.a = alpha;
	COLOR = filteredCol;
}
