class_name CrowdBaker
extends Node
## Renders CrowdAtlas at load: one real rig per crowd look in an offscreen SubViewport, posed
## through every clip on the fixed tick and captured frame by frame into one atlas image
## (25 captures, then the viewport and the rigs are freed). Headless (no GPU) it leaves the
## atlas unbaked; the layout and the clip table do not depend on it.
## Await bake(): it spans about 30 rendered frames, at load only (never in play).

const TICK: float = 1.0 / 60.0

var _rigs: Array[CutRig] = []
var _vp: SubViewport = null
var _image: Image = null
var _cell: int = CrowdAtlas.CELL_PX
## The D5 twin's own overlay materials (plain, hit tint): RigDetail's are shared with the live
## rigs, whose per-frame set_view would fade them out mid-bake.
var _d5_mats: Array[ShaderMaterial] = []


## A D5 atlas (CrowdAtlas.make_d5) bakes with CrowdBakeDetail overlays at full on every rig.
func bake(atlas: CrowdAtlas) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var saved_zoom: float = PartMaterials.view_px / CutRig.SC
	_cell = atlas.cell_px
	if atlas.d5:
		_d5_mats = CrowdBakeDetail.materials(atlas.bake_zoom)
	PartMaterials.set_view(atlas.bake_zoom)
	_make_stage(atlas.bake_zoom)
	var cell: int = _cell
	_image = Image.create_empty(
		CrowdAtlas.cols() * cell, CrowdAtlas.rows() * cell, false, Image.FORMAT_RGBA8
	)
	for c: int in CrowdAtlas.CLIPS:
		_start_clip(c as CrowdAtlas.Clip)
		var at: float = 0.0
		for f: int in CrowdAtlas.FRAMES[c]:
			var want: float = _frame_time(c as CrowdAtlas.Clip, f)
			_advance(want - at)
			at = want
			await RenderingServer.frame_post_draw
			_capture(CrowdAtlas.CLIP_FIRST[c] + f)
	atlas.texture = ImageTexture.create_from_image(_image)
	atlas.baked = true
	_vp.queue_free()
	_rigs.clear()
	PartMaterials.set_view(saved_zoom)


func _make_stage(zoom: float) -> void:
	var cell: int = _cell
	_vp = SubViewport.new()
	_vp.size = Vector2i(CrowdAtlas.LOOKS * cell, cell)
	_vp.transparent_bg = true
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_vp)
	_vp.canvas_transform = Transform2D.IDENTITY.scaled(Vector2.ONE * zoom)
	for look: int in CrowdAtlas.LOOKS:
		var v: RigVariant = RigVariant.crowd(look)
		var rig: CutRig = CutRig.new()
		_vp.add_child(rig)
		rig.setup(RigPool.plan_of(v.kind), v)
		_rigs.append(rig)


func _centre(look: int) -> Vector2:
	var w: float = CrowdAtlas.cell_world_px()
	return Vector2((look + 0.5) * w, 0.55 * w)


func _start_clip(c: CrowdAtlas.Clip) -> void:
	for look: int in _rigs.size():
		var rig: CutRig = _rigs[look]
		rig.global_position = _centre(look)
		rig.reset_state(0.0)
		var run: bool = c == CrowdAtlas.Clip.FLEE
		rig.vel_in = Vector2(CutRig.RUN_SPEED if run else CutRig.WALK_SPEED, 0.0)
		if c != CrowdAtlas.Clip.WALK and c != CrowdAtlas.Clip.FLEE:
			rig.vel_in = Vector2.ZERO
		rig.clips.fleeing = run
		rig.gun_out = c == CrowdAtlas.Clip.SHOOT and rig.plan.gun_arm >= 0
		rig.aiming = rig.gun_out
		rig.aim_at = rig.global_position + Vector2(400.0, 0.0)
		match c:
			CrowdAtlas.Clip.HIT:
				rig.clips.hit(rig, Vector2.RIGHT)
			CrowdAtlas.Clip.DEATH:
				rig.clips.die(false)
			CrowdAtlas.Clip.SHOOT:
				rig.clips.shoot(1.0)
	_advance(0.6 if c == CrowdAtlas.Clip.WALK or c == CrowdAtlas.Clip.FLEE else 0.0)


static func _frame_time(c: CrowdAtlas.Clip, f: int) -> float:
	var t: float = (f + 0.5) / CrowdAtlas.FPS[c]
	if c == CrowdAtlas.Clip.DEATH:
		t = (f + 1.0) / CrowdAtlas.FPS[c]
	return t


## Drives every rig on the fixed tick; walkers stay in their cell (a treadmill: the body and its
## planted feet shift back together, so the gait is the real one).
func _advance(seconds: float) -> void:
	for _k: int in roundi(seconds / TICK):
		for look: int in _rigs.size():
			var rig: CutRig = _rigs[look]
			rig.global_position += rig.vel_in * TICK
			rig.drive(TICK)
			var back: Vector2 = _centre(look) - rig.global_position
			rig.global_position += back
			for side: RigLimbs in rig.sides:
				side.foot_w += back
				side.foot_from += back
			for i: int in rig.hose_pts.size():
				rig.hose_pts[i] += back
				rig.hose_prev[i] += back
	if not _d5_mats.is_empty():
		for rig: CutRig in _rigs:
			CrowdBakeDetail.sync(rig, _d5_mats)


func _capture(col: int) -> void:
	var cell: int = _cell
	var shot: Image = _vp.get_texture().get_image()
	if shot == null or shot.is_empty():
		return
	shot.convert(Image.FORMAT_RGBA8)
	for look: int in CrowdAtlas.LOOKS:
		var src: Rect2i = Rect2i(look * cell, 0, cell, cell)
		_image.blit_rect(shot, src, Vector2i(col * cell, look * cell))
