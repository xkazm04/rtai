class_name GhostFormLayout
extends RefCounted
## The ghost-form card's sizes (GhostFormHud): `full` is the desktop card as authored; `compact` is
## the handheld card (DeviceProfile.hud, the owner's h-3 B of 2026-11-07): smaller chips closer
## together, one name (the selected ghost's) instead of every name, the same 18 px text so it stays
## above Valve's 9 px legibility floor on a 7-inch 1280x800 panel. Plain numbers, no drawing.

## The chip radius (the current form's chip is 1.18x this).
var chip_r: float = 26.0
## Chip centre to chip centre.
var gap: float = 84.0
## The card's distance from the screen's left and bottom edges.
var margin: float = 36.0
var text_size: int = 18
var card_h: float = 158.0
## The chips' centre line, from the card's top.
var chip_y: float = 60.0
## The Madness bar's top, from the card's top, and its height.
var bar_y: float = 128.0
var bar_h: float = 14.0
## false = only the selected ghost carries its name (the others read by their faces).
var all_names: bool = true


## The layout for this run's device row (the desktop row = full, untouched).
static func for_device(p: DeviceProfile) -> GhostFormLayout:
	return compact() if p.hud == &"compact" else GhostFormLayout.new()


static func compact() -> GhostFormLayout:
	var l: GhostFormLayout = GhostFormLayout.new()
	l.chip_r = 19.0
	l.gap = 50.0
	l.margin = 22.0
	l.card_h = 120.0
	l.chip_y = 46.0
	l.bar_y = 104.0
	l.bar_h = 9.0
	l.all_names = false
	return l


## The card's width for `chips` chips.
func card_w(chips: int) -> float:
	return gap * float(maxi(chips, 1)) + 24.0
