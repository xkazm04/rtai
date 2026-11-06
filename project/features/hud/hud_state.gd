class_name HudState
extends RefCounted
## What the HUD shows this frame, as plain values (LAY-05: features/hud reads no quest or stage
## internals; the caller fills this, e.g. boot/collect_call/view/hud_feed.gd). Words are already
## translated; numbers are raw and the HUD formats them.

## The beat panel's head line ("2/6  Find Juno"); empty hides the panel.
var head: String = ""
## Heat (the wanted level) as pips: `heat` lit out of `heat_max`.
var heat: int = 0
var heat_max: int = 3
var cash: int = 0
## The weapon in hand, display text; empty = unarmed.
var weapon: String = ""
## n8-hud: the weapon's HUD icon (its showcase icon cut, else the shipped icon); null = no icon.
var weapon_icon: Texture2D = null
## The magazine count drawn on the ammo ticket; -1 draws no count (e.g. the nail gun).
var ammo: int = -1
## The subtitle box: speaker and words; an empty speaker hides the box.
var speaker: String = ""
var words: String = ""
## One line under the beat panel (the save notice); empty hides it.
var notice: String = ""
## Translated labels (HUD__HEAT, HUD__UNARMED).
var heat_label: String = "HEAT"
var unarmed_label: String = "unarmed"


func say(who: String, line: String) -> void:
	speaker = who
	words = line


func silent() -> void:
	speaker = ""
	words = ""
