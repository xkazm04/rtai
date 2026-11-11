#!/bin/bash
export PATH=$HOME/node24/bin:/usr/local/bin:/usr/bin:/bin
d=/tmp/n15t_clone_s7; rm -rf $d
git -c core.hooksPath=/dev/null clone -q --no-local --branch n15-tools /mnt/c/Users/kazda/kiro/gtai $d 2>&1 | tail -2
cd $d && git log --oneline -1 && git --version && node --version
node --test 'tools/dev/*.test.mjs' 'tools/film/*.test.mjs' 'tools/merge/*.test.mjs' 'tools/gate/*.test.mjs' 'tools/lint/*.test.mjs' 2>&1 | grep -E '^ℹ (tests|pass|fail|skipped)|^not ok|✖' | head -20
cd /; rm -rf $d; echo "clones left: $(ls /tmp | grep -c n15t_clone)"
