class_name KillGround
extends Node2D
## One signature kill's print on the street (lane brutality, render only): its red spray, the
## smears of its parts that came to rest, its scorch and its ash heap. One node per kill, so a new
## kill or a part coming to rest reprints only its own kill, never every leftover (that full
## reprint was the kill-frame spike: 74 ms worst after 18 kills, CONTENDED). No RNG.

var view: KillView = null
var mark: KillMarks.Mark = null
var serial: int = -1


func _draw() -> void:
	var t0: int = Time.get_ticks_usec()
	if view.kills.tick - mark.tick >= mark.spray_from:
		KillMarkArt.spray(self, mark, view.ppm)
	for trail: PackedVector2Array in view.settled_smears(serial):
		KillMarkArt.smear(self, trail, view.ppm)
	KillMarkArt.scorch(self, mark, view.ppm)
	KillCharFx.pile(self, mark, view.kills.tick, view.ppm)
	view.add_us(Time.get_ticks_usec() - t0)


## An ash heap still growing in (KillCharFx.pile's 45 ticks) is reprinted every frame; a burst's
## print once more on the tick its spray lands (the pop).
func needs_reprint(tick: int) -> bool:
	if mark.spray_from > 0 and tick - mark.tick == mark.spray_from:
		return true
	var age: int = tick - mark.tick - mark.ash_from
	return mark.ash_m > 0.0 and age >= 0 and age <= 46
