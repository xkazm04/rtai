class_name RangeTarget
extends RefCounted
## A body a round can hit: a range dummy, a strafing drone, a hostile, Rivet. Carries the status
## the shooting model applies (burning = panics, stunned, knockback velocity that decays).

const KNOCK_DECAY_PER_TICK: float = 0.85

var id: int = 0
var pos: Vector2 = Vector2.ZERO
## Its own walk (a strafing target), metres per second; the sim moves it.
var walk: Vector2 = Vector2.ZERO
var knock: Vector2 = Vector2.ZERO
var radius_m: float = 0.35
var hp: float = 100.0
var max_hp: float = 100.0
var metal: bool = false
var team: int = Projectile.TEAM_ENEMY
var burn_ticks: int = 0
var burn_dps: float = 0.0
var stun_ticks: int = 0
var hurt_tick: int = -1000000


static func make(p_id: int, at: Vector2, hp_max: float, radius: float) -> RangeTarget:
	var t: RangeTarget = RangeTarget.new()
	t.id = p_id
	t.pos = at
	t.hp = hp_max
	t.max_hp = hp_max
	t.radius_m = radius
	return t


func alive() -> bool:
	return hp > 0.0


## Burning targets panic (enemy-ai reads this to break cover and run).
func panicking() -> bool:
	return burn_ticks > 0


func step() -> void:
	if stun_ticks <= 0:
		pos += walk * SimClock.TICK_DT
	pos += knock * SimClock.TICK_DT
	knock *= KNOCK_DECAY_PER_TICK
	stun_ticks = maxi(stun_ticks - 1, 0)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(id)
	out.put_float(pos.x)
	out.put_float(pos.y)
	out.put_float(hp)
	out.put_32(burn_ticks)
	out.put_32(stun_ticks)
