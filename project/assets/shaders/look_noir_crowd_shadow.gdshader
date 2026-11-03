// D-Noir (lane noir): the crowd's existing soft shadow blobs (CrowdLayers RL_PED_SHADOWS) printed
// as hard ink, stretched away from the light. No extra draw: it is a material on a layer the sim
// already fills every frame. The quad is the unit quad (-0.5..0.5) under the instance transform.
shader_type canvas_item;

uniform vec2 away = vec2(0.6, 0.8);
uniform float stretch = 1.8;
uniform float cut = 0.4;
uniform float value = 0.03;

void vertex() {
	VERTEX += away * (dot(VERTEX, away) + 0.5) * (stretch - 1.0);
}

void fragment() {
	float a = texture(TEXTURE, UV).a;
	COLOR = vec4(vec3(value), step(cut, a));
}
