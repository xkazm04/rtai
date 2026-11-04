class_name RigInput
extends RefCounted
## Copies one RigFeed row into a full rig: velocity, facing, aim, flags, and a clip started this
## tick (punch, roll, death, shoot, hit). The rig moves to the row's position (the sim owns it).


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
			rig.clips.shoot(feed.clip_arg[i] if feed.clip_arg[i] > 0.0 else 1.0)
		RigClips.Clip.HIT:
			rig.clips.hit(rig, Vector2.from_angle(feed.clip_arg[i]))
		RigClips.Clip.DEATH:
			rig.clips.die(feed.clip_arg[i] > 0.5)
		RigClips.Clip.STRIKE:
			strike(rig, int(feed.clip_arg[i]))
		_:
			pass


## Packs a strike (ticks of windup, active, recovery < 64 each; arm 0..2) into one clip_arg float
## (20 bits: exact in a float32).
static func pack_strike(windup: int, active: int, recovery: int, arm: int) -> float:
	var w: int = clampi(windup, 0, 63)
	var a: int = clampi(active, 0, 63)
	var r: int = clampi(recovery, 0, 63)
	return float(w | (a << 6) | (r << 12) | (clampi(arm, 0, 3) << 18))


static func strike(rig: CutRig, packed: int) -> void:
	var dt: float = SimClock.TICK_DT
	var w: float = float(packed & 63) * dt
	var a: float = float((packed >> 6) & 63) * dt
	var r: float = float((packed >> 12) & 63) * dt
	rig.clips.strike(rig, w, a, r, (packed >> 18) & 3)
