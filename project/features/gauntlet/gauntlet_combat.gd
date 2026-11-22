class_name GauntletCombat
extends CombatArena
## CombatArena omits Rivet from actor_killed. Observe the lethal transition at its damage entry,
## where melee, projectiles and area hits still carry the source ID. Combat owns the hit itself.

signal rivet_contact(victim: Fighter, counter: StringName)

const FIRED: StringName = &"gauntlet_fired"

var run: GauntletRun
var repair_in_wave: bool = false
var wave_live: bool = false
var enemy_damage_k: float = 1.0
var _round_starts: Dictionary[Shot, Vector2] = {}
var _melee: Array[StringName] = MeleeTable.weapon_ids()
var _departed: Dictionary[int, StringName] = {}


static func install(stage: ArenaStage, ctx: WorldContext, state: GauntletRun) -> void:
	# The street opens an empty stage. Keep the configured Rivet, tuning and combat RNG.
	var initial: CombatArena = stage.arena
	var combat: GauntletCombat = GauntletCombat.new(
		initial.tuning, ctx.events, ctx.rng.stream(&"combat")
	)
	combat.rivet = initial.rivet
	combat.metal = initial.metal
	combat.walls = stage.walls
	combat.run = state
	combat._melee.append_array(
		[PlayerMelee.WEAPON, DentJab.WEAPON, &"kerf_slice", &"stomp", &"ram"]
	)
	stage.arena = combat


func configure_repair(rules: DataTable) -> void:
	var row: Dictionary = rules.raw.get("rivet", {})
	repair_in_wave = row.get("repair_in_wave", false)
	for key: String in ["repair_per_s", "repair_delay_s"]:
		if row.has(key):
			tuning.rivet[key] = rules.num(row, key)


func can_repair() -> bool:
	return (repair_in_wave or not wave_live) and tuning.rivet["repair_per_s"] > 0.0


func _repair() -> void:
	if can_repair():
		super._repair()


## Tag rounds at the trigger. A hostile round returned by the sword also has Rivet's shooter ID.
func rivet_fire(at: Vector2) -> bool:
	var first: int = shots.size()
	if not super.rivet_fire(at):
		return false
	for i: int in range(first, shots.size()):
		shots[i].set_meta(FIRED, true)
	return true


func _step_shots() -> void:
	for shot: Shot in shots:
		_round_starts[shot] = shot.pos
	super._step_shots()
	_round_starts.clear()


## ArenaProjectiles advances in array order and dispatches damage before advancing the next
## round. The last moved, still-live round is the source. Only its first body on the actual
## swept segment counts. A thrown bottle, chain hop, ground fire or splash cannot score a hit.
func _direct_round(victim: Fighter) -> bool:
	for i: int in range(shots.size() - 1, -1, -1):
		var shot: Shot = shots[i]
		if not _round_starts.has(shot) or shot.pos == _round_starts[shot]:
			continue
		if (
			not shot.has_meta(FIRED)
			or (shot.spec != null and shot.spec.kind == WeaponSpec.Kind.THROWN)
		):
			return false
		if not shot.crossed(_round_starts[shot], victim.pos, victim.radius_m):
			return false
		shot.remove_meta(FIRED)
		return true
	return false


func damage(
	victim: Fighter, amount: float, killer_id: int, weapon: StringName, kind: StringName = &"shot"
) -> void:
	if killer_id == rivet.id and victim != rivet and victim.alive() and victim.exposed:
		if _melee.has(weapon):
			rivet_contact.emit(victim, &"hits_melee")
		elif not _round_starts.is_empty() and _direct_round(victim):
			rivet_contact.emit(victim, &"hits_gun")
	var was_alive: bool = victim == rivet and victim.alive()
	if victim == rivet and killer_id != rivet.id:
		amount *= enemy_damage_k
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
