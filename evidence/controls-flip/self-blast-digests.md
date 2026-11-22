# Self-blast replay comparison

| Capture | Default wheel controls | Legacy controls |
| --- | ---: | ---: |
| Archived scenario digest fields matching the new run | 61 / 61 | 61 / 61 |
| Saved or embedded replay tapes matching the archive | 6 / 6 | 6 / 6 |

Each mode was compared with its own pre-change `b2-impact` run in this worktree. The 61 fields include numeric fight hashes and planted-fault hashes. The tape check covers the exported and scratch arena-moves tapes, the embedded Ohm replay, quest 1 input, the 20-second city replay and the 60-second replay. Standalone files were compared byte for byte and the embedded replay by canonical JSON.

The isolated `replay_60s` run and both full suites reproduced `cbeb734ff9b97c41645f735114692ea3b9e7cc6578750f32d8d9f31d69844e85` over 3,600 ticks and 60 checkpoints. The quest 1 input final digest was `37bf8deacaad2f480055af695e77aa9296bb08c4f6b681c57344832333d4664a` in both modes.

The full legacy suite passed 65/65. The default suite passed 63/65 on its first run. The `corpse_horde` step-time check and the `rig_stress` 200-person budget missed. Both passed when rerun together in isolation. The 200-person rig p50 was 1.052 ms in the suite and 0.738 ms in the rerun against a 1.000 ms limit.

## In-memory rocket replay

In `brutality_kills`, Rivet takes 1.005714 fighter HP from his own rocket at combat ticks **66** and **396** in both modes. Each hit changes the HP recorded in the next three checkpoints. Repair restores his health before tick 700, so both final digests match their respective originals. This scenario generates its tape in memory and has no pinned golden to update.

The comparison used the scenario's own arena, input and recording loop twice in each mode. Setting `blast.self_k` to zero reproduces the previous HP behavior. The second run used the shipped value of one. The switch, throw and showcase-director recordings and the brutality lab's homing shard and mini-nuke recordings matched at every checkpoint and at the end.

| Controls | Checkpoint tick | Previous digest | New digest |
| --- | ---: | --- | --- |
| wheel | 120 | `efb7fa086968a949c650dc8a8145d4cb4d8667d26af582791881ccc3939fad7a` | `17686c101803a7f591867cf129a3d685552bf9c45f2345d294b9b3bc7cac3c68` |
| wheel | 180 | `b93b7d14684f2f39f501166b9dcb2b28c74476899b4c6528d3f878ec348aef21` | `569cd3ec02fb2e69d84f8e9c01aa14bd9d9f9f0b688d569e949f693067c5fcc2` |
| wheel | 240 | `83e2a04637e1fa81367cb73540e92189df5e29ada7b080ad810bbb284e2f0344` | `413f5739038c371152cb8df4e970f9738de3a5a2c39623a14871b7eebb60e272` |
| wheel | 420 | `7a477a47409c40b9c0af1b2cdb6c53e3df2cc5ba84a8c454c640f8f3af67e0ab` | `86de09be98f927ac08075c8232be2d844b1a5ca3cfb21aeb48645047fe5f9b4d` |
| wheel | 480 | `7e2045f55af2e89cb21c9cade4d896142022b1883352d16a3cfb15984df6f73c` | `6106f508a34eb032893dda3faf8183c753914048960f992fbe12c71d84daab46` |
| wheel | 540 | `1a8990cb0963c0e5700e4fe5b839124a99a97633943e54ff31042c0c0c0eb15f` | `56086af6fdf9639c08dab2d602068019721c5ba9616d3be62e8c8e71507cc6b4` |
| wheel | 700 (final) | `b9d27ec886eefceb9e096da2dba844f9e5ad10e2a1ac7427607e94e38c2d7738` | identical |
| legacy | 120 | `4a39c48773e429735b7ef6d06432600df6d08aa2ec45fff02fb54042702dadc4` | `ea1c2b5bbdc1059f358a1615e81b66dda51936ebc33c0e9838c7b9afec5b939c` |
| legacy | 180 | `1246a5ed5efb925e8c24a2bc81dae0f836622f38e57773ea873e58a9fe86abab` | `e04ad4b12e325fb1ef5eea68c44e4a3f1223784660a8077634de703b74aaf12a` |
| legacy | 240 | `5f6da4199db0f8a4c5c966b7740d4489de1c1ff0a2df5bb07badf2accabe10df` | `b501592dd73afcdbca3c5d1c6d676abd215cd904049eeba7341a2441a5ebaaeb` |
| legacy | 420 | `5959001a80788d856015436b708679bc020a07e96fe010bd801a1aa2456ca5b7` | `0bf53e9e1a03971e69b35fc714ade8af1535beda698cda0c31f31bf581e38547` |
| legacy | 480 | `5f82c7f77da5cef32132a41cfc790f71ff1ec4421cd6d1caa0dbf8f7b7267793` | `617e776f940a790fea285c32b3988d8a576ea42321d90cfc31f06ed9b970a481` |
| legacy | 540 | `041ee101b79798227043d1f8b8325a861d37ce61dbd9fb67357ec10d940fabd8` | `e8c577ed24f7300baae67525568b0dba2a6aebade8ab30153460359b711b63f5` |
| legacy | 700 (final) | `778ac1c1eccc08639f421af9f37f73a3617a93f5a1d826d6d7ef96930e485a7a` | identical |
