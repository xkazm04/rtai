class_name KingShowcaseRun
extends RigShowcaseRun
## d5-cast: King on the cutout rig in RigShowcaseRun's street (Rivet, two cops, peds through
## CharacterRigs), King standing off Rivet, facing him; shot at the boss-arena zoom (64 px/m)
## and the kill-cam (128 px/m), with the D5 parts tier on (RigDetail). Writes king-<ppm>ppm.png.

const KING_ZOOMS: Array[float] = [1.0, 2.0, 4.0]
const KING_AT_M: Vector2 = Vector2(-3.2, 2.9)

## RivetPlan's form for this run (`--rivet-form=night` = the pre-2026-11-03 scale, A/B frames)
var rivet_form: StringName = RivetPlan.FORM_BASE
## King's scale for this run (`--king-size=1.2`: the owner's smaller-King option, A/B frames)
var king_size: float = KingPlan.SIZE_K
var _king: CutRig = CutRig.new()


func _ready() -> void:
	RivetPlan.form = rivet_form  # before the pool builds Rivet's plan
	super._ready()
	_actors.add_child(_king)
	_king.setup(KingPlan.build(king_size), RigVariant.rivet())
	_king.position = KING_AT_M * PX
	_king.snap_facing((Vector2(0.0, 0.6) - KING_AT_M).angle())  # at Rivet (RigShowcaseRun's spot 0)


func shoot_king() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for z: float in KING_ZOOMS:
		_frame(z)
		_actors.transform.origin -= KING_AT_M * 0.5 * PX * z
		_world.transform.origin = _actors.transform.origin
		for t: int in SETTLE_TICKS:
			_pose(t)
			_rigs.step_ticks(1)
			_king.face_to = (_rigs.feed.pos[0] - _king.position).angle()
			_king.vel_in = Vector2.ZERO
			_king.drive(SimClock.TICK_DT)
			RigDetail.sync(_king)
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		var path: String = out_dir.path_join("king-%dppm.png" % roundi(z * PX))
		ok = img != null and img.save_png(path) == OK and ok
	return 0 if ok else 1
