shader_type canvas_item;
// ghost-forms: an ink silhouette (print_part's INK) for GhostRim.keyline: the die-cut line outside
// a light ghost's cream sticker rim, so a pale body holds on the pale kerb.

const vec3 INK = vec3(0.090, 0.075, 0.106);

void fragment() {
	if (COLOR.a < 0.3) discard;
	COLOR = vec4(INK, 1.0);
}
