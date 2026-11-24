#!/bin/bash
# Waits for the builder to free Godot, then runs the after-melee arm on the scratch tree (4a3ff4b04).
while [ ! -f /c/Users/kazda/kiro/gtai-wt/n23-loop/evidence/n27-pressure/godot-free.txt ]; do sleep 30; done
bash /c/Users/kazda/kiro/gtai-wt/n23-loop/evidence/n27-pressure/medians/join.sh melee
