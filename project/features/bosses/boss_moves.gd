class_name BossMoves
extends RefCounted
## How a boss's body moves and what its attacks do beyond the shared zone hit. The framework's
## default: walk toward Rivet between attacks (holding `keep_m`), stand still through a tell, and
## for a CHARGE drive the body along the locked aim at move_mps. A boss with its own needs (King's
## throne-car, Servo's rotor dash) names a script in bosses.json (`features/bosses/<id>/`) that
## extends this class and overrides only what differs.

## A walk that made less than this share of its step (cover pushed it back) is blocked.
const STUCK_K: float = 0.3
## Ticks a blocked walk sidesteps around what blocks it (a crate row, the stalled car).
const DETOUR_TICKS: int = 45

## The distance the default walk stops at.
var keep_m: float = 4.0
var _from: Vector2 = Vector2.ZERO
var _want: float = 0.0
var _t: int = -2
var _detour: int = 0
var _side: float = 1.0


## Between attacks (IDLE): close in on the target, sidestepping when cover blocks the way.
func idle_step(f: BossFight, target: Vector2) -> void:
	var d: Vector2 = target - f.body.pos
	if f.t == _t + 1 and _want > 0.0 and _from.distance_to(f.body.pos) < _want * STUCK_K:
		_side = -_side if _detour > 0 else (1.0 if f.body.id % 2 == 0 else -1.0)
		_detour = DETOUR_TICKS
	_t = f.t
	_want = 0.0
	_from = f.body.pos
	if d.length() > keep_m:
		var dir: Vector2 = d.normalized()
		if _detour > 0:
			_detour -= 1
			dir = (dir * 0.3 + dir.orthogonal() * _side).normalized()
		_want = f.spec.move_mps * SimClock.TICK_DT
		f.body.pos += dir * _want
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


## Once, by whoever builds the fight (BossHook): a boss script takes its own named RNG streams
## here (Servo's swarm), never a global or an unnamed one.
func bind(_f: BossFight, _rng: RngRegistry) -> void:
	pass


## Every tick in every state but DEFEATED, before the state's own step: damage that lands outside
## the active window (Servo's parcels, a late coin hail). The fight adds it to what it returns.
func tick(_f: BossFight, _target: Vector2, _target_r: float) -> float:
	return 0.0


## Extra hittable bodies the boss owns this tick (Servo's drones): BossHook keeps exactly these in
## the arena's hostiles (added when new, removed when gone), so every weapon and ghost hits them;
## the boss script reads their hp back itself. Default: none.
func bodies() -> Array[Fighter]:
	return []


## The way out of the boss script's own hazards that land outside the attack zone (Servo's drop
## rings, a late hail) for a body at `at` with clearance `r`, or zero when none threatens it. Only
## what a player can see by now: the bot reads it (BossBot). Default: none.
func threat_away(_at: Vector2, _r: float) -> Vector2:
	return Vector2.ZERO


## The phase changed (after its transition): a boss swaps its body or arena here.
func phase_entered(_f: BossFight, _phase: int) -> void:
	pass


## The boss script's own numbers for the bot's table (BossHook.telemetry, under `moves`).
func telemetry() -> Dictionary:
	return {}


## Extra state for the replay hash (a boss script that overrides it calls super first).
func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(_detour)
	out.put_float(_side)


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
