class_name BossHook
extends ArenaHook
## The boss fight in the arena (station file data/tables/arena_stations/bosses.json), live only
## under `--boss=<id>` (`--phase=N` starts at phase N, 1-based). It stands Rivet and the boss at
## the boss's arena record, steps BossFight after the stage, lands its hits on Rivet through the
## CombatArena chokepoint, and spawns the adds it asks for. The boss's body is one of the arena's
## hostiles (brain_owned), so every weapon, the claw and the four ghosts hit it as they hit
## anyone; the hp they take is routed back through BossFight.hurt() (punish window, phase floors,
## the invulnerable transition). The fight's beats go out as Events through CombatArena
## (announce_boss, announce_tell): features/combat is their declared emitter. Without --boss
## this hook does nothing, so no other station and no golden moves.

var fight: BossFight = null
## The adds the boss called in (each a one-phase bosses.json row on its own BossFight).
var adds: BossAdds = BossAdds.new()
var origin: Vector2 = Vector2.ZERO
## The fight's floor (the arena record's area): the boss and its adds never leave it.
var bounds: Rect2 = Rect2()
var defeated_tick: int = -1
## Hit counts for the bot's numbers: attacks begun / that landed, per attack id.
var tries: Dictionary[StringName, int] = {}
var landed: Dictionary[StringName, int] = {}
var rolled: Dictionary[StringName, int] = {}
var dealt: float = 0.0
var _arena: CombatArena = null
var _last_hp: float = 0.0
var _rng: RngRegistry = null
var _hooks_cleared: bool = false
## The boss script's extra bodies in the hostiles now (BossMoves.bodies()).
var _extra: Array[Fighter] = []
var _stun_seen: int = 0
## The boss script's solid boxes in the stage's walls now (BossMoves.solids()).
var _solids: Array[Rect2] = []


func setup(stage: ArenaStage, ctx: WorldContext) -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var boss_id: StringName = StringName(_arg(args, "--boss"))
	if boss_id == &"":
		return
	var spec: BossSpec = BossSpec.shipped(boss_id)
	if spec == null:
		return
	_arena = stage.arena
	_rng = ctx.rng
	_clear_floor(stage)
	var area: ArenaPlan.Area = stage.plan.area(String(spec.arena.area))
	origin = area.rect.get_center() if area != null else stage.arena.rivet.pos
	bounds = area.rect if area != null else Rect2(origin - Vector2(20, 20), Vector2(40, 40))
	stage.arena.rivet.pos = origin + spec.arena.rivet_at
	fight = BossFight.new(spec, ctx.rng.stream(spec.rng), origin + spec.arena.boss_at)
	fight.body.brain_owned = true
	fight.body.id = 9000
	_arena.hostiles.append(fight.body)
	fight.moves.bind(fight, ctx.rng)
	_connect()
	fight.start(maxi(int(_arg(args, "--phase", "1")) - 1, 0))
	_last_hp = fight.body.hp
	_arena.announce_boss(boss_id)
	Log.info("bosses", "%s engaged in %s, phase %d" % [boss_id, spec.arena.id, fight.phase + 1])


## Rivet's position now (view helpers: BossCam).
func rivet_pos() -> Vector2:
	return _arena.rivet.pos if _arena != null else origin


func step(stage: ArenaStage, tick: int) -> void:
	if fight == null:
		return
	if not _hooks_cleared:  # hooks set up after this one (station files load in name order)
		_hooks_cleared = true
		_clear_claw_cops(stage)
	BossAdds.route(fight, _last_hp)
	_last_hp = fight.body.hp
	adds.step(_arena, tick)
	var r: Fighter = _arena.rivet
	if not r.alive():
		return
	_stun_check()
	var hit: float = fight.step(tick, r.pos, r.radius_m)
	_sync_bodies()
	_sync_solids(stage.walls)
	_keep_in(fight)
	adds.separate(fight)
	for f: BossFight in adds.fights:
		_keep_in(f)
	fight.body.exposed = fight.state != BossFight.State.TRANSITION
	_last_hp = fight.body.hp
	if hit > 0.0 and not r.exposed:  # rolled through it (the roll's i-frames)
		rolled[fight.hit_id()] = rolled.get(fight.hit_id(), 0) + 1
	elif hit > 0.0:
		_arena.hit_dir = fight.aim
		_arena.hit_at = r.pos
		_arena.damage(r, hit, fight.body.id, StringName("boss_%s" % fight.hit_id()))
		landed[fight.hit_id()] = landed.get(fight.hit_id(), 0) + 1
		dealt += hit
	if fight.state == BossFight.State.DEFEATED and defeated_tick < 0:
		defeated_tick = tick


## A new stun on the boss's body (FightAreas: Ohm's bolt, the electro gun) dazes the fight.
func _stun_check() -> void:
	var fx: FighterFx = _arena.areas.fx.get(fight.body.id) if _arena.areas != null else null
	var s: int = fx.stun_ticks if fx != null else 0
	if s > _stun_seen and fight.daze(s):
		Log.info("bosses", "%s dazed %d ticks" % [fight.spec.id, fight.dazed])
	_stun_seen = s


## rivet-arsenal's claw cops (real guards that walk at Rivet and respawn) leave the boss floor:
## out of the hostiles, nothing steps, draws or hits them (their hook still ticks, harmlessly).
func _clear_claw_cops(stage: ArenaStage) -> void:
	for h: ArenaHook in stage.hooks:
		if h is ArenaClawCops:
			for f: Fighter in (h as ArenaClawCops).cops:
				_arena.hostiles.erase(f)


## The arena's hostiles hold exactly the boss script's extra bodies (Servo's drones).
func _sync_bodies() -> void:
	var now: Array[Fighter] = fight.moves.bodies()
	for b: Fighter in _extra:
		if not now.has(b):
			_arena.hostiles.erase(b)
	for b: Fighter in now:
		if not _extra.has(b):
			b.brain_owned = true
			_arena.hostiles.append(b)
	_extra = now


## The stage's walls hold exactly the boss script's solid boxes (Servo's crates), after its own.
func _sync_solids(walls: ArenaWalls) -> void:
	for b: Rect2 in _solids:
		walls.boxes.erase(b)
	_solids = fight.moves.solids()
	walls.boxes.append_array(_solids)


## A body stays on the fight's floor (a ram or a charge stops at its edge).
func _keep_in(f: BossFight) -> void:
	var inner: Rect2 = bounds.grow(-f.body.radius_m)
	f.body.pos = f.body.pos.clamp(inner.position, inner.end)


## The boss owns the floor: the stations' dummies leave and the pit's own waves never start.
func _clear_floor(stage: ArenaStage) -> void:
	for t: ArenaTargets.Target in stage.targets.targets:
		_arena.hostiles.erase(t.fighter)
	stage.pit.zone = Rect2()


func write_state(out: StreamPeerBuffer) -> void:
	if fight != null:
		fight.write_state(out)
		adds.write_state(out)


func telemetry() -> Dictionary:
	if fight == null:
		return {}
	return {
		"boss": String(fight.spec.id),
		"phase": fight.phase + 1,
		"hp_frac": fight.hp_frac(),
		"defeated_tick": defeated_tick,
		"tries": tries.duplicate(),
		"landed": landed.duplicate(),
		"rolled": rolled.duplicate(),
		"dealt": dealt,
		"adds_spawned": adds.fights.size(),
		"adds_tries": adds.tries,
		"adds_landed": adds.landed,
		"moves": fight.moves.telemetry(),
	}


func attach_view(view: Node) -> void:
	if fight != null:
		BossView.attach(view, self)


func _connect() -> void:
	var errs: Array[Error] = [
		fight.attack_windup.connect(_on_windup),
		fight.attack_active.connect(_on_active),
		fight.adds_wanted.connect(_on_adds),
		fight.phase_changed.connect(_on_phase),
		fight.defeated.connect(_on_defeated),
	]
	assert(errs.all(func(e: Error) -> bool: return e == OK))


func _on_windup(attack: StringName) -> void:
	tries[attack] = tries.get(attack, 0) + 1
	_arena.announce_tell(attack)


## An attack with `buff_adds` (King's decree) buffs the standing adds from its active window.
func _on_active(_attack: StringName) -> void:
	if fight.attack != null and fight.attack.buff_ticks > 0:
		adds.buff(fight.attack, fight.now())


func _on_phase(index: int, id: StringName) -> void:
	Log.info("bosses", "%s phase %d (%s)" % [fight.spec.id, index + 1, id])


func _on_defeated() -> void:
	Log.info("bosses", "%s defeated" % fight.spec.id)


## The adds the boss asks for: its bosses.json row when there is one (King's gang), else the
## arena's contractor guards (a boss whose add row has not landed yet).
func _on_adds(archetype: StringName, count: int) -> void:
	var points: Array[Vector2] = []
	var base: Vector2 = fight.body.pos if fight.spec.arena.adds_from_boss else origin
	for p: Vector2 in fight.spec.arena.add_spawns:
		points.append(base + p)
	if points.is_empty():
		return
	var row: BossSpec = BossSpec.shipped(archetype)
	if row == null:
		for i: int in mini(count, adds.cap - _arena.hostiles_alive() + 1):
			@warning_ignore("return_value_discarded")
			_arena.spawn_guard(points[i % points.size()])
		return
	var n: int = adds.spawn(_arena, row, _rng.stream(row.rng), points, count)
	Log.info("bosses", "%s: %d %s" % [fight.spec.id, n, archetype])


static func _arg(args: PackedStringArray, flag: String, fallback: String = "") -> String:
	for a: String in args:
		if a == flag or a.begins_with(flag + "="):
			return a.substr(flag.length() + 1)
	return fallback
