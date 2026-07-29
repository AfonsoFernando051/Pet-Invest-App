# AI Investment Mentor

## Status

Phase 1 (MVP) implemented: a "Mentor" bottom-nav tab where the user's pet
answers investing questions, grounded in the user's real portfolio and pet
context, following the product's long-term/educational philosophy and safety
rules (no buy/sell recommendations, no price predictions, no return
guarantees).

## What shipped in Phase 1

- Mobile: `petapp_mobile/lib/features/mentor/` — chat UI (bubbles, markdown
  rendering, suggested prompts, typing indicator, client-side typewriter
  reveal), a `MentorChatController` (`ChangeNotifier`), and a
  `MentorChatRepository` that persists the running conversation locally via
  `SharedPreferences` (single thread, no cloud sync).
- Backend: `PetApp-Backend` `application/mentor/*` + `infrastructure/.../mentor` —
  a `POST /api/mentor/chat` endpoint that loads the authenticated user's real
  portfolio/pet server-side, merges it with mobile-local signals (goal,
  horizon, current screen, language), builds a dedicated system prompt
  (`MentorSystemPromptBuilder`), and calls Google Gemini through a
  `GeminiChatPort`/`GeminiChatClient` adapter (plain `RestTemplate`, matching
  the existing Brapi/LibreTranslate client style). The API key never reaches
  the mobile client.
- "Streaming" is simulated client-side (typewriter reveal over a normal
  request/response call) — no SSE/reactive stack was added to the backend.

## Deferred (documented intent, not implemented)

These were requested in the original feature spec but intentionally deferred
to keep Phase 1 inside this project's MVP-first, avoid-speculative-development
principles (`docs/AI_RULES.md`, `docs/DECISIONS.md`):

- **Multiple AI providers wired up simultaneously / runtime switching.** The
  `GeminiChatPort` interface makes adding a second provider a contained
  change, but no second implementation exists yet — YAGNI until there's a
  real reason (cost, quality, outage) to switch.
- **True token-level streaming (SSE).** Would require adding a reactive
  stack (`spring-webflux`) or `SseEmitter`/chunked responses on the backend;
  not justified while the simulated typewriter reveal already delivers a
  premium feel.
- **Multiple named conversations, search, cloud sync.** Phase 1 is a single
  running thread persisted locally. A backend chat-history table would be
  the natural next step if multi-device/multi-thread history is needed.
- **Voice (STT/TTS), vision/image analysis, document/portfolio PDF analysis,
  screen-context agent mode, multi-agent architecture.** No code, no
  scaffolding — these are real product ideas for later, not stubs to
  maintain now.
- **Chat-triggered XP/badges/missions.** Needs anti-abuse consideration
  (e.g. spamming the chat for free XP) and depends on the missions/events
  engine described in `docs/MARKET_EVENTS_ENGINE.md`, which is itself not
  yet implemented. The pet still reacts visually (typing indicator) but chat
  currently grants no rewards.

## Safety rules baked into the system prompt

Never recommend buying/selling a specific security, never predict prices or
promise returns, never claim to be a licensed financial advisor, and always
redirect "what should I buy" questions toward the user's own goals/allocation
and the underlying methodology instead of a direct answer.

## Secrets & security

- **No secret ever reaches the mobile client.** The Gemini API key lives only
  in the backend process; the mobile app only ever sees the mentor's final
  `reply` text (`MentorChatResponse`), never the API key, the system prompt,
  or the raw portfolio/pet context assembled to build it.
- **No secret is committed to git.** `jwt.secret`, `api.brapi.token`,
  `api.libretranslate.key` and `api.gemini.key` are all blank in
  `application.properties`. Real values live in `PetApp-Backend/.env`
  (git-ignored — see root `.gitignore`), loaded into JVM system properties by
  `DotenvLoader.loadIntoSystemProperties()` at the top of `main()` before
  Spring starts, so `@Value("${api.gemini.key:}")`-style injection keeps
  working unchanged. `PetApp-Backend/.env.example` documents the expected
  keys with placeholder values, safe to commit. In CI/production, set real
  environment variables instead — `.env` is a local-dev convenience only.
  (Spring Boot's `EnvironmentPostProcessor` SPI was deprecated-for-removal as
  of Boot 4.0, so this deliberately doesn't depend on it.)
- **The system prompt itself is internal, not secret** — it's built fresh
  per request in `MentorSystemPromptBuilder` (backend-only,
  `application/mentor/prompt/`) and passed directly to Gemini; it's never
  serialized into any HTTP response body.
