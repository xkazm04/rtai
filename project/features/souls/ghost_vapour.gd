class_name GhostVapour
extends RefCounted
## One synchronously generated tile shared by the ribbon and the bridge silhouette.
static var _grain: Texture2D


static func grain() -> Texture2D:
	if _grain == null:
		var noise: FastNoiseLite = FastNoiseLite.new()
		noise.seed = 41731
		noise.frequency = 0.065
		noise.fractal_octaves = 3
		var img: Image = noise.get_seamless_image(128, 128)
		_grain = ImageTexture.create_from_image(img)
	return _grain


## In a front-facing billboard, the rising part of the column overlaps the opaque torso.
## Let the smoke clear the hem first. The authored rise still shows in profile and from behind.
static func hem_drop(width_px: float, rise_m: float, trail: Vector2) -> float:
	var toward: float = maxf(0.0, -trail.normalized().y)
	var rise_px: float = -ViewMode.shared().lift_px(maxf(rise_m, 0.0)).y
	return width_px * 0.15 + rise_px * toward


## Drop below the housing before drifting aft. Both ends stay on the flight chain.
static func hanging_offset(k: float, run: Vector2, drop: float) -> Vector2:
	return (Vector2.DOWN * drop * 0.33 - run * k * 0.22) * sin(k * PI)


static func hem_trail(
	k: float, run: Vector2, down: float, width_px: float, rise_m: float
) -> Vector2:
	var fall: float = hem_drop(width_px, rise_m, run)
	var head_on: float = maxf(0.0, -run.y - absf(run.x))
	var sweep: float = (run.x * 1.1 - head_on * 1.45) * k
	return Vector2(sweep, down * k + sin(k * PI) * fall)
