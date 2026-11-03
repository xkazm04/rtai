extends Scenario
## features/combat/ai in the pit: every archetype fights the scripted Rivet (PitDummy); the squad
## cap holds (never more than max_shooters winding up or firing); telegraphs are dodgeable (a
## dummy that reads tells takes far fewer hits than one that stands); flankers spread round
## Rivet; cover users hide between bursts; patrol cops panic when the squad falls, robots never;
## the same seed replays to the same digest. Planted faults (TST-05): the squad cap off and the
## aim lock off must each fail their judge.

## The dummy nails only inside this range, so every archetype gets to show its attack.
const FIGHT_M: float = 10.0
const IDS: Array[StringName] = [&"patrol_cop", &"riot_cop", &"swat", &"robot_thug", &"robot_gunner"]


func run(_tree: SceneTree) -> String:
	var ev: Dictionary = {}
	ev["archetypes"] = _archetypes()
	ev["squad"] = _squad_cap(false)
	ev["planted_no_squad"] = _squad_cap(true)
	ev["dodge"] = _dodge(PitDummy.Mode.DODGE, false)
	ev["stand"] = _dodge(PitDummy.Mode.STAND, false)
	ev["planted_no_lock"] = _dodge(PitDummy.Mode.DODGE, true)
	ev["flank"] = EnemyPitChecks.flank_spread()
	ev["cover"] = EnemyPitChecks.cover_hidden()
	ev["panic"] = EnemyPitChecks.panic()
	ev["determinism"] = _determinism()
	Log.info("scenario", "enemy pit: %s" % ev)
	var err: String = write_evidence("enemy-pit.json", ev)
	return err if err != "" else EnemyPitChecks.judge(ev)


func _archetypes() -> Dictionary:
	var out: Dictionary = {}
	for id: StringName in IDS:
		var pit: EnemyPit = PitLayout.build(7)
		PitLayout.squad(pit, PitLayout.many(id, 3))
		var dummy: PitDummy = PitDummy.new(PitDummy.Mode.FIGHT, PitLayout.RIVET_START)
		dummy.fire_m = FIGHT_M
		out[String(id)] = PitLayout.fight(pit, dummy, 40.0)
	return out


func _squad_cap(plant: bool) -> Dictionary:
	var pit: EnemyPit = PitLayout.build(11, false)
	PitLayout.squad(pit, PitLayout.many(&"patrol_cop", 6))
	pit.plant_no_squad = plant
	var r: Dictionary = PitLayout.fight(pit, PitDummy.new(PitDummy.Mode.STAND), 15.0)
	r["max_shooters"] = pit.roster.max_shooters
	return r


func _dodge(mode: PitDummy.Mode, plant: bool) -> Dictionary:
	var pit: EnemyPit = PitLayout.build(13, false)
	PitLayout.squad(pit, [&"patrol_cop", &"swat", &"robot_gunner"])
	pit.plant_no_lock = plant
	pit.rivet_hp = 100000.0
	var dummy: PitDummy = PitDummy.new(mode, PitLayout.RIVET_START)
	dummy.watch_rounds = false
	return PitLayout.fight(pit, dummy, 20.0)


func _determinism() -> Dictionary:
	var a: Array[String] = []
	for s: int in [21, 21, 22]:
		var pit: EnemyPit = PitLayout.build(s)
		PitLayout.squad(pit, IDS)
		var r: Dictionary = PitLayout.fight(pit, PitDummy.new(PitDummy.Mode.FIGHT), 12.0)
		a.append(r["digest"])
	return {"a": a[0], "b": a[1], "other_seed": a[2]}
