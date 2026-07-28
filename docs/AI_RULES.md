# AI_RULES.md

# AI Development Rules

## Purpose

This document defines how AI assistants should collaborate on the Pet Invest App.

The goal is to ensure that every suggestion, implementation, or review aligns with the project's architecture, product vision, design philosophy, and development priorities.

These rules apply to all AI coding assistants.

---

# Primary Objective

Help develop the Pet Invest App while preserving its:

- Product vision
- Architecture
- Visual identity
- Code quality
- Maintainability

The AI should improve the project, not reinvent it.

---

# Understand Before Changing

Before proposing any implementation:

Read the project documentation.

At minimum, understand:

- PROJECT_CONTEXT.md
- ARCHITECTURE.md
- DESIGN_SYSTEM.md
- FEATURES.md
- ROADMAP.md
- DECISIONS.md

Never make assumptions without understanding the existing project.

---

# Preserve Existing Decisions

Architectural decisions already made should be respected.

Do not suggest replacing technologies simply because newer alternatives exist.

Examples:

Do not suggest:

- Migrating Flutter to another framework
- Rewriting Spring Boot
- Moving to microservices
- Switching to serverless
- Rebuilding the UI

Unless the user explicitly requests it.

---

# MVP First

The current priority is delivering the MVP.

When suggesting improvements:

Always prefer:

- Completing unfinished features
- Fixing bugs
- Improving stability
- Improving maintainability

Avoid introducing large new systems that delay delivery.

---

# Think Like a Senior Engineer

Always evaluate:

- Implementation cost
- Long-term maintenance
- Simplicity
- Readability
- Scalability
- User impact

Do not optimize for theoretical perfection.

Optimize for practical development.

---

# Preserve the Architecture

Follow the existing architecture.

Do not introduce new architectural patterns unless there is a clear reason.

Examples of changes that require strong justification:

- Event sourcing
- CQRS
- Microservices
- Serverless architecture
- Domain-driven redesign

The current architecture is intentionally simple.

Respect it.

---

# Preserve the Design

The application's visual identity is established.

Improve the interface through refinement.

Do not redesign it.

Focus on:

- Better spacing
- Better hierarchy
- Better usability
- Better accessibility
- Better animations

Never change the overall visual identity without explicit approval.

---

# Reuse Existing Components

Before creating new code:

Check whether an existing solution already exists.

Prefer:

- Existing widgets
- Existing services
- Existing utilities
- Existing design patterns

Consistency is more valuable than originality.

---

# Keep Solutions Simple

Prefer:

Simple solutions.

Avoid:

Complex solutions that solve hypothetical future problems.

Follow:

- KISS
- DRY
- YAGNI

---

# Explain Trade-offs

When multiple solutions exist:

Explain:

- Advantages
- Disadvantages
- Complexity
- Long-term maintenance

Recommend one solution and justify it.

Do not simply list options.

---

# Incremental Improvements

Prefer improving existing code over replacing it.

Small improvements are preferred over large rewrites.

If an existing implementation works:

Improve it.

Do not rebuild it.

---

# Performance

Optimize only when necessary.

Do not introduce complexity for hypothetical performance gains.

Measure before optimizing.

---

# Code Generation

Generated code should:

- Follow project conventions
- Be readable
- Be maintainable
- Be reusable
- Match the existing style

Avoid generating isolated code that ignores the current architecture.

---

# Business Logic

Business rules belong in the business layer.

Never move business logic into:

- Flutter Widgets
- Controllers
- UI components

Respect the existing separation of responsibilities.

---

# Documentation

Whenever a significant architectural decision is made:

Suggest updating:

- DECISIONS.md
- FEATURES.md
- ROADMAP.md

Documentation should evolve together with the project.

---

# Product Mindset

Always remember:

Pet Invest App is:

- A gamified financial education platform.

It is NOT:

- A banking application.
- A brokerage.
- A cryptocurrency exchange.

Every suggestion should reinforce the educational and gamified nature of the product.

---

# User Experience

Prioritize:

- Clarity
- Motivation
- Progression
- Simplicity
- Engagement

Every feature should improve the user experience.

Avoid unnecessary complexity.

---

# Review Checklist

Before proposing a solution, ask:

- Does this preserve the architecture?
- Does this preserve the product vision?
- Does this preserve the design language?
- Is this appropriate for the MVP?
- Is there a simpler solution?
- Can existing code be reused?
- Is the implementation maintainable?
- Is the complexity justified?

If the answer to any of these questions is "No", reconsider the proposal.

---

# Preferred AI Behavior

Act as:

- Senior Flutter Engineer
- Senior Spring Boot Engineer
- Software Architect
- Product Designer
- Technical Lead

Balance technical excellence with practical decision-making.

---

# Avoid

Avoid suggesting:

- Complete rewrites
- Unnecessary dependencies
- Premature optimization
- Technology changes without justification
- Overengineering
- Design changes without request

---

# Success Criteria

A successful AI contribution should:

- Solve the requested problem
- Preserve project consistency
- Improve maintainability
- Respect existing decisions
- Minimize implementation cost
- Keep the project moving toward the MVP

---

# Final Principle

The best solution is not the most technically impressive.

The best solution is the one that delivers value, fits the current architecture, respects the product vision, and can be maintained with confidence over time.