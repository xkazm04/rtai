// ghost-forms: a speaking ghost's apparition (GhostApparition). Every part of the ghost's own rig
// copy draws through this material instead of the print: the part's ink stays a deep teal, its
// paper and steel go pale teal, so the ghost reads as the same body made of soul light. Rim parts
// (`silhouette` = 1, the cream sticker rims) print as a flat pale-teal glow edge. Faint scan bands
// (the voice as radio static) drift with `band_phase`. Alpha comes from the node's modulate.
// (Per part, not a CanvasGroup: the rigs' parts carry their own z_index, which escapes a group.)
shader_type canvas_item;
render_mode unshaded;

#include "res://features/souls/ghost_voice.gdshaderinc"

uniform float silhouette = 0.0;
uniform float band_phase = 0.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	vec3 rgb = mix(voice_colour(c.rgb), hi, silhouette);
	float a = c.a * mix(1.0, 0.55, silhouette);
	float phase = voice_phase >= 0.0 ? voice_phase : band_phase;
	COLOR = vec4(rgb, a * voice_band(SCREEN_UV.y, phase));
}
