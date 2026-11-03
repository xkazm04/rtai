class_name D5WalkRun
extends D5ShowcaseRun
## d5-close: the walk shimmer test. Rivet walks right at 64 px/m; every tick is shot twice from the
## same pose (D4 parts, D5 tier) as a Rivet crop that follows him: <tier>-walk-<tick>.png. Compare
## the frame-to-frame change of the two series: extra change in D5 = shimmer.

const WALK_TICKS: int = 40
const BOX: Vector2 = Vector2(120.0, 120.0)  # at zoom 2.0; scales with walk_zoom

## camera zoom of the walk (1.0 = 32 px/m); d5_walk.gd --zoom
var walk_zoom: float = 2.0


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	_frame_at(walk_zoom)
	for t: int in SETTLE_TICKS + WALK_TICKS:
		_pose(t)
		_walk()
		_follow()
		_rigs.step_ticks(1)
		if t < SETTLE_TICKS:
			await get_tree().process_frame
			continue
		for d5: bool in [false, true]:
			RigDetail.enabled = d5
			_shadow(d5)
			_rigs.step_ticks(0)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			ok = _save_walk("%s-walk-%02d" % ["d5" if d5 else "d4", t - SETTLE_TICKS]) and ok
	RigDetail.enabled = true
	return 0 if ok else 1


func _walk() -> void:
	var f: RigFeed = _rigs.feed
	f.vel[0] = Vector2(64.0, 0.0)
	f.pos[0] += f.vel[0] * SimClock.TICK_DT


## D5_WALK_FOLLOW=1: the camera follows Rivet (as the game camera), so the world moves under him;
## with D5_SUBPX=1 it moves by sub-pixel steps
func _follow() -> void:
	if OS.get_environment("D5_WALK_FOLLOW") == "1":
		cam = _rigs.feed.pos[0]
		_frame_at(walk_zoom)


## D5_WALK_SHADOW=1: the hatched rig shadow (item46b) in the d5 series
func _shadow(d5: bool) -> void:
	if OS.get_environment("D5_WALK_SHADOW") == "1":
		var tier: String = "d5" if d5 else "off"
		D5RigShadow.on_tier(_world, _rigs, 32.0, walk_zoom * 32.0, tier)


func _save_walk(name: String) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	var view: Vector2 = Vector2(img.get_size())
	var at: Vector2 = (view * 0.5 + (_rigs.feed.pos[0] - cam) * walk_zoom).round()
	var box: Vector2 = (BOX * walk_zoom * 0.5).round()
	var r: Rect2i = Rect2i(Vector2i(at - box * 0.5), Vector2i(box))
	return img.get_region(r).save_png(out_dir.path_join(name + ".png")) == OK
