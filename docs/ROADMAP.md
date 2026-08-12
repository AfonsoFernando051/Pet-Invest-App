# ROADMAP.md

# Product Roadmap

## Overview

This roadmap defines the development priorities for the Pet Invest App.

The roadmap is intended to guide development decisions and prevent unnecessary work.

The objective is to deliver a complete and stable MVP before expanding the product.

This roadmap should evolve over time.

---

# Development Philosophy

The project follows an MVP-first approach.

Priorities are determined by product value rather than technical interest.

Shipping a functional product is more important than implementing every possible feature.

Avoid feature creep.

---

# Current Phase

## Phase 1 — MVP Development

Status: In Progress

Current objective:

Deliver a complete, stable, and enjoyable first version of the application.

The MVP should provide a complete investment learning experience even if some advanced systems are not yet implemented.

---

# MVP Priorities

The following features are considered essential.

## Authentication

Priority: High

Deliver:

- User registration
- Login
- JWT authentication
- Session persistence
- Logout

---

## Portfolio

Priority: High

Deliver:

- Portfolio overview
- Current balance
- Asset allocation
- Portfolio value
- Investment history

---

## Market

Priority: High

Deliver:

- Asset listing
- Asset details
- Price simulation
- Search

---

## Buy and Sell Assets

Priority: High

Deliver:

- Buy assets
- Sell assets
- Portfolio updates
- Transaction history

---

## User Progression

Priority: High

Deliver:

- XP system
- Levels
- Progress tracking

---

## Missions

Priority: High

Deliver:

- Daily missions
- Weekly missions
- Reward system

---

## Achievements

Priority: High

Deliver:

- Achievement unlocks
- Progress tracking
- Reward feedback

---

## Rankings

Priority: Medium

Deliver:

- Global leaderboard
- Weekly rankings

Friendly competition is encouraged.

---

## Profile

Priority: Medium

Deliver:

- Avatar
- User statistics
- Progress overview

---

## Academy (Learning Content)

Priority: Medium

Phase 0 delivered (client-only): one fully authored module reachable from "Treinar", local XP/progress, no
punitive mechanics. See `ACADEMY_ENGINE.md` for the full phased design and what remains deferred (backend-authoritative
progress, remaining curriculum modules, practical market challenges, paper trading — tracked under Phase 3+ below).

---

# MVP Completion Criteria

The MVP is considered complete when users can:

- Create an account
- Log in
- Explore the market
- Buy assets
- Sell assets
- Build a portfolio
- Earn experience
- Complete missions
- Unlock achievements
- Progress through levels
- Track personal progress

---

# Phase 2 — Product Polish

This phase begins only after the MVP is stable.

Focus areas:

- UI refinements
- UX improvements
- Better animations
- Better transitions
- Better loading states
- Better accessibility
- Improved responsiveness

No major redesigns should occur during this phase.

---

# Phase 3 — Growth

Potential additions:

- Daily rewards
- Streak system
- Notifications
- Avatar customization
- Cosmetic unlocks
- Inventory
- Seasonal events

These features increase engagement but are not required for launch.

---

# Phase 4 — Community

Potential additions:

- Friends
- Clubs
- Guilds
- Social interactions
- Community challenges
- Shared achievements

These features should only be considered after validating user demand.

---

# Phase 5 — Platform Evolution

Future possibilities:

- Analytics
- Background jobs
- Cloud infrastructure improvements
- Performance optimization
- Additional educational content

Infrastructure improvements should support growth, not anticipate it.

---

# Technical Priorities

Current priorities:

- Stable backend
- Reliable authentication
- Clean architecture
- Reusable components
- Maintainable code

Avoid introducing unnecessary technologies during MVP development.

---

# UI Priorities

Current priorities:

- Consistency
- Responsiveness
- Clear navigation
- Premium appearance

The application's visual identity is already established.

Focus on refinement rather than redesign.

---

# Performance Priorities

Current goals:

- Fast application startup
- Smooth navigation
- Responsive interactions
- Efficient API communication

Optimize only when performance issues become measurable.

---

# Features Deferred Until After MVP

The following features are intentionally postponed:

- Avatar evolution
- Cosmetic inventory
- Friend system
- Guilds
- Seasonal events
- Interactive tutorials
- Advanced analytics
- AI-powered recommendations
- Complex social systems

These features should not delay the first release.

---

# Features Not Planned

The following are currently outside the project's scope:

- Cryptocurrency trading
- Real-money investing
- Banking services
- Payment processing
- Brokerage integration
- High-frequency trading
- Complex financial analysis

The application is an educational platform, not a brokerage.

---

# Architecture Evolution

Current architecture is sufficient.

Future improvements may include:

- Background workers
- Serverless jobs
- Queue processing
- Caching
- Horizontal scaling

These changes should only occur when there is a demonstrated need.

---

# Success Metrics

The MVP should achieve:

- Stable authentication
- Reliable portfolio simulation
- Smooth user experience
- Consistent progression
- Engaging gameplay
- Low crash rate
- Positive user feedback

---

# Decision Rules

Before starting a new feature, ask:

- Does this improve the MVP?
- Does this delay the release?
- Is it required for launch?
- Will users benefit immediately?

If the answer is "no", postpone the feature.

---

# Long-Term Vision

After the MVP, the project should evolve through continuous improvements.

Growth should be driven by:

- User feedback
- Real usage data
- Product validation
- Measured technical needs

Avoid speculative development.

---

# Guiding Principle

Finish what has already been started before building something new.

A completed MVP creates more value than an unfinished product with dozens of partially implemented features.