class_name ReelDirector
extends ArenaHook
## The showcase's director cut (`--bot=reel --reel=director --loadout=pistol`): a directed
## sequence, not a wave fight. Each ReelChapters chapter stands Rivet on one open mark in the
## course, hands him the chapter's weapon through rivet-arsenal's carry (RivetCarry.take, the
## pickup path a player uses), spawns the chapter's victims singly in front of him and lets the
## real fight code kill them: CombatArena, the signature kills, the reactions, the blood.
## The chapter state moves on the 60 Hz tick as a hook (sim side, after the stage's step); the
## inputs (CombatReel.sample delegates here) only read it, so a director run replays.

## The open mark (2 m east of brutality's solo-lab spot (-36, 2): the course's west edge stays
## out of the 48 px/m frame; checked on the 05:20 chapter frames).
const MARK: Vector2 = Vector2(-34.0, 2.0)
## The last chapter's dead move here (print and blood stay: cut.sh films one chapter per run).
const MORGUE: Vector2 = Vector2(-400.0, -400.0)
const HOLD_FIRE: int = 100000
## Ticks Rivet faces the new victims before the first shot (the beat reads).
const LOOK_TICKS: int = 45
const RUN_M: float = 1.8
const CLAW_M: float = 1.3
const CLAW_EVERY: int = 14
const BLADE_M: float = 1.6
## The tap chapter: a shot every this many ticks (the plasma stagger, 0.55 s, plays out).
const TAP_EVERY: int = 50

var actions: PlayerActions
var chapters: Array[ReelChapters.Chapter] = ReelChapters.all()
## The running chapter (-1 before the first starts; chapters.size() when the cut is over).
var index: int = -1
var started_tick: int = 0
var victims: Array[Fighter] = []
var spots: PackedVector2Array = PackedVector2Array()
## Victims killed per chapter id (the scenario's and the log's telemetry).
var kills: Dictionary[StringName, int] = {}
## False plants the scenario's fault: every button off (aim and walk only).
var trigger: bool = true
var _next_tick: int = 0
## Other live hostiles (station actors) held where they stood at the chapter's start.
var _extras: Dictionary[Fighter, Vector2] = {}


func _init(p_actions: PlayerActions) -> void:
	actions = p_actions
	var only: String = ArenaArgs.parse().text("--chapter")
	if not only.is_empty():  # one fresh run per chapter: a clean floor under every kill
		var keep: PackedStringArray = only.split(",", false)
		chapters = chapters.filter(
			func(c: ReelChapters.Chapter) -> bool: return keep.has(String(c.id))
		)


## Total ticks of the cut (a capture's --quit-after at 60 fps).
func length() -> int:
	var n: int = 0
	for c: ReelChapters.Chapter in chapters:
		n += c.ticks
	return n


## The running chapter's number in the full cut (1-based; a --chapter run keeps its number).
func number() -> int:
	var c: ReelChapters.Chapter = chapter()
	if c == null:
		return 0
	var ids: Array[ReelChapters.Chapter] = ReelChapters.all()
	for i: int in ids.size():
		if ids[i].id == c.id:
			return i + 1
	return index + 1


func chapter() -> ReelChapters.Chapter:
	return chapters[index] if index >= 0 and index < chapters.size() else null


func step(stage: ArenaStage, tick: int) -> void:
	if tick >= _next_tick and index < chapters.size():
		_count()
		index += 1
		if index < chapters.size():
			_begin(stage, tick)
	var c: ReelChapters.Chapter = chapter()
	if c == null:
		return
	for e: Fighter in _extras:
		e.pos = _extras[e]
		e.cooldown = HOLD_FIRE
		e.tell_left = 0
	for n: int in victims.size():
		var g: Fighter = victims[n]
		if not c.shoots:
			g.cooldown = HOLD_FIRE
			g.tell_left = 0
		if g.alive():  # a burning victim runs ablaze, tethered so the fire kill stays in frame
			g.pos = spots[n] + (g.pos - spots[n]).limit_length(RUN_M)


func telemetry() -> Dictionary:
	return {"director_chapter": index, "director_kills": kills.duplicate()}


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(index)
	out.put_32(victims.size())


## The tick's input: face the nearest standing victim, then the chapter's attack.
func sample(stage: ArenaStage, tick: int) -> TickInput:
	var c: ReelChapters.Chapter = chapter()
	if c == null:
		return _input(Vector2.ZERO, Vector2.RIGHT, 0)
	var rivet: Vector2 = stage.arena.rivet.pos
	var foe: Fighter = _nearest(rivet)
	if foe == null:
		return _input(Vector2.ZERO, stage.arena.rivet.facing, 0)
	var gap: Vector2 = foe.pos - rivet
	var aim: Vector2 = gap.normalized()
	var local: int = tick - started_tick
	if local < LOOK_TICKS:
		return _input(Vector2.ZERO, aim, 0)
	match c.mode:
		&"claw":
			var walk: Vector2 = aim if gap.length() > CLAW_M else Vector2.ZERO
			var jab: bool = gap.length() <= CLAW_M + 0.3 and local % CLAW_EVERY == 0
			return _input(walk, aim, _bit(&"melee", jab))
		&"blade":
			var close: Vector2 = aim if gap.length() > BLADE_M else Vector2.ZERO
			return _input(close, aim, _bit(&"fire", gap.length() <= BLADE_M + 0.3))
	# gun, deflect: held fire; tap: one shot per TAP_EVERY ticks (each reaction plays out)
	return _input(Vector2.ZERO, aim, _bit(&"fire", c.mode != &"tap" or local % TAP_EVERY < 2))


func _begin(stage: ArenaStage, tick: int) -> void:
	var c: ReelChapters.Chapter = chapters[index]
	started_tick = tick
	_next_tick = tick + c.ticks
	var arena: CombatArena = stage.arena
	_extras.clear()
	for h: Fighter in arena.hostiles:  # the last chapter's dead leave the frame
		if not h.alive():
			h.pos = MORGUE
		else:
			_extras[h] = h.pos
	var mark: Vector2 = stage.plan.base + MARK
	arena.rivet.pos = mark
	arena.rivet.facing = Vector2.RIGHT
	arena.rivet.hp = arena.rivet.max_hp
	var carry: RivetCarry = stage.pilot.carry if stage.pilot != null else null
	if carry != null:
		carry.take(c.weapon, arena)
	else:
		Log.warn(
			"showcase", "director: no carry (run with --loadout=pistol); %s skipped" % c.weapon
		)
	victims.clear()
	spots.clear()
	for off: Vector2 in c.victims:
		victims.append(_spawn(stage, mark + off, c))
		@warning_ignore("return_value_discarded")
		spots.append(mark + off)
	Log.info("showcase", "director chapter %s (%s) at tick %d" % [c.id, c.weapon, tick])


func _spawn(stage: ArenaStage, at: Vector2, c: ReelChapters.Chapter) -> Fighter:
	var g: Fighter = stage.arena.spawn_guard(at)
	g.pos = at
	g.facing = Vector2.LEFT
	if c.armored:
		g.max_hp *= ArenaPit.armored_hp()
		g.hp = g.max_hp
	if c.riot and stage.pit != null:  # the riot cop: armored hp, ArenaRigs dresses the shield
		if stage.pit.riot_hp <= 0.0:
			stage.pit.riot_hp = ArenaPit.armored_hp()
		g.max_hp *= stage.pit.riot_hp
		g.hp = g.max_hp
		stage.pit.riot[g.id] = true
	return g


func _count() -> void:
	var c: ReelChapters.Chapter = chapter()
	if c == null:
		return
	var dead: int = 0
	for g: Fighter in victims:
		dead += 0 if g.alive() else 1
	kills[c.id] = dead
	Log.info("showcase", "director chapter %s: %d/%d down" % [c.id, dead, victims.size()])


func _nearest(at: Vector2) -> Fighter:
	var best: Fighter = null
	for f: Fighter in victims:
		if f.alive() and (best == null or at.distance_to(f.pos) < at.distance_to(best.pos)):
			best = f
	return best


func _bit(action: StringName, on: bool) -> int:
	return 1 << actions.bit(action) if on else 0


func _input(move: Vector2, aim: Vector2, extra: int) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions) | (extra if trigger else 0)
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
