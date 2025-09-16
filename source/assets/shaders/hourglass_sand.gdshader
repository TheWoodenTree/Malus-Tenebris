shader_type spatial;

uniform float fill_proportion : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D volume_curve : repeat_disable;
uniform sampler2D albedo_texture;
uniform vec3 albedo_modulate : source_color = vec3(1.0, 1.0, 1.0);
uniform sampler2D normal_texture : hint_normal;
uniform float normal_scale = 1.0;
uniform bool is_top_half = true;

uniform float local_top = 0.246;
uniform float local_bottom = 0.0;

varying vec3 local_position;

void vertex() {
    local_position = VERTEX;
}

void fragment() {
    float local_height = local_position.y;
    float normalized_height = (local_height - local_bottom) / (local_top - local_bottom);
	
    if (is_top_half) {
        if (normalized_height > texture(volume_curve, vec2(fill_proportion, 0.0)).r) {
            discard;
        }
    } else { 
        if (normalized_height > (1.0 - texture(volume_curve, vec2(1.0 - fill_proportion, 0.0)).r)) {
            discard;
        }
    }
    
    vec4 tex_color = textureLod(albedo_texture, UV, 0.0);
	vec3 normal = texture(normal_texture, UV).rgb;
    
    ALBEDO = tex_color.rgb * albedo_modulate.rgb;
	NORMAL_MAP = normal;
	NORMAL_MAP_DEPTH = normal_scale;
}