# Brief 06 (lane polish): a voice-wash hook for ghosts that draw their own body; lift tonnage_spectral.gd's tests

Hard stop: 45 minutes after you start (write the stop time down at the start). Last commit 10 minutes before it.
Part 1 only (the tonnage tests moved to an earlier call). Commit what is green; report where you stopped.

## Environment
- `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/polish`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time; windowed runs use `--position 0,1440`; kill only your own PIDs. Nobody rebuilds native.

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
- `project/features/souls/ghost_*.gd` (incl. `ghost_bridge_fade.gd`, `ghost_apparition*.gd`, `ghost_drawn.gd`),
  `tonnage_*.gd`, `ohm_*.gd`, `dent_*.gd`, `hauler_*.gd`, their shaders, and their tests under `project/tests/unit/`.
- NOT yours: `kerf_*.gd` (lane kerf rebuilds Kerf tonight). Kerf must keep working through a default no-op.
  Write `NEED kerf: implement <hook name> on KerfSpectral to wash its parts` in your report.

## Part 1: the speaking apparition washes ghosts that draw their own body
Today `GhostBridgeFade.voice(spr, wash, phase)` tints the shared sprite of a speaking ghost (the story apparition,
`GhostApparition`), but Tonnage, Ohm and Dent under the spectral look draw their own body (`own_body`), so
`rig.drawn.sprite()` is null and the wash silently does nothing. `project/tests/unit/test_ghost_apparition.gd`
`test_spectral_voice_keeps_its_cut_and_only_the_speaker_has_a_shadow_and_tail` guards it out with
`pass_test("own_body: no shared sprite to wash")` (around line 115).
- Give rigs a hook: a method the apparition calls on the speaking rig with the voice phase (e.g.
  `func voice_wash(phase: float) -> void`, a no-op default where rigs share a base or via `has_method`), implemented
  for Tonnage's, Ohm's and Dent's spectral bodies: apply the same voice colour and scan bands that `GhostBridgeFade`
  applies to the shared sprite, to each own part (set the same `voice_phase` shader parameter where the part already
  uses `GhostBridgeFade.SHADER`, else the wash material / an instance parameter), and clear it when the voice ends.
  Do not change how a non-speaking ghost or an in-play ghost looks: only during an apparition voice.
- Restore the assert: replace the `pass_test` guard with an assertion that, for every own_body form under the spectral
  look, the speaking rig's parts carry `voice_phase == 0.44` (the value the test already expects at that tick) and
  that after the voice ends they carry none. Loop over tonnage, ohm, dent (not kerf; keep kerf's legacy check as is).
- Still: `C:/Users/kazda/kiro/gtai-masters/n21/polish/shared/voice_wash_{tonnage,ohm,dent}_{before,after}.png` of the
  apparition speaking (the dev entry that shows it: look in `project/dev/` for an apparition/voice scene, or the quest-1
  base whisper; use `tools/dev/run.mjs` and say which).
- `node tools/tests/run_unit.mjs --changed` green; quick gate green; commit
  ("Wash the speaking ghost's own parts in the apparition voice").
- Mutate: `node tools/mutate/mutate.mjs --file=features/souls/ghost_bridge_fade.gd --max=20 --lines=<changed>` and quote it.

## Repo law (binding)
- AGENTS.md / STANDARDS.md; typed GDScript, functions <= 40 lines, files about 200 lines (hard 300), <= 5 params, `Log`.
- Stage per path. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push.
- Fix lint and format findings in your own edit and go on.
- No sim, replay, parity or bake digest may move. Teal only for souls.

## Report back
Files, commits, test results, mutate lines, still paths, NEEDs, anything not done and why.
