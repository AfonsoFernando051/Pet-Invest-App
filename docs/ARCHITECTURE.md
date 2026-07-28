# ARCHITECTURE.md

# System Architecture

## Overview

Pet Invest App follows a traditional client-server architecture designed for maintainability, scalability, and rapid MVP development.

The current architecture prioritizes simplicity and predictable development over premature optimization.

The application is intentionally designed to evolve incrementally as the product grows.

---

# Technology Stack

## Frontend

- Flutter
- Dart

Responsibilities:

- User Interface
- State Management
- Navigation
- API Communication
- Local Storage
- Animations
- User Experience

---

## Backend

- Java
- Spring Boot

Responsibilities:

- Authentication
- Authorization
- Business Rules
- Investment Simulation
- User Progression
- Missions
- Achievements
- Rankings
- REST API

---

## Database

- PostgreSQL

Responsibilities:

- Persistent storage
- Transactions
- User data
- Financial simulation
- Game progression

---

## Authentication

Authentication is based on JWT.

Responsibilities:

- Login
- Registration
- Token validation
- Session management
- Authorization

---

# Architecture Style

The backend follows a layered architecture.

```
Controller
    ↓
Service
    ↓
Repository
    ↓
Database
```

Each layer has a single responsibility.

Business logic belongs exclusively inside the Service layer.

Controllers should remain thin.

Repositories should only access data.

---

# Frontend Architecture

Flutter should be organized by features whenever possible.

Example:

```
lib/

features/
    authentication/
    home/
    portfolio/
    market/
    missions/
    achievements/
    ranking/
    profile/

shared/
    components/
    theme/
    services/
    models/
    utils/
```

The exact folder structure may evolve, but responsibilities should remain clear.

---

# Backend Architecture

The backend should be organized by business domains.

Example:

```
authentication/

portfolio/

market/

missions/

achievements/

ranking/

profile/

notifications/
```

Avoid organizing packages only by technical type.

Business domains should be easy to identify.

---

# Business Logic

Business rules should never exist inside:

- Flutter Widgets
- Controllers
- Database queries

Business rules belong in dedicated service classes.

---

# API Design

The backend exposes a REST API.

General principles:

- Stateless
- JSON only
- Consistent naming
- Clear error responses
- Proper HTTP status codes

Future GraphQL adoption is not planned.

---

# State Management

The chosen state management solution should:

- Separate UI from business logic
- Be testable
- Be predictable
- Minimize widget rebuilds

Business logic should never depend directly on Widgets.

---

# Reusable Components

The frontend should maximize component reuse.

Examples:

- Buttons
- Cards
- Dialogs
- Inputs
- Progress Indicators
- Loading States
- Empty States
- Error States

Avoid duplicating UI code.

---

# Database Principles

The database is the single source of truth.

Avoid:

- duplicated information
- inconsistent relationships
- unnecessary denormalization

Optimize only when measurements indicate a real need.

---

# Performance Philosophy

Performance is important.

Premature optimization is not.

Always prefer:

- readable code
- maintainable code
- measurable improvements

Only optimize proven bottlenecks.

---

# Scalability

The current architecture is intentionally simple.

Scale only when necessary.

Expected evolution:

1. Stable MVP
2. Production usage
3. Performance improvements
4. Infrastructure improvements
5. Horizontal scaling

Do not build for millions of users before validating the product.

---

# AWS Strategy

AWS Lambda has been evaluated.

Current decision:

Do NOT migrate the backend to a serverless architecture during MVP development.

Reasons:

- Increased complexity
- Harder debugging
- No current scaling requirement
- Traditional backend better fits current needs

Future Lambda adoption is acceptable only for asynchronous workloads.

Examples:

- Scheduled jobs
- Notification processing
- Report generation
- Ranking updates
- Background calculations
- Import/export tasks

Core business logic should remain inside the Spring Boot backend.

---

# Error Handling

Errors should be:

- predictable
- descriptive
- logged
- user-friendly

Never expose internal exceptions directly to users.

---

# Logging

Log meaningful events.

Examples:

- Authentication
- Business failures
- External API failures
- Unexpected exceptions

Avoid excessive logging.

Sensitive information must never be logged.

---

# Security

Always validate:

- authentication
- authorization
- user ownership
- request input

Never trust client-side validation.

The backend is responsible for enforcing business rules.

---

# Testing Philosophy

Critical business rules should be testable.

Prioritize testing:

- Services
- Business rules
- Authentication
- Financial calculations

UI testing is secondary during MVP.

---

# Maintainability

Every architectural decision should reduce long-term maintenance costs.

Prefer:

- simple solutions
- explicit code
- reusable modules
- low coupling
- high cohesion

Avoid unnecessary abstractions.

---

# Evolution Principles

Architecture should evolve gradually.

Preferred order:

1. Build
2. Validate
3. Improve
4. Optimize
5. Scale

Avoid rewriting working code unless there is a measurable benefit.

---

# Decision Principles

Before introducing a new library, framework, or architectural pattern, ask:

- Does it solve a real problem?
- Is the current solution insufficient?
- Does it reduce maintenance?
- Is the added complexity justified?
- Will the team benefit from this change?

If the answer is "no" to most questions, keep the existing solution.

---

# Architecture Goals

The architecture should always prioritize:

- Simplicity
- Readability
- Maintainability
- Testability
- Scalability
- Reliability

Technology choices should support the product—not drive it.