shader_type canvas_item;
render_mode unshaded;

// Let the paper show through the teal plates. Keep the crash-test discs and printed ink dense.
void fragment() {
	float light = max(COLOR.r, max(COLOR.g, COLOR.b));
	float disc = smoothstep(0.06, 0.32, COLOR.r - COLOR.b);
	float plate = smoothstep(0.10, 0.38, light) * (1.0 - disc);
	COLOR.rgb = mix(COLOR.rgb, vec3(0.52, 1.0, 0.94), 0.14 * plate);
	COLOR.a *= 1.0 - 0.15 * plate;
}
