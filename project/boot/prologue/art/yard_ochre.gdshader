shader_type canvas_item;
render_mode unshaded, blend_mul;

// Only the warm pigment in the master darkens the printed paper. White passes through
// everything else, including the underlying pen lines, dust and any marks made in play.
uniform float strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 src = COLOR;
	float warm = smoothstep(0.10, 0.38, src.r - src.b) * smoothstep(0.02, 0.13, src.g - src.b);
	vec3 ink = clamp(src.rgb / max(src.r, 0.001), vec3(0.0), vec3(1.0));
	ink.g = max(ink.g, 0.66);
	COLOR = vec4(mix(vec3(1.0), ink, strength * warm * src.a), 1.0);
}
