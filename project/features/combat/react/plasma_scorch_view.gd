class_name PlasmaScorchView
extends Node2D
## The plasma bolt's mark on a human it did not kill (owner note 2026-11-04, "hot and heavy"):
## a charred spot on the torso where the bolt went in, its rim glowing hot cream and cooling to
## an ember over GLOW_TICKS, a thin smoke column rising out of it for SMOKE_TICKS. Drawn above
## the rigs (ShockArcsView's layer), centred on the rig's drawn torso so it rides the stagger.
## ReactLink.scorched holds the marks (fighter id -> [[tick, hit dir in rig space]]); a dead
## fighter's marks go (the kill's hole takes over). Phases from the age only; render only, no RNG.

## 0.1 m was 5 px at 48 px/m and read only through its smoke (journal 14:29); 0.13 m = 6 px.
const SPOT_M: float = 0.13
const ENTRY_M: float = 0.07
const SIDE_M: float = 0.06
const GLOW_TICKS: int = 120
const SMOKE_TICKS: int = 150
const SMOKE_PUFFS: int = 3
const SMOKE_CYCLE: int = 40
const MAX_MARKS: int = 3
const CHAR: Color = Color(0.16, 0.11, 0.09)

var arena: CombatArena = null
var rigs: CharacterRigs = null
## The ArenaRigs whose ReactLink holds the marks (read every frame: the link lands after this).
var host: ArenaRigs = null


## Adds a mark on fighter `id`, hit along `local_dir` (rig space) on `tick` (oldest dropped).
static func mark(marks: Dictionary[int, Array], id: int, local_dir: Vector2, tick: int) -> void:
	var list: Array = marks.get(id, [])
	list.append([tick, local_dir.normalized() if local_dir != Vector2.ZERO else Vector2.LEFT])
	while list.size() > MAX_MARKS:
		list.pop_front()
	marks[id] = list


## Where mark `i` sits from the torso centre in rig space (m): the entry side, a little apart.
static func spot_of(local_dir: Vector2, i: int) -> Vector2:
	return -local_dir * ENTRY_M + local_dir.orthogonal() * SIDE_M * float(i % 3 - 1)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if arena == null or rigs == null or host == null or host.react == null:
		return
	var marks: Dictionary[int, Array] = host.react.scorched
	for h: Fighter in arena.hostiles:
		if not marks.has(h.id):
			continue
		var rig: CutRig = rigs.rig_for(h.id)
		if not h.alive():
			@warning_ignore("return_value_discarded")
			marks.erase(h.id)
			continue
		if rig == null or rig.torso == null:
			continue
		var c: Vector2 = to_local(rig.torso.global_position)
		var ppm: float = Ink.PX_PER_M * rig.global_transform.get_scale().x / CutRig.SC
		var list: Array = marks[h.id]
		for i: int in list.size():
			var m: Array = list[i]
			var local: Vector2 = m[1]
			var born: int = m[0]
			_spot(c + spot_of(local, i).rotated(rig.facing) * ppm, ppm, arena.tick - born)


## One scorch `age` ticks old at `at` (px).
func _spot(at: Vector2, ppm: float, age: int) -> void:
	var r: float = SPOT_M * ppm
	var k: float = clampf(float(age) / GLOW_TICKS, 0.0, 1.0)
	var glow: Color = KillHoleFx.HOT.lerp(KillHoleFx.EMBER, k)
	draw_circle(at, r * 1.7, Color(KillHoleFx.HOT, 0.5 * (1.0 - k)))  # the heat bloom
	draw_circle(at, r, CHAR)
	draw_arc(at, r, 0.0, TAU, 16, Color(glow, 1.0 - 0.5 * k), maxf(r * 0.35, 1.5), true)
	_smoke(at, r, age)


## A thin column out of the spot (screen up), swelling and thinning, fading over SMOKE_TICKS.
func _smoke(at: Vector2, r: float, age: int) -> void:
	if age < 0 or age >= SMOKE_TICKS:
		return
	var fade: float = 1.0 - float(age) / float(SMOKE_TICKS)
	for i: int in SMOKE_PUFFS:
		var p: float = float((age + i * SMOKE_CYCLE / SMOKE_PUFFS) % SMOKE_CYCLE) / SMOKE_CYCLE
		var sway: float = sin(float(age) * 0.09 + float(i) * 2.1) * r * 0.6
		var pos: Vector2 = at + Vector2(sway, -p * r * 6.0)
		var a: float = KillHoleFx.SMOKE.a * (1.0 - p) * fade
		var pr: float = r * (0.5 + 1.1 * p)
		draw_circle(pos, pr, Color(KillHoleFx.SMOKE, a))
		draw_arc(pos, pr, 0.0, TAU, 12, Color(KillHoleFx.INK, a * 0.8), 1.2, true)
