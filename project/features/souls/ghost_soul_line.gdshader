shader_type canvas_item;
// n15 hero: a drawn ghost's figure as one flat soul-teal silhouette (GhostSoulLine): eight copies
// nudged round the figure, under it, make the outline.

uniform vec4 line : source_color = vec4(0.18, 0.80, 0.76, 0.6);

void fragment() {
	float a = texture(TEXTURE, UV).a;
	COLOR = vec4(line.rgb, line.a * smoothstep(0.15, 0.6, a));
}
