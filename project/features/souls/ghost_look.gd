class_name GhostLook
extends RefCounted
## Selects appearance once per form view. An explicit unrecognised look uses legacy art.

const LEGACY: StringName = &"legacy"
const SPECTRAL: StringName = &"spectral"

static var _forms: GhostFormTable
static var _testing: bool = false
static var _override: StringName = &""


static func of(form_id: StringName) -> StringName:
	if _testing:
		if _override != &"":
			return SPECTRAL if _override == SPECTRAL else LEGACY
	elif LaunchArgs.has("--ghost-look"):
		return SPECTRAL if LaunchArgs.value("--ghost-look") == SPECTRAL else LEGACY
	if _forms == null:
		_forms = GhostFormTable.load_default()
	var row: GhostFormDef = _forms.form(form_id)
	return row.look if row != null else LEGACY


static func spectral(form_id: StringName) -> bool:
	return of(form_id) == SPECTRAL


## An empty override tests the shipped rows independently of the command line.
static func override_for_test(look: StringName) -> void:
	_testing = true
	_override = look


static func reset_for_test() -> void:
	_testing = false
	_override = &""
