shader_type canvas_item;
render_mode blend_add;
// The 2D light (core/render/README.md, data/tables/lights.json): one pooled MultiMesh quad per light on the
// `light` canvas. The radial falloff is cut into flat bands (INSTANCE_CUSTOM.x steps) and each band edge is
// broken by a world-locked 2 px stipple, so a light prints as paper or an accent ink over the charcoal, like
// a lit patch drawn on the page, never a soft 3D bloom. COLOR.rgb = the token ink, COLOR.a = the strength
// (intensity x fade). INSTANCE_CUSTOM.y = cone half-angle in radians (0 = radial; the cone points along +x).

uniform vec2 world_px = vec2(0.0);   // the camera's world offset in screen px (hatch locked to the world)
uniform float hatch_px = 5.0;        // the band-edge hatch period in screen px

varying vec4 custom;

void vertex() {
	custom = INSTANCE_CUSTOM;
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float steps = max(custom.x, 1.0);
	float v = clamp(1.0 - r, 0.0, 1.0);
	if (custom.y > 0.0) {
		float ang = abs(atan(p.y, p.x));
		v *= 1.0 - smoothstep(custom.y * 0.8, custom.y, ang);
	}
	float k = v * steps;
	float band = floor(k);
	float f = fract(k);
	// band edge: 45-degree pen strokes locked to the world, thickening toward the next band (ink hatch,
	// not a random stipple, which read as a soft halftone glow in the first frames)
	vec2 w = FRAGCOORD.xy + world_px;
	float line = abs(fract((w.x - w.y) / hatch_px) - 0.5) * 2.0;
	band += step(line, smoothstep(0.6, 1.0, f));
	float level = band / steps;
	COLOR = vec4(COLOR.rgb * level * COLOR.a, 1.0);
}
