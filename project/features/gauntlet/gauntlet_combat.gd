class_name GauntletCombat
extends CombatArena
## CombatArena omits Rivet from actor_killed. Observe the lethal transition at its damage entry,
## where melee, projectiles and area hits still carry the source ID. Combat owns the hit itself.

var run: GauntletRun
var _departed: Dictionary[int, StringName] = {}


static func install(stage: ArenaStage, ctx: WorldContext, state: GauntletRun) -> void:
	# The street opens an empty stage. Keep the configured Rivet, tuning and combat RNG.
	var initial: CombatArena = stage.arena
	var combat: GauntletCombat = GauntletCombat.new(
		initial.tuning, ctx.events, ctx.rng.stream(&"combat")
	)
	combat.rivet = initial.rivet
	combat.metal = initial.metal
	combat.run = state
	stage.arena = combat


func damage(
	victim: Fighter, amount: float, killer_id: int, weapon: StringName, kind: StringName = &"shot"
) -> void:
	var was_alive: bool = victim == rivet and victim.alive()
	super.damage(victim, amount, killer_id, weapon, kind)
	if was_alive and not victim.alive():
		var by: StringName = weapon if weapon != &"" else &"unknown"
		run.death_by = by if kind in [&"blown", &"burned"] else _source(killer_id, by)


## A projectile can outlive its wave. Retain only the shooters of rounds still in flight.
func retire_wave() -> void:
	var still_flying: Dictionary[int, StringName] = {}
	for shot: Shot in shots:
		if not shot.from_rivet:
			still_flying[shot.shooter_id] = _source(shot.shooter_id, shot.weapon)
	_departed = still_flying


func _source(id: int, fallback: StringName) -> StringName:
	for foe: Fighter in hostiles:
		if foe.id == id and foe.archetype != &"":
			return foe.archetype
	var previous: StringName = _departed.get(id, &"")
	return previous if previous != &"" else fallback
