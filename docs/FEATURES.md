# FEATURES.md

# Features

## Overview

This document describes every feature of the Pet Invest App.

Each feature contains:

- Purpose
- User Goals
- Responsibilities
- Business Rules
- Current Status
- Future Improvements

This document should be updated whenever a new feature is added or significantly modified.

---

# Authentication

## Purpose

Allow users to securely access the application.

## Responsibilities

- User registration
- User login
- Logout
- Session validation
- Password recovery
- JWT authentication

## Business Rules

- Email must be unique.
- Passwords must be securely hashed.
- Users must authenticate before accessing protected resources.
- Expired tokens require reauthentication.

## Status

In Progress

---

# User Profile

## Purpose

Represent the player's identity inside the application.

## Responsibilities

- Avatar
- Username
- Experience
- Level
- Statistics
- Progress overview

## Business Rules

- Every user owns exactly one profile.
- Level progression is based on accumulated experience.
- User progress is persistent.

## Status

Planned

---

# Portfolio

## Purpose

Allow users to simulate building an investment portfolio.

## Responsibilities

- Portfolio visualization
- Asset allocation
- Portfolio value
- Profit and loss
- Investment history

## Business Rules

- Portfolio values are calculated using simulated market data.
- Historical transactions cannot be modified.
- Portfolio value updates according to asset prices.

## Status

In Progress

---

# Market

## Purpose

Provide simulated investment assets.

## Responsibilities

- Asset listing
- Asset details
- Price history
- Categories
- Search

## Business Rules

- Market data is simulated.
- Prices may change over time.
- Users cannot modify market information.

## Status

In Progress

---

# Dividend Radar

## Purpose

Show users the real, confirmed dividend/JCP/yield payments for the assets they actually hold — inspired by
Investidor10's dividend calendar/radar, adapted to this app's "the number never lies" principle (see
`MARKET_EVENTS_ENGINE.md`).

## Responsibilities

- Fetch confirmed corporate-action history from the external market data provider (Brapi
  `/api/v2/stocks/dividends`) for every distinct ticker the user holds.
- Split into upcoming (announced, not yet paid) and history (already paid), each scaled by the quantity the
  user actually held at the relevant date.
- Surface the radar inside the existing "Proventos" tab, above the pre-existing yield-based estimate, so
  confirmed data and projection are never visually conflated.

## Business Rules

- Never fabricate a payment: a ticker the provider has nothing confirmed for contributes nothing to the radar.
- A historical (already-paid) event only counts for a user if they held the position on or before that
  event's data-com date — a position purchased after the fact is never scaled into "what you received".
- Upcoming events are scaled by the user's current quantity as a forward-looking estimate, clearly distinct
  in the UI from the confirmed history section.

## Status

Implemented (Phase 0 slice of `MARKET_EVENTS_ENGINE.md` — no XP/mission/notification wiring yet; that remains
Phase 3+, pending the event-driven gameplay engine described there).

---

# Buy Assets

## Purpose

Allow users to purchase simulated assets.

## Responsibilities

- Purchase execution
- Balance validation
- Portfolio update

## Business Rules

- Users cannot spend more than their available balance.
- Every purchase creates a transaction history record.
- Portfolio updates immediately after a purchase.

## Status

Planned

---

# Sell Assets

## Purpose

Allow users to sell assets from their portfolio.

## Responsibilities

- Sell execution
- Balance update
- Portfolio update
- Transaction history

## Business Rules

- Users cannot sell assets they do not own.
- Partial sales are allowed.
- Portfolio value is recalculated after each transaction.

## Status

Planned

---

# Transactions

## Purpose

Store every investment operation performed by the user.

## Responsibilities

- Buy history
- Sell history
- Date
- Quantity
- Price

## Business Rules

- Transaction history is immutable.
- Every operation must be traceable.

## Status

Planned

---

# Experience System (XP)

## Purpose

Reward user activity.

## Responsibilities

- Gain XP
- Level progression
- Progress tracking

## Business Rules

Users earn experience by:

- Completing missions
- Logging in daily
- Learning content
- Investing
- Achievements

Experience is cumulative.

## Status

Planned

---

# Level System

## Purpose

Represent long-term user progression.

## Responsibilities

- Player level
- XP requirements
- Progress display

## Business Rules

- Levels cannot decrease.
- XP requirements increase progressively.

## Status

Planned

---

# Missions

## Purpose

Guide users through educational objectives.

## Responsibilities

- Daily missions
- Weekly missions
- Progress tracking
- Rewards

## Business Rules

Missions should encourage:

- Learning
- Exploration
- Consistent usage

## Status

Planned

---

# Achievements

## Purpose

Reward important milestones.

## Responsibilities

- Unlock achievements
- Achievement gallery
- Reward notifications

## Business Rules

Achievements are permanent.

Once unlocked, they cannot be removed.

## Status

Planned

---

# Daily Rewards

## Purpose

Encourage daily engagement.

## Responsibilities

- Login rewards
- Streak tracking
- Bonus rewards

## Business Rules

Rewards increase user motivation without creating unhealthy pressure.

## Status

Planned

---

# Ranking

## Purpose

Create friendly competition between users.

## Responsibilities

- Global ranking
- Weekly ranking
- Seasonal ranking

## Business Rules

Rankings should encourage participation rather than frustration.

## Status

Planned

---

# Learning Content (Academy)

## Purpose

Teach investing concepts through short, interactive lessons rather than articles — see
`ACADEMY_ENGINE.md` for the full design.

## Responsibilities

- Module/lesson progression, reachable from the Home "Treinar" button
- Short interactive lessons (explanation, example, micro-exercise, applied scenario, summary)
- XP integration with the existing gamification system
- Curriculum structured across 7-8 modules of increasing difficulty

## Business Rules

- Content should prioritize clarity over technical complexity.
- Content teaches users to investigate concepts, never to imply a buy/sell signal
  (e.g. never "low P/L = good investment").
- No punitive mechanics — a wrong answer gets encouraging feedback, never a lost life or reset progress,
  per this app's existing no-punishment principle for the Pet.

## Status

In Progress — Phase 0 slice shipped (client-only): one fully authored module ("Fundamentos do Investidor"),
remaining modules shown as "coming soon" placeholders. See `ACADEMY_ENGINE.md` for what's deferred and why.

---

# Notifications

## Purpose

Keep users informed.

## Responsibilities

- Mission reminders
- Reward notifications
- Achievement notifications
- Important updates

## Business Rules

Notifications should provide value.

Avoid excessive notifications.

## Status

Planned

---

# Settings

## Purpose

Allow users to personalize their experience.

## Responsibilities

- Theme
- Notification preferences
- Privacy settings
- Account settings

## Status

Planned

---

# Avatar

## Purpose

Represent the player's identity visually.

## Responsibilities

- Avatar customization
- Unlockable items
- Cosmetic progression

## Business Rules

Avatar customization should never affect gameplay balance.

## Status

Future

---

# Inventory

## Purpose

Store cosmetic and collectible items.

## Responsibilities

- Rewards
- Cosmetics
- Collectibles

## Business Rules

Inventory items are tied to the user account.

## Status

Future

---

# Analytics

## Purpose

Measure user engagement and application usage.

## Responsibilities

- Usage metrics
- Feature adoption
- User retention

## Business Rules

Analytics should respect user privacy.

Sensitive personal information must never be collected without consent.

## Status

Future

---

# Future Features

Potential future additions include:

- Seasonal events
- Challenges
- Friend system
- Clubs or guilds
- Interactive tutorials
- Investment quizzes
- Market events
- Collectible cards
- Leaderboard seasons

These features are intentionally excluded from the MVP.

---

# MVP Scope

The MVP focuses on delivering the core experience.

Priority features:

- Authentication
- Portfolio
- Market
- Buy assets
- Sell assets
- User profile
- Experience system
- Levels
- Missions
- Achievements
- Rankings

Everything else can be implemented after the MVP is stable.

---

# Feature Development Principles

When implementing a new feature:

- Keep it simple.
- Build the smallest useful version first.
- Validate it.
- Improve it incrementally.
- Avoid unnecessary complexity.

A working feature is more valuable than a perfect but unfinished one.

---

# Guiding Principle

Every feature should contribute to at least one of the following:

- Learning
- Progression
- Motivation
- Engagement
- User satisfaction

If a feature does not improve the product experience, it should be reconsidered.