class_name BossBladeBot
extends InputSource
## n15 combat (the n14 owner call: a blade boss bot, so a real boss fight films the 55-degree
## wind-ups): `--bot=boss --boss=<id> --loadout=pistol --boss-blade=<weapon>` takes that blade
## from the carry once the fight is up (as the director reel does), closes to REACH_M of the boss's
## body and swings (fire) while in reach. Dev only: no dodges (it is there to be filmed swinging,
## not to win); it reads only the sim, so a run replays.

const REACH_M: float = 1.6
## Fire this much past REACH_M (the director reel's blade slack).
const SLACK_M: float = 0.3

var base: BossBot
var weapon: StringName = &""
var _taken: bool = false


## `bot` itself without `--boss-blade`, else wrapped to swing that blade at the boss.
static func wrap(bot: BossBot, args: ArenaArgs) -> InputSource:
	var w: String = args.text("--boss-blade")
	if w == "":
		return bot
	var b: BossBladeBot = BossBladeBot.new()
	b.base = bot
	b.weapon = StringName(w)
	return b


func sample(tick: int) -> TickInput:
	var inp: TickInput = base.sample(tick)
	var hook: BossHook = base.hook
	if hook == null or hook.fight == null:
		return inp
	_take()
	var me: Vector2 = base.stage.arena.rivet.pos
	var to: Vector2 = hook.fight.body.pos - me
	var gap: float = to.length() - hook.fight.body.radius_m
	var aim: Vector2 = to.normalized() if to.length() > 0.01 else Vector2.RIGHT
	var m: Vector2 = (aim if gap > REACH_M else Vector2.ZERO) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, base.actions)
	if gap <= REACH_M + SLACK_M and hook.fight.state != BossFight.State.DEFEATED:
		buttons |= 1 << base.actions.bit(&"fire")
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))


func _take() -> void:
	if _taken:
		return
	_taken = true
	var pilot: StagePilot = base.stage.pilot
	if pilot == null or pilot.carry == null:
		Log.warn("boss", "blade bot: no carry (run with --loadout=pistol); %s not taken" % weapon)
		return
	pilot.carry.take(weapon, base.stage.arena)
	Log.info("boss", "blade bot: %s taken" % weapon)
