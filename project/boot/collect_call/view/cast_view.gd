class_name CastView
extends Node2D
## Quest 1's people as flat placeholder ink, each with its initial on its body: Rivet (cream,
## teal eye slits, vermilion collar), the Toner Room robots (Juno, Brass, Dr. Kilohm, Don Fax)
## once the quest brings them on, the vermilion humans (patrol cops while Rivet is hot, the
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
			_human(p, "C", Vector2.DOWN)
	for h: Fighter in stage.arena.hostiles:
		if h.kind == Fighter.Kind.BOSS:
			_mertz(h)
		elif h.alive():
			_human(h.pos, "G", h.facing)
		else:
			Ink.disc(self, h.pos, 0.3, Color(Ink.INK, 0.35))
	_rivet(stage.arena.rivet)


func _rivet(r: Fighter) -> void:
	var at: Vector2 = r.pos
	if stage.hidden_in != "":
		Ink.box(self, at + Vector2(0.0, -0.75), Vector2(0.9, 0.6), Ink.CREAM)
		_eyes(at + Vector2(0.0, -0.85))
		Ink.initial(self, at + Vector2(0.0, -0.58), "R", Ink.INK, 0.28)
		return
	var hand: Vector2 = at + Vector2(0.45, 0.0)
	var arm: Vector2 = r.facing.normalized() * 0.9
	draw_line(Ink.px(hand), Ink.px(hand + arm), Ink.INK, 5.0)
	draw_circle(Ink.px(hand + arm), 4.0, Ink.TEAL)
	Ink.box(self, at + Vector2(0.0, 0.15), Vector2(1.0, 1.1), Ink.CREAM)
	Ink.box(self, at + Vector2(0.0, -0.55), Vector2(0.9, 0.6), Ink.CREAM)
	var collar_a: Vector2 = Ink.px(at + Vector2(-0.5, -0.2))
	draw_line(collar_a, Ink.px(at + Vector2(0.5, -0.2)), Ink.VERMILION, 6.0)
	_eyes(at + Vector2(0.0, -0.6))
	Ink.initial(self, at + Vector2(0.0, 0.2), "R", Ink.INK, 0.5)
	_hp_bar(at + Vector2(0.0, -1.2), r.hp / r.max_hp)


func _eyes(at: Vector2) -> void:
	var c: Vector2 = Ink.px(at)
	draw_rect(Rect2(c + Vector2(-14, -4), Vector2(28, 8)), Ink.INK, true)
	draw_rect(Rect2(c + Vector2(-11, -2), Vector2(8, 4)), Ink.TEAL, true)
	draw_rect(Rect2(c + Vector2(3, -2), Vector2(8, 4)), Ink.TEAL, true)


func _ally(tag: String, at: Vector2) -> void:
	var size: Vector2 = ALLY_SIZE.get(tag, Vector2.ONE)
	var dark: bool = tag == "Brass"
	Ink.box(self, at, size, Ink.INK if dark else Ink.CREAM)
	_eyes(at + Vector2(0.0, -size.y * 0.3))
	var letter: String = ALLY_LETTER.get(tag, "?")
	Ink.initial(
		self, at + Vector2(0.0, size.y * 0.15), letter, Ink.CREAM if dark else Ink.INK, 0.45
	)
	if tag == "Don Fax":
		draw_circle(Ink.px(at + Vector2(0.6, 0.3)), 5.0, Ink.VERMILION)
	Ink.label(self, at + Vector2(0.0, size.y * 0.5 + 0.45), tag, 18, Ink.INK)


func _human(at: Vector2, letter: String, facing: Vector2) -> void:
	draw_line(Ink.px(at), Ink.px(at + facing.normalized() * 0.9), Ink.INK, 5.0)
	Ink.disc(self, at, 0.45, Ink.VERMILION, letter)
	draw_arc(Ink.px(at), 0.32 * Ink.PX_PER_M, 0.3, 2.8, 12, Ink.CREAM, 3.0, true)


func _mertz(m: Fighter) -> void:
	var at: Vector2 = m.pos
	if not m.alive():
		Ink.box(self, at + Vector2(0.0, 0.3), Vector2(1.9, 0.9), Color(Ink.INK, 0.6))
		Ink.label(self, at + Vector2(0.0, 1.3), "shorted out", 16, Ink.INK)
		return
	Ink.box(self, at + Vector2(0.0, -0.95), Vector2(1.2, 0.7), Ink.INK)
	Ink.box(self, at, Vector2(1.9, 1.5), Ink.INK)
	Ink.box(self, at + Vector2(0.0, -0.95), Vector2(1.0, 0.25), Ink.CREAM)
	for i: int in 3:
		var bar: Vector2 = Ink.px(at + Vector2(-0.75 + i * 0.25, -0.5))
		draw_rect(Rect2(bar, Vector2(9, 5)), Ink.CREAM, true)
	Ink.initial(self, at + Vector2(0.15, 0.15), "M", Ink.CREAM, 0.6)
	var dir: Vector2 = m.facing.normalized()
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


func _hp_bar(at: Vector2, frac: float) -> void:
	var r: Rect2 = Rect2(Ink.px(at) - Vector2(30, 4), Vector2(60, 8))
	draw_rect(r, Ink.CREAM, true)
	draw_rect(Rect2(r.position, Vector2(60.0 * clampf(frac, 0.0, 1.0), 8)), Ink.TEAL, true)
	draw_rect(r, Ink.INK, false, 2.0)
