class_name FoeMix
extends RefCounted


## Set up the pit encounter. Mounts join the end of the stage's hook list only when a
## turret actually spawns, after the stations that resolve contacts and weapon knockback.
static func configure(stage: ArenaStage, args: ArenaArgs, table: Array) -> Array:
	var squad: ArenaSquad = stage.arena.squad_ai
	squad.mounts.host = weakref(stage)
	return choose(args, squad.pit.roster, stage.pit, table)


## An explicit list is the whole encounter, including repeated ids. Validate the whole
## list before changing wave sizes so a typo leaves the table encounter intact.
static func choose(args: ArenaArgs, roster: EnemyRoster, pit: ArenaPit, table: Array) -> Array:
	if not args.has("--foe-mix"):
		return table
	var ids: Array[StringName] = []
	for token: String in args.text("--foe-mix").split(","):
		var id: StringName = StringName(token.strip_edges())
		if id == &"" or roster.archetype(id) == null:
			Log.error("arena", "unknown --foe-mix id '%s', using the table mix" % token)
			return table
		ids.append(id)
	pit.first_wave = ids.size()
	pit.max_wave = ids.size()
	pit.grow = 0
	return ids
