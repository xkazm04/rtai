class_name BossAdds
extends RefCounted
## The adds a boss calls in (King's gang, Servo's drones): each add is a one-phase row of
## bosses.json run by its own BossFight, so it follows the same tell rules (windup, aim lock,
## recovery) and its tell is drawn by the same view. Bodies are arena hostiles (brain_owned):
## every weapon and ghost hits them, and the hp the arena's chokepoint takes is routed back
## through BossFight.hurt() (route()). Never more than `cap` stand at once.

const FIRST_ID: int = 9100

var fights: Array[BossFight] = []
var cap: int = 6
var tries: int = 0
var landed: int = 0
var _last_hp: Dictionary[int, float] = {}
var _next_id: int = FIRST_ID


## Up to `count` adds of row `spec` at `points` (cycled), within the cap; `rng` is the row's named
## stream (ctx.rng.stream(spec.rng)), shared by every add of that row. Returns how many came.
func spawn(
	arena: CombatArena,
	spec: BossSpec,
	rng: RandomNumberGenerator,
	points: Array[Vector2],
	count: int
) -> int:
	var n: int = mini(count, cap - standing())
	for i: int in n:
		var at: Vector2 = points[(_next_id + i) % points.size()]
		var f: BossFight = BossFight.new(spec, rng, at)
		f.body.id = _next_id + i
		f.body.brain_owned = true
		f.start()
		arena.hostiles.append(f.body)
		fights.append(f)
		_last_hp[f.body.id] = f.body.hp
	_next_id += maxi(n, 0)
	return maxi(n, 0)


func standing() -> int:
	var n: int = 0
	for f: BossFight in fights:
		n += 1 if f.state != BossFight.State.DEFEATED else 0
	return n


## Every add's tick after the stage's: route the hits it took, step it, land its swipe on Rivet.
func step(arena: CombatArena, tick: int) -> void:
	var r: Fighter = arena.rivet
	for f: BossFight in fights:
		if f.state == BossFight.State.DEFEATED:
			continue
		route(f, _last_hp[f.body.id])
		if f.state == BossFight.State.DEFEATED or not r.alive():
			_last_hp[f.body.id] = f.body.hp
			continue
		var was: BossFight.State = f.state
		var hit: float = f.step(tick, r.pos, r.radius_m)
		tries += 1 if was == BossFight.State.IDLE and f.state == BossFight.State.WINDUP else 0
		if hit > 0.0 and r.exposed:
			arena.hit_dir = f.aim
			arena.hit_at = r.pos
			arena.damage(r, hit, f.body.id, StringName("boss_%s" % f.hit_id()))
			landed += 1
		_last_hp[f.body.id] = f.body.hp


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(fights.size())
	for f: BossFight in fights:
		f.write_state(out)


## The hp the arena's chokepoint took from `f`'s body since `last_hp` goes back through
## BossFight.hurt() (punish window, phase floors, the invulnerable transition).
static func route(f: BossFight, last_hp: float) -> void:
	var lost: float = last_hp - f.body.hp
	if lost <= 0.0:
		return
	f.body.hp = last_hp
	@warning_ignore("return_value_discarded")
	f.hurt(lost)
