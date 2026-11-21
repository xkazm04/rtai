# a3b: resume a3-blast (lane guard)

Allowed: update the debt baseline through the debt tool for Part 0 only:
`node tools/debt/debt.mjs --update --accept-regression="restore doc comments deleted in 8a8a0d93c/123ec794d (n22 guard)"`,
stage `tools/debt/baseline.json` with the three files and commit Part 0. Add `tools/debt/baseline.json` (through the debt tool
only, never by hand) to your allowlist for the rest of this call too; any later rise needs its own `--accept-regression` reason
naming the file.

Then go on with the rest of brief a3-blast unchanged (parts 1 to 7, tests, scenarios, commit, mutate).
Wall-clock HARD STOP 02:55; commit by 02:45. Never stop the whole call for a NEED that only blocks one part: report it, skip
that part, and go on with the others.
