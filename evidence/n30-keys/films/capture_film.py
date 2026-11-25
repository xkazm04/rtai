from pathlib import Path
import json,sys,subprocess,shutil
weapon,mode=sys.argv[1:3];PPMS=[int(x) for x in sys.argv[3].split(",")];SUB=sys.argv[4];masters=Path(r"C:/Users/kazda/kiro/gtai-masters/n30/keys/"+SUB+r"");source=Path("C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_gloria_arena/capture-source")
arena=masters/f"grid_{weapon}_arena";arena.mkdir(exist_ok=True,parents=True)
scene="legs_film" if mode.startswith("rows") else "grid_arena_film"
files=[p for p in source.iterdir() if p.stem.startswith("legs_")== (scene=="legs_film")]
work=(Path.cwd()/"project/dev/motion").resolve();work.mkdir(exist_ok=True);pass
archive=arena/(mode+"_source");archive.mkdir()
for f in files:assert not (work/f.name).exists(),f.name
try:
 for f in files:shutil.copyfile(f,work/f.name)
 for ppm in ([32] if scene=="legs_film" else PPMS):
  output=arena/(mode if scene=="legs_film" else f"{mode}_{ppm}");output.mkdir(exist_ok=False)
  args=["--rendering-driver","d3d12","--position","0,1440","--fixed-fps","60","--max-fps","0","--log-file",str(output/"godot.log"),f"res://dev/motion/{scene}.tscn","--",f"--weapon={weapon}",f"--ppm={ppm}","--view=tilt70",f"--out={output.as_posix()}"]
  if scene=="grid_arena_film":args+=["--clean","--silent","--start=boulevard",f"--loadout={weapon}"]
  js="import {runGodot} from './tools/lib/godot.mjs';const r=await runGodot(JSON.parse(process.argv[1]),{headless:false,name:'n30-keys-film',timeoutMs:360000});process.stdout.write(r.out);process.exit(r.status===0 && !r.timedOut && !r.out.includes('SCRIPT ERROR')?0:1);"
  with (output/"console.log").open("xb") as log:v=subprocess.run(["node","--input-type=module","-e",js,json.dumps(args)],stdout=log,stderr=subprocess.STDOUT)
  print(mode,ppm,"exit",v.returncode,flush=True)
  if v.returncode:raise RuntimeError(output)
finally:
 for f in files:
  if (work/f.name).is_file():shutil.move(str(work/f.name),str(archive/f.name))
