# native

`gtai_sim.gdextension` loads the `CitySim` class (the native bubble sim, NAT-01) from `bin/`,
which is git-ignored build output. Build it from `native/` (see `native/README.md`):
`scons platform=windows arch=x86_64 target=template_debug` (and `target=template_release`).
`reloadable=false` until hot reload is proven stable on Windows (NAT-12).
