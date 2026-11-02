class_name CollectCallStage
extends WorldSystem
## Quest 1's stage (collect-call), composed from the features (police heat, the missions
## payphone router, economy, combat) on the fixed tick. Rivet walks, hides, answers phones,
## fights and torches per StageIntent; patrols and guards see him; Dock 9's encounters start
## when he arrives; the cues the quest's barks wait on are raised here, once per tick. Registered
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
var cues: Dictionary[String, bool] = {}
var crates_burning: bool = false
var burn_ticks: int = 0
## The payphone the payout is taped under, once Don says so.
var cash_phone: String = ""
var refusal_left: int = 0
var deaths: int = 0
var shots_fired: int = 0
## This tick's interact press, if the stage did not use it (the quest's meet beat takes it).
var press_left: bool = false
var tick: int = 0
var _quest: QuestSystem = null
var _asked: Dictionary[String, bool] = {}
var _last_line: String = ""


func _init(p_layout: StageLayout) -> void:
	layout = p_layout


## The quest whose spoken lines drive line_hooks (read only).
func watch(quest: QuestSystem) -> void:
	_quest = quest


func setup(ctx: WorldContext) -> void:
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


func step(p_tick: int, _input: TickInput) -> void:
	tick = p_tick
	cues.clear()
	_line_hooks()
	_move()
	press_left = intent.interact and not StageActions.interact(self)
	if intent.fire_at != Vector2.INF and hidden_in == "":
		shots_fired += 1 if arena.rivet_fire(intent.fire_at) else 0
	arena.step(tick)
	_encounters()
	_spawns()
	StagePolice.step_patrols(self)
	var witnessed: bool = arena.kills_now > 0 and arena.hostiles_alive() > 0
	heat.step(StagePolice.seen(self))
	if witnessed:
		heat.raise_by(1)
	router.step(heat.level)
	_raise_cues()
	_respawn()
	refusal_left = maxi(refusal_left - 1, 0)
	burn_ticks += 1 if crates_burning else 0
	intent.clear()


## The torch: the crate stack burns, the whispers spike, and the alarm puts heat at its peak.
func ignite() -> void:
	crates_burning = true
	burn_ticks = 0
	cues["static-whisper-burst"] = true
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


func _move() -> void:
	if intent.move_to == Vector2.INF:
		hidden_ticks += 1 if hidden_in != "" else 0
		return
	if hidden_in != "":
		hidden_in = ""
	var speed: float = arena.tuning.rivet["walk_mps"] * SimClock.TICK_DT
	arena.rivet.pos = arena.rivet.pos.move_toward(intent.move_to, speed)


func _spawns() -> void:
	var due: WaveDirector.Spawn = layout.waves.step(arena.hostiles_alive())
	if layout.waves.began >= 0:
		cues["wave-start"] = true
	if due == null:
		return
	var at: Vector2 = layout.spawn_points[due.point]
	var spawned: Fighter = arena.spawn_boss(at) if due.boss != "" else arena.spawn_guard(at)
	if spawned.kind == Fighter.Kind.BOSS:
		cues["boss-intro"] = true


func _encounters() -> void:
	for marker: String in ENCOUNTERS:
		if _asked.get(marker, false) and not layout.waves.running():
			var m: QuestPlaces.Marker = layout.marker(marker)
			if arena.rivet.pos.distance_to(m.at) <= m.radius_m and not encounter_cleared(marker):
				layout.waves.start(marker)
				_asked[marker] = false


func _raise_cues() -> void:
	if heat.dropped:
		cues["heat-dropping"] = true
	if arena.kills_now > 0:
		cues["kill"] = true
	if arena.tazer != null and arena.tazer.charge_began():
		cues["robo-tazer-charge"] = true
	if arena.tazer_hit_now:
		cues["robo-tazer-hit"] = true
		cues["static-whisper-burst"] = true
	if crates_burning:
		cues["crates-burning"] = true
	var first: int = layout.whisper_first_ticks
	if hidden_in != "" and hidden_ticks >= first:
		if (hidden_ticks - first) % layout.whisper_every_ticks == 0:
			cues["static-whisper-burst"] = true


## Rivet destroyed: he wakes up in the Toner Room, and Juno's tape bill comes off the payout.
func _respawn() -> void:
	if arena.rivet.alive():
		return
	deaths += 1
	arena.rivet.hp = arena.rivet.max_hp
	arena.rivet.pos = layout.marker("The Toner Room").at
	hidden_in = ""
	Log.info("stage", "Rivet destroyed: respawn at the Toner Room (tape bill %d)" % deaths)


func _line_hooks() -> void:
	var line: String = ""
	if _quest != null and _quest.runner != null and _quest.runner.lines.current != null:
		line = _quest.runner.lines.current.id
	if line == _last_line:
		return
	_last_line = line
	match layout.line_hooks.get(line, ""):
		"give_gloria":
			arena.rivet.weapon = &"gloria"
		"repair":
			arena.rivet.hp = arena.rivet.max_hp
		"whisper":
			cues["static-whisper-burst"] = true
		"cash_under_phone":
			cash_phone = _nearest_phone()


func _nearest_phone() -> String:
	var best: String = ""
	for phone: String in layout.phones:
		var d: float = layout.phones[phone].distance_to(arena.rivet.pos)
		if best == "" or d < layout.phones[best].distance_to(arena.rivet.pos):
			best = phone
	return best
