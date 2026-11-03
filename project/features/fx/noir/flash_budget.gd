class_name FlashBudget
extends RefCounted
## D-Noir photosensitivity budget (lane noir): every effect that flashes a large part of the
## screen (the kill beat's white silhouette flash + panel, the muzzle's pool of light) spends
## from ONE shared budget, so they cannot add up past the limit together. WCAG 2.x 2.3.1 allows
## at most 3 flashes in any 1 s (a flash = a pair of opposite luminance changes); the budget is
## MAX_FLASHES (3) per WINDOW ticks, and the muzzle light keeps BEAT_COST free (spend_light), so
## a round fired just before a kill never turns that kill's beat calm: at most 1 light + 1 beat
## a second. The beat is costed at 2 (measured 1-1.5 in the flash check), which is the margin.
## enabled = false is the "flashes off"
## accessibility mode: nothing may flash at all (the callers fall back to non-flashing beats).
## Stepped on the fixed tick.

const WINDOW: int = 60
const MAX_FLASHES: int = 3
## What each effect costs: the kill beat flashes the whole frame and then holds a paper-gutter
## panel (up to two luminance pairs in a region); the muzzle light is one frame of light.
const BEAT_COST: int = 2
const LIGHT_COST: int = 1

var enabled: bool = true
var _tick: int = 0
## Tick stamps of the flashes inside the window, one per flash spent.
var _spent: PackedInt32Array = PackedInt32Array()


static func from_params(d: Dictionary) -> FlashBudget:
	var b: FlashBudget = FlashBudget.new()
	var safety: Variant = d.get("safety", {})
	if safety is Dictionary:
		var s: Dictionary = safety
		b.enabled = s.get("flashes", true)
	return b


func can_spend(cost: int) -> bool:
	return enabled and _spent.size() + cost <= MAX_FLASHES


## Spends `cost` flashes now if they fit in the window; false = do not flash.
func spend(cost: int) -> bool:
	if not can_spend(cost):
		return false
	for i: int in cost:
		@warning_ignore("return_value_discarded")
		_spent.append(_tick)
	return true


## The muzzle light's spend: only if a kill beat would still fit after it.
func spend_light() -> bool:
	if not can_spend(LIGHT_COST + BEAT_COST):
		return false
	return spend(LIGHT_COST)


func step_ticks(n: int) -> void:
	_tick += n
	while not _spent.is_empty() and _tick - _spent[0] >= WINDOW:
		_spent.remove_at(0)


## Flashes spent in the last WINDOW ticks (tests, evidence).
func used() -> int:
	return _spent.size()
