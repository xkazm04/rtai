shader_type canvas_item;
// D5 UI art minified (proposal for the HUD lane): the 512 px portraits and the phone frame draw at 0.3-0.7x
// in the dialogue panel and the phone close-up. Plain trilinear blends two mips there and blurs the pen line
// (the item17 board). This takes 4 taps on a rotated grid inside the pixel's footprint, each one mip SHARPER
// than trilinear would read, so the result is about a box filter of the true footprint (Lanczos-like), at any
// window size (no pre-scaled set per UI scale). `sharp` adds a light unsharp mask against the next mip up.
// Set the node's texture_filter to LINEAR_WITH_MIPMAPS (the texture must import with mipmaps).

uniform float sharp : hint_range(0.0, 1.0) = 0.5;  // unsharp amount vs the footprint's own blur (0.5: item50)
uniform float lod_bias = 0.0;                      // extra mip bias on top of the per-tap footprint

varying vec4 tint;  // the node's modulate (the fragment's COLOR already holds the default texture sample)

void vertex() {
	tint = COLOR;
}

void fragment() {
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 dx = dFdx(UV);
	vec2 dy = dFdy(UV);
	// source texels per screen pixel (the footprint); below 1 the art is magnified: one plain tap
	float fp = max(length(dx * size), length(dy * size));
	vec4 c;
	if (fp <= 1.0) {
		c = texture(TEXTURE, UV);
	} else {
		// each tap covers half the footprint, so it reads one mip finer than the footprint
		float lod = max(log2(fp * 0.5) + lod_bias, 0.0);
		// rotated grid (RGSS): the taps sit at +-1/8, +-3/8 of the footprint on both axes
		c = textureLod(TEXTURE, UV + dx * 0.125 + dy * 0.375, lod);
		c += textureLod(TEXTURE, UV - dx * 0.125 - dy * 0.375, lod);
		c += textureLod(TEXTURE, UV + dx * 0.375 - dy * 0.125, lod);
		c += textureLod(TEXTURE, UV - dx * 0.375 + dy * 0.125, lod);
		c *= 0.25;
		if (sharp > 0.0) {
			vec4 soft = textureLod(TEXTURE, UV, lod + 1.0);
			c = clamp(c + (c - soft) * sharp, vec4(0.0), vec4(1.0));
		}
	}
	COLOR = c * tint;
}
