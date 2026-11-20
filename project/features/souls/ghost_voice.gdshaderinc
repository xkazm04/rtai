// Apply after a part has computed its own coverage (jar fill, printed plates, or belt cut).
uniform float voice_phase = -1.0;
uniform vec3 voice_ink : source_color = vec3(0.04, 0.27, 0.28);
uniform vec3 voice_light : source_color = vec3(0.72, 1.0, 0.95);

vec4 ghost_voice(vec4 body, vec2 screen_uv) {
	if (voice_phase >= 0.0) {
		float luma = dot(body.rgb, vec3(0.299, 0.587, 0.114));
		body.rgb = mix(voice_ink, voice_light, smoothstep(0.04, 0.62, luma));
		body.a *= 1.0 - 0.2 * step(0.5, fract(screen_uv.y * 80.0 + voice_phase));
	}
	return body;
}
