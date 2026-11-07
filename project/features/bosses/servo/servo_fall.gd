class_name ServoFall
extends RefCounted
## Servo's defeat beat on the rig's canvas (docs/bosses/servo.md section 4), timed in sim ticks
## since he went down (ServoMoves.defeated_at): a white flash and a spark burst off the rack, the
## pads spin down and sag in, the body slumps forward with a settling bounce and greys out, the
## head droops, the drones still docked spill off the rack and tumble to the floor, the drones in
## the air crash where they flew (ServoSwarm.ground), and the rack smoulders for good. Render only.

const FLASH_TICKS: int = 5
const SPILL_TICKS: int = 36
const CRASH_TICKS: int = 30
const SPARK_TICKS: int = 24
const GREY: Color = Color(0.6, 0.6, 0.63)
const WIND: Vector2 = Vector2(0.55, -0.85)
## The visor's dying stutter after the flash: cream (no danger now), out for good by VISOR_TICKS.
const VISOR_TICKS: int = 80

var px: float = 32.0
var drone_tex: Texture2D = load(ServoArt.path(&"drone")) as Texture2D
var _pal: PaletteTokens = PaletteTokens.shared()


## The body's scale: slumps to 0.84 with one settling bounce.
static func scale_k(dt: int) -> float:
	return 0.84 + 0.16 * exp(-dt / 14.0) * cos(dt * 0.22)


## Forward slump of the body (metres along the facing): he folds over his legs.
static func slump_m(dt: int) -> float:
	return 0.6 * (1.0 - exp(-dt / 16.0))


## d8: the stood body's lift (ServoArt.stand) as he goes down: it sinks onto the floor (1 .. 0).
static func stand_k(dt: int) -> float:
	return exp(-dt / 16.0)


## How far the pads sag in toward the body (metres) and their scale (dropping to the floor).
static func pad_in_m(dt: int) -> float:
	return 0.5 * (1.0 - exp(-dt / 20.0))


static func pad_k(dt: int) -> float:
	return 1.0 - 0.15 * (1.0 - exp(-dt / 20.0))


## The pads' spin per tick, winding down from the dash rate.
static func spin(dt: int) -> float:
	return 0.9 * exp(-dt / 30.0)


static func head_droop(dt: int) -> float:
	return 0.5 * (1.0 - exp(-dt / 18.0))


static func tint(dt: int) -> Color:
	if dt < FLASH_TICKS:
		return Color(2.0, 2.0, 2.0)
	return Color.WHITE.lerp(GREY, minf(float(dt - FLASH_TICKS) / 90.0, 1.0))


## Docked drones spill off the rack: each tumbles out from its cell and lands 1.8 m beyond.
func spill(c: CanvasItem, rack: ServoRack, dt: int, bays: Array[Vector2]) -> void:
	var u: float = minf(float(dt) / SPILL_TICKS, 1.0)
	var ease_out: float = 1.0 - (1.0 - u) * (1.0 - u)
	for i: int in rack.state.size():
		if rack.state[i] != ServoRack.Cell.FULL:
			continue
		var cell: Vector2 = bays[i]  # where the rig drew the bay (ServoRig._bay_points)
		var out: Vector2 = (cell - rack.origin).normalized()
		var at: Vector2 = cell + out * 1.8 * ease_out
		c.draw_circle(cell * px, 0.26 * px, Color(_pal.color(&"ink_2"), 0.6))  # the bay is empty
		var hop: float = sin(u * PI) * 0.5  # up off the rack, then down
		var spin_r: float = (1.0 if i % 2 == 0 else -1.0) * u * 4.0
		_wreck(c, at, hop, spin_r, u >= 1.0)


## The drones that were flying crash where they were: down from the air onto their shadows.
func crashes(c: CanvasItem, spots: Array[Vector2], dt: int) -> void:
	var u: float = minf(float(dt) / CRASH_TICKS, 1.0)
	for k: int in spots.size():
		var h: float = 1.2 * (1.0 - u * u)
		_wreck(c, spots[k], h, u * 3.0 * (1.0 if k % 2 == 0 else -1.0), u >= 1.0)
		if u >= 1.0 and dt < CRASH_TICKS + 12:  # the dust ring of the impact
			var r: float = 0.4 + 0.06 * (dt - CRASH_TICKS)
			c.draw_arc(spots[k] * px, r * px, 0.0, TAU, 20, Color(_pal.color(&"paper_2"), 0.7), 2.0)


## The spark burst off the rack, then smoke rising from both wings for good.
func smoke(c: CanvasItem, rack: ServoRack, dt: int) -> void:
	var o: Vector2 = rack.origin
	if dt < SPARK_TICKS:
		var a: float = 1.0 - float(dt) / SPARK_TICKS
		for j: int in 12:
			var dir: Vector2 = Vector2.from_angle(TAU * j / 12.0 + 0.3)
			var r0: float = 0.6 + dt * 0.12
			c.draw_line(
				(o + dir * r0) * px, (o + dir * (r0 + 0.5)) * px, Color(1.0, 0.93, 0.7, a), 3.0
			)
	var ramp: float = minf(float(dt) / 40.0, 1.0)
	for j: int in 4:  # one plume, off the wing still on his back (thin: the wrecks must read)
		var ph: float = fmod(dt * 0.012 + j / 4.0, 1.0)
		var src: Vector2 = rack.cell_pos(rack.state.size() - 1)
		var at: Vector2 = src + WIND * ph * 2.6
		var col: Color = Color(_pal.color(&"ink"), 0.45 * (1.0 - ph) * ramp)
		c.draw_circle(at * px, (0.3 + 0.8 * ph) * px, col)


## A drone on its way down (height h metres: the sprite sits above and right of its shadow) or a
## wreck on the floor (darkened).
func _wreck(c: CanvasItem, at: Vector2, h: float, rot: float, down: bool) -> void:
	c.draw_circle((at + ServoDraw.SHADOW * h) * px, 0.33 * px, Color(_pal.color(&"ink"), 0.4))
	var k: float = ServoDraw.DRONE_K * (1.0 + 0.15 * h)
	c.draw_set_transform(at * px, rot, Vector2.ONE * k * px / ServoRig.ART_PPM)
	c.draw_texture(drone_tex, -drone_tex.get_size() * 0.5, GREY if down else Color.WHITE)
	c.draw_set_transform(Vector2.ZERO)


## The visor after the defeat: a cream bar that stutters on and off (a fixed beat, slower and
## dimmer as it dies) and is dark by VISOR_TICKS. Never vermilion: the danger is over.
func visor(c: CanvasItem, at: Vector2, rot: float, dt: int) -> void:
	if dt < FLASH_TICKS or dt >= VISOR_TICKS:
		return
	var u: float = float(dt - FLASH_TICKS) / (VISOR_TICKS - FLASH_TICKS)
	var beat: int = 3 + int(u * 9.0)  # the flicker slows as it dies
	if floori(float(dt) / beat) % 2 == 1:
		return
	var dir: Vector2 = Vector2.from_angle(rot + PI / 2)
	var mid: Vector2 = (at + dir * 0.32) * px
	var half: Vector2 = dir.orthogonal() * 0.25 * px * (1.0 - 0.5 * u)
	c.draw_line(mid - half, mid + half, Color(_pal.color(&"paper"), 1.0 - 0.7 * u), 4.0)
