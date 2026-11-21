shader_type canvas_item;

// The ghost strip shares one canvas item for the portraits and the Madness gauge.
uniform float meter_band_px;
uniform vec4 notch_ink : source_color = vec4(0.31, 0.28, 0.31, 1.0);

void fragment() {
	float from_bottom = (1.0 - SCREEN_UV.y) / SCREEN_PIXEL_SIZE.y;
	if (from_bottom <= meter_band_px && COLOR.g > COLOR.r * 1.5 && COLOR.b > COLOR.r * 1.5) {
		COLOR.rgb = notch_ink.rgb;
	}
}
