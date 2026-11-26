# --foe-fire=hot is setting B (n31 foes, b4q)

Question: does HEAD with `--foe-fire=hot` play exactly the setting measured at `c825715e8` (B: share 0.75, pistol 1.5, rifle 1.5, cannon 8)?

Commands (seed 3, average profile, 1 seed, 7 waves, `gauntlet --controls=wheel --pick=greedy`):

    node tools/gauntlet/waiting.mjs --out=build/n31/hotproof/head-hot --profiles=average --seeds=1 --seed0=3 --game-flag=--foe-fire=hot --tag=b4q
    node tools/gauntlet/waiting.mjs --out=build/n31/hotproof/rev-b   --profiles=average --seeds=1 --seed0=3 --rev=c825715e8 --tag=b4q
    node tools/gauntlet/waiting.mjs --out=build/n31/hotproof/head-def --profiles=average --seeds=1 --seed0=3 --tag=b4q   (control: no flag)

Result lines:

    head-hot: average seed 3: exit 0, 15 s; ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 7 against KNOWN (waiting_probe.gd)
    rev-b:    average seed 3: exit 0, 22 s; ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 6 against KNOWN (waiting_probe.gd)
    head-def: average seed 3: exit 0, 14 s; ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 6 against KNOWN (waiting_probe.gd)

Verdict: `cmp` says `runs/average-3.json` (the waiting tally: shots, never-fired, idle, react) and `runs/average-3.result.json`
(the run result: damage taken per wave, picks) are BYTE-IDENTICAL between head-hot and rev-b. The no-flag control differs
(`cmp` differs at byte 164 and byte 1587), so the flag changes the run and lands exactly on B.

Damage taken per wave (result file): head-hot = rev-b = [10.5, 3, 18, 8.54, 98.48, 41.6, 10.5]; head-def = [15, 21, 4, 4.21, 93.02, 8, 6].
Seeds: 1 (seed 3) only, the quick path; no 20-seed rerun. Probe change: `waiting.mjs --game-flag=<f,..>` (node test added),
and `waiting_probe.gd` accepts `--foe-fire` / `--foe-moves` itself because the shared gauntlet.gd rejects them
(see `evidence/n31/foes/need_gauntlet_flags.patch`).
