class_name KillXray
extends RefCounted
## n16 kills-polish (DEFECTS ranking #2): where the electro X-ray skeleton (KillShockFx) stands. It
## stands where the body stood, its feet on the body's feet (KillView places a body at its ground
## point) and FOOT_M below them, so it reads as HIS X-ray, not a sticker lying beside him.
## `--shock-xray=lie` = the before (turned along the shot, centred on the feet).
## n16 item 3 (asset lane A3, it418/it422): each street kind flashes its own drawn skeleton
## (its cap, helmet, hood or hard hat drawn as gear over the bones), two frames: cream bones on
## ink for the held flash, the inverse on alternate strobe pulses (tools/art/xray_cells.py packs
## them). No drawn set (the top view, `--xray-art=plain`): the one plain skeleton.

const FOOT_M: float = 0.05
const KIND: StringName = &"xray_kind"
## The drawn figure's height and its widest (m): the plain sticker's 1.6 m, arms flung out.
const WIDE_M: float = 1.75
const ART: Dictionary[String, Texture2D] = {
	"cop_patrol": preload("res://features/combat/weapons/art/gore/xray_cop_patrol.png"),
	"cop_riot": preload("res://features/combat/weapons/art/gore/xray_cop_riot.png"),
	"swat": preload("res://features/combat/weapons/art/gore/xray_swat.png"),
	"ped_hood": preload("res://features/combat/weapons/art/gore/xray_ped_hood.png"),
	"ped_cap": preload("res://features/combat/weapons/art/gore/xray_ped_cap.png"),
	"ped_worker": preload("res://features/combat/weapons/art/gore/xray_ped_worker.png"),
	"ped_suit": preload("res://features/combat/weapons/art/gore/xray_ped_suit.png"),
	"ped_generic": preload("res://features/combat/weapons/art/gore/xray_ped_generic.png"),
}
## n16 it4 (asset lane 15:01): the same kinds redrawn for the p55 view (face under the crown).
const ART_55: Dictionary[String, Texture2D] = {
	"cop_patrol": preload("res://features/combat/weapons/art/gore/xray_cop_patrol_55.png"),
	"cop_riot": preload("res://features/combat/weapons/art/gore/xray_cop_riot_55.png"),
	"swat": preload("res://features/combat/weapons/art/gore/xray_swat_55.png"),
	"ped_hood": preload("res://features/combat/weapons/art/gore/xray_ped_hood_55.png"),
	"ped_cap": preload("res://features/combat/weapons/art/gore/xray_ped_cap_55.png"),
	"ped_worker": preload("res://features/combat/weapons/art/gore/xray_ped_worker_55.png"),
	"ped_suit": preload("res://features/combat/weapons/art/gore/xray_ped_suit_55.png"),
	"ped_generic": preload("res://features/combat/weapons/art/gore/xray_ped_generic_55.png"),
}
## Street row -> drawn set; another cop row is a patrol cop, any other human the generic ped.
const BY_ROW: Dictionary[String, String] = {
	"cop/head_cap": "cop_patrol",
	"cop/head_helmet": "cop_riot",
	"cop/head_swat": "swat",
	"ped/head_hood": "ped_hood",
	"ped/head_cap": "ped_cap",
	"ped/head_worker": "ped_worker",
	"ped/head_hair": "ped_suit",
}

static var _lie: int = -1
static var _plain: int = -1


## The skeleton's centre for a body whose feet are at `feet`: half of `height_m` above them (the
## feet themselves when lying).
static func mid(feet: Vector2, height_m: float, ppm: float) -> Vector2:
	if lies():
		return feet
	return feet + Vector2(0.0, (FOOT_M - height_m * 0.5) * ppm)


## True under `--shock-xray=lie` (the skeleton turned along the shot: the before).
static func lies() -> bool:
	if _lie < 0:
		_lie = 1 if ArenaArgs.parse().text("--shock-xray") == "lie" else 0
	return _lie == 1


## The drawn set's key for a street row ("" = none: the plain skeleton).
static func kind_of_row(row: String) -> String:
	if row == "":
		return ""
	if BY_ROW.has(row):
		return BY_ROW[row]
	return "cop_patrol" if row.begins_with("cop/") else "ped_generic"


## Tags the shock's wrapped body with the victim's drawn set (a rig with no head card: none).
static func tag(root: Node2D, rig: CutRig) -> void:
	if root != null and rig != null and rig.head_card != null:
		root.set_meta(KIND, kind_of_row(StreetWalkerCards.row_of(rig)))


## The two-frame strip for a tagged body, or null (the plain skeleton: untagged, or
## `--xray-art=plain`).
static func art_of(body: Node2D) -> Texture2D:
	if _plain < 0:
		_plain = 1 if ArenaArgs.parse().text("--xray-art") == "plain" else 0
	if _plain == 1 or body == null or not body.has_meta(KIND):
		return null
	var kind: String = body.get_meta(KIND)
	return (ART_55 if ViewMode.shared().art == "p55" else ART).get(kind, null)


## Where the drawn frame `frame` (0 or 1) of `tex` lands: feet FOOT_M below `feet`, XRAY height
## `height_m` unless that makes it wider than WIDE_M.
static func rect(tex: Texture2D, feet: Vector2, height_m: float, ppm: float) -> Rect2:
	var cell: Vector2 = Vector2(tex.get_width() * 0.5, tex.get_height())
	var s: float = minf(height_m * ppm / cell.y, WIDE_M * ppm / cell.x)
	var size: Vector2 = cell * s
	return Rect2(feet + Vector2(-size.x * 0.5, FOOT_M * ppm - size.y), size)


## Draws frame `frame` (0 held, 1 the inverse) of the strip `tex` on `ci`, standing on `feet`.
static func draw(ci: CanvasItem, tex: Texture2D, feet: Vector2, frame: int, ppm: float) -> void:
	var cw: float = tex.get_width() * 0.5
	var src: Rect2 = Rect2(cw * frame, 0.0, cw, tex.get_height())
	ci.draw_texture_rect_region(tex, rect(tex, feet, KillShockFx.XRAY_M * view_scale(), ppm), src)


## The X-ray's height over XRAY_M in the shared view: the view's card height over the p70 one
## (n16 it4: the p55 cards stand 2.0 m, so a 1.6 m skeleton looked shrunken in the man's place).
static func view_scale() -> float:
	var h: float = StreetWalkerCards.HEIGHT_BY_ART.get(
		ViewMode.shared().art, StreetWalkerCards.HEIGHT_M
	)
	return h / StreetWalkerCards.HEIGHT_M
