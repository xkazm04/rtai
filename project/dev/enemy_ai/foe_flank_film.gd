extends Node
## Capture-only autoload for tools/film's pinned arena. The bot uses ordinary player inputs
## to circle the mount, waits for the first cooling window, then shoots from behind.


class FlankInput:
	extends GunplayBot

	var saw_cool: bool = false
	var phase: int = -1
	var flank: bool = false
	var last_tell: int = -1
	var dodge_until: int = -1
	var dodge_side: float = 1.0

	func sample(tick: int) -> TickInput:
		var rivet: Vector2 = stage.arena.rivet.pos
		var h: Fighter = _nearest(rivet)
		if h == null:
			return _input(Vector2.ZERO, Vector2.RIGHT, false)
		var mind: SquadMind = stage.arena.squad_ai.minds.get(h.id)
		if mind != null and mind.rocket != null:
			return _rocket(tick, h, mind)
		if mind != null and mind.shield != null:
			return _shield(tick, h)
		if mind == null or mind.turret == null:
			return _input(Vector2.ZERO, rivet.direction_to(h.pos), false)
		if phase != mind.turret.phase:
			phase = mind.turret.phase
			Log.info("foe-film", "%s at %d" % [FoeTurret.Phase.keys()[phase], tick])
		saw_cool = saw_cool or mind.turret.phase == FoeTurret.Phase.COOL
		var radial: Vector2 = h.pos.direction_to(rivet)
		var distance: float = rivet.distance_to(h.pos)
		var approach: Vector2 = radial * clampf((2.8 - distance) / 2.0, -1.0, 1.0)
		var turn: float = clampf(radial.angle_to(-h.facing) * 2.0, -1.0, 1.0)
		var move: Vector2 = approach + radial.rotated(PI * 0.5) * turn
		if not saw_cool or tick < 390:
			move = Vector2.ZERO
		var rear: bool = h.facing.dot(radial) < -0.4
		return _input(move, -radial, tick >= 660 and rear and _lane(rivet, h.pos), distance)

	func _rocket(tick: int, h: Fighter, mind: SquadMind) -> TickInput:
		var rivet: Vector2 = stage.arena.rivet.pos
		var aim: Vector2 = rivet.direction_to(h.pos)
		if h.tell_left > 0 and h.tell_left == mind.agent.arch.telegraph_ticks:
			Log.info("foe-film", "rocket tell %d at %s" % [tick, h.pos])
		if h.tell_left == 1:
			Log.info("foe-film", "rocket releases %d toward %s" % [tick, mind.rocket.locked_point])
			dodge_until = tick + 25
			dodge_side *= -1.0
		var move: Vector2 = aim.orthogonal() * dodge_side if tick < dodge_until else Vector2.ZERO
		var fire: bool = tick > 760 and _lane(rivet, h.pos)
		return _input(move, aim, fire, rivet.distance_to(h.pos))

	func _shield(tick: int, h: Fighter) -> TickInput:
		var rivet: Vector2 = stage.arena.rivet.pos
		var radial: Vector2 = h.pos.direction_to(rivet)
		var distance: float = rivet.distance_to(h.pos)
		if h.swing_left > 0 and last_tell != h.swing_tick:
			last_tell = h.swing_tick
			Log.info("foe-film", "shield windup at %d for %d ticks" % [last_tell, h.swing_left])
		if h.swing_left > 0:
			flank = true
		var move: Vector2 = Vector2.ZERO
		if flank:
			move = radial.rotated(PI * 0.5) + radial * clampf(1.45 - distance, -1.0, 1.0)
			if h.swing_left > 20:
				move = radial
		var rear: bool = radial.dot(h.facing) < -0.4
		var fire: bool = tick in [110, 190] or (flank and rear and (tick < 425 or tick > 575))
		return _input(move, -radial, fire and _lane(rivet, h.pos), distance)


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	get_tree().node_added.connect(_added)


func _added(node: Node) -> void:
	if node is ArenaGame:
		_install.call_deferred(node)


func _install(game: ArenaGame) -> void:
	var session: ArenaSession = game.session
	var stage: ArenaStage = session.stage
	# The hub's sparring partners otherwise chase Rivet into the pit independently of waves.
	stage.arena.hostiles.clear()
	stage.arena.rivet.pos = stage.plan.base + Vector2(5, 20.5)
	session.pilot.stop()
	var anchor: Vector2 = stage.plan.base + Vector2(15, 20.5)
	if stage.pit.squad_mix == [&"rocket_trooper"]:
		stage.arena.rivet.pos = stage.plan.base + Vector2(4.5, 15.7)
		anchor = stage.plan.base + Vector2(17, 16.3)
	stage.pit.points.assign([anchor])
	if stage.pit.squad_mix.size() > 1:
		stage.pit.points.assign([anchor + Vector2(2, 2), anchor, anchor + Vector2(2, -2)])
	stage.pit.gap_ticks = 1800
	var driver: GunplayBot = (
		FoeWalkerFilm.new(stage, session.actions, 9.0)
		if stage.pit.squad_mix.has(&"war_machine")
		else FlankInput.new(stage, session.actions, 9.0)
	)
	session.world.loop().set_input(driver)
	if stage.pit.squad_mix.has(&"rocket_trooper"):
		@warning_ignore("return_value_discarded")
		stage.arena.squad_ai.rockets.burst.connect(_burst.bind(stage.arena))
	@warning_ignore("return_value_discarded")
	session.stage.arena.struck.connect(_hit.bind(session.stage.arena))


func _burst(at: Vector2, _radius: float, _shot: Shot, arena: CombatArena) -> void:
	Log.info("foe-film", "rocket burst %d at %s" % [arena.tick, at])


func _hit(h: Fighter, dir: Vector2, dead: bool, _weapon: StringName, arena: CombatArena) -> void:
	if h.archetype in [&"sentry_turret", &"shield_robot", &"war_machine"]:
		Log.info("foe-film", "hit %d dot %.3f dead %s" % [arena.tick, h.facing.dot(-dir), dead])
