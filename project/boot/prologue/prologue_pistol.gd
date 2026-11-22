class_name ProloguePistol
extends RefCounted
## The patrol's sidearm exists only for the ranged encounter.

var id: StringName
var marked_tick: int = -1
var picked_tick: int = -1
var left: bool = false


func _init(weapon_id: StringName) -> void:
	id = weapon_id


func mark(carry: RivetCarry, at: Vector2, tick: int) -> void:
	carry.ground.drop(id, at)
	marked_tick = tick


func observe(carry: RivetCarry, prompts: ProloguePrompts, tick: int) -> void:
	if marked_tick < 0 or id not in carry.first_seen:
		return
	if picked_tick < 0:
		picked_tick = tick
		prompts.offer("wheel", tick)
	if carry.weapon() == id:
		prompts.dismiss("wheel")
		prompts.offer("fire", tick)


func clear(stage: ArenaStage) -> void:
	var carry: RivetCarry = stage.pilot.carry
	var slot: int = carry.slot_of(id)
	if carry.slots[slot] == id:
		carry.slots[slot] = &""
	carry.first_seen.erase(id)
	for item: WeaponPickups.Item in carry.ground.items.duplicate():
		if item.id == id:
			carry.ground.items.erase(item)
	carry.current = -1
	stage.arena.rivet.weapon = &""
	stage.arena.gun = null
	stage.pilot.wheel.bind(carry)


func leave(stage: ArenaStage) -> void:
	clear(stage)
	left = true
