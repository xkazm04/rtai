shader_type canvas_item;
// The D4/D5 print on the blood (lane d5-combat, features/fx/combat_blood.gd): blood is drawn above
// the world print (that pass would turn any red into its vermilion plate), so it takes its own
// print here: the world-locked paper tooth of look_d4_item, and the grime lattice as 1 px ink
// grains in the wet (an aquatint on the red, denser in the dark body than at the bright rim),
// so it reads as printed ink, not a vector fill. Alpha untouched: decals still fade as in noir.

uniform vec2 world_px = vec2(0.0);  // the camera's world offset in screen px (CityView.world_px)
uniform sampler2D grime_tex : filter_nearest, repeat_enable;  // GrimeLattice.texture()
uniform float grain = 0.32;  // ink grain cover in the darkest red
uniform vec3 ink_tone = vec3(0.10, 0.07, 0.07);

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	vec2 w = FRAGCOORD.xy + world_px;
	vec3 c = COLOR.rgb;
	float lum = dot(c, vec3(0.299, 0.587, 0.114));
	float hg = texture(grime_tex, (floor(w) + 0.5) / 128.0).r;
	float cover = grain * smoothstep(0.55, 0.10, lum);
	c = mix(c, ink_tone, step(hg, cover) * 0.55);
	c *= 1.0 - 0.06 * hash(floor(w) + vec2(17.0, 31.0));
	COLOR = vec4(c, COLOR.a);
}
