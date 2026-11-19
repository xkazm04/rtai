class_name StreetMovesTrace
extends RefCounted
## One observed quest run, including the city position used to start the next tick.

var feet: PackedVector2Array = []
var city_feet: PackedVector2Array = []
var counts: Dictionary[String, int] = {
	"ticks": 0,
	"vault_starts": 0,
	"vault_refusals": 0,
	"landings": 0,
	"snaps": 0,
	"cover_refusals": 0,
	"airborne_ticks": 0,
	"overlaps": 0,
	"car_contacts": 0
}
var starts: PackedInt32Array = []
var kinds: Dictionary[String, int] = {}
var digest: String
var failure: String
var contacts: StreetMovesContacts = StreetMovesContacts.new()
var target_feet: int = 0
var target_resolved: int = 0
var road_landings: int = 0


static func record(tape: StreetMovesTape, expected: StreetMovesTrace = null) -> StreetMovesTrace:
	var trace: StreetMovesTrace = StreetMovesTrace.new()
	var bus: EventBus = EventBus.new()
	var s: Quest1Session = Quest1Session.open(bus, Data, StreetMovesTape.SEED)
	if s == null or s.city == null:
		trace.failure = "quest 1 did not open on the city"
	else:
		tape.bind(s)
		for tick: int in StreetMovesTape.TICKS:
			trace.advance(s, tape)
			if trace.failure == "" and expected != null:
				if (
					trace.feet[tick] != expected.feet[tick]
					or trace.city_feet[tick] != expected.city_feet[tick]
				):
					trace.failure = "replay position diverged"
			if trace.failure != "":
				trace.failure = "seed %d tick %d: %s" % [StreetMovesTape.SEED, tick, trace.failure]
				break
		trace.digest = s.world.loop().state_hash()
	if s != null:
		# Release the live cursor and the two back-references a running quest normally owns.
		s.live.cursor_px = Callable()
		s.autosave = null
		s.stage.watch(null)
		s.world.free()
	bus.free()
	return trace


func advance(s: Quest1Session, tape: StreetMovesTape) -> void:
	var m: PlayerMotion = s.pilot.motion
	var last: VaultProbe.Hit = m.vault.hit
	var before: PlayerCover.Phase = m.cover.phase
	var incoming: Vector2 = Vector2.INF
	if s.city.body.knocked():
		incoming = s.city.body.pos + s.city.body.knock_vel * SimClock.TICK_DT
	s.step()
	var p: Vector2 = s.stage.arena.rivet.pos
	var resolved: Vector2 = s.city.target
	@warning_ignore("return_value_discarded")
	feet.append(p)
	@warning_ignore("return_value_discarded")
	city_feet.append(resolved)
	_observe(s, tape, last, before)
	counts["car_contacts"] += int(contacts.traffic(s, p if incoming == Vector2.INF else incoming))
	if m.vault.frame == m.vault.ticks - 1:
		var code: int = s.city.sim.cell_at(p.x, p.y)
		road_landings += int(code == SimConst.C_LANE and contacts.near_traffic)
	failure = VaultTrial.forbidden_contact(s.stage)
	if failure == "":
		failure = contacts.centre(s, p)
		target_feet += int(contacts.over_target)
	if failure == "":
		failure = contacts.centre(s, resolved)
		target_resolved += int(contacts.over_target)
	if failure != "":
		counts["overlaps"] += 1
		failure += (
			" (feet %s resolved %s heading %s frame %d)"
			% [p, resolved, s.pilot.facing(), m.vault.frame]
		)


func _observe(
	s: Quest1Session, tape: StreetMovesTape, last: VaultProbe.Hit, before: PlayerCover.Phase
) -> void:
	var tick: int = s.stage.tick
	var m: PlayerMotion = s.pilot.motion
	var bits: int = TickInput.unpack(tape.words[tick]).buttons
	var prev: int = TickInput.unpack(tape.words[tick - 1]).buttons if tick > 0 else 0
	var cover: bool = ((bits & ~prev) & (1 << s.actions.bit(&"cover"))) != 0
	counts["ticks"] += 1
	counts["vault_refusals"] += int(m.vault.hit != last and m.vault.frame != 0)
	counts["landings"] += int(m.vault.frame == m.vault.ticks - 1)
	counts["snaps"] += int(before == PlayerCover.Phase.OFF and m.cover.spot != null)
	counts["cover_refusals"] += int(
		cover and before == PlayerCover.Phase.OFF and m.cover.spot == null
	)
	counts["airborne_ticks"] += int(m.vault.airborne())
	if m.vault.frame == 0:
		counts["vault_starts"] += 1
		@warning_ignore("return_value_discarded")
		starts.append(tick)
		var kind: String = m.vault.hit.kind
		kinds[kind] = kinds.get(kind, 0) + 1
