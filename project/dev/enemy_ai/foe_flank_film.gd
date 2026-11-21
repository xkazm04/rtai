extends Node
## Capture-only autoload for tools/film's pinned arena. The bot uses ordinary player inputs
## to circle the mount, waits for the first cooling window, then shoots from behind.


class FlankInput:
	extends GunplayBot

	var saw_cool: bool = false

	func sample(tick: int) -> TickInput:
		var rivet: Vector2 = stage.arena.rivet.pos
		var h: Fighter = _nearest(rivet)
		if h == null or _next < ArenaPitBot.ENTRY.size():
			return super.sample(tick)
		var mind: SquadMind = stage.arena.squad_ai.minds.get(h.id)
		if mind == null or mind.turret == null:
			return super.sample(tick)
		saw_cool = saw_cool or mind.turret.phase == FoeTurret.Phase.COOL
		var radial: Vector2 = h.pos.direction_to(rivet)
		var distance: float = rivet.distance_to(h.pos)
		var approach: Vector2 = radial * clampf((2.8 - distance) / 2.0, -1.0, 1.0)
		var turn: float = clampf(radial.angle_to(-h.facing) * 2.0, -1.0, 1.0)
		var move: Vector2 = approach + radial.rotated(PI * 0.5) * turn
		var rear: bool = h.facing.dot(radial) < -0.4
		return _input(move, -radial, saw_cool and rear and _lane(rivet, h.pos), distance)


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	get_tree().node_added.connect(_added)


func _added(node: Node) -> void:
	if node is ArenaGame:
		_install.call_deferred(node)


func _install(game: ArenaGame) -> void:
	var session: ArenaSession = game.session
	session.world.loop().set_input(FlankInput.new(session.stage, session.actions, 9.0))
	@warning_ignore("return_value_discarded")
	session.stage.arena.struck.connect(_hit.bind(session.stage.arena))


func _hit(h: Fighter, dir: Vector2, dead: bool, _weapon: StringName, arena: CombatArena) -> void:
	if h.archetype == &"sentry_turret":
		Log.info("foe-film", "hit %d dot %.3f dead %s" % [arena.tick, h.facing.dot(-dir), dead])
