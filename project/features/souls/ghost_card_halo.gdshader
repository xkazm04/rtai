shader_type canvas_item;
// d8 chars: the soul halo behind a ghost's facing card (GhostCard.halo): the card's silhouette in one
// flat colour (soul teal), its alpha times the halo's, so the possessed body reads at height.

uniform vec4 tint : source_color = vec4(0.18, 0.77, 0.71, 0.5);

void fragment() {
	COLOR = vec4(tint.rgb, texture(TEXTURE, UV).a * tint.a);
}
