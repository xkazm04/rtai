class_name Quest1ControlsText
extends RefCounted
## Quest 1's title and pause cards use the same translated controls and device glyphs.

const LEGACY: String = (
	"WASD / arrows move    mouse aims    left click fires\n"
	+ "Space / right click: electroshock    E: use (phones, hiding, allies, torch)\n"
	+ "F: car (soon)    Esc: pause    Gamepad: sticks, RT fire, A use, X shock"
)
const LEGACY_PAD: String = (
	"[move] move    [aim] aims    [fire] fires\n"
	+ "[melee]: electroshock    [use]: use (phones, hiding, allies, torch)    [pause]: pause"
)
const WHEEL: String = (
	"WASD / arrows move    mouse aims    Left mouse: swing or fire    Right mouse: guard\n"
	+ "Mouse wheel: change weapon    Space: quick claw    "
	+ "E: use (phones, hiding, allies, torch)    Esc: pause\n"
	+ "Gamepad: left stick move, right stick aim, RT swing or fire, LT guard\n"
	+ "Back change weapon, X quick claw, A use"
)
const WHEEL_PAD: String = (
	"[move] move    [aim] aims    [fire]: swing or fire\n"
	+ "[guard]: guard    [weapon_next]: change weapon    [melee]: quick claw\n"
	+ "[use]: use (phones, hiding, allies, torch)    [pause]: pause"
)


static func source(glyphs: bool, wheel: bool = ControlsMode.wheel()) -> String:
	if glyphs:
		return WHEEL_PAD if wheel else LEGACY_PAD
	return WHEEL if wheel else LEGACY


static func resolve(text: QuestText) -> String:
	var pad: bool = DeviceProfile.shared().is_handheld()
	var glyphs: bool = PadGlyphArt.active()
	var wheel: bool = ControlsMode.wheel()
	var key: StringName = &"SLICE__CONTROLS_PAD" if glyphs else &"SLICE__CONTROLS"
	if wheel:
		key = &"SLICE__CONTROLS_WHEEL_PAD" if glyphs else &"SLICE__CONTROLS_WHEEL"
	var prompt: String = text.resolve(key, source(glyphs, wheel))
	if not glyphs:
		return prompt
	if wheel:
		var guard: String = (
			ObjectiveHint.pad_name(&"guard") if pad else ObjectiveHint.key_name(&"guard")
		)
		var cycle: String = (
			"[%s]" % ObjectiveHint.pad_name(&"weapon_next")
			if pad
			else text.resolve(&"SLICE__MOUSE_WHEEL", "Mouse wheel")
		)
		prompt = prompt.replace("[guard]", "[%s]" % guard).replace("[weapon_next]", cycle)
	return ObjectiveHint.with_keys(prompt, pad)
