class_name CombatBlood
extends Node2D
## The default blood of the D4/D5 game (lane d5-combat): noir's BloodFx (pooled directional
## spurts, teardrop splats with satellites, spreading pools with wet edges, wall splats, decals
## that persist and fade) on the actors canvas's `blood` band: under the bodies, above the world
## print (the D4 print maps any red to its vermilion plate; blood keeps the protected arterial
## red and gets its own print, fx_blood_print). Fed by the FX cues (FxTriggers.cued): a `death`
## sprays along the round that killed (a projectile_end within MATCH_M on the same tick, else the
## body heading) and pools; Rivet's `player_hit` throws white sparks that land as black oil (a
## robot never bleeds). Mode `-- --blood=noir|ink|both` (blood_fx.json game.default): `ink` is
## the fallback D4 ink splat with the cream rim (fx.json ink_splat) and no blood; `noir` mutes
## that splat; `both` keeps it under the blood. Render only: counter-hash scatter, stepped on
## the sim tick (never a frame delta), nothing written back to the sim.

## A human sprayed at `pos_px` along `dir` (CorpseStains soaks the body).
signal bled(pos_px: Vector2, dir: Vector2)
## The same, when the host named the victim (listen(): Events.actor_killed's victim id).
signal bled_body(id: int, dir: Vector2)

const MODES: PackedStringArray = ["noir", "ink", "both"]
const SHADER: String = "res://assets/shaders/fx_blood_print.gdshader"
const MATCH_M: float = 1.5
const MAX_STEPS: int = 4
## Kill kinds (events.json) that leave no red (lane human-reactions): a body burned to death lies
## charred (HumanReact's char tint), its spray and soak read as a red blob over the char.
const DRY_KILLS: Array[StringName] = [&"burned", &"cauterised"]

var mode: String = "noir"
var blood: BloodFx = null
## Rivet's own fluid (blood_fx.json `player`: oil, sparks then black).
var oil: BloodFx = null
## ghost-powers: actor ids drawn as robots (ArenaRobotRigs): their death leaks oil, never red.
var robot_ids: Dictionary[int, bool] = {}
## Optional Callable(px: Vector2) -> bool: true inside a building or prop (wall splats).
var solid: Callable = Callable():
	set = set_solid
var kills: int = 0
var hits: int = 0
## Deaths that sprayed along the round that killed (the rest along the body heading).
var aimed: int = 0
## Microseconds the last step took (the riot budget, STANDARDS section 20).
var last_us: int = 0
## Ticks one step may catch up (the game: MAX_STEPS; a fast-forwarding frame grabber: more).
var max_steps: int = MAX_STEPS
## Frames stepped and the CPU microseconds spent (steps + redraws) since boot: the riot average.
var frames: int = 0
var spent_us: int = 0
## Where the player is (px), for the oil trail after a hit: Callable() -> Vector2 (INF = unknown).
var player_px: Callable = Callable()
## Callable(pos_px: Vector2) -> bool: true skips a death's blood (a signature kill, lane brutality,
## prints its own marks there).
var veto: Callable = Callable()
var leak: OilLeak = null
var _draws: PackedInt32Array = [0, 0]
var _drop_draws: PackedInt32Array = [0, 0]
var _game: Dictionary = {}
## The city's dead slide this far (px) along the blow (blood_fx.json game.pool_lead_m).
var _slide_px: float = 4.0
var _deaths: Array[Vector4] = []
var _ends: Array[Vector4] = []
var _tick: int = -1
var _mat: ShaderMaterial = ShaderMaterial.new()
var _locate: Callable = Callable()
var _player: int = -1
var _meshes: Array[BloodSplatMesh] = []


func _init() -> void:
	z_index = RenderLayers.z(&"blood")
	blood = BloodFx.new()
	var tokens: Dictionary[StringName, Color] = PaletteTokens.shared().tokens
	if tokens.has(&"blood"):
		blood.set_ground(tokens[&"blood"])
	_game = blood.p.get("game", {})
	_pool_from_game()
	if not NoirLook.requested():  # the noir gate prints a body this dark as black
		var dark: Color = NoirPack.rgb(_game.get("pool_dark", [0.46, 0.0, 0.03]))
		blood.set_dark(tokens[&"blood_dark"] if tokens.has(&"blood_dark") else dark)
	var fallback: String = _game.get("default", "noir")
	mode = requested(fallback)
	oil = BloodFx.new()
	var player: Dictionary = blood.p.get("player", {})
	var fluid: String = player.get("fluid", "")
	if not oil.use_fluid(fluid):
		oil.free()
		oil = null
	var ink_px: float = _game.get("ink_px", 0.0)
	var settled: int = _game.get("settled_redraw_ticks", 1)
	blood.set_ink(ink_px, NoirPack.rgb(_game.get("ink", [0.1, 0.08, 0.08])))
	blood.settled_every = settled
	if oil != null:
		oil.settled_every = settled
	var drip: Dictionary = blood.p.get("drip", {})
	leak = OilLeak.new(drip)
	_mat.shader = load(SHADER)
	_mat.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	for fx: BloodFx in [blood, oil]:
		if fx != null:
			_meshes.append(fx.use_splat_mesh())
			fx.material = _mat
			fx.use_parent_material = false
			add_child(fx)


## The mode `-- --blood=<mode>` asks for, else `fallback`.
static func requested(fallback: String) -> String:
	var want: String = LaunchArgs.value("--blood")
	return want if MODES.has(want) else fallback


## Listens to `triggers`' cues; under `noir` mutes the D4 kinds the blood replaces (ink_splat).
func attach(triggers: FxTriggers) -> void:
	@warning_ignore("return_value_discarded")
	triggers.cued.connect(_on_cue)
	if mode != "noir":
		return
	var replaced: Array = _game.get("replaces_fx", [])
	for id: StringName in triggers.rows:
		var row: Dictionary = triggers.rows[id]
		var kept: Array = []
		for kind: String in row["fx"]:
			if not replaced.has(kind):
				kept.append(kind)
		row["fx"] = kept


## Follows a quest fight's Events instead of the cues: actor_killed bleeds the victim along
## killer -> victim, player_hit leaks the player's oil. `locate`: Callable(id) -> Vector2 metres
## (Vector2.INF when unknown); `player` = the player's actor id.
func listen(bus: EventBus, locate: Callable, player: int) -> void:
	_locate = locate
	_player = player
	player_px = func() -> Vector2:
		var at: Vector2 = _locate.call(_player)
		return at if at == Vector2.INF else at * SimConst.PX_PER_M
	@warning_ignore("return_value_discarded")
	bus.actor_killed.connect(_on_killed)
	@warning_ignore("return_value_discarded")
	bus.player_hit.connect(_on_player_hit)


func set_solid(c: Callable) -> void:
	solid = c
	blood.solid = c


## True when blood draws (noir or both).
func bleeds() -> bool:
	return mode != "ink"


func _on_cue(id: StringName, pos_px: Vector2, angle: float, tick: int) -> void:
	if not bleeds():
		return
	if id == &"death":
		_deaths.append(Vector4(pos_px.x, pos_px.y, angle, tick))
	elif id == &"projectile_end":
		_ends.append(Vector4(pos_px.x, pos_px.y, angle + PI, tick))
	elif id == &"player_hit":
		hit_robot(pos_px)


func _on_killed(killer: int, victim: int, _kind: StringName) -> void:
	if _kind in DRY_KILLS and not robot_ids.has(victim):  # burned or cut dry: no red (a robot leaks)
		return
	if veto.is_valid():  # the signature kill lands after actor_killed: ask once the step is done
		_bleed_killed.call_deferred(killer, victim)
	else:
		_bleed_killed(killer, victim)


func _bleed_killed(killer: int, victim: int) -> void:
	var at: Vector2 = _locate.call(victim)
	if at == Vector2.INF or not bleeds():
		return
	if veto.is_valid() and veto.call(at * SimConst.PX_PER_M):
		return
	var from: Vector2 = _locate.call(killer)
	var dir: Vector2 = at - from if from != Vector2.INF else Vector2.RIGHT
	if victim == _player:
		hit_robot(at * SimConst.PX_PER_M)
	elif robot_ids.has(victim):
		var fx: BloodFx = oil if oil != null else blood
		fx.splash(at * SimConst.PX_PER_M, dir.normalized(), "robot_hit")
	else:
		kill_human(at * SimConst.PX_PER_M, dir)
		bled_body.emit(victim, dir.normalized())


func _on_player_hit(_weapon: StringName) -> void:
	var at: Vector2 = _locate.call(_player)
	if at != Vector2.INF and bleeds():
		hit_robot(at * SimConst.PX_PER_M)


## A hit on a robot (Rivet) at `pos_px`: white sparks that land as black oil, no red.
func hit_robot(pos_px: Vector2) -> void:
	hits += 1
	var fx: BloodFx = oil if oil != null else blood
	var player: Dictionary = blood.p.get("player", {})
	var kind: String = player.get("hit", "robot_hit")
	fx.splash(pos_px, Vector2.from_angle(hits * 2.4), kind)
	leak.start()


## The D4/D5 pool's lead (the city's death slide) and its optional size (blood_fx.json game).
func _pool_from_game() -> void:
	var lead_m: float = _game.get("pool_lead_m", 0.125)
	_slide_px = lead_m * SimConst.PX_PER_M
	if NoirLook.requested():  # owner 2026-11-03: the D4/D5 game's pool is 16 px, noir keeps 22
		return
	var pool_r1: float = _game.get("pool_radius_px", 0.0)
	blood.pool_r1_px = pool_r1


## A human killed at `pos_px` by a blow travelling along `dir` (quest 1's events feed).
## `slide_px`: how far the body slides along `dir` after death (its pool starts under it there).
func kill_human(pos_px: Vector2, dir: Vector2, slide_px: float = 4.0) -> void:
	if veto.is_valid() and veto.call(pos_px):
		return
	kills += 1
	var kind: String = _game.get("death_hit", "kill")
	blood.pool_lead_px = slide_px
	blood.splash(pos_px, spray_dir(pos_px, dir), kind)
	bled.emit(pos_px, dir.normalized())


## The kill spray's axis: `dir` turned between game.spray_tilt_min_deg and spray_tilt_deg either
## way, hashed from the spot (lane gunplay): a blow due south never prints a ruler-straight column.
func spray_dir(pos_px: Vector2, dir: Vector2) -> Vector2:
	var lo_deg: float = _game.get("spray_tilt_min_deg", 0.0)
	var hi_deg: float = _game.get("spray_tilt_deg", 0.0)
	var lo: float = deg_to_rad(lo_deg)
	var hi: float = maxf(deg_to_rad(hi_deg), lo)
	var s: float = NoirPack.hash01(roundi(pos_px.x) * 7919 + roundi(pos_px.y) * 104729) * 2.0 - 1.0
	return dir.normalized().rotated(signf(s + 1e-6) * lerpf(lo, hi, absf(s)))


## The blood's print (fx_blood_print): other blood nodes (CorpseStains) print through it.
func print_material() -> ShaderMaterial:
	return _mat


## Advances the blood to sim tick `tick` (once a frame); world_px locks the print grain.
func step(tick: int, world_px: Vector2) -> void:
	var t0: int = Time.get_ticks_usec()
	_mat.set_shader_parameter(&"world_px", world_px)
	_resolve()
	var n: int = clampi(tick - _tick, 0, max_steps) if _tick >= 0 else 1
	_tick = tick
	if n > 0:
		blood.step_ticks(n)
		if oil != null:
			oil.step_ticks(n)
		if player_px.is_valid():
			var at: Vector2 = player_px.call()
			leak.step(n, at, oil if oil != null else blood)
	for m: BloodSplatMesh in _meshes:
		m.update(world_px, blood.tick)
	last_us = Time.get_ticks_usec() - t0
	frames += 1
	spent_us += last_us + _new_draw_us()


## Each death this step sprays along the round that stopped nearest to it on its tick.
func _resolve() -> void:
	var near_px: float = MATCH_M * SimConst.PX_PER_M
	for d: Vector4 in _deaths:
		var at: Vector2 = Vector2(d.x, d.y)
		var dir: Vector2 = Vector2.from_angle(d.z)
		var best: float = near_px
		var hit: bool = false
		for e: Vector4 in _ends:
			var gap: float = at.distance_to(Vector2(e.x, e.y))
			if e.w == d.w and gap < best:
				best = gap
				dir = Vector2.from_angle(e.z)
				hit = true
		aimed += 1 if hit else 0
		if veto.is_valid():  # the city's death cue can run before the frame's kill_landed
			kill_human.call_deferred(at, dir, _slide_px)
		else:
			kill_human(at, dir, _slide_px)
	_deaths.clear()
	_ends.clear()


## The redraw microseconds of the blood and the oil since the last call (each counted once).
func _new_draw_us() -> int:
	var us: int = 0
	var fxs: Array[BloodFx] = [blood, oil]
	for k: int in 2:
		if fxs[k] != null and fxs[k].draws != _draws[k]:
			us += fxs[k].draw_us
			_draws[k] = fxs[k].draws
		if fxs[k] != null and fxs[k].drops_draws != _drop_draws[k]:
			us += fxs[k].drops_us
			_drop_draws[k] = fxs[k].drops_draws
	return us
