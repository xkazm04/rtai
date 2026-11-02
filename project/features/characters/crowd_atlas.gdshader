shader_type canvas_item;
// The baked crowd (CrowdAtlas): a MultiMeshInstance2D draws one quad per person; the instance's
// custom.x is its atlas cell (look * 25 + clip first + frame). The cell picks a tile of the
// cols x rows atlas. COLOR carries the instance tint (a hit flash, the dead's teal plate).

uniform int cols = 25;
uniform int rows = 8;

void vertex() {
	float cell = floor(INSTANCE_CUSTOM.x + 0.5);
	float c = mod(cell, float(cols));
	float r = floor(cell / float(cols));
	UV = (UV + vec2(c, r)) / vec2(float(cols), float(rows));
}
