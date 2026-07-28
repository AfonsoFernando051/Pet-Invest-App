# CODING_GUIDELINES.md

# Coding Guidelines

## Purpose

This document defines the coding standards and development principles for the Pet Invest App.

Its purpose is to ensure consistency, maintainability, readability, and long-term scalability across the entire codebase.

Every contribution should follow these guidelines unless there is a clear technical reason not to.

---

# General Philosophy

Code is written for humans first.

Readable code is more valuable than clever code.

Favor simplicity over unnecessary abstractions.

Every line of code should have a clear purpose.

---

# Core Principles

Always prioritize:

- Readability
- Maintainability
- Simplicity
- Reusability
- Testability
- Consistency

Avoid writing code that is difficult to understand or maintain.

---

# Clean Code

Follow Clean Code principles whenever possible.

Good code should be:

- Easy to read
- Easy to modify
- Easy to test
- Self-explanatory

Prefer expressive code over comments.

Comments should explain *why*, not *what*.

---

# SOLID Principles

Apply SOLID principles where appropriate.

Do not force design patterns when they provide no practical benefit.

The goal is maintainability, not theoretical perfection.

---

# KISS

Keep It Simple.

The simplest solution that solves the problem correctly is usually the best solution.

Avoid unnecessary layers, abstractions, or design patterns.

---

# YAGNI

You Aren't Gonna Need It.

Do not implement functionality based on hypothetical future requirements.

Build what is needed today while keeping the architecture flexible enough for future evolution.

---

# DRY

Don't Repeat Yourself.

Extract reusable logic whenever duplication becomes noticeable.

However, avoid premature abstractions.

A small amount of duplication is often preferable to an unnecessary abstraction.

---

# Naming

Names should clearly express intent.

Good names eliminate the need for comments.

Prefer:

- `calculatePortfolioValue()`
- `currentUser`
- `isAuthenticated`

Avoid:

- `calc()`
- `data`
- `temp`
- `obj`
- `list2`

---

# Functions

Functions should:

- Have a single responsibility
- Be easy to understand
- Be relatively short
- Return predictable results

Avoid deeply nested logic.

Extract complex behavior into smaller methods.

---

# Classes

Classes should represent a single concept.

Avoid "God Classes" that manage multiple unrelated responsibilities.

Prefer composition over inheritance whenever possible.

---

# Business Logic

Business logic must remain independent of the UI.

Flutter Widgets should never contain complex business rules.

Spring Controllers should never contain business logic.

Business logic belongs inside dedicated service classes.

---

# Reusability

Before creating a new component, ask:

- Does something similar already exist?
- Can the existing component be extended?
- Would a reusable solution reduce duplication?

Favor reusable solutions over copy-and-paste implementations.

---

# Flutter Guidelines

Flutter Widgets should be small and focused.

Avoid large widget trees inside a single file.

Extract reusable widgets whenever appropriate.

Separate:

- UI
- State
- Business logic
- Services

Widgets should describe the interface—not implement application rules.

---

# Spring Boot Guidelines

Controllers should:

- Receive requests
- Validate input
- Call services
- Return responses

Services should:

- Execute business rules
- Coordinate repositories
- Validate domain logic

Repositories should:

- Access the database
- Execute queries
- Persist entities

Repositories should never contain business rules.

---

# Error Handling

Handle errors explicitly.

Avoid silent failures.

Provide meaningful error messages.

Unexpected exceptions should be logged.

User-facing messages should be understandable and actionable.

---

# Constants

Avoid magic numbers and hardcoded strings.

Extract constants into appropriate locations.

Examples include:

- API endpoints
- Animation durations
- Padding values
- Colors
- Validation limits

---

# Null Safety

Prefer explicit null handling.

Avoid force unwrapping unless absolutely necessary.

Code should fail safely rather than unexpectedly.

---

# Dependency Management

Add dependencies only when they provide clear value.

Before introducing a new library, ask:

- Does Flutter or Spring already solve this?
- Is the dependency actively maintained?
- Does it reduce complexity?
- Is it worth the additional maintenance?

Avoid unnecessary dependencies.

---

# Performance

Write clean code first.

Optimize only after identifying real bottlenecks.

Do not sacrifice readability for hypothetical performance gains.

---

# Documentation

Public APIs, complex business rules, and architectural decisions should be documented.

Documentation should explain intent rather than implementation details.

Keep documentation up to date with the code.

---

# Logging

Log meaningful events only.

Useful logs include:

- Authentication events
- Business failures
- External API failures
- Unexpected exceptions

Avoid excessive logging.

Never log sensitive information such as passwords, tokens, or personal data.

---

# Code Reviews

Every code change should improve at least one of the following:

- Readability
- Maintainability
- Reliability
- Performance
- User experience

Avoid changes that increase complexity without delivering measurable value.

---

# Refactoring

Refactor incrementally.

Avoid large rewrites.

Improve the codebase continuously while implementing new features.

Working software should not be rewritten without strong justification.

---

# Testing

Critical business logic should be testable.

Prioritize tests for:

- Authentication
- Business rules
- Financial calculations
- User progression
- Missions
- Achievements

Testing should increase confidence, not become a burden.

---

# Consistency

Consistency is more valuable than personal preference.

Follow existing project conventions before introducing new patterns.

A consistent codebase is easier to maintain than a collection of individually "perfect" solutions.

---

# AI Development Guidelines

When generating code, always prefer:

- Existing project patterns
- Existing components
- Existing architecture

Do not introduce new architectural styles unless explicitly requested.

Do not rewrite existing implementations simply because another approach is possible.

Favor incremental improvements over replacement.

---

# Guiding Questions

Before submitting code, ask yourself:

- Is this easy to understand?
- Is this consistent with the existing project?
- Can another developer maintain it easily?
- Is there unnecessary complexity?
- Can this be reused elsewhere?
- Does this preserve the current architecture?

If the answer to any of these questions is "no", reconsider the implementation.

---

# Guiding Principle

Good code is not the most clever solution.

Good code is the solution that another developer can understand, maintain, and extend with confidence.