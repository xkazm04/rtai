class_name StreetCardSets
extends RefCounted
## Lane n8 street's card rows, per view art (view.json `art`), in RigCardSets.SETS's row shape:
## art_dir or art_dir/head part -> [strip, anchor y, width over the anchor part's, bust, raw].
## RigHeadCard.rows_of merges these after RigCardSets.SETS[art] (street rows win the keys they
## name). p70 strips are cut by tools/art/street_head.py from the assets library's keyed 70 sheets
## (keyed/street/<id>_70.png); widths keep each head's on-screen width equal to its p55 card's
## (the head's share of the cell measured on both strips). p55 rows stay in RigCardSets for now.

const P55: String = "res://features/characters/art/view/p55/"
const P70: String = "res://features/characters/art/view/p70/"
## The riot shield's upright plate per art (RiotShieldCard), cut by shield_cut.py from the
## library's keyed cop_riot sheets (the front-on plate of the advance pose).
const SHIELD: Dictionary[String, String] = {
	"p55": P55 + "riot_shield_card.png",
	"p70": P70 + "riot_shield_card.png",
}

const SETS: Dictionary[String, Dictionary] = {
	"p70":
	{
		"cop/head_cap": [P70 + "cop_cap_card.png", 0.8, 1.72, false, true],
		"cop/head_helmet": [P70 + "cop_riot_card.png", 0.82, 1.05, false, true],
		"cop/head_swat": [P70 + "swat_head_card.png", 0.82, 1.4, false, true],
		"thug": [P70 + "thug_head_card.png", 0.8, 1.2, false, true],
	},
}


## The rows this lane registers for one art key (empty for an art it has none for).
static func rows_for(art: String) -> Dictionary:
	return SETS.get(art, {})


## The shield plate's strip for one art ("" = none: the crescent part draws).
static func shield_for(art: String) -> String:
	return SHIELD.get(art, "")
