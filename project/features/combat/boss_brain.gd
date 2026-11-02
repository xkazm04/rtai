class_name BossBrain
extends RefCounted
## Quartermaster Mertz: steps along the cage front between his two cover posts while the
## Robo-tazer waits or charges (in cover: nails hit the crates), and stands still, exposed,
## while it vents. Returns the ball on the tick he fires.


static func step(
	boss: Fighter, tazer: RoboTazer, target: Vector2, anchor: Vector2, tuning: CombatTuning
) -> ArcBall:
	boss.facing = (target - boss.pos).normalized()
	var fired: bool = tazer.step()
	boss.exposed = tazer.vulnerable()
	if fired:
		var muzzle: Vector2 = boss.pos + boss.facing * (boss.radius_m + 0.5)
		return ArcBall.launch(muzzle, target, tuning)
	if not boss.exposed:
		var swing: float = sin(float(tazer.shots) * 1.7 + float(tazer.ticks) * 0.02) * 3.0
		var post: Vector2 = anchor + Vector2(swing, 0.0)
		boss.pos = boss.pos.move_toward(post, tuning.tazer["strafe_mps"] * SimClock.TICK_DT)
	return null
