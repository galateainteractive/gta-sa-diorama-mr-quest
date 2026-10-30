# Diorama MR controls and tutorial adaptation

This is the maintenance reference for Diorama MR input. It records what the
player is taught, what the Quest controllers actually send to GTA, which
Android touch widgets are bridged, and which ids must remain untouched.

The audited retail target is GTA San Andreas Android 2.11.311. Diorama changes
are runtime-only: GXT files, mission scripts and save data remain unmodified.
Immersive VR keeps its tracked/manual interaction paths.

## Production architecture

There are three complementary layers:

1. `native/src/Xr.cpp` adapts known tutorial text. Semantic `~widget_*~`
   markers work in every language because the original sentence is retained.
   Screen-region prose without a marker is replaced only by exact verified
   English sentences.
2. `native/src/VrCamera.cpp` snapshots Quest input before GTA's `UpdatePads`
   and answers only the touch widget GTA is polling. Held, pressed, released
   and double-tap queries receive the corresponding real controller level or
   edge. This preserves the retail mission/minigame state machines.
3. Existing `CPad` bridges remain authoritative for ordinary movement,
   combat, vehicles and radio. `native/src/Driving.cpp` forces conventional
   vehicle weapons and an `R3` horn in Diorama; parachutes likewise force the
   conventional stick/button path. Tracked risers, manual vehicle weapons,
   physical pickups and similar full-size interactions remain Immersive-only.

If a context widget bound to `R3` is being polled, that widget owns `R3` through
a short 400 ms freshness window. The window covers retail script opcodes that
run after `UpdatePads`; the on-foot selector and `L3 + R3` view chord wait,
preventing a horn, camera, crane or mission action from opening the selector.

## Fixed Quest layout

| Control | Ordinary Diorama action |
| --- | --- |
| Left Stick | Walk/swim; steer; aircraft pitch/roll; contextual cursors |
| Right Stick | Weapon-selector direction; vehicle turret; camera zoom |
| `A` | Jump, handbrake, parachute deploy, accept/start |
| `B` | Sprint/swim, vehicle weapon/nitro, cancel/exit |
| `X` | Classic attack; next radio station in a vehicle; grab/drop |
| `Y` | Enter/exit vehicle; reset/split in the relevant minigame |
| `L2` | Aim, brake/descend, decline/remove/easier |
| `R2` | Fire, accelerate/ascend, accept/buy/place/harder |
| `L3` | Crouch |
| `R3` | On-foot weapon selector; contextual horn/camera/machinery action |
| `L3 + R3` | Cycle `TRACK`, `FOLLOW`, `FIXED` views |
| Left Grip + `X` | Previous radio station |
| Left/Right Grip + `B` | Fire the matching side vehicle weapon |
| Both Grips + `B` | Cancel mission/minigame prompt |
| Both Grips + `R2` | Answer the phone |
| Both Grips + Menu or `Y` | Open/close the Diorama menu |
| Menu without grips | Open GTA's stock pause/map frontend |

Freefall uses `R2` for the accelerated dive and `A` to deploy the canopy.
After deployment the Left Stick controls the canopy. Diorama ignores the
Immersive-riser preference so a saved Immersive setting cannot remove the
classic fallback.

## Contextual retail widget map

The numeric ids below come from the retail 2.11 `CTouchInterface::DrawHelpIcon`
name chain. The bridge is an explicit allowlist; never replace it with a range.

| Area | Retail widget ids and Diorama controls |
| --- | --- |
| Core/vehicle | enter `0=Y`; accelerate `2=R2`; brake `3=L2`; handbrake `4=A`; steer `5/6=Left Stick`; horn `7=R3`; sprint `31=B`; dive `33=X`; swim `34=B` |
| Social/gang | gift `9=A`; kiss `10=A`; recruit `106=R2`; follow `108=R2`; hold `109=L2`; yes `110=R2`; no `111=L2` |
| Vehicle specials | hydraulics `12/13=R3`; crane drop `14=R3`; item drop `15=X`; side fire `16/17=matching Grip+B`; camera `18=R3`; vehicle shoot `21=R2`; air gun/rocket `23/24=B`; bomb `25=R3`; turret `26/27=Right Stick`; nitro `30=B` |
| Arcade/meter | button `37=A`; power off `38=B`; reset `39=Y`; joystick `40=Left Stick`; meter tap `43=A`; rhythm exit `102=B`; ITB/video-poker exit `149/134=B` |
| Camera/race | zoom `50/51=Right Stick up/down`; race `52/53=Left Stick left/right`; thumb circle `164=rotate Left Stick` |
| Store | purchase `28=A`; accept `54=A`; cancel/back `55/56=B`; buy `57=R2` |
| Casino | roulette `58-61=Left Stick directions`; place/remove bet `62=R2`, `63=L2`; quit/continue `89=B`, `90=A`; blackjack split/double/hit/stand `91=Y`, `92=X`, `93=A`, `94=B` |
| Machinery | crane/magnet up `44/46=R2`; down `45/47=L2`; grab `66=X`; magnet/stinger `67/68=R3`; train next station `42=R3` |
| Missions/school | skip cutscene `41=A`; mission/vigilante/minigame start `69/70/73=A`; cancel `71/72/74=Both Grips+B`; school exit/left/right/continue `75=B`, `76/77=Left Stick`, `79=A` |
| Activities | basketball shot `87=R2`; gym easier/harder `48=L2`, `49=R2` |

Widget `6` is the terminal right-steer case in the same audited retail chain;
the disassembly reaches it through the final fall-through rather than the
ordinary immediate-id pattern.

### Dedicated bridges

These controls intentionally stay outside the generic table because their
scripts or native pad lifecycle need special handling:

- `8` phone: Both Grips + `R2`, with the existing ringing-flow guard;
- `19` target: complete `L2` press/hold/release lifecycle plus direct `CPad`
  targeting; `R2` attacks independently while aiming;
- `29` weapon switching: the Diorama `R3` owned-weapon selector;
- `156/160` HUD/stats tutorials: bounded `R2` windows, never a permanent hold;
- `166` radio swipe: direct `X`/Left Grip + `X` station bridges;
- `187` parachute deploy: dedicated release query and deploy-phase guard.

### Forbidden broad mappings

- `161` can open pause/radar. Forcing it previously opened the game menu. Its
  text marker is safely labelled `MENU`, but the numeric widget is not faked;
  the existing plain Menu-button path opens the stock frontend.
- `167` is the live movement region.
- `175` is used as a live look/sprint/double-tap region depending on script.
- `0/1` were historically guessed as generic screen zones. Retail 2.11 proves
  `0` is enter-car, but `1` attack remains on the direct classic combat path.

Do not add any of these ids to a generic range or to the heuristic yes/no pair
detector. A new id must be tied to a retail name and tested in its real script.

## Tutorial text coverage

Semantic labels cover 120 of the 124 retail names in the audited chain: the
core layout plus flight, stores, casino, gym,
school, arcade, vehicle weapons, cranes, magnets, radio, gang commands and
minigame exits. Examples include `~widget_store_buy~ -> R2`,
`~widget_black_jack_hit~ -> A`, `~widget_camera~ -> R3` and
`~widget_thumb_circle~ -> ROTATE LEFT STICK`.

Exact English mobile sentences currently cover:

- moving, sprinting, jumping/climbing, crouching, swimming and diving;
- bicycle mounting, pedalling, weight shifting and bunny hop;
- weapon selection, melee, lock-on, manual aim, looking and firing;
- touch-stick/finger-flick vehicle steering and radio swipes;
- helicopter/aircraft thrust, ascent, level-off and speed maintenance;
- wheelies, leaning and accelerated freefall.

The final-font prefilter recognizes widget markers and the verified phrases
(`tap`, `swipe`, screen corners/sides/centre, finger flick and thumb wording).
Unknown candidates are logged once as
`[tabletop.tutorial] mobile-unmapped` and rendered unchanged. Successfully
adapted text has no repeated `DIORAMA MR TIP` prefix.

The four intentionally unlabelled retail names are
`widget_explicit_look_back_keyboard`,
`widget_explicit_toggle_landing_gear`, `widget_look_left` and
`widget_look_right`. The first two do not yet have a proven Diorama action;
the latter pair share dangerous live region `175`. They must stay original
until a real pad bridge is implemented and tested. The GXT audit also leaves
purely descriptive screen text and Android control-layout/menu labels alone.

Set `debug.savr.diorama_tutorials=0` before process launch to disable only the
final text adapter for an A/B comparison.

## Historical decisions

- Package 56 introduced Diorama-only semantic replacement and a narrow exact
  English allowlist at the copied OpenXR help-text boundary.
- Package 57 added the brief-text path, verified bicycle lessons and the
  two-page in-headset control guide.
- Package 60 added large-message coverage, made the guide the first Controls
  row and added menu discovery/reminder behavior.
- Packages 61-63 were diagnostic passes: enqueue, stored buffers, then the
  audited final `CFont::PrintString` boundary. They proved visible tutorials
  can bypass earlier queues.
- Package 64 promoted the final-font hook to the conservative production
  adapter and retained a process-start escape hatch.
- Package 65 added verified opening tutorials and safe `Tap` normalization.
- Package 66 removed the temporary queue/buffer diagnostics while retaining
  the final adapter and once-per-unknown reporting.
- Package 74 removed the repeated branded prefix while preserving all control
  substitutions and GTA colour markers.
- The current complete pass adds the audited contextual widget allowlist,
  wider exact mobile wording, R3 conflict ownership, and forced classic
  vehicle/parachute fallbacks.

## Review and extension checklist

1. Capture the exact visible text and the widget id/name polled by the retail
   script. Never infer an id from adjacency alone.
2. Choose an existing Quest control that is free in that context.
3. Add the runtime mapping in `ControlForTabletopWidget` first.
4. Add the matching label in `kWidgetLabels` or an exact full sentence in
   `kExactHelpTexts`; do not rewrite generic prose by keyword.
5. If the control is `R3`, preserve contextual ownership over the selector.
6. Add a static contract to `tools/test-tabletop-effects.ps1`.
7. Run `git diff --check`, the tabletop-effects suite against the verified
   `libGame.so`, and an ARM64 native build.
8. Validate press, hold and release in the real mission/minigame on Quest;
   confirm no action leaks after the prompt closes.
