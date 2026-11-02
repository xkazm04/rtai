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
	if feed.has_flag(i, RigFeed.Flag.DEAD):
		rig.clips.die(feed.clip_arg[i] > 0.5)
	match feed.clip[i] as RigClips.Clip:
		RigClips.Clip.PUNCH:
			rig.clips.punch(maxi(1, int(feed.clip_arg[i])))
		RigClips.Clip.ROLL:
			rig.clips.roll()
		RigClips.Clip.SHOOT:
			rig.clips.shoot(feed.clip_arg[i] if feed.clip_arg[i] > 0.0 else 1.0)
		RigClips.Clip.HIT:
			rig.clips.hit(rig, Vector2.from_angle(feed.clip_arg[i]))
		RigClips.Clip.DEATH:
			rig.clips.die(feed.clip_arg[i] > 0.5)
		_:
			pass
