shader_type canvas_item;
// D-Noir cast shadows (lane noir, NoirShadows): ONE quad per caster covers its texture plus the
// sweep; each fragment takes the max alpha of the caster's texture along the sweep, printed as one
// flat value. The host packs the sweep per command into the modulate colour: rg = the sweep in
// texture uv (0.5 + d / D_SCALE), b = the tap count / 255; the region's uv runs past 0..1.

uniform float value = 0.1;
const float D_SCALE = 16.0;
// fragment()'s COLOR is already multiplied by the texture: the packing travels in a varying
varying vec4 pack;

void vertex() {
	pack = COLOR;
}

void fragment() {
	vec2 d = (pack.rg - 0.5) * D_SCALE;
	int n = max(int(pack.b * 255.0 + 0.5), 1);
	float a = 0.0;
	for (int i = 0; i <= n; i++) {
		vec2 uv = UV - d * (float(i) / float(n));
		if (all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0)))) {
			a = max(a, texture(TEXTURE, uv).a);
		}
	}
	COLOR = vec4(vec3(value), a);
}
