shader_type canvas_item;
// D4 cast shadow (the building_shadows band, data/tables/cast_shadows.json): this lane's placeholder until the
// d5-close lane's look_d5_shadow is in the tree (same uniforms; CastShadows picks it). A shadow command's silhouette
// (TEXTURE alpha) prints as a light ink tint plus world-locked 45-degree pen strokes with a hand wobble and broken
// runs; the look_d4 print then inks it like any drawn hatch (the hatched cast shadows of the target frame).
// World-locked by construction: w is the canvas (world) position, not FRAGCOORD.

uniform sampler2D grime_tex : filter_linear, repeat_enable;  // GrimeLattice: the wobble / gaps, 1 fetch each
uniform float period = 5.0;  // world px between strokes
uniform float tint = 0.36;   // ink alpha between the strokes
uniform float stroke = 0.85; // ink alpha of a stroke
uniform float cov = 0.42;    // stroke width as a fraction of the period
uniform float zoom = 1.0;    // camera zoom (1 = 32 px/m): above 2 (64 px/m) the world period shrinks so the strokes
                             // stay ~10 screen px apart (ChunkView sets it; no change at 32-64 px/m)

varying vec2 w;

float tnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p);
	return texture(grime_tex, (i + f * f * (3.0 - 2.0 * f) + 0.5) / 128.0).r;
}

void vertex() {
	w = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float along = (w.x - w.y) * 0.7071;
	float across = (w.x + w.y) * 0.7071 + (tnoise(vec2(along * 0.05, 1.7)) - 0.5) * 2.2;
	float per = period / max(1.0, zoom * 0.5);
	float row = floor(across / per);
	float gap = step(0.2, tnoise(vec2(along * 0.06, row * 4.3)));
	float f = abs(fract(across / per) - 0.5) * 2.0;
	float line = (1.0 - smoothstep(cov - 0.15, cov + 0.15, f)) * gap;
	COLOR = vec4(0.090, 0.075, 0.106, mix(tint, stroke, line) * texture(TEXTURE, UV).a);
}
