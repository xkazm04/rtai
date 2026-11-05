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
## rivet-arsenal: this tick's sway of the fire line off the aim (rad; the flamer's hose, else 0).
var sway_rad: float = 0.0
## rivet-arsenal: the molotov's wind-up before the bottle leaves.
var throw: PlayerThrow = PlayerThrow.new()
## Claw hits started (a press that started or chained a hit; the Hauler's stomp is not one).
var melee_swings: int = 0
var car_presses: int = 0
## features/souls: the four ghost forms for the bound player (GhostPilot: Q / LB transforms, G / RB
## picks or switches the ghost); the bot never builds a pilot. hauler (Tonnage), dent, kerf and ohm
## are its attack stages (lane ghost-powers), kept here for the views and the tests.
var ghosts: GhostPilot = GhostPilot.shipped()
var hauler: HaulerStage = ghosts.hauler
var dent: DentStage = ghosts.dent
var kerf: KerfStage = ghosts.kerf
var ohm: OhmStage = ghosts.ohm
## The tick the last input arrived and the tick its first move or claw started (latency probe).
var last_press_tick: int = -1
var _previous: int = 0
## rivet-arsenal: the claw and each carried melee weapon's combo, by weapon id.
var _melees: Dictionary[StringName, PlayerMelee] = {}


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
	_pick_melee()
	if stage.hidden_in != "" and c.move == Vector2.ZERO:
		motion.stop()
	if rivet.alive():
		_move(stage, c)
	else:
		motion.stop()
	if c.was_pressed(actions, &"interact"):
		stage.intent.interact = true
	_fire(stage, c)
	var press: bool = _melee_press(c)
	if _ghosts(stage, c, press):
		return
	var free: bool = motion.phase == PlayerMotion.Phase.FREE
	var down: bool = c.is_held(actions, &"melee") and rivet.alive()
	@warning_ignore("return_value_discarded")
	shock.step(stage.arena, down, free and not melee.busy(), rivet.facing)
	if press and free and not shock.busy():
		var before: int = melee.combo.starts
		melee.combo.press()
		melee_swings += 1 if melee.combo.starts != before or melee.combo.buffered else 0
	melee.combo.holding = _attack_held(c) and rivet.alive()
	stage.intent.move_by += melee.step(stage.arena, false, rivet.facing)
	if c.was_pressed(actions, &"car"):
		car_presses += 1
		Log.info("pilot", "enter/exit car pressed (stub until the vehicles lane's API lands)")


## The ghost forms (features/souls GhostPilot); true when a form owns the melee press this tick
## (the pilot skips the claw).
func _ghosts(stage: CollectCallStage, c: PlayerCommand, press: bool) -> bool:
	if ghosts == null:
		return false
	stage.intent.move_by = ghosts.drive(stage, c, actions, press)
	return ghosts.owns_melee()


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
		throw.write_state(out)
	out.put_32(_previous)
	if ghosts != null:
		ghosts.write_state(out)


## The walk, sprint and roll; a claw hit slows the walk (move_mult), so do spinning barrels (the
## gatling's fire_move_mult), and the roll's i-frames close
## Rivet to damage (CombatArena.damage skips a fighter that is not exposed).
func _move(stage: CollectCallStage, c: PlayerCommand) -> void:
	var rivet: Fighter = stage.arena.rivet
	var walk: float = stage.arena.tuning.rivet["walk_mps"] * melee.move_scale()
	var gun: GunHand = stage.arena.gun
	if gun != null and gun.trigger.spinning():
		walk *= gun.trigger.spec.fire_move_mult  # the gatling's barrels turn: a heavy slow walk
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


## rivet-arsenal: a carried melee weapon (katana, baton) is in the claw.
func wielding() -> bool:
	return carry != null and carry.melee_ids.has(hold.held)


## The melee combo follows the weapon in the claw (the bare claw otherwise); it changes between
## hits only, never inside one.
func _pick_melee() -> void:
	var want: StringName = hold.held if wielding() else MeleeTable.CLAW
	if want == melee.weapon_id or melee.busy():
		return
	_melees[melee.weapon_id] = melee
	if not _melees.has(want):
		_melees[want] = PlayerMelee.new(MeleeTable.weapon(want))
	melee = _melees[want]


## The melee key's press; with a melee weapon drawn, a held fire swings too (held = the combo
## chains, as a mash does). Nothing swings while the weapon is still being drawn.
func _melee_press(c: PlayerCommand) -> bool:
	if not wielding():
		return c.was_pressed(actions, &"melee")
	if not hold.can_fire():
		return false
	return c.was_pressed(actions, &"melee") or c.is_held(actions, &"fire")


## The attack is held down: melee, or a held fire with a melee weapon drawn (the chainsaw grinds).
func _attack_held(c: PlayerCommand) -> bool:
	return c.is_held(actions, &"melee") or (wielding() and c.is_held(actions, &"fire"))


## A held fire shoots along the aim; the flamer's hose sways the line (ArsenalTable.Grip.sway).
func _fire(stage: CollectCallStage, c: PlayerCommand) -> void:
	var armed: bool = hold.can_fire() and not melee.busy() and not shock.busy() and not wielding()
	var grip: ArsenalTable.Grip = hold.table.grip_of(hold.held)
	var firing: bool = c.is_held(actions, &"fire") and c.aim != Vector2.ZERO and armed
	if grip != null and grip.windup_ticks > 0:  # the molotov: wind up, then the bottle leaves
		var gun: GunHand = stage.arena.gun
		var ready: bool = gun != null and gun.trigger.cooldown == 0 and not gun.trigger.reloading()
		var at: Vector2 = throw.step(grip.windup_ticks, firing, armed, ready, c.aim)
		if at != Vector2.ZERO:
			stage.intent.fire_at = stage.arena.rivet.pos + at * _reach(stage, c)
		return
	sway_rad = grip.sway(stage.tick) if firing and grip != null else 0.0
	if firing:
		stage.intent.fire_at = stage.arena.rivet.pos + c.aim.rotated(sway_rad) * actions.aim_range_m


## How far along the aim the fire point sits: a thrown weapon lands where the cursor was (lane
## gunplay, rivet-arsenal REQUEST 12); everything else aims aim_range_m out (direction only).
func _reach(stage: CollectCallStage, c: PlayerCommand) -> float:
	var gun: GunHand = stage.arena.gun
	if c.aim_m > 0.0 and gun != null and gun.trigger.spec.kind == WeaponSpec.Kind.THROWN:
		return c.aim_m
	return actions.aim_range_m
