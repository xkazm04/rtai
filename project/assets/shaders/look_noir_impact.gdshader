shader_type canvas_item;
// D-Noir comic impact frame (lane noir): drawn for 1-3 frames on a big hit, above the noir pass.
// mode 1 = the panel inverts (ink <-> paper; the blood stays red), mode 2 = a white flash with the
// silhouettes left as ink, mode 3 = paper with a speed-line burst, mode 4 = the silhouette flash:
// the host hides the world and clears to `key`, so every non-key pixel (the actors) prints as
// solid ink on paper. lines > 0 adds the radial
// speed-line burst from `center` (screen uv) on any mode. Params: look_noir.params.json `impact`.

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform int mode = 0;
uniform vec2 center = vec2(0.5);
uniform float lines = 1.0;
uniform float line_count = 64.0;
uniform float line_inner = 0.10;   // the burst's clear radius (screen heights)
uniform float flash_cut = 0.2;     // mode 2: luminance under which a pixel stays ink
uniform float aspect = 1.7778;
uniform vec3 key = vec3(0.0, 1.0, 0.0);

const vec3 PAPER = vec3(0.945, 0.937, 0.910);
const vec3 INK = vec3(0.027, 0.027, 0.035);

float hash(float n) { return fract(sin(n * 12.9898) * 43758.5453); }

void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	float red = step(0.3, c.r) * (1.0 - step(0.2, max(c.g, c.b) / max(c.r, 0.001)));
	vec3 col = c;
	if (mode == 1) {
		col = mix(PAPER, INK, step(0.5, l));
	} else if (mode == 2) {
		col = mix(PAPER, INK, step(l, flash_cut));
	} else if (mode == 3) {
		col = PAPER;
	} else if (mode == 4) {
		col = mix(INK, PAPER, step(distance(c, key), 0.35));
	}
	col = mix(col, c, red);
	vec2 d = (SCREEN_UV - center) * vec2(aspect, 1.0);
	float a = atan(d.y, d.x) / 6.28318 + 0.5;
	float k = floor(a * line_count);
	float w = 0.18 + 0.5 * hash(k);
	float on = step(abs(fract(a * line_count) - 0.5) * 2.0, w * 0.5);
	float r0 = line_inner * (1.0 + 1.6 * hash(k + 17.0));
	float burst = on * smoothstep(r0, r0 + 0.08, length(d)) * lines * step(0.5, hash(k + 3.0) + 0.3);
	vec3 line_col = (mode == 1 || mode >= 3) ? INK : PAPER;
	col = mix(col, line_col, burst * float(mode > 0));
	COLOR = vec4(col, float(mode > 0));
}
