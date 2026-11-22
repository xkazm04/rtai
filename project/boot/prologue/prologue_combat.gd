class_name PrologueCombat
extends CombatArena
## Apply the commander's last-man rule before CombatArena emits a kill or drops a body.

var formation: PrologueFormation


func damage(
	victim: Fighter, amount: float, killer_id: int, weapon: StringName, kind: StringName = &"shot"
) -> void:
	if formation != null:
		if victim == formation.boss and formation.men_standing():
			amount = minf(amount, victim.hp - formation.last_stand_hp)
		elif victim in formation.shields and kind == &"shot":
			var riot: EnemyRoster.Archetype = squad_ai.pit.roster.archetype(victim.archetype)
			if victim.facing.dot(-hit_dir.normalized()) >= riot.shield_cos:
				amount *= riot.shield_front_mult
	if amount > 0.0:
		super.damage(victim, amount, killer_id, weapon, kind)
	if formation != null and victim in formation.shields and not formation.shields_standing():
		formation.boss.exposed = true


func _drop(victim: Fighter) -> void:
	if formation == null or victim not in formation.members:
		super._drop(victim)
