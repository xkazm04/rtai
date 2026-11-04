# Combat notes from the owner, 2026-11-04 (night run final reel)

Verdict: "nice baselines, all approved". The lane reports are archived in
`docs/night/2026-11-04/<lane>/REPORT.md`; the final reel is reel-1012 in
`C:\Users\kazda\kiro\gtai-masters\n4\showcase\`.

## Open items

1. **Electro gun and plasma rifle: the human reaction.** Improve how a struck and a killed human
   reacts to the electro gun and to the plasma rifle (human-reactions + brutality; the electro
   corpse now lies in the plank, REQUEST 30).
2. **Rivet's melee hold and animation.** How Rivet holds the melee weapons and how he swings them
   (rivet-arsenal: katana, chainsaw, electro baton, plasma sword, claw).
3. **The plasma sword's visual asset.** The sword itself needs a better asset (weapon-art).
4. **Homing shard (reel chapter 14): the victim reacts with a delay.** The hit reaction starts
   late after the shards land (gunplay shard flight + ReactLink queue + brutality burst kill).
5. **A Gatling gun as a new weapon**, in a future session (gunplay row, weapon-art asset,
   rivet-arsenal hold, human-reactions class, a brutality signature kill if wanted).
6. **Reel chapter 18 (city block) lags so badly it cannot be watched.** A performance issue in the
   city fight to investigate. It ties to the r19 bench miss (aggregate p99 8.79 ms, 1 % low 74 fps,
   worst frame 424 ms; one CONTENDED run, not bisected; r16 was 8.52 ms / 88 fps). Start with a
   clean bench of the city fight and a bisect over rounds 16-19.

## Closed by the verdict

- All lanes' "Calls for the owner" defaults are approved as they are (the owner: "all approved").
