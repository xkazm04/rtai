shader_type canvas_item;
// D5 cast shadow (proposal for the city lane): a building's shadow quad, drawn on the world layer UNDER the
// look_d4 print, as a light ink tint plus world-locked hand-drawn pen strokes (wobble, ink pressure, broken
// strokes), the hatched building shadows of d4h2_mock.jpg. The D4 print then inks it like any drawn hatch.
// Used by dev/showcase/d5_hero_run.gd; params in look_d5.params.json ("shadow").
// On a Sprite2D the shadow takes the sprite's alpha (a character's cast shadow); a Polygon2D samples the default
// white texture, so building/kerb quads are unchanged.

uniform float period = 5.0;    // world px between strokes (0.16 m)
uniform float tint = 0.36;     // ink alpha between the strokes
uniform float stroke = 0.85;   // ink alpha of a stroke
uniform float cov = 0.42;      // stroke width as a fraction of the period
uniform float zoom = 1.0;      // camera zoom (1 = 32 px/m): above 2 (64 px/m) the world period shrinks so the
                               // strokes stay ~10 screen px apart (at 128 px/m they read as coarse stripes)

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
	vec2 dir = vec2(0.7071, 0.7071);
	float along = dot(w, vec2(-dir.y, dir.x));
	float across = dot(w, dir) + (vnoise(vec2(along * 0.05, 1.7)) - 0.5) * 2.2;
	float per = period / max(1.0, zoom * 0.5);
	float row = floor(across / per);
	float press = 0.6 + 0.8 * vnoise(vec2(along * 0.03, row * 1.9));
	float gap = step(0.2, vnoise(vec2(along * 0.06, row * 4.3)));
	float f = abs(fract(across / per) - 0.5) * 2.0;
	float line = (1.0 - smoothstep(cov * press - 0.15, cov * press + 0.15, f)) * gap;
	COLOR = vec4(0.090, 0.075, 0.106, mix(tint, stroke, line) * texture(TEXTURE, UV).a);
}
