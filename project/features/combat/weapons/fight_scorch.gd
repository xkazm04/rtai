class_name FightScorch
extends RefCounted
## The burnt ground a fire patch leaves when it goes out (molotov, flamethrower run-off): the
## patch's ink char (FightScorchArt) stays printed for HOLD_TICKS, then fades over FADE_TICKS.
## It starts at the strength the live patch ends on, so the flames die off a char that stays.
## The mini-nuke's ring patch leaves none (its own floor prints ground zero). View state only:
## GunFx steps it from the drawn tick, it reads FightAreas and never writes it. Lane gunplay.

const HOLD_TICKS: int = 900
const FADE_TICKS: int = 120
const MAX_MARKS: int = 24
## The live patch's char strength at its last tick (FightAreasArt._patch: 0.7 + fade * 0.3).
const START_K: float = 0.7

## Burnt marks: x, y, the radius (m), the tick the fire went out.
var marks: Array[Vector4] = []
## Patches seen on the last step: centre -> radius.
var _live: Dictionary[Vector2, float] = {}


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
	while marks.size() > MAX_MARKS:
		marks.remove_at(0)
	while not marks.is_empty() and tick - int(marks[0].w) >= HOLD_TICKS + FADE_TICKS:
		marks.remove_at(0)


func draw(ci: CanvasItem, tick: int) -> void:
	for m: Vector4 in marks:
		var left: int = HOLD_TICKS + FADE_TICKS - (tick - int(m.w))
		var k: float = clampf(float(left) / float(FADE_TICKS), 0.0, 1.0)
		FightScorchArt.blotch(ci, Vector2(m.x, m.y), m.z, START_K * k)
