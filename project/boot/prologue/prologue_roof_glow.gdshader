shader_type canvas_item;
render_mode blend_add;
// Fire light rising off the burning hall's roof: hottest at the band's south edge (the roof line),
// fading to nothing `rise` of the band north, with soft ends. `flicker` and `phase` are stepped on
// sim ticks by PrologueRoofGlow; nothing here reads TIME.

uniform vec4 color: source_color = vec4(1.0, 0.549, 0.078, 1.0);
uniform vec4 hot_color: source_color = vec4(1.0, 0.698, 0.227, 1.0);
uniform vec2 size_m = vec2(60.0, 6.0);
uniform float strength = 0.4;
uniform float base_feather_m = 1.0;
uniform float side_feather_m = 3.0;
uniform float flicker = 1.0;
uniform float phase = 0.0;

void fragment() {
	float up_m = (1.0 - UV.y) * size_m.y;
	float x_m = UV.x * size_m.x;
	float rise = smoothstep(0.0, base_feather_m, up_m) * pow(UV.y, 1.6);
	float sides = smoothstep(0.0, side_feather_m, x_m) * smoothstep(0.0, side_feather_m, size_m.x - x_m);
	float wave = 0.78 + 0.22 * sin(x_m * 0.41 + phase) * sin(x_m * 0.17 - phase * 0.6);
	vec3 tint = mix(hot_color.rgb, color.rgb, clamp(up_m / size_m.y * 1.5, 0.0, 1.0));
	COLOR = vec4(tint * (rise * sides * wave * strength * flicker), 1.0);
}
