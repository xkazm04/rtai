shader_type canvas_item;
render_mode unshaded;

uniform vec3 fill;
uniform vec3 top_px;
uniform vec3 bottom_px;
uniform bool circles = false;
uniform float flash;
uniform float vent;
uniform vec4 teal : source_color = vec4(0.1804, 0.7686, 0.7137, 1.0);
uniform vec4 full : source_color = vec4(0.7490, 1.0, 0.9647, 1.0);
uniform vec4 amber : source_color = vec4(1.0, 0.6902, 0.0, 1.0);

void fragment() {
	vec4 mask = texture(TEXTURE, UV);
	float y = UV.y / TEXTURE_PIXEL_SIZE.y;
	vec3 level = mix(bottom_px, top_px, fill);
	vec3 lit = smoothstep(level - 0.5, level + 0.5, vec3(y)) * step(vec3(0.0001), fill);
	float coverage = dot(mask.rgb, lit);
	float strength = dot(mask.rgb, fill);
	vec3 tint = mix(teal.rgb, full.rgb, smoothstep(0.7, 1.0, strength));
	if (circles) {
		coverage = dot(mask.rgb, fill);
		tint = mix(teal.rgb, full.rgb, 0.48);
	}
	tint = mix(tint, vec3(1.0), flash);
	if (vent > 0.0) {
		tint = amber.rgb;
	}
	COLOR = vec4(tint, mask.a * max(coverage, max(flash, vent)));
}
