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
## Art by id from data/tables/collect_call_art.json (QuestArt). The rig captures (rivet: idle,
## facing -y, 120 px/m, arms included; rivet_peek: its round cut for the hide spots; cop: gun
## out) carry their drawn size there (size_m x draw_k: Rivet at the base form, 1.1 / 1.3 of the
## night capture until d5-cast re-captures him), so a re-capture is a table edit.
const ALLY_ART: Dictionary[String, String] = {
	"Juno": "juno", "Brass": "brass", "Dr. Kilohm": "kilohm", "Don Fax": "don_fax"
}

var stage: CollectCallStage
var port: CollectCallWorld


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
	for h: Fighter in stage.arena.hostiles:
		if h.kind == Fighter.Kind.BOSS:
			_mertz(h)
		elif h.alive():
			_sprite("dock_guard", h.pos, Vector2(0.9, 0.9) * GUARD_DRAW, h.facing)
		else:
			_sprite("guard_down", h.pos, Vector2(1.6, 1.6), h.facing, DOWN_FADE)
	_rivet(stage.arena.rivet)


func _rivet(r: Fighter) -> void:
	var at: Vector2 = r.pos
	if stage.hidden_in != "":
		_sprite("rivet_peek", at + Vector2(0.0, -0.75), _size(&"rivet_peek"), Vector2.UP)
		return
	_sprite("rivet", at, _size(&"rivet"), r.facing)
	_hp_bar(at + Vector2(0.0, -1.2), r.hp / r.max_hp)


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
