# DECISIONS.md

# Architectural & Product Decisions

## Purpose

This document records important technical and product decisions made throughout the project's development.

Each decision includes:

- Context
- Decision
- Rationale
- Consequences

The objective is to preserve historical knowledge and avoid repeatedly discussing decisions that have already been made.

---

# DECISION-001

## Title

Flutter as the Mobile Framework

### Status

Accepted

### Context

The project requires a cross-platform mobile application with a modern UI, strong community support, and long-term maintainability.

### Decision

Flutter is the official frontend framework.

### Rationale

Flutter provides:

- Excellent performance
- Native compilation
- Strong UI capabilities
- Cross-platform development
- Large ecosystem
- Long-term maintainability

Changing the frontend framework is not planned.

### Consequences

All mobile development should follow Flutter best practices.

---

# DECISION-002

## Title

Spring Boot as the Backend

### Status

Accepted

### Context

The application requires authentication, business rules, APIs, and database integration.

### Decision

Spring Boot is the official backend framework.

### Rationale

Spring Boot offers:

- Mature ecosystem
- Strong security support
- Excellent REST capabilities
- Scalability
- Maintainability

The current architecture fully satisfies MVP requirements.

### Consequences

Backend development should continue using Spring Boot.

---

# DECISION-003

## Title

Traditional Backend Instead of Serverless

### Status

Accepted

### Context

AWS Lambda and serverless architectures were evaluated.

### Decision

Do not migrate the backend to AWS Lambda during MVP development.

### Rationale

Current requirements do not justify additional complexity.

A traditional backend provides:

- Easier debugging
- Simpler architecture
- Faster development
- Lower maintenance cost

### Future

Lambda may be introduced later for asynchronous workloads only.

Examples:

- Scheduled jobs
- Notifications
- Reports
- Ranking calculations

Core business logic should remain inside Spring Boot.

---

# DECISION-004

## Title

MVP First

### Status

Accepted

### Context

Many projects fail because they spend excessive time redesigning or rebuilding instead of shipping.

### Decision

Complete the MVP before introducing major improvements.

### Rationale

A working product generates feedback.

Feedback generates better decisions.

Unreleased software generates assumptions.

### Consequences

Prioritize completing existing functionality.

Avoid feature creep.

---

# DECISION-005

## Title

Preserve the Current Visual Identity

### Status

Accepted

### Context

The application's visual identity has evolved into a consistent futuristic space theme.

### Decision

Do not redesign the interface unless explicitly requested.

### Rationale

The current design successfully communicates:

- Gamification
- Progress
- Premium quality
- Exploration

Future work should focus on refinement rather than redesign.

### Consequences

Improvements should target:

- Better spacing
- Better hierarchy
- Better animations
- Better accessibility

Not a completely different visual style.

---

# DECISION-006

## Title

Gamification as a Core Product Principle

### Status

Accepted

### Context

The product aims to teach investing through engagement.

### Decision

Gamification is a core system, not an optional feature.

### Rationale

Progression systems increase motivation and long-term retention.

Examples include:

- XP
- Levels
- Missions
- Achievements
- Rewards
- Rankings

### Consequences

Every major feature should reinforce user progression whenever appropriate.

---

# DECISION-007

## Title

The Application Is Not a Banking App

### Status

Accepted

### Context

Many financial applications follow traditional banking interfaces.

### Decision

Pet Invest App should not resemble a bank or brokerage.

### Rationale

The application is an educational platform.

The interface should feel approachable, enjoyable, and game-inspired.

### Consequences

Avoid:

- Corporate dashboards
- Banking aesthetics
- Enterprise UI patterns

Favor:

- Exploration
- Progress
- Rewards
- Premium game-inspired design

---

# DECISION-008

## Title

Incremental Refactoring

### Status

Accepted

### Context

Large rewrites frequently introduce regressions and delay delivery.

### Decision

Improve the project incrementally.

### Rationale

Small improvements are:

- Safer
- Easier to review
- Easier to test
- Easier to maintain

### Consequences

Avoid rewriting working modules.

Improve code while implementing new features.

---

# DECISION-009

## Title

Reusable Components

### Status

Accepted

### Context

The UI will continue growing throughout development.

### Decision

Prioritize reusable UI components.

### Rationale

Reusable components improve:

- Consistency
- Development speed
- Maintainability

### Consequences

Before creating a new widget, verify whether an existing component can be reused or extended.

---

# DECISION-010

## Title

Technology Should Support the Product

### Status

Accepted

### Context

New technologies appear continuously.

### Decision

Technology changes should only occur when they solve a real problem.

### Rationale

Changing frameworks or architectures simply because they are newer creates unnecessary maintenance costs.

### Consequences

Avoid replacing stable technologies without measurable benefits.

---

# DECISION-011

## Title

Academy (Financial Education) — Phase 0 Scope, Client-Only, No Punitive Mechanics

### Status

Accepted

### Context

A brief requested a full production Academy: backend REST API + Flyway tables, offline-first sync, CMS-ready
content, eight fully populated curriculum modules, and a Duolingo-style lives/hearts mechanic. This exceeds
DECISION-004 (MVP First) and ROADMAP.md, which lists "Interactive tutorials" and "Investment quizzes" as
post-MVP. Separately, a lives/hearts mechanic conflicts with PROJECT_CONTEXT.md's explicit rule that the game must
never punish the user.

### Decision

Ship a client-only Phase 0 slice: one fully authored module reachable from the existing "Treinar" button, local
XP/progress persistence following the same pattern as `AchievementsLocalRepository`, and no lives/hearts or other
punitive mechanic — wrong answers get encouraging feedback and the user continues. The full north-star design
(backend-authoritative progress, remaining curriculum, practical market challenges, paper trading) is documented in
`ACADEMY_ENGINE.md` as explicit future phases, not built now.

### Rationale

Mirrors the precedent already set by `MARKET_EVENTS_ENGINE.md` for the same tension. A real, working slice that
reuses existing patterns (catalog-of-defs content, local persistence, the achievement celebration UI) delivers value
now without the multi-week, cross-stack lift the full brief implies, and without contradicting the project's own
no-punishment design principle.

### Consequences

Future work extending Academy content or moving progress server-side should follow `ACADEMY_ENGINE.md`'s phasing
rather than re-deriving scope from the original brief.

---

# Future Decisions

Whenever a significant architectural or product decision is made, add a new entry following the same structure.

Each decision should include:

- Title
- Status
- Context
- Decision
- Rationale
- Consequences

---

# Guiding Principle

Document decisions once.

Refer to them often.

Avoid revisiting previously accepted decisions unless new evidence justifies a change.