shader_type canvas_item;
// D5 "Inked Grime" soul print (proposal for the fx lane): the teal souls of destroyed robots, drawn on the actor
// layer above the world print. Snaps the soul art to the doctrine's two teal inks + the cream sticker rim, with paper
// grain, instead of look_d4_item's ghost dot screen (which dissolves a drawn soul into a mesh at 64 px/m, h21).
// At 32 px/m the snap busies the minified art (+6% fine-detail energy vs the art as drawn), so it rides the D5 tier
// fade like the character overlays (`amount`). Teal belongs to the dead only: nothing here prints any other hue. `fade` = the soul's life (1 fresh, 0 gone).

uniform float fade = 1.0;
uniform float amount = 1.0;    // the print's share over the art as drawn: the D5 tier fade (0 below 56 px/m, 1 at 64)
uniform float ink_at = 0.42;   // luminance below which a pixel prints as the teal ink line
uniform float rim_sat = 0.10;  // saturation below which a light pixel is the cream rim

const vec3 CREAM = vec3(0.949, 0.910, 0.835);
const vec3 TEAL = vec3(0.122, 0.710, 0.659);
const vec3 TEAL_PALE = vec3(0.560, 0.860, 0.815);
const vec3 TEAL_INK = vec3(0.050, 0.360, 0.345);

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	vec4 c = COLOR;
	if (amount > 0.0 && c.a < 0.04) discard;
	float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b));
	// soft ramps, not hard thresholds: at 32 px/m the art is minified ~4x and a hard snap speckles (h34, 32 px/m)
	vec3 o = mix(TEAL_PALE, TEAL, smoothstep(0.68, 0.54, lum));   // the body: the art's mid tones a step down
	o = mix(o, CREAM, smoothstep(rim_sat, rim_sat * 0.5, sat) * smoothstep(0.66, 0.76, lum));
	o = mix(o, TEAL_INK, smoothstep(ink_at + 0.08, ink_at - 0.08, lum));
	float g = 1.0 - 0.07 * hash(floor(FRAGCOORD.xy));
	float a = mix(c.a, smoothstep(0.04, 0.5, c.a), amount);
	COLOR = vec4(mix(c.rgb, o * g, amount), a * fade);
}
