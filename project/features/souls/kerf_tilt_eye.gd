class_name KerfTiltEye
extends Sprite2D
## Centres and diameters of the visible poised and cruise sockets, in atlas cell pixels.
## The rear two facings hide the lens behind the hull.

const SOCKET_70: Array[Vector4] = [
	Vector4(75, 118, 20, 19), Vector4(101, 118, 17, 21), Vector4(130, 96, 10, 19)
]
const SOCKET_55: Array[Vector4] = [
	Vector4(77, 91, 20, 17), Vector4(106, 96, 16, 20), Vector4(134, 76, 10, 17)
]
const CRUISE_70: Array[Vector4] = [
	Vector4(75, 117, 18, 16), Vector4(100, 116, 16, 16), Vector4(128, 93, 12, 16)
]
const CRUISE_55: Array[Vector4] = [
	Vector4(77, 88, 18, 16), Vector4(104, 90, 16, 16), Vector4(132, 73, 11, 14)
]


func place(sheet: Sprite2D, art: String, locked: bool, flinch: bool) -> void:
	var row: int = sheet.frame_coords.y
	var col: int = sheet.frame_coords.x
	# The lunge already has a slit painted in its cell.
	var lock_eye: bool = locked and col == KerfSpectral.Mood.POISED
	visible = row < 3 and (lock_eye or flinch and col != KerfSpectral.Mood.LUNGE)
	if not visible:
		return
	var socket: Vector4 = SOCKET_70[row] if art == "p70" else SOCKET_55[row]
	if col == KerfSpectral.Mood.CRUISE:
		socket = CRUISE_70[row] if art == "p70" else CRUISE_55[row]
	var cell: Vector2 = sheet.texture.get_size() / Vector2(sheet.hframes, sheet.vframes)
	position = Vector2(socket.x, socket.y) - cell * 0.5
	var side: float = -1.0 if sheet.flip_h else 1.0
	position.x *= side
	flip_h = sheet.flip_h
	rotation = deg_to_rad(28.0 * side) if row == 1 else 0.0
	scale = Vector2(socket.z, socket.w) / texture.get_size()
