class_name BossMoves
extends RefCounted
## How a boss's body moves and what its attacks do beyond the shared zone hit. The framework's
## default: walk toward Rivet between attacks (holding `keep_m`), stand still through a tell, and
## for a CHARGE drive the body along the locked aim at move_mps. A boss with its own needs (King's
## throne-car, Servo's rotor dash) names a script in bosses.json (`features/bosses/<id>/`) that
## extends this class and overrides only what differs.

## The distance the default walk stops at.
var keep_m: float = 4.0


## Between attacks (IDLE): close in on the target.
func idle_step(f: BossFight, target: Vector2) -> void:
	var d: Vector2 = target - f.body.pos
	if d.length() > keep_m:
		f.body.pos += d.normalized() * f.spec.move_mps * SimClock.TICK_DT
	if d.length() > 0.01:
		f.body.facing = d.normalized()


## Each tick of the active window. Return true when the target is struck this tick (the fight
## lands the damage once per attack).
func active_step(f: BossFight, target: Vector2, target_r: float) -> bool:
	var a: BossAttack = f.attack
	if a.shape == BossAttack.Shape.CHARGE:
		var travelled: float = f.origin.distance_to(f.body.pos)
		if travelled < a.range_m:
			f.body.pos += f.aim * a.move_mps * SimClock.TICK_DT
		return BossZone.body_hits(f.body.pos, f.body.radius_m, a, target, target_r)
	return BossZone.hits(a, f.origin, f.aim, target, target_r)


## The phase changed (after its transition): a boss swaps its body or arena here.
func phase_entered(_f: BossFight, _phase: int) -> void:
	pass


## Extra state for the replay hash.
func write_state(_out: StreamPeerBuffer) -> void:
	pass


## The per-boss moves `path` names, or the default (logged when the path is broken).
static func make(path: String) -> BossMoves:
	if path.is_empty() or not path.begins_with("res://features/bosses/"):
		return BossMoves.new()
	if not ResourceLoader.exists(path):
		Log.warn("bosses", "moves %s not found: default moves" % path)
		return BossMoves.new()
	var scr: GDScript = load(path) as GDScript
	var obj: Variant = scr.new() if scr != null and scr.can_instantiate() else null
	if not obj is BossMoves:
		Log.warn("bosses", "%s does not extend BossMoves: default moves" % path)
		return BossMoves.new()
	return obj
