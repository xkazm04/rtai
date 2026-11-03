class_name RiotBed
extends RefCounted
## The riot's roar: a crowd bed that swells with the violence heard. Each frame it counts the
## gun, death and body-hit cues the service started, smooths that rate (fast up, slow down) and sets
## the `crowd_roar` bed between quiet_db and loud_db (data/tables/audio_mix.json riot_bed_*).
## Render-side: it reads `service.played`, nothing is written back.

const WATCHED: Array[StringName] = [
	&"shot", &"shot_assault_rifle", &"shot_gloria", &"death", &"hit_flesh", &"rivet_kill"
]
const OFF_BELOW: float = 0.04

## 0..1: how loud the riot is right now.
var intensity: float = 0.0
var _seen: int = 0


func step(service: AudioService, frame_s: float) -> void:
	var total: int = 0
	for id: StringName in WATCHED:
		total += service.played.get(id, 0)
	var rate: float = float(total - _seen) / maxf(frame_s, 0.0001)
	_seen = total
	var t: AudioTables = service.tables
	var want: float = clampf(rate / t.mix_float("riot_bed_full_rate", 6.0), 0.0, 1.0)
	var tc: float = (
		t.mix_float("riot_bed_rise_s", 1.5)
		if want > intensity
		else t.mix_float("riot_bed_fall_s", 4.0)
	)
	intensity = lerpf(intensity, want, 1.0 - exp(-frame_s / maxf(tc, 0.01)))
	var quiet: float = t.mix_float("riot_bed_quiet_db", -18.0)
	var loud: float = t.mix_float("riot_bed_loud_db", 0.0)
	service.loops.set_on(&"crowd_roar", intensity > OFF_BELOW, lerpf(quiet, loud, intensity))
