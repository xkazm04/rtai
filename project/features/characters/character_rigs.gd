class_name CharacterRigs
extends Node2D
## The characters view: full cutout rigs for the nearest MAX_FULL people within RADIUS_M of the
## focus (LOD 0), the baked crowd atlas for everyone else (LOD 1, drawn by the city's MultiMesh
## people layer). Render-side: it reads the 60 Hz tick from ctx.clock and steps each full rig
## once per sim tick with TICK_DT (never a frame delta), draws no RNG stream, writes no state.
## Integration (lane A): setup(ctx) once at load (prewarms the pools), fill `feed` every tick,
## set `focus` (world px) and `zoom`, give the people layer `atlas` + CrowdAtlas.clip_table(),
## and draw rows where full_row(i) is false from the atlas (cell: baked_cell(i, t)).

const MAX_FULL: int = 16
## LOD 0b: past the nearest FULL_RATE rigs, a rig poses on alternate ticks with twice the step
## (the spike's half-rate crowd LOD: the gait phase and planted feet stay true); past HALF_RATE,
## every 4th tick with four times the step (LOD 0c, RigSprings sub-steps the springs). The rig
## still moves to its sim position every frame; only the limbs pose at 30 / 15 Hz.
const FULL_RATE: int = 4
const HALF_RATE: int = 8
## At arena zoom (64 px/m, zoom 2) the rigs are twice the size and nearly all on screen, while an
## arena holds few people: no quarter tier there (ranks past HALF_RATE pose at half rate).
const ARENA_ZOOM: float = 1.9
const RADIUS_M: float = 14.0
## The nearest-N selection (a GDScript scan of the whole feed, ~0.1 ms in a riot) runs every
## SELECT_EVERY calls; between, the kept rigs only find their rows again (a native find).
const SELECT_EVERY: int = 4
const PX_PER_M: float = 32.0
const MAX_STEPS: int = 4
const PREWARM: Dictionary[int, int] = {
	BodyPlan.Kind.RIVET: 1, BodyPlan.Kind.COP: MAX_FULL, BodyPlan.Kind.PED: MAX_FULL
}

var feed: RigFeed = RigFeed.new(512)
var focus: Vector2 = Vector2.ZERO
var zoom: float = 1.0
var atlas: CrowdAtlas = CrowdAtlas.new()
## The D5 twin of the crowd atlas, shown by the people layer while the RigDetail tier is on.
var atlas_d5: CrowdAtlas = CrowdAtlas.make_d5()
var prewarm_ms: float = 0.0
## Per-frame cost of the rig work (selection + pose steps), for the section 20 rig budget.
var last_us: int = 0
var ticks_stepped: int = 0

var _clock: SimClock = null
var _last_tick: int = 0
var _pool: RigPool = RigPool.new()
var _by_actor: Dictionary[int, CutRig] = {}
var _full: PackedByteArray = PackedByteArray()
var _rank: Dictionary[int, int] = {}
var _select_in: int = 0


func setup(ctx: WorldContext) -> void:
	_clock = ctx.clock
	_last_tick = _clock.tick()
	add_child(_pool)
	for kind: int in PREWARM:
		prewarm_ms += _pool.prewarm(kind as BodyPlan.Kind, PREWARM[kind])
	Log.info("characters", "prewarmed %d rigs in %.1f ms" % [rig_count(), prewarm_ms])


## Bakes the crowd atlas and its D5 twin (await at load; a no-op headless).
func bake_crowd() -> void:
	for a: CrowdAtlas in [atlas, atlas_d5]:
		var baker: CrowdBaker = CrowdBaker.new()
		add_child(baker)
		await baker.bake(a)
		baker.queue_free()


## The crowd atlas the people layer shows now: the D5 twin while the RigDetail tier is on.
func crowd_texture() -> Texture2D:
	var d5: bool = RigDetail.active and RigDetail.enabled and atlas_d5.baked
	return atlas_d5.texture if d5 else atlas.texture


func _process(_delta: float) -> void:
	if _clock == null:
		return
	var steps: int = clampi(_clock.tick() - _last_tick, 0, MAX_STEPS)
	_last_tick = _clock.tick()
	step_ticks(steps)


## Selection, then `steps` fixed pose steps for every full rig. Tests and benches call it directly.
func step_ticks(steps: int) -> void:
	var t0: int = Time.get_ticks_usec()
	PartMaterials.set_view(zoom)
	var d5: bool = RigDetail.set_view(zoom)
	_assign()
	for actor: int in _by_actor:
		if d5 or RigDetail.is_on(_by_actor[actor]):
			RigDetail.sync(_by_actor[actor])
	for _k: int in steps:
		ticks_stepped += 1
		for actor: int in _by_actor:
			var every: int = rate_of(_rank[actor], zoom)
			if (ticks_stepped + actor) % every == 0:
				_by_actor[actor].drive(SimClock.TICK_DT * every)
	last_us = Time.get_ticks_usec() - t0


## Ticks between pose steps for the rig at nearest-rank r: 1 (full), 2 (half) or 4 (quarter; half
## at arena zoom).
static func rate_of(r: int, view_zoom: float = 1.0) -> int:
	if r < FULL_RATE:
		return 1
	return 2 if r < HALF_RATE or view_zoom >= ARENA_ZOOM else 4


func full_row(i: int) -> bool:
	return i < _full.size() and _full[i] == 1


func full_count() -> int:
	return _by_actor.size()


func rig_count() -> int:
	var n: int = 0
	for kind: int in PREWARM:
		n += _pool.built_count(kind as BodyPlan.Kind)
	return n


func pool() -> RigPool:
	return _pool


func rig_for(actor_id: int) -> CutRig:
	return _by_actor.get(actor_id, null)


## The atlas cell of a row drawn by the crowd layer, at clip time t (s).
func baked_cell(i: int, t: float) -> int:
	var c: CrowdAtlas.Clip = CrowdAtlas.clip_of(feed, i)
	return CrowdAtlas.cell_for(feed.look_of(i), c, t)


func _assign() -> void:
	_select_in -= 1
	if _select_in > 0 and _remap():
		return
	_select_in = SELECT_EVERY
	var chosen: PackedInt32Array = RigSelect.nearest(feed, focus, RADIUS_M * PX_PER_M, MAX_FULL)
	@warning_ignore("return_value_discarded")
	_full.resize(feed.count)
	_full.fill(0)
	var keep: Dictionary[int, int] = {}
	_rank.clear()
	for r: int in chosen.size():
		var i: int = chosen[r]
		keep[feed.ids[i]] = i
		_rank[feed.ids[i]] = r
		_full[i] = 1
	for actor: int in _by_actor.keys():
		if not keep.has(actor):
			_pool.release(_by_actor[actor])
			@warning_ignore("return_value_discarded")
			_by_actor.erase(actor)
	for actor: int in keep:
		var i: int = keep[actor]
		if not _by_actor.has(actor):
			_by_actor[actor] = _acquire(i)
		RigInput.apply(_by_actor[actor], feed, i)


## Between selections the feed is rebuilt (rows move): each kept rig finds its row by actor id
## and takes its input. False when a kept actor left the feed (the caller then reselects).
func _remap() -> bool:
	@warning_ignore("return_value_discarded")
	_full.resize(feed.count)
	_full.fill(0)
	for actor: int in _by_actor:
		var i: int = feed.ids.find(actor)
		if i < 0 or i >= feed.count:
			return false
		_full[i] = 1
		RigInput.apply(_by_actor[actor], feed, i)
	return true


func _acquire(i: int) -> CutRig:
	var kind: BodyPlan.Kind = feed.kinds[i] as BodyPlan.Kind
	var look: RigVariant = RigVariant.rivet()
	if kind != BodyPlan.Kind.RIVET:
		look = RigVariant.crowd(feed.look_of(i))
		if look.kind != kind:  # a look of another body plan: fall back to the actor's own pick
			look = RigVariant.crowd(RigVariant.crowd_index_for(feed.ids[i], kind))
	var rig: CutRig = _pool.acquire(kind, look, feed.pos[i], feed.face[i])
	rig.actor_id = feed.ids[i]
	return rig
