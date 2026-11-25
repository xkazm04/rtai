class_name PrologueRoofGlow
extends CanvasLayer
## Fire light rising off the burning hall: one additive amber band over the void north of the roof
## line, from a dressing's optional `roof_glow` row (absent = no node). It sits on the actors canvas
## ahead of the actor layer, like the floor glow, and never reaches the wall base. Render only: the
## flicker steps on the sim tick it reads, never on frame delta or a global RNG.

const NODE_NAME: String = "RoofGlow"
const BAND_NAME: String = "Band"
const SHADER: Shader = preload("res://boot/prologue/prologue_roof_glow.gdshader")

var _stage: ArenaStage = null
var _step_ticks: int = 1
var _flicker: float = 0.0
var _last_step: int = -1
var _material: ShaderMaterial = null


## The roof glow of a dressing row's `roof_glow` object: rect_m, color, hot_color, strength,
## flicker (0..1 depth) and step_ticks.
static func read(table: DataTable, row: Dictionary) -> Dictionary:
	var rect: Dictionary = table.object(row, "rect_m")
	return {
		"rect_m": Rect2(table.vec(rect, "origin"), table.vec(rect, "size")),
		"color": Color(table.text(row, "color")),
		"hot_color": Color(table.text(row, "hot_color")),
		"strength": table.num(row, "strength"),
		"flicker": table.num(row, "flicker"),
		"step_ticks": maxi(1, table.integer(row, "step_ticks")),
	}


static func attach(print_stage: PrintStage, spec: Dictionary, stage: ArenaStage) -> void:
	if spec.is_empty():
		return
	var node: PrologueRoofGlow = build(spec)
	node._stage = stage
	print_stage.add_child(node)
	print_stage.move_child(node, print_stage.actor_layer().get_index())


static func build(spec: Dictionary) -> PrologueRoofGlow:
	var node: PrologueRoofGlow = PrologueRoofGlow.new()
	node.name = NODE_NAME
	node.layer = RenderLayers.canvas(&"actors")
	node.follow_viewport_enabled = true
	var rect: Rect2 = spec["rect_m"]
	node._step_ticks = spec["step_ticks"]
	node._flicker = spec["flicker"]
	node._material = ShaderMaterial.new()
	node._material.shader = SHADER
	node._material.set_shader_parameter(&"color", spec["color"])
	node._material.set_shader_parameter(&"hot_color", spec["hot_color"])
	node._material.set_shader_parameter(&"size_m", rect.size)
	node._material.set_shader_parameter(&"strength", spec["strength"])
	var band: ColorRect = ColorRect.new()
	band.name = BAND_NAME
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.material = node._material
	band.position = rect.position * SimConst.PX_PER_M
	band.size = rect.size * SimConst.PX_PER_M
	node.add_child(band)
	node.step(0)
	return node


## Set the flicker for a sim tick: one new level every step_ticks, a fixed function of the step.
func step(tick: int) -> void:
	var at: int = floori(float(tick) / float(_step_ticks))
	if at == _last_step:
		return
	_last_step = at
	var k: float = float(at)
	var swing: float = 0.5 + 0.5 * sin(k * 1.7) * sin(k * 0.63 + 1.0)
	_material.set_shader_parameter(&"flicker", 1.0 - _flicker * swing)
	_material.set_shader_parameter(&"phase", k * 0.37)


func _process(_delta: float) -> void:
	if _stage != null:
		step(_stage.tick)
