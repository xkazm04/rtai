class_name CorpseStains
extends Node2D
## Blood on the dead (lane d5-combat; noir's BloodStains, made riot-cheap), in the city and in
## quest 1: each kill the combat blood sprays (CombatBlood.bled) soaks the nearest fresh body
## (the city's rig feed, or any host's id -> px map) with red stains, a little toward the exit
## side of the round. One cached node per body: its stains are drawn ONCE, then only its
## transform follows the sliding body and its scale grows the soak (no per-tick redraw: noir's
## per-tick _draw was ~13 circles a stain). A body that leaves the dead (despawned after 8 s,
## or its slot reused) takes its stains with it. On the actors band, each body's node SOAK_Z
## above it (a rig's parts stay under +30: body_plan arm_above 10), so the stains lie on the
## dead; printed with the blood's material. That z also lifts them over a living body on the
## same band, so a soak fades out while a walker (Rivet, or anyone alive) stands on its body.
## Data: blood_fx.json stain.<row>. Counter-hash scatter, stepped on the sim tick. Render only.

const MATCH_M: float = 1.5
const SOAK_Z: int = 60
## Ticks a death waits for its body to show up dead in the feed before it is dropped.
const WAIT_TICKS: int = 6
## A walker this close (m) hides the soak; it is whole again past CLEAR_M.
const COVER_M: float = 0.4
const CLEAR_M: float = 0.9

var row: String = "corpse"
## Bodies soaked so far, and deaths that never found their body (evidence).
var soaked: int = 0
var missed: int = 0
## Where the walkers stand (px): living bodies the soaks must not draw over (step() fills
## every living row of the rig feed; a host using step_bodies sets it).
var walkers: PackedVector2Array = PackedVector2Array()
## False draws the soaks over the walkers too (the before frame of that change).
var fade_walkers: bool = true
## Callable(body id) -> float: the body's own fade (CorpseDecay in the live fight); unset = 1.
var body_alpha: Callable = Callable()
## The first tick a walker stood on a soaked body (evidence captures; -1 = not yet).
var first_cover: int = -1
## CPU microseconds spent in step since boot, and the steps (the riot budget, STANDARDS 20).
var spent_us: int = 0
var steps: int = 0
var _p: Dictionary = {}
var _grow: int = 24
var _blood: Color = Color(0.64, 0.02, 0.035)
var _dark: Color = Color(0.46, 0.0, 0.03)
var _soaks: Array[Soak] = []
var _next: int = 0
## Waiting deaths: x, y (px), heading angle, tick seen.
var _pending: Array[Vector4] = []
## Waiting named deaths: body id -> Vector2(heading angle, tick seen).
var _named: Dictionary[int, Vector2] = {}
var _k: int = 0
var _tick: int = 0


## One body's stains, drawn once (local px around the body's centre).
class Soak:
	extends Node2D
	var slot: int = -1
	var born: int = 0
	var spots: PackedVector3Array = PackedVector3Array()
	var dirs: PackedVector2Array = PackedVector2Array()
	var blood: Color
	var dark: Color

	func _draw() -> void:
		for i: int in spots.size():
			var s: Vector3 = spots[i]
			var at: Vector2 = Vector2(s.x, s.y)
			draw_circle(at, s.z * 1.15, dark)
			BloodMarks.splat(self, at, s.z, dirs[i] * 0.45, blood)


## `dark` = the spots' shadow (the blood's pool body); transparent = blood_fx.json blood_dark.
func _init(
	bodies: int = 16, ground: Color = Color(0.64, 0.02, 0.035), dark: Color = Color.TRANSPARENT
) -> void:
	z_index = RenderLayers.z(&"actors")
	var d: Dictionary = NoirLook.read_params(BloodFx.PARAMS)
	_p = d.get("stain", {})
	_grow = _p.get("grow_ticks", _grow)
	var c: Dictionary = d.get("colour", {})
	_dark = dark if dark.a > 0.0 else NoirPack.rgb(c.get("blood_dark", [0.46, 0.0, 0.03]))
	_blood = ground
	for i: int in bodies:
		var s: Soak = Soak.new()
		s.visible = false
		s.z_index = SOAK_Z
		s.use_parent_material = true
		_soaks.append(s)
		add_child(s)


## A human sprayed at `pos_px` by a blow along `dir` (connect to CombatBlood.bled).
func on_bled(pos_px: Vector2, dir: Vector2) -> void:
	_pending.append(Vector4(pos_px.x, pos_px.y, dir.angle(), _tick))


## Body `id` killed by a blow along `dir` (connect to CombatBlood.bled_body when the host
## names its victims: the exact body, never a neighbour in a pile).
func on_bled_body(id: int, dir: Vector2) -> void:
	_named[id] = Vector2(dir.angle(), _tick)


## Advances to sim tick `tick` against `feed` (the city's RigFeed: dead rows carry Flag.DEAD).
func step(tick: int, feed: RigFeed) -> void:
	var t0: int = Time.get_ticks_usec()
	var dead: Dictionary[int, Vector2] = {}
	walkers.clear()
	for i: int in feed.count:
		if (feed.flags[i] & RigFeed.Flag.DEAD) != 0:
			dead[feed.ids[i]] = feed.pos[i]
		else:
			@warning_ignore("return_value_discarded")
			walkers.append(feed.pos[i])
	step_bodies(tick, dead)
	spent_us += Time.get_ticks_usec() - t0
	steps += 1


## Advances to sim tick `tick` against `dead`: body id -> where it lies (px). Any host (the
## city's rig feed, quest 1's CombatArena) hands its dead this way.
func step_bodies(tick: int, dead: Dictionary[int, Vector2]) -> void:
	_tick = tick
	_match(dead)
	for s: Soak in _soaks:
		if s.slot < 0:
			continue
		if not dead.has(s.slot):
			s.slot = -1
			s.visible = false
			continue
		s.position = dead[s.slot]
		s.scale = Vector2.ONE * clampf(float(tick - s.born) / maxf(_grow, 1.0), 0.3, 1.0)
		s.modulate.a = _uncovered(s.position) if fade_walkers else 1.0
		if body_alpha.is_valid():
			var k: float = body_alpha.call(s.slot)
			s.modulate.a *= k


## 0 while a walker stands on the body at `at` (px), 1 once every walker is CLEAR_M away.
func _uncovered(at: Vector2) -> float:
	var a: float = 1.0
	var clear2: float = pow(CLEAR_M * SimConst.PX_PER_M, 2.0)
	for w: Vector2 in walkers:
		if at.distance_squared_to(w) < clear2:
			var m: float = at.distance_to(w) / SimConst.PX_PER_M
			a = minf(a, smoothstep(COVER_M, CLEAR_M, m))
	if a < 0.5 and first_cover < 0:
		first_cover = _tick
	return a


## The soaked body nearest `at` (px), or `at` when none is soaked (evidence captures).
func nearest_soak(at: Vector2) -> Vector2:
	var out: Vector2 = at
	var best: float = INF
	for s: Soak in _soaks:
		if s.slot >= 0 and at.distance_to(s.position) < best:
			best = at.distance_to(s.position)
			out = s.position
	return out


## Bodies carrying stains now (tests, evidence).
func active() -> int:
	var n: int = 0
	for s: Soak in _soaks:
		n += 1 if s.slot >= 0 else 0
	return n


func _match(dead: Dictionary[int, Vector2]) -> void:
	for id: int in _named.keys():
		var w: Vector2 = _named[id]
		if dead.has(id) or _tick - int(w.y) >= WAIT_TICKS:
			if dead.has(id) and not _soaked(id):
				_soak(id, Vector2.from_angle(w.x))
			elif not dead.has(id):
				missed += 1
			@warning_ignore("return_value_discarded")
			_named.erase(id)
	var keep: Array[Vector4] = []
	for d: Vector4 in _pending:
		var slot: int = _nearest(dead, Vector2(d.x, d.y))
		if slot >= 0:
			_soak(slot, Vector2.from_angle(d.z))
		elif _tick - int(d.w) < WAIT_TICKS:
			keep.append(d)
		else:
			missed += 1
	_pending = keep


## The nearest dead slot within MATCH_M of `at` that carries no stains yet, else -1.
func _nearest(dead: Dictionary[int, Vector2], at: Vector2) -> int:
	var best: float = MATCH_M * SimConst.PX_PER_M
	var out: int = -1
	for slot: int in dead:
		var gap: float = at.distance_to(dead[slot])
		if gap < best and not _soaked(slot):
			best = gap
			out = slot
	return out


func _soaked(slot: int) -> bool:
	for s: Soak in _soaks:
		if s.slot == slot:
			return true
	return false


func _soak(slot: int, dir: Vector2) -> void:
	var s: Soak = _soaks[_next]
	_next = (_next + 1) % _soaks.size()
	var r: Dictionary = _p.get(row, _p.get("kill", {}))
	var n: int = r.get("spots", 5)
	var radii: Array = r.get("r_px", [1.6, 3.6])
	var spread: float = r.get("spread_px", 4.0)
	var exit: float = r.get("exit_px", 4.0)
	s.spots.clear()
	s.dirs.clear()
	for i: int in n:
		var jitter: Vector2 = Vector2(_rand() - 0.5, _rand() - 0.5) * 2.0 * spread
		var r0: float = radii[0]
		var r1: float = radii[1]
		var rad: float = lerpf(r0, r1, _rand())
		var off: Vector2 = dir * exit * (0.4 + _rand()) + jitter
		@warning_ignore("return_value_discarded")
		s.spots.append(Vector3(off.x, off.y, rad))
		@warning_ignore("return_value_discarded")
		s.dirs.append(dir.rotated((_rand() - 0.5) * 1.2))
	s.slot = slot
	s.born = _tick
	s.blood = _blood
	s.dark = _dark
	s.visible = true
	s.queue_redraw()
	soaked += 1


func _rand() -> float:
	_k += 1
	return fposmod(sin(_k * 91.3458 + 7.13) * 47453.5453, 1.0)
