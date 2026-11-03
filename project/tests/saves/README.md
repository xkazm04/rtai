# tests/saves

`vN.sav` fixtures for every released save version (SAV-04). `v1.sav` is a GTSV container (save_version 1,
seq 1, a collect-call checkpoint at b2-payphone); `test_gtsv_container.gd` loads it and checks the
encoder still reproduces its bytes. Never edit a released fixture; add `v2.sav` with the v2 format.
