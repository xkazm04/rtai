class_name StreetCardSets
extends RefCounted
## Lane n8 street's per-pitch art that is not a head card row: the riot shield's plate
## (RiotShieldCard). The street head card rows are data: data/tables/card_sets/street.json
## (merged over RigCardSets.SETS by RigCardSets.all()).

const P55: String = "res://features/characters/art/view/p55/"
const P70: String = "res://features/characters/art/view/p70/"
## The riot shield's upright plate per art (RiotShieldCard), cut by shield_cut.py from the
## library's keyed cop_riot sheets (the front-on plate of the advance pose).
const SHIELD: Dictionary[String, String] = {
	"p55": P55 + "riot_shield_card.png",
	"p70": P70 + "riot_shield_card.png",
}


## The shield plate's strip for one art ("" = none: the crescent part draws).
static func shield_for(art: String) -> String:
	return SHIELD.get(art, "")
