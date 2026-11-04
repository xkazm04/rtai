class_name StagePilot
extends RefCounted
## The player at quest 1's stage: each tick's TickInput (live devices or a replay log, never raw
## keys) decoded into StageIntent. The move stick drives a TopDownMover (acceleration, turn rate,
## strafe), a held fire shoots along the aim heading, an interact press uses whatever is in reach
## (StageActions), melee is Rivet's electroshock jab, and the car key is a stub until the
## vehicles lane's enter/exit API lands (JOURNAL REQUEST 1 -> vehicles).

const MELEE_REACH_M: float = 1.6
const MELEE_CONE_DOT: float = 0.5
const MELEE_DAMAGE: float = 1.0
const MELEE_COOLDOWN_TICKS: int = 30

var actions: PlayerActions
var mover: TopDownMover = TopDownMover.new()
var melee_cooldown: int = 0
var melee_swings: int = 0
var car_presses: int = 0
## features/souls: the Hauler for the bound player (Q / LB); the bot never builds a pilot.
var hauler: HaulerStage = HaulerStage.shipped()
var _previous: int = 0


func _init(p_actions: PlayerActions) -> void:
	actions = p_actions


## Fills the stage's intent for this tick from `input`.
func drive(stage: CollectCallStage, input: TickInput) -> void:
	var c: PlayerCommand = PlayerCommand.decode(input, _previous, actions)
	_previous = input.buttons
	var walk: float = stage.arena.tuning.rivet["walk_mps"]
	if stage.hidden_in != "" and c.move == Vector2.ZERO:
		mover.stop()
	if stage.arena.rivet.alive():
		stage.intent.move_by = mover.step(c.move, c.aim, walk, actions)
		stage.arena.rivet.facing = mover.facing
	else:
		mover.stop()
	if c.was_pressed(actions, &"interact"):
		stage.intent.interact = true
	if c.is_held(actions, &"fire") and c.aim != Vector2.ZERO:
		stage.intent.fire_at = stage.arena.rivet.pos + c.aim * _reach(stage, c)
	melee_cooldown = maxi(melee_cooldown - 1, 0)
	if hauler != null:
		var melee: bool = c.was_pressed(actions, &"melee")
		var power: bool = c.was_pressed(actions, &"power_hauler")
		stage.intent.move_by = hauler.drive(stage, power, melee, stage.intent.move_by)
		if hauler.owns_melee():
			return
	if c.was_pressed(actions, &"melee") and melee_cooldown == 0:
		_jab(stage, c.aim if c.aim != Vector2.ZERO else mover.facing)
	if c.was_pressed(actions, &"car"):
		car_presses += 1
		Log.info("pilot", "enter/exit car pressed (stub until the vehicles lane's API lands)")


func facing() -> Vector2:
	return mover.facing


func write_state(out: StreamPeerBuffer) -> void:
	mover.write_state(out)
	out.put_32(melee_cooldown)
	out.put_32(_previous)
	if hauler != null:
		hauler.write_state(out)


## The electroshock jab: every exposed hostile in a cone in front, within reach, takes a hit.
func _jab(stage: CollectCallStage, heading: Vector2) -> void:
	melee_cooldown = MELEE_COOLDOWN_TICKS
	melee_swings += 1
	var at: Vector2 = stage.arena.rivet.pos
	for h: Fighter in stage.arena.hostiles:
		var to: Vector2 = h.pos - at
		if h.alive() and to.length() <= MELEE_REACH_M + h.radius_m:
			if to.normalized().dot(heading) >= MELEE_CONE_DOT:
				stage.arena.damage(h, MELEE_DAMAGE, stage.arena.rivet.id, &"shock")


## How far along the aim the fire point sits: a thrown weapon lands where the cursor was (lane
## gunplay, rivet-arsenal REQUEST 12); everything else aims aim_range_m out (direction only).
func _reach(stage: CollectCallStage, c: PlayerCommand) -> float:
	var gun: GunHand = stage.arena.gun
	if c.aim_m > 0.0 and gun != null and gun.trigger.spec.kind == WeaponSpec.Kind.THROWN:
		return c.aim_m
	return actions.aim_range_m
