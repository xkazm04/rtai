class_name BladeProbe
extends RefCounted
## n31 melee 01a: reads the melee geometry DRAWN this frame off Rivet's live views (after they
## processed): the held blade from RivetHeldView's sprite and smear root (the same grip and length
## RivetMuzzle.feed_smear hands the smear, so a strip-drawn blade counts too), and the
## RivetSwipeView crescent rebuilt from its own angles, root and radius exactly as its _draw does.
## Points in the views' layer pixels ("px") and in ground metres ("blade"/"crescent": px over
## SimConst.PX_PER_M less ShotLift's gun-height lift). Dev only, read only.

var held: RivetHeldView = null


static func find(root: Node) -> BladeProbe:
	var p: BladeProbe = BladeProbe.new()
	var all: Array[Node] = root.find_children("*", "RivetHeldView", true, false)
	p.held = all[0] as RivetHeldView if not all.is_empty() else null
	return p


func swipe() -> RivetSwipeView:
	for c: Node in held.get_children():
		if c is RivetSwipeView:
			return c as RivetSwipeView
	return null


## True while the smear still fans (a swing's trail or its linger).
func smearing() -> bool:
	return held._smear != null and held._smear.steps() > 0


## Why the blade is or is not read this frame (the views' own gates), for the log.
func why() -> String:
	var rig: CutRig = held.rigs.rig_for(held.rivet_id)
	var sprite: Sprite2D = held._sprite
	var parts: Array[String] = ["sprite=%s" % (sprite != null), "smear=%s" % (held._smear != null)]
	if sprite != null:
		parts.append("visible=%s" % sprite.visible)
	if rig != null:
		parts.append("gun_out=%s hides=%s" % [rig.gun_out, RivetStrips.hides_held(rig)])
		parts.append("owns=%s drawn=%s" % [RivetFrames.owns_weapon(rig), RivetFrames.drawn(rig)])
		parts.append("arc=%s" % RivetSwipe.needs_arc(rig, RivetFrames.oct_of(rig)))
		var eq: String = RivetStrips.strip_of(ViewMode.shared().art, RivetFrames.weapon_of(rig))
		parts.append("wield=%s eq=%s" % [held.pilot.wielding(), eq.get_file()])
		if eq != "":
			parts.append("tip=%s" % RivetMuzzle.point(eq, RivetFrames.Eq.FIRE_SIDE))
	return " ".join(parts)


## This frame's drawn geometry: {"blade", "crescent", "blade_px", "crescent_px", "source"}.
func read() -> Dictionary:
	var out: Dictionary = {}
	var blade_px: PackedVector2Array = _blade_px()
	var source: String = ""
	if not blade_px.is_empty():
		var rig: CutRig = held.rigs.rig_for(held.rivet_id)
		source = "strip" if RivetFrames.owns_weapon(rig) else "blade"
	var cres_px: PackedVector2Array = _crescent_px()
	if not cres_px.is_empty():
		source += "+crescent"
	var rig_now: CutRig = held.rigs.rig_for(held.rivet_id)
	if (
		source == ""
		and rig_now != null
		and held.pilot.wielding()
		and RivetFrames.owns_weapon(rig_now)
	):
		source = "pixels"  # the strip cell draws the blade and no view carries its geometry
	out["source"] = source
	out["blade_px"] = blade_px
	out["crescent_px"] = cres_px
	out["blade"] = _to_m(blade_px)
	out["crescent"] = _to_m(cres_px)
	return out


## Grip and tip as drawn: the smear's grip (fed this frame) along the sprite's rotation, the
## fed length. Empty when no blade is shown (the claw, a hidden held part, the strip's own arc).
func _blade_px() -> PackedVector2Array:
	var sprite: Sprite2D = held._sprite
	var smear: MeleeSmearView = held._smear
	if held.pilot == null or not held.pilot.wielding():
		return PackedVector2Array()
	var rig: CutRig = held.rigs.rig_for(held.rivet_id)
	if rig != null and rig.gun_out and RivetFrames.owns_weapon(rig):
		return _strip_px(rig)
	if rig == null or not rig.gun_out or RivetStrips.hides_held(rig):
		return PackedVector2Array()
	if sprite == null or smear == null or not sprite.visible:
		return PackedVector2Array()
	var grip: Vector2 = smear.to_global(smear._grip)
	var tip: Vector2 = grip + Vector2.from_angle(sprite.global_rotation) * smear._len
	return PackedVector2Array([grip, tip])


## A strip-drawn blade (d9: the cell carries the weapon, no held part): the root and length
## RivetMuzzle.feed_smear takes from the strip's fire-side point, along the guard line
## (RigGrip.blade_angle) swept by the strike (RivetHeldView's MeleeSwing angle). The views' own
## model of where the cell's blade is; blade_volume's overlay frame checks it against the pixels.
func _strip_px(rig: CutRig) -> PackedVector2Array:
	var eq: String = RivetStrips.strip_of(ViewMode.shared().art, RivetFrames.weapon_of(rig))
	var tip: Vector2 = RivetMuzzle.point(eq, RivetFrames.Eq.FIRE_SIDE)
	if tip.x < 0.0:
		return PackedVector2Array()
	var tex: Texture2D = load(eq) as Texture2D
	var card: Sprite2D = rig.head_card
	var res: float = RivetWalk.res_of(card)
	var eq_res: float = RivetRes.of(eq)
	var at: Vector2 = Vector2(0.0, RivetFrames.PAD_PX - tex.get_height() / eq_res + tip.y) * res
	var root: Vector2 = card.to_global(at)
	var half: float = tex.get_width() / float(RivetFrames.EQ_CELLS) * 0.5 / eq_res
	var len_px: float = (tip.x - half) * absf(card.global_scale.x) * res
	var rot: float = RigGrip.blade_angle(rig) + _sweep(rig)
	return PackedVector2Array([root, root + Vector2.from_angle(rot) * len_px])


## RivetHeldView._sweep with its _arc: the strike's angle off the guard line (0 when idle).
func _sweep(rig: CutRig) -> float:
	var c: MeleeCombo = held.pilot.melee.combo
	if rig.clips.strike_t < 0.0:
		return 0.0
	var h: MeleeHit = c.current()
	if h == null and c.last_index > 0 and c.last_index <= c.table.hits.size():
		h = c.table.hits[c.last_index - 1]
	var arc: float = RivetHeldView.SWEEP_MIN
	if h != null:
		arc = maxf(arc, acos(clampf(h.cone_dot, -1.0, 1.0)))
	var side: float = 1.0 if c.last_index % 2 == 1 else -1.0
	return MeleeSwing.angle(rig.clips.strike_t, rig.clips.strike_ph, side, arc)


## RivetSwipeView._draw's band (outer, inner reversed) in layer pixels; empty when not drawn.
func _crescent_px() -> PackedVector2Array:
	var v: RivetSwipeView = swipe()
	if v == null or v._angles.size() < 2:
		return PackedVector2Array()
	var a0: float = v._angles[0]
	var a1: float = v._angles[v._angles.size() - 1]
	if absf(a1 - a0) < RivetSwipeView.MIN_SPAN:
		return PackedVector2Array()
	var outer: PackedVector2Array = PackedVector2Array()
	var inner: PackedVector2Array = PackedVector2Array()
	var steps: int = RivetSwipeView.STEPS
	for s: int in steps + 1:
		var t: float = float(s) / steps
		var dir: Vector2 = Vector2.from_angle(lerpf(a0, a1, t))
		var taper: float = sin(PI * t)
		@warning_ignore("return_value_discarded")
		outer.append(v.to_global(v._root + dir * v._r * (1.0 + 0.04 * taper)))
		@warning_ignore("return_value_discarded")
		inner.append(v.to_global(v._root + dir * v._r * (1.0 - RivetSwipeView.THICK * taper)))
	inner.reverse()
	outer.append_array(inner)
	return outer


func _to_m(px: PackedVector2Array) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	var lift: Vector2 = ShotLift.up_m()
	for p: Vector2 in px:
		@warning_ignore("return_value_discarded")
		out.append(p / SimConst.PX_PER_M - lift)
	return out
