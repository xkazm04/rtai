class_name PrologueCombat
extends CombatArena
## Apply the commander's last-man rule before CombatArena emits a kill or drops a body.

var formation: PrologueFormation
var pin_ticks: int
var pinned_until: int = -1
var first_catch_tick: int = -1
var catcher: Fighter


func damage(
	victim: Fighter, amount: float, killer_id: int, weapon: StringName, kind: StringName = &"shot"
) -> void:
	if formation != null:
		if victim == formation.boss and formation.men_standing():
			amount = minf(amount, victim.hp - formation.last_stand_hp)
		elif victim in formation.shields and kind == &"shot":
			var riot: EnemyRoster.Archetype = squad_ai.pit.roster.archetype(victim.archetype)
			if (
				formation.braced(victim)
				and victim.facing.dot(-hit_dir.normalized()) >= riot.shield_cos
			):
				return
	if amount > 0.0:
		var before: float = victim.hp
		super.damage(victim, amount, killer_id, weapon, kind)
		if victim == rivet and weapon == &"catch_pole" and victim.hp < before:
			for h: Fighter in hostiles:
				if h.id == killer_id:
					if first_catch_tick < 0:
						first_catch_tick = tick
					catcher = h
					pinned_until = tick + pin_ticks
					break
	if formation != null and victim in formation.shields and not formation.shields_standing():
		formation.boss.exposed = true


func _drop(victim: Fighter) -> void:
	if formation == null or victim not in formation.members:
		super._drop(victim)
