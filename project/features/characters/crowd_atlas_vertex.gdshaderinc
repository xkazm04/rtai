// The baked crowd (CrowdAtlas): a MultiMeshInstance2D draws one quad per person; the instance's
// custom.x is its atlas cell (look * 25 + clip first + frame). The cell picks a tile of the
// cols x rows atlas. COLOR carries the instance tint (a hit flash, the dead's teal plate).
//
// n10 world: the lying cells (the DEATH clip past its mid-fall frame) turn to StreetDeadHeading's
// few screen headings, as the near dead do: the sim's heading is the blow, the cell's head is its
// +y, the look picks the pose. Off (snap_dead false, the default) for every other user of this
// shader, the traffic atlas among them.

// Traffic uses the identity defaults. People also pass their slot + 1 in custom.y.
uniform int cols = 25;
uniform int rows = 8;
uniform bool snap_dead = false;
uniform bool drawn_fall = false;
uniform bool slot_sizes = false;
uniform vec2 standing_shift = vec2(0.0);
uniform vec2 fall_shift = vec2(0.0);
uniform float ground_k = 1.0;
uniform float fall_x = 1.0;
uniform float body_scales[512];
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
	bool fall = c >= DEAD_FROM - 1.0 && c <= DEAD_TO;
	VERTEX += fall ? fall_shift : standing_shift;
	if (fall) {
		VERTEX.x /= fall_x;
	}
	if (!fall || drawn_fall || !snap_dead) {
		VERTEX.y /= ground_k;
	}
	int slot = int(INSTANCE_CUSTOM.y) - 1;
	if (slot_sizes && slot >= 0 && slot < body_scales.length()) {
		VERTEX *= body_scales[slot];
	}
	if (snap_dead && !drawn_fall && c >= DEAD_FROM && c <= DEAD_TO) {
		VERTEX = laid(VERTEX, normalize(MODEL_MATRIX[0].xy), mod(r, POSES));
	} else if (drawn_fall && c >= DEAD_FROM && c <= DEAD_TO) {
		vec2 blow = normalize(MODEL_MATRIX[0].xy);
		float at = atan(blow.y, blow.x);
		float heading = radians(head_even[int(mod(round(at / (PI * 0.25)), 8.0))]);
		vec2 p = VERTEX;
		if (blow.x < 0.0) {
			p.x = -p.x;
			heading -= PI;
		}
		float d = heading - at;
		VERTEX = vec2(cos(d) * p.x - sin(d) * p.y, sin(d) * p.x + cos(d) * p.y);
	}
	UV = (UV + vec2(c, r)) / vec2(float(cols), float(rows));
}
