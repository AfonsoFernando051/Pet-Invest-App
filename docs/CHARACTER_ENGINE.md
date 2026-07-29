# CHARACTER_ENGINE.md

# Living Pet Character Engine

## Status

Design specification. **Phase 0 is implemented** alongside this document (see
[What's implemented today](#whats-implemented-today)); everything else described here is north-star
architecture for Phase 1 and beyond — not yet built.

This document is written to the quality bar the brief asked for (a Character Engine on par with Dragon
City, Talking Tom, Pou, the Duolingo Owl, and Pokémon partners), but it is deliberately **phased** — see
[Reconciling Ambition With the Roadmap](#reconciling-ambition-with-the-roadmap) before building anything
further from it.

---

## Reconciling Ambition With the Roadmap

Three existing documents constrain this feature, same as they constrained `MARKET_EVENTS_ENGINE.md`:

- **ROADMAP.md** lists "Avatar evolution," "Interactive tutorials," and "AI-powered recommendations" under
  *Features Deferred Until After MVP*, and its Decision Rules ask: "Does this delay the release? Will
  users benefit immediately?"
- **AI_RULES.md** says: prefer extending existing code over rewriting it, avoid introducing new
  architectural patterns "unless there is a clear reason," follow KISS/DRY/YAGNI, and "avoid overengineering."
- **DECISIONS.md** has no existing decision permitting a new state-management package, a message broker,
  or an on-device/client LLM SDK — none of that is introduced here.

The brief asks for a system that makes users "forget they're using a finance app" and rivals
Supercell/Talking-Tom-grade companions. That is the right target for the *idea*. A senior engineer's job
is to sequence it so today's version is honest about what already exists in this codebase and doesn't
outrun the app's current architecture or data.

So, like `MARKET_EVENTS_ENGINE.md`, this document does two things:

1. Designs the **full system** the brief asked for — all 14 subsystems — as the north-star architecture.
2. Calls out a **Phase 0 slice**, implemented now, that is small enough to ship without violating any of
   the three documents above — because most of what makes the pet feel alive today doesn't require AI,
   TTS, or new art; it requires *using the state the app already tracks* more expressively.

### What already exists

| Concern | Already exists at |
|---|---|
| Mascot state, evolution, accessory equip/unlock, event-animation overrides | [`mascot_controller.dart`](../petapp_mobile/lib/features/pet/presentation/mascot/controllers/mascot_controller.dart) |
| Mascot rendering (Lottie → PNG → icon fallback, breathe/bump tweens, gestures, crossfade) | [`character_widget.dart`](../petapp_mobile/lib/features/pet/presentation/character/widgets/character_widget.dart) |
| 9-tier evolution ladder (currently dog-named/dog-art only) | [`pet_evolution_stage.dart`](../petapp_mobile/lib/features/pet/domain/enums/pet_evolution_stage.dart) |
| 6-value animation state machine (idle/celebrate/think/sleep/victory/happy) | [`pet_animation_state.dart`](../petapp_mobile/lib/features/pet/domain/enums/pet_animation_state.dart) |
| Species selection (6 species, server-backed) | [`pet_specie_enum.dart`](../petapp_mobile/lib/features/pet/data/models/pet_specie_enum.dart), [`pet_repository.dart`](../petapp_mobile/lib/features/pet/domain/repositories/pet_repository.dart) |
| Real, server-backed LLM chat (the brief's "Financial Coach") | [`mentor_screen.dart`](../petapp_mobile/lib/features/mentor/presentation/screens/mentor_screen.dart), `GeminiChatClient.java` (backend) |
| Achievement unlock detection | [`portfolio_controller.dart`](../petapp_mobile/lib/features/portfolio/presentation/controllers/portfolio_controller.dart) (`_evaluateGamification`) |

### Reference concept art already exists — and is richer than the brief assumed

`assets/pets/{dog,cat,wolf,fox,bear,lion}.png` are full concept-art style sheets, one per species, and they
are the actual design bible this document's enums are built against. They are **now partially sliced** —
see [Sliced assets](#sliced-assets) below — into the individual files `CharacterAssetLoader` resolves;
`pet_showcase.dart`/`pet_repository_impl.dart` still separately use the single-pose
`assets/images/generated_*.png` renders, untouched by this pass.

- A **25-expression grid** per species (NEUTRAL, HAPPY, VERY HAPPY, LAUGHING, CURIOUS, THINKING,
  DETERMINED, CONFIDENT, PROUD, EXCITED, MOTIVATED, SURPRISED, CONFUSED, EMBARRASSED, SAD, CRYING,
  SLEEPY, SLEEPING, LOVE, SCARED, DIZZY, SICK, SHOCKED, ANGRY, PLAYFUL) — identical across all 6 species.
  `CharacterEmotion` (Phase 0) now has exactly these 25 values, in the same names, for exactly this reason:
  when this sheet is eventually sliced into individual assets, `CharacterEmotion.name` already is the file
  key, no remapping needed.
- A **named gameplay-pose set** per species (IDLE, WALK, RUN, JUMP, SIT, LAY DOWN, SLEEP, EAT, DRINK,
  CELEBRATE, DANCE, THINK, WAVE, STRETCH, VICTORY, LOOK UP, LOOK DOWN, plus a separate LAUGH sprite
  sheet). `PetAnimationState` (Phase 0) was expanded from 6 to 19 values to cover every one of these;
  `IdleVariant` covers the subset that makes sense as unprompted idle behavior (stretch/sit/layDown/
  lookUp/lookDown/think/wave/eat/drink/dance, plus the sheets' own IDLE/BLINK loops as `breathing`/
  `blinking`).
- A **9-tier evolution ladder per species**, already using the exact same names as `PetEvolutionStage`
  (BABY → TEEN → ADULT → MASTER → LEGENDARY → ROYAL → CYBER MYSTIC → COSMIC GUARDIAN → GOLDEN FINANCE),
  for all 6 species — meaning "per-species evolution art" is a **slicing task against art that already
  exists**, not a commissioning task. This changes the Phase 2 estimate below.
- Turnaround views (front/3-4/side/back) and named accessories (golden crown, wizard hat, headphones,
  angel wings, hero cape, etc.) that already overlap heavily with `PetAccessoryId` — not touched in this
  pass, but a natural next slicing target.

### Sliced assets

Cropped directly from `assets/pets/{cat,wolf,fox,bear,leon}.png` (script-assisted: row/column boundaries
detected from pixel density gaps, background removed via flood-fill from each corner, not hand-traced) into
`assets/characters/<species>/{expressions,poses}/`:

- **Expressions**: every labeled face in each species' grid — 24 for cat/wolf/lion, 23 for fox (no
  `motivated`), 21 for bear (no `love`, `motivated`, `confident`, `playful` — that sheet's grid has fewer
  columns). Filenames match `CharacterEmotion.name` exactly, so `CharacterAssetLoader.expressionPaths`
  resolves them with no mapping table.
- **Poses**: the 7 states actually reachable today — `idle`, `sleep`, `think`, `celebrate`, `victory`,
  `jump`, `wave` (achievement/mission/evolution reactions, tap/double-tap/drag) — cropped from each
  species' "GAMEPLAY POSES" grid. The other 12 `PetAnimationState` values (walk, run, sit, layDown, eat,
  drink, dance, stretch, lookUp, lookDown, laugh, happy) are visible in the same sheets but weren't sliced
  since nothing in the app triggers them yet; slicing is cheap to extend once something does.
- **DOG is deliberately not sliced.** `assets/pets/dog.png` has an analogous face grid but — unlike the
  other five — **no printed text labels**, and its layout doesn't match the other sheets' column order.
  Mapping its faces to `CharacterEmotion` values would be visual guesswork with no way to verify it, and a
  silently-wrong expression (e.g. showing `angry` when the code asked for `confident`) is worse than
  showing none. DOG keeps conveying emotion via `EmotionVisualProfile`'s aura/breathe retinting only, same
  as every species did before this pass.
- **The expression face renders as a small corner badge, not a face swap.** Once a real per-species pose
  PNG resolves (all 7 sliced states, for the 5 sliced species), that pose already has its own face baked
  in — overlaying a second, bigger expression face on top of it would compete with it rather than
  complement it. `_ExpressionLayer` therefore renders as a small circular badge pinned to the upper-right
  corner (mirrors how mobile games show a separate emote/mood bubble rather than replacing the character's
  face), not a large centered overlay.

### The honest gaps

- **No client-side LLM/TTS/speech SDK.** The Mentor chat's LLM call is server-side only
  (`GeminiChatClient`); there is no `AiBrain`/`SpeechController` implementation client-side, only the
  interface shapes (Phase 0 adds these as unimplemented seams — see below).
- **No lip-sync art or rig.** These are flat 2D concept renders, not a rigged mouth layer — lip sync still
  needs either a real rig or a discrete mouth-shape sprite set per species, neither of which exists yet.
- **No Lottie animation for any pose, for any species.** The sliced pose art is a single static frame per
  state (that's all the reference sheets have) — `CharacterAssetLoader.posePaths` still lists a
  `.json` Lottie candidate first for when a real animated export exists, ahead of the static PNG.
- **12 of 19 `PetAnimationState` values, and every state/expression for DOG, still fall through to the
  pre-existing evolution-stage PNG chain** — `assets/mascot/evolutions/` and `assets/mascot/animations/`
  still contain only `.gitkeep`. `CharacterWidget` renders via that fallback chain unchanged for those.
- **Two disconnected pet renderers.** `PetShowcase` (dashboard) and `CharacterWidget`
  (`RpgIntegrationCard`) are independent widgets with independent `AnimationController`s and independent
  data fetches; `RpgIntegrationCard.showPetVisual` exists specifically to avoid showing both mascots at
  once. This pass does **not** merge them — `PetShowcase` shows the user's real species image today via
  `generated_*.png`, a different (also real, also single-pose) asset than the newly-sliced `poses/idle.png`
  `CharacterWidget` now shows; merging the two widgets is still separate follow-up work, now more viable
  than before but not done here.
- **No historical portfolio series or dividend feed client-side.** Same gap `MARKET_EVENTS_ENGINE.md`
  already documented. `CharacterEventType.portfolioAllTimeHigh`, `.portfolioSignificantDrop` and
  `.dividendReceived` are declared in code but **not published** until that data exists — never simulate a
  market event that isn't real (same non-negotiable rule as `MARKET_EVENTS_ENGINE.md`).

---

## What's implemented today (Phase 0)

All in `lib/features/pet/`, following the existing Clean Architecture split, using only what's already in
`pubspec.yaml` (plain `ChangeNotifier` + `Timer`/`Stream` — no new state-management package, no event
sourcing):

- **Animation Controller** — `MascotController` (unchanged) + `CharacterWidget` (renamed from
  `PetMascotWidget`, moved to `presentation/character/widgets/`), now emotion- and idle-variant-aware, with
  an `AnimatedSwitcher` crossfade (~250ms) between animation states instead of an instant swap.
- **Interaction Controller** — `InteractionController`: translates gestures into reactions so
  `CharacterWidget` never manipulates `MascotController`/`CharacterEmotionController` directly. Tap →
  `happy` bump (unchanged); double tap → `jump` + `veryHappy`; long press → `curious` expression only; drag
  release → `wave` + `happy`. Drag-follow itself (the mascot tracking the finger while held) is local,
  ephemeral widget state — mirrors the `_parallax` pattern `PetShowcase` already used for its accelerometer
  parallax — since it's pure visual feedback, not a Character Engine state change.
- **AssetLoader** — `CharacterAssetLoader`: a pure, stateless path resolver (no caching, no I/O — see
  [Asset conventions](#asset-conventions)) that `CharacterWidget` consumes via nested `errorBuilder`s, the
  same graceful-degradation pattern the fallback chain already used pre-species-art. As of
  [Sliced assets](#sliced-assets), it resolves to *real* per-species art for cat/wolf/fox/bear/lion's 7
  reachable poses and (for cat/wolf/fox/lion) 24 expressions / (bear) 21 / (fox) 23 — DOG still falls
  through to the pre-existing evolution PNG chain, by design (see above).
- **Behavior Controller** — `IdleBehaviorController`: while (and only while) the mascot is `idle`, swaps to
  a new random `IdleVariant` (breathing / blinking / stretch / sit / layDown / lookUp / lookDown / think /
  wave / eat / drink / dance — the idle-appropriate subset of the reference sheets' named poses, see
  below) every 4–10s, so idle never reads as one static loop. Implemented as a smoothly animated tilt
  (`AnimatedRotation`) on the existing art — no new assets yet.
- **Emotion Controller** — `CharacterEmotionController`: tracks a `CharacterEmotion` (25 values, matching
  the reference sheets' expression grid one-for-one — see below) and derives an `EmotionVisualProfile`
  (aura color, breathe-speed multiplier, bump-intensity multiplier, sparkle flag) that retints/repaces the
  mascot's *existing* aura and breathe/bump tweens.
- **Event Reaction Engine** — `CharacterEventBus` + `CharacterEvent`: a lightweight broadcast stream (not a
  message broker). `PortfolioController` publishes `achievementUnlocked` and `missionCompleted` (diffed
  against `MissionCatalog.evaluate`, session-level — missions are recomputed fresh each load, unlike
  persisted achievements, so there's no existing "seen missions" store to diff against durably);
  `CharacterEngine` publishes `stageEvolved` and `userReturned` from data it already has. The brief's
  "UserLevelUp" and "MarketCrash" aren't separate types — they're `stageEvolved` (this app has no numeric
  level distinct from evolution tier) and `portfolioSignificantDrop`, respectively; "PortfolioImported"
  isn't modeled at all — there's no import/CSV/broker feature in this app to derive it from.
- **Personality Engine** — `PersonalityEngine`/`DefaultPersonalityEngine`: species-flavored template
  phrases (dog=playful/energetic, wolf=serious/protective, fox=curious/strategic, bear=calm/patient,
  lion=confident/inspiring, cat=aloof-but-warm) for events and "welcome back" greetings. This is the
  explicit stand-in for what an `AiBrain`-composed system prompt will generate in Phase 1+.
- **Relationship Engine** — `RelationshipEngine`: a pure function over `PetProfile.lastActiveAt` deciding
  whether a "welcome back" moment applies (≥1 day away) and for how long — the same signal
  `MascotController.restingStateFor` already uses for the sleep state.
- **Notification Presenter** (template form) — `CharacterSpeechBubble`: a transient bubble showing
  `CharacterEngine.currentLine`, auto-clearing after 4s.
- **Evolution System** — existing 9-tier ladder, now finally fed the user's *real* species:
  `CharacterEngine.loadProfile()` calls `PetRepository.getMyPet()` and corrects
  `MascotController`'s specie via the new `MascotController.updateSpecie()`, fixing a confirmed bug where
  `MascotRepositoryImpl.loadProfile()` hardcoded every user's mascot to `PetSpecieEnum.DOG`.
- **`CharacterEngine`** (`presentation/character/character_engine.dart`) — the façade composing all of the
  above, re-exposing `MascotController`'s entire public surface so every existing call site
  (`dashboard_screen.dart`, `PortfolioController`, `RpgIntegrationCard`) swaps `MascotController` →
  `CharacterEngine` as a type change.

**Explicitly not built** (interfaces only, not wired into any UI): `AiBrain`, `SpeechController`,
`LipSyncController` — see [Phase 1+](#phase-1-ai-brain--voice) below. Also not built: merging
`PetShowcase`/`CharacterWidget`, multi-species evolution art, `portfolioAllTimeHigh`/`.
portfolioSignificantDrop`/`.dividendReceived` publishing, a formal state-transition-legality graph (nothing
in this app needs to forbid a transition, so none is built), a sprite-flipbook player (Lottie is the
rendering technology already in use — a second pipeline for PNG-sequence frames isn't justified without a
concrete need for it), camera/AR/vision, multiple pets, mini-games.

### Asset conventions

`CharacterAssetLoader` (`presentation/character/asset/character_asset_loader.dart`) is the single place
that knows these paths — nothing else should hardcode them:

- **Poses**: `assets/characters/<species>/poses/<PetAnimationState.name>.json` (species-specific Lottie,
  not authored yet) → `.../poses/<state>.png` (species-specific static frame — **real for
  cat/wolf/fox/bear/lion's 7 reachable states**, see [Sliced assets](#sliced-assets)) → the shared
  `assets/mascot/animations/<state>.json` → the existing evolution-stage PNG chain. `<species>` is
  `PetSpecieEnum.name.toLowerCase()` (`dog`, `cat`, `wolf`, `fox`, `bear`, `lion` — **not** `leon`, the
  reference sheet's filename typo).
- **Expressions**: `assets/characters/<species>/expressions/<CharacterEmotion.name>.png` — a species-
  specific static face, **real for cat/wolf/fox/bear/lion**. No shared fallback; if missing (every emotion
  for DOG, and the handful of emotions each of the other 5 sheets doesn't label), `CharacterWidget` renders
  no expression badge and keeps conveying emotion via `EmotionVisualProfile`'s aura/breathe retinting alone.
- Both folder trees exist for all 6 species (declared in `pubspec.yaml`); DOG's remain `.gitkeep`-only by
  design. Dropping a correctly-named file into either makes it appear automatically, zero code changes.
- Evolution art is **not** duplicated under `assets/characters/` — `assets/mascot/evolutions/
  <PetEvolutionStage.name>.png` remains the one location for it (per-species evolution naming is still the
  Phase 2+ gap noted above).

---

## Full north-star architecture

```
Character Engine
├── Animation Controller     — MascotController + CharacterWidget           [done]
├── Behavior Controller      — IdleBehaviorController                       [done]
├── Interaction Controller   — InteractionController                        [done]
├── Emotion Controller       — CharacterEmotionController                   [done]
├── AssetLoader              — CharacterAssetLoader                         [done; assets/characters/ scaffolded, empty]
├── Event Reaction Engine    — CharacterEventBus / CharacterEvent           [done, partial event set — see below]
├── Personality Engine       — PersonalityEngine / DefaultPersonalityEngine [done, template-based]
├── Relationship Engine      — RelationshipEngine                          [done, single "welcome back" moment]
├── Notification Presenter   — CharacterSpeechBubble                       [done, text only]
├── Evolution System         — PetEvolutionStage + species hydration       [done; multi-species art is Phase 2+]
├── AI Brain                 — AiBrain (interface only)                    [Phase 1+]
├── Speech Controller        — SpeechController (interface only)           [Phase 1+]
├── Lip Sync Controller       — LipSyncController (interface only)         [Phase 2+, depends on Speech]
├── Mission Narrator          — not started                                [Phase 1+, once Speech exists]
├── Financial Coach           — already exists as the Mentor chat feature  [merge with Speech in Phase 1+, not reinvented]
└── Memory Engine             — not started                                [Phase 2+, needs durable per-user AI memory store]
```

### Phase 1 — AI Brain + voice

Once product/infra decide on an LLM strategy for the mascot's voice, `AiBrain` should reuse the same
Gemini backend the Mentor chat already calls (`GeminiChatClient`) rather than stand up a second provider —
the brief's "Financial Coach" is that existing feature, not a new one. The LLM must always respond *as the
pet* (species + personality system prompt, built from `PersonalityEngine`'s existing tone descriptors),
never as a generic assistant. `SpeechController` picks a TTS provider (Google TTS / Gemini TTS / OpenAI TTS
/ Azure Speech / ElevenLabs / Cartesia) behind the existing interface — provider swaps should never touch
`CharacterEngine`.

### Phase 2 — Lip sync + expanded art

`LipSyncController` maps elapsed audio playback to `MouthShape` (closed/halfOpen/open/smile/wideOpen/
surprised); natural movement, not perfect sync, per the brief. This phase is also when the
`assets/pets/*.png` reference sheets get sliced into the individual files under `assets/characters/
<species>/{poses,expressions}/` and `assets/mascot/evolutions/` that `CharacterAssetLoader`/
`PetEvolutionStage` already point at (see [Asset conventions](#asset-conventions)) — expressions and 7
reachable poses are already sliced for cat/wolf/fox/bear/lion (see [Sliced assets](#sliced-assets)); this
phase covers the rest: the remaining 12 `PetAnimationState` values, DOG (needs a labeled reference sheet
first, or a manual mapping someone can actually verify), and turning the static poses into real animation.
This phase is also when the `PetShowcase`/`CharacterWidget` merge becomes viable.

### Phase 3+ — Vision, AR, multiplayer

Camera interaction, emotion recognition, AR mode, multiple pets, pet-to-pet interaction, seasonal events,
mini-games — genuinely new systems, sequenced only after Phase 1/2 prove the core loop, per ROADMAP.md's
"Avoid speculative development."

---

## Verification

- `cd petapp_mobile && flutter analyze`
- `cd petapp_mobile && flutter test`
- Manual: open the dashboard tab, leave the app idle 30–60s and confirm the mascot's tilt visibly varies;
  trigger an achievement unlock and confirm a species-flavored speech bubble line appears alongside the
  existing celebration overlay; double-tap/long-press/drag the mascot in `RpgIntegrationCard` and confirm
  each produces a distinct reaction. For a non-dog species (configure one via `PetRepository.configurePet`
  or the pet-configuration screen), confirm the mascot now actually renders the sliced species art (not the
  generic dog fallback) for idle/sleep/think/celebrate/victory/jump/wave, and that the small mood badge in
  the upper-right corner shows a real species-specific face instead of nothing.
