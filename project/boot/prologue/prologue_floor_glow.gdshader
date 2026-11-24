shader_type canvas_item;
render_mode blend_add;
// The floor glow's soft wall edge: the sprite is clipped to the yard rect, so its brightness is cut
// to nothing over `feather_px` of world px from the wall base (edge_y) instead of stopping on a line.

uniform float edge_y = 0.0;
uniform float feather_px = 48.0;

varying float world_y;

void vertex() {
	world_y = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).y;
}

void fragment() {
	float fade = smoothstep(edge_y, edge_y + feather_px, world_y);
	vec4 c = texture(TEXTURE, UV) * COLOR;
	COLOR = vec4(c.rgb * c.a * fade, 1.0);
}
