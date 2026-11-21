class_name FoeTtkTrial
extends RefCounted
## Count a round once on impact with the sole target (direct or splash). Ground fire
## still deals its real damage. No damage-over-time ticks count as additional rounds.

const DISTANCE_M: float = 8.0
const LIMIT: int = 30 * SimClock.TICK_RATE

var hits: int = 0
var wounded: bool = false


func measure(
	id: StringName, weapon: StringName, rear: bool, registry: RngRegistry, table: WeaponTable
) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), bus, registry.stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2.ZERO, id)
	h.brain_owned = true
	h.facing = Vector2.RIGHT if rear else Vector2.LEFT
	arena.rivet.pos = h.pos + Vector2.LEFT * DISTANCE_M
	arena.rivet.facing = arena.rivet.pos.direction_to(h.pos)
	@warning_ignore("return_value_discarded")
	arena.wounded.connect(_wound)
	@warning_ignore("return_value_discarded")
	arena.struck.connect(_strike)
	var melee: PlayerMelee
	if weapon == MeleeTable.CLAW:
		melee = PlayerMelee.new()
	else:
		arena.rivet.weapon = weapon
		arena.gun = GunHand.make(table, weapon, registry.stream(&"gunplay"))
		arena.gun.tap = true
	var row: Dictionary = _fire(arena, h, melee)
	bus.free()
	return row


func _fire(arena: CombatArena, h: Fighter, melee: PlayerMelee) -> Dictionary:
	var attempts: int = 0
	var killed: int = LIMIT + 1
	for tick: int in range(1, LIMIT + 1):
		if melee != null:
			# Both positions stay fixed, including during a claw lunge.
			@warning_ignore("return_value_discarded")
			melee.step(arena, true, arena.rivet.facing)
			attempts = melee.landed + melee.whiffs
			hits = melee.landed
		else:
			var trigger: Trigger = arena.gun.trigger
			# A fresh press when ready gives the charge gun its fastest tap cadence.
			if trigger.spec.charge_ticks == 0 or trigger.cooldown != 1:
				if arena.rivet_fire(h.pos):
					attempts += trigger.spec.pellets
		arena.step(tick)
		if not h.alive():
			killed = tick
			break
	return {
		"tick": killed, "attempts": attempts, "hits": hits, "first": not h.alive() and not wounded
	}


func _wound(_target: Fighter, _weapon: StringName) -> void:
	wounded = true


func _strike(_target: Fighter, _dir: Vector2, _lethal: bool, weapon: StringName) -> void:
	if weapon != &"burn":
		hits += 1
