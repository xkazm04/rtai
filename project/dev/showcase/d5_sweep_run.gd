class_name D5SweepRun
extends D5ShowcaseRun
## d5-close: the tier-fade sweep. The A/B cast shot at 51 to 67 px/m in 2 px/m steps (D4 and the D5
## tier from the same pose), so the share of Rivet that the tier repaints can be plotted per zoom: a
## smooth ramp from 0 at the switch = no pop. Writes <tier>-<ppm>ppm(-rivet).png like the parent.


func _init() -> void:
	zooms = []
	for k: int in 9:
		zooms.append((51.0 + 2.0 * k) / PX)
