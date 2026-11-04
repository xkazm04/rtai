class_name BrutalityHook
extends ArenaHook
## The brutality lane in the arena (station `brutality_pit`, arena_stations/brutality.json): it
## feeds CombatArena.struck lethal hits into SignatureKills, steps the gibs on the 60 Hz tick from
## the `brutality` RNG stream, folds them into the replay hash and draws them with KillView on the
## print stage's actor layer. Arena args (after --): --sig-gun=<weapon id> hands Rivet that
## weapons.json gun (the rocket launcher, until the arsenal lane's weapon wheel lands);
## --sig-lab lines guards up in front of him (KillLab, a framed capture); --gore=reduced turns
## every signature kill into the standard death.

const PART_RADIUS_M: float = 0.2

var kills: SignatureKills = null
var view: KillView = null
var _stage: ArenaStage = null
var _rigs: ArenaRigs = null
var _game: Node = null
var _lab: KillLab = null


func setup(stage: ArenaStage, ctx: WorldContext) -> void:
	_stage = stage
	var table: SignatureKillTable = SignatureKillTable.load_table()
	table.gore_full = SignatureKillTable.gore_from_args(ArenaArgs.parse().text("--gore", "full"))
	kills = SignatureKills.new(table, ctx.rng.stream(&"brutality"))
	kills.push_out = _push_out
	@warning_ignore("return_value_discarded")
	stage.arena.kill_landed.connect(_on_kill_landed)
	var gun: String = ArenaArgs.parse().text("--sig-gun")
	var weapons: WeaponTable = WeaponTable.shipped() if not gun.is_empty() else null
	if weapons != null and weapons.weapons.has(StringName(gun)):
		stage.arena.gun = GunHand.make(weapons, StringName(gun), ctx.rng.stream(&"brutality_gun"))
		stage.arena.rivet.weapon = &"gloria"  # the view's armed state (the claw pistol cell)
	if ArenaArgs.parse().has("--sig-lab"):
		_lab = KillLab.new()
		_lab.setup(stage)


func step(stage: ArenaStage, tick: int) -> void:
	kills.step(tick)
	if _lab != null:
		_lab.step(stage, tick)
	if kills.consumed.is_empty():
		return
	for h: Fighter in stage.arena.hostiles:  # a revived or re-spawned body is whole again
		if h.alive() and kills.consumed.has(h.id):
			@warning_ignore("return_value_discarded")
			kills.consumed.erase(h.id)
			var rigs: ArenaRigs = _find_rigs()
			if rigs != null:
				@warning_ignore("return_value_discarded")
				rigs.hidden.erase(h.id)


func write_state(out: StreamPeerBuffer) -> void:
	kills.write_state(out)


func telemetry() -> Dictionary:
	return {"signature_kills": kills.consumed.size(), "by_style": kills.by_style.duplicate()}


func attach_view(p_view: Node) -> void:
	var cc: CollectCallView = p_view as CollectCallView
	if cc == null or cc.print_stage == null:
		return
	_game = p_view.get_parent()
	view = KillView.new()
	view.z_index = RenderLayers.z(&"actors") - 1
	view.ppm = SimConst.PX_PER_M
	view.reduced_motion = LaunchArgs.has("--reduced-motion")
	view.rig_lookup = _rig_of
	view.bind(kills)
	cc.print_stage.actor_layer().add_child(view)


## gunplay's kill payload (JOURNAL REQUEST 1, agreed): every lethal hit on a non-Rivet fighter;
## a fire death carries the weapon `burn`.
func _on_kill_landed(
	victim: Fighter, weapon: StringName, dir: Vector2, _at: Vector2, kind: StringName
) -> void:
	var e: KillEvent = KillEvent.of_fighter(victim, dir, weapon)
	e.damage_type = kind
	if kills.on_kill(e):
		_hide(victim.id)


## A part against the arena's walls (and the city block's buildings and cars).
func _push_out(p: Vector2) -> Vector2:
	var out: Vector2 = _stage.walls.push_out(p, PART_RADIUS_M)
	return _stage.cells.push_out(out, PART_RADIUS_M) if _stage.cells != null else out


func _rig_of(victim_id: int) -> CutRig:
	var rigs: ArenaRigs = _find_rigs()
	return rigs.rigs.rig_for(victim_id) if rigs != null else null


func _hide(victim_id: int) -> void:
	var rigs: ArenaRigs = _find_rigs()
	if rigs != null:
		rigs.hidden[victim_id] = true


func _find_rigs() -> ArenaRigs:
	if _rigs == null and _game != null:
		for ch: Node in _game.get_children():
			if ch is ArenaRigs:
				_rigs = ch as ArenaRigs
				if _rigs.react != null:  # human-reactions' DeathPipe: our kills skip the standard death
					_rigs.react.pipe.add_signature(_takes_death)
	return _rigs


func _takes_death(rig: CutRig, _hit: StringName, _dir: Vector2, _weapon: StringName) -> bool:
	return kills.consumed.has(rig.actor_id)
