"""Join two synchronized native cursor captures. Insets enlarge the actual pointer pixels."""
import json
from pathlib import Path
import subprocess
import sys


def assemble(before, after, master):
    tracks = [json.loads((root / 'pointers.json').read_text()) for root in (before, after)]
    for track in tracks:
        if [s[0] for s in track] != list(range(60, 1020)):
            raise ValueError('missing capture ticks')
    if [s[:2] for s in tracks[0]] != [s[:2] for s in tracks[1]]:
        raise ValueError('wheel inputs diverged between revisions')
    segments = [(0, 173, 'pistol'), (180, 360, 'katana'), (361, 533, 'chainsaw'),
                (540, 720, 'hands'), (721, 960, 'pistol')]
    captions = []
    for i, (start, end, item) in enumerate(segments):
        for revision, track in enumerate(tracks):
            _, selected, arrow, _ = track[(start + end) // 2]
            if selected != item or arrow != (revision == 1 and item != 'pistol'):
                raise ValueError(f'cursor {revision}: expected {item}, got {selected}, arrow={arrow}')
        captions.append(f'{i+1}\n{timestamp(start)} --> {timestamp(end-1)}\n'
                        f'{item.title()}   |   Left: b3f4727c0     Right: shipped melee cursor')
    srt = after / 'wheel.srt'
    srt.write_text('\n\n'.join(captions) + '\n')
    out = master / 'films' / 'cursor_before_after.mp4'
    cmd = ['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y']
    for root in (before, after):
        cmd.extend(['-framerate', '60', '-start_number', '60', '-i', str(root / '%04d.jpg')])
    graph = []
    for i in (0, 1):
        graph.extend([f'[{i}:v]split=2[main{i}][detail{i}]',
                      f'[detail{i}]crop=72:72:585:420,scale=216:216:flags=neighbor[icon{i}]',
                      f'[main{i}][icon{i}]overlay=16:32[side{i}]'])
    graph.append('[side0][side1]hstack=inputs=2[v]')
    cmd.extend(['-i', str(srt), '-filter_complex', ';'.join(graph), '-map', '[v]', '-map', '2:s',
                '-c:v', 'libx264', '-threads', '4', '-crf', '16', '-preset', 'veryfast',
                '-pix_fmt', 'yuv420p', '-c:s', 'mov_text', '-disposition:s:0', 'default',
                '-movflags', '+faststart', str(out)])
    subprocess.run(cmd, check=True)
    probe = json.loads(subprocess.check_output(['ffprobe', '-v', 'error', '-select_streams', 'v:0',
                       '-show_streams', '-show_format', '-of', 'json', str(out)]))
    v = probe['streams'][0]
    if (v['width'], v['height'], v['avg_frame_rate'], int(v['nb_frames']), float(v['duration'])) != (
            1920, 1080, '60/1', 960, 16.0):
        raise ValueError(v)
    (after / 'ffprobe.json').write_text(json.dumps(probe, indent=2))


def timestamp(frame):
    ms = round(frame * 1000 / 60)
    return f'00:00:{ms // 1000:02d},{ms % 1000:03d}'


if __name__ == '__main__':
    assemble(*(Path(arg) for arg in sys.argv[1:]))

