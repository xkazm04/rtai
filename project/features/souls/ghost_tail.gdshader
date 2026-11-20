shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D grain : repeat_enable, filter_linear;
uniform float flow = 0.0;
uniform int strands = 1;
uniform float fray = 0.25;

void fragment() {
	float x = UV.x;
	float y = UV.y * 2.0 - 1.0;
	float billow = texture(grain, vec2(x * 1.65 - flow * 0.48, y * 0.31 + flow * 0.12)).r;
	float grain2 = texture(grain, vec2(x * 3.1 - flow * 0.73, y * 0.76 - flow * 0.16)).r;
	float warp = (billow - 0.5) * (0.35 + fray * 0.9);
	float channel = y + warp + 0.12 * sin(x * 13.0 - flow * 4.0);
	float plume = 0.0;
	float vein = 0.0;
	for (int i = 0; i < 5; i++) {
		if (i >= strands) { break; }
		float lane = (float(i) + 0.5) / float(strands);
		float wave = 0.14 * sin(x * 12.0 + flow * 3.0 + lane * 11.0);
		float centre = (lane * 2.0 - 1.0) * 1.62 + wave * smoothstep(0.0, 0.32, x);
		float across = abs(channel - centre) * float(strands);
		float reach = 1.0 - 0.16 * abs(sin(lane * 17.0)) * float(strands > 1);
		float tongue = (1.0 - smoothstep(reach - 0.21, reach, x)) *
			(1.0 - smoothstep(0.16, 0.89 + (grain2 - 0.5) * 0.45, across));
		plume = max(plume, tongue);
		vein = max(vein, tongue * (1.0 - smoothstep(0.04, 0.48, across + (grain2 - 0.5) * 0.8)));
	}
	float shell = 1.0 - smoothstep(0.48, 1.0, abs(y) + (billow - 0.5) * 0.45);
	float filaments = 0.5 + 0.5 * sin(channel * 22.0 + 11.0 * billow + x * 10.0 - flow * 2.4);
	float cuts = smoothstep(0.16, 0.49, grain2 + 0.24 * filaments + (1.0 - x) * 0.19);
	float density = max(plume * cuts, shell * (1.0 - x) * 0.38);
	float light = clamp(0.48 * filaments + 0.55 * vein + (1.0 - x) * 0.34, 0.0, 1.0);
	vec3 ink = mix(vec3(0.07, 0.45, 0.42), vec3(0.18, 0.77, 0.71), light);
	ink = mix(ink, vec3(0.81, 1.0, 0.97), smoothstep(0.54, 1.0, light) * (1.0 - 0.48 * x));
	COLOR = vec4(ink, density * (1.0 - smoothstep(0.70, 1.0, x)) * (1.0 - 0.35 * x));
}
