"""Replays the quest 1 line timeline (ticks in/out) through VoiceChannel's queue rules
(one voice, MAX_PENDING 2, oldest waiting line dropped) and reports lines never spoken
and lines cut by the on-screen line leaving. Usage: voice_queue_sim.py <timeline.json> <out.json>"""
import json, sys
MAX_PENDING = 2
lengths = json.load(open("project/data/tables/voice_lengths.json"))["lines"]
def v(i):
    e = lengths[i]
    return e["seconds"] if isinstance(e, dict) else e
tl = json.load(open(sys.argv[1]))["lines"]
events = sorted((l["in"] / 60.0, l["id"]) for l in tl if l["id"] in lengths)
t = 0.0; playing = None; end = 0.0; pending = []; spoken = []; dropped = []
def advance(to):
    global playing, end, pending
    while playing is not None and end <= to:
        playing = None
        if pending:
            nid = pending.pop(0); playing = nid; spoken.append(nid); globals()["end"] = end + v(nid)
for tt, i in events:
    advance(tt)
    if playing is not None:
        if len(pending) >= MAX_PENDING:
            dropped.append(pending.pop(0))
        pending.append(i)
    else:
        playing = i; end = tt + v(i); spoken.append(i)
advance(1e9)
res = {"voiced_lines": len(events), "spoken": len(spoken), "dropped": dropped}
json.dump(res, open(sys.argv[2], "w"), indent=1); print(res)
