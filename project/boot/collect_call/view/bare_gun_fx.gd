class_name BareGunFx
extends RefCounted
## n7-ranged (it16): Rivet's muzzle flash and inked tracer for a weapon with no weapons.json row.
## Quest 1's picked-up assault rifle fires on combat.json's path (StageGuns nulls `arena.gun`),
## so FxView drew its rounds as the evening path's thin ink dashes with no flash at all. Here they
## draw with the weapon's rivet_arsenal.json `art_stand_in` cells (assault-rifle ->
## machine_pistol: flash_smg and the tracer) at that id's hit_feel.json muzzle_k. A round is aged
## from its own travelled distance (range_m - left_m), so the flash also shows on a film that
## draws every second tick. Render only: reads the arena, writes nothing (quest 1's replay holds).
## Off: `--weapon-fx=shapes` (WeaponFxArt.enabled) or no stand-in row = the dashes (the before).

static var _arsenal: ArsenalTable = null


## Rivet's spec-less round `s` as art (its tracer, and the flash while it is FLASH_TICKS young);
## false leaves it to the caller's dashes.
static func shot(ci: CanvasItem, s: Shot, arena: CombatArena) -> bool:
	var id: StringName = stand_in(s)
	if id == &"" or not arena.tuning.weapons.has(s.weapon):
		return false
	var w: CombatTuning.Weapon = arena.tuning.weapon(s.weapon)
	var dir: Vector2 = s.vel.normalized()
	var flew: float = maxf(w.range_m - s.left_m, 0.0)
	var went: float = flew + arena.rivet.radius_m + 0.1  # Shot.fire starts it past the body edge
	if went >= WeaponFxArt.CLEAR_M:
		var into: float = (went - WeaponFxArt.CLEAR_M) / WeaponFxArt.CONVERGE_M
		var side: float = WeaponFxArt.GUN_SIDE_M * clampf(1.0 - into, 0.0, 1.0)
		var fx: StringName = WeaponFxArt.art().projectile_fx(id)
		var k: float = WeaponFxArt.art().round_k.get(id, 1.0)
		var at: Vector2 = s.pos + dir.orthogonal() * side
		var cell: StringName = fx if fx != &"" else &"tracer"
		WeaponFxArt.draw_cell(ci, cell, 0, at, dir.angle(), Vector2(sqrt(k), k))
	var ticks: int = roundi(flew / maxf(w.speed_mps * SimClock.TICK_DT, 0.001))
	if ticks <= WeaponFxArt.FLASH_TICKS:
		_flash(ci, id, arena.rivet, dir, maxi(ticks - 1, 0))
	return true


## The stand-in art id drawing Rivet's round `s`, or &"" (an enemy round, a table gun's round,
## a weapon with no stand-in, or the art off).
static func stand_in(s: Shot) -> StringName:
	if not WeaponFxArt.enabled or not s.from_rivet or s.spec != null:
		return &""
	if _arsenal == null:
		_arsenal = ArsenalTable.shipped()
	var id: StringName = _arsenal.art_stand_in.get(s.weapon, &"")
	return id if id != &"" and WeaponFxArt.art().has(id) else &""


## The stand-in's flash cell, frame `age`, on the held gun's bore tip (or the claw-side spot).
static func _flash(ci: CanvasItem, id: StringName, r: Fighter, aim: Vector2, age: int) -> void:
	var fx: StringName = WeaponFxArt.art().muzzle_fx(id)
	if fx == &"":
		return
	var reach: float = r.radius_m + WeaponFxArt.FLASH_AHEAD_M
	reach += WeaponFxArt.art().muzzle_m(id).x * 0.5
	var spot: Vector2 = r.pos + aim * reach + aim.orthogonal() * WeaponFxArt.GUN_SIDE_M
	var at: Vector2 = HeldMuzzle.at_m(ci, spot)
	var k: float = WeaponFxIgnite.muzzle_k(id)
	WeaponFxArt.draw_cell(ci, fx, age, at, aim.angle(), Vector2.ONE * k)
