class_name StreetCrowdCards
extends RefCounted
## Lane n8 street: the crowd's head cards under a card view draw all nine library pedestrian types
## (gtai-art library keyed/street/ped_*), not one card per crowd look. The game has six pedestrian
## looks (RigVariant.crowd) and five heads; a look with a POOLS entry draws one of its pool's card
## rows (data/tables/card_sets/street.json), picked by the actor id (no RNG draw: rigs are
## render-side). The pick swaps the card's strip once per built card, keeps the row's anchor, and
## scales the card by the row's width over the base row's each step (after RigHeadCard places it).
## An art with no row for the pick keeps the base card. Straight down nothing here runs.
## Every pedestrian's card also varies by its actor id: a scale within +-SCALE_VAR (the head and
## shoulders read as a build) and a value within +-VALUE_VAR (grey, so no hue moves: the colour law
## holds). Both 0 = every person of a type drawn alike (the before).

## Look tag -> the card rows its people draw (index = the actor's hash modulo the pool size).
const POOLS: Dictionary[String, PackedStringArray] = {
	"jacket-hair": ["ped/head_hair", "ped/head_punk"],
	"vest-hair": ["ped/head_shopper", "ped/head_jogger"],
	"overalls-bald": ["ped/head_bald", "ped/head_worker"],
}
## The card's width over the base row's (1.0 = the base card, no swap) times the person's scale.
const K: StringName = &"street_card_k"
const SCALE_VAR: float = 0.08
const VALUE_VAR: float = 0.07
static var _tex: Dictionary[String, Texture2D] = {}


## Each pose step under a tilt (StreetView, after RigHeadCard placed the card).
static func step(rig: CutRig) -> void:
	var card: Sprite2D = rig.head_card
	if card == null or rig.variant == null:
		return
	if not card.has_meta(K):
		var k_swap: float = _swap(rig, card)
		if rig.plan.art_dir == "ped":
			k_swap *= 1.0 + SCALE_VAR * vary(rig.actor_id, 3)
			var v: float = 1.0 + VALUE_VAR * vary(rig.actor_id, 17)
			card.self_modulate = Color(v, v, v)
		card.set_meta(K, k_swap)
	var k: float = card.get_meta(K)
	if k != 1.0:
		card.global_scale = card.global_scale * k


## The card row an actor of a look draws ("" = the look's own head).
static func pick(tag: String, actor_id: int) -> String:
	var pool: PackedStringArray = POOLS.get(tag, PackedStringArray())
	if pool.is_empty():
		return ""
	var h: int = ((actor_id * 2246822519) >> 9) & 0x7FFFFFFF
	return pool[h % pool.size()]


## A stable value in [-1, 1] for an actor id (salt picks an independent draw; no RNG stream).
static func vary(actor_id: int, salt: int) -> float:
	var h: int = (((actor_id + salt * 7919) * 2654435761) >> 11) & 0xFFFF
	return h / 32767.5 - 1.0


static func _swap(rig: CutRig, card: Sprite2D) -> float:
	var key: String = pick(rig.variant.tag, rig.actor_id)
	var rows: Dictionary[String, Array] = RigHeadCard.rows()
	var base: String = RigHeadCard.key_of(rig.plan, rig.variant.head)
	if key.is_empty() or key == base or not rows.has(key) or not rows.has(base):
		return 1.0
	var row: Array = rows[key]
	var path: String = row[0]
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	card.texture = _tex[path]
	var cell: Vector2 = Vector2(
		card.texture.get_width() / float(RigHeadCard.FRAMES), card.texture.get_height()
	)
	var anchor_y: float = row[1]
	card.offset = Vector2(-cell.x * 0.5, -cell.y * anchor_y)
	card.set_meta(&"street_row", key)
	var w: float = row[2]
	var w_base: float = rows[base][2]
	return w / w_base
