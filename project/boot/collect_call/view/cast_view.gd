class_name CastView
extends Node2D
## Quest 1's people as flat placeholder ink, each with its initial on its body: Rivet (cream,
## teal eye slits, vermilion collar), the Toner Room robots (Juno, Brass, Dr. Kilohm, Don Fax)
## once the quest brings them on, the humans (patrol cops in cop blue while Rivet is hot, the
## dock contractors), and Quartermaster Mertz in his own silhouette: wide black uniform, a
## flat garrison cap, the battery backpack and its cable to the Robo-tazer.

const ALLY_LETTER: Dictionary[String, String] = {
	"Juno": "J", "Brass": "B", "Dr. Kilohm": "K", "Don Fax": "D"
}
const ALLY_SIZE: Dictionary[String, Vector2] = {
	"Juno": Vector2(0.8, 1.2),
	"Brass": Vector2(1.6, 1.2),
	"Dr. Kilohm": Vector2(0.8, 1.6),
	"Don Fax": Vector2(1.8, 1.1),
}

## The art is fitted to the gameplay footprints; drawn at these factors the silhouettes carry the
## visual mass of the placeholder boxes (a thin IV-pole robot at 0.8 m read as a speck).
const CAST_DRAW: float = 1.5
const GUARD_DRAW: float = 1.7
## Knocked-out bodies stay quiet (the placeholder drew them as faint discs).
const DOWN_FADE: Color = Color(1.0, 1.0, 1.0, 0.8)
## n5-cast: Rivet and his peek switch to the gameplay-scale sticker captures below ~42 px/m
## (`_lod_art`); false = the art captures at every zoom (the cream sprite Rivet before 2026-11-05).
const LOD_SPRITES: bool = true
## Art by id from data/tables/collect_call_art.json (QuestArt). The rig captures (rivet: idle,
## facing -y, 120 px/m, arms included; rivet_peek: its round cut for the hide spots; cop: gun
## out) carry their drawn size there (size_m x draw_k; Rivet is d5-cast's base form, the T2
## hunch, at true scale), so a re-capture is a table edit.
const ALLY_ART: Dictionary[String, String] = {
	"Juno": "juno", "Brass": "brass", "Dr. Kilohm": "kilohm", "Don Fax": "don_fax"
}

var stage: CollectCallStage
var port: CollectCallWorld
## Lane gunplay: the shared hit feel's flash, drawn as an inked impact star behind the struck
## figure (null in quest 1 until a gun is wired).
var hit_link: HitLink = null
## rivet-arsenal (dev --rigs in quest 1): the cast rigs draw Rivet and the fighters, so this view
## keeps only the allies, the patrol, the boss (no boss rig yet) and the Hauler's marks.
var fighters_on_rigs: bool = false


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if stage == null:
		return
	for tag: String in port.allies:
		_ally(tag, stage.layout.places.actors[tag].at)
	if stage.heat.level > 0:
		for p: Vector2 in stage.patrol_pos:
			_sprite("cop", p, _size(&"cop"), Vector2.DOWN)
	if fighters_on_rigs:
		for h: Fighter in stage.arena.hostiles:
			if h.kind == Fighter.Kind.BOSS:
				_mertz(h)
		if stage.hidden_in == "":
			_hauler_marks()
		return
	for h: Fighter in stage.arena.hostiles:
		_impact(h)
		if h.kind == Fighter.Kind.BOSS:
			_mertz(h)
		elif h.alive():
			var lean: Vector2 = hit_link.lean(h) if hit_link != null else Vector2.ZERO
			_sprite("dock_guard", h.pos + lean, Vector2(0.9, 0.9) * GUARD_DRAW, h.facing)
		else:
			_sprite("guard_down", h.pos, Vector2(1.6, 1.6), h.facing, DOWN_FADE)
	_rivet(stage.arena.rivet)


func _rivet(r: Fighter) -> void:
	var at: Vector2 = r.pos
	if stage.hidden_in != "":
		var peek: String = _lod_art("rivet_peek")
		_sprite(peek, at + Vector2(0.0, -0.75), _size(StringName(peek)), Vector2.UP)
		return
	_impact(r, Ink.VERMILION)  # Rivet struck is danger: the star's rim goes vermilion
	_hauler_marks()
	var h: HaulerForm = stage.pilot.hauler.form if stage.pilot != null else null
	var k: float = h.morph_k() if h != null else 0.0
	var art: String = _lod_art("rivet")
	if k > 0.0:  # features/souls: the Hauler grows and tints Rivet by the morph
		var grow: float = HaulerLook.sprite_k(k, h.windup_k())
		var tint: Color = HaulerLook.tint(h.num(&"look_tint_k"), k)
		_sprite(art, at, _size(StringName(art)) * grow, r.facing, tint)
	else:
		_sprite(art, at, _size(StringName(art)), r.facing)
	_hp_bar(at + Vector2(0.0, -1.2), r.hp / r.max_hp)


## n5-cast: below the rigs' flat-sticker threshold (PartMaterials.flat_below, about 42 px/m) the
## rig Rivet prints his gameplay stickers (tan core, visor slot, hazard collar), so the sprite
## Rivet and his peek draw from the capture of that tier (`<id>_lod`), the art capture above it.
func _lod_art(id: String) -> String:
	var ppm: float = get_global_transform_with_canvas().get_scale().x * Ink.PX_PER_M
	var px: float = CutRig.SC * ppm / SimConst.PX_PER_M
	return id + "_lod" if LOD_SPRITES and px < PartMaterials.flat_below else id


func _ally(tag: String, at: Vector2) -> void:
	var size: Vector2 = ALLY_SIZE.get(tag, Vector2.ONE)
	var art: String = ALLY_ART.get(tag, "juno")
	_sprite(art, at, size * CAST_DRAW, Vector2.UP)
	Ink.label(self, at + Vector2(0.0, size.y * 0.5 + 0.45), tag, 18, Ink.INK)


func _mertz(m: Fighter) -> void:
	var at: Vector2 = m.pos
	if not m.alive():
		_sprite("mertz_down", at, Vector2(2.6, 2.4) * CAST_DRAW, Vector2.UP, DOWN_FADE)
		return
	var dir: Vector2 = m.facing.normalized()
	_sprite("mertz", at, Vector2(1.9, 2.0) * CAST_DRAW, dir)
	var gun_root: Vector2 = at + dir * 0.9
	var muzzle: Vector2 = at + dir * 2.1
	draw_line(Ink.px(gun_root), Ink.px(muzzle), Ink.INK, 12.0)
	draw_line(Ink.px(gun_root), Ink.px(muzzle), Ink.VERMILION, 4.0)
	Ink.zigzag(self, at + Vector2(-0.9, 0.3), gun_root, 6, 3, Ink.INK)
	_tazer_charge(m, muzzle, dir)
	if m.exposed:
		Ink.label(self, at + Vector2(0.0, 1.35), "VENTING", 18, Ink.VERMILION)


## The capacitor tubes fill cream back to front; the prongs spark vermilion while it whines.
func _tazer_charge(m: Fighter, muzzle: Vector2, dir: Vector2) -> void:
	var tazer: RoboTazer = stage.arena.tazer
	var frac: float = tazer.charge_frac()
	for i: int in 5:
		var c: Vector2 = m.pos + dir * (1.0 + i * 0.22) + dir.orthogonal() * 0.3
		var lit: bool = frac * 5.0 > float(i)
		draw_circle(Ink.px(c), 5.0, Ink.CREAM if lit else Ink.INK)
		draw_arc(Ink.px(c), 5.0, 0.0, TAU, 10, Ink.CREAM, 1.5, true)
	if tazer.state == RoboTazer.State.CHARGING:
		for k: int in 3:
			var tip: Vector2 = muzzle + dir.rotated(-0.8 + k * 0.8) * (0.5 + frac * 0.6)
			Ink.zigzag(self, muzzle, tip, 4, tazer.ticks + k, Ink.VERMILION)


## The hit flash: a cream star with an ink rim behind the victim, big on the hit, shrinking out.
func _impact(f: Fighter, rim: Color = Ink.INK) -> void:
	var k: float = hit_link.flash(f) if hit_link != null else 0.0
	if k <= 0.0:
		return
	var pts: PackedVector2Array = PackedVector2Array()
	@warning_ignore("return_value_discarded")
	pts.resize(17)
	var spin: float = float(f.id) * 0.7
	for i: int in 16:
		var r: float = (1.15 if i % 2 == 0 else 0.55) * (0.6 + 0.6 * k)
		pts[i] = Ink.px(f.pos + Vector2.from_angle(spin + TAU * i / 16.0) * r)
	pts[16] = pts[0]
	draw_colored_polygon(pts.slice(0, 16), Ink.CREAM)
	draw_polyline(pts, rim, 3.0, true)


## The Hauler stomp's ring and D5 crack where it landed (features/souls HaulerMarks).
func _hauler_marks() -> void:
	var h: HaulerStage = stage.pilot.hauler if stage.pilot != null else null
	if h == null or h.stomp_tick < 0:
		return
	var age: float = (stage.tick - h.stomp_tick) * SimClock.TICK_DT
	var radius: float = h.form.num(&"stomp_radius_m")
	HaulerMarks.draw(self, Ink.px(h.stomp_at), age, radius, Ink.PX_PER_M, h.stomp_tick)


## Ink on cream: teal belongs to the dead (D4 doctrine), not to a health bar.
func _hp_bar(at: Vector2, frac: float) -> void:
	var r: Rect2 = Rect2(Ink.px(at) - Vector2(30, 4), Vector2(60, 8))
	draw_rect(r, Ink.CREAM, true)
	draw_rect(Rect2(r.position, Vector2(60.0 * clampf(frac, 0.0, 1.0), 8)), Ink.INK, true)
	draw_rect(r, Ink.INK, false, 2.0)


## A cast sprite (drawn facing -y) centred on `at`, turned to `facing`.
func _sprite(
	name: String, at: Vector2, size: Vector2, facing: Vector2, tint: Color = Color.WHITE
) -> void:
	var tex: Texture2D = QuestArt.shared().texture(StringName(name))
	draw_set_transform(Ink.px(at), facing.angle() + PI * 0.5)
	var r: Rect2 = Rect2(-size * 0.5 * Ink.PX_PER_M, size * Ink.PX_PER_M)
	draw_texture_rect(tex, r, false, tint)
	draw_set_transform(Vector2.ZERO)


func _size(id: StringName) -> Vector2:
	return QuestArt.shared().size_m(id)
