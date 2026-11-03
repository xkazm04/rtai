# JOURNAL e-fixes (visual-fixes lane)
- 20:53 iter1 start. Order changed once: item 3 (voice timing) first, it is the smallest and surest; then 1 (rim), then 2 (roads).
- MILESTONE item 3: QuestLine.voice_s + VoiceLengths loader; duration = max(text, voice+0.4). Timeline before 190.6 s / after 329.7 s, 23/23 lines >= voice+0.4. Unit 538, scenarios 19/19, lint 13/13. Goldens did not move (no golden covers line durations). evidence/lines/.
- MILESTONE item 1: rim halved via CutRig.RIM_K=0.5 (halo scale). Measured before/after at 32/48/64/128 for rivet/cop/ped (evidence/rim). Look goldens re-blessed (both sites). No robot rig kind; portraits not measured.
- FRICTION: unit tests flake (29/453/630 fail) while other lanes run Godot at the same time (shared user:// test_tmp); re-ran, 538/538 twice.
