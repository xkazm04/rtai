class_name PlayerVault
extends RefCounted
## The committed crossing. The stage always collides its grounded circle after resolving bodies.
## It approaches the near face, transfers across at mid-flight, and settles past the far face.
## Start and landing also define the uninterrupted airborne path for the pose.

var enabled: bool = false
var ticks: int
var iframe_from: int
var iframe_to: int
var no_fire: bool
var apex_m: float
var probe: VaultProbe
var hit: VaultProbe.Hit
var start: Vector2
var position: Vector2
## Tick just executed, including the final tick whose next phase is RECOVER.
var frame: int = -1
var owns_move: bool = false
var _radius: float
var _ready: bool = false
var _stations: ArenaStations
var _base: Vector2


func apply_flags() -> void:
	enabled = (enabled or LaunchArgs.has("--vault")) and not LaunchArgs.has("--no-vault")


func configure(t: DataTable) -> Array[String]:
	var row: Dictionary = t.object(t.raw, "vault")
	enabled = row.get("enabled", false) == true
	ticks = t.integer(row, "ticks")
	iframe_from = t.integer(row, "iframe_from")
	iframe_to = t.integer(row, "iframe_to")
	no_fire = row.get("no_fire", true) == true
	apex_m = t.num(row, "apex_m")
	probe = VaultProbe.new(t, row)
	var errors: Array[String] = t.errors()
	if iframe_from > iframe_to or iframe_to >= ticks:
		errors.append("rivet_motion.json: vault i-frames must be ordered and inside ticks")
	return errors


func drive(stage: CollectCallStage, pilot: StagePilot, c: PlayerCommand, walk: float) -> void:
	var motion: PlayerMotion = pilot.motion
	if motion.phase == PlayerMotion.Phase.FREE and c.was_pressed(pilot.actions, &"roll"):
		prepare(stage)
	stage.intent.move_by = motion.step(c, walk, pilot.actions)
	if owns_move:
		stage.arena.rivet.pos = position
		if frame >= 0:
			stage.hidden_in = ""


## Prepare only on a press. Retain the stage's geometry without retaining the stage or pilot.
func prepare(stage: CollectCallStage) -> void:
	if not enabled:
		return
	_bind(stage)
	start = stage.arena.rivet.pos
	_radius = stage.arena.rivet.radius_m
	_ready = true


func reset_tick() -> void:
	frame = -1
	owns_move = false


## A blocked landing consumes the roll press and stops the mover at its current position.
func intercept(motion: PlayerMotion, stick: Vector2) -> bool:
	if not enabled or not _ready:
		return false
	_ready = false
	var mover: TopDownMover = motion.mover
	var heading: Vector2 = stick if stick != Vector2.ZERO else mover.facing
	hit = probe.find(start, _radius, mover.velocity, heading)
	if hit.reason != &"ok" and hit.reason != &"landing_blocked":
		return false
	position = start
	motion.sprinting = false
	owns_move = true
	if hit.reason == &"ok":
		motion.phase = PlayerMotion.Phase.VAULT
		mover.facing = start.direction_to(hit.landing)
	mover.stop()
	return true


func advance(k: int) -> int:
	owns_move = true
	frame = k
	var u: float = float(k + 1) / ticks
	if u < 0.5:
		position = start.lerp(hit.takeoff, 2.0 * u)
	else:
		position = hit.touchdown.lerp(hit.landing, 2.0 * u - 1.0)
	return (k + 1) % ticks


func invulnerable() -> bool:
	return frame >= 0 and frame >= iframe_from and frame <= iframe_to


func write_state(out: StreamPeerBuffer) -> void:
	for p: Vector2 in [start, hit.takeoff, hit.touchdown, hit.landing]:
		out.put_float(p.x)
		out.put_float(p.y)


## Sequential ejection from touching solids can push a circle back into the first one. Keep
## the current footing if even the final body-collision pass would still leave it embedded.
func guard_move(stage: CollectCallStage) -> void:
	if not enabled or stage.intent.move_by == Vector2.ZERO or stage.intent.move_to != Vector2.INF:
		return
	var p: Vector2 = stage.arena.rivet.pos + stage.intent.move_by
	var resolved: Vector2 = stage._collide(p)
	if resolved == p:
		return
	_bind(stage)
	if not probe.clear_at(stage._collide(resolved), stage.arena.rivet.radius_m):
		stage.intent.move_by = Vector2.ZERO


func _bind(stage: CollectCallStage) -> void:
	var arena: ArenaStage = stage as ArenaStage
	if arena != null and (arena.stations != _stations or arena.plan.base != _base):
		_stations = arena.stations
		_base = arena.plan.base
		probe.stations(_stations, _base)
	elif arena == null and _stations != null:
		probe.boxes.clear()
		_stations = null
	if stage.cells == null:
		probe.city = null
	elif probe.city == null or probe.city.cells != stage.cells:
		probe.city = VaultCity.new(stage.cells)
