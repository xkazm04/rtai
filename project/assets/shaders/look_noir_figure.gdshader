shader_type canvas_item;
// D-Noir figure shadows (lane noir, NoirFigureShadows): TEXTURE is the casters (the rigs) rendered
// alone into a screen-sized SubViewport. Each fragment walks back along the sweep (towards the light)
// and takes the max alpha of the silhouette, SCALED about the nearest body's centre by a height
// profile: narrow legs at the feet, the full shoulders mid-way, a small head at the far end - so a
// body casts a figure, not the box a straight sweep of its top-down outline makes. Printed flat.

const int MAX_BODIES = 16;
uniform float value = 0.1;
uniform vec2 sweep = vec2(0.0);   // screen uv, away from the light
uniform int taps = 1;
uniform vec2 view = vec2(1280.0, 720.0);
uniform vec2 bodies[MAX_BODIES];  // screen uv of each body's centre
uniform int body_count = 0;
uniform float legs = 0.35;        // silhouette scale at the feet (t = 0)
uniform float head = 0.5;         // silhouette scale at the head (t = 1)
uniform float reach_px = 48.0;    // screen px: a sample further than this from the body is another's

float width(float t) {
	return mix(legs, 1.0, smoothstep(0.25, 0.55, t)) * mix(1.0, head, smoothstep(0.8, 0.95, t));
}

void fragment() {
	vec2 mid = UV - sweep * 0.5;
	vec2 c = vec2(-10.0);
	float best = 1e9;
	for (int k = 0; k < body_count; k++) {
		float dd = length((bodies[k] - mid) * view);
		if (dd < best) {
			best = dd;
			c = bodies[k];
		}
	}
	float a = 0.0;
	for (int i = 1; i <= taps; i++) {
		float t = float(i) / float(taps);
		vec2 uv = c + (UV - sweep * t - c) / width(t);
		bool own = length((uv - c) * view) < reach_px;
		if (own && all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0)))) {
			a = max(a, texture(TEXTURE, uv).a);
		}
	}
	COLOR = vec4(vec3(value), step(0.5, a) * step(0.0, c.x));
}
