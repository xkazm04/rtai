class_name PlayerMelee
extends RefCounted
## Rivet's bare-claw combo in the live game (quest 1, the arena, the city block): MeleeCombo over
## rivet_melee.json against the CombatArena's hostiles. A press starts or buffers a hit; on a
## hit's first active tick every exposed hostile inside its reach and cone takes its damage and a
## shove along the hit line (knockback_m, eased out over SHOVE_TICKS so it reads as a slide; the
## stage pushes the body back out of buildings). The lunge and the move scale go to the pilot.
## Hosts (views) read `starts`, `hit_index` and `last_land_tick` to pose the rig and the hit-stop.

const WEAPON: StringName = &"claw"
const SHOVE_TICKS: int = 8
## A body's radius is added to a hit's reach (the claw reaches the edge, not the centre).
const EDGE_SLACK_M: float = 0.0

var combo: MeleeCombo
## The weapon id the hits are dealt with (CombatArena.damage; brutality keys kills on it).
var weapon_id: StringName = WEAPON
## Hit starts (a view compares it with the count it last saw to start the strike clip).
var starts: int = 0
var landed: int = 0
var whiffs: int = 0
var last_land_tick: int = -1000000
var last_land_index: int = 0
## Shoves in flight: fighter id -> the metres still to slide (a vector).
var _shoves: Dictionary[int, Vector2] = {}


func _init(table: MeleeTable = MeleeTable.shipped()) -> void:
	combo = MeleeCombo.new(table)
	weapon_id = table.id


## One tick: `press` is this tick's melee press; `facing` is Rivet's heading. Returns the lunge
## displacement (m) for this tick.
func step(arena: CombatArena, press: bool, facing: Vector2) -> Vector2:
	if press:
		combo.press()
	combo.step()
	if combo.starts != starts:
		starts = combo.starts
	_slide(arena)
	if combo.lands():
		_land(arena, combo.current(), facing)
	return facing * combo.lunge_step_m()


## Scale for the walk's top speed while a hit plays.
func move_scale() -> float:
	return combo.move_scale()


func busy() -> bool:
	return combo.hit_index != 0


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(combo.hit_index)
	out.put_32(combo.tick_in)
	out.put_8(1 if combo.buffered else 0)
	out.put_32(mini(combo.since_end, 1 << 20))
	out.put_32(combo.last_index)
	out.put_32(landed)
	var ids: Array = _shoves.keys()
	ids.sort()
	out.put_32(ids.size())
	for id: int in ids:
		out.put_float(_shoves[id].x)
		out.put_float(_shoves[id].y)


func _land(arena: CombatArena, h: MeleeHit, facing: Vector2) -> void:
	var at: Vector2 = arena.rivet.pos
	var hit_any: bool = false
	for f: Fighter in arena.hostiles:
		var to: Vector2 = f.pos - at
		if not f.alive() or to.length() > h.reach_m + f.radius_m + EDGE_SLACK_M:
			continue
		var dir: Vector2 = to.normalized() if to.length() > 0.001 else facing
		if dir.dot(facing) < h.cone_dot:
			continue
		arena.damage(f, h.damage, arena.rivet.id, weapon_id)
		if h.stun_ticks > 0 and f.alive():  # the electro baton's lock
			PlayerShock.stun_on(PlayerShock.areas_of(arena), f, h.stun_ticks)
		_shoves[f.id] = dir * h.knockback_m
		hit_any = true
	if hit_any:
		landed += 1
		last_land_tick = arena.tick
		last_land_index = combo.hit_index
	else:
		whiffs += 1


## Eases every shove out: each tick slides a share of what is left (by id order: deterministic).
func _slide(arena: CombatArena) -> void:
	if _shoves.is_empty():
		return
	var k: float = 1.0 / float(SHOVE_TICKS) * 2.0
	for f: Fighter in arena.hostiles:
		if not _shoves.has(f.id):
			continue
		var left: Vector2 = _shoves[f.id]
		var d: Vector2 = left * minf(k, 1.0)
		f.pos += d
		left -= d
		if left.length() < 0.01:
			@warning_ignore("return_value_discarded")
			_shoves.erase(f.id)
		else:
			_shoves[f.id] = left
