"""Writes data/tables/voice_lengths.json (seconds per voiced line, from the processed Ogg files) and prints the
subtitle-vs-voice gap per line against quest_rules.json's line timing. Run from the repo root after process.py."""
import json, pathlib, subprocess

rules = json.loads(pathlib.Path("project/data/tables/quest_rules.json").read_text())["tuning"]
quest = json.loads(pathlib.Path("project/quests/collect-call/quest.json").read_text(encoding="utf-8"))
lines = {}
gap = []
for l in quest["lines"]:
    f = pathlib.Path("project/assets/audio/voice") / (l["id"] + ".ogg")
    sec = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(f)], capture_output=True, text=True).stdout)
    lines[l["id"]] = round(sec, 2)
    sub = min(max(len(l["text"]) / rules["line_type_cps"] + rules["line_hold_s"], rules["line_min_s"]), rules["line_max_s"])
    gap.append((l["id"], round(sub, 1), round(sec, 1)))
doc = ("Seconds of each voiced quest line (the processed Ogg in assets/audio/voice). Quest line timing (quest_rules.json: "
       "line_type_cps, line_hold_s, line_max_s) shows a line for 2.2-9 s while the voice runs 4-20 s, so a voiced line "
       "outlives its subtitle; the quest lane should take max(text time, voice_s + a beat) from here. Written by tools/audio/voice_lengths.py.")
pathlib.Path("project/data/tables/voice_lengths.json").write_text(json.dumps({"schema": "gtai.voice-lengths/1", "doc": doc, "lines": lines}, indent=2, sort_keys=True) + "\n", newline="\n")
pathlib.Path("project/data/schemas/voice_lengths.schema.json").write_text(json.dumps({
    "$id": "gtai.voice-lengths/1", "additionalProperties": False, "type": "object", "required": ["schema", "doc", "lines"],
    "properties": {"schema": {"const": "gtai.voice-lengths/1"}, "doc": {"minLength": 1, "type": "string"},
                   "lines": {"type": "object", "additionalProperties": {"type": "number", "minimum": 0.1, "maximum": 60}}}}, indent=2, sort_keys=True) + "\n", newline="\n")
over = [g for g in gap if g[2] > g[1]]
print("lines whose voice outlasts the subtitle:", len(over), "of", len(gap), "| total voice s", round(sum(g[2] for g in gap), 1), "| total subtitle s", round(sum(g[1] for g in gap), 1))
for g in gap: print(g)
