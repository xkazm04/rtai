class_name HeldPitchArt
extends RefCounted
## d8-weapons: the held weapon drawn for a raised camera (data/tables/weapon_held_pitch.json).
## Per camera pitch (the view row's pitch_deg, rounded; "55" today, "70" can sit beside it) and
## weapon id: a three-quarter part that shows the gun's top AND its side body (trigger, grip),
## origin on the grip, +x along the barrel, like WeaponArt's top-down part. A weapon with no row
## for the pitch (and every weapon under `top`, 90) keeps WeaponArt's part: `top` is untouched.
## The side view must never hang upside down, so while the barrel points left on screen the part
## is mirrored about its barrel line (`face`), the classic held-sprite flip. `--held-pitch=off`
## draws the top-down part under any view (the before). Render only: writes nothing to the sim.

const TABLE: String = "res://data/tables/weapon_held_pitch.json"
const SCHEMA: String = "gtai.weapon-held-pitch/1"

static var _shipped: HeldPitchArt = null


class Row:
	extends RefCounted
	var art: String = ""
	var grip: Vector2 = Vector2.ZERO
	var muzzle: Vector2 = Vector2.ZERO
	var length_px: float = 1.0
	## Draw size against weapon_art length_m (the side body adds the grip's height, so a
	## three-quarter pistol at full length reads bigger than the top-down one).
	var size_k: float = 1.0


## pitch key ("55") -> weapon id -> Row
var pitches: Dictionary[String, Dictionary] = {}
var errors: Array[String] = []


static func shipped() -> HeldPitchArt:
	if _shipped == null:
		_shipped = from_table(DataTable.open(TABLE, SCHEMA))
	return _shipped


static func from_table(t: DataTable) -> HeldPitchArt:
	var h: HeldPitchArt = HeldPitchArt.new()
	var rows: Dictionary = t.object(t.raw, "pitches")
	for key: String in rows:
		var by_id: Dictionary = {}
		var weapons: Dictionary = t.object(t.object(rows, key), "weapons")
		for id: String in weapons:
			var w: Dictionary = t.object(weapons, id)
			var r: Row = Row.new()
			r.art = t.text(w, "art")
			r.grip = t.vec(w, "grip_px")
			r.muzzle = t.vec(w, "muzzle_px")
			r.length_px = maxf(t.num(w, "length_px"), 1.0)
			r.size_k = t.num(w, "size_k") if w.has("size_k") else 1.0
			by_id[StringName(id)] = r
		h.pitches[key] = by_id
	h.errors = t.errors()
	return h


## The key of a camera pitch: whole degrees ("55"); "" for a straight-down view.
static func key_of(pitch_deg: float) -> String:
	return "" if pitch_deg >= 89.5 else str(roundi(pitch_deg))


## The row for `id` at `pitch_deg` (null: none, the top-down part draws).
func row(id: StringName, pitch_deg: float) -> Row:
	var by_id: Dictionary = pitches.get(key_of(pitch_deg), {})
	return by_id.get(id, null) if LaunchArgs.value("--held-pitch") != "off" else null


## A held sprite for `id` at `pitch_deg` (origin on the grip, world px scale from WeaponArt's
## length_m, an ink-paper rim like WeaponArt's), or null when the pitch has no art for it.
func make(id: StringName, pitch_deg: float, art: WeaponArt) -> Sprite2D:
	var r: Row = row(id, pitch_deg)
	if r == null or not ResourceLoader.exists(r.art):
		return null
	var s: Sprite2D = Sprite2D.new()
	s.name = "Held55_%s" % id
	s.texture = load(r.art) as Texture2D
	s.centered = false
	s.offset = -r.grip
	s.scale = Vector2.ONE * art.length_m(id) * WeaponArt.WORLD_PX_PER_M / r.length_px * r.size_k
	s.set_meta(&"pitch_row", r)
	return s


## The held sprite for `id` under the launch view: the pitch part, else WeaponArt's top-down one.
func held(id: StringName, art: WeaponArt) -> Sprite2D:
	var s: Sprite2D = make(id, ViewMode.shared().pitch_deg, art)
	return s if s != null else art.make_held(id)


## Faces the part (`face`) and publishes its bore tip as this frame's muzzle (HeldMuzzle).
static func publish_muzzle(s: Sprite2D, top_down_muzzle: Vector2) -> void:
	face(s)
	HeldMuzzle.publish(s, muzzle_local(s, top_down_muzzle))


## Mirrors a pitch part about its barrel line while the barrel points left on screen, so the
## grip always hangs down. A top-down part (no pitch row) is left alone.
static func face(s: Sprite2D) -> void:
	var r: Row = row_of(s)
	if r == null:
		return
	var left: bool = cos(s.global_rotation) < 0.0
	s.flip_v = left
	var h: float = s.texture.get_size().y
	s.offset = Vector2(-r.grip.x, -(h - r.grip.y) if left else -r.grip.y)


## The bore tip in the sprite's local px (offset and flip included).
static func muzzle_local(s: Sprite2D, top_down_muzzle: Vector2) -> Vector2:
	var r: Row = row_of(s)
	if r == null:
		return top_down_muzzle + s.offset
	var y: float = s.texture.get_size().y - r.muzzle.y if s.flip_v else r.muzzle.y
	return Vector2(r.muzzle.x, y) + s.offset


## The pitch row a held sprite was made from (null: a top-down part).
static func row_of(s: Sprite2D) -> Row:
	if s == null or not s.has_meta(&"pitch_row"):
		return null
	var m: Variant = s.get_meta(&"pitch_row")
	return m if m is Row else null
