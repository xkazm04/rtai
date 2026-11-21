# Control-mode flip measurement

All 65 scenarios ran headless on the guard branch. Each wheel run supplied the actual OS argument after the Godot separator. A scratch copy of the scenario runner adds one accepted flag. The scenario files, seeds and thresholds are unchanged.

| Run | Passed | Failed |
|---|---:|---:|
| legacy | 65 | 0 |
| wheel-before | 48 | 17 |
| wheel-final | 49 | 16 |

| Scenario | Legacy | Wheel before | Wheel after |
|---|---|---|---|
| arena_city | ok | FAIL | FAIL |
| arena_course | ok | ok | ok |
| arena_pit | ok | FAIL | FAIL |
| arena_range | ok | FAIL | FAIL |
| arena_squad | ok | FAIL | FAIL |
| arena_stations | ok | ok | ok |
| arena_zebra | ok | ok | ok |
| autosave_input | ok | ok | ok |
| autosave_resume | ok | ok | ok |
| bodies_cop | ok | ok | ok |
| bodies_crowd | ok | ok | ok |
| bodies_runin | ok | ok | ok |
| bodies_tackle | ok | ok | ok |
| brutality_kills | ok | FAIL | FAIL |
| car_knocks_rivet | ok | ok | ok |
| city_bake | ok | ok | ok |
| city_chase | ok | ok | ok |
| city_parity_ref | ok | ok | ok |
| city_replay | ok | ok | ok |
| city_scare | ok | FAIL | FAIL |
| corpse_horde | ok | ok | ok |
| crowd_react | ok | ok | ok |
| enemy_pit | ok | ok | ok |
| enemy_waves | ok | ok | ok |
| ghost_attacks | ok | ok | ok |
| gunplay_fight | ok | ok | ok |
| gunplay_fire | ok | ok | ok |
| handheld_focus_pause | ok | ok | ok |
| human_react | ok | ok | ok |
| moves_fuzz | ok | ok | ok |
| moves_replay | ok | FAIL | FAIL |
| moves_street | ok | ok | ok |
| ohm_bolt_delay | ok | ok | ok |
| quest1_dent | ok | ok | ok |
| quest1_dent_lock | ok | ok | ok |
| quest1_input | ok | FAIL | ok |
| quest1_kerf | ok | ok | ok |
| quest1_keys | ok | ok | ok |
| quest1_ohm | ok | ok | ok |
| quest1_tonnage | ok | ok | ok |
| quest_collect_call | ok | ok | ok |
| quest_selftest | ok | ok | ok |
| react_line | ok | FAIL | FAIL |
| replay_60s | ok | ok | ok |
| rifle_rack | ok | FAIL | FAIL |
| rig_stress | ok | ok | ok |
| rivet_chainsaw | ok | FAIL | FAIL |
| rivet_city_fight | ok | ok | ok |
| rivet_city_melee | ok | ok | ok |
| rivet_claw | ok | ok | ok |
| rivet_cover | ok | FAIL | FAIL |
| rivet_deflect | ok | ok | ok |
| rivet_katana | ok | FAIL | FAIL |
| rivet_pickup | ok | FAIL | FAIL |
| rivet_switch | ok | FAIL | FAIL |
| rivet_throw | ok | ok | ok |
| rivet_vault | ok | ok | ok |
| showcase_director | ok | FAIL | FAIL |
| showcase_reel | ok | FAIL | FAIL |
| souls_powers | ok | ok | ok |
| traffic_yields_rivet | ok | ok | ok |
| vehicle_carnage | ok | ok | ok |
| vehicle_doors | ok | ok | ok |
| vehicle_drive | ok | ok | ok |
| vehicle_yield | ok | ok | ok |

## Recorded hashes and digests

Full values below include recorded and planted runs. A dash means the run did not produce that value. The tape SHA-256 columns hash the saved file bytes. The other values are the simulationâ€™s own digests. Additional read-only observer runs print in-memory replay hashes before scenarios discard them. Numbered suffixes denote successive recordings within a scenario. The city bake also verifies every chunk against the same committed list in project/data/generated/city_chunks.sha256.

| Evidence field | Legacy | Wheel before | Wheel after |
|---|---|---|---|
| arena-moves.replay.final_hash | 152d6f323aee587635166ff37ffcd77299ccc386a13b2b2951cb75de285fe5c0 | â€” | â€” |
| arena_city.tape1 | 82fac4fa78037d9b537aab21004f1233ad6237f43676f5b22d0fb6d231896f2b | 86ac353d8952eb7c96f7e9b16aaa5ee066970f7bfdd9ace04759a810e8a071c4 | 46bb9528f6bec52aaac18773ce96d72e072959fb103aa0b1810a377d1b07ecca |
| arena_course.tape1 | 56f2a903f06ea8a67b5fcacd31612026539880b96fa34540e5d467cdefd3345e | 5bdc48bfe88965f3af83b977d8b3948fabe74ee2f3dadbc8d75127c163620832 | 5ddb615c1dca9b2cacddb2bc2c019dfbe8966a5569d07e238945b9e16af508c4 |
| arena_pit.tape1 | de7eb709c6f69239ad37a3d32777f416c3286e2cdfb92ef6114584b3ad515cef | a7ec406aae05bc4a4e99d6b0e26aa78be6c14c759dbe93d41c02cb1a665c3fc6 | 1bd720140d32a8c0c918ca69313adb025b3633a9ea0700a3efac2b1386646940 |
| arena_range.tape1 | f91bee54466967d9b3fc7957f24a45407e5602001cb8a2a0389336187d3a2cfc | 5cc8dea1d0fbb3b19e4980d02e4437f1c2c3a03d0758dba4bfcd5348ab467e55 | c6706ee2e66fbde2f3ed83b3813cf7088a0999523c85f893f2498d3813ea129e |
| arena_squad.tape1 | 08d8c9cb2ce570cd1c325882c4b8179df153642c3d9eeb99bd0c7511e7b63070 | 102dc2cbc95e7b8c698ac0a3f205e8b84a969475294bbda3911afbc10df798ff | 1ec41d874e2bdd8074111d65e94008798193236310065fbc2da33c6e03f02b15 |
| arena_squad.tape2 | a816e38b8beaff5502372e9085ba8e0bb66200664a459bbfc72be58e9165a13a | e45b8065b2397713ef9d1e9469aef713781c9258f85e44554ea9833653d4e4f9 | 158c6d9ced16da56d1f82a96c74990b7a15035ec2e0c9fcf2a0b3515ecf1031e |
| arena_squad.tape3 | be20c7be9abc46f56e5a1c1708141d5d347585483cf9c5464e1cd2c9b64245fe | 8b3b6de338885f40221f3b04151f8b1593e71920be2863b8b77ce91de7e8457d | 38a90ca4ecbec5b51cd59bfc2a988a07e16f7cff337868aec44e6bdd3db411ae |
| arena_squad.tape4 | fe9917462d521fea38d3cb9511bafcdb3842b3065e040db286f9b15686c384f6 | 8d0dfc9e64b6a687e0ca09089fc69627c9523a12002999122ab4960b80cac69b | 5f756d218363677e1ed66d64b4abd4ac4efe24b9562f13922f454ea9d19dcd14 |
| arena_squad.tape5 | f32d5a234fb852136ed0a1d6569e423206a74ce66d3026377e1db8595bd913d2 | aff506bbe7bc06a09cafeb9582cff267fee4ff97d23b10358e35300215137499 | d4f846d4ecc46c5e159e4107e52d6dafba0b8623da8152721ff49c5b41890376 |
| arena_squad.tape6 | 084b50f2cc55099eae73da12a6e5d377ca9027ad64e23d32552382e07cba8435 | 89fd93cc4074ab762aa478c59d0554ff29f31aae136f0379b2586a0f8b7321ab | 910b200c07b8fad171c1b5b5b1256560962faea2b44d1164a351f41c8a438d87 |
| autosave-input.quit_save.hash | d18e6acb534a219c65e6a0b381d4d1d566deb701c8849aa11b72a14d56232aea | c66f059dbaae42d0bd6e928d2bc1e256c17fab7e2dff87c29c3106c4e39f440e | d18e6acb534a219c65e6a0b381d4d1d566deb701c8849aa11b72a14d56232aea |
| autosave-input.saved.as-b2-payphone.hash | 029ccc6ab888422c4dedc8e7c3c55588ffd6ca537e80210a0d0fcb1291004aae | 40ef42e26965a1896269d803c658fb77d2b939406292a391f0c93825439a347e | 029ccc6ab888422c4dedc8e7c3c55588ffd6ca537e80210a0d0fcb1291004aae |
| autosave-input.saved.as-b3-toner-room.hash | f840e893c2dd9e9e4f8650741fe8ee600e3b2c1c0bbb663ac085b60bd1fce79a | dffeee84391eceab675f67175af77fd19da8b392c68b62436ec31b74cb7c161f | f840e893c2dd9e9e4f8650741fe8ee600e3b2c1c0bbb663ac085b60bd1fce79a |
| autosave-input.saved.as-b4-dock.hash | 521f286cfd893d1428068eee6922fd75985ae7b41dc80f6cec52d91810178c3d | 62cdabf8307ad44ab282d927f950e45ae7381110bc80ee4cb3dcddc16d99a4ca | 521f286cfd893d1428068eee6922fd75985ae7b41dc80f6cec52d91810178c3d |
| autosave-resume.reference_final_hash | 7e52ad768b1c7bf3cecf3f3e616cdbf2fdbc4b334ce5086d819f276d08c3a638 | 7e52ad768b1c7bf3cecf3f3e616cdbf2fdbc4b334ce5086d819f276d08c3a638 | 7e52ad768b1c7bf3cecf3f3e616cdbf2fdbc4b334ce5086d819f276d08c3a638 |
| autosave-resume.resumed_final_hash | 7e52ad768b1c7bf3cecf3f3e616cdbf2fdbc4b334ce5086d819f276d08c3a638 | 7e52ad768b1c7bf3cecf3f3e616cdbf2fdbc4b334ce5086d819f276d08c3a638 | 7e52ad768b1c7bf3cecf3f3e616cdbf2fdbc4b334ce5086d819f276d08c3a638 |
| autosave-resume.saved.as-b2-payphone.hash | 4f16b60c30b307111e7a77a17aa0ff997e8dda349e59ae13f031e235ac8d5ea4 | 4f16b60c30b307111e7a77a17aa0ff997e8dda349e59ae13f031e235ac8d5ea4 | 4f16b60c30b307111e7a77a17aa0ff997e8dda349e59ae13f031e235ac8d5ea4 |
| autosave-resume.saved.as-b3-toner-room.hash | 9aad19fdcd26acb9b619400506098ed410d6cdeadf29da6f6e86cad36bc8f64a | 9aad19fdcd26acb9b619400506098ed410d6cdeadf29da6f6e86cad36bc8f64a | 9aad19fdcd26acb9b619400506098ed410d6cdeadf29da6f6e86cad36bc8f64a |
| autosave-resume.saved.as-b4-dock.hash | 990b6f80ca86a08e07981963454f622d279703aa2250f922fe2545d2b6462576 | 990b6f80ca86a08e07981963454f622d279703aa2250f922fe2545d2b6462576 | 990b6f80ca86a08e07981963454f622d279703aa2250f922fe2545d2b6462576 |
| autosave-resume.tampered_hash_and_other_corrupt.notice | Your saves could not be read. Starting the quest from the start. | Your saves could not be read. Starting the quest from the start. | Your saves could not be read. Starting the quest from the start. |
| autosave-resume.tampered_hash_and_other_corrupt.status | 1 | 1 | 1 |
| brutality_kills.tape1 | 231be97fa14f04ab77e2e6f87a07864bd6ada9a6897501e8819627b182ecc4a5 | 988b27154cb74521b50006d5996de0ff6b5039fb955d52eb979d44014169bff0 | f066d173aafae354b00d3ba607dcb235f677d3d387b6436cda4f71af17f661de |
| brutality_kills.tape10 | 33073e3bf288aa52e21f0f96cac7ebbffa4f055b569d423ca41aaf30fee84c29 | â€” | â€” |
| brutality_kills.tape11 | 7eb22df0b57abdcb6f1d9c568fcf9905cd6caa56ae0684199699e8633eb488c4 | â€” | â€” |
| brutality_kills.tape12 | 06476ed8ec37c4c88ecbe9278daff27e2dfd74748472ed1c3622de4d89bb3b42 | â€” | â€” |
| brutality_kills.tape13 | fe2e08ff5f95dc2ecfdea735942c6b0223fc894b0f291eefd368d917a86b3db2 | â€” | â€” |
| brutality_kills.tape14 | 0ac52e4bf7301fb2cb6bfeb4126aaf28cb9c6e967e55bc2fd63c778b48de6b16 | â€” | â€” |
| brutality_kills.tape15 | 865ddb152b93ce2ffc00f12f45807bd79a61f599fa45f976f0b146ea87dfa2b5 | â€” | â€” |
| brutality_kills.tape16 | ec9cdb4675877838033d6be148498d49fb0c94a0a9f56b975b553ea6a9aded9a | â€” | â€” |
| brutality_kills.tape17 | 9faa0b741e3f7c90cf6bd5c9467ac9b294332585b05450137bc45ac2760d2f90 | â€” | â€” |
| brutality_kills.tape2 | ef22f0385b2b0f2a8b6ea5723d1dd18f4b1d97d0b2ba8d66101a30c961fe8e32 | â€” | â€” |
| brutality_kills.tape3 | 7387fa675005f5c20ff4e59325bb5fb70e25d79740f6781e1e16b835a67c66ce | â€” | â€” |
| brutality_kills.tape4 | 4969bfa35896f06ad010a443a323d810ad67bf807ecd536db4ac299985fcf4cc | â€” | â€” |
| brutality_kills.tape5 | de37c338f7455f3255804060c95f0b19673eeefed3ea6550e9f84bf6990f7934 | â€” | â€” |
| brutality_kills.tape6 | 21c08cf2f3912f9ba73ea675afe3191b23ef493d4be61fa395b7b473dbe6cabf | â€” | â€” |
| brutality_kills.tape7 | 36485c131ce6d32764bf7ad1d422143f581f1a413cb3daa7d2a53918a1e15e0b | â€” | â€” |
| brutality_kills.tape8 | 6110c3742a2c615582594326cc028cc3aa3d24e6689c0b39703f116fd0cc2b1a | â€” | â€” |
| brutality_kills.tape9 | 0a2f5a92794e4660d74d54e572eda7d66c727ef5e35c352c2fa696d937b183d0 | â€” | â€” |
| city_20s.file_sha256 | 89758a9d678a18151d6b30ba339792a95c60ecda98c1e4eb0550addacfdfe366 | 89758a9d678a18151d6b30ba339792a95c60ecda98c1e4eb0550addacfdfe366 | 89758a9d678a18151d6b30ba339792a95c60ecda98c1e4eb0550addacfdfe366 |
| city_20s.final_hash | 7571fcfe027f9994d8cc511bd321fd4cbaeb43a07f679eaae1ab088dbac97892 | 7571fcfe027f9994d8cc511bd321fd4cbaeb43a07f679eaae1ab088dbac97892 | 7571fcfe027f9994d8cc511bd321fd4cbaeb43a07f679eaae1ab088dbac97892 |
| city_bake.verified_golden_list_sha256 | 4a92471cca416299d1fe88a7de4950ae9343c8f39fa9af0f534d0be497bbf60f | 4a92471cca416299d1fe88a7de4950ae9343c8f39fa9af0f534d0be497bbf60f | 4a92471cca416299d1fe88a7de4950ae9343c8f39fa9af0f534d0be497bbf60f |
| city_scare.tape1 | 122efdb9ea027442e265e84cab988fff775c7a11915b669723485b9056821481 | 2111132f7b55c6df10079516d308ab63aff6e4c3f2f905d6b4165cc6f01cf646 | fbdf8296fe2a98644735f95f877983a7aec67415525f36ce05d84e511b3b3d8d |
| corpse_horde.tape1 | 033c94531bd68c92b7a03273b8523cb7c98f3d9dcc3851317b24e495f3c79e0b | c176c9a70eac0b7bd2f227cfd919736a3aa205f0795bbbf40e7657e9f3d6fdc0 | 2565ac51e98261a7638ffa5f7606b91010131fa71c6a3c2928248a778599db08 |
| crowd-react.digest_again | 1457941746 | 1457941746 | 1457941746 |
| crowd-react.planted_no_startle.digest | 2464648745 | 2464648745 | 2464648745 |
| crowd-react.planted_no_trip.digest | 3770557908 | 3770557908 | 3770557908 |
| crowd-react.run.digest | 1457941746 | 1457941746 | 1457941746 |
| enemy-pit.archetypes.patrol_cop.digest | 2278425bd72395d5 | 2278425bd72395d5 | 2278425bd72395d5 |
| enemy-pit.archetypes.riot_cop.digest | 7506d3b598f6f0bb | 7506d3b598f6f0bb | 7506d3b598f6f0bb |
| enemy-pit.archetypes.robot_gunner.digest | 3466f303a4b24a84 | 3466f303a4b24a84 | 3466f303a4b24a84 |
| enemy-pit.archetypes.robot_thug.digest | 24091d6db6911a32 | 24091d6db6911a32 | 24091d6db6911a32 |
| enemy-pit.archetypes.swat.digest | afb807e2771a2bea | afb807e2771a2bea | afb807e2771a2bea |
| enemy-pit.determinism.a | c706f7c549ec2a9d | c706f7c549ec2a9d | c706f7c549ec2a9d |
| enemy-pit.determinism.b | c706f7c549ec2a9d | c706f7c549ec2a9d | c706f7c549ec2a9d |
| enemy-pit.determinism.other_seed | dbdd12d071feee47 | dbdd12d071feee47 | dbdd12d071feee47 |
| enemy-pit.dodge.digest | 4bb94517ab15696b | 4bb94517ab15696b | 4bb94517ab15696b |
| enemy-pit.planted_no_lock.digest | 43fc1f7c974d7167 | 43fc1f7c974d7167 | 43fc1f7c974d7167 |
| enemy-pit.planted_no_squad.digest | eb97fd1d072baffa | eb97fd1d072baffa | eb97fd1d072baffa |
| enemy-pit.squad.digest | 7c19364dca3c7832 | 7c19364dca3c7832 | 7c19364dca3c7832 |
| enemy-pit.stand.digest | 0bcd9f994b3d745a | 0bcd9f994b3d745a | 0bcd9f994b3d745a |
| enemy-waves.curves.gentle.digest | 7f6c041cf9739a12 | 7f6c041cf9739a12 | 7f6c041cf9739a12 |
| enemy-waves.curves.standard.digest | 852d4365eeff57a3 | 852d4365eeff57a3 | 852d4365eeff57a3 |
| enemy-waves.curves.steep.digest | a2eca1619e189de6 | a2eca1619e189de6 | a2eca1619e189de6 |
| enemy-waves.planted_overlap.digest | be3e05901843819c | be3e05901843819c | be3e05901843819c |
| enemy-waves.replay | a2eca1619e189de6 | a2eca1619e189de6 | a2eca1619e189de6 |
| ghost_attacks.dent1 | c5dbb7d49fdbeab9189e3ed4eb94c33faed0418f73691c4965525e1841a2b449 | 1f04cc6fcbe813a03f7029cc20285db3500cfe646a32d61afcee00add73dc920 | cd46f25c4c965057e013c6b21549152827caab5ecf20f6c7687ec3fdaa36f35a |
| ghost_attacks.kerf1 | 909398d41cfd37a5a00d02f9a1b2dc3aed9bfd747bf45d95f0237df577cc71e3 | 7755cd73ffc1278a1b717221a192705e3f15e2c665e7ea2aace236925df6e112 | 5affa250d35d293843f24538c35712374a6f46896ccdf7e573d2b6dd6272455d |
| ghost_attacks.ohm1 | 729b9ff923eebb18e2313db37b4a106bb81c69cd585843a0a5d9122ad80806b6 | 9e8a63af91ed356f3a9489ed1cde1eac85ffc3c0c3bbfc6967ff2173ceb22267 | 9f4269857aa6a4afef755e47adcf145adbabd979ead47ab754b571a767802ae1 |
| ghost_attacks.tonnage1 | 8f90cb5cafdccfb088505d4c1a1b4a32635313e611f3c67ebbbe7be19d3c129b | ad9348e5db083e333895083c9cb45b660796216367d382d30bbb7e3775f751a4 | bfbc215ae815ba3961935fdb92eb22a870a3c1cedbefed5ce6e1745b9d8f0b1d |
| gunplay-fight.electro_gun.hash | 442811266 | 442811266 | 442811266 |
| gunplay-fight.electro_gun.planted_hash | 3468331012 | 3468331012 | 3468331012 |
| gunplay-fight.flamethrower.hash | 1696583415 | 1696583415 | 1696583415 |
| gunplay-fight.flamethrower.planted_hash | 1505607827 | 1505607827 | 1505607827 |
| gunplay-fight.hand_cannon.hash | 3825860695 | 3825860695 | 3825860695 |
| gunplay-fight.hand_cannon.planted_hash | 4256868849 | 4256868849 | 4256868849 |
| gunplay-fight.homing_shard.hash | 183419567 | 183419567 | 183419567 |
| gunplay-fight.homing_shard.planted_hash | 575585865 | 575585865 | 575585865 |
| gunplay-fight.machine_pistol.hash | 417852881 | 417852881 | 417852881 |
| gunplay-fight.machine_pistol.planted_hash | 4142379438 | 4142379438 | 4142379438 |
| gunplay-fight.mini_nuke.hash | 2315154757 | 2315154757 | 2315154757 |
| gunplay-fight.mini_nuke.planted_hash | 2338294040 | 2338294040 | 2338294040 |
| gunplay-fight.molotov.hash | 2220288831 | 2220288831 | 2220288831 |
| gunplay-fight.molotov.planted_hash | 3146451663 | 3146451663 | 3146451663 |
| gunplay-fight.pistol.hash | 342267790 | 342267790 | 342267790 |
| gunplay-fight.pistol.planted_hash | 3987697359 | 3987697359 | 3987697359 |
| gunplay-fight.plasma_rifle.hash | 925341807 | 925341807 | 925341807 |
| gunplay-fight.plasma_rifle.planted_hash | 3577135787 | 3577135787 | 3577135787 |
| gunplay-fight.ray_gun.hash | 3958852990 | 3958852990 | 3958852990 |
| gunplay-fight.ray_gun.planted_hash | 3898718619 | 3898718619 | 3898718619 |
| gunplay-fight.rocket_launcher.hash | 2529842700 | 2529842700 | 2529842700 |
| gunplay-fight.rocket_launcher.planted_hash | 3445292942 | 3445292942 | 3445292942 |
| gunplay-fire.determinism.electro_gun[0] | 4080357602 | 4080357602 | 4080357602 |
| gunplay-fire.determinism.electro_gun[1] | 4080357602 | 4080357602 | 4080357602 |
| gunplay-fire.determinism.electro_gun[2] | 2639321056 | 2639321056 | 2639321056 |
| gunplay-fire.determinism.flamethrower[0] | 886076436 | 886076436 | 886076436 |
| gunplay-fire.determinism.flamethrower[1] | 886076436 | 886076436 | 886076436 |
| gunplay-fire.determinism.flamethrower[2] | 1784422757 | 1784422757 | 1784422757 |
| gunplay-fire.determinism.machine_pistol[0] | 1829670528 | 1829670528 | 1829670528 |
| gunplay-fire.determinism.machine_pistol[1] | 1829670528 | 1829670528 | 1829670528 |
| gunplay-fire.determinism.machine_pistol[2] | 747632813 | 747632813 | 747632813 |
| gunplay-fire.determinism.molotov[0] | 62522396 | 62522396 | 62522396 |
| gunplay-fire.determinism.molotov[1] | 62522396 | 62522396 | 62522396 |
| gunplay-fire.determinism.molotov[2] | 3514076845 | 3514076845 | 3514076845 |
| gunplay-fire.determinism.pistol[0] | 314566697 | 314566697 | 314566697 |
| gunplay-fire.determinism.pistol[1] | 314566697 | 314566697 | 314566697 |
| gunplay-fire.determinism.pistol[2] | 697145214 | 697145214 | 697145214 |
| gunplay-fire.determinism.rocket_launcher[0] | 2390821752 | 2390821752 | 2390821752 |
| gunplay-fire.determinism.rocket_launcher[1] | 2390821752 | 2390821752 | 2390821752 |
| gunplay-fire.determinism.rocket_launcher[2] | 2435003715 | 2435003715 | 2435003715 |
| human-react.digest[0] | 1400046892 | 1400046892 | 1400046892 |
| human-react.digest[1] | 1400046892 | 1400046892 | 1400046892 |
| moves_fuzz.city | 358603ac0a1f5d6c4d842a79a195b56fd61c01899a6b533a710bce763d41b13d | 6d16e885ac9d78c0253b6782e2dc8d97e6df8eb1eb1f277c2361d88773ff909b | 65d1ff9217a904dbb57e2f60356a49f2b136d1d7a9acf5aaab7344e1e6b740e2 |
| moves_fuzz.off | 7e01f1233503c50e841634d9731ac7cc925de19924da4ea750c5bb7f74bdd985 | 7e01f1233503c50e841634d9731ac7cc925de19924da4ea750c5bb7f74bdd985 | 7e01f1233503c50e841634d9731ac7cc925de19924da4ea750c5bb7f74bdd985 |
| moves_fuzz.pit | 80b0fc6e33a608e4cfcc9df58b2b5844b77d5a745853edcec068d5cfcd8226d4 | b2b4e0d6af15673afe3978178fa0751c95aba67ac0fb49d7de451be37f308a1e | b2c08aff63e01c0b187d6517e09802f0547ebec0e9ff4a31d1df87476c2f1965 |
| moves_street | 98ec51a0b77d667666bdb7be2565519bbbb07eff96bebee9c252c7afc026233c | 6a13cc7e9935b26e812bb9f603636c39deece4a7fb76bfe022bfaa2c3c36c3a2 | 98ec51a0b77d667666bdb7be2565519bbbb07eff96bebee9c252c7afc026233c |
| ohm-bolt-delay.cast_hashes[0] | 15db432e0757a96d05dd4605845170f4fe6597973feeef1166323ba336bb2bab | 15db432e0757a96d05dd4605845170f4fe6597973feeef1166323ba336bb2bab | 15db432e0757a96d05dd4605845170f4fe6597973feeef1166323ba336bb2bab |
| ohm-bolt-delay.cast_hashes[1] | 42799ff1a4a508da92c40962645212868f4df28141cfd3c2b7d0f072b79f20ac | 42799ff1a4a508da92c40962645212868f4df28141cfd3c2b7d0f072b79f20ac | 42799ff1a4a508da92c40962645212868f4df28141cfd3c2b7d0f072b79f20ac |
| ohm-bolt-delay.cast_hashes[2] | 68f0a7dbbccc71ad181d92d7bef9f18b86fcbb8390af83d224a3429b483a064a | 68f0a7dbbccc71ad181d92d7bef9f18b86fcbb8390af83d224a3429b483a064a | 68f0a7dbbccc71ad181d92d7bef9f18b86fcbb8390af83d224a3429b483a064a |
| ohm-bolt-delay.cast_hashes[3] | 00c2615ee48ef4c7b5e2973aa1eb79040acb49c1631a78a9251a56484b994e07 | 00c2615ee48ef4c7b5e2973aa1eb79040acb49c1631a78a9251a56484b994e07 | 00c2615ee48ef4c7b5e2973aa1eb79040acb49c1631a78a9251a56484b994e07 |
| ohm-bolt-delay.cast_hashes[4] | d61eca9bffd6bc9f9d28d4ba040a6a6ed1d9e863726c8477146b6f99f9f84684 | d61eca9bffd6bc9f9d28d4ba040a6a6ed1d9e863726c8477146b6f99f9f84684 | d61eca9bffd6bc9f9d28d4ba040a6a6ed1d9e863726c8477146b6f99f9f84684 |
| ohm-bolt-delay.replay.final_hash | d61eca9bffd6bc9f9d28d4ba040a6a6ed1d9e863726c8477146b6f99f9f84684 | d61eca9bffd6bc9f9d28d4ba040a6a6ed1d9e863726c8477146b6f99f9f84684 | d61eca9bffd6bc9f9d28d4ba040a6a6ed1d9e863726c8477146b6f99f9f84684 |
| quest-collect-call.evidence_sha256 | 0be37fbda3bd56397ba4ebed391b7adca5787aa36b98948526fcd6597167f689 | 0be37fbda3bd56397ba4ebed391b7adca5787aa36b98948526fcd6597167f689 | 0be37fbda3bd56397ba4ebed391b7adca5787aa36b98948526fcd6597167f689 |
| quest-collect-call.stateHash | 7e52ad768b1c7bf3cecf3f3e616cdbf2fdbc4b334ce5086d819f276d08c3a638 | 7e52ad768b1c7bf3cecf3f3e616cdbf2fdbc4b334ce5086d819f276d08c3a638 | 7e52ad768b1c7bf3cecf3f3e616cdbf2fdbc4b334ce5086d819f276d08c3a638 |
| quest-selftest.stateHash | 55865ee8edb4fe94b274183cc321462bf093b31c12e35c5cb8a491688cf41db6 | 55865ee8edb4fe94b274183cc321462bf093b31c12e35c5cb8a491688cf41db6 | 55865ee8edb4fe94b274183cc321462bf093b31c12e35c5cb8a491688cf41db6 |
| quest1-dent-lock.evidence_sha256 | 7dd8253bd9f5ede15f16e378a592fbbb81415a9fbb5deafb177810123d8fab8a | 7dd8253bd9f5ede15f16e378a592fbbb81415a9fbb5deafb177810123d8fab8a | 7dd8253bd9f5ede15f16e378a592fbbb81415a9fbb5deafb177810123d8fab8a |
| quest1-dent.hash | f78884a9a891f968c14284a49debc963832e39ab22954f03a5a1acb7512b6822 | 13fd3ac273cdeeb3490492baa4747e080e8630cc30d3abbdfc0576be28ac3184 | f78884a9a891f968c14284a49debc963832e39ab22954f03a5a1acb7512b6822 |
| quest1-input.final_hash | 37bf8deacaad2f480055af695e77aa9296bb08c4f6b681c57344832333d4664a | 7cb7efb9c1c6253cce9995ae5a4c50cb55b8b3866d4524e5d9ba86fc4cc99157 | 37bf8deacaad2f480055af695e77aa9296bb08c4f6b681c57344832333d4664a |
| quest1-input.tape_sha256 | af44e7c7f5f9e9da0caadd29e1d6fdbdf9ad330aeea2f4d7d8e8360cd1a4e68a | d811c5df7ef83e448659c88565fbec3cc80fe77e539bfa4fe541a7d281ccce6e | af44e7c7f5f9e9da0caadd29e1d6fdbdf9ad330aeea2f4d7d8e8360cd1a4e68a |
| quest1-kerf.hash | 26fa9dc079c55392da7f59496025abe932e5703ae1b0182cfc66fc88f96844dc | 1bf825c1416fb7d4e0fb84b01701075a57021cd98cf8e9e96974b768897b7422 | 26fa9dc079c55392da7f59496025abe932e5703ae1b0182cfc66fc88f96844dc |
| quest1-ohm.hash | fd2779b3c87a24f445bfbb31f26848462d777f3772c0a13899ea3da13ebdd57d | 4bf763b5674dd89ea163a450f22a0cff4a265c219ae299aa735833fc43be0d40 | fd2779b3c87a24f445bfbb31f26848462d777f3772c0a13899ea3da13ebdd57d |
| quest1-tonnage.hash | f11db19e3375686e98a60fb3267849a31b38cf0e9c3a865fcc9e6ca8e367fee7 | c20705f8ff6da48ac001e70a23f18be675de4f53534c7e8c754e7a4d0c33d76f | f11db19e3375686e98a60fb3267849a31b38cf0e9c3a865fcc9e6ca8e367fee7 |
| react_line.tape1 | 66bfe8fa498158be3d23826e5b4d1c98c319082104ffcd5ad47f90ddb02cf66f | 3a7dd066f1ed099bdc9679cd1ba2822475525892bab386c07c7a88d3f1e5ce86 | 2b2f1546467b7d085d461a41116e1c2aceea478bd74ad14d5897c5745e44bb0a |
| replay_60s.file_sha256 | 73e204a23a6b82a9fcc2cfcf0bc2f025e647b1a0001c86df9499099510d318ed | 73e204a23a6b82a9fcc2cfcf0bc2f025e647b1a0001c86df9499099510d318ed | 73e204a23a6b82a9fcc2cfcf0bc2f025e647b1a0001c86df9499099510d318ed |
| replay_60s.final_hash | cbeb734ff9b97c41645f735114692ea3b9e7cc6578750f32d8d9f31d69844e85 | cbeb734ff9b97c41645f735114692ea3b9e7cc6578750f32d8d9f31d69844e85 | cbeb734ff9b97c41645f735114692ea3b9e7cc6578750f32d8d9f31d69844e85 |
| rifle_rack.tape1 | 04150bcf493cdbdd9544044c6b07c4a8d4118a22c8e570851b39c9eddd07aaa1 | 665719e5083c15f3254461a0fbaf8c84fbfb8cdac260ec6e678851d2ff37d94d | cd11790a79786eb35c47e206b57d7cfcaec3fdfccbf5e484273a80f68c98818a |
| rifle_rack.tape2 | 539ecbebccc0110be87b1270c7e4659c0f9322611b486f702b9472b3b99d1056 | â€” | â€” |
| rivet_chainsaw.tape1 | 87c3074fc348d5b134baddb8f73bc52ebc0d364975d721e497c2d34111fa503f | e8c99517e3979059cbe725f5100b889cb48e49ec1777aa3a7a2c9f95ba14dfac | 4038ee6a05c11b619499d6d242b9f584f20bc536c0f1dd71baddae0c78385d7c |
| rivet_city_fight.tape1 | 1c2cb37b80d676f1d268a6dfbad54e3507f1639286e8b57ef9178893f07d8a4a | 00f237ef8e2643ca3281c66511a98f7f05b894febfef0b683e0bbc62bab0caa3 | cf5bc5546b54b6ba7da8681a93597f9d98883cfd967de3bf596e14a90b665f81 |
| rivet_city_melee.tape1 | cf66e949742254f55a5641fdfbcdb1076bc515ae1f0b66cbee9199564c680092 | cae36e4393bf922a18a0d0aeb8dcf0ff48a58cfc676c5745b08c60869a8e52ca | 5fda289ced2c1691ab5c5d5971d01dae67e041799cc9a0ce4363b90c8c94b6b5 |
| rivet_claw.tape1 | d288159185644124c21d62a7250eb27df9f2582536778162e8436e64481486f7 | c19cc45b85dc085953e7772f847c59e435f77d672182d5c5f34ddac96ff62cc1 | d2867df7cf67e247d8c3e1d69dc1a986029ef2a97e05a7d605c27e3cb3265ed3 |
| rivet_deflect.tape1 | d4907e1c10125244a1c8f442c06b15a26d8d002399d3c2c7245e8d01ce2a9169 | 0aab5fd8721beb72b2778c8c9aea138ec5f36aa497db1c7b3f116e8ea3d3f645 | 4352a44470140d68f6ba237fb842cfb9745b557caefca284a81da77f039fd7ae |
| rivet_katana.tape1 | 124677b8e9b8aec7a65a25e6943067bb13f1424a885d60da8c8f15168f97f682 | 9e92b3c136fc9819ef539752b493d9762cf74aea72235390cf276db6f10fea41 | 4038ee6a05c11b619499d6d242b9f584f20bc536c0f1dd71baddae0c78385d7c |
| rivet_pickup.tape1 | 61a6e7fbd64ff6cda6b086c7d62bf6392f65e6f5188cd89201285a0dc198f7f2 | a41dcb1ca5ab42da76ca64db8ba9d414e618996b9631cd90cbb0a2e60ba2689e | 214dd1a04a7d5003d968ce63c33d9f212657e4f229f95d605bf987dc5fc8253f |
| rivet_switch.tape1 | 9aab067dbc0d535f8bd6249ca5e0ea4cad493b6c2cca7c8c305341abb6605111 | b5ed5ee8c047c5cfbd319f9963521e3871a4b0ac97aeb26603d6f20e50c9b907 | 8a0d3e8670f1b6cebf69fc513dc8c61da5bb7c57acda30480e232f1b47cd041c |
| rivet_throw.tape1 | 0dd72cb30a50d625da8048f5f0716489f453a54f15dcd58517c9f3b6e0dd69d2 | 0119b72db1ebdc2a783c343f846ea8e14f230f46530f01a017c3acffa2438fd0 | e65e473c51c3b45b7a6fe6346c44fd45beec1db5b8e8f598055da6ad3b0fb86e |
| rivet_vault.replay1 | bb48cfc4a1dbff23119392a40fbf1075132697f819ad615a880d1ae6a3a713ba | bb48cfc4a1dbff23119392a40fbf1075132697f819ad615a880d1ae6a3a713ba | bb48cfc4a1dbff23119392a40fbf1075132697f819ad615a880d1ae6a3a713ba |
| scenario.cover | 4b8ed38e1fb2fce993ee8881e172de598872a22645a1b17cba09e8e5f21cd1a5 | â€” | â€” |
| scenario.vehicle_doors | 36555d6dc09f424f27bb609eef98d667fe96ad4683ac3284529893f88589de66 | 36555d6dc09f424f27bb609eef98d667fe96ad4683ac3284529893f88589de66 | 36555d6dc09f424f27bb609eef98d667fe96ad4683ac3284529893f88589de66 |
| showcase_director.tape1 | 772b7abaf5927afe9dc29567c1a4d2959b7638d22deb1a918c257bd7100672aa | 46bd3a19b7ed3b5056b19fb049403d1607b57fad3e22f7a7d7b3848920a05771 | a927585bedb7fba99f0e722bc080cf4ededc4d4d12f2197525244b9b691bee32 |
| showcase_reel.tape1 | 7f2c08dec78c0d7bca2cc1799d9556e6a561b64828647475f1439234da33a3e3 | e9f7fcd1a21e880b57a6798305e6c70c9a8feee3e88df406574d780dc9033aa7 | fb9579129014e67abdfa0440642b4070cefe72b40b4bd3252bfb4f5109e6a70a |
| vehicle_carnage.tape1 | 6f2503c8f3bde8a80a7a41ed4eead3d27bf6ae6888125ed7272653e67935ad6a | 6f2503c8f3bde8a80a7a41ed4eead3d27bf6ae6888125ed7272653e67935ad6a | 6f2503c8f3bde8a80a7a41ed4eead3d27bf6ae6888125ed7272653e67935ad6a |
| vehicle_drive.tape1 | a66330d61fb992b45b22e81102595e13303dbb9045666c554fd5c89141f71765 | a66330d61fb992b45b22e81102595e13303dbb9045666c554fd5c89141f71765 | a66330d61fb992b45b22e81102595e13303dbb9045666c554fd5c89141f71765 |

## Cross-mode comparison

Fields that differed before Part B and now match legacy exactly:

- autosave-input.quit_save.hash
- autosave-input.saved.as-b2-payphone.hash
- autosave-input.saved.as-b3-toner-room.hash
- autosave-input.saved.as-b4-dock.hash
- moves_street
- quest1-dent.hash
- quest1-input.final_hash
- quest1-input.tape_sha256
- quest1-kerf.hash
- quest1-ohm.hash
- quest1-tonnage.hash

Fields still different under wheel:

- arena_city.tape1
- arena_course.tape1
- arena_pit.tape1
- arena_range.tape1
- arena_squad.tape1
- arena_squad.tape2
- arena_squad.tape3
- arena_squad.tape4
- arena_squad.tape5
- arena_squad.tape6
- brutality_kills.tape1
- city_scare.tape1
- corpse_horde.tape1
- ghost_attacks.dent1
- ghost_attacks.kerf1
- ghost_attacks.ohm1
- ghost_attacks.tonnage1
- moves_fuzz.city
- moves_fuzz.pit
- react_line.tape1
- rifle_rack.tape1
- rivet_chainsaw.tape1
- rivet_city_fight.tape1
- rivet_city_melee.tape1
- rivet_claw.tape1
- rivet_deflect.tape1
- rivet_katana.tape1
- rivet_pickup.tape1
- rivet_switch.tape1
- rivet_throw.tape1
- showcase_director.tape1
- showcase_reel.tape1

Legacy supplemental observer values were read after Part B. Legacy gameplay and serialization are independently checked against the original run and the pre-wheel pilot pin. A failed scenario can stop before computing its final digest. The recorder may still have a tape available in the observer run.

## Replay bytes and Quest 1

| Measure | Legacy | Wheel before | Wheel after |
|---|---|---|---|
| ticks | 19024 | 15728 | 19024 |
| shots | 65 | 8 | 65 |
| kills | 49 | 8 | 49 |
| paid | 1500 | 0 | 1500 |
| verdict | pass | not paid: state failed at beat b4-dock, tick 15728 | pass |
| Quest 1 input tape | 38100 bytes | different bytes | identical bytes |
| 60 s tape | 11825 bytes | identical bytes | identical bytes |
| 20 s city tape | 2360 bytes | identical bytes | identical bytes |
| quest1-dent.json evidence | reference | different bytes | identical bytes |
| quest1-dent-lock.json evidence | reference | identical bytes | identical bytes |
| quest1-kerf.json evidence | reference | different bytes | identical bytes |
| quest1-ohm.json evidence | reference | different bytes | identical bytes |
| quest1-tonnage.json evidence | reference | different bytes | identical bytes |
| quest-collect-call.json evidence | reference | identical bytes | identical bytes |

The city_replay scenario covers 1,200 ticks across native and GDScript. replay_60s covers 3,600 ticks of DummyRun and 60 checkpoints. Neither uses StagePilot. quest1_input drives the live pilot. quest_collect_call uses CollectCallBot.

## Final verification

- Final commit: dcb9ee5d778aa1bfbcdeb656cd99dc30ea009ba6
- run_scenarios: 65 ran, 0 failed
- unit-tests: 3459 passed, 0 failed, 2 skipped (GUT, headless)
- Shot: score 68.4% = killed 13 / (killed 13 + survived 6); timeout 0, invalid 1; 477 s
- RivetWheelStory before extra coverage: score 75.0% = killed 15 / (killed 15 + survived 5); timeout 0, invalid 0; 316 s
- RivetWheelStory after extra coverage: score 100.0% = killed 20 / (killed 20 + survived 0); timeout 0, invalid 0; 345 s
- The stock unit CLI rejects --controls=wheel (exit 2). The full wheel-mode unit gate was skipped as the brief permits. The RMB tests set their mode explicitly.
