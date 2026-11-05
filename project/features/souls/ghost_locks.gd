class_name GhostLocks
extends RefCounted
## d7-calls ghost-powers-5 (owner, 2026-11-05): a ghost stays locked until its act. Each
## ghost_forms.json row may name `unlock`, the quest whose completion unlocks it ("" = always
## free). The shipped story turns the lock on with the quests it has done (quest 1: none, so Dent
## is locked); the showcase paths (the dev arena, `--arena=city`, `--bot=ghosts`) never turn it on,
## so every ghost stays free there. The picker skips a locked ghost and Q refuses it (LOCKED).

const LOCKED: StringName = &"locked"

## false = every ghost free (the showcase paths and the tests that predate the lock).
var on: bool = false
## The quests the story has completed (an `unlock` named here frees its ghost).
var done: Array[StringName] = []
## Fault injection for the scenario (never set in game): the lock is ignored.
var plant_ignore: bool = false


func allows(table: GhostFormTable, id: StringName) -> bool:
	if not on or plant_ignore:
		return true
	var f: GhostFormDef = table.form(id)
	return f != null and (f.unlock == &"" or done.has(f.unlock))


## The next free ghost after `id` in the cycle (`id` itself when no other is free).
func next_after(table: GhostFormTable, id: StringName) -> StringName:
	var n: StringName = id
	for _i: int in table.order.size():
		n = table.next_after(n)
		if allows(table, n):
			return n
	return id


## The first free ghost in the cycle (&"" when none is).
func first(table: GhostFormTable) -> StringName:
	for id: StringName in table.order:
		if allows(table, id):
			return id
	return &""
