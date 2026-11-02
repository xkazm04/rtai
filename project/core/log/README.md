# core/log

`Log` autoload (TEL-01). The only place allowed to call `print()`.
`HitchRecorder` (TEL-03): every frame over 25 ms goes to `user://logs/hitches.jsonl`, attributed
(`outside` / `pipeline` / `game` / `render` / `unexplained`) with the help of `FrameCanary`, a
1 ms sleeper thread that shows when the whole process stalled. The composition root owns one.
