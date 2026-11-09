# it17: every frame over 40 ms in the four Deck runs, with its split; the frame dumps stay out of tree and this output is what is kept.
import json, sys
S = 'C:/Users/kazda/kiro/gtai-n10/tmp/handheld/it17/'
K = ['wall_ms', 'pump_ms', 'process_ms', 'physics_ms', 'draw_ms', 'flush_ms', 'render_gpu_ms', 'pipelines', 'tick']
for label in ['deck_grab_r1', 'deck_none_r2', 'deck_none_r3', 'deck_grab_r4']:
    d = json.load(open(S + label + '.frames.json'))
    n = len(d['wall_ms'])
    rows = [i for i in range(n) if d['wall_ms'][i] > 40]
    print(f'== {label} frames {n}, over 40 ms: {len(rows)}, over 100 ms past frame 60: {sum(1 for i in rows if i >= 60 and d["wall_ms"][i] > 100)}')
    for i in rows:
        print(f'  f{i:5d} ' + ' '.join(f'{k.replace("_ms","")}={d[k][i]:.1f}' for k in K))
