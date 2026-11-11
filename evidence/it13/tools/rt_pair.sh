#!/bin/bash
# n15 hero it13: per-cell diff of the retone films. usage: rt_pair.sh <tag>...  (tag = dent, dent55, ...)
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
for t in "$@"; do
  for s in before after; do for e in png tsv; do cp build/film/h3_${t}_rt$s.$e build/film/h3_${t}rt_$s.$e; done; done
  py -3 -I evidence/it12/tools/pair.py ${t}rt
done
