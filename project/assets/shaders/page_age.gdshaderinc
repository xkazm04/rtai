// The page age (core/render/README.md "Page age"): the D5 overlay's aged paper, one rule for every pass that
// prints the page - grade_ink (world + actors, under the lights), light_ink (the additive lights) and fx_ink
// (the emissive FX twin above the lights). `age` 0 = off; only neutral colours warm, accents keep their hue.
uniform float age = 0.0;
// per-channel gains at luma 0 / 1, solved so the D4 print's street (86,76,77, luma 0.31) and paper
// (235,225,207, luma 0.89) land on d4h2_mock.jpg's medians (81,71,72) / (243,218,188); look_d5's own
// AGE_DARK / AGE_LIGHT (1.03,0.955,0.87 / 1.065,1,0.955) left the street too red (89,74,69)
uniform vec3 age_dark = vec3(0.892, 0.915, 0.950);
uniform vec3 age_light = vec3(1.052, 0.976, 0.903);

vec3 page_age(vec3 c) {
	float chroma = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b));
	float neutral = 1.0 - smoothstep(0.12, 0.22, chroma);
	vec3 aged = clamp(c * mix(age_dark, age_light, dot(c, vec3(0.299, 0.587, 0.114))), 0.0, 1.0);
	return mix(c, aged, age * neutral);
}
