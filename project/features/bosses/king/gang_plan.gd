class_name GangPlan
extends RefCounted
## King's gang: the robot thug's body (ThugPlan) in the rich dress (art/gang/, art/d5/gang/, from
## tools/art/gang_parts.py: a black visor with a gold frame, two gold chains, gold knuckle rings).
## ART_DIR "thug" is the one line back to the plain thug.

const ART_DIR: String = "gang"
## Bodyguard bulk (it9 trial): the target's gang are heavy steel bots, the plain thug reads as thin
## grey limbs at 32 px/m. SIZE_K ThugPlan.SIZE_K and ARM_W ThugPlan.ARM_W = the plain thug's body.
const SIZE_K: float = 1.2
const ARM_W: float = 1.7


static func build() -> BodyPlan:
	var p: BodyPlan = ThugPlan.build(SIZE_K)
	p.name = "king_gang"
	p.art_dir = ART_DIR
	p.arm_w = ARM_W
	return p
