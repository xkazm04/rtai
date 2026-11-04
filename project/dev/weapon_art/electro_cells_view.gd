extends Node2D
## Weapon-art dev still (loaded by electro_cells.gd): gunplay's procedural chain arcs + daze
## zigzags (left, the before) beside weapon-art's electro cells (WeaponFxElectro, right), three
## phases top to bottom, at 48 px/m on the arena floor grey.

const ZOOM: float = 1.0  # the window stretch (1.5x) makes it 48 px/m in the saved frame
const FLOOR: Color = Color(0.42, 0.38, 0.38)


func _ready() -> void:
	scale = Vector2.ONE * ZOOM


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(20.0, 12.0) * Ink.PX_PER_M), FLOOR)
	for row: int in 3:
		var y: float = 1.6 + 3.5 * float(row)
		var phase: int = row * 2 + 1
		for side: int in 2:
			var x: float = 0.8 + 10.0 * float(side)
			var a: Vector2 = Vector2(x, y)
			var b: Vector2 = Vector2(x + 3.4, y + 0.9)
			var c: Vector2 = Vector2(x + 7.0, y + 0.1)
			if side == 0:
				_before(a, b, c, phase)
			else:
				var drawn: bool = WeaponFxElectro.chain(self, a, b, phase)
				drawn = WeaponFxElectro.chain(self, b, c, phase + 1) and drawn
				drawn = WeaponFxElectro.stun(self, c, phase * 7) and drawn
				assert(drawn)


func _before(a: Vector2, b: Vector2, c: Vector2, phase: int) -> void:
	FightAreasArt._bolt(self, a, b, phase, 11.0, Ink.INK)
	FightAreasArt._bolt(self, a, b, phase, 4.5, Ink.CREAM)
	FightAreasArt._bolt(self, b, c, phase + 1, 11.0, Ink.INK)
	FightAreasArt._bolt(self, b, c, phase + 1, 4.5, Ink.CREAM)
	FightAreasArt._stun(self, c, phase * 7)
