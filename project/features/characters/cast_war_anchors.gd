class_name CastWarAnchors
extends RefCounted
## DO NOT EDIT. Generated from shipped alpha by tools/art/cast_war_soles.py.
## Vector4(sole x, sole y, body x, body y) per facing x drawing, px from the cell's
## centre on the foot line (FoeWarCardView.BASE_PX), before the view's mirror.
const EIGHT: String = "war_machine_planted8_armed_walk.png"
const FOUR: String = "war_machine_armed_walk.png"
## The shipped walk; EIGHT selects the n29 eight-drawing walk (regenerate with --walk).
const WALK: String = FOUR
const SHEET: String = WALK
## p70 SHA-256 cb469ff594124f30c940d3c688eafc1abe7adc76db923b6522f74bcbd5381eaf
const FOUR70: Array[Vector4] = [
	Vector4(-38.5, -0.5, -3, -139.5),
	Vector4(-1.5, -0.5, -3.5, -132.5),
	Vector4(38, -0.5, -3.5, -140.5),
	Vector4(-9, -0.5, -3.5, -136.5),
	Vector4(-38, -0.5, -16.5, -136.5),
	Vector4(-12, -0.5, -17, -129.5),
	Vector4(32, -0.5, -15.5, -137.5),
	Vector4(-18, -0.5, -16, -132.5),
	Vector4(42.5, -0.5, -11.5, -129.5),
	Vector4(24.5, -0.5, 3.5, -133.5),
	Vector4(47.5, -0.5, 5.5, -128.5),
	Vector4(-18.5, -0.5, 1.5, -127.5),
	Vector4(10.5, -0.5, -7, -137.5),
	Vector4(19.5, -0.5, -5.5, -129.5),
	Vector4(-46.5, -0.5, 5, -125.5),
	Vector4(-14.5, -0.5, -3, -121.5),
	Vector4(0.5, -0.5, -1.5, -132.5),
	Vector4(-41.5, -0.5, 2.5, -132.5),
	Vector4(39.5, -0.5, -2.5, -136.5),
	Vector4(9, -0.5, 2.5, -127.5),
]
## p55 SHA-256 8dbc84c2df128711200ef92694b561bd9866728aac42677e864c80f42e9f9b5a
const FOUR55: Array[Vector4] = [
	Vector4(-39.5, -0.5, 0.5, -139.5),
	Vector4(-37.5, -0.5, -0.5, -131.5),
	Vector4(42, -0.5, -2, -138.5),
	Vector4(2.5, -0.5, -1, -129.5),
	Vector4(-45, -0.5, -16.5, -141.5),
	Vector4(-18.5, -0.5, -16, -132.5),
	Vector4(37.5, -0.5, -17, -141.5),
	Vector4(-14, -0.5, -17, -133.5),
	Vector4(27, -0.5, -0.5, -132.5),
	Vector4(17.5, -0.5, -0.5, -134.5),
	Vector4(41.5, -0.5, -0.5, -127.5),
	Vector4(-51.5, -0.5, -0.5, -127.5),
	Vector4(-3, -0.5, -5.5, -137.5),
	Vector4(16.5, -0.5, -7, -137.5),
	Vector4(35.5, -0.5, -0.5, -129.5),
	Vector4(-45.5, -0.5, -1.5, -127.5),
	Vector4(-38.5, -0.5, 1.5, -140.5),
	Vector4(32, -0.5, 0.5, -132.5),
	Vector4(36.5, -0.5, -4, -134.5),
	Vector4(-35, -0.5, 0.5, -127.5),
]
const FOUR_STEP_M: float = StreetQuestCards.STRIDE_M / 4.0
## p70 SHA-256 71e424ac0f347fb534fef07c1461b473420b3475d70ec379c00890923f59238a
const EIGHT70: Array[Vector4] = [
	Vector4(-31, -3.5, -0.5, -137.5),
	Vector4(-30, -3.5, 0, -137.5),
	Vector4(-31, -3.5, -0.5, -137.5),
	Vector4(30, 5.5, -0.5, -137.5),
	Vector4(32, -0.5, 0, -137.5),
	Vector4(31, -0.5, -0.5, -137.5),
	Vector4(31, -0.5, 0, -137.5),
	Vector4(-29, 3.5, -0.5, -137.5),
	Vector4(-28.5, -2.5, 0, -134.5),
	Vector4(-28.5, -2.5, 0, -134.5),
	Vector4(-29.5, -2.5, 0, -134.5),
	Vector4(-35, -5.5, 0, -134.5),
	Vector4(38.5, -1.5, 0, -134.5),
	Vector4(39, -0.5, 0, -134.5),
	Vector4(39.5, -0.5, 0.5, -134.5),
	Vector4(-43, -17.5, 0, -134.5),
	Vector4(39.5, 2.5, 0, -129.5),
	Vector4(16.5, 2.5, 0, -129.5),
	Vector4(-51, -0.5, 0.5, -129.5),
	Vector4(-53.5, -0.5, -0.5, -129.5),
	Vector4(43, 0.5, 0, -129.5),
	Vector4(17, -0.5, 0, -129.5),
	Vector4(34.5, -1.5, 0, -129.5),
	Vector4(-40, -3.5, 0.5, -129.5),
	Vector4(-46, 0.5, 0.5, -128.5),
	Vector4(-46, 0.5, 0.5, -128.5),
	Vector4(35.5, -4.5, 0, -128.5),
	Vector4(-53, 3.5, 0, -128.5),
	Vector4(43.5, -10.5, 0, -128.5),
	Vector4(35.5, -4.5, 0, -128.5),
	Vector4(38.5, -2.5, 0, -128.5),
	Vector4(-53.5, 2.5, 0.5, -128.5),
	Vector4(33, 1.5, 0, -132.5),
	Vector4(32.5, -1.5, 0, -132.5),
	Vector4(-37.5, -5.5, -0.5, -132.5),
	Vector4(-36, -0.5, 0, -132.5),
	Vector4(-35.5, 1.5, 0, -132.5),
	Vector4(-36, 0.5, 0, -132.5),
	Vector4(33.5, -3.5, 0.5, -132.5),
	Vector4(32.5, 0.5, 0, -132.5),
]
## p55 SHA-256 0a94953dac96721576ba315f32e5ab1a0c5741392041e91d259c0ae6df6274fc
const EIGHT55: Array[Vector4] = [
	Vector4(-38, 1.5, 0, -135.5),
	Vector4(-37, -2.5, 0, -135.5),
	Vector4(-38, -2.5, 0, -135.5),
	Vector4(38.5, 1.5, -0.5, -135.5),
	Vector4(42, -0.5, 0.5, -135.5),
	Vector4(39, -2.5, 0, -135.5),
	Vector4(41, -3.5, 0, -135.5),
	Vector4(-40.5, 1.5, 0, -135.5),
	Vector4(-27.5, -0.5, 0, -137.5),
	Vector4(-27.5, -1.5, 0.5, -137.5),
	Vector4(-28.5, -2.5, -0.5, -137.5),
	Vector4(-37.5, -19.5, 0.5, -137.5),
	Vector4(54, 0.5, -0.5, -137.5),
	Vector4(51.5, -0.5, 0.5, -137.5),
	Vector4(50.5, -0.5, -0.5, -137.5),
	Vector4(-39, -13.5, -0.5, -137.5),
	Vector4(31, 0.5, 0, -131.5),
	Vector4(28, 0.5, -0.5, -131.5),
	Vector4(28.5, 0.5, -0.5, -131.5),
	Vector4(-58.5, -5.5, -0.5, -130.5),
	Vector4(32.5, 0.5, 0, -131.5),
	Vector4(29, 0.5, 0, -131.5),
	Vector4(29, 0.5, 0, -131.5),
	Vector4(-59.5, -3.5, -0.5, -130.5),
	Vector4(-35, 1.5, 0, -132.5),
	Vector4(-34, 1.5, 0, -132.5),
	Vector4(-34.5, 1.5, 0, -132.5),
	Vector4(-39, 1.5, 0.5, -132.5),
	Vector4(40, -1.5, -0.5, -132.5),
	Vector4(44, -3.5, 0, -132.5),
	Vector4(43.5, -6.5, 0, -132.5),
	Vector4(-41, 2.5, 0, -132.5),
	Vector4(-37.5, -0.5, 0, -133.5),
	Vector4(-38, -0.5, 0, -133.5),
	Vector4(-37.5, -0.5, 0, -133.5),
	Vector4(-37.5, -0.5, 0, -133.5),
	Vector4(39.5, -0.5, 0, -133.5),
	Vector4(39.5, -0.5, 0, -133.5),
	Vector4(39.5, -0.5, 0, -133.5),
	Vector4(39.5, -0.5, 0, -133.5),
]
const EIGHT_STEP_M: float = 0.3244
const FOUR_ROWS: int = 4
const EIGHT_ROWS: int = 8
## Derived from WALK alone: switching the walk is the one WALK value (n29-11).
const WALK70: Array[Vector4] = EIGHT70 if WALK == EIGHT else FOUR70
const WALK55: Array[Vector4] = EIGHT55 if WALK == EIGHT else FOUR55
const WALK_STEP_M: float = EIGHT_STEP_M if WALK == EIGHT else FOUR_STEP_M
const WALK_ROWS: int = EIGHT_ROWS if WALK == EIGHT else FOUR_ROWS
