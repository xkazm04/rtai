class_name GauntletTestPlayer
extends GauntletPilot
## Street owns the session and wave boundaries. The brain owns its private input streams.

const BONUSES: String = "res://data/tables/gauntlet_bonuses.json"

var _seed: int
var _skill: BotProfile
var _picker: BotPick
var _brain: GauntletBot
var _run: GauntletRun
var _stage: ArenaStage


func configure(p_profile: StringName, pick_policy: StringName, seed: int) -> void:
	super.configure(p_profile, pick_policy, seed)
	_seed = seed
	_skill = BotProfile.shipped(p_profile)
	var table: DataTable = DataTable.open(BONUSES, "gtai.gauntlet_bonuses/1")
	var catalog: Dictionary[StringName, Dictionary] = {}
	for row: Dictionary in table.array(table.raw, "rows"):
		catalog[StringName(table.text(row, "id"))] = row
	_picker = BotPick.new(pick_policy, _skill, RngRegistry.new(seed), catalog)


func bind(run: GauntletRun, session: ArenaSession) -> void:
	_run = run
	_stage = session.stage
	var view: BotViewArena = BotViewArena.new(session.stage, session.actions, true)
	if session is GauntletSession:
		view.street_layout = (session as GauntletSession).street
	_brain = GauntletBot.new(view, session.actions, _skill, _seed)
	if session is GauntletSession:
		session.stage.hooks.append(BotStreetStats.new(run, view, _brain.counters))
	Log.info(
		"gauntlet", "test player bound: %s, %s picks, seed %d" % [_profile, _pick_policy, _seed]
	)


func sample(tick: int) -> TickInput:
	return _brain.sample(tick)


## Read after the tick so a roll, raised guard or transformation matches the rig on screen.
func act() -> StringName:
	if _stage == null or not _stage.arena.rivet.alive():
		return &"REST"
	var pilot: StagePilot = _stage.pilot
	if pilot.motion.roll_progress() > 0.0:
		return &"ROLL"
	if pilot.guard != null and pilot.guard.up():
		return &"GUARD"
	if cover_threat() != &"":
		return &"COVER"
	var forms: GhostForms = pilot.ghosts.forms
	if forms.to_id != GhostForms.BASE:
		return StringName(String(forms.to_id).to_upper())
	return _attack_or_travel(pilot)


func cover_threat() -> StringName:
	return _brain.cover_threat if _brain != null else &""


func _attack_or_travel(pilot: StagePilot) -> StringName:
	if pilot.melee.busy() and pilot.melee.weapon_id == PlayerMelee.WEAPON:
		return &"ATTACK CLAW"
	if pilot.melee.busy() or _brain.firing():
		if pilot.carry != null and pilot.carry.current >= 0:
			return StringName("ATTACK %d" % (pilot.carry.current + 1))
		return &"ATTACK PRIMARY"
	return _brain.travel


func pick(offered: Array[StringName]) -> int:
	return offered.find(_picker.pick(offered, _run.wave))
