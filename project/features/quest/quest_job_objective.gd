class_name QuestJobObjective
extends RefCounted
## The job verbs of quest 1 (collect-call) on top of QuestObjective: evade (lose the heat, and
## for "then answer the payphone" targets ring the beat's phone and wait for Patch to connect),
## answer (the beat's payphone), meet (talk to every listed actor; nobody opens up while Rivet
## is hot), fight (the encounter staged at the marker is cleared) and sabotage (reach the marker,
## which starts its encounter, then clear it and finish the sabotage). The world owns the
## payphone router, the encounters and the sabotage target; the quest only asks (LAY-05).

const PHASE_START: int = 0
const PHASE_SECOND: int = 1


static func start(o: QuestObjective, world: QuestWorld) -> void:
	match o.beat.handler:
		QuestRules.Handler.ANSWER:
			world.ask(QuestWorld.Ask.RING_PHONE, o.beat.location)
		QuestRules.Handler.MEET:
			for tag: String in o.beat.targets:
				world.spawn_actor(tag)
		QuestRules.Handler.FIGHT:
			world.ask(QuestWorld.Ask.START_ENCOUNTER, o.beat.location)


static func check(o: QuestObjective, world: QuestWorld, radius_m: float) -> StringName:
	match o.beat.handler:
		QuestRules.Handler.EVADE:
			return _evade(o, world)
		QuestRules.Handler.ANSWER:
			return _done(world.reached(QuestWorld.Goal.PHONE_CONNECTED, o.beat.location))
		QuestRules.Handler.MEET:
			return _meet(o, world, radius_m)
		QuestRules.Handler.FIGHT:
			return _done(world.reached(QuestWorld.Goal.ENCOUNTER_CLEARED, o.beat.location))
	return _sabotage(o, world)


static func _evade(o: QuestObjective, world: QuestWorld) -> StringName:
	if o.phase == PHASE_START:
		if world.wanted_level() > 0:
			return QuestObjective.RUNNING
		if not o.beat.then_answer:
			return QuestObjective.DONE
		o.phase = PHASE_SECOND
		world.ask(QuestWorld.Ask.RING_PHONE, o.beat.location)
	return _done(world.reached(QuestWorld.Goal.PHONE_CONNECTED, o.beat.location))


## One interact press meets the nearest unmet listed actor in reach, only at heat 0.
static func _meet(o: QuestObjective, world: QuestWorld, radius_m: float) -> StringName:
	var here: Vector2 = world.focus_position()
	var best: String = ""
	var best_d: float = radius_m
	for tag: String in o.beat.targets:
		var d: float = world.actor_position(tag).distance_to(here)
		if not o.met.has(tag) and d <= best_d:
			best = tag
			best_d = d
	if best != "" and world.wanted_level() == 0 and world.interact_pressed():
		o.met.append(best)
		o.newly_met.append(best)
	return _done(o.met.size() == o.beat.targets.size())


static func _sabotage(o: QuestObjective, world: QuestWorld) -> StringName:
	if o.phase == PHASE_START:
		if not o.arrived(world.focus_position()):
			return QuestObjective.RUNNING
		o.phase = PHASE_SECOND
		world.ask(QuestWorld.Ask.START_ENCOUNTER, o.beat.location)
	var cleared: bool = world.reached(QuestWorld.Goal.ENCOUNTER_CLEARED, o.beat.location)
	return _done(cleared and world.reached(QuestWorld.Goal.SABOTAGED, o.beat.location))


static func _done(yes: bool) -> StringName:
	return QuestObjective.DONE if yes else QuestObjective.RUNNING
