class_name KillLabTurn
extends RefCounted
## The kill reel's directions (dev arg --sig-dir=<deg>, tools/film/kill_reel.mjs): turns a solo
## KillLab's guards about Rivet's solo spot, 0 = as placed (east of him), 90 = south (screen down).
## Dev capture only: a lab without --sig-dir, and every run without --sig-lab, is untouched.


static func apply(lab: KillLab, deg: float) -> void:
	if lab.solo == Vector2.INF or is_zero_approx(deg):
		return
	for n: int in lab.guards.size():
		var at: Vector2 = lab.solo + (lab.spots[n] - lab.solo).rotated(deg_to_rad(deg))
		lab.spots[n] = at
		lab.guards[n].pos = at
