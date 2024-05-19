shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_factor : hint_range(0.0, 1.0) = 0.5;
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void vertex() {
}

void fragment() {
	vec4 main_texture = texture(TEXTURE, UV);
	vec4 final_output = main_texture;
	
	float original_modulation = 1.0 - tint_factor;
	final_output.rgb = mix(main_texture.rgb * original_modulation, color.rgb * tint_factor, tint_factor);
	final_output.a *= fade;
	COLOR = final_output;
}
