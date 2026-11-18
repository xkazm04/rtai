# Production fight baseline

Base `28302bd3c42ef083009c5e081ce4459668949410`. Godot 4.7.2, headless, 60 Hz, seeds 20261103 through 20261107. Each cell gives the arithmetic mean of the five seed results followed by the minimum and maximum. A smaller sample count appears where the tick budget cut a wave short.

| Metric | City street fight | Arena pit | Quest 1, Dock 9 bonded storage |
|---|---:|---:|---:|
| Measured ticks | 2303 (2303..2303) | 2303 (2303..2303) | 2122.6 (2083..2163) |
| Hostile-ticks | 4834.6 (4564..5079) | 4238.2 (3919..4422) | 5986 (5622..6279) |
| LOS share (%) | 14.27 (13.05..15.5) | 77.64 (73.78..87.72) | 100 (100..100) |
| In cover (%) | 44.19 (36.56..48.69) | 3.22 (1.09..5.59) | 0 (0..0) |
| Crowded (%) | 30.28 (21.54..42.6) | 0.44 (0..2.19) | 24.76 (14.62..32.37) |
| Pairs within 1 m, peak | 2.6 (2..3) | 0.2 (0..1) | 4.6 (2..7) |
| Pairs within 1 m, mean/tick | 0.3285 (0.2275..0.4655) | 0.0041 (0..0.0204) | 0.4352 (0.206..0.675) |
| Mean distance to Rivet (m) | 13.87 (13.54..14.03) | 13.79 (13.53..13.97) | 15.39 (15.24..15.57) |
| Distinct firing flank bearings (1° bins) | 3.2 (0..8) | 5 (2..7) | 0.8 (0..3) |
| Distinct flanking shooters | 1.8 (0..5) | 1.6 (1..2) | 0.6 (0..2) |
| State — approach (hostile-ticks) | 201.8 (117..299) | 2143.8 (1873..2749) | 5115.2 (4840..5246) |
| State — burst (hostile-ticks) | 84.4 (30..119) | 195 (130..254) | 148.8 (92..172) |
| State — cooldown (hostile-ticks) | 366.4 (332..416) | 894 (707..1067) | 722 (544..937) |
| State — route (hostile-ticks) | 4182 (4000..4449) | 1005.4 (575..1208) | 0 (0..0) |
| Encounter objective clear (s) | 17.58 (16.52..18.47) | 14.53 (13.97..15.35) | 35.36 (34.7..36.03) |
| Waves cleared | 5.8 (5..6) | 7 (7..7) | 5 (5..5) |
| Damage taken (HP) | 3.6 (0.6..5.4) | 7.32 (1.2..10.2) | 4.68 (2.4..7.2) |
| Rivet deaths | 0 (0..0) | 0 (0..0) | 0 (0..0) |
| Kills | 23.6 (22..24) | 29 (29..29) | 48 (48..48) |
| Hostile shots fired | 14.8 (5..21) | 33.6 (22..44) | 26 (17..30) |
| Hits on Rivet | 6 (1..9) | 12.2 (2..17) | 7.8 (4..12) |
| Wave 1 clear (s) | 5.06 (4.17..6.22) | 3.73 (3.65..4.05) | 3.75 (3.18..4.1) |
| Wave 2 clear (s) | 3.49 (2.95..3.75) | 3.09 (2.47..3.88) | 4.59 (4.32..4.88) |
| Wave 3 clear (s) | 4.03 (3.57..4.87) | 2.71 (2.42..3.25) | 4.01 (3.78..4.45) |
| Wave 4 clear (s) | 3.92 (3.6..4.35) | 3.1 (2.85..3.65) | 5.03 (4.88..5.32) |
| Wave 5 clear (s) | 4.46 (4.25..4.77) | 3.2 (2.82..3.65) | 6.81 (6.68..6.92) |
| Wave 6 clear (s) | 4.44 (3.9..5.63) [4/5] | 3.18 (2.97..3.38) | n/a |
| Wave 7 clear (s) | n/a | 3.32 (2.85..3.7) | n/a |
| Wave 8 clear (s) | n/a | n/a | n/a |
| Hostile stepping, total (µs) | 11224.8 (10967..11600) | 8713.8 (7977..9152) | 8223.4 (7618..8496) |
| Hostile stepping, mean/tick (µs) | 4.87 (4.76..5.04) | 3.78 (3.46..3.97) | 3.87 (3.66..4.08) |
| Mean per hostile step (µs) | 2.32 (2.24..2.42) | 2.06 (2.01..2.13) | 1.37 (1.32..1.45) |
| P99 per hostile step (µs) | 13.4 (12..15) | 7.8 (7..9) | 3.8 (3..5) |
| Max per hostile step (µs) | 92 (65..116) | 56 (51..61) | 13.8 (10..21) |

City and pit use `ArenaSession.open` and `ArenaPitBot` for 2,400 world ticks. Their repeatable clear objective is three waves from the first spawn, including inter-wave gaps. Fight totals cover all waves through tick 2,399. Quest 1 uses the same `CollectCallPlay.begin` and `CollectCallBot` inputs as `scenario_quest_collect_call`, from the dumpster through the director’s clear of the fifth bonded-storage wave. Its objective clock includes the director’s final wait. Wave clocks run from announcement through the last kill. An n/a wave has no observed clear in that encounter. The full per-seed wave records distinguish absent waves from waves still open at cutoff.

Rows sample living encounter guards after hostile stepping and before projectile resolution. Station dummies stay in the simulation. Shares use hostile-ticks, and the mean pair count includes empty ticks between the first wave and the measurement endpoint. Cover requires blocked LOS and at most 1.5 m to the nearest solid. The quest scenario’s authored floor has no collision geometry, giving measured LOS of 100% and cover of 0%. A flanking shot comes from a bearing over 60° from the circular mean of the living squad. Distinct bearings use nearest-degree world headings. Hits and HP loss are counted at the damage call, before repair or respawn.

**CONTENDED timing.** Two clock reads bracket each encounter guard’s production `_step_hostile` call. The per-tick trace sums these calls, including movement and routing. Empty ticks contribute zero. P99 is nearest-rank across individual calls per seed. The table uses run 1 timing on the shared machine.

## Replay check

All 15 per-seed digests, every deterministic trace column and every non-timing summary field matched. Each seed digest hashes the tick, roster size, and every arena hostile’s ID, position and HP after every world step, including dead actors and station dummies. The sweep digest is SHA-256 of the ordered ASCII lines `encounter,seed,digest\n`.

- Run 1 sweep digest `3debe07fc9fefda57340f150f89a9a99c154849f336dc8a35e916f800c60fa2b`.
- Run 2 sweep digest `3debe07fc9fefda57340f150f89a9a99c154849f336dc8a35e916f800c60fa2b`.

<details><summary>Both SHA-256 digests for each encounter and seed</summary>

| Encounter | Seed | Run 1 | Run 2 |
|---|---:|---|---|
| city | 20261103 | `7a61766c8e50d05869f4a60992ece5cd79d11b15266ef2384afa28e5a372d0c2` | `7a61766c8e50d05869f4a60992ece5cd79d11b15266ef2384afa28e5a372d0c2` |
| city | 20261104 | `6c453d01df988d826d259f2f8a2ad11ad20cb3ddf5fe2f3ed8c7a32c0b17322f` | `6c453d01df988d826d259f2f8a2ad11ad20cb3ddf5fe2f3ed8c7a32c0b17322f` |
| city | 20261105 | `638eac3e621c0a7da3dafacb33764f94ad0ea1ca068f86c7928de71ca962eee9` | `638eac3e621c0a7da3dafacb33764f94ad0ea1ca068f86c7928de71ca962eee9` |
| city | 20261106 | `b98df35202c6ddff8796a87c6c240ef3c7b21ac3e418b475c617261527569df3` | `b98df35202c6ddff8796a87c6c240ef3c7b21ac3e418b475c617261527569df3` |
| city | 20261107 | `d91f383ea1078089179e1850067e5a680eb23cdbb947904a4310f826e84509fb` | `d91f383ea1078089179e1850067e5a680eb23cdbb947904a4310f826e84509fb` |
| pit | 20261103 | `1efb05436029012bc6de1fb538e9ccf60a6713b0b8b6792bd658aa08e6cb88c1` | `1efb05436029012bc6de1fb538e9ccf60a6713b0b8b6792bd658aa08e6cb88c1` |
| pit | 20261104 | `b69d9deefdf67c5a4af3771ff85e35c73b16c8d848d559a77d099eb1dca00c42` | `b69d9deefdf67c5a4af3771ff85e35c73b16c8d848d559a77d099eb1dca00c42` |
| pit | 20261105 | `cb2515acd326c937550d7022487cfbd433f42c261d61a47c7e1d383ca522082d` | `cb2515acd326c937550d7022487cfbd433f42c261d61a47c7e1d383ca522082d` |
| pit | 20261106 | `3976a3c2f3c61b5b8eced3af67440ab6f7c6009229782f0a8aba645c8a21afd1` | `3976a3c2f3c61b5b8eced3af67440ab6f7c6009229782f0a8aba645c8a21afd1` |
| pit | 20261107 | `99df41cff4ce66254ee09acec482624a23572c1d5f7157f87b4fd9b18cd9671d` | `99df41cff4ce66254ee09acec482624a23572c1d5f7157f87b4fd9b18cd9671d` |
| quest1 | 20261103 | `0e26748f40d64c51e27d2ac3fe8c9b81d7f1723d1f9d5e61cd686d39e1bb566f` | `0e26748f40d64c51e27d2ac3fe8c9b81d7f1723d1f9d5e61cd686d39e1bb566f` |
| quest1 | 20261104 | `53d9556ea0e1315b4cebb25d94b1258d22608cbe47177e4a37e89ea942ce8cb6` | `53d9556ea0e1315b4cebb25d94b1258d22608cbe47177e4a37e89ea942ce8cb6` |
| quest1 | 20261105 | `3e19499c28878dac78e27a9504f3f3c4bb6f6fa93f22f666b9a6f4ea5f07a082` | `3e19499c28878dac78e27a9504f3f3c4bb6f6fa93f22f666b9a6f4ea5f07a082` |
| quest1 | 20261106 | `02f49b97b9ccf8d34409c4996f9d612675f25eff7a3a246e8995683825319334` | `02f49b97b9ccf8d34409c4996f9d612675f25eff7a3a246e8995683825319334` |
| quest1 | 20261107 | `167aca0103c2f65c271bf819497699917a1f9068135b61854ff240fadc9119f3` | `167aca0103c2f65c271bf819497699917a1f9068135b61854ff240fadc9119f3` |

</details>

## Rerun from this worktree

```powershell
$env:APPDATA = 'C:/Users/kazda/kiro/gtai-n19/appdata/ai'
$env:GODOT_BIN = 'C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
node tools/dev/run.mjs fight_probe --all --seeds=5 --out=C:/Users/kazda/kiro/gtai-wt/n19-ai/evidence/n19-ai/probe-current.json
```

The default run writes the JSON summary. Add `--trace` to write per-tick NDJSON beside `--out`. The accepted baseline trace is archived at `C:/Users/kazda/kiro/gtai-masters/n19/ai/probe/probe-baseline.ndjson`. The JSON lists both column layouts. For one encounter use `--encounter=city`, `pit` or `quest1`. The probe accepts `--brain=old`. Its flag parser marks where to enable `squad` when production implements that argument.
