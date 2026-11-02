class_name PayphoneRouter
extends RefCounted
## The payphone job router (Patch). A job's call waits on a payphone; the phone rings only while
## Rivet's heat is 0. Picking up a phone while hot gets Patch's refusal, drops any call and keeps
## the phone quiet until the heat is 0 again; picking up a ringing phone at heat 0 connects the
## caller. Phones are ids (the quest's marker names). Ticks only, no randomness.

enum Phone { QUIET, WAITING, RINGING, CONNECTED, REFUSED }
enum Pickup { DIAL_TONE, CONNECTED, REFUSED_HOT }

const TABLE: String = "res://data/tables/payphone_router.json"
const SCHEMA: String = "gtai.payphone-router/1"

## Patch's refusal (a router line, not a quest line): id, speaker, symbolic key, source text.
var refuse_line: Dictionary[String, String] = {}
var refusals: int = 0
var _phones: Dictionary[String, Phone] = {}


func _init(path: String = TABLE) -> void:
	var t: DataTable = DataTable.open(path, SCHEMA)
	var row: Dictionary = t.object(t.raw, "refuse_line")
	for key: String in ["id", "speaker", "key", "text"]:
		refuse_line[key] = t.text(row, key)
	if not t.ok():
		Log.error("payphone", str(t.errors()))


## A caller waits on `phone` (it rings once the heat is 0).
func queue_call(phone: String) -> void:
	if state(phone) != Phone.CONNECTED:
		_phones[phone] = Phone.WAITING


func state(phone: String) -> Phone:
	return _phones.get(phone, Phone.QUIET)


func ringing(phone: String) -> bool:
	return state(phone) == Phone.RINGING


func connected(phone: String) -> bool:
	return state(phone) == Phone.CONNECTED


## One tick: waiting (and refused) calls ring at heat 0; a ringing phone goes quiet while hot.
func step(heat: int) -> void:
	for phone: String in _phones:
		match _phones[phone]:
			Phone.WAITING, Phone.REFUSED:
				if heat == 0:
					_phones[phone] = Phone.RINGING
			Phone.RINGING:
				if heat > 0:
					_phones[phone] = Phone.WAITING


## Rivet picks up `phone` with `heat`.
func pick_up(phone: String, heat: int) -> Pickup:
	if heat > 0:
		refusals += 1
		if state(phone) in [Phone.WAITING, Phone.RINGING]:
			_phones[phone] = Phone.REFUSED
		return Pickup.REFUSED_HOT
	if ringing(phone):
		_phones[phone] = Phone.CONNECTED
		return Pickup.CONNECTED
	return Pickup.DIAL_TONE


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(refusals)
	var ids: Array[String] = _phones.keys()
	ids.sort()
	for phone: String in ids:
		out.put_utf8_string(phone)
		out.put_8(_phones[phone])
