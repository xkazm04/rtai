# usage: compose.py <out.mp4> <start> <last_frame> <top1_dir> <top2_dir> <top3_dir> <bottom_dir> <label1> <label2> <label3> <bottom_label> <footer>
import sys,subprocess,pathlib,tempfile
out,start,last,d1,d2,d3,db,l1,l2,l3,lb,foot=sys.argv[1:13]
start=int(start);last=int(last)
db=pathlib.Path(db)
ticks=sorted(int(p.stem.split("_")[1]) for p in db.glob("sample_*.png"))
tmp=pathlib.Path(tempfile.mkdtemp(prefix="films_cc_",dir="C:/Users/kazda/kiro/gtai-wt/n23-controls/build"))
lst=tmp/"b.txt";lines=[]
for i,t in enumerate(ticks):
    if t<start-59: continue
    nxt=ticks[i+1] if i+1<len(ticks) else last+1
    lines.append(f"file '{(db/f'sample_{t:04d}.png').as_posix()}'\nduration {(nxt-max(t,start))/60:.6f}")
lst.write_text("\n".join(lines)+"\n")
n=last-start+1
F="C\\:/Windows/Fonts/arial.ttf"
def dt(t,x,y,s=26):return f"drawtext=fontfile='{F}':text='{t}':x={x}:y={y}:fontsize={s}:fontcolor=white:box=1:boxcolor=black@0.7:boxborderw=6"
def inp(d):return ["-framerate","60","-start_number",str(start),"-i",f"{d}/frame_%04d.jpg"]
fc=(f"[0:v]crop=640:540:640:270,{dt(l1,8,8)}[a];[1:v]crop=640:540:640:270,{dt(l2,8,8)}[b];[2:v]crop=640:540:640:270,{dt(l3,8,8)}[c];"
    f"[3:v]fps=60,crop=1920:540:0:270,{dt(lb,8,8)},{dt(foot,8,500,22)}[d];[a][b][c]hstack=inputs=3[t];[t][d]vstack=inputs=2,scale=in_range=full:out_range=tv,format=yuv420p[v]")
cmd=["ffmpeg","-y","-v","error"]+inp(d1)+inp(d2)+inp(d3)+["-f","concat","-safe","0","-i",str(lst),"-filter_complex",fc,"-map","[v]","-frames:v",str(n),"-r","60","-c:v","libx264","-crf","16","-preset","medium",out]
print(subprocess.run(cmd).returncode)
