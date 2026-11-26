# n31 ghost 16 - Dent deploy beats: art prep (no Godot, no repo edit, no images)

Builder tag: `g16-dent-prep`. Hard stop 30 minutes after launch. Report and END. Model this on g11's Ohm prep: read `C:\Users\kazda\kiro\gtai-art\ghost-n31\ohm-beats\state.md` for the format and depth wanted.
Worktree (read only): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Write ONLY under `C:\Users\kazda\kiro\gtai-art\ghost-n31\dent-beats\` (state.md, jobs.json, make_jobs.py, refs/).

## Why
Dent (key 1) becomes one press (g15, `evidence/briefs/n31-ghost-15-dent-drop.md`): a 0.25 s wind-up, then a ram along Rivet's aim from his side to the aim point (range 8), every body within `ram_half_m` of the lane hit and shoved. The owner: deploy animation and effect "needs more detailed work". Beats to plan (P = press, R = P + 15 the ram tick): arrival at Rivet's side (P..P+4), wind-up (P..R-1: Dent crouches/pulls back, the lane announced ON THE GROUND by the effect itself, e.g. skid scrape or dust streaks running out along the lane to its end: a telegraph, not a UI marker), ram (R..R+8: the body visibly travels the lane to the spot, a dust wake along the lane, shoves), aftermath (scuff marks along the lane held 2 s + 1 s fade, he fades).

## Do
1. The chain (code reading only, like state.md section 1 of Ohm): how a deployed Dent is drawn today (`project/features/souls/ghost_deploy_body.gd` DentBody path, `dent_body.gd`, Dent's spectral sheets under `project/features/souls/art/view/{p55,p70}/dent_*`, `ghost_drawn*.gd` act/jab cells, `ghost_deploy_effects.gd` dent branch), what cells exist for a crouch / a lunge / a run, where the body stands during the strike (origin or spot), what effects draw, what happens after `phase != ACTIVE`. File:line for each claim. The gauntlet `--pick-view` uses p70 art.
2. The beat plan at 32 px/m: which shipped cells carry each beat (prefer shipped cells; list any cell that does not exist), which ground effects are needed and in what world colours (dust tan, soot, ink; never teal on the ground, never red, never vermilion), the scale of each at 32 px/m (Dent's drawn height in px; lane width = 2 x ram_half_m), and how the body travels the lane (ticks, easing).
3. Image jobs: at most 6, for the ground effects only (a skid-scrape lane strip that tiles or stretches along a lane, a dust wake, scuff marks; chroma green #00B140 background like the Ohm jobs), each with a reference crop in `refs/` from the shipped Tonnage/Ohm decals (`project/features/souls/art/tonnage_drop_*.png`, `ohm_drop_*.png`) for style. Write `jobs.json` the way `ohm-beats/jobs.json` is (same keys; read `C:\Users\kazda\kiro\gtai-art\gen.mjs` for the job format). Do NOT run gen.mjs.
4. `state.md` with sections: chain, beat plan, jobs, open questions (each with your recommended answer).

## Rules
No Godot, no repo edit, no commit, no image generation. Report: the state.md path, the 3 most important findings, open questions with your recommendation.

## Added 01:23 (director, launch)
- Launched 01:23; hard stop 01:52 (the director's session ends 01:59). Write state.md early and keep it current, so a cut-off still leaves it usable.
- Dent's drop shipped in `87ac21445` (`DentLane` in `project/features/souls/dent_lane.gd`, strike on the charge's last tick, life_ticks 57). g15 found the VIEW still plays the hold animation: g12's generalised `_drops` (`ghost_deploy_body.gd`) locks every drop row to row 0, so Dent faces the camera, and his body slides along the lane during the wind-up instead of after the ram. In your plan, say exactly which lines of `ghost_deploy_body.gd` (and DentBody) must change so that Dent faces along the lane (not row 0), stands at the lane's origin through the wind-up, and travels origin -> spot on R..R+8. That code change is the first part of the next build call.
