# n8 hud lane: REPORT (final, it21, 07:55; the project tree frozen at f80e09ba)

Lane `hud`, branch `n8-hud`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n8\hud\` (`frames.json`,
15 entries, best first; the combined clip `hud_set_combined_it19.mp4`, 61 s, 7 segments). Repo evidence under
`evidence/`. Full log: `JOURNAL.md`. Presentation only: no combat number, quest logic or line text
changed. `top` stays bit-identical (look goldens 11/11 + block 5/5 at every gate run).

## What works (with its evidence)

1. **Showcase art for all 17 drawable weapons**, one drawing per weapon at p70, p55 and a flat icon
   cut, keyed by the view row's art key (`WeaponShowcase`; `top` draws today's parts). 12 from the
   owner-approved `rivet-r2/out/arm_<id>.png` designs via the assets lane's showcase sheets, 5 from
   the owner's redesigns (`rivet-final/out/showcase_<id>_{70,55}.png`). Cut by re-runnable tools
   (`tools/art/showcase_import.py`, `design_cut.py --showcase`), provenance per file.
   - **Floor pickup** (hover 0.35 m kept, the default), **open crate** (`--pickup-crate=on`, the 70
     crate from `weapon_crate_open_70_v3`, A), **wall rack** (`WeaponRackView`: handguns hang flat
     from hooks, long guns stand), **HUD icon** on the ammo ticket.
   - Stills: `armory_tilt70_48_before_after_crop2x.png` (frames 1), `armory_tilt70_32_...`,
     `armory_tilt_48_...` (55), `rack_handguns_flat_tilt70_32_...`, `crate_v3_tilt70_{32,48}_...`,
     `chainsaw_v2_tilt70_{32,48}_before_after_x3.png`.
   - it20: on the wall rack a showcase piece hangs at least 0.7 m (`WeaponRackView.MIN_SHOW_M`): the molotov
     was a 4 px sliver at 32 px/m, now its bottle and rag read: `rack_molotov_min_show_tilt70_32_64_before_after.png`;
     the whole showcase at 64 px/m, p70 over p55: `armory_showcase_64ppm_tilt70_tilt.png`.
   - it19: the rocket launcher, flamethrower and molotov icons from the assets lane's
     `weapon_showcase_heavy_70_v3` (the icon column fixed to rust/brass; the molotov no longer
     cream-on-cream): `hud_heavy_icons_v3_tickets_1280x800_before_after.png`,
     `armory_rack_heavy_icons_v3_tilt70_48ppm_before_after_x2.png`.
2. **The dialogue box with a face.** `PortraitBook` rows (approved busts only: the quest-1 cast,
   cut from the library's newest graded sheets), name plate, emotion swap on the line's tag, rise-in
   0.18 s / fade-out 0.22 s, never pauses play, fits its line (150-236 px). Don Fax and Patch get a
   device frame (the payphone), never a face. LIVE: `quest1_payphone_call_live_tilt70.mp4`;
   `dialogue_faces_1280x800_before_after.png`, `dialogue_contact_{1280x800,1080p}.png`.
   Boss taunt presentation (`BossTaunt`, a paper strip under the boss bar, tail at the crest):
   `call_boss_taunt_box_vs_strip_combo_1280x800.png` (dev shot: no taunt lines exist yet).
   it20: Juno Stitch's busts from the assets lane's rust-brown post fix of v4 (red-hue px 738 -> 265 /
   990 -> 225; red stays for blood): `dialogue_nurse_rustbrown_busts_before_after.png`.
3. **The HUD pass on one hand-inked torn-paper style** (`HudPaper`): beat panel, cash frame (fits
   its sum), ammo ticket (a 3-slice with the showcase icon), the ghost-form card (soul teal only on
   the current form; each chip shows that ghost's own drawn face), quest 1's control prompt, heat
   pips police blue, the brass bullet (no red). The top corners turn see-through (35 %) over Rivet,
   the goal, a living hostile or a patrol (`HudSee`). Legible at 1080p and 1280x800:
   `hud_full_1920x1080_after.png`, `hud_full_1920x1080_it16.png`, `hud_fit_1280x800_before_after.png`,
   `hud_see_through_cop_tilt70_1280x800_before_after_x2.png`, `ghost_chip_faces_tilt70_48_before_after_x2.png`,
   `quest1_prompt_paper_1280x800_1080p_before_after.png`, `hud_tickets_all_weapons_{1280x800,1920x1080}_contact.png`.
4. **The boss bar** with each boss's crest (the King, Servo), on a paper banner hanging from the
   top edge, name and phase count in ink; the bar keeps its place (BossCam unchanged):
   `bossbar_paper_king_combo_before_after_x2.png`, `bossbar_paper_king_servo_combo_1280x800_before_after.png`,
   `bossbar_paper_king_servo_combo_1920x1080_top.png` (it19).

Every look has a flag one value away (`PAPER`, `FACES`, `SEE`, `ON_TICKET`, `FIT_BOX`,
`--pickup-crate`, `MIN_SHOW_M`), recorded as `DECISION hud/...` in `docs/decisions.md`.

## Gates
- Last full gate run: 610da507 (it16): lint 15/15, unit 1528/0, scenarios 52/52, parity bit-exact
  + planted mutation, look goldens 11/11 + block 5/5, export-audit 563/0. Full unit 1529/0 at 8ee9483f.
- it19 (icons only): `--select` test_hud_art + test_weapon_showcase 20/0, lint 15/15.
- Director reel at 2a8a045c (it19, headless, `--bot=reel --reel=director --loadout=pistol --rigs`):
  `top` 19/19 chapters down, `tilt70` 19/19 down, 0 SCRIPT ERROR both
  (`evidence/director-reel-n8hud-it19-{top,tilt70}.log`).
- Full gate run at 38bc8bee (it19, `evidence_run_it19.log`): lint 15/15, unit 1529/0, scenarios
  52/52, parity bit-exact + planted mutation caught at step 629, look goldens 11/11 + block 5/5 (top did not move), export-audit 563/0.
- Full gate run at 9a6a3ce4 (it20, after Juno's rust-brown busts, `evidence_run_it20.log`, 07:15-07:22): lint 15/15,
  unit 1529/0, scenarios 52/52, parity bit-exact + planted mutation caught at step 629, look goldens 11/11 +
  block 5/5 (top did not move), export-audit 563/0. The reel was not re-run for it: a portrait PNG only, no
  reel chapter draws the dialogue box (quest 1 only); the it19 reel ran on the same code.
- Full gate run at f80e09ba (it20, after the rack show minimum, `evidence_run_it20b.log`, 07:33-07:41): lint 15/15,
  unit 1530/0, scenarios 52/52, parity bit-exact + planted mutation caught at step 629, look goldens 11/11 +
  block 5/5 (top did not move), export-audit 563/0. Director reel at f80e09ba: `top` 19/19 down, `tilt70`
  19/19 down, 0 SCRIPT ERROR both (`evidence/director-reel-n8hud-it20-{top,tilt70}.log`).
- FREEZE (it21): the project tree did not change after f80e09ba (`git diff f80e09ba HEAD -- project` empty), so the
  f80e09ba gate run, reel and exe stand as the freeze's.

## What does not work / not done
- No vendor exists in the game: the rack and the crate are the showcase's display forms.
- No boss taunt line system and no owner-signed boss lines: `BossTaunt` waits for a caller.
- The car radio carries no speech (3 placeholder music loops): no speaker to frame; a
  `PortraitBook` `kind: device` row is the hook.
- The heavy and long showcase sheets' p70/p55 columns are near side profiles with a thin top band
  (assets' B note); the chainsaw got a top-plane raise (0505), the rest wait for a raise.
- Quest 1's Dock 9 crate row sits under the HUD's top-right corner at tilt70 (stage placement; the
  see-through corners soften it).
- The dialogue box over a fight: quest 1's Mertz engage puts his 3-line intro (the box at its
  fitted max, ~35 % of the screen's height at 1280x800) over the lower street while play runs (view's
  merged clip `quest1_mertz_ease_before_after_combo_32ppm_merged_t15200_15600.mp4`). Built: opaque,
  never pauses. Options: the box's see-through over Rivet/a hostile (as the corners, but text must
  stay legible: ~70 %), a slimmer box in a fight, or pause on a boss intro. Not built tonight.
  Looked on n8-hud (it19, `quest1_clip --view=combo --ticks=15200-15600`, 1280x800, 0 SCRIPT ERROR,
  an 8-frame contact): Rivet and Mertz stay at the crate row top right, clear of the box, through
  the whole line; one blue figure brushes the box's right end. So it reads as crowding, not as a
  hidden fight: kept opaque (the Call stands).
- `--write-movie` ignores `--resolution`: 1080p arena shots need `window_width/height_override` in
  the local override.cfg (JOURNAL it19).

## Calls for the owner
- **Pickup hover (built) vs lying in the open crate:** `call_pickup_hover_vs_crate_32_crop2x.png`;
  exe `RTAI.exe -- --armory --view=tilt70 --rigs` vs `... --pickup-crate=on`.
- **Boss taunt: strip under the bar (built) vs the dialogue box with a bust** (`BossTaunt.FORM`):
  `call_boss_taunt_box_vs_strip_combo_1280x800.png`.
- **The boss banner (built) vs the bare bar** (`BossBar.PAPER`): `bossbar_paper_king_combo_before_after_x2.png`;
  exe `RTAI.exe -- --boss=king --view=combo --rigs`.
- **Ghost chip faces (built) vs the ink glyphs** (`GhostChipFace.FACES`): `ghost_chip_faces_tilt70_48_before_after_x2.png`.
- **See-through corners at 35 % (built) vs 50 %** (`HudSee.SEE_A`): `hud_see_through_cop_tilt70_1280x800_before_after_x2.png`.
- Portrait side and size (left, 252 px bust at 1080p); the dialogue never pauses play (built); Don
  Fax's payphone frame vs his concept bust (one table row); Rivet's dialogue face waits for the
  Rivet triage (`proposal_rivet_dialogue_face.png`, off-game).
- FINDING: the dock guard's approved concept wears an orange-vermilion hard hat and hi-vis vest;
  vermilion is reserved for danger, objectives, the collar and the cape. Kept as drawn (hazard gear).

## Exe
- Preset `windows-showcase` (boots `dev/arena/arena.tscn`, embedded pck):
  `"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`
- `RTAI.exe -- --armory --view=tilt70 --rigs` (showcase on the floor, the rack, the ticket),
  `RTAI.exe -- --armory --view=tilt --rigs` (55), `RTAI.exe -- --armory --pickup-crate=on --view=tilt70 --rigs`,
  `RTAI.exe -- --boss=king --view=combo --rigs`, `RTAI.exe -- --boss=servo --view=combo --rigs`.
  The taunt shot and the dialogue board are dev-only (-s scripts): see the masters stills.
- Built at 07:48 from f80e09ba (gates + reel green at that head; it replaces the 07:01 and 07:22 builds): `build/export/windows/RTAI.exe`
  (262 MB, embedded pck, + `gtai_sim.windows.template_release.x86_64.dll` beside it), export 0 errors.
  Smoke: `RTAI.exe --log-file <f> --write-movie <dir>/f.png --fixed-fps 60 --quit-after 240 -- --armory
  --view=tilt70 --rigs` and `-- --boss=king --view=combo --rigs`: 241 frames each, 0 errors in the
  log; looked at frame 239 of each (the floor showcase + rack + chip faces; the King's paper banner).
  Smoke frames: `gtai-n8/scratch/hud/it20/exe_smoke.png`
  (07:22 build, armory + King) and `exe2_smoke.png` (07:48 build, armory: the rack bottle at 0.7 m).
  it21 (07:54), the 07:48 build again: `-- --boss=king --view=combo --rigs` and `-- --boss=servo --view=combo --rigs`,
  241 frames each, exit 0, 0 ERROR lines in either log; frame 239 of both looked at (the paper banner with
  the King's and Servo's crests, the ghost card): `gtai-n8/scratch/hud/it21/exe_boss_smoke.png`.
  Also `-- --armory --view=tilt --rigs` and `-- --armory --pickup-crate=on --view=tilt70 --rigs` (07:59):
  241 frames each, exit 0, 0 ERROR lines; frame 239 looked at (the p55 floor pieces + rack; the open crates):
  `it21/exe_armory55_crate_smoke.png`. Every exe command line in this section is smoked on the shipped build.

## Merge notes for the Director
- hud touches `features/hud/`, `features/bosses/boss_bar.gd`, `features/police/heat_meter.gd`, the
  quest/payphone presentation, `features/player/pickups_view.gd`, `features/combat/weapons/art/`
  (showcase, pickup look, rack), `tools/art/*`, `tools/debt/baseline.json` (dev_loc accepted).
- With view: take view's `StoryForms.follow` over hud's `fold_rigs` (JOURNAL 04:55).
- Quest 1 under tilt70 is flat on n8-hud because the city art is on n8-city: clean on merge.

## Next steps
- The assets lane's raises for the heavy/long showcase top views (p70/p55), then re-import.
- Boss taunt lines (owner-signed) wire into `BossTaunt`.
- Portraits for the bosses as busts once approved; Rivet's dialogue face after the Rivet triage.
- The equipped weapon form waits for the owner's Rivet pick (not this lane tonight).
