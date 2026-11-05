class_name GangPlan
extends RefCounted
## King's gang: the robot thug's body (ThugPlan) in the rich dress (art/gang/, art/d5/gang/, from
## tools/art/gang_parts.py: a black visor with a gold frame, two gold chains, gold knuckle rings).
## ART_DIR "thug" is the one line back to the plain thug.

const ART_DIR: String = "gang"


static func build() -> BodyPlan:
	var p: BodyPlan = ThugPlan.build()
	p.name = "king_gang"
	p.art_dir = ART_DIR
	return p
