class_name KillCutEdge
extends Node2D
## The raw edge of a blade-split half (lane brutality, KillSplitFx): an ink lip along the cut
## and a red band just inside it on the half's own `side`. Drawn once (it moves with its half).

const INK: Color = KillSplitFx.INK
const RAW: Color = KillSplitFx.RAW
const SOUL_WHITE: Color = Color(0.9, 1.0, 0.97)
## n16 kills-polish (assets A2 it414, the gore level's drawn insides): the cut face seen edge-on,
## an ink lip over meat with cream rib ovals and a spine disc (clean: katana; saw: chainsaw, ragged
## with bone chips; hot: plasma sword, charred, no red). Drawn on the half's side of the cut, its
## lip on the line, FACE_K of the edge's length deep. `--cut-face=line` = the before (drawn lines).
const FACES: Dictionary[StringName, Texture2D] = {
	&"clean": preload("res://features/combat/weapons/art/gore/cut_face_clean.png"),
	&"saw": preload("res://features/combat/weapons/art/gore/cut_face_saw.png"),
	&"hot": preload("res://features/combat/weapons/art/gore/cut_face_hot.png"),
}
const FACE_K: float = 0.2

static var _lines: int = -1

var a: Vector2 = Vector2.ZERO
var b: Vector2 = Vector2.ZERO
## Unit normal pointing into the half.
var side: Vector2 = Vector2.UP
## Cauterised (the plasma sword): a hot cream band in a heat bloom, no red.
var hot: bool = false
## The drawn cut face (FACES), or null: the drawn lines.
var face: Texture2D = null
## With hot: Kerf's soul beam: a teal bloom round a white-hot band (teal is the souls' colour).
var soul: bool = false


## The edge of the half on `p_side` of the cut through `mid` along `dir` (px), half `half_px` long,
## styled by `row`: no spray = cauterised, edge `soul` = Kerf's.
static func along(
	mid: Vector2, dir: Vector2, half_px: float, p_side: Vector2, row: SignatureKill
) -> KillCutEdge:
	var e: KillCutEdge = KillCutEdge.new()
	e.a = mid - dir * half_px
	e.b = mid + dir * half_px
	e.side = p_side
	e.hot = row.spray == 0
	e.soul = row.edge == &"soul"
	e.z_index = 30
	e.face = face_of(row)
	return e


## The row's drawn cut face: hot (no spray), saw (a grind), clean; none for Kerf's soul edge or
## under `--cut-face=line`.
static func face_of(row: SignatureKill) -> Texture2D:
	if _lines < 0:
		_lines = 1 if ArenaArgs.parse().text("--cut-face") == "line" else 0
	if _lines == 1 or row.edge == &"soul":
		return null
	if row.spray == 0:
		return FACES[&"hot"]
	return FACES[&"saw"] if row.grind_ticks > 0 else FACES[&"clean"]


func _draw() -> void:
	var w: float = (b - a).length() * 0.13
	var inset: Vector2 = side * w * 0.6
	if face != null:
		if hot:  # the heat bloom under the charred face
			draw_line(a + inset * 1.5, b + inset * 1.5, Color(KillHoleFx.HOT, 0.45), w * 2.6, true)
		_face()
		return
	draw_line(a, b, INK, w * 0.55, true)
	if hot:
		var band: Color = SOUL_WHITE if soul else KillHoleFx.HOT
		var bloom: Color = Color(HaulerLook.TEAL if soul else KillHoleFx.HOT, 0.45)
		draw_line(a + inset * 1.5, b + inset * 1.5, bloom, w * 2.6, true)
		draw_line(a.lerp(b, 0.05) + inset, b.lerp(a, 0.05) + inset, band, w, true)
		return
	draw_line(a.lerp(b, 0.08) + inset, b.lerp(a, 0.08) + inset, RAW, w, true)
	for i: int in 3:  # the meat shows in three ragged red dabs along the band
		var at: Vector2 = a.lerp(b, 0.25 + 0.25 * i) + inset * 1.4
		draw_circle(at, w * 0.55, RAW)


## The face strip along a..b, its top (the ink lip) on the cut, reaching into the half (`side`).
func _face() -> void:
	var d: Vector2 = b - a
	var turn: float = d.angle()
	var flip: float = 1.0 if Vector2.DOWN.rotated(turn).dot(side) > 0.0 else -1.0
	draw_set_transform(a, turn, Vector2(1.0, flip))
	var deep: float = d.length() * FACE_K
	draw_texture_rect(face, Rect2(0.0, -deep * 0.1, d.length(), deep), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
