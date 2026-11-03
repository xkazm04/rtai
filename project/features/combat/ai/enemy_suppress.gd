class_name EnemySuppress
extends RefCounted
## Suppression (the brief's "suppress" state): a nail that flies past a human enemy within NEAR_M
## without hitting it makes the enemy flinch. A patrol cop dies to one nail, so the flinch is the
## only non-lethal reaction it can show, and it reads differently from a hit (a sidestep away from
## the nail, no flash, no blood). Gameplay: a flinch during the tell breaks the windup (the aim
## line drops, the squad token goes back), so firing near a shooter buys the player a beat.
## Robots never flinch; neither does a shield bearer facing the nail. A REFRACTORY_TICKS gap stops
## a burst from pinning one enemy forever. Deterministic: no RNG.

const NEAR_M: float = 0.6
const FLINCH_TICKS: int = 14
const REFRACTORY_TICKS: int = 45
const SHIELD_COS: float = 0.5


## Checks the nail `s` (moved this tick from `from`) against every human it has just passed.
static func near_miss(pit: EnemyPit, s: Shot, from: Vector2) -> void:
	var dir: Vector2 = s.vel.normalized()
	for e: EnemyAgent in pit.agents:
		if not _can_flinch(e, pit.tick, dir):
			continue
		if (e.pos - s.pos).dot(dir) >= 0.0:
			continue  # not passed yet: it may still hit next tick
		if s.crossed(from, e.pos, e.radius() + NEAR_M):
			flinch(pit, e, s.pos - dir * (s.pos - e.pos).dot(dir))


## `e` flinches away from the point `at` where the nail passed it.
static func flinch(pit: EnemyPit, e: EnemyAgent, at: Vector2) -> void:
	var away: Vector2 = e.pos - at
	e.flinch_dir = away.normalized() if away.length() > 0.01 else -e.facing.orthogonal()
	e.flinch_tick = pit.tick
	pit.stats["flinches"] += 1.0
	if e.state == EnemyAgent.State.WINDUP or e.state == EnemyAgent.State.FIRE:
		pit.stats["tells_broken"] += 1.0
		pit.stun(e, FLINCH_TICKS)


static func flinching(e: EnemyAgent, now: int) -> bool:
	return e.alive() and now - e.flinch_tick < FLINCH_TICKS


static func _can_flinch(e: EnemyAgent, now: int, dir: Vector2) -> bool:
	if not e.alive() or e.arch.body != &"human" or e.state == EnemyAgent.State.DOWN:
		return false
	if now - e.flinch_tick < REFRACTORY_TICKS:
		return false
	var shielded: bool = e.arch.shield_front_mult < 1.0
	return not (shielded and e.facing.dot(-dir) > SHIELD_COS)
