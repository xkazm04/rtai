extends SceneTree
## combat-notes dev probe: Rivet's rig alone (no weapon), big: left the night's one-claw hold,
## middle the two-hand hilt grip (CutRig.two_hand_melee), right the same with the off arm hidden.
## It showed why the grip does not read: the off arm has no claw cell, its forearm texture runs
## 434 px (a torch tool) past a 182 px wrist, so a wrist on the hilt still draws the tool across
## the blade. Usage (windowed, d3d12):
## <godot> --rendering-driver d3d12 --path project -s res://dev/combat_notes/hilt_probe.gd
##     -- --out=<png>


func _initialize() -> void:
	var out: String = "user://hilt_probe.png"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
	_run(out)


func _run(out: String) -> void:
	await process_frame
	var rig_s: GDScript = load("res://features/characters/cut_rig.gd")
	var plan_s: GDScript = load("res://features/characters/rivet_plan.gd")
	var var_s: GDScript = load("res://features/characters/rig_variant.gd")
	var rigs: Array[Node2D] = []
	for k: int in 3:
		var holder: Node2D = Node2D.new()
		holder.position = Vector2(220 + k * 420, 400)
		holder.scale = Vector2.ONE * 5.0
		root.add_child(holder)
		var rig: Node2D = rig_s.new()
		holder.add_child(rig)
		rig.call("setup", plan_s.call("build"), var_s.call("rivet"))
		rig.call("snap_facing", 0.0)
		rigs.append(rig)
	for _f: int in 40:
		for k: int in 3:
			var rig: Node2D = rigs[k]
			rig.set("gun_out", true)
			rig.set("two_hand_melee", k > 0)
			rig.set("hilt_dir", Vector2.RIGHT)
			rig.set("face_to", 0.0)
			rig.call("drive", 1.0 / 60.0)
		await process_frame
	_tint(rigs[2])
	await process_frame
	await process_frame
	var img: Image = root.get_texture().get_image()
	var err: int = img.save_png(out)
	printerr("hilt_probe: %d" % err)
	quit(0)


## The off arm hidden (upper, fore, hand), so the probe shows which arm is which.
func _tint(rig: Node2D) -> void:
	var sides: Array = rig.get("sides")
	var plan: Object = rig.get("plan")
	for s: int in 2:
		var gun: int = plan.get("gun_arm")
		var side: Object = sides[s]
		for part: String in ["upper", "fore", "hand"]:
			var spr: CanvasItem = side.get(part)
			if spr != null and s != gun:
				spr.visible = false
