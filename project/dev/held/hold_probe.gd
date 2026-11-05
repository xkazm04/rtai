extends SceneTree
## d7-held dev probe: Rivet's rig, big, facing right (+x), with a held weapon placed the way
## RivetHeldView places it (the gun claw's GRIP_U point, the claw's rotation + RigGrip.wrist_turn;
## two-claw kinds on the aim line). One panel per `--holds=` entry (held_classes.json ids),
## `--aim` aims every panel at a point ahead. Usage (windowed, d3d12):
## <godot> --rendering-driver d3d12 --path project -s res://dev/held/hold_probe.gd
##     -- --out=<png> [--holds=blade,long_gun] [--aim] [--weapon=katana]

const GRIP_U: float = 0.62
const PANEL: float = 400.0
const ZOOM: float = 5.0
const HELD_K: float = 1.2


func _initialize() -> void:
	var out: String = "user://hold_probe.png"
	var holds: PackedStringArray = PackedStringArray(["blade"])
	var aim: bool = false
	var weapon: String = "katana"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--holds="):
			holds = arg.substr(8).split(",")
		elif arg.begins_with("--weapon="):
			weapon = arg.substr(9)
		elif arg == "--aim":
			aim = true
	_run(out, holds, aim, weapon)


func _run(out: String, holds: PackedStringArray, aim: bool, weapon: String) -> void:
	await process_frame
	var rig_s: GDScript = load("res://features/characters/cut_rig.gd")
	var plan_s: GDScript = load("res://features/characters/rivet_plan.gd")
	var var_s: GDScript = load("res://features/characters/rig_variant.gd")
	var grip_s: GDScript = load("res://features/characters/rig_grip.gd")
	var table: Object = (load("res://features/player/held_table.gd") as GDScript).call("shipped")
	var tex: Texture2D = load("res://features/combat/weapons/art/%s/held_small.png" % weapon)
	var rigs: Array[Node2D] = []
	var guns: Array[Sprite2D] = []
	for k: int in holds.size():
		rigs.append(_make_rig(k, rig_s, plan_s, var_s))
		guns.append(_make_gun(tex))
	for _f: int in 40:
		for k: int in rigs.size():
			var hold: Object = table.get("holds")[StringName(holds[k])]
			var rig: Node2D = rigs[k]
			rig.set("gun_out", true)
			rig.set("aiming", aim)
			rig.set("aim_at", rig.global_position + Vector2(900, 0))
			rig.set("grip", hold.get("kind"))
			rig.set("hold", StringName(holds[k]))
			rig.set("face_to", 0.0)
			rig.call("drive", 1.0 / 60.0)
		await process_frame
		for k: int in rigs.size():
			_place(rigs[k], guns[k], grip_s, aim)
	await process_frame
	await process_frame
	var img: Image = root.get_texture().get_image()
	var err: int = img.save_png(out)
	printerr("hold_probe: %d" % err)
	quit(0)


func _place(rig: Node2D, gun: Sprite2D, grip_s: GDScript, aim: bool) -> void:
	var plan: Object = rig.get("plan")
	var sides: Array = rig.get("sides")
	var side: Object = sides[plan.get("gun_arm")]
	var hand: Sprite2D = side.get("hand")
	var t: Vector2 = hand.texture.get_size()
	gun.global_position = hand.global_transform * (Vector2(t.x * GRIP_U, t.y * 0.5) + hand.offset)
	gun.global_rotation = hand.global_rotation
	var kind: int = rig.get("grip")
	if aim and kind != 0 and kind != 5:
		var at: Vector2 = rig.get("aim_at")
		gun.global_rotation = (at - gun.global_position).angle()
	if kind == 5:
		gun.global_rotation = grip_s.call("blade_angle", rig)
	gun.global_scale = hand.global_scale.abs() * HELD_K


func _make_rig(k: int, rig_s: GDScript, plan_s: GDScript, var_s: GDScript) -> Node2D:
	var holder: Node2D = Node2D.new()
	holder.position = Vector2(200 + k * PANEL, 400)
	holder.scale = Vector2.ONE * ZOOM
	root.add_child(holder)
	var rig: Node2D = rig_s.new()
	holder.add_child(rig)
	rig.call("setup", plan_s.call("build"), var_s.call("rivet"))
	rig.call("snap_facing", 0.0)
	return rig


func _make_gun(tex: Texture2D) -> Sprite2D:
	var gun: Sprite2D = Sprite2D.new()
	gun.texture = tex
	gun.centered = false
	gun.offset = -Vector2(tex.get_width() * 0.13, tex.get_height() * 0.5)
	gun.z_index = 60
	root.add_child(gun)
	return gun
