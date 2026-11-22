class_name GauntletLiveWave
extends RefCounted
## A roster stays in composition order. Its measurement interval starts at the first spawn
## and ends after the last member falls, even when another wave has joined the fight.

var start_tick: int = -1
var row: Dictionary
var members: Array[Fighter] = []
var stats: GauntletWaveStats = GauntletWaveStats.new()
var _roster: Array[StringName]
var _delayed: int
var _counts: Dictionary[StringName, int] = {&"hits": 0, &"hits_melee": 0, &"hits_gun": 0}


func _init(roster: Array[StringName], slots: int) -> void:
	_roster = roster
	_delayed = maxi(0, roster.size() - slots)


func remaining() -> int:
	return _roster.size() - members.size()


func cleared() -> bool:
	if remaining() > 0:
		return false
	for foe: Fighter in members:
		if foe.alive():
			return false
	return true


func seconds(tick: int) -> float:
	return (tick - start_tick) * SimClock.TICK_DT


func spawn(
	stage: ArenaStage, block: GauntletSegment, slots: int, tick: int, run: GauntletRun
) -> int:
	var count: int = mini(remaining(), slots)
	if count == 0:
		return 0
	if start_tick < 0:
		start_tick = tick
		run.begin_wave({})
		row = run.waves[-1]
		row["spawn_delayed"] = _delayed
		stats.begin(stage)
	var enemies: Dictionary = row["enemies"]
	for i: int in range(members.size(), members.size() + count):
		var at: Vector2 = block.spawns[i % block.spawns.size()]
		var foe: Fighter = stage.arena.squad_ai.spawn_member(stage.arena, at, _roster[i])
		# Reused anchors keep the arena spawner's seeded spread, constrained to this block.
		var offset: Vector2 = (
			(foe.pos - at).limit_length(1.2) if i >= block.spawns.size() else Vector2.ZERO
		)
		foe.pos = stage.walls.push_out(at + offset, foe.radius_m)
		members.append(foe)
		var id: String = String(foe.archetype)
		var previous: int = enemies.get(id, 0)
		enemies[id] = previous + 1
	return count


func contact(victim: Fighter, counter: StringName) -> void:
	if members.has(victim):
		_counts[counter] += 1


func finish(stage: ArenaStage, pilot: GauntletPilot, tick: int, was_cleared: bool) -> void:
	stats.finish(stage, row)
	stats.collect_pilot(pilot, row)
	row.merge(_counts)
	if was_cleared:
		row["seconds"] = seconds(tick)
