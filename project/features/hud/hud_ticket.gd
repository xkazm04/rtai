class_name HudTicket
extends RefCounted
## n8-hud: the ammo ticket carries the weapon's showcase icon on its own paper (ON_TICKET), right of
## the name: the bare icon on the field left of the ticket read as a floor pickup on a busy street
## (view's quest 1 Dock 9 note, it11). The ticket grows left to hold it by a 3-slice: the bullet
## stub end (L_SRC) and the torn right end (R_SRC) kept at the drawn 260 px scale, the plain paper
## between stretched. ON_TICKET false = the 260 px ticket with the icon beside it on the street.

const ON_TICKET: bool = true
const W: float = 260.0
const H: float = 124.0
const L_SRC: float = 150.0
const R_SRC: float = 120.0
## The name's left edge in the ticket (source px, right of the perforation).
const TEXT_SRC: float = 140.0
## The icon's box on the paper (screen px): its height, widest, the gap after the words and the
## paper right of it (clear of the torn end's hatch).
const ICON_H: float = 80.0
const ICON_MAX_W: float = 180.0
const GAP: float = 22.0
const RIGHT_PAD: float = 30.0


## The icon's drawn size on the paper: ICON_H tall, no wider than ICON_MAX_W, aspect kept.
static func icon_size(icon: Texture2D) -> Vector2:
	var src: Vector2 = Vector2(icon.get_size())
	var k: float = minf(ICON_H / src.y, ICON_MAX_W / src.x)
	return src * k


## The ticket's width: the words (`words` px wide) and the icon, at least the drawn W.
static func width(art: HudArt, words: float, icon: Texture2D) -> float:
	if not ON_TICKET or icon == null:
		return W
	return maxf(W, text_x(art) + words + GAP + icon_size(icon).x + RIGHT_PAD)


## The name's left edge in the ticket (screen px).
static func text_x(art: HudArt) -> float:
	return TEXT_SRC * W / art.size_px(&"ammo_ticket").x


## The ticket's words: the name at `size` or the count in the numeral strip at 30, the wider.
static func words_w(art: HudArt, state: HudState, size: int) -> float:
	var name: String = state.weapon.to_upper()
	var font: Font = ThemeDB.fallback_font
	var name_w: float = font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var count: String = "x%d" % state.ammo if state.ammo >= 0 else ""
	return maxf(name_w, HudCash.digits_w(art, count, 30.0))


## The ticket into `box` on `ci`: the stub end and the torn end at the drawn scale, the middle
## stretched (the plain paper and its two border lines).
static func frame(ci: CanvasItem, art: HudArt, box: Rect2) -> void:
	var t: Texture2D = art.texture(&"ammo_ticket")
	var src: Vector2 = Vector2(t.get_size())
	var k: float = W / src.x
	var l: float = L_SRC * k
	var r: float = R_SRC * k
	ci.draw_texture_rect_region(
		t, Rect2(box.position, Vector2(l, box.size.y)), Rect2(0.0, 0.0, L_SRC, src.y)
	)
	var mid: Rect2 = Rect2(box.position.x + l, box.position.y, box.size.x - l - r, box.size.y)
	ci.draw_texture_rect_region(t, mid, Rect2(L_SRC, 0.0, src.x - L_SRC - R_SRC, src.y))
	ci.draw_texture_rect_region(
		t,
		Rect2(box.end.x - r, box.position.y, r, box.size.y),
		Rect2(src.x - R_SRC, 0, R_SRC, src.y)
	)


## Where the icon sits on the ticket `box` (right-aligned, centred on the paper).
static func icon_rect(box: Rect2, icon: Texture2D) -> Rect2:
	var sz: Vector2 = icon_size(icon)
	var at: Vector2 = Vector2(
		box.end.x - RIGHT_PAD - sz.x, box.position.y + (box.size.y - sz.y) * 0.5
	)
	return Rect2(at, sz)
