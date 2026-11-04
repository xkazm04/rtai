class_name FightScorch
extends RefCounted
## The burnt ground a fire patch leaves when it goes out (molotov, flamethrower run-off): the
## patch's ink char (FightScorchArt) stays printed for HOLD_TICKS, then fades over FADE_TICKS.
## It starts at the strength the live patch ends on, so the flames die off a char that stays.
## A rocket's blast scorches the ground it hit the same way. The mini-nuke leaves none (its own
## floor prints ground zero). View state only:
## GunFx steps it from the drawn tick, it reads FightAreas and never writes it. Lane gunplay.

const HOLD_TICKS: int = 900
const FADE_TICKS: int = 120
const MAX_MARKS: int = 24
## The live patch's char strength at its last tick (FightAreasArt._patch: 0.7 + fade * 0.3).
const START_K: float = 0.7
## A blast this wide or wider scorches (the rocket's 3.5 m; the homing shard's 1.2 m pops do not).
const MIN_BLAST_M: float = 2.0
## The scorch's radius as a share of the blast's splash radius.
const BLAST_K: float = 0.4

## Burnt marks: x, y, the radius (m), the tick the fire went out.
var marks: Array[Vector4] = []
## Patches seen on the last step: centre -> radius.
var _live: Dictionary[Vector2, float] = {}
## The born tick of the newest blast already scorched.
var _seen_blast: int = -1


func step(areas: FightAreas, tick: int) -> void:
	var now: Dictionary[Vector2, float] = {}
	if areas != null:
		for p: Vector4 in areas.patches:
			if p.z < FightAreasArt.RING_PATCH_M:
				now[Vector2(p.x, p.y)] = p.z
	for c: Vector2 in _live:
		if not now.has(c):
			marks.append(Vector4(c.x, c.y, _live[c], tick))
	_live = now
	if areas != null:
		_blasts(areas, now)
	while marks.size() > MAX_MARKS:
		marks.remove_at(0)
	while not marks.is_empty() and tick - int(marks[0].w) >= HOLD_TICKS + FADE_TICKS:
		marks.remove_at(0)


func draw(ci: CanvasItem, tick: int) -> void:
	for m: Vector4 in marks:
		var left: int = HOLD_TICKS + FADE_TICKS - (tick - int(m.w))
		var k: float = clampf(float(left) / float(FADE_TICKS), 0.0, 1.0)
		FightScorchArt.blotch(ci, Vector2(m.x, m.y), m.z, START_K * k)


## New blasts leave their scorch at once (it prints under the starburst), held from the blast
## tick. A bottle's burst is left to its fire patch (same centre), the nuke to its own floor.
func _blasts(areas: FightAreas, now: Dictionary[Vector2, float]) -> void:
	var newest: int = _seen_blast
	for i: int in areas.blasts.size():
		var b: Vector3 = areas.blasts[i]
		var born: int = areas.blast_ticks[i]
		if born <= _seen_blast or b.z < MIN_BLAST_M or b.z >= FightNukeArt.NUKE_M:
			continue
		newest = maxi(newest, born)
		if not now.has(Vector2(b.x, b.y)):
			marks.append(Vector4(b.x, b.y, b.z * BLAST_K, born))
	_seen_blast = newest
