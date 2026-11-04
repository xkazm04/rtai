class_name SignatureKills
extends RefCounted
## The signature-kill framework (lane brutality), sim side. Fed the kill event (CombatArena.struck:
## victim, direction, lethal, weapon id): a lethal hit by a weapon with a signature_kills.json row
## replaces the standard death on that human. The victim is marked consumed (views hide its body),
## its parts are thrown into GibSim and its marks left in KillMarks, all from this lane's RNG
## stream on the 60 Hz tick. A kill's hit-stop holds the gibs `hitstop_ticks` before they fly.
## Robots never take a signature kill (they spark; robots and bosses are resolved later).

signal killed(victim_id: int, serial: int, row: SignatureKill, at: Vector2, dir: Vector2)

## A part's speed kept off a wall it hit (the rest is lost into the wall).
const WALL_REBOUND: float = 0.3
## The body-local start of each piece (metres; x along the facing, y to the right).
const OFFSETS: PackedVector2Array = [
	Vector2(0.05, 0.0),
	Vector2(0.0, 0.0),
	Vector2(0.0, -0.28),
	Vector2(0.0, 0.28),
	Vector2(-0.12, -0.12),
	Vector2(-0.12, 0.12)
]

var table: SignatureKillTable = null
var gibs: GibSim = GibSim.new()
var marks: KillMarks = null
## victim fighter id -> kill serial, for every human a signature kill consumed.
var consumed: Dictionary[int, int] = {}
var tick: int = 0
var hold: int = 0
var by_style: Dictionary[StringName, int] = {}
## Callable(pos_m: Vector2) -> Vector2: the stage's wall push-out for a part (none = no walls).
var push_out: Callable = Callable()
var _rng: RandomNumberGenerator = null


func _init(p_table: SignatureKillTable, rng: RandomNumberGenerator) -> void:
	table = p_table
	_rng = rng
	marks = KillMarks.new(table.leftover_budget)


## The kill event: true when a signature kill replaced the standard death (the victim's facing
## turns the piece offsets; a robot never takes a row).
func on_kill(e: KillEvent) -> bool:
	var row: SignatureKill = table.for_weapon(e.weapon) if e.human else null
	if row == null or consumed.has(e.victim_id):
		return false
	var victim_id: int = e.victim_id
	var at: Vector2 = e.at
	var d: Vector2 = e.dir.normalized() if e.dir != Vector2.ZERO else Vector2.RIGHT
	var offs: PackedVector2Array = PackedVector2Array()
	for o: Vector2 in OFFSETS:
		@warning_ignore("return_value_discarded")
		offs.append(o.rotated(e.facing.angle()))
	var serial: int = gibs.throw(row, at, d, offs, _rng)
	@warning_ignore("return_value_discarded")
	marks.leave(row, at, d, tick, _rng)
	consumed[victim_id] = serial
	by_style[row.style] = by_style.get(row.style, 0) + 1
	hold = maxi(hold, row.hitstop_ticks)
	killed.emit(victim_id, serial, row, at, d)
	return true


## One 60 Hz tick: the hit-stop holds, then the gibs fly.
func step(p_tick: int) -> void:
	tick = p_tick
	if hold > 0:
		hold -= 1
		return
	gibs.step()
	if push_out.is_valid():
		_collide()


## Walls stop the parts: a piece pushed out of a wall loses the speed it had into it and
## rebounds a little (deterministic: the stage's own push-out, no dice).
func _collide() -> void:
	for i: int in GibSim.CAPACITY:
		if not gibs.live(i) or gibs.at_rest(i):
			continue
		var p: Vector2 = gibs.pos[i]
		var out: Vector2 = push_out.call(p)
		if out == p:
			continue
		var n: Vector2 = (out - p).normalized()
		var into: float = gibs.vel[i].dot(n)
		gibs.pos[i] = out
		if into < 0.0:
			gibs.vel[i] -= n * into * (1.0 + WALL_REBOUND)


func write_state(out: StreamPeerBuffer) -> void:
	gibs.write_state(out)
	marks.write_state(out)
	out.put_32(consumed.size())
