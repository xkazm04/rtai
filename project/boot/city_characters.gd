class_name CityCharacters
extends RefCounted
## Composition-root glue between the city and the characters (LAY-05: neither feature knows the
## other). Each frame, right before the crowd is written, it fills lane B's RigFeed from the
## sim's people near the focus (plus Rivet), steps CharacterRigs on the fixed tick, and tells the
## sim which slots a full rig draws, so the MultiMesh crowd skips them. Beyond the 16 nearest
## within 14 m, people draw from the baked crowd atlas. Render-side only: it reads sim state and
## writes none (parity and replay are untouched).

const RIVET_ID: int = 1 << 20
const FEED_RADIUS_M: float = CharacterRigs.RADIUS_M + 4.0

## Rivet stands at the city's target (on foot); false while Rivet is in a car.
var rivet_on_foot: bool = true
var rigs: CharacterRigs = CharacterRigs.new()
## Frames where no sim tick passed and the rig pass was skipped (bench evidence).
var skipped_frames: int = 0
## The combat blood on the city (noir's blood, the D4/D5 default; boot/city_blood.gd).
var blood: CityBlood = null
var _primed: bool = false
var _city: CitySystem
var _view: CityView
var _clock: SimClock
var _last_tick: int = 0
var _rivet_prev: Vector2 = Vector2.ZERO
var _slots: Array[int] = []


func _init(city: CitySystem, view: CityView, ctx: WorldContext) -> void:
	_city = city
	_view = view
	_clock = ctx.clock
	view.clock = ctx.clock
	_last_tick = _clock.tick()
	_rivet_prev = city.target
	rigs.z_index = RenderLayers.z(&"actors")
	view.actor_layer().add_child(rigs)
	rigs.setup(ctx)
	rigs.set_process(false)
	view.before_render = _before_render
	blood = CityBlood.attach(city, view)


## At load: bakes the crowd atlas (a no-op headless) and switches the people layer to it.
func bake() -> void:
	await rigs.bake_crowd()
	if not rigs.atlas.baked:
		return
	var people: MultiMeshInstance2D = _view.crowd.nodes[SimConst.RL_PEDS]
	people.texture = rigs.atlas.texture
	people.material = rigs.atlas.crowd_material()
	_city.sim.set_render(_view.crowd.rids(), CrowdAtlas.clip_table())
	_city.sim.set_person_px(CrowdAtlas.cell_world_px())


## The rigs only move on a sim tick: on a frame where no tick passed (a display faster than
## 60 Hz, or a second frame inside one tick) the feed, the pose and the rig slots are all
## unchanged, so the whole rig pass is skipped (lane A measured rig p99 0.57 ms against 0.3).
func _before_render(focus: Vector2) -> void:
	PartMaterials.set_world_px(_view.world_px)  # every frame: the camera moves between ticks
	var steps: int = clampi(_clock.tick() - _last_tick, 0, CharacterRigs.MAX_STEPS)
	if steps == 0 and _primed and is_equal_approx(rigs.zoom, _view.zoom):
		rigs.last_us = 0
		skipped_frames += 1
		return
	_primed = true
	_fill_feed(focus)
	if _view.look_params != null:
		PartMaterials.set_flat_below(_view.look_params.parts_flat_below)
	rigs.focus = focus * SimConst.PX_PER_M
	rigs.zoom = _view.zoom
	_last_tick = _clock.tick()
	rigs.step_ticks(steps)
	_slots.clear()
	for i: int in rigs.feed.count:
		if rigs.full_row(i) and rigs.feed.ids[i] != RIVET_ID:
			_slots.append(rigs.feed.ids[i])
	_city.sim.set_rig_slots(PackedInt32Array(_slots))


## One row per live person within FEED_RADIUS_M of the focus, then Rivet.
func _fill_feed(focus: Vector2) -> void:
	var snap: PackedFloat64Array = _city.sim.snapshot()
	if _view.fx_feed != null:
		_view.fx_feed.observe(snap, _clock.tick())
	var variants: PackedByteArray = _city.sim.get_variants()
	var feed: RigFeed = rigs.feed
	feed.count = 0
	var r2: float = FEED_RADIUS_M * FEED_RADIUS_M
	var aim: Vector2 = _city.target * SimConst.PX_PER_M
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] >= SimConst.SNAP_PROJ_BASE:
			break  # projectile records (stride 3) follow every actor: not people
		var kind: int = int(snap[r + 1])
		if kind != SimConst.K_PED and kind != SimConst.K_COP:
			continue
		var p: Vector2 = Vector2(snap[r + 4], snap[r + 5])
		if p.distance_squared_to(focus) > r2:
			continue
		_put_person(feed, snap.slice(r, r + SimConst.SNAP_STRIDE), variants, aim)
	if rivet_on_foot:
		var at: Vector2 = _city.target * SimConst.PX_PER_M
		var vel: Vector2 = (at - _rivet_prev) / SimClock.TICK_DT
		_rivet_prev = at
		@warning_ignore("return_value_discarded")
		feed.put(feed.count, RIVET_ID, BodyPlan.Kind.RIVET, at, vel)


static func _put_person(
	feed: RigFeed, a: PackedFloat64Array, variants: PackedByteArray, aim: Vector2
) -> void:
	var slot: int = int(a[0])
	var cop: bool = int(a[1]) == SimConst.K_COP
	var mode: int = int(a[2])
	var head: Vector2 = Vector2(a[6], a[7])
	var px: float = SimConst.PX_PER_M
	var kind: BodyPlan.Kind = BodyPlan.Kind.COP if cop else BodyPlan.Kind.PED
	var i: int = feed.put(feed.count, slot, kind, Vector2(a[4], a[5]) * px, head * a[8] * px)
	feed.looks[i] = variants[slot] if slot < variants.size() else RigFeed.LOOK_AUTO
	feed.face[i] = head.angle()
	var fl: int = 0
	if mode == SimConst.M_DEAD:
		fl |= RigFeed.Flag.DEAD
	elif mode == SimConst.M_FLEE or mode == SimConst.M_RIOT:
		fl |= RigFeed.Flag.FLEE
	if cop and mode != SimConst.M_DEAD:
		fl |= RigFeed.Flag.GUN_OUT
		feed.aim[i] = aim
		if a[10] > 0.0:
			fl |= RigFeed.Flag.AIMING
	feed.flags[i] = fl
