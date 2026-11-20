# Brief 09 (lane tonnage): one test guard, 10 minutes max

All rules of briefs 03-08 bind (no amend/rebase/squash/stash, no `add -A/./-u`, no `reset --hard`, never push, stage per path, a fix is a NEW
commit; `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/tonnage`;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; one Godot process at a time; kill only by PID).
No other change. Do not touch any product code.

`project/tests/unit/test_ghost_apparition.gd` (flight's file; flight's owner OKed exactly this edit as a named call site) fails at line 100,
`test_spectral_voice_keeps_its_cut_and_only_the_speaker_has_a_shadow_and_tail`: `rig.drawn.sprite().material` on a null sprite, because spectral
Tonnage draws its own body (`drawn.own_body = true`, so `sprite()` is null). Product is safe (`GhostBridgeFade.voice` returns on null).
Fix, as flight specified: replace line 100's `var cut: ShaderMaterial = rig.drawn.sprite().material` with
```
	var spr: Sprite2D = rig.drawn.sprite()
	if spr == null:
		pass_test("own_body: no shared sprite to wash")
		return
	var cut: ShaderMaterial = spr.material
```
(keep everything after it unchanged). Then `node tools/tests/run_unit.mjs --select=test_ghost_apparition` green, then
`node tools/tests/run_unit.mjs --failed` or `--changed` green, `node tools/lint/lint.mjs` green. Commit on its own:
`Let the spectral voice test accept a form that draws its own body`. Report: sha, counts. Stop.
