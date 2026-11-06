shader_type canvas_item;
// n8 vehicles: the traffic card atlas (VehicleCards). One quad per car; the instance's custom.x
// is its cell (art id * cols + view), custom.y > 0.5 mirrors the cell about its centre (the three
// mirrored views). COLOR carries the tint and the blend weight (alpha).

uniform int cols = 5;
uniform int rows = 9;

void vertex() {
	float cell = floor(INSTANCE_CUSTOM.x + 0.5);
	float c = mod(cell, float(cols));
	float r = floor(cell / float(cols));
	vec2 uv = UV;
	if (INSTANCE_CUSTOM.y > 0.5) {
		uv.x = 1.0 - uv.x;
	}
	UV = (uv + vec2(c, r)) / vec2(float(cols), float(rows));
}
