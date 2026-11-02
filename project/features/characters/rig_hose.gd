class_name RigHose
extends RefCounted
## Rivet's torch hose: a verlet rope from the back plate to the torch forearm, bulging out to the
## side and trailing the motion, with a length constraint so it never stretches.

const SLACK_PX: float = 26.0


static func step(rig: CutRig, dt: float) -> void:
	var p: BodyPlan = rig.plan
	var n: int = p.hose_n
	var a: Vector2 = rig.torso.global_transform * p.hose_from
	var fo: Sprite2D = rig.sides[BodyPlan.R].fore
	var b: Vector2 = fo.global_transform * Vector2(p.fore_len[BodyPlan.R] * p.hose_along, 0)
	if rig.hose_pts.size() != n:
		_init_rope(rig, a, b, n)
	var out_dir: Vector2 = Vector2(0, 1).rotated(rig.facing)
	var follow: float = 1.0 - exp(-dt * 6.0)
	for i: int in range(1, n - 1):
		var k: float = float(i) / (n - 1)
		var bulge: Vector2 = out_dir * sin(PI * k) * p.hose_bulge * CutRig.SC
		var rest: Vector2 = a.lerp(b, k) + bulge - rig.fwd() * sin(PI * k) * 6.0
		var pt: Vector2 = rig.hose_pts[i]
		var v: Vector2 = (pt - rig.hose_prev[i]) * 0.9
		rig.hose_prev[i] = pt
		rig.hose_pts[i] = pt + v + (rest - pt) * follow
	rig.hose_pts[0] = a
	rig.hose_pts[n - 1] = b
	_constrain(rig, n, (a.distance_to(b) + SLACK_PX) / (n - 1))
	var loc: PackedVector2Array = PackedVector2Array()
	@warning_ignore("return_value_discarded")
	loc.resize(n)
	for i: int in n:
		loc[i] = rig.to_local(rig.hose_pts[i])
	rig.hose.points = loc


static func _init_rope(rig: CutRig, a: Vector2, b: Vector2, n: int) -> void:
	@warning_ignore_start("return_value_discarded")
	rig.hose_pts.resize(n)
	rig.hose_prev.resize(n)
	@warning_ignore_restore("return_value_discarded")
	for i: int in n:
		rig.hose_pts[i] = a.lerp(b, float(i) / (n - 1))
		rig.hose_prev[i] = rig.hose_pts[i]


static func _constrain(rig: CutRig, n: int, seg: float) -> void:
	for _it: int in 4:
		for i: int in n - 1:
			var dd: Vector2 = rig.hose_pts[i + 1] - rig.hose_pts[i]
			var length: float = dd.length()
			if length < 0.0001 or length <= seg:
				continue
			var corr: Vector2 = dd * (1.0 - seg / length) * 0.5
			if i > 0:
				rig.hose_pts[i] += corr
			if i + 1 < n - 1:
				rig.hose_pts[i + 1] -= corr
