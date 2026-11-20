shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D grain : repeat_enable, filter_linear;
uniform float flow = 0.0;
uniform int strands = 1;
uniform float fray = 0.25;

void fragment() {
	float x = UV.x;
	float y = UV.y * 2.0 - 1.0;
	float roll = texture(grain, vec2(x * 1.4 - flow * 0.48, y * 0.36 + flow * 0.12)).r;
	float fine = texture(grain, vec2(x * 3.3 - flow * 0.71, y * 0.84 - flow * 0.16)).r;
	float split = smoothstep(0.25, 0.59, x);
	float channel = y + (roll - 0.5) * (0.18 + fray * split);
	float contour = abs(channel) - (0.85 + (fine - 0.5) * (0.16 + split * 0.28));
	float aa = max(fwidth(contour), 0.006);
	float shell = 1.0 - smoothstep(-aa, aa, contour);
	float tongue = 0.0;
	for (int i = 0; i < 5; i++) {
		if (i >= strands) { break; }
		float lane = (float(i) + 0.5) / float(strands);
		float wave = sin(x * 14.0 - flow * 3.1 + lane * 8.0);
		float centre = split * ((lane * 2.0 - 1.0) * 0.85 + 0.13 * wave);
		float width = mix(0.89, 0.72 / float(strands), split);
		float reach = 1.0 - 0.14 * abs(sin(lane * 17.0)) * float(strands > 1);
		float ridge = 1.0 - smoothstep(width * 0.39, width, abs(channel - centre));
		tongue = max(tongue, ridge * (1.0 - smoothstep(reach - 0.16, reach, x)));
	}
	float fibre = 0.5 + 0.5 * sin(channel * 20.0 + 9.0 * roll + x * 13.0 - flow * 2.1);
	float core = 1.0 - smoothstep(0.28, 0.91, abs(channel) + (roll - 0.5) * 0.25);
	vec3 teal = mix(vec3(0.071, 0.478, 0.447), vec3(0.18, 0.77, 0.71), core + fibre * 0.13);
	vec3 vapour = mix(teal, vec3(0.81, 1.0, 0.97), core * (0.97 - 0.55 * x) + fibre * 0.07);
	float alpha = mix(0.98, tongue * (0.70 + 0.30 * fine), smoothstep(0.30, 0.52, x));
	float rim = smoothstep(-2.5 * aa, -0.5 * aa, contour) * (1.0 - smoothstep(0.35, 0.56, x));
	COLOR = vec4(mix(vapour, vec3(0.043, 0.18, 0.173), rim), shell * mix(alpha, 0.55, rim)
		* (1.0 - smoothstep(0.77, 1.0, x)) * COLOR.a);
}
