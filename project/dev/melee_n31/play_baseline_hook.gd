class_name PlayBaselineHook
extends ArenaHook
## n31 melee 01b: holds the test player to ONE melee weapon (or the bare claw) and counts swings,
## landed hits, kills and the damage Rivet takes. Measures only: it changes no rule.

var weapon: StringName = &"claw"
var kills: int = 0
var kills_by_weapon: Dictionary[StringName, int] = {}
var damage_taken: float = 0.0
var _hp: float = -1.0
var _wired: bool = false


func step(stage: ArenaStage, _tick: int) -> void:
	if not _wired:
		_wired = true
		@warning_ignore("return_value_discarded")
		stage.arena.kill_landed.connect(_killed)
	var rivet: Fighter = stage.arena.rivet
	if _hp >= 0.0:
		damage_taken += maxf(_hp - rivet.hp, 0.0)
	_hp = rivet.hp
	_hold(stage)


func _killed(
	_victim: Fighter, by: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	kills += 1
	kills_by_weapon[by] = kills_by_weapon.get(by, 0) + 1


## Only the chosen weapon stays in the inventory; the wheel is put back on it after each tick.
func _hold(stage: ArenaStage) -> void:
	var wheel: RivetWheel = stage.pilot.wheel
	var carry: RivetCarry = stage.pilot.carry
	if wheel == null or carry == null:
		return
	var want: StringName = RivetWheel.HANDS
	if weapon != &"claw":
		want = weapon
		if weapon not in carry.first_seen:
			@warning_ignore("return_value_discarded")
			carry.add(weapon)
	for id: StringName in carry.first_seen.duplicate():
		if id != want:
			carry.first_seen.erase(id)
	for i: int in carry.slots.size():
		if carry.slots[i] != want:
			carry.slots[i] = &""
	if wheel.selected() != want:
		wheel._choose(want, stage.arena)


## Swings (hit starts), landed and whiffed hits of every melee instance the pilot used.
func melee_totals(stage: ArenaStage) -> Dictionary:
	var out: Dictionary = {}
	var pilot: StagePilot = stage.pilot
	var all: Array[PlayerMelee] = [pilot.melee]
	all.append_array(pilot._melees.values())
	var seen: Dictionary = {}
	for m: PlayerMelee in all:
		if seen.has(m):
			continue
		seen[m] = true
		out[String(m.weapon_id)] = {"swings": m.starts, "landed": m.landed, "whiffs": m.whiffs}
	return out
