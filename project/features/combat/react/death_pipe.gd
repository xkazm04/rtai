class_name DeathPipe
extends RefCounted
## The reaction and death pipeline for humans: one call per landed hit. A signature kill (lane
## brutality) registers a Callable(rig: CutRig, hit_class: StringName, dir: Vector2,
## weapon: StringName) -> bool; the first one that returns true owns the death and the standard
## one is skipped. Otherwise the damage class picks the standard death (death_map).

var table: ReactTable
var _signatures: Array[Callable] = []


static func make(p_table: ReactTable) -> DeathPipe:
	var p: DeathPipe = DeathPipe.new()
	p.table = p_table
	return p


func add_signature(c: Callable) -> void:
	_signatures.append(c)


## Kills `rig` with a hit of `hit_class` along `dir` (world); returns the death played
## (&"signature" when a signature kill took it).
func kill(rig: CutRig, hit_class: StringName, dir: Vector2, weapon: StringName) -> StringName:
	for c: Callable in _signatures:
		var took: Variant = c.call(rig, hit_class, dir, weapon)
		if took is bool and took:
			return &"signature"
	var kind: StringName = table.death_for(hit_class)
	HumanReact.on(rig).play(rig, kind, dir, table)
	return kind


## Kills the robot `rig` (the thug) along `dir` (world): the power-down death. No signature
## and no death_map: brutality's kills and the damage classes are human-only.
func kill_robot(rig: CutRig, dir: Vector2) -> StringName:
	HumanReact.on(rig).play(rig, &"death_robot", dir, table)
	return &"death_robot"


## A wounding hit: picks and plays the wound family; returns it.
func wound(
	rig: CutRig, hit_class: StringName, dir: Vector2, shielded: bool, in_cover: bool
) -> StringName:
	var local: Vector2 = dir.normalized().rotated(-rig.facing)
	var kind: StringName = table.reaction_for(hit_class, local, shielded, in_cover)
	HumanReact.on(rig).play(rig, kind, dir, table)
	return kind
