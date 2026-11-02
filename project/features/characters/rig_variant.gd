class_name RigVariant
extends RefCounted
## A look on a body plan: part swaps only (head, torso), the riot shield, and the print shader's
## palette swap. A pooled rig changes variant by swapping textures, never by rebuilding.
## CROWD is the slice's crowd cast; its index is the clip table's variant (the city's
## SimConst.CLIP_VARIANTS = 8), so the baked atlas and the full rigs agree on who wears what.

const CROWD_COUNT: int = 8

var tag: String = ""
var kind: BodyPlan.Kind = BodyPlan.Kind.PED
var head: String = ""
var torso: String = ""
var shield: bool = false
var swap: int = 0


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


## The slice cast: cops (patrol, riot) and pedestrians (coat or jacket, three heads).
static func crowd(index: int) -> RigVariant:
	match index:
		0:
			return make(BodyPlan.Kind.PED, "coat-hat", "head_hat", "torso", false)
		1:
			return make(BodyPlan.Kind.PED, "jacket-hair", "head_hair", "torso_jacket", false)
		2:
			return make(BodyPlan.Kind.PED, "coat-hood", "head_hood", "torso", false)
		3:
			return make(BodyPlan.Kind.PED, "jacket-hat", "head_hat", "torso_jacket", false)
		4:
			return make(BodyPlan.Kind.PED, "vest-hair", "head_hair", "torso_vest", false)
		5:
			return make(BodyPlan.Kind.COP, "patrol", "head_cap", "torso", false)
		6:
			return make(BodyPlan.Kind.COP, "riot", "head_helmet", "torso", true)
		_:
			return make(BodyPlan.Kind.PED, "coat-hair", "head_hair", "torso", false)


## A stable look for an actor id with no RNG draw (rigs are render-side: they must never move a
## replay-hashed stream). Cops pick from the cop looks, everyone else from the pedestrians.
static func crowd_index_for(actor_id: int, body: BodyPlan.Kind) -> int:
	var h: int = RngRegistry.fnv1a32(str(actor_id))
	if body == BodyPlan.Kind.COP:
		return 5 + h % 2
	var peds: PackedInt32Array = PackedInt32Array([0, 1, 2, 3, 4, 7])
	return peds[h % peds.size()]
