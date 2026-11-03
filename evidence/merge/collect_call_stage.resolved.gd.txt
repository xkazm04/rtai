class_name CollectCallStage
extends WorldSystem
## Quest 1's stage (collect-call), composed from the features (police heat, the missions
## payphone router, economy, combat) on the fixed tick. Rivet walks, hides, answers phones,
## fights and torches per StageIntent; patrols and guards see him; Dock 9's encounters start
## when he arrives; what the quest's barks react to goes out as typed Events from the features
## (the arena: actor_killed, wave_started, boss_engaged, attack_telegraphed, player_hit; the heat
## meter: wanted_changed) and, standing in for madness, whispers_spiked from here (at most one
## burst per tick). Registered
## before the QuestSystem, so the quest reads this tick's state. Lines the Toner Room speaks
## act through line_hooks (Brass's line hands over Gloria, ...), read one tick late, in order.

const ENCOUNTERS: PackedStringArray = ["Dock 9 bonded storage", "Dock 9 vault cage"]

var layout: StageLayout
var heat: HeatMeter
var router: PayphoneRouter
var wallet: Wallet
var arena: CombatArena
var intent: StageIntent = StageIntent.new()
var hidden_in: String = ""
var hidden_ticks: int = 0
var patrol_pos: Array[Vector2] = []
var patrol_leg: Array[int] = []
## The voices spiked on this tick (Events.whispers_spiked; the view draws the burst).
var whisper_now: bool = false
var crates_burning: bool = false
var burn_ticks: int = 0
## The payphone the payout is taped under, once Don says so.
var cash_phone: String = ""
var refusal_left: int = 0
var deaths: int = 0
var shots_fired: int = 0
## This tick's interact press, if the stage did not use it (the quest's meet beat takes it).
var press_left: bool = false
## The player (bound input) when set; null for the bot, which writes intent itself.
var pilot: StagePilot = null
var tick: int = 0
## The last quest line StageLines acted on.
var last_line: String = ""
## The city's walk cells Rivet collides with, and the city whose bubble follows him (both null
## on the invented arena).
var cells: StageCells = null
var follow: CitySystem = null
var _quest: QuestSystem = null
var _asked: Dictionary[String, bool] = {}
var _cued: Dictionary[String, bool] = {}
var _events: EventBus


func _init(p_layout: StageLayout) -> void:
	layout = p_layout


## The quest whose spoken lines drive line_hooks (read only).
func watch(quest: QuestSystem) -> void:
	_quest = quest


func setup(ctx: WorldContext) -> void:
	_events = ctx.events
	heat = HeatMeter.new(ctx.events)
	router = PayphoneRouter.new()
	wallet = Wallet.new(ctx.events)
	arena = CombatArena.new(CombatTuning.shipped(), ctx.events, ctx.rng.stream(&"combat"))
	arena.metal = layout.metal
	arena.rivet.pos = layout.rivet_start
	heat.set_level(layout.start_heat)
	for p: StageLayout.Patrol in layout.patrols:
		patrol_pos.append(p.route[0])
		patrol_leg.append(1 % p.route.size())


func step(p_tick: int, tick_input: TickInput) -> void:
	tick = p_tick
	whisper_now = false
	StageLines.apply(self, _current_line())
	if follow != null and follow.body != null and follow.body.on:
		arena.rivet.pos = follow.target  # features/bodies: where the city's people left him
	var from: Vector2 = arena.rivet.pos
	if pilot != null:
		pilot.drive(self, tick_input)
	_move()
	press_left = intent.interact and not StageActions.interact(self)
	if intent.fire_at != Vector2.INF and hidden_in == "":
		shots_fired += 1 if arena.rivet_fire(intent.fire_at) else 0
	arena.step(tick)
	@warning_ignore("return_value_discarded")
	ArenaBodies.resolve(arena, (arena.rivet.pos - from) / SimClock.TICK_DT)  # features/bodies
	arena.rivet.pos = _collide(arena.rivet.pos)
	_collide_hostiles()
	_encounters()
	_spawns()
	StagePolice.step_patrols(self)
	var witnessed: bool = arena.kills_now > 0 and arena.hostiles_alive() > 0
	heat.step(StagePolice.seen(self))
	if witnessed:
		heat.raise_by(1)
	router.step(heat.level)
	_emit_events()
	_respawn()
	refusal_left = maxi(refusal_left - 1, 0)
	burn_ticks += 1 if crates_burning else 0
	intent.clear()
	if follow != null:
		follow.focus = arena.rivet.pos
		follow.target = follow.focus


## The torch: the crate stack burns, the whispers spike, and the alarm puts heat at its peak.
func ignite() -> void:
	crates_burning = true
	burn_ticks = 0
	whisper_now = true
	heat.set_level(heat.max_level)
	Log.info("stage", "TUCK-IN crates on fire at tick %d" % tick)


## Asked by the quest: the encounter at `marker` comes once Rivet is inside the marker.
func arm_encounter(marker: String) -> void:
	_asked[marker] = true


func encounter_cleared(marker: String) -> bool:
	return layout.waves.cleared(marker)


## Rivet's weapon as the bark vocabulary names it ("" for none).
func weapon_name() -> String:
	return String(arena.rivet.weapon)


func write_state(out: StreamPeerBuffer) -> void:
	heat.write_state(out)
	router.write_state(out)
	arena.write_state(out)
	out.put_32(wallet.cash)
	out.put_8(1 if crates_burning else 0)
	out.put_utf8_string(hidden_in)
	out.put_32(deaths)
	out.put_32(_cued.size())
	if pilot != null:
		pilot.write_state(out)


func _move() -> void:
	if intent.move_to == Vector2.INF and intent.move_by != Vector2.ZERO:
		hidden_in = ""
		arena.rivet.pos = _collide(arena.rivet.pos + intent.move_by)
		return
	if intent.move_to == Vector2.INF:
		hidden_ticks += 1 if hidden_in != "" else 0
		return
	if hidden_in != "":
		hidden_in = ""
	var speed: float = arena.tuning.rivet["walk_mps"] * SimClock.TICK_DT
	arena.rivet.pos = _collide(arena.rivet.pos.move_toward(intent.move_to, speed))


func _collide(p: Vector2) -> Vector2:
	return cells.push_out(p, arena.tuning.rivet["radius_m"]) if cells != null else p


## On the city the guards and Mertz keep out of buildings, props and parked cars too.
func _collide_hostiles() -> void:
	if cells == null:
		return
	for h: Fighter in arena.hostiles:
		if h.alive():
			h.pos = cells.push_out(h.pos, h.radius_m)


func _spawns() -> void:
	var due: WaveDirector.Spawn = layout.waves.step(arena.hostiles_alive())
	if layout.waves.began >= 0:
		var w: WaveDirector.Wave = layout.waves.waves[layout.waves.began]
		arena.announce_wave(StringName(w.encounter), _wave_number(layout.waves.began))
	if due == null:
		return
	var at: Vector2 = layout.spawn_points[due.point]
	if due.boss != "":
		@warning_ignore("return_value_discarded")
		arena.spawn_boss(at, StringName(due.boss))
	else:
		@warning_ignore("return_value_discarded")
		arena.spawn_guard(at)


func _encounters() -> void:
	for marker: String in ENCOUNTERS:
		if _asked.get(marker, false) and not layout.waves.running():
			var m: QuestPlaces.Marker = layout.marker(marker)
			if arena.rivet.pos.distance_to(m.at) <= m.radius_m and not encounter_cleared(marker):
				layout.waves.start(marker)
				_asked[marker] = false


## The voices (the madness stand-in), cued by the story, never by a repeating timer: a beat's
## whisper cue (data whispers.cues: in b1, once Rivet has hidden a moment), Kilohm's line
## (line_hooks), the tazer hit and the fire.
func _emit_events() -> void:
	if arena.tazer_hit_now:
		whisper_now = true
	var beat: String = _beat_id()
	if layout.whisper_cues.has(beat) and not _cued.has(beat) and hidden_in != "":
		if hidden_ticks >= layout.whisper_cues[beat]:
			_cued[beat] = true
			whisper_now = true
	if whisper_now:
		_events.whispers_spiked.emit()


## The quest line on screen ("" for none).
func _current_line() -> String:
	if _quest != null and _quest.runner != null and _quest.runner.lines.current != null:
		return _quest.runner.lines.current.id
	return ""


func _beat_id() -> String:
	if _quest == null or _quest.runner == null or _quest.runner.current_beat() == null:
		return ""
	return _quest.runner.current_beat().id


## Wave `i`'s number within its encounter, from 1.
func _wave_number(i: int) -> int:
	var n: int = 0
	for k: int in i + 1:
		n += 1 if layout.waves.waves[k].encounter == layout.waves.waves[i].encounter else 0
	return n


## Rivet destroyed: he wakes up in the Toner Room, and Juno's tape bill comes off the payout.
func _respawn() -> void:
	if arena.rivet.alive():
		return
	deaths += 1
	arena.rivet.hp = arena.rivet.max_hp
	arena.rivet.pos = layout.marker("The Toner Room").at
	hidden_in = ""
	Log.info("stage", "Rivet destroyed: respawn at the Toner Room (tape bill %d)" % deaths)
