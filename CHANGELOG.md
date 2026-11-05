# Changelog

## Unreleased — complete Diorama contextual controls

- Put Build storage first in the Windows installer. Android-phone extraction
  now follows it as step 2 and automatically writes the verified split set to
  the already-selected `<Build storage>\exports` folder.
- Wait up to 45 seconds for the selected Quest serial to reconnect after the
  pinned ADB server restarts. Temporary missing, offline and unauthorized
  states no longer fail a completed personal build after a single probe.
- Separate the installer's game-source and build-storage steps, rename existing
  source actions explicitly, and give status text DPI-safe vertical space.
- Let the Windows installer persist a user-selected build-storage folder for
  downloads, tools, phone exports, build runs and backups. It now reports free
  space up front and blocks a new export/build below the required 15 GB instead
  of failing during payload staging on a full system drive.
- Fix the intermittent BMX bunny-hop `SIGILL` by replacing the unsafe generic
  trampoline with a fingerprinted bridge that preserves both retail branch
  continuations.
- Keep retrying Guardian suppression until the Quest runtime explicitly reports
  the boundary as suppressed; accepted requests alone are no longer treated as
  proof that the boundary disappeared.
- Restore the proven single-subtitle cutscene path: the theater keeps GTA's
  original subtitle and does not draw a second direct-XR copy. Gameplay help,
  tutorial and stat text remain unchanged.
- Anchor the automatic `DIORAMA MR MENU` reminder to the same `LOCAL` space,
  orientation and depth as GTA's frontend screen, placing its compact cropped
  banner directly below that screen. It no longer follows head rotation, and a
  Meta recenter moves the frontend and reminder together; full SAVR menus keep
  their existing head-locked presentation.
- Keep `L3 + R3` exclusive to `TRACK`/`FOLLOW`/`FIXED` cycling in Diorama.
  The legacy simultaneous recenter now remains Immersive-only, allowing the
  existing continuous-transition compensation to preserve the miniature's
  position, rotation and scale; the Meta button remains Diorama's recenter.
- Add a `DIORAMA GUARDIAN` menu preference backed by
  `XR_META_boundary_visibility`. Boundary suppression is requested only while
  Diorama MR is focused and after `xrEndFrame` has successfully submitted its
  passthrough layer. A rejected request retries every 30 real passthrough
  frames; Immersive VR, focus loss, passthrough shutdown and unsupported
  runtimes all keep or restore the Quest boundary.
- Declare only the contextual `BOUNDARY_VISIBILITY` permission. Do not mark the
  whole APK as boundaryless, because the same installation also contains the
  Immersive VR mode.
- Keep the spray can and extinguisher out of GTA's fixed-heading targeting task
  in Diorama. Holding `R2` now runs their continuous attack while the Left
  Stick remains available, and an explicit forward target prevents the hidden
  mobile camera from turning the jet behind CJ.

- Recover the retail 2.11 touch-widget name/id map and bridge verified mobile
  mission, store, casino, gym, school, arcade and vehicle/machinery actions to
  the existing Quest controls only while GTA polls their widget.
- Keep press, hold and release semantics frame-coherent, give a live contextual
  `R3` action temporary priority over the plain-R3 weapon selector, and keep
  pause/radar (`161`), movement (`167`) and look/sprint (`175`) regions outside
  the allowlist. The explicit `L3 + R3` Diorama view chord remains available in
  vehicles even while GTA continuously polls `R3` for the horn.
- Expand verified mobile tutorial translations for swimming, climbing, aiming,
  radio, vehicles, aircraft, wheelies and freefall. Displayed labels now match
  the implemented contextual action.
- Force conventional vehicle weapons, `R3` horn and stick/button parachute
  control in Diorama even when an Immersive preference was saved. Immersive VR
  keeps its tracked/manual interactions.
- Add `DIORAMA_CONTROLS.md` as the consolidated history, control map, safety
  rules and future-review checklist.
- Keep Diorama coverage fixed at the proven 60 m radius and render ordinary
  road traffic beyond 30 m through GTA's intact low-LOD vehicle path. Nearby
  traffic, the player vehicle, boats and aircraft retain full detail; this
  removes the battery-power GPU collapse without relying on a USB connection.

## Package 74 concise Diorama tutorials

- Remove the repeated `DIORAMA MR TIP` prefix from adapted gameplay tutorial
  cards. The verified Quest-control translations and GTA colour markers remain
  unchanged, while the messages now read like concise in-game instructions.
- Keep the Welcome page, persistent Diorama menu reminder and all other
  Galatea/Diorama branding unchanged. Immersive VR remains untouched.

## Package 73 retire black-shrub diagnostics

- Remove the Package 72 `ProcObjectMan` source suppression after headset
  testing showed that the crossed-card shrubs remained unchanged. Restore the
  normal procedural-object generation path in Diorama MR.
- Retire every controller selector, model/atomic filter and plant colour/blend
  experiment from Packages 67 and 69-72. Production retains only the proven
  player-centred plant coverage update; there is no shrub diagnostic work or
  periodic telemetry left running.
- Record the five eliminated renderer families in the technical notes. Any
  future investigation must start with visual evidence that identifies the
  exact texture/material or GPU submission, rather than another broad A/B.

## Package 72 direct ProcObject source suppression

- Retire the Package 71 final-atomic selector after headset testing exposed
  only one or two candidates and neither affected the crossed-card shrubs.
- Add one build-level, fingerprint-guarded test at
  `ProcObjectMan_c::ProcessTriangleAdded`. In Diorama MR it prevents retail
  procedural objects from being generated at their source, avoiding every
  later ambiguity involving entity wrappers, missing atomic model IDs or draw
  callbacks. Installation/relaunch naturally starts with an empty procedural
  object set; no controller sequence is required.
- Keep Immersive VR untouched. The test performs no frame logging, modifies no
  assets or saves and will be removed after the headset comparison.

## Package 71 procedural-plant final-atomic isolator

- Retire the Package 70 nearby-scenery isolator after headset testing traversed
  every candidate without affecting the crossed-card shrubs. This proves that
  the target bypasses the ordinary opaque/alpha entity wrappers.
- Read GTA's model index at the final RenderWare atomic callback and admit only
  the bounded retail procedural family (IDs 800-906) plus `grasshouse` (3261)
  and `grassplant` (3409). Houses, roads, vehicles, pedestrians and unrelated
  scenery can no longer enter this diagnostic list.
- Keep the same deliberate controls: the first `Both Grips + X` captures the
  visible procedural IDs, later presses hide one exact model at a time, and
  `Both Grips + B` restores everything. The test resets on launch, is active
  only in Diorama MR and performs no periodic logging.

## Package 70 nearby-scenery model isolator

- Remove the completed Package 69 procedural/static vegetation A/B. Headset
  testing proved that the crossed-card shrubs in front of Grove Street houses
  belong to neither tested renderer family.
- Add a process-local nearby-scenery isolator. The first `Both Grips + X`
  starts a bounded 35-metre capture; after a short wait, the second press sorts
  the visible scenery models by distance and hides only the nearest candidate.
  Further presses advance one model at a time and display its model ID plus
  `OPAQUE`, `ALPHA` or `OPAQUE+ALPHA` path.
- `Both Grips + B` immediately restores the complete scene. Collection uses a
  fixed 96-entry array only while explicitly armed, excludes pedestrians and
  vehicles, writes one event per command and never touches saves or Immersive VR.

## Package 69 bounded plant-renderer A/B

- Add one temporary, process-local headset comparison for the unresolved black
  shrubs. `Both Grips + X` cycles `ORIGINAL`, `NO PROCEDURAL` and
  `NO STATIC VEGETATION`, with a four-second status line and haptic confirmation.
- `NO PROCEDURAL` skips only the fingerprint-verified retail
  `CGrassRenderer::DrawTriPlants` submission. `NO STATIC VEGETATION` skips the
  existing audited model family 615-792 in both opaque and alpha entity paths.
- Reset to `ORIGINAL` on every launch and write only one log line when the mode
  changes. No colour, alpha, blend state, save, game logic or Immersive VR path
  is modified by this diagnostic.
- Headset validation showed the crossed-card shrubs did not change in either
  suppression mode. Package 70 therefore retires this A/B and moves to exact
  nearby-model isolation.

## Package 68 retire ineffective procedural-plant experiment

- Remove the Package 67 `CGrassRenderer::DrawTriPlants` colour/blend wrapper
  after headset validation showed no visible change to the black shrubs. This
  restores the original GTA plant draw path instead of retaining an unproven
  hook in production.
- Preserve the Package 67 Release telemetry cleanup. Scene-identity,
  alpha-depth, mask-window, stereo-ring, passthrough-audit and mask-health
  witnesses remain `SAVR_DEV`-only; production keeps only genuine errors and
  one-time setup reports.

## Package 67 experimental procedural-plant guard and quiet Release telemetry

- Attempt to fix the solid-black low shrubs reproduced in the opening Grove Street scene.
  The official procedural-plant renderer is hooked only after its 2.11.311
  address and prologue match. In active Diorama stereo, near-zero plant RGB is
  temporarily raised to GTA's live ambient colour, then the original plant
  bytes are restored immediately after the draw. Headset testing later showed
  that these shrubs use a different rendering path, so Package 68 removes this
  experiment.
- Save and restore RenderWare source blend, destination blend and vertex-alpha
  state around the same procedural draw. This prevents a plant transition from
  inheriting an opaque state while leaving Immersive VR and ordinary world
  entities untouched.
- Compile the former scene-identity, alpha-depth, mask-window, stereo-ring,
  passthrough-audit and mask-health witnesses only in `SAVR_DEV`. Production
  keeps fail-closed error reporting and one-time setup messages, but no longer
  performs those per-frame aggregations or periodic two/five-second reports.

## Package 66 persistent GTA-menu Diorama discovery

- Replace the unreliable timed gameplay reminder with a persistent transparent
  banner over GTA's own frontend and pause-menu theater screen. Every menu visit
  now shows a large `DIORAMA MR MENU` heading and
  `HOLD BOTH GRIPS + MENU (OR Y)` at the bottom without covering the menu.
- Cache the banner in the existing OpenXR panel swapchain. Its pixels upload
  only when a swapchain image first needs the fixed content, not every frame.
- Retire the Package 61-63 production diagnostics: remove the enqueue hook,
  the per-frame scans of brief/big/ten help buffers and the scoped render logs.
  The required final-font adapter remains fingerprint-guarded and uses one
  bounded ASCII prefilter; unknown touch tutorials log only once per phrase.

## Package 65 first-session reminder and opening tutorials

- Keep the centred Diorama-menu reminder pending while the one-time Welcome
  page is open. A new installation now shows the five-second
  `BOTH GRIPS + MENU (OR Y)` hint as soon as the Welcome closes and CJ becomes
  controllable, instead of incorrectly treating the Welcome as the reminder.
- Add exact official-English mappings for the opening Android instructions:
  move Carl with the Left Stick, sprint with `B`, open the weapon selector with
  `R3`, and perform a melee attack with `X`.
- Add proven mappings for camera view (`L3 + R3`), yes (`R2`) and no (`L2`).
  Android `Tap` becomes `Press` only after a known semantic widget was replaced.
- Observe unknown final-font `Tap`, `Touch`, `Swipe` and weapon-icon cards once
  in diagnostics while preserving their original text for safe future mapping.

## Package 64 final Diorama tutorial adapter and guide-first Controls

- Turn the verified retail `CFont::PrintString` boundary into a conservative
  Diorama-only adapter. The global hook changes only known Android touch
  tutorial phrases or semantic `~widget_*~` control markers; all other GTA
  text continues through the original render call unchanged.
- Prefix successfully adapted cards with `DIORAMA MR TIP` and retain GTA's
  colour markers for the stock font renderer. Unknown mobile-style candidates
  are logged once and remain untouched. Set
  `debug.savr.diorama_tutorials=0` before launch to disable this final adapter.
- Show the Diorama menu chord once per application session in a dedicated
  top-centre notice for five seconds, independently of the movable timer HUD.
- Make **Controls** open the active mode's guide first. `A` opens the secondary
  **Customize Controls** page and `B` returns to the main menu; the guide and
  remapping remain mode-specific.

## Package 63 touch-render tutorial capture

- Intercept the verified retail `CFont::PrintString` entry and inspect only
  calls returning from `CWidgetHelpText`'s audited ARM64 code range. This sees
  the final GXT string at the exact moment Android's touch tutorial is drawn,
  after Packages 61 and 62 proved that visible prompts can bypass both the
  enqueue function and the later copied HUD buffers.
- Leave every unrelated HUD, subtitle and menu font call on the normal path.
  The hook preserves the retail draw call, is Diorama-only for diagnostics and
  fails closed unless the official 2.11.311 offset and prologue both match.

## Package 62 direct tutorial-buffer capture

- Diagnose the final text state directly instead of relying on the Package 61
  enqueue hook. Diorama MR now records each distinct occupied value from the
  brief-message buffer, all eight large-message styles and all ten mobile-help
  queue slots, including strings written without `AddMessageToQueue`.
- Deduplicate by channel, slot and text hash with a bounded 512-entry history.
  Empty buffers remain free and occupied buffers add only a small diagnostic
  scan; retail text, rendering and Immersive VR remain unchanged.

## Package 61 complete mobile tutorial capture

- Observe GTA Android's common `CWidgetHelpText::AddMessageToQueue` boundary in
  Diorama MR and log each distinct tutorial string once. Any mobile tutorial is
  now sufficient for diagnosis; testing no longer depends on catching the
  short bicycle card or timing a live logcat session around a cutscene.
- Keep this pass diagnostic-only: it does not rewrite the retail queue, add
  per-frame work or affect Immersive VR, and it fails closed unless the exact
  verified 2.11.311 symbol offset and ARM64 prologue match.
- Start the standard diagnostic capture at the current device time rather than
  replaying the entire historical logcat buffer. Short tutorial tests can now
  begin immediately and the BAT may remain open during ordinary play.

## Package 60 tutorial delivery and menu discovery

- Put the mode-specific **Diorama Control Guide** at the first row of the
  Controls page, ahead of remapping and layout options.
- Keep the full Welcome as a one-time mod-install message, while showing a
  compact `HOLD BOTH GRIPS + MENU (OR Y)` reminder once per application
  session when controllable Diorama gameplay begins. Starting a new GTA save
  no longer needs to reset the persistent Welcome flag for the menu chord to
  remain discoverable.
- Apply the Diorama tutorial adapter to GTA's large-message channel in addition
  to brief/help text. This covers early bicycle lessons that bypassed the two
  previously intercepted HUD paths.
- Make the verified bicycle translations tolerant of GTA formatting markers
  while retaining narrow phrase matching. Add channel-labelled, once-per-text
  diagnostics for any remaining mobile screen-region wording without creating
  a per-frame logging cost.

## Package 59 unobtrusive Diorama objective cones

- Replace the filled red/yellow/blue stock objective cone with a hollow
  tabletop-only outline: a perimeter plus four guide ribs preserves the
  official colour and position without hiding the bicycle, vehicle, person or
  prop being identified.
- Reduce cone opacity from 58% to 34% and reduce its distance-driven minimum
  angular footprint. Mission-area cylinders and optional highlight cages keep
  their established presentation.
- Keep Immersive VR's filled stock marker unchanged. The new outline remains a
  late stereo navigation overlay, avoiding the terrain/building occlusion that
  previously made official markers disappear at some Diorama zoom levels.

## Package 58 first-run identity and upstream credit

- Use the complete **GTA San Andreas Diorama MR** name in the first-run
  welcome.
- Explain directly that Diorama MR is the default, that Immersive VR remains
  available through `Main Menu > Play Mode`, and that a restart applies the
  selection.
- Credit **Galatea Diorama Mods** for Diorama MR and identify the immersive
  foundation as **GTA San Andreas VR Quest** by its original port
  contributors, while keeping the full provenance and links in About/README.
- Keep the welcome focused by pointing to the two-page control guide instead
  of repeating individual gameplay shortcuts.

## Package 57 tutorial coverage and readable control guide

- Adapt both GTA HUD tutorial channels while Diorama MR is active, so early
  mission lessons no longer bypass the Quest-control translation merely
  because the retail game publishes them as brief text instead of help text.
- Correct the opening bicycle lesson to teach the actual Diorama controls:
  `Y` mounts the bicycle, holding `R2` pedals, the left stick shifts weight,
  and `A` performs a bunny hop. Immersive VR and retail GXT data remain
  untouched.
- Replace the crowded single-page Diorama command list with two colour-grouped
  pages for on-foot/Diorama and views/vehicles. `L2` and `R2` select a page;
  `A` or `B` returns to Controls.
- Separate the automatic first-run welcome from the full About page. New
  players now see only menu discovery, play-mode restart behaviour, the path
  to the control guide, and the three essential Diorama shortcuts.
- Keep the first-run audio path unchanged pending a live capture of the rare
  fresh-install-only stutter; the verified audio payload itself is complete.

## Package 56 Diorama-aware tutorial controls

- Translate GTA Android's semantic touch-widget markers into the proven Quest
  controls only while Diorama MR is active. Targeting, attacks, crouch, jump,
  sprint, vehicle entry, weapon selection, phone prompts, supported minigames,
  swimming, bicycles and basic vehicle/aircraft prompts now retain their
  original prose and language while displaying controller labels.
- Keep Immersive VR and GTA's original GXT/script data untouched. The adapter
  changes only the copied OpenXR help string and leaves every unrecognised
  instruction on the retail fallback path.
- Replace a small allowlist of verified English screen-region instructions for
  crouch, parachute deployment and climbing out of water. Exact full-sentence
  matching prevents ordinary dialogue or unrelated uses of words such as
  `tap`, `screen` or `press` from being rewritten.
- Add bounded `[tabletop.tutorial]` diagnostics for adapted and still-unmapped
  help messages, emitted once per distinct message so normal play has no
  per-frame logging cost.

## Unreleased — Diorama MR publication preparation

- Update the Windows installer to shared core 1.3.2. After PowerShell reports a
  completed, verified installation, a detached ADB server can no longer leave
  the interface permanently busy by retaining its redirected output handle.
  Hash-qualified source-kit folders also let a newer installer coexist safely
  with an older installer window that has not been closed yet.
- Make the Windows installer name the exact supported LibertyCity download in
  the audio step: **Original plan mod pack** (1.41 GB), file
  `gta-sa-ps2-style-mod-pack_1786856007_737162.7z`, explicitly excluding
  CLASSIC ADVANCED v1.0 and v1.1.
- Detect a running SideQuest process before downloads or compilation begin,
  with a direct instruction to close its tray process instead of failing after
  the lengthy personal build.
- Retain completed personal builds after a device-stage failure and expose an
  **Install latest completed build (no rebuild)** action. The retry rechecks
  every APK and payload hash before touching the Quest.
- Extract pinned ZIP toolchains through the verified 7-Zip binary on Windows,
  avoiding the legacy .NET path-length failure seen in fresh installer work
  directories while retaining SHA-256 verification and managed-root guards.
- Rebuild the Galatea Windows installer on shared installer core 1.2.0, adding
  automatic live Quest USB detection for disconnected, authorization-pending,
  offline, and ready states without requiring repeated manual refreshes.
- Make the mod menu discoverable before publication: the automatic first-run
  welcome now gives the both-grips + `Menu` (`Y` fallback) chord a dedicated
  high-contrast callout, and the public Quick Start/control documentation
  repeats it while distinguishing the mod menu from GTA's pause menu.
- Add a Galatea-branded Windows installer profile for the reusable private
  installer engine. It can export the official Google Play split set from an
  authorized Android phone or accept an existing export, collect the verified
  audio source, and run the fail-closed personal builder against a selected
  Quest.
- Keep the public installer free of Rockstar APKs, game data, audio and signing
  keys. The generated executable embeds only ADB and a reviewed open-source
  source-kit snapshot, obtains explicit SDK/signature consent, streams logs,
  preserves the existing verified save/settings backup transaction, and leaves
  GTA stopped after installation.
- Adopt **GTA San Andreas Diorama MR** as the public project name while
  retaining the existing `tabletop` configuration, source and diagnostic
  identifiers for compatibility.
- Record the upstream MIT project and exact imported baseline explicitly in the
  public documentation and notices.
- Preserve Package 48 unchanged as the local `archive/pacote-48` safety branch
  before publication work.
- Add a root-menu **PLAY MODE** selector that safely persists **DIORAMA MR** or
  **IMMERSIVE VR** for the next restart without switching a live OpenXR session.
- Replace the legacy immersive-only About title and control-tips page with
  Diorama MR branding and mode-correct Quest controls.
- Point the one-click source updater at the independent Diorama MR repository
  instead of replacing a Diorama checkout with the immersive upstream project.
- Add a consolidated English feature and control overview to the public README,
  covering the accumulated Diorama MR work from the package history.
- Introduce **Galatea Diorama Mods** as the mixed-reality mod-series signature,
  credit **Galatea Interactive** as its parent, and show the signature in the
  public README and the in-headset Welcome/About panel.
- Make local Windows launchers and diagnostics independent of the project's
  drive letter, and replace machine-specific package-guide paths with a
  portable `<project-root>` placeholder.
- Add a safe Windows first-run validation helper that hash-verifies a local
  save/settings backup before removing only the VR configuration files.

## Package 55 compact radial weapon labels

- Give long weapon names dedicated short labels on the selector ring, including
  `BAT`, `DEAGLE`, `FLAMER`, `EXTING.` and `NV GOGGLES`, preventing collisions
  with neighbouring entries and the centre information.
- Keep the complete weapon name in the highlighted centre block, so no item
  identity or detail is lost when navigating the compact controller overlay.

## Package 54 in-headset Diorama control guide

- Replace the inherited mixed control-tips page with a current Diorama guide
  covering `R3` weapon selection, `L3 + R3` camera cycling, Meta recenter,
  classic attacks, targeting, grabs, the fixed 60-metre radius and vehicles.
- Explain `TRACK`, `FOLLOW` and `FIXED` directly in the headset and state that
  the right stick does not rotate the Diorama scene.
- Point Welcome/About to `Menu > Controls > Guide`, rename the guide entry for
  the active play mode and identify Diorama's structural shortcuts as fixed so
  they are not confused with ordinary remappable face-button actions.

## Package 53 raised high-contrast weapon selector

- Raise the compact selector six centimetres farther above the right controller
  so it no longer overlaps the rendered hand.
- Expand the radial weapon-label spacing while retaining the Package 52 panel's
  smaller physical footprint, keeping peripheral names clear of the centre
  selection and ammunition text.
- Render the selector through fully opaque brighter glyphs with a thin dark
  outline. The overlay remains transparent, but its labels stay readable over
  bright or colourful GTA map and HUD content.

## Package 52 compact selector and current-frame camera transitions

- Reduce the physical right-controller weapon selector substantially while
  enlarging its surrounding weapon names relative to the selected centre name
  and bringing the radial entries closer together.
- Reconstruct the outgoing `TRACK`, `FOLLOW` or `FIXED` anchor from the live
  current frame before changing modes. This removes the remaining small map
  correction caused by inheriting a one-frame-old player or vehicle position.
- Reserve right-stick scene rotation for immersive VR. In Diorama MR the map
  rotates through the two-grip gesture, while the stick remains available to
  the weapon selector and keeps its existing aircraft-control paths.

## Package 51 controller selector, continuous cameras and classic melee

- Move the owned-weapon selector from the large head-locked compositor card to
  a compact transparent panel above the right-controller status display. Its
  texture updates only when inventory or selection changes.
- Preserve the complete physical miniature transform while cycling `TRACK`,
  `FOLLOW` and `FIXED`. The new mode begins from the exact table pose already
  visible instead of invoking a full recenter and moving the map.
- Bridge Diorama's classic attack input into GTA Android's separate
  `CPad::GetMeleeAttack` held query and `MeleeAttackJustDown` edge query. `X`
  now starts and continues unarmed and held-melee attacks even without a target.

## Package 50 radial text weapon selector

- Add a lightweight on-foot Diorama MR weapon selector. Press `R3` to open it,
  point at one of CJ's owned weapon slots with the right stick, and press `R3`
  again to equip and close. Selecting the current weapon only closes it.
- Render the first version through the existing low-cost head-locked text panel,
  showing the selected weapon and ammunition without new image assets or a new
  render pass. Gameplay sticks, triggers, grips and face buttons are neutral
  while the selector is visible.
- Move production camera cycling to `L3 + R3`. Preserve plain `L3` crouch and
  all fixed-view one/two-grip manipulation.
- Follow Meta's ordinary system recenter: once OpenXR reports that the new
  `LOCAL` reference-space origin is effective, recenter the diorama on the live
  player/vehicle and re-latch headset-relative locomotion.
- Explicitly link Android's static libc++ runtime and ABI support so native
  builds remain reliable when the SDK path contains spaces, including the
  migrated `F:` workspace.

## Package 49 production diorama views

- Fix normal-play world coverage to the proven 60 metre radius around CJ or the
  current vehicle. Preserved settings from 30, 75 or 120 metres are migrated in
  memory on startup, and the connected/two-island experiments are no longer
  reachable through controller shortcuts.
- Keep two-grip physical diorama resizing independent from the 60 metre
  game-world radius.
- Assign plain `R3` to cycle `TRACK`, `FOLLOW` and `FIXED` camera modes. Each
  change recentres on the live player, refreshes locomotion direction and shows
  a two-second English status line.
- Preserve plain `L3` crouch and `L3 + R3` recenter. Limit the legacy
  both-grips + `R3` vehicle-camera shortcut to immersive VR.
- Update the in-headset controls page and technical documentation for the
  production layout.

## Package 48 deep-water tabletop mask

- Preserve GTA's transparent water surface inside the tabletop radial fade
  when the opaque seabed lies much farther below it. The compositor now tests
  the view ray against a retail-confirmed water plane instead of applying the
  radius at the seabed position.
- Limit the correction to water positively returned by GTA beneath the live
  player/vehicle anchor and to pixels with real scene depth below that surface.
  Clear-depth sky remains transparent, and land/object rendering, streaming
  radii and immersive VR are unchanged.
- Carry the water plane in the same synchronized stereo snapshot as the eye
  textures and mask transform. Add the process-start A/B property
  `debug.savr.tabletop_water_mask=0` for an exact fallback comparison.

## Package 47 cutscene surround and tabletop aircraft

- Submit passthrough behind GTA's finite story-cutscene video quad, leaving the
  video itself opaque and readable while replacing the black room surround.
  Menu and loading presentation keep their Package 45/46 behavior.
- Force fixed-wing pitch to the conventional left stick while tabletop is
  active, regardless of a persisted immersive-yoke setting. `R2` accelerates;
  pulling the left stick back raises the nose.
- In `Track`/conveyor view, latch altitude when entering an airplane or
  helicopter and follow only its horizontal translation. The ground remains at
  table height while the aircraft visibly climbs; recentering establishes a
  fresh altitude reference.

## Package 46 passthrough loading and tabletop startup defaults

- Start gameplay in the translation-following `Track`/conveyor view, which keeps
  the miniature centred without rotating the room when CJ or a vehicle turns.
- Start at the farthest/smallest tabletop scale (`0.010`). Personal updates
  migrate only the exact former shipped `0.040` value, preserving any other
  custom scale and the process-level debug override.
- Replace GTA's opaque flat loading surface with passthrough alone when loading
  is positively identified and the passthrough backend is active. If it is not
  available, keep the original loading surface as a safe fallback.
- Keep cutscene/story video presentation unchanged on its theater quad with a
  black surround, and keep the Package 45 menu-over-passthrough presentation.
- Remove the experimental custom 3D beacon for a pause-map user waypoint after
  headset testing. Preserve pause-map grip zoom and every official red, yellow
  and blue world/mission marker.

## Package 45 passthrough behind GTA menus

- Retire the successful manual weather-palette preview and restore plain `R3`
  to its normal tabletop radius-preset cycle. Keep the stronger automatic dawn,
  cloud and rain palettes from Package 44.
- Present the existing opaque theater quad over passthrough while GTA's boot
  frontend or in-game pause/map menu is open, leaving the surrounding room
  visible instead of black.
- Publish the retail mobile-menu state from GameThread through an atomic
  snapshot; the XR presentation thread never reads GTA frontend memory.
- Limit the new composition path to a successfully rendered game-surface menu.
  Cutscenes, shop interfaces and black stereo-recovery fallbacks retain their
  previous presentation.

## Package 44 stronger dawn and wet-weather passthrough

- Strengthen dawn warmth after the Package 43 headset preview showed that the
  original palette was readable but too restrained.
- Move overcast and rain closer to the approved fog character: markedly lower
  saturation and contrast, slightly darker output and restrained cool tint,
  avoiding the same bright/white fog finish.
- Make automatic cloud and rain response begin earlier during GTA's gradual
  transitions. Preserve a clear-weather dead zone so ordinary daytime
  passthrough remains neutral.
- Keep the temporary plain-`R3` palette preview for another headset comparison;
  the final entry still returns control to automatic GTA weather.

## Package 43 manual passthrough weather palette preview

- Temporarily assign plain `R3` in tabletop gameplay to a deterministic colour
  preview: neutral, dawn, sunset, night, overcast, rain, fog, sandstorm and back
  to automatic GTA clock/weather control. Existing chorded `R3` actions keep
  priority and are unchanged.
- Drive the preview through the production passthrough palettes and the same
  gradual OpenXR style path used by automatic weather, isolating palette/output
  validation from GTA weather-global detection.
- Promote `[tabletop.passthrough.weather.preview]` and the bucketed
  `[tabletop.passthrough.weather.applied]` transition to release telemetry. No
  per-frame logging or additional render pass is introduced.

## Package 42 bounded XR slowdown diagnostic

- Expose one compact release-build `[tabletop.perf42]` aggregate per second,
  using counters already collected for adaptive pacing. It correlates GTA frame
  production with OpenXR presentation, runtime CPU/GPU frame time, compositor
  waits, application work, `xrEndFrame`, repeated frames, synchronization/fence
  waits and scene pressure.
- Report once at startup whether Quest exposes the META CPU/GPU performance
  counters, and report only event-driven OpenXR performance/thermal warning and
  recovery transitions.
- Add no per-frame logging, file output, GL query, runtime query or rendering
  change. Preserve Package 41 graphics, controls, passthrough and game data.

## Package 41 Quest controller ergonomics and aim release

- Change the shipped on-foot Quest layout to `A` jump, `B` sprint, `X`
  alternate attack and `Y` enter/exit. Migrate only the exact old default in
  the preserved locomotion configuration; keep custom mappings untouched.
- Return plain `L3` to GTA's crouch toggle and move tabletop view cycling to
  left grip + `L3`. Keep `R3` radius, right grip + `R3` coverage and
  `L3` + `R3` reset.
- Publish L2 enter/exit-targeting edges to every consumer in the exact GTA
  frame rather than consuming them on the first query, so releasing L2
  reliably lowers the weapon. Reserve tabletop `R2` for aimed fire instead of
  simultaneously treating it as sprint.

## Package 40 controller combat and nearby-ped correction

- Route tabletop `L2` through GTA SA Android's native `CPad::GetTarget`,
  `GetEnterTargeting` and `GetExitTargeting` functions. This covers controller
  missions such as the bottle tutorial, which never poll `widget_target`.
- Make `L2` + `R2` feed the classic attack path without requiring a recent
  touch-widget poll; keep `B` as the alternate attack and retain vehicle/grab
  isolation.
- Keep pedestrians within 25 m of either the tabletop camera or CJ in the
  omnidirectional render safety, preventing nearby mission companions from
  falling through a camera-centred culling hole. Reduce the legacy flicker
  telemetry cadence from 0.5 s to 2 s without removing its counters.

## Package 39 modern tabletop combat controls

- Bridge Quest L2 to GTA Android's retail `widget_target` press, hold and
  release lifecycle while Tabletop combat is active.
- Merge R2 into the classic attack query while L2 is held, covering firearms,
  spray weapons and melee; keep `B` as a compatibility attack binding.
- Preserve vehicle brake/accelerator triggers, tabletop grips and non-combat
  R2/L2 prompt answers through context gating. Add target-pointer diagnostics
  for headset validation. See `PACKAGE_39.md`.

## Package 38 navigation beacon and weather validation

- Promote the waypoint selected on GTA's pause map to a lightweight translucent
  tabletop beacon without widening scenery rendering or streaming.
- Show its true position up to three times the map radius; clamp farther targets
  just outside the circle in the correct direction. Provide a process-start A/B
  switch and preserve GTA's retail waypoint ownership.
- Increase the centralized passthrough weather/clock validation multiplier from
  `2.0x` to `3.0x`, leaving clear daytime neutral. See `PACKAGE_38.md`.

## Package 37 translucent objective markers

- Reduce tabletop-only opacity of red, yellow and blue navigation markers to
  58%, including stock arrows, mission cylinders and highlighted cages.
- Preserve position, size, pulse, visibility at every miniature zoom and the
  Package 36 flicker correction. See `PACKAGE_37.md`.

## Package 36 frame-bound passthrough lifecycle fix

- Fix the second confirmed cross-thread path behind whole-radius scenery
  flashes: the XR loop can no longer pause passthrough because the GameThread
  briefly clears its live camera flag during a normal tabletop rebuild.
- Keep the backend alive while focused, but submit its layer only for the exact
  synchronized tabletop projection frame; preserve that decision in cached
  repeated frames.
- Add bounded lifecycle telemetry for a decisive headset confirmation. Preserve
  fade, radii, gameplay, audio and user data. See `PACKAGE_36.md`.

## Package 35 synchronized-frame radial mask fix

- Fix the confirmed cross-thread race that intermittently skipped the radial
  alpha mask for one eye and exposed distant scenery outside the whole radius.
- Make the mask state captured with the leased stereo generation authoritative;
  the transient live GameThread camera flag can no longer cancel it.
- Report snapshot-authority interventions and base diagnostic windows on the
  captured frame. Preserve the approved fade and all gameplay. See
  `PACKAGE_35.md`.

## Package 34 tabletop flicker correction and diagnostic candidate

- Correct P33 overflow replacement priority for returning entries vs newcomers.
- Restore bounded overflow and combat telemetry in player APKs and audit the
  diagnostic strings in the actual packaged native library.
- Replace order-sensitive render-list hashes with a membership-oriented hash;
  GTA's per-eye LOD qsort was a false-positive source in P32/P33.
- Add all-attempt mask-input windows, final-eye stereo anomaly counters and
  audited no-Z-write alpha-model dispatch witnesses. Preserve the approved
  fade and all gameplay. See `PACKAGE_34.md` for limits and the manual test.

## Package 33 tabletop alpha stability candidate

- Add a bounded 96-entry spill list for static alpha scenery rejected when
  GTA's fixed 200-node list is saturated, using current-frame validation and
  prior-frame selection priority to reduce border churn safely.
- Freeze the same spill selection across both stereo eyes and report bounded
  `[tabletop.flicker.fix]` telemetry; keep an isolated process-start off switch
  for an exact same-APK comparison.
- Extend tabletop attack telemetry with CJ's forward basis and add
  `[tabletop.aim.area]` arguments for spray can, flamethrower and extinguisher.
  Combat direction remains unchanged pending headset evidence. See
  `PACKAGE_33.md`.

## Package 32 targeted flicker diagnostic candidate

- Add player-build telemetry for half-second windows of visible entities,
  ordinary LODs, super-LODs, streaming requests and alpha-list sizes while
  Tabletop is active.
- Hash render-list pointer identity before the stereo pair and after each eye,
  detecting same-count model/LOD substitutions and left/right mutations that
  the earlier candidate counter could not expose.
- Report the exact synchronized stereo generation, ring slot, colour/depth
  resources, clip planes and radial-mask scale used by the compositor.
- Preserve Package 31 rendering and gameplay byte-for-behaviour: this package
  changes diagnostics only. See `PACKAGE_32.md`.

## Package 31 passthrough validation candidate

- Amplify the existing gradual GTA clock/weather passthrough treatment to
  `2.0x` through one centralized validation constant while retaining a neutral
  clear daytime identity grade.
- Add bounded successful-application telemetry reporting GTA weather inputs,
  final grade and the active `META_LUT` or `FB_BASIC` compositor path.
- Preserve the headset-approved Package 30 marker correction and all gameplay,
  rendering, controls, data, audio, saves and configuration. See
  `PACKAGE_31.md`.

## Package 30 test candidate

- Fix the remaining grab-zoom marker disappearance identified by Package 29:
  late objective vertices were in physical metres but used the tabletop world
  pass's game-unit near/far clip distances.
- Convert those clip distances with the synchronized eye/mask frame scale so
  nearby red, yellow and blue markers stay inside the physical projection at
  every miniature size.
- Preserve Package 29 diagnostics and all Package 28/25 marker positioning and
  presentation behaviour. See `PACKAGE_30.md`.

## Package 29 targeted diagnostic candidate

- Extend the marker draw heartbeat with one compact record per active marker:
  stable ID, kind, colour family, clip result, RGB, NDC position and GTA-world
  distance from the current player anchor.
- Report how many submitted markers used Package 28's synchronized world-point
  reprojection, distinguishing a missing rebase from a projection/identity
  error.
- Preserve Package 28 rendering unchanged. See `PACKAGE_29.md`.

## Package 28 test candidate

- Fix the grab-zoom marker divergence identified by Package 27 diagnostics:
  markers remained live and submitted but moved outside clip space at small
  tabletop scales.
- Retain each marker's absolute GTA world point and reconstruct its physical
  position from the exact player centre, scale and map axes captured alongside
  the corresponding stereo eye/mask frame.
- Keep Package 27 bounded telemetry for headset confirmation and preserve all
  Package 26/25 behaviour. See `PACKAGE_28.md`.

## Package 27 diagnostic candidate

- Add bounded marker-source telemetry separating GTA cone/cylinder calls from
  successful tabletop publications, transform failures and colour families.
- Report the XR marker pool even when empty, including expiration/eviction
  counts and live tabletop scale.
- Add a left-eye clip-space audit reporting submitted, visible, outside and
  behind-camera markers plus their eye-distance range.
- Keep Package 26 rendering and Package 25 sparks unchanged. See
  `PACKAGE_27.md`.

## Package 26 test candidate

- Expand the late stereo objective-marker pool from 16 to 64 entries. GTA's
  radar can submit more than sixteen active 3D blips in one frame; the old
  ring silently replaced early mission colours with later markers.
- Add a bounded `[objective.pool]` heartbeat reporting live entries, pool
  evictions, expirations and tabletop scale for headset confirmation.
- Preserve Package 25 sparks and every Package 24 passthrough/control change.
  See `PACKAGE_26.md`.

## Package 25 test candidate

- Extend the stereo-safe 3D scraping/wheel spark replacement from CJ's current
  vehicle to matching contacts around the player inside the tabletop radius.
- Make the replacement streaks 20% wider and modestly longer while retaining
  the 96-particle pool and eight-birth global frame budget. Nearby traffic may
  use at most half that budget, reserving capacity for CJ's vehicle.
- Make red, yellow and blue objective-marker presentation independent of map
  scale, then enforce a minimum angular footprint from the viewer in the late
  stereo overlay without moving the marker's gameplay position.
- Retain objective markers for 1.25 seconds to bridge short GTA marker/LOD
  update gaps while tabletop zoom changes.
- Preserve Package 24 passthrough grading and all approved controls, data,
  audio, saves and configuration. See `PACKAGE_25.md`.

## Package 24 test candidate

- Add gradual weather-reactive passthrough driven by the verified retail GTA
  clock, rain, fog, cloud-coverage and sandstorm values.
- Keep clear daytime neutral; use restrained dawn, sunset, night, rain/fog and
  sandstorm palettes with a smooth 1.35 s transition.
- Prefer a compact `XR_META_passthrough_color_lut` path updated at no more than
  4 Hz, with FB brightness/contrast/saturation fallback.
- Change only OpenXR passthrough styling; preserve Package 23 rendering,
  effects, controls, data, audio, saves and configuration.
- Headset colour validation remains pending; see `PACKAGE_24.md`.

## Package 23 test candidate

- Replace scoped nearby vehicle scraping/wheel sparks with capped world-space
  crossed fins shared by both stereo eyes; retain other stock effect producers.
- Stop heuristic left-to-right Fx batch substitution in tabletop.
- Require high-precision depth sampling for the radial mask, isolate its
  sampler state, and reject invalid mask inputs/non-finite distances.
- Make mask failure counters available in player APKs and add a bounded
  success heartbeat. P22 used a logging macro compiled out in these APKs.
- Preserve P22 road admission and all previously approved gameplay changes.
- Headset validation remains pending; see `PACKAGE_23.md` for test guidance.

## 0.1.4 alpha

### Added

- Added release-build swim-state diagnostics confirming that tabletop movement
  remains headset-relative and immersive arm-stroke locomotion stays blocked.

### Improved

- Extended stereo stabilization from 32 to 64 vertices for matrix-null Fx
  batches. Live scraping diagnostics showed that isolated sparks were already
  stable while denser collision bursts just above the old limit diverged.
- Replaced the 90 metre radius preset with a 75 metre test step between the
  stable 60 metre profile and the expensive 120 metre profile.
- Made mission/checkpoint cylinders mandatory tabletop information rather than
  tying them to the optional stock objective-marker preference.

### Fixed

- Made the tabletop passthrough mask fail closed. A transient missing mask,
  depth-copy failure, allocation failure, or shader error now leaves that
  frame transparent instead of exposing arbitrary RenderWare alpha and
  flashing distant scenery outside the radial boundary.
- Extended the immediate player-safety island by each entity's bounded
  collision sphere. Large road shoulders, plazas, and terrain slabs routed
  through GTA's non-road path can no longer disappear beside CJ merely because
  their authored pivot lies outside the safety radius.
- Added rate-limited mask fallback counters identifying inactive state,
  program, source-depth, storage, copy, and shader failures in headset logs.
- Added a tabletop-specific swimming adapter. The left stick now selects a
  headset-relative world direction and is converted into GTA's separate swim
  turn/thrust axes, with a short water-surface debounce and no vehicle-yaw
  inheritance.
- Removed the experimental height-only aircraft shell after headset testing
  showed that it also revealed upper portions of unrelated scenery outside the
  tabletop radius. Aircraft now obey the normal mask again.
- Removed the boundary-object completion experiment after headset testing; the
  fade is once again the original continuous radial mask with no per-building
  or vegetation extensions.
- Fixed yellow objective cones using the immersive world transform in tabletop,
  which could place them far away from their matching miniature location.
- Kept red mission areas and yellow objective markers physically readable when
  the model is shrunk, and draw them as unobstructed tabletop navigation UI.
- Fixed tabletop mission cylinders being captured successfully and then skipped
  by the late-overlay renderer's tabletop early return.
- Added a cylinder-only fallback when shared scene depth is unavailable, so a
  mission trigger area is not silently lost for that frame.

## 0.1.3 alpha

### Added

- Added a tabletop-only actor-up radar mode: the CJ/vehicle arrow stays aligned
  while the map rotates from the gameplay heading instead of the independent VR
  camera.
- Added targeted tabletop aim diagnostics for the classic attack route and the
  Android targeting widget, without enabling physical weapons in miniature mode.
- Added a stereo tabletop replacement for script mission cylinders and tube
  checkpoints captured from the complete `C3dMarkers::PlaceMarker` path.
- Added an APK-only installer option that hash-checks preserved Quest audio,
  refreshes its read permissions, and republishes it only when invalid.
- Added Vice City-style volumetric bullet tracers with a thin core and a
  multi-fin smoke volume.
- Added in-game tracer colour selection (`VICE CITY` or `GOLD`) and live smoke
  spread adjustment from 25% to 400%.
- Added the full retail mission list to the mission launcher instead of the old
  fixed 20-mission limit.
- Added the settings export helper for copying VR calibration files from Quest
  to a PC without including saves, logs, screenshots, game data, or the device
  serial number.

### Improved

- Capped procedural-grass detail at the proven 60 m budget for the 75/120 m
  tabletop radius presets while retaining the established 18 m object residency
  skirt to avoid extra pop/flicker. Ground, roads, large structures, and every
  object inside the selected visible radius remain.
- Shortened tracer length and lifetime so shots read as fast projectiles rather
  than persistent laser beams.
- Stabilized parachute visibility distance against altitude changes and moved
  the custom VR risers farther toward the canopy.
- Hid the redundant retail parachute strings and ripcord while the VR risers
  are active.
- Included the UltimateXR open-palm basketball hand meshes in player builds.
- Updated the Classic HUD health crop to the current tested `244 x 84` source
  region without changing the selected HUD preset.

### Fixed

- Fixed BMX/bicycle steering in tabletop mode being overwritten by the idle
  immersive-handlebar value after the left-stick query had succeeded.
- Fixed the direct BMX fork/handling write using the opposite steering sign
  from the tabletop `CPad` query.
- Fixed older tracers dimming newly spawned smoke by sharing one averaged alpha
  value.
- Fixed mission selection wrapping and page-specific mission counts.
- Fixed the public packager omitting the basketball palm assets even though the
  runtime referenced them.
