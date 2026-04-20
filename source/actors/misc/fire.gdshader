shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

uniform sampler2D flipbook_texture;
uniform int cols = 8;
uniform int rows = 8;
uniform float fps = 30.0;
uniform vec4 color : source_color;

void vertex() {
    vec3 scale = vec3(
        length(MODEL_MATRIX[0].xyz),
        length(MODEL_MATRIX[1].xyz),
        length(MODEL_MATRIX[2].xyz)
    );

    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
        vec4(INV_VIEW_MATRIX[0].xyz * scale.x, 0.0),
        vec4(INV_VIEW_MATRIX[1].xyz * scale.y, 0.0),
        vec4(INV_VIEW_MATRIX[2].xyz * scale.z, 0.0),
        MODEL_MATRIX[3]
    );
}

void fragment() {
    float total_frames = float(cols * rows);
    float frame = floor(mod(TIME * fps, total_frames));
    float col = mod(frame, float(cols));
    float row = floor(floor(frame / float(cols)));
    
    vec2 uv = UV / vec2(float(cols), float(rows));
    uv += vec2(col / float(cols), row / float(rows));
    
    vec4 tex = texture(flipbook_texture, uv);
    ALBEDO = tex.rgb * color.rgb * 10.0;
	EMISSION = tex.rgb * color.rgb * 10.0;
    ALPHA = tex.a;
}