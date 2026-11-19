class_name PlayerVault
extends RefCounted
## The committed crossing uses the same eased world position for combat, collision and the rig.
## Only contact with the selected low obstacle may bypass the stage's ground collision pass.

var enabled: bool = false
var drawn_cells: bool = true
var bodies_block_landing: bool
var ticks: int
var iframe_from: int
var iframe_to: int
var no_fire: bool
var top_scale: float
var apex_m: float
var probe: VaultProbe
var hit: VaultProbe.Hit
var start: Vector2
var position: Vector2
## Tick just executed, including the final tick whose next phase is RECOVER.
var frame: int = -1
var owns_move: bool = false
var _body: Fighter
var _radius: float
var _ready: bool = false
var _landing_arena: CombatArena
var _stations: ArenaStations
var _base: Vector2


func apply_flags() -> void:
	enabled = (enabled or LaunchArgs.has("--vault")) and not LaunchArgs.has("--no-vault")


func configure(t: DataTable) -> Array[String]:
	var row: Dictionary = t.object(t.raw, "vault")
	enabled = row.get("enabled", false) == true
	bodies_block_landing = row.get("bodies_block_landing", false) == true
	drawn_cells = row.get("drawn_cells", true) == true
	ticks = t.integer(row, "ticks")
	iframe_from = t.integer(row, "iframe_from")
	iframe_to = t.integer(row, "iframe_to")
	no_fire = row.get("no_fire", true) == true
	top_scale = t.num(row, "top_scale")
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
	_ready = false
	_landing_arena = null
	if owns_move:
		stage.arena.rivet.pos = position
		if frame >= 0:
			stage.hidden_in = ""


## Prepare only on a press. Retain the stage's geometry without retaining the stage or pilot.
func prepare(stage: CollectCallStage) -> void:
	if not enabled:
		return
	bind_solids(stage)
	_body = stage.arena.rivet
	start = _body.pos
	_radius = _body.radius_m
	_landing_arena = stage.arena if bodies_block_landing else null
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
	if (
		_landing_arena != null
		and hit.reason == &"ok"
		and VaultProbe.landing_occupied(_landing_arena, hit.landing)
	):
		hit.reason = &"landing_blocked"
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
	position = start.lerp(hit.landing, smoothstep(0.0, 1.0, u))
	return (k + 1) % ticks


## Read the fighter after body resolution as collision can displace him from the sampled path.
func airborne() -> bool:
	return frame >= 0 and (probe.contacts(_body.pos, _radius, hit) & VaultProbe.Contact.TARGET) != 0


## Combat runs after the pilot. A lethal hit or a body blocking the path into another solid
## interrupts now, before the stage decides whether to skip its ground collision.
func airborne_after_contacts(motion: PlayerMotion) -> bool:
	if frame < 0:
		return false
	if not _body.alive() or (_body.pos != position and _touches_other_solid()):
		motion.stop()
		return false
	return airborne()


func interrupt() -> void:
	if frame >= 0:
		position = hit.landing
		_body.pos = position
		_body.exposed = true
	_ready = false
	reset_tick()


## Parabolic visual lift, normalized to reach one on the middle tick of any multi-tick vault.
func lift() -> float:
	if frame < 0 or ticks < 2:
		return 0.0
	var elapsed: int = frame + 1
	var middle: int = ticks >> 1
	return float(elapsed * (ticks - elapsed)) / (middle * (ticks - middle))


func invulnerable() -> bool:
	return frame >= 0 and frame >= iframe_from and frame <= iframe_to


func write_state(out: StreamPeerBuffer, phase: PlayerMotion.Phase) -> void:
	if phase != PlayerMotion.Phase.VAULT:
		return
	out.put_u8(1 if hit.city_prop != null else 0)
	out.put_float(_radius)
	for p: Vector2 in [start, hit.landing, hit.box.position, hit.box.size]:
		out.put_float(p.x)
		out.put_float(p.y)


## Sequential ejection from touching solids can push a circle back into the first one. Keep
## the current footing if even the final body-collision pass would still leave it embedded.
func guard_move(stage: CollectCallStage) -> void:
	if not enabled or stage.intent.move_by == Vector2.ZERO or stage.intent.move_to != Vector2.INF:
		return
	var p: Vector2 = stage.arena.rivet.pos + stage.intent.move_by
	var resolved: Vector2 = stage.collide_preview(p)
	if resolved == p:
		return
	bind_solids(stage)
	if not probe.clear_at(stage.collide_preview(resolved), stage.arena.rivet.radius_m):
		stage.intent.move_by = Vector2.ZERO


func _touches_other_solid() -> bool:
	return (probe.contacts(_body.pos, _radius, hit) & VaultProbe.Contact.OTHER) != 0


func bind_solids(stage: CollectCallStage) -> void:
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
