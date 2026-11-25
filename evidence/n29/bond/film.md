# n29 film: Tonnage's bond to 70, mastery card, T

`render_bond.mjs` is the n28 script copied (paths n28 -> n29, `BOT` env picks the bot, default expert).
Take: `node evidence/n29/bond/render_bond.mjs <out.mp4> 32 2 6 1400 3000` (seed 2, expert bot, `--bond-prefill=6`, so labelled:
every form starts 6 points under its bar, Tonnage at 64). Same seed and prefill as the n28 film, so only the bar differs.
Events: bond full tick 1765, mastery card (Master Tonnage first) at the rest after wave 2, mastered tick 2463, Tonnage entered 2884.
Output `gtai-masters/n29/combat/films/tonnage_mastery_70.mp4`: 1920x1080, 60/1 fps, 35.15 s. Still: 64 px/m via `bond_film_64.tscn`,
ticks 2500-2503 -> `stills/tonnage_chip_70_64.png`.

A natural (no-prefill) take was tried on seed 1 (mastery at wave 7) but `project/dev/ghost-forms/bond_film.gd:68` fails with prefill 0
(`SCRIPT ERROR` assigning an untyped `[]` to `Array[StringName]`); that file is outside this brief's allowlist.
