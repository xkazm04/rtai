class_name StreetDead70
extends RefCounted
## n10 world (the owner's note on the dead): a class with a sheet DRAWN for the 70-degree camera
## (art/view/p70/dead70_<class>.png, tools/art/dead_70.py) lies in a cell picked by the head's
## screen heading and is never turned: the left side mirrors the right. Rows 0 face down, 1 on the
## back; columns the head down, down-right, right, up-right, up. The drawing already shows the
## camera's foreshortening and near side. A class without a sheet keeps its plan pose.
## View only. ENABLED false = every class on the plan poses.
const ENABLED: bool = true
const DIR: String = "res://features/characters/art/view/p70/dead70_"
const COLS: int = 5
const ROWS: int = 2
## The last column drawn: a body with its head straight up reads as a man standing, so bodies lie
## across the view or on a diagonal and an up heading takes the up-right cell, mirrored by the
## person. COLS - 1 = the straight-up cells too.
const LAST_COL: int = 3
const CLASSES: Array[String] = ["cop_patrol", "ped_suit"]
## The degrees between two columns' headings, and the head's screen heading of column 0.
const COL_STEP_DEG: float = 45.0
const COL_0_DEG: float = 90.0
## StreetDeadPlan's pose -> the row (poses that share a heading differ here; -1: by the person).
const FAMILY: PackedInt32Array = [0, 1, 1, 0, -1]

static var _tex: Dictionary[String, Texture2D] = {}


## The sheet for a card row ("" = no sheet: the row lies in its plan pose).
static func path_of(row: String) -> String:
	if not ENABLED or not StreetDeadPlan.CLASS_OF.has(row):
		return ""
	var cls: String = StreetDeadPlan.CLASS_OF[row]
	return DIR + cls + ".png" if CLASSES.has(cls) else ""


## The cell that draws a head lying along `head` (right-side headings; see mirrored()).
static func cell(head: Vector2, pose: int, odd: bool) -> int:
	var deg: float = rad_to_deg(Vector2(absf(head.x), head.y).angle())
	var col: int = clampi(roundi((COL_0_DEG - deg) / COL_STEP_DEG), 0, LAST_COL)
	var row: int = FAMILY[pose] if FAMILY[pose] >= 0 else (1 if odd else 0)
	return row * COLS + col


## Whether the cell draws mirrored: its head lies left (straight up or down: by the person).
static func mirrored(head: Vector2, odd: bool) -> bool:
	return odd if is_zero_approx(snappedf(head.x, 0.001)) else head.x < 0.0


## `plan` shows the cell for this body, unturned.
static func lay(plan: Sprite2D, head: Vector2, pose: int, odd: bool) -> void:
	plan.frame = cell(head, pose, odd)
	plan.flip_h = mirrored(head, odd)


## Shows `plan`'s cell; returns (its turn, the ground's squash to undo): art drawn for this camera
## (`for_camera`) is neither turned nor squashed, a plan pose is both.
static func place(plan: Sprite2D, head: Vector2, pose: int, odd: bool, for_camera: bool) -> Vector2:
	if for_camera:
		lay(plan, head, pose, odd)
		return Vector2(0.0, ViewMode.shared().ground_k())
	plan.frame = pose
	plan.flip_h = StreetDeadHeading.flipped(head, pose, odd)
	return Vector2(StreetDeadHeading.angle_of(head, pose, plan.flip_h), 1.0)


## `card`'s lying sprite on `path`, a `h_cells` x `v_cells` sheet.
static func sprite(card: Sprite2D, path: String, h_cells: int, v_cells: int) -> Sprite2D:
	var plan: Sprite2D = card.get_node_or_null(StreetDeadPlan.NODE) as Sprite2D
	if plan == null:
		plan = Sprite2D.new()
		plan.name = StreetDeadPlan.NODE
		card.add_child(plan)
	if plan.texture == null or plan.texture.resource_path != path:
		if not _tex.has(path):
			_tex[path] = load(path) as Texture2D
		plan.frame = 0
		plan.hframes = h_cells
		plan.vframes = v_cells
		plan.texture = _tex[path]
	return plan
