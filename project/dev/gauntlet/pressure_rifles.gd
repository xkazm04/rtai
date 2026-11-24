class_name PressureRifles
extends RefCounted
## Three staggered firing positions. The 9.5 m takes share one aim and cadence.
## `near()` and `durable` serve the 6 m takes: the shooters stand closer and the salvo changes.
## `durable` (dev take only, never data) gives each shooter and Rivet enough HP to outlast the
## whole take, so every return that reaches a shooter is counted instead of ending the take.

const GUARD_LEAD_TICKS: int = 6
const NEAR_M: float = 6.0

var passed: int = 0
var returned: int = 0
var fired: int = 0
var struck: int = 0
var first_return: int = 0
var distance_m: float = 9.5
var beat_ticks: int = 130
var gap_ticks: int = 24
var salvo: int = 3
var fan_rad: float = 0.32
var reactive: bool = false
## blade6_spaced: one round per beat, the three riflemen in turn, so rounds reach Rivet a whole
## beat (36 ticks) apart, longer than a 33-tick sword swing.
var spaced: bool = false
var _blade: MeleeTable = MeleeTable.weapon(&"plasma_sword")
var _shots: Array[Fighter] = []
var _hp: Array[float] = []
var _session: GauntletSession
var _arena: CombatArena
var _sword: bool
var _tick: int = 0


## The 6 m takes. The guard is the slower one: its meter refills only while lowered, so it
## gets longer salvos and long pauses; the sword has no meter and swings between rounds.
func near(sword: bool, p_spaced: bool = false) -> void:
	spaced = p_spaced
	distance_m = NEAR_M
	fan_rad = 0.5
	reactive = true
	beat_ticks = 36 if sword else 180
	salvo = (1 if spaced else 2) if sword else 6
	gap_ticks = 18 if sword else 9


func place(session: GauntletSession, mark: Vector2, sword: bool, durable: bool = false) -> void:
	_session = session
	_arena = session.stage.arena
	_sword = sword
	@warning_ignore("return_value_discarded")
	DeflectRule.of(_arena).passed.connect(_passed)
	@warning_ignore("return_value_discarded")
	_arena.deflected.connect(_returned)
	if durable:
		_arena.rivet.max_hp = 1.0e6
		_arena.rivet.hp = 1.0e6
	if _sword:
		@warning_ignore("return_value_discarded")
		session.pilot.carry.add(&"plasma_sword")
	for angle: float in [-fan_rad, 0.0, fan_rad]:
		var at: Vector2 = mark + Vector2.RIGHT.rotated(angle) * distance_m
		var cop: Fighter = _arena.spawn_guard(at)
		cop.pos = at
		cop.pursuit = null
		cop.archetype = &"patrol_cop"
		cop.cooldown = ArenaTargets.NEVER
		if durable:
			cop.hp = 1.0e6
			cop.max_hp = 1.0e6
		_shots.append(cop)
		_hp.append(cop.hp)


func drive(input: TickInput, tick: int) -> void:
	# Three riflemen fire in order. The pause between salvos lets Rivet lower his guard.
	var beat: int = posmod(tick - 45, beat_ticks)
	if tick == 2 and _sword:
		input.buttons |= 1 << _session.actions.bit(&"weapon_next")
	if tick >= 45 and beat % gap_ticks == 0 and beat < salvo * gap_ticks:
		@warning_ignore("integer_division")
		var turn: int = fired if spaced else beat / gap_ticks
		var cop: Fighter = _shots[turn % _shots.size()]
		if cop.alive():
			var dir: Vector2 = cop.pos.direction_to(_arena.rivet.pos)
			_arena.shots.append(Shot.fire(cop, dir, _arena.tuning.weapon(&"assault-rifle")))
			cop.cooldown = ArenaTargets.NEVER
			fired += 1
	if _sword:
		_swing(input)
	elif _guard_up(beat, tick):
		input.buttons |= 1 << _session.actions.bit(&"guard")


## After the stage stepped: count each point of HP a returned round took from a shooter.
func observe(tick: int) -> void:
	_tick = tick
	for i: int in _shots.size():
		var left: float = maxf(_shots[i].hp, 0.0)
		struck += roundi((_hp[i] - left) / PlayerDeflect.BACK_DAMAGE)
		_hp[i] = left


func summary() -> Dictionary:
	return {
		"passed": passed,
		"returned": returned,
		"fired": fired,
		"struck": struck,
		"first_return": first_return,
		"breaks": _arena.guard.breaks if _arena != null and _arena.guard != null else -1,
	}


func _guard_up(beat: int, tick: int) -> bool:
	if tick < 45:
		return false
	if not reactive:
		return beat < 69 and posmod(beat, 24) >= 11
	for shot: Shot in _arena.shots:
		if shot.from_rivet or shot.has_meta(PlayerDeflect.PASSED):
			continue
		var gap: float = shot.pos.distance_to(_arena.rivet.pos) - _arena.rivet.radius_m
		if gap / (shot.vel.length() * SimClock.TICK_DT) <= GUARD_LEAD_TICKS:
			return true
	return false


func _swing(input: TickInput) -> void:
	if _session.pilot.melee.busy():
		return
	for shot: Shot in _arena.shots:
		if shot.from_rivet or shot.has_meta(PlayerDeflect.PASSED):
			continue
		var distance: float = shot.pos.distance_to(_arena.rivet.pos) - _blade.deflect_m
		var eta: int = ceili(distance / (shot.vel.length() * SimClock.TICK_DT))
		if eta == _blade.hits[0].windup:
			input.buttons |= 1 << _session.actions.bit(&"fire")
			break


func _passed(_at: Vector2, _dir: Vector2) -> void:
	passed += 1


func _returned(_at: Vector2, _dir: Vector2) -> void:
	returned += 1
	if first_return == 0:
		first_return = _tick + 1
