class_name RigInput
extends RefCounted
## Copies one RigFeed row into a full rig: velocity, facing, aim, flags, and a clip started this
## tick (punch, roll, death, shoot, hit). The rig moves to the row's position (the sim owns it).

## n7-melee: a strike starts `late` ticks in (pack_strike), so the rig is out at full reach on the
## sim's hit tick, which the hit-stop then holds; `--strike-sync=off` = the before (from 0).
static var strike_sync: bool = not OS.get_cmdline_user_args().has("--strike-sync=off")


static func apply(rig: CutRig, feed: RigFeed, i: int) -> void:
	rig.global_position = feed.pos[i]
	rig.vel_in = feed.vel[i]
	rig.face_to = feed.face[i]
	rig.aim_at = feed.aim[i]
	rig.gun_out = feed.has_flag(i, RigFeed.Flag.GUN_OUT) and not rig.clips.rolling()
	rig.aiming = rig.gun_out and feed.has_flag(i, RigFeed.Flag.AIMING)
	rig.clips.fleeing = feed.has_flag(i, RigFeed.Flag.FLEE)
	rig.clips.down = feed.has_flag(i, RigFeed.Flag.DOWN)
	if feed.has_flag(i, RigFeed.Flag.DEAD):
		rig.clips.die(feed.clip_arg[i] > 0.5)
	match feed.clip[i] as RigClips.Clip:
		RigClips.Clip.PUNCH:
			rig.clips.punch(maxi(1, int(feed.clip_arg[i])))
		RigClips.Clip.ROLL:
			var roll_s: float = feed.clip_arg[i]
			rig.clips.roll(roll_s if roll_s > 0.0 else RigClips.ROLL_S)
		RigClips.Clip.SHOOT:
			rig.clips.shoot(feed.clip_arg[i] if feed.clip_arg[i] != 0.0 else 1.0)
		RigClips.Clip.HIT:
			rig.clips.hit(rig, Vector2.from_angle(feed.clip_arg[i]))
		RigClips.Clip.DEATH:
			rig.clips.die(feed.clip_arg[i] > 0.5)
		RigClips.Clip.STRIKE:
			strike(rig, int(feed.clip_arg[i]))
		_:
			pass


## Packs a strike (ticks of windup, active, recovery < 64 each; arm 0..2; `late` 0..15 = the sim
## ticks of the windup already gone when the view sees it) into one clip_arg float (24 bits: exact
## in a float32).
static func pack_strike(windup: int, active: int, recovery: int, arm: int, late: int = 0) -> float:
	var w: int = clampi(windup, 0, 63)
	var a: int = clampi(active, 0, 63)
	var r: int = clampi(recovery, 0, 63)
	var l: int = clampi(late, 0, 15) << 20
	return float(w | (a << 6) | (r << 12) | (clampi(arm, 0, 3) << 18) | l)


## A melee hit seen `tick_in` ticks into its windup, packed: the windup gone is tick_in + 1 (seen
## one step in, drawn one behind: measured in the arena's claw reel); 0 under --strike-sync=off.
static func pack_hit(h: MeleeHit, arm: int, tick_in: int) -> float:
	var late: int = tick_in + 1 if strike_sync else 0
	return pack_strike(h.windup, h.active, h.recovery, arm, late)


static func strike(rig: CutRig, packed: int) -> void:
	var dt: float = SimClock.TICK_DT
	var w: float = float(packed & 63) * dt
	var a: float = float((packed >> 6) & 63) * dt
	var r: float = float((packed >> 12) & 63) * dt
	rig.clips.strike(rig, w, a, r, (packed >> 18) & 3)
	rig.clips.strike_t = float((packed >> 20) & 15) * dt  # n7-melee: in step with the sim's hit
