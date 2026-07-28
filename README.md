# Pet Invest App

> A gamified financial education platform that makes learning investing engaging, intuitive, and rewarding.

---

# Overview

Pet Invest App is a cross-platform mobile application built to teach investing through gamification.

Instead of behaving like a traditional banking application or brokerage platform, Pet Invest App focuses on education, progression, and user engagement.

The application combines investment simulation with game mechanics such as experience points, levels, missions, achievements, rankings, and rewards to create an enjoyable learning experience.

---

# Project Goals

- Teach investing through interaction
- Encourage healthy financial habits
- Make financial education accessible
- Increase long-term user engagement
- Deliver a premium mobile experience

---

# Technology Stack

## Frontend

- Flutter
- Dart

## Backend

- Java
- Spring Boot

## Database

- PostgreSQL

## Authentication

- JWT

---

# Architecture

The project follows a traditional client-server architecture.

```
Flutter
      │
 REST API
      │
Spring Boot
      │
 PostgreSQL
```

The backend is intentionally maintained as a monolithic application during MVP development to maximize development speed and maintainability.

Future infrastructure improvements will only be introduced when justified by real product needs.

---

# Repository Structure

Example structure:

```
root/

frontend/
backend/
docs/

README.md
```

The exact folder organization may evolve over time.

---

# Documentation

The complete project documentation is available in the `docs` directory.

Recommended reading order:

1. AGENTS.md
2. PROJECT_CONTEXT.md
3. PRODUCT_VISION.md
4. ARCHITECTURE.md
5. DESIGN_SYSTEM.md
6. CODING_GUIDELINES.md
7. API_GUIDELINES.md
8. FEATURES.md
9. ROADMAP.md
10. DECISIONS.md
11. AI_RULES.md

---

# Development Philosophy

The project follows a few simple principles:

- MVP first
- Build before optimizing
- Preserve simplicity
- Prefer incremental improvements
- Prioritize maintainability
- Reuse components whenever possible

Technology exists to support the product—not define it.

---

# Product Identity

Pet Invest App is **not**:

- A bank
- A brokerage
- A cryptocurrency exchange
- A professional trading platform

Pet Invest App **is**:

- A gamified financial education platform
- An investment simulator
- A learning experience
- A progression-based application

Every contribution should reinforce this identity.

---

# Current Status

The project is currently focused on completing the Minimum Viable Product (MVP).

Current priorities include:

- Authentication
- Portfolio
- Market
- Asset trading
- User progression
- Missions
- Achievements
- Rankings

Large architectural changes are intentionally postponed until after the MVP.

---

# Contributing

Before making changes:

- Read the documentation in the `docs` folder.
- Follow the existing architecture.
- Preserve the visual identity.
- Reuse existing components whenever possible.
- Avoid unnecessary complexity.

Every contribution should improve maintainability without delaying the MVP.

---

# Coding Standards

This project follows:

- Clean Code
- SOLID (when appropriate)
- KISS
- DRY
- YAGNI

Consistency is preferred over personal coding style.

---

# Design Principles

The application's visual identity is already established.

Future work should focus on refinement rather than redesign.

The interface should remain:

- Futuristic
- Premium
- Space-inspired
- Gamified
- Dark-first

---

# Long-Term Vision

Pet Invest App aims to become a reference platform for gamified investment education.

The focus is not on becoming another investment platform, but on making financial learning engaging, motivating, and accessible.

---

# Guiding Principle

> Build a product that helps people learn investing while making the journey feel rewarding, enjoyable, and memorable.