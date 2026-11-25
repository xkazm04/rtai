# usage (cwd = a worktree root): run_hands.py <outdir> <ppm> <movie 0|1>
# Copies the n26 hands_arena harness into project/dev/motion, runs it with godot, moves it out again.
import json,sys,subprocess,shutil
from pathlib import Path
out=Path(sys.argv[1]);ppm=sys.argv[2];movie=sys.argv[3]=="1"
src=Path("C:/Users/kazda/kiro/gtai-masters/n26/keys/capture-source")
work=(Path.cwd()/"project/dev/motion").resolve();work.mkdir(exist_ok=True)
files=[src/n for n in ("hands_arena.gd","hands_arena.gd.uid","hands_arena.tscn")]
for f in files:assert not (work/f.name).exists(),f.name
out.mkdir(parents=True,exist_ok=False)
try:
 for f in files:shutil.copyfile(f,work/f.name)
 args=["--rendering-driver","d3d12","--position","0,1440","--fixed-fps","60","--max-fps","0","--log-file",str(out/"godot.log"),"res://dev/motion/hands_arena.tscn","--",f"--ppm={ppm}","--view=tilt","--clean","--silent",f"--out={out.as_posix()}","--rev="+out.name]+(["--movie"] if movie else [])
 js="import {runGodot} from './tools/lib/godot.mjs';const r=await runGodot(JSON.parse(process.argv[1]),{headless:false,name:'n29-keys-film',timeoutMs:420000});process.stdout.write(r.out);process.exit(r.status===0 && !r.timedOut && !r.out.includes('SCRIPT ERROR')?0:1);"
 with (out/"console.log").open("xb") as log:v=subprocess.run(["node","--input-type=module","-e",js,json.dumps(args)],stdout=log,stderr=subprocess.STDOUT)
 print("exit",v.returncode)
finally:
 for f in files:
  if (work/f.name).is_file():(work/f.name).unlink()
