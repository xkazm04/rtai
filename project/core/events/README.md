# core/events

`Events` autoload (`EventBus`). Every signal is registered in `data/schemas/events.json` with its
emitter, `wired` flag and typed params (ARC-06); the param names are the achievements contract.
Systems emit through `ctx.events` (the `WorldContext`), never by reaching for the autoload.
`EventLog` records emits with their tick: the debug ring buffer and the replay timeline.
