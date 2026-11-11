class_name KillXray
extends RefCounted
## n16 kills-polish (DEFECTS ranking #2): where the electro X-ray skeleton (KillShockFx) stands. It
## stands where the body stood, its feet on the body's feet (KillView places a body at its ground
## point) and FOOT_M below them, so it reads as HIS X-ray, not a sticker lying beside him.
## `--shock-xray=lie` = the before (turned along the shot, centred on the feet).

const FOOT_M: float = 0.05

static var _lie: int = -1


## The skeleton's centre for a body whose feet are at `feet`: half of `height_m` above them (the
## feet themselves when lying).
static func mid(feet: Vector2, height_m: float, ppm: float) -> Vector2:
	if lies():
		return feet
	return feet + Vector2(0.0, (FOOT_M - height_m * 0.5) * ppm)


## True under `--shock-xray=lie` (the skeleton turned along the shot: the before).
static func lies() -> bool:
	if _lie < 0:
		_lie = 1 if ArenaArgs.parse().text("--shock-xray") == "lie" else 0
	return _lie == 1
