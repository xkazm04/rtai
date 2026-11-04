class_name ReelChapters
extends RefCounted
## The director cut's chapters (the 04:00 checkpoint's order): one weapon or one kill each, 4-8 s,
## its victims spawned singly in front of Rivet (metres from his chapter mark, +x is ahead), so a
## signature kill plays alone in the 48 px/m frame. Modes: gun (hold fire), claw (the bare claw
## combo with a gun drawn: melee presses), blade (a carried melee weapon: held fire swings),
## deflect (the plasma sword; the victim shoots, the batted round kills him), tap (one shot per
## ReelDirector.TAP_EVERY ticks).


class Chapter:
	var id: StringName
	var weapon: StringName
	var mode: StringName
	var ticks: int
	var victims: PackedVector2Array
	## The victim keeps shooting (the deflect needs rounds to bat back).
	var shoots: bool = false
	## The victim is a riot cop: armored hp and the shield look.
	var riot: bool = false
	## The victim wears armor under a patrol look: armored hp, no shield (combat-notes).
	var armored: bool = false

	func _init(
		p_id: StringName, p_weapon: StringName, p_mode: StringName, p_ticks: int, p_victims: Array
	) -> void:
		id = p_id
		weapon = p_weapon
		mode = p_mode
		ticks = p_ticks
		victims = PackedVector2Array(p_victims)

	## The caption burned into the corner (derived from the id: no new UI string table).
	func title() -> String:
		return String(id).replace("_", " ").to_upper()


static func all() -> Array[Chapter]:
	var out: Array[Chapter] = [
		Chapter.new(
			&"claw_combo", &"pistol", &"claw", 360, [Vector2(2.4, -0.8), Vector2(3.0, 1.2)]
		),
		Chapter.new(&"pistol", &"pistol", &"gun", 360, [Vector2(5.5, -1.6), Vector2(6.5, 1.4)]),
		Chapter.new(&"machine_pistol", &"machine_pistol", &"gun", 420, _group(6.5)),
		Chapter.new(&"rocket_launcher", &"rocket_launcher", &"gun", 360, [Vector2(7.0, 0.0)]),
		Chapter.new(&"flamethrower", &"flamethrower", &"gun", 420, [Vector2(4.0, 0.0)]),
		Chapter.new(&"electro_gun", &"electro_gun", &"gun", 330, [Vector2(5.0, 0.0)]),
		Chapter.new(&"molotov", &"molotov", &"gun", 420, [Vector2(7.0, 0.0)]),
		Chapter.new(&"katana", &"katana", &"blade", 330, [Vector2(2.6, 0.0)]),
		Chapter.new(&"chainsaw", &"chainsaw", &"blade", 390, [Vector2(2.2, 0.0)]),
		_deflect(),
		Chapter.new(&"hand_cannon", &"hand_cannon", &"gun", 300, [Vector2(6.0, 0.0)]),
		Chapter.new(&"plasma_rifle", &"plasma_rifle", &"gun", 300, [Vector2(6.0, 0.0)]),
		Chapter.new(&"ray_gun", &"ray_gun", &"gun", 300, [Vector2(6.0, 0.0)]),
		Chapter.new(&"homing_shard", &"homing_shard", &"gun", 330, [Vector2(6.0, 1.5)]),
		_riot(),
		Chapter.new(&"mini_nuke", &"mini_nuke", &"gun", 480, _group(15.0)),
		_armored(),
		Chapter.new(&"electro_baton", &"electro_baton", &"blade", 330, [Vector2(2.4, 0.0)]),
	]
	return out


## Four standing staggered in depth `ahead` metres out (the machine pistol's group, the nuke's;
## the 05:20 column fell as one stack).
static func _group(ahead: float) -> Array:
	return [
		Vector2(ahead, -2.4),
		Vector2(ahead + 1.6, -0.8),
		Vector2(ahead + 0.4, 0.9),
		Vector2(ahead + 2.2, 2.5)
	]


static func _deflect() -> Chapter:
	var c: Chapter = Chapter.new(
		&"plasma_sword_deflect", &"plasma_sword", &"deflect", 420, [Vector2(7.0, 0.0)]
	)
	c.shoots = true
	return c


static func _riot() -> Chapter:
	var c: Chapter = Chapter.new(&"riot_cop", &"machine_pistol", &"gun", 420, [Vector2(5.0, 0.0)])
	c.riot = true
	return c


## combat-notes (owner note 2026-11-04): an armored cop takes a plasma bolt and lives, staggers
## with the burn smoking on his chest, and the next bolt holes him (after the cut's numbering).
static func _armored() -> Chapter:
	var c: Chapter = Chapter.new(&"plasma_armored", &"plasma_rifle", &"tap", 300, [Vector2(6.0, 0)])
	c.armored = true
	return c
