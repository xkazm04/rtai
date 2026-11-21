class_name GuardFilmCaptions
extends CanvasLayer
## Optional editorial captions. The HP and guard figures are sampled from the displayed tick.

var heading: Label
var line: Label
var figures: Label


func _ready() -> void:
	layer = RenderLayers.canvas(&"hud") + 1
	heading = _label(Vector2(56, 46), 32)
	line = _label(Vector2(57, 92), 22)
	figures = _label(Vector2(57, 126), 18)


func _label(at: Vector2, px: int) -> Label:
	var label: Label = Label.new()
	label.position = at
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", px)
	label.add_theme_color_override("font_color", Color("#fff6e5"))
	label.add_theme_color_override("font_outline_color", Color("#28252b"))
	label.add_theme_constant_override("outline_size", 6)
	add_child(label)
	return label


func show_tick(beat: String, row: Dictionary) -> void:
	var t: int = row.tick
	match beat:
		"guard":
			heading.text = tr("Guard")
			line.text = _guard_line(row)
		"rocket":
			heading.text = tr("Guard against a rocket")
			line.text = tr("Hold guard and face the launcher.")
			if row.hp < 100.0:
				line.text = tr("The blast reaches Rivet through the guard.")
		"wall":
			heading.text = tr("Behind a high wall")
			line.text = tr("The first rocket strikes the wall.")
			if t >= 186:
				line.text = tr("Rivet walks out from cover for the second shot.")
			if row.hp < 100.0:
				line.text = tr("In the open, the same rocket takes health.")
		"wheel":
			heading.text = tr("The weapon wheel")
			line.text = _wheel_line(t)
	var health: float = row.hp
	var hp: String = tr("Health  %d") % roundi(health)
	if row.meter == null:
		figures.text = hp + tr("     Legacy controls")
	elif beat == "wheel":
		figures.text = tr("Selected  %s") % str(row.selected).capitalize()
	else:
		var meter: float = row.meter
		figures.text = hp + tr("     Guard  %d%%") % roundi(meter)


func _guard_line(row: Dictionary) -> String:
	if row.meter == null:
		return tr("Three pistols fire from the front.")
	if row.broken:
		return tr("Guard broken. The next shots get through.")
	if row.tick >= 263:
		return tr("Lower the guard to refill the meter.")
	if row.deflects > 0:
		return tr("Pistol rounds fly back toward their shooters.")
	return tr("Hold the guard into the incoming fire.")


func _wheel_line(t: int) -> String:
	if t < 131:
		return tr("Hands come first. Primary swings the claw.")
	if t < 278:
		return tr("Scroll to the katana. Primary swings the blade.")
	if t < 437:
		return tr("Scroll to the pistol. Primary fires.")
	return tr("Scroll again to return to hands.")
