shader_type canvas_item;
// One landed blood droplet per MultiMesh instance (lane d5-combat, features/fx/blood_splat_mesh.gd):
// the shape BloodMarks.splat drew with draw_circle calls, as a distance field in units of the splat
// radius (+x = the travel): a round core, a teardrop body stretched along the travel by the
// elongation e, three shrinking satellite drops ahead of it and four lobes round the core. Then the
// D4/D5 print of fx_blood_print: world-locked paper tooth and the grime lattice as ink grains.
// INSTANCE_CUSTOM = (elongation, seed, detail 0/1, birth tick); COLOR = the fluid's ground colour.
// The fade is BloodDecals': full until fade_after ticks old, then down to min_alpha over fade_ticks.

uniform vec2 world_px = vec2(0.0);
uniform sampler2D grime_tex : filter_nearest, repeat_enable;
uniform float grain = 0.32;
uniform vec3 ink_tone = vec3(0.10, 0.07, 0.07);
uniform float tick = 0.0;
uniform float fade_after = 3600.0;
uniform float fade_ticks = 7200.0;
uniform float min_alpha = 0.0;
// a cream rim `halo` radii wide round each splat (oil: black on asphalt reads only with it, the D4
// ink-with-cream-rim rule); 0 = none (blood)
uniform float halo = 0.0;
uniform vec3 halo_tone = vec3(0.93, 0.9, 0.82);

varying vec2 lp;
varying vec3 cus;
varying float fade;

float wave(float s, float k) { return fract(sin((s + k) * 91.7) * 43758.5453); }
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float disc(vec2 p, vec2 c, float r) { return length(p - c) - r; }

void vertex() {
	lp = VERTEX;
	cus = INSTANCE_CUSTOM.xyz;
	float age = tick - INSTANCE_CUSTOM.w;
	fade = age < 0.0 ? 0.0 : max(1.0 - clamp((age - fade_after) / fade_ticks, 0.0, 1.0), min_alpha);
}

void fragment() {
	float e = cus.x, s = cus.y;
	float d = disc(lp, vec2(0.0), 0.7);
	if (cus.z > 0.5) {
		for (int k = 0; k < 3; k++) {
			float fk = float(k);
			d = min(d, disc(lp, vec2(0.4 * fk * e, 0.0), 0.66 - 0.14 * fk));
			vec2 sat = vec2((1.5 + 1.1 * fk) * (0.4 + e), (wave(s, fk) - 0.5) * 0.8);
			d = min(d, disc(lp, sat, 0.26 - 0.06 * fk));
		}
		for (int k = 0; k < 4; k++) {
			float fk = float(k);
			float a = 6.2831853 * (fk + 0.6 * wave(s, fk + 7.0)) / 4.0;
			d = min(d, disc(lp, vec2(cos(a), sin(a)) * 0.62, 0.16 + 0.18 * wave(s, fk + 3.0)));
		}
	}
	float aa = max(fwidth(d), 1e-4);
	float cover = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, d);
	float rim = 1.0 - smoothstep(-aa * 0.5, aa * 0.5, d - halo);
	vec2 w = FRAGCOORD.xy + world_px;
	vec3 c = COLOR.rgb;
	float lum = dot(c, vec3(0.299, 0.587, 0.114));
	float hg = texture(grime_tex, (floor(w) + 0.5) / 128.0).r;
	c = mix(c, ink_tone, step(hg, grain * smoothstep(0.55, 0.10, lum)) * 0.55);
	c *= 1.0 - 0.06 * hash(floor(w) + vec2(17.0, 31.0));
	if (halo > 0.0) {
		c = mix(halo_tone, c, cover);
		cover = rim;
	}
	COLOR = vec4(c, COLOR.a * cover * fade);
}
