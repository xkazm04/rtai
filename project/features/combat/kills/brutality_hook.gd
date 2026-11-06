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
var _rigs: RigHost = null
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
	if not gun.is_empty():
		arm(stage, ctx, StringName(gun))
	if ArenaArgs.parse().has("--sig-lab"):
		open_lab(stage, StringName(gun))


## Hands Rivet the weapons.json gun `weapon` (the dev arg --sig-gun, or a scenario).
func arm(stage: ArenaStage, ctx: WorldContext, weapon: StringName) -> void:
	var weapons: WeaponTable = WeaponTable.shipped()
	if weapons.weapons.has(weapon):
		stage.arena.gun = GunHand.make(weapons, weapon, ctx.rng.stream(&"brutality_gun"))
		stage.arena.rivet.weapon = &"gloria"  # the view's armed state (the claw pistol cell)


## Lines the KillLab guards up in front of Rivet (the dev arg --sig-lab, or a scenario); with a
## melee `weapon` (melee_weapons.json) Rivet lunges and slashes instead of firing.
func open_lab(stage: ArenaStage, weapon: StringName = &"") -> void:
	_lab = KillLab.new()
	var row: SignatureKill = kills.table.for_weapon(weapon)
	var blade: bool = MeleeTable.weapon_ids().has(weapon) or (row != null and row.style == &"split")
	_lab.blade = weapon if blade else &""  # a split row's weapon is a blade (the plasma sword)
	_lab.hold_ticks = row.hitstop_ticks + row.grind_ticks if row != null else 0
	_lab.spread = row != null and row.style == &"dissolve"
	_lab.pack = row != null and row.style == &"vaporise"
	_lab.claw = PlayerShock.shipped() if weapon == PlayerShock.WEAPON else null
	var solo: String = ArenaArgs.parse().text("--sig-solo")
	if solo.begins_with("start"):  # Rivet's start (+ start:dx,dy), the city block's frame
		var d: PackedStringArray = (solo.trim_prefix("start").trim_prefix(":") + ",").split(",")
		_lab.solo = stage.plan.rivet_start + Vector2(d[0].to_float(), d[1].to_float())
	elif not solo.is_empty():
		var xy: PackedStringArray = solo.split(",")
		_lab.solo = Vector2(xy[0].to_float(), xy[1].to_float())
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
			var rigs: RigHost = _find_rigs()
			if rigs != null:
				@warning_ignore("return_value_discarded")
				rigs.hidden.erase(h.id)


func write_state(out: StreamPeerBuffer) -> void:
	kills.write_state(out)


func telemetry() -> Dictionary:
	var out: Dictionary = {
		"signature_kills": kills.consumed.size(), "by_style": kills.by_style.duplicate()
	}
	if view != null and view.frames > 0:  # the kill view's CPU cost (CONTENDED machine)
		out["view_frames"] = view.frames
		out["view_avg_us"] = view.spent_us / view.frames
		out["view_worst_us"] = view.worst_us
		out["kill_cut_us"] = Array(view.kill_us)
		out["view_worst_tick"] = view.worst_tick
		out["kill_ticks"] = Array(view.kill_ticks)
		out["view_over_2ms"] = view.over_2ms
	return out


func attach_view(p_view: Node) -> void:
	var cc: CollectCallView = p_view as CollectCallView
	_game = p_view.get_parent()
	_veto_bloods.call_deferred(_game)  # the city block's CityBlood lands after the hooks attach
	var layer: CanvasLayer = _actor_layer(cc)
	if layer == null:
		return
	view = KillView.new()
	view.z_index = RenderLayers.z(&"actors") - 1
	view.ppm = SimConst.PX_PER_M
	view.reduced_motion = LaunchArgs.has("--reduced-motion")
	view.rig_lookup = _rig_of
	view.bind(kills)
	view.styles.burst_fx.flinch = not ArenaArgs.parse().has("--no-shard-flinch")  # the A/B's before
	FightShardArt.own_pop = view.styles.burst_fx.flinch
	layer.add_child(view)


## The printed path's actor layer, or the CityView's on the city block (--arena=city), where the
## rigs draw too (the dev ArenaRigs.attach); null with neither (headless).
static func _actor_layer(cc: CollectCallView) -> CanvasLayer:
	if cc == null:
		return null
	if cc.print_stage != null:
		return cc.print_stage.actor_layer()
	return cc.city_view.actor_layer() if cc.city_view != null else null


## Every standard death blood under the arena game asks the kill first: the kill prints its own
## blood (or none, fire/electro), so no standard pool, spray or corpse soak under it. On the city
## block that is CityBlood's CombatBlood as well as the print stage's.
func _veto_bloods(root: Node) -> void:
	if root is CombatBlood:
		(root as CombatBlood).veto = kills.marked_near
	for c: Node in root.get_children():
		_veto_bloods(c)


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
	var rigs: RigHost = _find_rigs()
	return rigs.rigs.rig_for(victim_id) if rigs != null else null


func _hide(victim_id: int) -> void:
	var rigs: RigHost = _find_rigs()
	if rigs != null:
		rigs.hidden[victim_id] = true


func _find_rigs() -> RigHost:
	if _rigs == null and _game != null:
		for ch: Node in _game.get_children():
			if ch is RigHost:
				_rigs = ch as RigHost
				if _rigs.react != null:  # human-reactions' DeathPipe: our kills skip the standard death
					_rigs.react.pipe.add_signature(_takes_death)
	return _rigs


func _takes_death(rig: CutRig, _hit: StringName, _dir: Vector2, _weapon: StringName) -> bool:
	return kills.consumed.has(rig.actor_id)
