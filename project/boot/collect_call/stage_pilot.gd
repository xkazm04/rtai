class_name StagePilot
extends RefCounted
## The player at quest 1's stage (and the arena's, and the city block's): each tick's TickInput
## (live devices or a replay log, never raw keys) decoded into StageIntent. The move stick drives
## PlayerMotion (rivet_motion.json over TopDownMover: the walk, the held sprint, the dodge roll
## with its i-frames), a held fire shoots along the aim heading, an interact press uses whatever
## is in reach (StageActions), melee is the claw combo (PlayerMelee over rivet_melee.json), and
## the car key is a stub until the vehicles lane's enter/exit API lands.

var actions: PlayerActions
var motion: PlayerMotion = PlayerMotion.shipped()
var melee: PlayerMelee = PlayerMelee.new()
## rivet-arsenal: hold melee after the jab to charge the electroshock, release to discharge.
var shock: PlayerShock = PlayerShock.shipped()
## rivet-arsenal: the weapon in the claw follows the arena's rivet.weapon with a stow and a draw
## (rivet_arsenal.json); no shot leaves before the draw ends.
var hold: WeaponHold = WeaponHold.new()
## rivet-arsenal: the carried guns and the switch keys (null: quest 1 keeps its own weapons).
var carry: RivetCarry = null
## Claw hits started (a press that started or chained a hit; the Hauler's stomp is not one).
var melee_swings: int = 0
var car_presses: int = 0
## features/souls: the Hauler for the bound player (Q / LB); the bot never builds a pilot.
var hauler: HaulerStage = HaulerStage.shipped()
## The tick the last input arrived and the tick its first move or claw started (latency probe).
var last_press_tick: int = -1
var _previous: int = 0


func _init(p_actions: PlayerActions) -> void:
	actions = p_actions


## Fills the stage's intent for this tick from `input`.
func drive(stage: CollectCallStage, input: TickInput) -> void:
	var c: PlayerCommand = PlayerCommand.decode(input, _previous, actions)
	_previous = input.buttons
	if c.pressed != 0:
		last_press_tick = stage.tick
	var rivet: Fighter = stage.arena.rivet
	if carry != null and rivet.alive():
		carry.step(c, actions, stage.arena)
	_follow_weapon(rivet.weapon)
	if stage.hidden_in != "" and c.move == Vector2.ZERO:
		motion.stop()
	if rivet.alive():
		_move(stage, c)
	else:
		motion.stop()
	if c.was_pressed(actions, &"interact"):
		stage.intent.interact = true
	var armed: bool = hold.can_fire() and not melee.busy() and not shock.busy()
	if c.is_held(actions, &"fire") and c.aim != Vector2.ZERO and armed:
		stage.intent.fire_at = rivet.pos + c.aim * actions.aim_range_m
	var press: bool = c.was_pressed(actions, &"melee")
	if hauler != null:
		var power: bool = c.was_pressed(actions, &"power_hauler")
		stage.intent.move_by = hauler.drive(stage, power, press, stage.intent.move_by)
		if hauler.owns_melee():
			return
	var free: bool = motion.phase == PlayerMotion.Phase.FREE
	var down: bool = c.is_held(actions, &"melee") and rivet.alive()
	@warning_ignore("return_value_discarded")
	shock.step(stage.arena, down, free and not melee.busy(), rivet.facing)
	if press and free and not shock.busy():
		var before: int = melee.combo.starts
		melee.combo.press()
		melee_swings += 1 if melee.combo.starts != before or melee.combo.buffered else 0
	stage.intent.move_by += melee.step(stage.arena, false, rivet.facing)
	if c.was_pressed(actions, &"car"):
		car_presses += 1
		Log.info("pilot", "enter/exit car pressed (stub until the vehicles lane's API lands)")


func facing() -> Vector2:
	return motion.facing()


## Kept for the dev arena's teleport and older hosts: the walk under PlayerMotion.
func stop() -> void:
	motion.stop()


func write_state(out: StreamPeerBuffer) -> void:
	motion.write_state(out)
	melee.write_state(out)
	shock.write_state(out)
	hold.write_state(out)
	if carry != null:
		carry.write_state(out)
	out.put_32(_previous)
	if hauler != null:
		hauler.write_state(out)


## The walk, sprint and roll; a claw hit slows the walk (move_mult) and the roll's i-frames close
## Rivet to damage (CombatArena.damage skips a fighter that is not exposed).
func _move(stage: CollectCallStage, c: PlayerCommand) -> void:
	var rivet: Fighter = stage.arena.rivet
	var walk: float = stage.arena.tuning.rivet["walk_mps"] * melee.move_scale()
	var aim: Vector2 = c.aim
	if melee.busy() and aim == Vector2.ZERO:
		c.aim = motion.facing()  # a swing holds the heading it started on
	stage.intent.move_by = motion.step(c, walk, actions)
	c.aim = aim
	rivet.facing = motion.facing()
	rivet.exposed = not motion.invulnerable()


## Starts a stow and draw when the arena changed Rivet's weapon (a pickup, the rifle running dry).
func _follow_weapon(weapon: StringName) -> void:
	var coming: StringName = hold.pending if hold.state == WeaponHold.State.STOWING else hold.held
	if weapon != coming:
		@warning_ignore("return_value_discarded")
		hold.equip(weapon)
	hold.step()
