class_name BotStreetStats
extends ArenaHook
## The pilot samples before the simulation advances. This hook runs after hits,
## before GauntletWaves closes the row, so a lethal hit includes its last tick.

var _run: GauntletRun
var _view: BotView
var _counts: BotCounters
var _wave: int = 0
var _guard: int = 0
var _cover: int = 0
var _forms: Dictionary[StringName, int] = {}
var _machine: Fighter
var _claw_m: float = MeleeTable.shipped().hits[0].reach_m


func _init(run: GauntletRun, view: BotView, counts: BotCounters) -> void:
	_run = run
	_view = view
	_counts = counts


func step(stage: ArenaStage, _tick: int) -> void:
	var guarding: int = _counts.guard_ticks - _guard
	var covering: int = _counts.cover_ticks - _cover
	_guard = _counts.guard_ticks
	_cover = _counts.cover_ticks
	if _run.waves.is_empty() or _run.waves[-1].has("shots"):
		return
	var row: Dictionary = _run.waves[-1]
	if _wave != _run.wave:
		_begin(row, stage)
	row.guard_ticks += guarding
	row.cover_ticks += covering
	var me: BotView.Player = _view.player()
	if me.settled and _forms.has(me.form):
		_forms[me.form] += 1
		row.form_seconds[me.form] = _forms[me.form] * SimClock.TICK_DT
	if _machine != null:
		var stats: Dictionary = row.machine
		_measure(stats, stage, guarding, covering)


func _begin(row: Dictionary, stage: ArenaStage) -> void:
	_wave = _run.wave
	_forms.clear()
	row["form_seconds"] = {}
	row["guard_ticks"] = 0
	row["cover_ticks"] = 0
	for id: StringName in stage.pilot.ghosts.forms.table.order:
		_forms[id] = 0
		row.form_seconds[id] = 0.0
	_machine = null
	for foe: Fighter in stage.arena.hostiles:
		if foe.archetype == &"war_machine":
			_machine = foe
			row["machine"] = {
				"ticks": 0,
				"claw_reach_ticks": 0,
				"hp_lost": 0.0,
				"guard_ticks": 0,
				"rolling_ticks": 0,
				"cover_ticks": 0
			}
			break


func _measure(stats: Dictionary, stage: ArenaStage, guarding: int, covering: int) -> void:
	for foe: BotView.Hostile in _view.hostiles():
		if foe.id != _machine.id:
			continue
		var distance: float = _view.player().pos.distance_to(foe.pos)
		stats.ticks += 1
		stats.claw_reach_ticks += int(distance <= _claw_m + _machine.radius_m)
		stats.hp_lost += maxf(0.0, foe.hp - maxf(_machine.hp, 0.0))
		stats.guard_ticks += guarding
		stats.cover_ticks += covering
		stats.rolling_ticks += int(stage.pilot.motion.roll_progress() > 0.0)
		break
