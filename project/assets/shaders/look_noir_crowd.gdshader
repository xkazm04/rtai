shader_type canvas_item;
// D-Noir crowd print (lane noir, experiment): the baked crowd atlas (CrowdAtlas cells, same vertex
// as crowd_atlas.gdshader) printed as a solid ink silhouette carved by a white rim - thick on the
// side facing the light, a hairline on the far side.

uniform int cols = 25;
uniform int rows = 8;
uniform vec2 light_dir = vec2(-0.6, -0.8);
uniform float rim_px = 7.0;   // lit-side rim width in atlas texels (the far side is 0.4 of it)

const vec3 PAPER = vec3(0.945, 0.937, 0.910);
const vec3 INK = vec3(0.027, 0.027, 0.035);

void vertex() {
	float cell = floor(INSTANCE_CUSTOM.x + 0.5);
	float c = mod(cell, float(cols));
	float r = floor(cell / float(cols));
	UV = (UV + vec2(c, r)) / vec2(float(cols), float(rows));
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	if (t.a < 0.5) {
		discard;
	}
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec2 l = normalize(light_dir);
	float lit = 0.0;
	for (int i = 1; i <= 4; i++) {
		lit = max(lit, step(texture(TEXTURE, UV + l * px * float(i) * rim_px * 0.25).a, 0.5));
	}
	float far = 0.0;
	float f = rim_px * 0.4;
	far = max(far, step(texture(TEXTURE, UV + vec2(px.x * f, 0.0)).a, 0.5));
	far = max(far, step(texture(TEXTURE, UV - vec2(px.x * f, 0.0)).a, 0.5));
	far = max(far, step(texture(TEXTURE, UV + vec2(0.0, px.y * f)).a, 0.5));
	far = max(far, step(texture(TEXTURE, UV - vec2(0.0, px.y * f)).a, 0.5));
	float rim = max(lit, far);
	COLOR = vec4(mix(INK, PAPER, rim), 1.0);
}
