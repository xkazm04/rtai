shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D grain : repeat_enable, filter_linear;
uniform vec2 grid = vec2(1.0);
uniform float fade_from = 0.0;
uniform float flow = 0.0;
uniform bool outline = false;
// The outline sprite is nudged on screen. Sample its erosion in the parent's cell coordinates.
instance uniform vec2 cut_shift = vec2(0.0);

void fragment() {
	vec2 cell = fract(UV * grid) + cut_shift;
	float fine = texture(grain, cell * vec2(3.4, 1.6) + vec2(flow * 0.11, -flow * 0.32)).r;
	float coarse = texture(grain, cell * vec2(1.3, 0.8) - vec2(flow * 0.17, flow * 0.24)).r;
	float from_bottom = 1.0 - cell.y;
	float edge = fade_from + (coarse - 0.5) * 0.12 + (fine - 0.5) * 0.09;
	float keep = smoothstep(edge - 0.075, edge + 0.024, from_bottom);
	float glow = 1.0 - smoothstep(edge + 0.01, edge + 0.12, from_bottom);
	vec3 band = mix(vec3(0.09, 0.61, 0.54), vec3(0.81, 1.0, 0.96), fine);
	if (outline) {
		COLOR = vec4(0.18, 0.77, 0.71, COLOR.a * keep * 0.6);
	} else {
		COLOR = vec4(mix(COLOR.rgb, band, glow * 0.95), COLOR.a * keep);
	}
}
