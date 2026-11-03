extends SceneTree
## rivet-motion: how far Rivet's feet show past his torso while walking and running, per
## gait_scale (headless). Prints one JSON line: for each scale and speed, the max foot reach
## ahead of or behind the body centre (m) along the walk, over the second of two seconds.
## Usage: <godot> --headless --path project -s res://dev/rivet_motion/stride_probe.gd

const SCALES: Array[float] = [1.0, 1.3, 1.6]
const SPEEDS_MPS: Array[float] = [1.6, 4.5, 5.6]


func _initialize() -> void:
	var out: Dictionary = {}
	for k: float in SCALES:
		for mps: float in SPEEDS_MPS:
			out["g%.1f_v%.1f" % [k, mps]] = _probe(k, mps)
	printerr("stride_probe: " + JSON.stringify(out))
	quit(0)


func _probe(k: float, mps: float) -> Dictionary:
	var plan: Object = (load("res://features/characters/rivet_plan.gd") as GDScript).call("build")
	plan.set("gait_scale", k)
	var rig: Node2D = (load("res://features/characters/cut_rig.gd") as GDScript).new()
	root.add_child(rig)
	var look: Object = (load("res://features/characters/rig_variant.gd") as GDScript).call("rivet")
	rig.call("setup", plan, look)
	rig.call("snap_facing", 0.0)
	var v: Vector2 = Vector2(mps * 32.0, 0.0)
	var reach: float = 0.0
	for t: int in 240:
		rig.position += v / 60.0
		rig.set("vel_in", v)
		rig.set("face_to", 0.0)
		rig.call("drive", 1.0 / 60.0)
		if t < 120:
			continue
		var sides: Array = rig.get("sides")
		for s: int in 2:
			var side: Object = sides[s]
			var f: Vector2 = side.get("foot_w")
			reach = maxf(reach, absf(f.x - rig.position.x))
	rig.queue_free()
	return {"foot_m": snappedf(reach / 32.0, 0.01)}
