class_name RigCardSets
extends RefCounted
## The per view art rows of RigHeadCard (RigHeadCard.SET_CARDS): view.json `art` -> art_dir or
## art_dir/head part -> [strip, anchor y, width over the anchor part's, bust, raw], the row shape
## of RigHeadCard.CARDS. An empty path keeps the base strip and changes the rest. p55: Rivet's bust
## (rivet_bust.py), Dent's tan bust (ghost_card_tone.py), the street heads (street_head.py, from the
## assets library's keyed 55 sheets). p70: view70's widths for its own strips.

const SETS: Dictionary[String, Dictionary] = {
	"p55":
	{
		"rivet":
		["res://features/characters/art/view/p55/rivet_bust_card.png", 0.66, 1.25, true, true],
		"dent":
		["res://features/characters/art/view/p55/dent_bust_card.png", 0.75, 1.75, true, true],
		"cop/head_swat":
		["res://features/characters/art/view/p55/swat_head_card.png", 0.8, 1.68, false, true],
		"cop/head_cap":
		["res://features/characters/art/view/p55/cop_cap_card.png", 0.78, 1.73, false, true],
		"cop/head_helmet":
		["res://features/characters/art/view/p55/cop_riot_card.png", 0.82, 1.32, false, true],
		"ped/head_hair":
		["res://features/characters/art/view/p55/ped_hair_card.png", 0.74, 2.0, false, true],
		"ped/head_bald":
		["res://features/characters/art/view/p55/ped_bald_card.png", 0.74, 1.9, false, true],
		"ped/head_hat":
		["res://features/characters/art/view/p55/ped_hat_card.png", 0.74, 1.93, false, true],
		"ped/head_hood":
		["res://features/characters/art/view/p55/ped_hood_card.png", 0.74, 1.81, false, true],
		"ped/head_cap":
		["res://features/characters/art/view/p55/ped_cap_card.png", 0.74, 2.3, false, true],
		"thug":
		["res://features/characters/art/view/p55/thug_head_card.png", 0.86, 1.0, false, true],
	},
	"p70":
	{
		"rivet": ["", 0.86, 1.17, false, true],
		"king": ["", 0.80, 3.53, true, true],
	},
}
