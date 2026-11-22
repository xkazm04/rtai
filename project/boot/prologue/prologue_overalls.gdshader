shader_type canvas_item;

// Preserve the printed folds, skin and outlines of the original facing and stride.
void fragment() {
	vec4 cloth = texture(TEXTURE, UV);
	float blue = smoothstep(0.012, 0.075, cloth.b - cloth.r);
	vec3 drill = vec3(1.35, 1.34, 0.82) * cloth.b;
	COLOR = vec4(mix(cloth.rgb, drill, blue), cloth.a);
}
