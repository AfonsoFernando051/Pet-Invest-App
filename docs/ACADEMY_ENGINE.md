# ACADEMY_ENGINE.md

# Academy — Financial Education Engine

## Status

Phase 0 slice implemented (client-only). Sections marked **Phase 3+** below are design intent, not yet built.

---

## Reconciling Ambition With the Roadmap

The brief that motivated this document asked for a production-grade learning platform: a full REST API under
`/api/v1/education/*`, Flyway-backed lesson/progress tables, a CMS-ready content pipeline, offline-first sync, a
lives/hearts mechanic, and eight fully populated curriculum modules. Three existing documents constrain that brief,
the same way they already constrained `MARKET_EVENTS_ENGINE.md`:

- **ROADMAP.md** and **FEATURES.md** list "Interactive tutorials" and "Investment quizzes" under *Future Features*,
  explicitly excluded from the MVP. "Learning Content" itself is `Status: Planned`, not an MVP-priority feature.
- **AI_RULES.md** says new systems must not delay MVP delivery and to "avoid introducing large new systems."
- **PROJECT_CONTEXT.md** states the game must never punish the user — the Pet "will never die, degrade, or severely
  penalize" the user for a bad outcome. A hearts-lose-on-wrong-answer mechanic, taken literally, violates this.

So — same move as `MARKET_EVENTS_ENGINE.md`: this document sketches the full north-star shape, but only the **Phase
0** slice is implemented now. Everything else is explicitly deferred, not abandoned.

### What already exists that this reuses

| Concern | Already exists at |
|---|---|
| Local, permanent-unlock progress persisted client-side | [`achievements_local_repository.dart`](../petapp_mobile/lib/features/portfolio/data/repositories/achievements_local_repository.dart) |
| Fixed catalog-of-defs pattern (content as static data, not hardcoded widgets) | [`achievement_catalog.dart`](../petapp_mobile/lib/features/portfolio/domain/services/achievement_catalog.dart), [`mission_catalog.dart`](../petapp_mobile/lib/features/portfolio/domain/services/mission_catalog.dart) |
| XP → Level derivation | [`level_calculator.dart`](../petapp_mobile/lib/features/game/domain/services/level_calculator.dart) |
| Reward celebration UI moment | [`achievement_celebration_overlay.dart`](../petapp_mobile/lib/features/portfolio/presentation/widgets/achievement_celebration_overlay.dart) |
| Pet reaction on a game-progression moment | `MascotController.triggerEventAnimation` |
| Cross-controller reaction without tight coupling | `AppEventBus` |
| Closest existing "lesson content" shape | [`indicator_education_catalog.dart`](../petapp_mobile/lib/features/asset_details/domain/services/indicator_education_catalog.dart) |
| The literal entry point the brief describes | the "Treinar" button, `action_buttons.dart` (previously a stub snackbar) |

Nothing above is replaced. The Academy feature is new files under `features/academy/`, following the same
`data → domain → presentation` shape every other feature uses.

---

## 1. Vision (north star, not all built today)

Turn the app's existing "Train" stub into a real, short-lesson, gamified financial-education flow: `Home → Academy →
Module → Lesson → Micro-exercises → Result → XP/Progress → Next lesson`. Content teaches the user to *investigate*
concepts (P/L, risk, diversification, …) rather than memorize definitions or receive buy/sell advice — see
`docs/PROJECT_CONTEXT.md`'s "never misleading" principle. Full curriculum (from the original brief, Level 1–8):
Investor Foundations, Fixed Income, Stocks, Fundamental Analysis, ETFs, Crypto, Portfolio Construction, Advanced.

## 2. Phase 0 (implemented now)

- One fully authored module — **"Fundamentos do Investidor"** (Investor Foundations) — 6 real lessons, 5 interactive
  steps each (~120 total XP for the module).
- Remaining six modules from the brief exist as catalog entries with `contentAvailable: false`, rendered as
  "Em breve" (coming soon) cards — so the progression system's *shape* is visible without writing content that would
  just be a wall of unvalidated text (`FEATURES.md`'s "build the smallest useful version first").
- **No lives/hearts.** A wrong answer shows the correct explanation, encouragingly, and lets the user continue —
  matching both `PROJECT_CONTEXT.md`'s no-punishment rule and the brief's own §9 ("don't make users afraid to
  invest"). A future "streak of correct answers this lesson" stat is a candidate replacement if positive
  reinforcement is wanted later — additive, never subtractive.
- **No lives means no lesson-restart/fail state either** — a lesson always ends in completion; the point is
  understanding, not gatekeeping.
- **No streak system.** A genuine daily-open streak doesn't exist anywhere in the app yet (confirmed — the
  "Sequência" stat on `RpgIntegrationCard` is actually "days since first investment," not a login streak).
  `MARKET_EVENTS_ENGINE.md` already designs the real target shape (`user_streak` table, `STREAK_MAINTAINED` event) as
  a Phase 3+ item; Academy should plug into that system once it exists rather than build a second, competing streak
  tracker.
- **No backend.** Progress is local-only (`SharedPreferences`), following the exact pattern
  `AchievementsLocalRepository` already established — consistent with the fact that XP/achievements/missions
  themselves are still 100% local today; Academy is not a weaker citizen than the systems it integrates with.
- **No practical market challenges, no paper trading.** Both are real, good ideas (brief §7, §16) but need either
  live market data wiring or a simulated-portfolio feature that doesn't exist yet. The domain model below leaves
  room for a `PracticalChallenge` concept without building it.

## 3. Domain Model (implemented)

```
AcademyModule
  id, title, description, icon, order, lessonIds, contentAvailable

Lesson
  id, moduleId, title, order, xpReward, steps: List<LessonStep>

LessonStep (sealed)
  ExplanationStep      { title, body }
  ExampleStep          { title, body }
  ChoiceQuestionStep   { framing (microExercise | apply), prompt, options, correctIndex, explanation }
  SummaryStep          { title, takeaways }
```

`ChoiceQuestionStep` covers multiple-choice, true/false (as a 2-option question) and scenario/apply questions with
one shared shape and one shared widget — the "engine" the brief asked for, sized to what six real lessons actually
need. Matching, ordering, numeric-input and chart-identification question types from the brief are real future step
types; adding one is a new `LessonStep` subclass + one new step-view widget, nothing else changes (`LessonSession`
already switches on step type generically).

Progress is derived, not stored as a separate aggregate: `AcademyProgressCalculator` computes lesson/module status
(`locked | available | completed`, `comingSoon | inProgress | completed`) from `AcademyCatalog` (static) crossed with
`Set<String> completedLessonIds` (persisted). This mirrors `MissionCatalog.evaluate()` — a pure function over a fixed
catalog and live state, not a stored derived value that can drift.

## 4. Gamification Integration

Lesson completion persists the lesson id via `AcademyProgressLocalRepository` (identical shape to
`AchievementsLocalRepository`: a `SharedPreferences` string list, entries only ever added). Total game XP was
previously `AchievementCatalog.totalXpFor(unlockedAchievementIds)` alone; it is now
`TotalXpCalculator.compute()` = achievement XP + academy XP, in one place
(`lib/core/services/total_xp_calculator.dart`), used by both `PortfolioController._evaluateGamification()` (so a
portfolio refresh never clobbers XP earned from lessons) and `LessonSessionController` (so completing a lesson is
reflected immediately without waiting for the next portfolio load). This is the one deliberate cross-feature touch
point — Academy does not depend on `PortfolioController` or any financial aggregate, only on the same
`AchievementsLocalRepository` read `PortfolioController` already uses, so the education bounded context stays
decoupled from Portfolio/Transactions/Assets per the brief's own §17.

On lesson completion: `MascotController.evaluateEvolution(currentNetWorth, newTotalXp)` runs (same call
`PortfolioController` already makes), so a lesson can trigger a level-up or pet evolution exactly like an achievement
does, and `MascotController.triggerEventAnimation(PetAnimationState.victory)` plays the same pet reaction. No new
animation states, no new event bus events were needed — `UserLeveledUpEvent`/`PetEvolvedEvent` already fire generically
from `evaluateEvolution` regardless of caller.

## 5. UX Flow (implemented)

```
Home → "Treinar" button → AcademyHomeScreen
  → shows current level, next-lesson CTA, module list (in-progress / completed / coming soon)
  → ModuleDetailScreen (lesson list with locked/available/completed state + progress bar)
    → LessonScreen (step player: progress bar, one step at a time, Continue button)
      → on last step: inline completion state (glass card, +XP, "Continuar" / "Voltar à Academia")
```

Reused verbatim: `CosmicBackground`, `GlassCard`, `GameButton`, the `AchievementCelebrationOverlay` visual language
(sparkle burst, gold glow, `+N XP` pill) for the lesson-complete moment, `PortfolioProgressBar`'s progress-bar visual
style for module/lesson progress, and the existing `_fadeRoute` push transition used everywhere else in the app.

## 6. Folder Structure (implemented)

```
petapp_mobile/lib/features/academy/
  domain/
    entities/academy_module.dart
    entities/lesson.dart
    entities/lesson_step.dart
    services/academy_catalog.dart
    services/academy_progress_calculator.dart
  data/
    repositories/academy_progress_local_repository.dart
  presentation/
    controllers/academy_controller.dart
    controllers/lesson_session_controller.dart
    screens/academy_home_screen.dart
    screens/module_detail_screen.dart
    screens/lesson_screen.dart
    widgets/module_card.dart
    widgets/lesson_list_tile.dart
    widgets/academy_progress_bar.dart
    widgets/steps/explanation_step_view.dart
    widgets/steps/example_step_view.dart
    widgets/steps/choice_question_step_view.dart
    widgets/steps/summary_step_view.dart
    widgets/lesson_complete_card.dart

petapp_mobile/lib/core/services/total_xp_calculator.dart
```

No new top-level pattern; mirrors `features/portfolio/` and `features/mentor/` exactly.

## 7. Phase 3+ (explicitly deferred — design intent only)

These are not built. Each needs a real trigger (more content, real usage data, or a dependency that doesn't exist
yet) before it's worth building, per `AI_RULES.md`'s "does it solve a real, measured problem" test.

- **Backend-authoritative progress**: `POST /api/education/lessons/{id}/complete` + Flyway tables
  (`education_modules`, `education_lessons`, `user_lesson_progress`), once local-only achievements/missions
  themselves make that same migration (`MARKET_EVENTS_ENGINE.md` §6 already earmarks this as "the single
  highest-value, lowest-risk first migration" for achievements — Academy should follow, not lead, that move).
- **Remaining 6 modules' real content** (Fixed Income → Advanced), written and reviewed incrementally, module by
  module, validated against real user engagement with Module 1 first.
- **Practical market challenges** (brief §7): a `PracticalChallenge` entity referencing a real ticker/ratio, reward
  wired through the same `TotalXpCalculator`, gated on the asset-details screen already having the indicator data
  (`IndicatorEducationCatalog`) — the natural next integration once Module 4 (Fundamental Analysis) has real content.
- **Paper trading step type**: a `SimulationStep` LessonStep subclass, gated on a simulated-allocation feature that
  doesn't exist yet.
- **Streak**: plug into `MARKET_EVENTS_ENGINE.md`'s `STREAK_MAINTAINED`/`user_streak` design once that ships, rather
  than building a second streak tracker.
- **CMS / content pipeline**: only worth it once content velocity (multiple modules, frequent edits) makes hardcoded
  Dart catalogs the actual bottleneck — not before, per YAGNI.
- **Offline-first outbox sync**: only meaningful once progress is backend-authoritative; local-only progress has
  nothing to sync yet.

## 8. Edge Cases (Phase 0)

- **Answering the same question twice**: `LessonSessionController` locks in the first answer per step
  (`hasAnswered`) — no re-answering to game the "correct" state, but also no penalty for the wrong first answer.
- **Leaving mid-lesson**: nothing is persisted until the lesson's final step completes — a partially-played lesson
  simply resumes from step 1 next time, no partial-credit bookkeeping to get wrong.
- **Re-opening a completed lesson**: allowed, freely replayable for review; replaying never re-grants XP (`markCompleted`
  is a set-union, identical semantics to achievement unlocking).
- **Module with no content yet**: rendered as "coming soon" unconditionally — never gated behind a fake unlock
  condition that would mislead the user about their own progress.

## Documentation Follow-Ups

Per `AI_RULES.md` ("whenever a significant architectural decision is made, suggest updating DECISIONS.md,
FEATURES.md, ROADMAP.md"):

- `FEATURES.md`: "Learning Content" status updated to reference this document.
- `DECISIONS.md`: new entry recording the Phase-0-slice scoping decision and the no-punishment (no lives/hearts)
  decision.
- `ROADMAP.md`: Phase 1 (MVP) now references Academy Phase 0 as delivered; remaining phases referenced under Phase 3.
