import json,subprocess,sys
d,out,title=sys.argv[1],sys.argv[2],sys.argv[3]
tl=json.load(open(d+"/timeline.json"))
import glob; total=len(glob.glob(d+"/f_*.jpg"))/30.0
f=[]
font="C\:/Windows/Fonts/arialbd.ttf"
f.append(f"drawtext=fontfile='{font}':text='{title}':x=24:y=20:fontsize=22:fontcolor=0xF2EBCC:box=1:boxcolor=0x17131Bcc:boxborderw=8")
for i,s in enumerate(tl):
    a=s["start_s"]; b=tl[i+1]["start_s"] if i+1<len(tl) else total+1
    t=s["label"].replace(":","\:").replace(",","\,").replace("'","")
    f.append(f"drawtext=fontfile='{font}':text='{t}':x=24:y=h-52:fontsize=26:fontcolor=0xF2EBCC:box=1:boxcolor=0x17131Bcc:boxborderw=10:enable='between(t,{a:.3f},{b:.3f})'")
subprocess.run(["C:/ffmpeg/bin/ffmpeg.exe","-loglevel","error","-y","-framerate","30","-i",d+"/f_%05d.jpg","-vf",",".join(f),"-c:v","libx264","-pix_fmt","yuv420p","-crf","18",out],check=True)
