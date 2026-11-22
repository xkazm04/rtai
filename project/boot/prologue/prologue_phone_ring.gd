class_name ProloguePhoneRing
extends Node2D
## World-space objective ink above the yard's screen-print pass.

const PERIOD: int = 48

var tick: int


func _draw() -> void:
	var phase: float = float(tick % PERIOD) / PERIOD
	for echo: float in [0.0, 0.5]:
		var spread: float = fmod(phase + echo, 1.0)
		var radius: float = (0.82 + 0.87 * spread) * SimConst.PX_PER_M
		var color: Color = Ink.VERMILION
		color.a = 1.0 - spread * 0.32
		for centre: float in [0.0, PI]:
			draw_arc(Vector2.ZERO, radius, centre - 0.73, centre + 0.73, 20, Ink.INK, 6.5, true)
			draw_arc(Vector2.ZERO, radius, centre - 0.73, centre + 0.73, 20, color, 3.7, true)
