shader_type canvas_item;
// D-Noir cast shadows (lane noir, NoirShadows): a draw command's silhouette as one flat value,
// its own alpha kept, so the swept stamps of a prop merge into one ink mass.

uniform float value = 0.1;

void fragment() {
	COLOR = vec4(vec3(value), texture(TEXTURE, UV).a * COLOR.a);
}
