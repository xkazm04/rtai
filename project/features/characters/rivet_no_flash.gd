class_name RivetNoFlash
extends RefCounted
## n17 rivet-strike (DEFECTS #9): a gun's drawn fire cell carries a painted flash and is held for
## the recoil pose (RivetFrames.FIRE_TICKS and the kick), so one pistol round showed 8 ticks of
## flash (weapon:pistol at 64 px/m, t333-340) where the game's own flare holds its muzzle_ticks
## (gun_fx.json, 3). Past the flare's ticks the fire cell now draws from the strip's flashless twin
## (rivet_eq_<gun>_noflash.png, tools/art/rivet_fire_noflash.py: the same canvas, cells 5 and 6
## with the flash erased by the asset lane, it454): the pose holds, the flash lasts as long as the
## flare. Only the texture swaps (the strip's path stays on the card), so the muzzle, feet and res
## tables keyed by that path still apply. `--rivet-noflash=off` (CastFlags) = before. Render only.

const AGE: StringName = &"rivet_fire_age"
const SUFFIX: String = "_noflash.png"
const FX: String = "res://features/combat/weapons/gun_fx.json"
## A gun whose gun_fx row draws no flare (default muzzle_ticks 0: the rocket's back-blast, the
## electro gun's arcs are drawn only in the cell) keeps its painted flash this many ticks.
const MIN_TICKS: int = 2
const NONE: int = 1 << 30

static var enabled: bool = true
static var _ticks: Dictionary[StringName, int] = {}


## RivetFrames.publish: ticks since the held gun's last round left (0 = this tick), NONE while
## no round is up (its trigger cooled); RivetFrames' fire latch is this age under FIRE_TICKS.
static func publish(rig: CutRig, t: Trigger) -> int:
	var up: bool = t != null and t.cooldown > 0
	rig.set_meta(AGE, t.spec.interval_ticks - t.cooldown if up else -1)
	return t.spec.interval_ticks - t.cooldown if up else NONE


## Shows `cell` seated on its boots (RivetCellFeet.show); a fire cell past its flash draws from
## the flashless twin, every other frame (and the flash's own ticks) from the strip itself.
static func show(rig: CutRig, card: Sprite2D, cell: int) -> void:
	RivetCellFeet.show(card, cell)
	var on: String = str(card.get_meta(RivetFrames.ON, ""))
	if on.is_empty() or card.texture == null:
		return
	var want: Texture2D = StreetStrips.get_tex(on)
	var fire: bool = cell == RivetFrames.Eq.FIRE_SIDE or cell == RivetFrames.Eq.FIRE_CAM
	if enabled and fire and card.hframes == RivetFrames.EQ_CELLS and _past(rig):
		var twin: String = on.trim_suffix(".png") + SUFFIX
		if RivetStrips.has_file(twin):
			want = StreetStrips.get_tex(twin)
	if card.texture != want:
		card.texture = want


## True when the fire cell shows with no round inside the weapon's flare ticks.
static func _past(rig: CutRig) -> bool:
	var age: int = rig.get_meta(AGE, -1)
	return age < 0 or age >= ticks_of(RivetFrames.weapon_of(rig))


## The painted flash's ticks for `weapon`: gun_fx.json muzzle_ticks, at least MIN_TICKS.
static func ticks_of(weapon: StringName) -> int:
	if _ticks.is_empty():
		var p: Dictionary = NoirLook.read_params(FX)
		var rows: Dictionary = p.get("weapons", {})
		for id: String in rows:
			var row: Dictionary = rows[id]
			var n: float = row.get("muzzle_ticks", 0.0)
			_ticks[StringName(id)] = int(n)
		_ticks[&""] = 0
	var own: int = _ticks.get(weapon, 0)
	return maxi(own, MIN_TICKS)
