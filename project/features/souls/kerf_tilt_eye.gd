class_name KerfTiltEye
extends Sprite2D
## Centres and diameters of the three visible POISED sockets in each atlas cell, in cell pixels.
## The rear two facings hide the lens behind the hull.

const SOCKET_70: Array[Vector4] = [
	Vector4(75, 118, 20, 19), Vector4(101, 118, 17, 21), Vector4(130, 96, 10, 19)
]
const SOCKET_55: Array[Vector4] = [
	Vector4(77, 91, 20, 17), Vector4(106, 96, 16, 20), Vector4(134, 76, 10, 17)
]


func place(sheet: Sprite2D, art: String, locked: bool) -> void:
	var row: int = sheet.frame_coords.y
	visible = locked and sheet.frame_coords.x == KerfSpectral.Mood.POISED and row < 3
	if not visible:
		return
	var socket: Vector4 = SOCKET_70[row] if art == "p70" else SOCKET_55[row]
	var cell: Vector2 = sheet.texture.get_size() / Vector2(sheet.hframes, sheet.vframes)
	position = Vector2(socket.x, socket.y) - cell * 0.5
	var side: float = -1.0 if sheet.flip_h else 1.0
	position.x *= side
	flip_h = sheet.flip_h
	rotation = deg_to_rad(28.0 * side) if row == 1 else 0.0
	scale = Vector2(socket.z, socket.w) / texture.get_size()
