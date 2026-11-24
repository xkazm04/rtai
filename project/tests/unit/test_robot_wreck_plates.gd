extends GutTest
## The thug and the gunner wreck as themselves: the plates on the wreck are copies of each
## robot's own live torso and head, never the shield robot's or the turret's.


func _tex(color: Color) -> Texture2D:
	return ImageTexture.create_from_image(_image(color))


func _image(color: Color) -> Image:
	var img: Image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return img


func _rig(torso: Texture2D, head: Texture2D) -> CutRig:
	var rig: CutRig = CutRig.new()
	var holder: Node2D = Node2D.new()
	add_child_autofree(holder)
	holder.add_child(rig)
	rig.setup(FoeLooks.robot_plan(&"robot_thug", ThugPlan.build(), rig), RigVariant.rivet())
	rig.torso_spr.texture = torso
	rig.head_spr.texture = head
	return rig


func _wreck(victim: StringName, rig: CutRig) -> ElectricWreckFx:
	var rows: SignatureKillTable = SignatureKillTable.load_table()
	var kills: SignatureKills = SignatureKills.new(rows, RngRegistry.new(82).stream(&"brutality"))
	var row: SignatureKill = rows.shutdown(victim, &"claw_shock")
	var wreck: ElectricWreckFx = autofree(ElectricWreckFx.for_row(row, rig))
	var body: Node2D = GibCut.cut(rig, true)[SignatureKill.BODY]
	@warning_ignore("return_value_discarded")
	wreck.mount_body(body, row, kills, 32.0, Vector2.RIGHT)
	return wreck


func _textures(wreck: ElectricWreckFx) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	for z: int in [25, 26]:
		for node: Node in wreck.chassis.find_children("*", "Sprite2D", true, false):
			if (node as Sprite2D).z_index == z:
				out.append((node as Sprite2D).texture)
	return out


func test_each_robot_wrecks_from_its_own_torso_and_head() -> void:
	var thug: Array[Texture2D] = [_tex(Color.DARK_SLATE_GRAY), _tex(Color.SADDLE_BROWN)]
	var gunner: Array[Texture2D] = [_tex(Color.NAVY_BLUE), _tex(Color.DARK_ORANGE)]
	var a: Array[Texture2D] = _textures(_wreck(&"robot_thug", _rig(thug[0], thug[1])))
	var b: Array[Texture2D] = _textures(_wreck(&"robot_gunner", _rig(gunner[0], gunner[1])))
	assert_true(a.has(thug[0]) and a.has(thug[1]), "thug plates are the thug's own")
	assert_true(b.has(gunner[0]) and b.has(gunner[1]), "gunner plates are the gunner's own")
	assert_false(a.has(gunner[0]) or b.has(thug[0]), "the two wrecks share no plate")


func test_no_robot_wreck_borrows_the_shield_or_turret_plate() -> void:
	var rig: CutRig = _rig(_tex(Color.GRAY), _tex(Color.BLACK))
	for victim: StringName in [&"robot_thug", &"robot_gunner"]:
		var plates: Array[Texture2D] = _textures(_wreck(victim, rig))
		assert_false(plates.has(FoeShieldView.TORSO))
		assert_false(plates.has(FoeTurretView.HEAD))
		assert_eq(plates.size(), 2)


func test_a_rig_without_the_textures_keeps_the_borrowed_plates() -> void:
	var body: Node2D = autofree(Node2D.new())
	assert_eq(ElectricChassis.own_plates(body, _tex(Color.RED), _tex(Color.BLUE)).size(), 0)
	assert_eq(ElectricChassis.own_plates(body, null, null).size(), 0)


func _fitted(side: float) -> Array[Sprite2D]:
	var chassis: Node2D = autofree(Node2D.new())
	var plates: Array[Sprite2D] = []
	for color: Color in [Color.RED, Color.BLUE]:
		var spr: Sprite2D = Sprite2D.new()
		spr.texture = _tex(color)
		plates.append(spr)
	ElectricChassis.fit_own(chassis, plates, 32.0, 0.4, side)
	return plates


func test_plates_are_sized_stacked_and_placed_on_the_chest() -> void:
	var plates: Array[Sprite2D] = _fitted(1.0)
	var core: Sprite2D = plates[0]
	var cap: Sprite2D = plates[1]
	assert_almost_eq(core.get_rect().size.x * core.scale.x, 0.91 * 32.0, 0.01, "chest plate width")
	assert_almost_eq(cap.get_rect().size.x * cap.scale.x, 0.49 * 32.0, 0.01, "optic cap width")
	assert_eq(core.z_index, 25)
	assert_eq(cap.z_index, 26, "the cap over the chest plate")
	assert_eq(core.position, Vector2.UP * 0.4 * 32.0)
	assert_eq(cap.position, core.position + Vector2(0.04, -0.28) * 32.0, "the cap sits up-right")
	assert_eq(core.get_parent(), cap.get_parent(), "both on the chassis")


func test_the_cap_offset_mirrors_with_the_side() -> void:
	var plates: Array[Sprite2D] = _fitted(-1.0)
	assert_almost_eq(plates[1].position.x - plates[0].position.x, -0.04 * 32.0, 0.001)
