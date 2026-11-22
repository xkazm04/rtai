class_name PrologueBodies
extends CorpseDecayHook
## These are already-dead opening cast members. They use the human body and corpse rig
## paths without emitting a new kill, raising heat, or drawing from the combat RNG.

const FIRST_ID: int = 1000

var opening: Array[Fighter] = []


static func place(stage: ArenaStage, data: DataTable, ctx: WorldContext) -> PrologueBodies:
	var hook: PrologueBodies = PrologueBodies.new()
	hook.setup(stage, ctx)
	# The hook snapshots the arena's respawning fixtures once. Our corpses should be released.
	hook.step(stage, stage.tick)
	var rng: RandomNumberGenerator = ctx.rng.stream(&"prologue")
	var next_id: int = FIRST_ID
	for row: Dictionary in data.array(data.raw, "opening_bodies"):
		var officer: Fighter = Fighter.make(
			Fighter.Kind.GUARD, next_id, data.vec(row, "at"), stage.arena.tuning.human["hp"]
		)
		officer.archetype = &"patrol_cop"
		officer.body_class = RivetBody.PERSON
		officer.radius_m = ArenaBodies.table().radius(officer.body_class)
		officer.facing = Vector2.RIGHT.rotated(rng.randf_range(-PI, PI))
		officer.take(officer.max_hp, stage.tick, officer.facing)
		stage.arena.hostiles.append(officer)
		hook.opening.append(officer)
		next_id += 1
	stage.hooks.append(hook)
	return hook


func restore_opening(tick: int) -> void:
	for officer: Fighter in opening:
		decay.forget(officer.id)
		if _stage.arena.hostiles.has(officer):
			decay.add(officer.id, tick)
		else:
			# Decay released this body. Its normal booking pass runs again on the next tick.
			_stage.arena.hostiles.append(officer)
