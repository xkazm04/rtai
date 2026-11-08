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
## n9 (the owner's s-4 C): on Rivet's rig while a car's knock-down lasts, removed when he is up:
## Vector3(the car's ground heading x, y, SimClock tick at the hit). Lane rivet reads it for the
## drawn knock-down; until then his row carries RigFeed.Flag.DOWN (the tackle sprawl and rise).
const KNOCK_META: StringName = &"rivet_knock"

## Rivet stands at the city's target (on foot); false while Rivet is in a car.
var rivet_on_foot: bool = true
var rigs: CharacterRigs = CharacterRigs.new()
## Frames where no sim tick passed and the rig pass was skipped (bench evidence).
var skipped_frames: int = 0
## The combat blood on the city (noir's blood, the D4/D5 default; boot/city_blood.gd).
var blood: CityBlood = null
## human-reactions: pedestrians whose flight just began cower first (features/combat/react).
var crowd: CrowdReact = CrowdReact.make()
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
	rigs.corpse_hold_ticks = RigSelect.CORPSE_HOLD_TICKS  # the crowd atlas takes the corpse after
	view.before_render = _before_render
	blood = CityBlood.attach(city, view)
	blood.follow(rigs.feed)


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
	crowd.observe(rigs, maxi(steps, 1))  # human-reactions: a startled pedestrian cowers
	if _view.look_params != null:
		PartMaterials.set_flat_below(_view.look_params.parts_flat_below)
	rigs.focus = focus * SimConst.PX_PER_M
	rigs.zoom = _view.zoom
	_last_tick = _clock.tick()
	rigs.step_ticks(steps)
	_mark_knock()
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
		_put_person(feed, snap, r, variants, aim)  # by offset: no slice allocated a person
	if rivet_on_foot:
		var at: Vector2 = _city.target * SimConst.PX_PER_M
		var vel: Vector2 = (at - _rivet_prev) / SimClock.TICK_DT
		_rivet_prev = at
		var row: int = feed.put(feed.count, RIVET_ID, BodyPlan.Kind.RIVET, at, vel)
		if _city.body != null and _city.body.knocked():
			feed.flags[row] |= RigFeed.Flag.DOWN


## Sets or clears KNOCK_META on Rivet's rig from the city body (read only: the sim owns the knock).
func _mark_knock() -> void:
	var rig: CutRig = rigs.rig_for(RIVET_ID)
	if rig == null:
		return
	var b: RivetBody = _city.body
	if rivet_on_foot and b != null and b.knocked():
		if not rig.has_meta(KNOCK_META):
			var h: Vector2 = b.knock_heading
			rig.set_meta(KNOCK_META, Vector3(h.x, h.y, float(_clock.tick())))
	elif rig.has_meta(KNOCK_META):
		rig.remove_meta(KNOCK_META)


## The actor record at offset `r` of `a` (a snapshot) as one feed row.
static func _put_person(
	feed: RigFeed, a: PackedFloat64Array, r: int, variants: PackedByteArray, aim: Vector2
) -> void:
	var slot: int = int(a[r])
	var cop: bool = int(a[r + 1]) == SimConst.K_COP
	var mode: int = int(a[r + 2])
	var head: Vector2 = Vector2(a[r + 6], a[r + 7])
	var px: float = SimConst.PX_PER_M
	var kind: BodyPlan.Kind = BodyPlan.Kind.COP if cop else BodyPlan.Kind.PED
	var i: int = feed.put(
		feed.count, slot, kind, Vector2(a[r + 4], a[r + 5]) * px, head * a[r + 8] * px
	)
	feed.looks[i] = variants[slot] if slot < variants.size() else RigFeed.LOOK_AUTO
	feed.face[i] = head.angle()
	var fl: int = 0
	if mode == SimConst.M_DEAD:
		fl |= RigFeed.Flag.DEAD
	elif mode == SimConst.M_DOWN:
		fl |= RigFeed.Flag.DOWN
	elif mode == SimConst.M_FLEE or mode == SimConst.M_RIOT:
		fl |= RigFeed.Flag.FLEE
	if cop and mode != SimConst.M_DEAD and mode != SimConst.M_DOWN:
		fl |= RigFeed.Flag.GUN_OUT
		feed.aim[i] = aim
		if a[r + 10] > 0.0:
			fl |= RigFeed.Flag.AIMING
	feed.flags[i] = fl
