shader_type canvas_item;
// D-Noir HUD print (lane noir): the HUD draws above the noir pass, so it keeps its own colours; this
// material on the HUD node prints the D4 vermilion (#E8502A: heat pips, speaker names, the weapon)
// as ink, so the HUD is black and white like the rest of the direction (value, not hue). Blood red
// and the teal of the dead are not touched (hue distance from the vermilion key).

uniform vec3 key = vec3(0.910, 0.314, 0.165);
uniform vec3 ink = vec3(0.090, 0.075, 0.106);
uniform float reach = 0.18;

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	float near = 1.0 - smoothstep(reach * 0.5, reach, distance(c.rgb, key));
	COLOR = vec4(mix(c.rgb, ink, near), c.a);
}
