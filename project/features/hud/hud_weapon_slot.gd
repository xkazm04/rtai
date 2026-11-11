class_name HudWeaponSlot
extends RefCounted
## n17 rivet-strike (owner 2026-11-11 19:20, "Active weapon could have HUD in right bottom corner
## to see showcase asset and named"): the weapon in hand in the bottom-right corner, on the memo
## paper: its showcase drawing (HudState.weapon_icon: the flat ICON cut, the form drawn for a
## screen; the p70/p55 forms are drawn for a tilted camera), its name under it (the feed's
## WEAPON__<id> text) and the magazine count beside the name when the weapon has one.
## The slot sits in the corner, and just above the subtitle paper while a line is up: a cut,
## never a slide; a weapon change is a cut as well (the next frame draws the new weapon).
## Sizes are HUD px on the 1280x800 base canvas (the Deck's panel 1:1; a desktop window scales it
## through the canvas_items stretch). `--hud-weapon=off` = before (the weapon on the top-right
## ammo ticket, no slot). Render only.

const W: float = 248.0
const ICON_H: float = 92.0
const PAD: float = 14.0
const NAME_H: float = 34.0
## The name's sizes, largest first: the first that fits beside the count is used.
const NAME_SIZES: Array[int] = [24, 21, 18, 16]
const COUNT_SIZE: float = 30.0
## Room between the slot's paper and the subtitle paper above which it sits while a line is up.
const GAP: float = 12.0
const INK: Color = Color("17131b")
const SHADOW: Vector2 = Vector2(4.0, 5.0)
const SHADOW_A: float = 0.5


static func on() -> bool:
	return LaunchArgs.value("--hud-weapon") != "off"


## The slot's box (its words' rect: the paper grows round it, HudView.paper_of) on a
## `screen`-sized HUD: the bottom-right corner, or above the subtitle paper when `subtitle_up`.
static func box_of(screen: Vector2, subtitle_up: bool) -> Rect2:
	var h: float = PAD + ICON_H + NAME_H + PAD
	var bottom: float = screen.y - HudView.MARGIN
	if subtitle_up:
		bottom = HudView.subtitle_top(screen.y) - GAP - 10.0
	return Rect2(screen.x - HudView.MARGIN - W, bottom - h, W, h)


## The icon's rect in `box`: the drawing fitted into the top band, aspect kept, centred.
static func icon_rect(box: Rect2, t: Texture2D) -> Rect2:
	var band: Rect2 = Rect2(box.position + Vector2(PAD, PAD), Vector2(W - PAD * 2.0, ICON_H))
	var k: float = minf(band.size.x / t.get_width(), band.size.y / t.get_height())
	var sz: Vector2 = Vector2(t.get_width(), t.get_height()) * k
	return Rect2(band.get_center() - sz * 0.5, sz)


## The count's text ("x12"), or "" when the weapon has no magazine (state.ammo < 0).
static func count_text(ammo: int) -> String:
	return "x%d" % ammo if ammo >= 0 else ""


## The name's size: the largest of NAME_SIZES whose width fits `room` px (else the smallest).
static func name_size(words: String, room: float) -> int:
	var font: Font = ThemeDB.fallback_font
	for s: int in NAME_SIZES:
		if font.get_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, -1, s).x <= room:
			return s
	return NAME_SIZES[NAME_SIZES.size() - 1]


## Paper, drawing (with its ink drop shadow), name and count into `box` on `ci`.
static func draw(ci: CanvasItem, art: HudArt, state: HudState, box: Rect2) -> void:
	var paper: Texture2D = art.texture(art.memo_art)
	HudView.nine(ci, paper, HudView.paper_of(box), art.memo_margin_px, art.memo_scale)
	if state.weapon_icon != null:
		var r: Rect2 = icon_rect(box, state.weapon_icon)
		var ink: Color = Color(INK, SHADOW_A)
		ci.draw_texture_rect(state.weapon_icon, Rect2(r.position + SHADOW, r.size), false, ink)
		ci.draw_texture_rect(state.weapon_icon, r, false)
	var base: float = box.position.y + PAD + ICON_H + NAME_H * 0.72
	var count: String = count_text(state.ammo)
	var count_w: float = HudCash.digits_w(art, count, COUNT_SIZE) if count != "" else 0.0
	if count != "":
		var at: Vector2 = Vector2(box.end.x - PAD - count_w, base + 2.0)
		HudCash.ink_digits(ci, art, at, count, COUNT_SIZE)
	var words: String = state.weapon.to_upper()
	var room: float = W - PAD * 2.0 - (count_w + 10.0 if count != "" else 0.0)
	var size: int = name_size(words, room)
	var font: Font = ThemeDB.fallback_font
	var at_name: Vector2 = Vector2(box.position.x + PAD, base)
	ci.draw_string(font, at_name, words, HORIZONTAL_ALIGNMENT_LEFT, room, size, INK)
