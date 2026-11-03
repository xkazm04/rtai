shader_type canvas_item;
// D5 rig cast shadow (iteration 8, dev proposal for the characters lane): the CanvasGroup variant of
// look_d5_shadow. The group merges every part's silhouette first (so overlapping parts never stack into darker
// seams), then this prints the merged alpha as look_d5_shadow's world-locked pen hatch. Used by
// dev/showcase/d5_rig_shadow.gd on the world layer, under the look_d4 print, from 56 px/m (amount) up close.

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest;
uniform float period = 5.0;    // world px between strokes (as look_d5_shadow)
uniform float tint = 0.36;     // ink alpha between the strokes
uniform float stroke = 0.85;   // ink alpha of a stroke
uniform float cov = 0.42;      // stroke width as a fraction of the period
uniform float zoom = 1.0;      // camera zoom (1 = 32 px/m), as look_d5_shadow
uniform float amount = 1.0;    // the zoom fade (0 = off)

varying vec2 w;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

float vnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

void vertex() {
	w = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float a = step(0.5, textureLod(screen_tex, SCREEN_UV, 0.0).a);
	vec2 dir = vec2(0.7071, 0.7071);
	float along = dot(w, vec2(-dir.y, dir.x));
	float across = dot(w, dir) + (vnoise(vec2(along * 0.05, 1.7)) - 0.5) * 2.2;
	float per = period / max(1.0, zoom * 0.5);
	float row = floor(across / per);
	float press = 0.6 + 0.8 * vnoise(vec2(along * 0.03, row * 1.9));
	float gap = step(0.2, vnoise(vec2(along * 0.06, row * 4.3)));
	float f = abs(fract(across / per) - 0.5) * 2.0;
	float line = (1.0 - smoothstep(cov * press - 0.15, cov * press + 0.15, f)) * gap;
	COLOR = vec4(0.090, 0.075, 0.106, mix(tint, stroke, line) * a * amount);
}
