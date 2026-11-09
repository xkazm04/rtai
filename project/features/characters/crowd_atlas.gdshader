shader_type canvas_item;
// The baked crowd (CrowdAtlas): a MultiMeshInstance2D draws one quad per person; the instance's
// custom.x is its atlas cell (look * 25 + clip first + frame). The cell picks a tile of the
// cols x rows atlas. COLOR carries the instance tint (a hit flash, the dead's teal plate).
//
// n10 world: the lying cells (the DEATH clip past its mid-fall frame) turn to StreetDeadHeading's
// few screen headings, as the near dead do: the sim's heading is the blow, the cell's head is its
// +y, the look picks the pose. Off (snap_dead false, the default) for every other user of this
// shader, the traffic atlas among them.

uniform int cols = 25;
uniform int rows = 8;
uniform bool snap_dead = false;
uniform float head_even[8];
uniform float head_odd[8];

const float DEAD_FROM = 20.0;  // CrowdAtlas.CLIP_FIRST[DEATH] + 1: the drawn corpse cells
const float DEAD_TO = 22.0;
const float POSES = 5.0;  // StreetDeadPlan.POSES
const float ACROSS_POSE = 4.0;  // StreetDeadHeading.ACROSS_POSE

vec2 laid(vec2 v, vec2 blow, float pose) {
	float at = atan(blow.y, blow.x);
	int octant = int(mod(round(at / (PI * 0.25)), 8.0));
	bool odd = mod(pose, 2.0) > 0.5;
	float want = radians(odd ? head_odd[octant] : head_even[octant]);
	vec2 p = v;
	if (abs(pose - ACROSS_POSE) < 0.5) {
		want = blow.x >= 0.0 ? 0.0 : PI;
		p.x = blow.x >= 0.0 ? p.x : -p.x;  // mirrored for its side, never upside down
	}
	float d = want - (at + PI * 0.5);
	return vec2(cos(d) * p.x - sin(d) * p.y, sin(d) * p.x + cos(d) * p.y);
}

void vertex() {
	float cell = floor(INSTANCE_CUSTOM.x + 0.5);
	float c = mod(cell, float(cols));
	float r = floor(cell / float(cols));
	if (snap_dead && c >= DEAD_FROM && c <= DEAD_TO) {
		VERTEX = laid(VERTEX, normalize(MODEL_MATRIX[0].xy), mod(r, POSES));
	}
	UV = (UV + vec2(c, r)) / vec2(float(cols), float(rows));
}
