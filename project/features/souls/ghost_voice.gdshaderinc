// Apply after a part has computed its own coverage (jar fill, printed plates, or belt cut).
uniform float voice_phase = -1.0;
uniform float band_k = 0.45;
uniform vec3 deep : source_color = vec3(0.04, 0.27, 0.28);
uniform vec3 hi : source_color = vec3(0.72, 1.0, 0.95);

vec3 voice_colour(vec3 rgb) {
	float luma = dot(rgb, vec3(0.299, 0.587, 0.114));
	return mix(deep, hi, smoothstep(0.04, 0.62, luma));
}

float voice_band(float screen_y, float phase) {
	return 1.0 - band_k * step(0.5, fract(screen_y * 80.0 + phase));
}

vec4 ghost_voice(vec4 body, vec2 screen_uv) {
	if (voice_phase >= 0.0) {
		body.rgb = voice_colour(body.rgb);
		body.a *= voice_band(screen_uv.y, voice_phase);
	}
	return body;
}
