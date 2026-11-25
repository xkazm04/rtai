# n30-06 prologue film and span shadow film

Whole prologue, menu Start to quest 1's first line, HEAD's default yard `arched_line` (table diff empty at render): `newgame_pilot.gd --bot --seed=7` through `build/prologue-film` (1920x1080 override.cfg), d3d12, `--fixed-fps 60`, re-encoded yuv420p (range converted) crf 20 to `gtai-masters/n30/yard/prologue_menu_to_quest1.mp4`: h264 yuv420p 1920x1080 60 fps, 189.32 s.
Handover tick 10792, quest 1 first line `rivet-line-stopped` tick 10793: unchanged from n29. Script errors 0. In: shade 0.5 `31838bbae`, decals `5950ceb34`/`ed6b97278`/`7236d6218`, span shadow `726550b45`/`ceb17574f`, hall roof `507f75178`/`7fd323782` (tint a0a0acff), mouth span `65183a395`.
First render run was lost: a duplicate waiter of mine started a second Godot that truncated the avi during the encode; re-rendered (same ticks both times).

Frames seen: menu (Start/Quit card on cream); yard fight at 45 s (Rivet on the belt, cops, blood); Warden line at 3 s; Mulroney card at 100 s (Rivet line over the yard); Don Fax line at 150 s; city with "1/6 Line Stopped" and Rivet's first line at 187 s.

Span shadow film `span_shadow_before_after_32ppm.mp4`: mid camera ticks 1757..3256 (25 s), 32 px/m, crops x 220, before = HEAD with `arched_line.span_shadow` removed by a temporary table edit (restored byte-identical, git diff clean), after = HEAD. Finding: in this window Rivet fights beside the S span's foot, mostly off the span art; the shadow blot is not visible in frames 60, 150, 330, 500. The film does not show the shadow read; a window where he walks along a span is still owed.
