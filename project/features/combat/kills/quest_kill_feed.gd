class_name QuestKillFeed
extends WorldSystem
## n31 melee 03p2: the signature-kill feed in quest 1 (on by default since 03p3; `--kill-feed=off`
## restores the generic deaths). Quest 1's stage is a plain CollectCallStage (no ArenaHook list), so
## this is a world system after the stage: CombatArena's lethal hits go into SignatureKills from
## the `brutality` RNG stream on the 60 Hz tick, and its state folds into the world hash (SimLoop
## folds every system). The view half (attach_view) draws the kills over the rig cast; the sprite
## cast cannot hide a consumed body, so Quest1Session installs the feed only with the rigs.
## `--gore=reduced` turns every signature kill into the standard death. The quest's script and
## lines are untouched: this only changes how a body that is already dead is drawn.

var kills: SignatureKills = null
var view: KillView = null
var _stage: CollectCallStage = null
var _fire: KillFireSource = null
var _game: Node = null
var _rigs: RigHost = null


## Added to the world after `stage` (so it steps after the stage's arena each tick).
func _init(stage: CollectCallStage) -> void:
	_stage = stage


## True when quest 1 draws its fighters on the cast rigs (Quest1Game._dev_rigs: `-- --rigs` in a
## debug build, or the standing cards with `rigs_under_cards`), not the sprite cast.
static func rig_cast(rigs_under_cards: bool) -> bool:
	var dev: bool = LaunchArgs.has("--rigs") and OS.is_debug_build()
	return dev or (rigs_under_cards and ViewMode.shared().cards)


## A feed on `stage`, registered through `add_system` (World.add_system: after the stage, so it
## steps after the stage's arena each tick).
static func install(add_system: Callable, stage: CollectCallStage) -> QuestKillFeed:
	var feed: QuestKillFeed = QuestKillFeed.new(stage)
	add_system.call(feed)
	return feed


## The feed's view (attach_view) when there is a feed; none (null) draws nothing.
static func attach(feed: QuestKillFeed, game: Node, cc: CollectCallView) -> void:
	if feed != null:
		feed.attach_view(game, cc)


func setup(ctx: WorldContext) -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	table.gore_full = SignatureKillTable.gore_from_args(LaunchArgs.value("--gore"))
	kills = SignatureKills.new(table, ctx.rng.stream(&"brutality"))
	kills.push_out = _stage.collide_preview
	@warning_ignore("return_value_discarded")
	_stage.arena.kill_landed.connect(_on_kill_landed)
	_fire = KillFireSource.watch(_stage.arena)


func step(p_tick: int, _input: TickInput) -> void:
	kills.step(p_tick)
	if kills.consumed.is_empty():
		return
	for h: Fighter in _stage.arena.hostiles:  # a re-spawned body is whole again
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
	return {"signature_kills": kills.consumed.size(), "by_style": kills.by_style.duplicate()}


## The KillView on the print stage's actor layer (or the city view's); `game` is the node whose
## child RigHost draws the cast (Quest1Game: ArenaRigs).
func attach_view(game: Node, cc: CollectCallView) -> void:
	_game = game
	_veto_bloods.call_deferred(game)
	var layer: CanvasLayer = BrutalityHook._actor_layer(cc)
	if layer == null:
		return
	view = KillView.new()
	view.z_index = RenderLayers.z(&"actors") - 1
	view.ppm = SimConst.PX_PER_M
	view.reduced_motion = LaunchArgs.has("--reduced-motion")
	view.rig_lookup = _rig_of
	view.bind(kills)
	layer.add_child(view)


func _on_kill_landed(
	victim: Fighter, weapon: StringName, dir: Vector2, _at: Vector2, kind: StringName
) -> void:
	var e: KillEvent = KillEvent.of_fighter(victim, dir, _fire.weapon_of(victim.id, weapon))
	e.damage_type = kind
	if kills.on_kill(e):
		var rigs: RigHost = _find_rigs()
		if rigs != null:
			rigs.hidden[victim.id] = true


## Every standard death blood under the game asks the kill first (BrutalityHook._veto_bloods).
func _veto_bloods(root: Node) -> void:
	if root is CombatBlood:
		(root as CombatBlood).veto = kills.marked_near
	for c: Node in root.get_children():
		_veto_bloods(c)


func _rig_of(victim_id: int) -> CutRig:
	return RobotShutdownFx.rig_for(_find_rigs(), victim_id)


func _find_rigs() -> RigHost:
	if _rigs == null and _game != null:
		for ch: Node in _game.get_children():
			if ch is RigHost:
				_rigs = ch as RigHost
				if _rigs.react != null:  # the DeathPipe: our kills skip the standard death
					_rigs.react.pipe.add_signature(_takes_death)
	return _rigs


func _takes_death(rig: CutRig, _hit: StringName, _dir: Vector2, _weapon: StringName) -> bool:
	return kills.consumed.has(rig.actor_id)
