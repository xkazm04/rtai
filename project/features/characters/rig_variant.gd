class_name RigVariant
extends RefCounted
## A look on a body plan: part swaps only (head, torso), the riot shield, and the print shader's
## palette swap. A pooled rig changes variant by swapping textures, never by rebuilding.
## CROWD is the slice's crowd cast; its index is the clip table's variant (the city's
## SimConst.CLIP_VARIANTS = 8), so the baked atlas and the full rigs agree on who wears what.

const CROWD_COUNT: int = 8
## Looks past the crowd cast: full rigs only (the arena pit, the reaction line, dev scenes). The
## baked atlas has CROWD_COUNT rows, so atlas_look() prints these as their nearest crowd look.
const SWAT: int = 8
const LOOK_COUNT: int = 9
## n5-cast r7: the hoodie's sleeves follow its mid warm-grey body (was "_dark": black ink arms
## made the walking hoodie ped a dark blob at 32-48 px/m). "_dark" = the iteration 12 look.
const HOODIE_SLEEVE: String = "_grey"

var tag: String = ""
var kind: BodyPlan.Kind = BodyPlan.Kind.PED
var head: String = ""
var torso: String = ""
var shield: bool = false
var swap: int = 0
## Sleeve value: "" = the cream arm parts, else a suffix ("_dark", "_grey"): the arm cells use
## `<part><sleeve>` where the art has it, so looks differ in their widest shapes, not only the head.
var sleeve: String = ""


static func make(
	p_kind: BodyPlan.Kind, p_tag: String, p_head: String, p_torso: String, p_shield: bool
) -> RigVariant:
	var v: RigVariant = RigVariant.new()
	v.kind = p_kind
	v.tag = p_tag
	v.head = p_head
	v.torso = p_torso
	v.shield = p_shield
	return v


static func rivet() -> RigVariant:
	return make(BodyPlan.Kind.RIVET, "rivet", "helmet", "torso", false)


## The slice cast: cops (patrol, riot) and pedestrians (coat, jacket, vest, hoodie, overalls).
static func crowd(index: int) -> RigVariant:
	match index:
		0:
			return make(BodyPlan.Kind.PED, "coat-hat", "head_hat", "torso", false)
		1:
			return _sleeved(
				make(BodyPlan.Kind.PED, "jacket-hair", "head_hair", "torso_jacket", false), "_dark"
			)
		2:
			return make(BodyPlan.Kind.PED, "coat-hood", "head_hood", "torso", false)
		3:
			return _sleeved(
				make(BodyPlan.Kind.PED, "hoodie-cap", "head_cap", "torso_hoodie", false),
				HOODIE_SLEEVE
			)
		4:
			return make(BodyPlan.Kind.PED, "vest-hair", "head_hair", "torso_vest", false)
		5:
			return make(BodyPlan.Kind.COP, "patrol", "head_cap", "torso", false)
		6:
			return make(BodyPlan.Kind.COP, "riot", "head_helmet", "torso", true)
		SWAT:  # weapon-art d9102db7: the dark helmet with a visor, the plate carrier
			return make(BodyPlan.Kind.COP, "swat", "head_swat", "torso_swat", false)
		_:
			return _sleeved(
				make(BodyPlan.Kind.PED, "overalls-bald", "head_bald", "torso_overalls", false),
				"_grey"
			)


## The baked atlas row a look prints as at LOD 1 (the atlas holds the crowd cast only): SWAT
## prints as the patrol cop (same body, a blue shirt) until the city bakes a ninth row.
static func atlas_look(index: int) -> int:
	return 5 if index == SWAT else clampi(index, 0, CROWD_COUNT - 1)


## The pit's rifle squads (arena --rigs): patrol, riot and SWAT by actor id, no RNG draw.
static func squad_index_for(actor_id: int) -> int:
	var h: int = ((actor_id * 2654435761) >> 13) & 0x7FFFFFFF
	return [5, 6, SWAT][h % 3]


static func _sleeved(v: RigVariant, p_sleeve: String) -> RigVariant:
	v.sleeve = p_sleeve
	return v


## A stable look for an actor id with no RNG draw (rigs are render-side: they must never move a
## replay-hashed stream). Cops pick from the cop looks, everyone else from the pedestrians.
static func crowd_index_for(actor_id: int, body: BodyPlan.Kind) -> int:
	var h: int = ((actor_id * 2654435761) >> 13) & 0x7FFFFFFF
	if body == BodyPlan.Kind.COP:
		return 5 + h % 2
	var peds: PackedInt32Array = PackedInt32Array([0, 1, 2, 3, 4, 7])
	return peds[h % peds.size()]
