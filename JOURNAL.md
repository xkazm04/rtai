# n20 flight JOURNAL

- 00:13 START iteration 1 BUILD. No astra.lock / calls for flight. Other lanes' journals empty (no NEED flight yet).
- 00:25 DECISION interface shape: GhostLook (static, one "which look" question; `--ghost-look=legacy|spectral`
  overrides; row field `look` in ghost_forms.json, all "legacy"), GhostHover + ghost_hover.json (hover, bob,
  bank, lag, plus a `tail` and `shadow` object per form), GhostTail (Node2D), GhostShadow (Node2D),
  GhostFlight (Node2D composer the form view drives on sim ticks). Feet off: GhostDrawn.hover holds the
  standing cell (no phase), GhostFormView feeds the top-view rigs speed 0 under spectral (no stamp/stride),
  so no ghost-lane file needs an edit for the stub. Rejected: per-rig edits by flight (ownership).
- 00:16 ASTRA RUNNING interface since 00:16 (brief evidence/briefs/n20-flight-01-interface.md)
- 00:20 PLATES read (all four). Shared: ragged teal vapour tails, bright at the root; every plate puts a teal
  light pool on the wet street under the ghost (so GhostShadow = dark core + teal pool, not a plain blob).
  Per-form tail: dent_a one long comet tongue (+glass shards: dent lane's), kerf_a thin straight wisps
  along the hull (beam streamers: kerf lane's), ohm_c tattered robe hem of 4-5 tatters, tonnage_b thick
  smoke column curling up/back. Package 2 brief written (evidence/briefs/n20-flight-02-real.md): tail
  shader on tick (not TIME), shadow+pool, hover character, legless fade bridge on legacy drawn sprites,
  tools/film/ghost_films.mjs (n19's two-panel 1920x1080 layout was never committed: lanes need it).
- 00:29 NEED from ohm (spec_hover/spec_act sheets in GhostDrawn, sprite()) + tonnage/dent pose-sheet plans -> package 1b brief (evidence/briefs/n20-flight-01b-sheets.md), queued as --resume after the interface.
- 00:40 MILESTONE interface 0e7d91e46 (committed 00:37 by Astra, session 'interface' still running for polish)
- 00:49 NEED from ohm #2 (public instant_windup, 0 under spectral ohm) added to 1b brief. ohm adds a one-line call site in GhostActs.prepare_ohm (rig.ohm = o): accepted.
- 01:00 NEED from dent (DentBody.step kept under spectral + tail geometry) added to 1b. Looked at scratch kerf_move_tilt70_{spectral,legacy}_f124: spectral stands lifted with lag + wedge stub tail; the ground ring stays put. OK as stub.
- 01:24 ASTRA interface 68 accepted. Commits 0e7d91e46 (interface 00:37) .. 28f7e5520. Astra's report: lint 19/19, GUT --changed 3202 pass/2 skip, replay 3600 ticks cbeb734ff9b97c41, parity 1200 exact + mutation caught, bake golden, legacy 370 frames pixel-identical, TonnageRig stamps 0 under spectral, Dent 0 catch-up steps. Not yet re-run by me (one Godot per lane; 1b started first).
- FRICTION: Astra trimmed doc comments in ghost_drawn.gd to fit size; consider moving code out to restore them.
- 01:24 ASTRA RUNNING sheets since 01:24 (--resume, brief evidence/briefs/n20-flight-01b-sheets.md, out .out.txt)
- 01:27 Replied to ohm (cross-session): flight adopts `<card>_spec_hover.png` / `_spec_hover_left.png` / `_spec_act.png`, `pose`, `sprite()`, public `instant_windup` (0 under spectral ohm), tail `points()/half_widths()`; promised the 1b sha when it lands.
NEXT: (1) check astra.lock + astra-02-sheets; when 1b ends, review the diff and its tests, ASTRA sheets <min> accepted|bounced, message ohm (pipe from-name n20-ohm-8c) and write the sha where dent/tonnage read it (their JOURNALs are theirs: just reply via SendMessage if listed). (2) Re-run myself: `node tools/tests/run_unit.mjs --select=test_ghost_look,test_ghost_hover` and the scenario replay (one Godot per lane: only when Astra is idle). (3) Start package 2 (evidence/briefs/n20-flight-02-real.md: tail shader on tick, shadow+teal pool, hover character, legless fade bridge, tools/film/ghost_films.mjs + flight_* films). Consider splitting the film tool out as package 3 if 2 runs long. (4) Commit JOURNAL.md + evidence/briefs/* when Astra is idle (not yet committed). Final gate by 06:15.
- 01:27 DECISION ghost_hover.json rows: each ghost lane owns and tunes its OWN row (as in ghost_forms.json); flight owns the schema, new fields and defaults. Answers kerf NEED 01:10 (kerf edits lag/bank itself). Kerf's one-line call site in ghost_form_view.gd (`v._bodies.kerf.stage = stage`) accepted. To docs/decisions.md via package 2 (Astra writes it).
- 01:27 dent LOOKED: the shared comet tail is a thin faint wisp below the plume; wants root as wide as the torso at the belt, tapering over ~2 body lengths, brightest at the root -> added to package 2 brief.
- 01:25 Messaged kerf (row ownership), dent (tail feedback in pkg 2), tonnage (spec sheet naming, pose). Peer names: n20-tonnage-58, n20-ohm-8c, n20-kerf-26, n20-dent-27.
- 01:36 tonnage NEED: GhostDrawn opt-out -> DECISION name `drawn.own_body = true` (no sprite at all); first item of package 2. Default fallback (legacy cell, standing) stays for lanes without sheets. dent acks tail plan (will raise its width_m back ~0.5 after the root lands).
- 01:37 ASTRA RUNNING sheets since 01:24 (--resume of the interface session; lock present; out evidence/briefs/n20-flight-01b-sheets.out.txt; no commit from it yet at 01:37). Session 1 ends.
NEXT (supersedes the 01:27 NEXT): (1) wait for astra.lock to clear, read 01b out + diff (pose/spec sheets, sprite(), instant_windup, tail points()/half_widths(), DentBody under spectral), log `ASTRA sheets <min> accepted|bounced`. (2) SendMessage the 1b sha to n20-ohm-8c, n20-dent-27, n20-tonnage-58 (promised). (3) Start package 2 (evidence/briefs/n20-flight-02-real.md, now opens with GhostDrawn.own_body for tonnage, then lane feedback, then tail/shadow/hover/fade/film tool). Send the own_body sha to tonnage once committed. (4) When Astra is idle: re-run test_ghost_look/test_ghost_hover myself and commit JOURNAL.md + evidence/briefs/*. (5) Scan the four lane JOURNALs for `NEED flight` each session. Final gate by 06:15.
- 01:36 tonnage acked own_body; its session hands over ~01:44: send the shas to whichever n20-tonnage-* session ListAgents shows live (same for the other lanes).
- 01:39 ASTRA sheets 14 accepted. d2a44407e (01:38): spec_hover/spec_act + pose, sprite(), instant_windup (0 spectral ohm), tail points()/half_widths(); Astra: lint 19/19, --changed 3208 pass/0 fail, legacy kerf still byte-identical. Sha sent to ohm + dent; tonnage gets the own_body sha from package 2. No Astra running at session end.
NEXT: start package 2 now (brief ready, opens with own_body); then items (4)-(5) of the 01:37 NEXT.
