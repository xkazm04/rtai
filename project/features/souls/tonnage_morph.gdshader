shader_type canvas_item;
render_mode unshaded;

uniform float emerge : hint_range(0.0, 1.0) = 1.0;
uniform float reach : hint_range(0.0, 1.0) = 1.0;
varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	// Sprite2D supplies atlas UVs for the current facing. Warp within that cell only.
	vec2 grid = vec2(4.0, 5.0);
	vec2 cell = floor(UV * grid);
	vec2 p = fract(UV * grid);
	float elbow = 0.57;
	float lower = max(0.0, p.y - elbow);
	float sy = elbow + lower / mix(0.54, 1.0, reach);
	if (p.y <= elbow) {
		sy = p.y;
	}
	float press = smoothstep(elbow - 0.10, 0.89, sy) * (1.0 - reach);
	vec2 source = vec2((p.x - 0.5) / (1.0 - 0.42 * press) + 0.5, sy);
	if (any(lessThan(source, vec2(0.0))) || any(greaterThanEqual(source, vec2(1.0)))) {
		discard;
	}
	vec4 ink = texture(TEXTURE, (cell + source) / grid);
	// Start at the tucked palms and let the soft boundary pass the crown before full reach.
	float edge = mix(0.85, 0.12, smoothstep(0.0, 0.78, emerge));
	ink.a *= smoothstep(edge - 0.15, edge + 0.04, p.y);
	COLOR = ink * tint;
}
