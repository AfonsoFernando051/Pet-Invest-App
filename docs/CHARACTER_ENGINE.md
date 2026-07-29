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
| Mascot rendering (Lottie → PNG → icon fallback, breathe/bump tweens) | [`pet_mascot_widget.dart`](../petapp_mobile/lib/features/pet/presentation/mascot/widgets/pet_mascot_widget.dart) |
| 9-tier evolution ladder (currently dog-named/dog-art only) | [`pet_evolution_stage.dart`](../petapp_mobile/lib/features/pet/domain/enums/pet_evolution_stage.dart) |
| 6-value animation state machine (idle/celebrate/think/sleep/victory/happy) | [`pet_animation_state.dart`](../petapp_mobile/lib/features/pet/domain/enums/pet_animation_state.dart) |
| Species selection (6 species, server-backed) | [`pet_specie_enum.dart`](../petapp_mobile/lib/features/pet/data/models/pet_specie_enum.dart), [`pet_repository.dart`](../petapp_mobile/lib/features/pet/domain/repositories/pet_repository.dart) |
| Real, server-backed LLM chat (the brief's "Financial Coach") | [`mentor_screen.dart`](../petapp_mobile/lib/features/mentor/presentation/screens/mentor_screen.dart), `GeminiChatClient.java` (backend) |
| Achievement unlock detection | [`portfolio_controller.dart`](../petapp_mobile/lib/features/portfolio/presentation/controllers/portfolio_controller.dart) (`_evaluateGamification`) |

### The honest gaps

- **No client-side LLM/TTS/speech SDK.** The Mentor chat's LLM call is server-side only
  (`GeminiChatClient`); there is no `AiBrain`/`SpeechController` implementation client-side, only the
  interface shapes (Phase 0 adds these as unimplemented seams — see below).
- **No lip-sync art or rig.** `PetEvolutionStage` renders flat Lottie/PNG per stage; there is no mouth
  layer to drive shapes with.
- **No per-species evolution art.** All 9 `PetEvolutionStage` values are dog-named (`babyDog` …
  `goldenFinanceDog`) and every fallback PNG is `generated_dog.png`. Non-dog species currently render as a
  generic dog once past the raw species-select screen. This document does not fix that (it's an art
  pipeline problem, not a code one) — it's named so Phase 2+ scoping doesn't assume otherwise.
- **Two disconnected pet renderers.** `PetShowcase` (dashboard) and `PetMascotWidget`
  (`RpgIntegrationCard`) are independent widgets with independent `AnimationController`s and independent
  data fetches; `RpgIntegrationCard.showPetVisual` exists specifically to avoid showing both mascots at
  once. Phase 0 does **not** merge them (see below) — `PetShowcase` shows the user's real species image
  today, and `PetMascotWidget`'s per-species art doesn't exist yet, so merging now would be a visible
  regression, not an improvement.
- **No historical portfolio series or dividend feed client-side.** Same gap `MARKET_EVENTS_ENGINE.md`
  already documented. `CharacterEventType.portfolioAllTimeHigh`, `.portfolioSignificantDrop` and
  `.dividendReceived` are declared in code but **not published** until that data exists — never simulate a
  market event that isn't real (same non-negotiable rule as `MARKET_EVENTS_ENGINE.md`).

---

## What's implemented today (Phase 0)

All in `lib/features/pet/`, following the existing Clean Architecture split, using only what's already in
`pubspec.yaml` (plain `ChangeNotifier` + `Timer`/`Stream` — no new state-management package, no event
sourcing):

- **Animation Controller** — `MascotController` (unchanged) + `PetMascotWidget`, now emotion- and
  idle-variant-aware.
- **Behavior Controller** — `IdleBehaviorController`: while (and only while) the mascot is `idle`, swaps to
  a new random `IdleVariant` (breathing / lookAround / stretch / tailWag / sit / watchCoins /
  watchNotification) every 4–10s, so idle never reads as one static loop. Implemented as a smoothly
  animated tilt (`AnimatedRotation`) on the existing art — no new assets.
- **Emotion Controller** — `CharacterEmotionController`: tracks a `CharacterEmotion` (the brief's 14
  states) and derives an `EmotionVisualProfile` (aura color, breathe-speed multiplier, bump-intensity
  multiplier, sparkle flag) that retints/repaces the mascot's *existing* aura and breathe/bump tweens.
- **Event Reaction Engine** — `CharacterEventBus` + `CharacterEvent`: a lightweight broadcast stream (not a
  message broker). `PortfolioController` publishes `achievementUnlocked`; `CharacterEngine` publishes
  `stageEvolved` and `userReturned` from data it already has.
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

**Explicitly not built in Phase 0** (interfaces only, not wired into any UI): `AiBrain`, `SpeechController`,
`LipSyncController` — see [Phase 1+](#phase-1-ai-brain--voice) below. Also not built: merging
`PetShowcase`/`PetMascotWidget`, multi-species evolution art, `portfolioAllTimeHigh`/`.
portfolioSignificantDrop`/`.dividendReceived` publishing, camera/AR/vision, multiple pets, mini-games.

---

## Full north-star architecture

```
Character Engine
├── Animation Controller     — MascotController + PetMascotWidget            [Phase 0 — done]
├── Behavior Controller      — IdleBehaviorController                        [Phase 0 — done]
├── Emotion Controller       — CharacterEmotionController                    [Phase 0 — done]
├── Event Reaction Engine    — CharacterEventBus / CharacterEvent            [Phase 0 — done, partial event set]
├── Personality Engine       — PersonalityEngine / DefaultPersonalityEngine  [Phase 0 — done, template-based]
├── Relationship Engine      — RelationshipEngine                            [Phase 0 — done, single "welcome back" moment]
├── Notification Presenter   — CharacterSpeechBubble                        [Phase 0 — done, text only]
├── Evolution System         — PetEvolutionStage + species hydration         [Phase 0 — done; multi-species art is Phase 2+]
├── AI Brain                 — AiBrain (interface only)                      [Phase 1+]
├── Speech Controller        — SpeechController (interface only)            [Phase 1+]
├── Lip Sync Controller       — LipSyncController (interface only)          [Phase 2+, depends on Speech]
├── Mission Narrator          — not started                                 [Phase 1+, once Speech exists]
├── Financial Coach           — already exists as the Mentor chat feature   [merge with Speech in Phase 1+, not reinvented]
└── Memory Engine             — not started                                 [Phase 2+, needs durable per-user AI memory store]
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
surprised); natural movement, not perfect sync, per the brief. This phase is also when per-species
evolution art and the `PetShowcase`/`PetMascotWidget` merge become viable — both are blocked on art, not
code.

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
  existing celebration overlay.
