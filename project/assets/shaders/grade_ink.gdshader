shader_type canvas_item;
// The time-of-day grade (data/tables/lights.json `grades`, core/render/light_layer.gd): a full-screen rect on the
// `light` canvas under the additive lights. It reads the printed screen and re-prints it at a lower ink level:
//  - luminance l -> paper_level * l^gamma (hue kept: the paper stays warm cream-grey, the charcoal streets sink
//    toward the ink, the ink stays ink), so night is the same black-and-white print, darker and harder
//  - a pixel the palette gates call an accent (vermilion / teal) keeps up to `accent_keep` of its own value:
//    at night the spot colours (threats, cops, danger cues, souls) stand out of the darkened print
//  - `age` (the page age, LookOverlay.page_age: the D5 overlay's aged paper, routed here so the actors age WITH
//    the world they stand on): the neutral print warms toward the mock's sepia first; accents keep their hue
// The `day` grade with age 0 hides the rect (zero cost). Uniforms are grade-row data except the gates (palette.json)
// and the age (look_d5.params.json `world.age` x the overlay amount; the gains are look_d5's mock medians).

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float paper_level = 1.0;  // luminance the paper (l = 1) prints at
uniform float gamma = 1.0;        // > 1 sinks the mids and darks faster than the paper
uniform float accent_keep = 0.0;  // 0..1: how much of an accent pixel escapes the grade
uniform float verm_gate = 0.31;   // palette.json gates (PaletteTokens.classify)
uniform float teal_gate = 0.26;
uniform float age = 0.0;          // 0..1 aged paper over the whole printed page (0 = off)
// per-channel gains at luma 0 / 1, solved so the D4 print's street (86,76,77, luma 0.31) and paper
// (235,225,207, luma 0.89) land on d4h2_mock.jpg's medians (81,71,72) / (243,218,188); look_d5's own
// AGE_DARK / AGE_LIGHT (1.03,0.955,0.87 / 1.065,1,0.955) left the street too red (89,74,69)
uniform vec3 age_dark = vec3(0.892, 0.915, 0.950);
uniform vec3 age_light = vec3(1.052, 0.976, 0.903);

void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float chroma = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b));
	float neutral = 1.0 - smoothstep(0.12, 0.22, chroma);
	vec3 aged = clamp(c * mix(age_dark, age_light, dot(c, vec3(0.299, 0.587, 0.114))), 0.0, 1.0);
	c = mix(c, aged, age * neutral);
	float l = max(dot(c, vec3(0.299, 0.587, 0.114)), 1e-4);
	float f = paper_level * pow(l, gamma - 1.0);
	float verm = (c.r - max(c.g, c.b)) / verm_gate;
	float teal = (min(c.g, c.b) - c.r) / teal_gate;
	float accent = smoothstep(0.6, 1.0, max(verm, teal));
	f = mix(f, 1.0, accent * accent_keep);
	COLOR = vec4(c * min(f, 1.0), 1.0);
}
