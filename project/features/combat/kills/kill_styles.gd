class_name KillStyles
extends Node2D
## The per-style overlays of the signature kills (lane brutality), render only, one place for the
## style dispatch KillView used to carry: how a kill's rig is cut (gib or whole body, the blade's
## halves, the plasma hole, the ray gun's wrap) and which overlay takes the body after (the burn
## char and the nuke's shadow, the electro X-ray, the blade streak, the dissolve, the shard burst).
## Children keep KillView's z order (this node sits at z 0, relative). No RNG.

## The burn char (smoke, embers, ash flakes) over the burnt bodies; the nuke's shadows.
var char_fx: KillCharFx = KillCharFx.new()
## The electro kill (convulsion, X-ray flash, stiff drop, collar smoke).
var shock_fx: KillShockFx = KillShockFx.new()
## The blade kill's slash streak (the halves themselves are KillSplitFx.cut groups).
var split_fx: KillSplitFx = KillSplitFx.new()
## The ray gun kill (the body eaten by rings into a glowing dust pile and its empty clothes).
var dissolve_fx: KillDissolveFx = KillDissolveFx.new()
## The homing shard kill (shards stuck in the frozen body, the red mist at the pop).
var burst_fx: KillBurstFx = KillBurstFx.new()

## The plasma kills' bodies (the topple).
var _holes: Array[KillHoleFx.Topple] = []
var _kills: SignatureKills = null
var _ppm: float = 32.0


func bind(kills: SignatureKills, ppm: float, reduced_motion: bool) -> void:
	_kills = kills
	_ppm = ppm
	for fx: Node2D in [char_fx, shock_fx, split_fx, dissolve_fx]:
		fx.set(&"kills", kills)
		fx.set(&"ppm", ppm)
		fx.set(&"reduced_motion", reduced_motion)
	char_fx.z_index = 4
	add_child(char_fx)
	shock_fx.z_index = 40  # the X-ray over the living rigs crowding the victim (parts reach +30)
	add_child(shock_fx)
	split_fx.z_index = KillSplitFx.HELD_Z + 5  # over a body held on the saw (gib_layer + HELD_Z)
	add_child(split_fx)
	dissolve_fx.z_index = 4
	add_child(dissolve_fx)
	burst_fx.bind(kills, ppm, reduced_motion)
	burst_fx.z_index = 40
	add_child(burst_fx)


## After KillView placed the parts this frame.
func pose() -> void:
	char_fx.pose()
	shock_fx.pose()
	split_fx.pose()
	dissolve_fx.pose()
	for h: KillHoleFx.Topple in _holes:
		h.pose(_kills.tick, _ppm)


func forget(serial: int) -> void:
	char_fx.forget(serial)
	shock_fx.forget(serial)
	split_fx.forget(serial)
	dissolve_fx.forget(serial)
	_holes = _holes.filter(func(h: KillHoleFx.Topple) -> bool: return h.serial != serial)


## The victim's parts by the row's style: the gib or whole-body cut, the blade's two halves, or
## the body with the plasma hole punched through.
func parts(
	rig: CutRig, serial: int, row: SignatureKill, at: Vector2, dir: Vector2
) -> Array[Node2D]:
	var split: bool = row.style == &"split" and rig != null  # the blade's halves, cut along dir
	var groups: Array[Node2D] = (
		KillSplitFx.cut(rig, dir, _ppm, row.spray == 0)
		if split
		else GibCut.parts(rig, row.whole_body(), _ppm)
	)
	if row.style == &"split":
		split_fx.add(serial, at, dir, row, groups)
	elif row.style == &"hole" and rig != null:
		groups[SignatureKill.BODY] = KillHoleFx.punch(groups[SignatureKill.BODY], _kills, _ppm)
	elif row.style == &"dissolve" and rig != null:
		groups[SignatureKill.BODY] = KillDissolveFx.wrap(groups[SignatureKill.BODY])
	return groups


## The overlay that takes the placed body (`body`: the kept BODY group, may be null).
func take(serial: int, body: Node2D, row: SignatureKill, at: Vector2, dir: Vector2) -> void:
	if row.style == &"burn" or row.style == &"vaporise":
		char_fx.add(serial, body, row)
	elif row.style == &"shock":
		shock_fx.add(serial, body, row, dir)
	elif row.style == &"dissolve" and body != null:
		dissolve_fx.add(serial, body, row, at)
	elif row.style == &"hole" and body != null:
		var h: KillHoleFx.Topple = KillHoleFx.Topple.new()
		h.serial = serial
		h.body = body
		h.born = _kills.tick
		h.row = row
		h.dir = dir
		_holes.append(h)
