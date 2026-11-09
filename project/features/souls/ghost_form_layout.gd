class_name GhostFormLayout
extends RefCounted
## The ghost HUD's sizes (GhostFormHud): `full` is the desktop strip; `compact` is the handheld one
## (DeviceProfile.hud, the owner's h-3 B of 2026-11-07): smaller avatars closer together, the same
## 18 px text so it stays above Valve's 9 px legibility floor on a 7-inch 1280x800 panel. n11: no
## paper behind any of it, only the selected ghost carries a name. Plain numbers, no drawing.

## The avatar radius (the current form's avatar is 1.18x this).
var chip_r: float = 26.0
## Avatar centre to avatar centre.
var gap: float = 58.0
## The strip's distance from the screen's left and bottom edges.
var margin: float = 18.0
var text_size: int = 18
## The strip's height: the name, the avatars, the chevron and key hint, the Madness bar.
var card_h: float = 128.0
## The avatars' centre line, from the strip's top.
var chip_y: float = 50.0
## The Madness bar's top, from the strip's top, and its height.
var bar_y: float = 116.0
var bar_h: float = 7.0
## false = only the selected ghost carries its name (the others read by their faces).
var all_names: bool = false


## The layout for this run's device row (the desktop row = full).
static func for_device(p: DeviceProfile) -> GhostFormLayout:
	return compact() if p.hud == &"compact" else GhostFormLayout.new()


static func compact() -> GhostFormLayout:
	var l: GhostFormLayout = GhostFormLayout.new()
	l.chip_r = 19.0
	l.gap = 42.0
	l.margin = 12.0
	l.card_h = 100.0
	l.chip_y = 40.0
	l.bar_y = 90.0
	l.bar_h = 6.0
	return l


## The strip's width for `chips` avatars.
func card_w(chips: int) -> float:
	return gap * float(maxi(chips, 1)) + 12.0
