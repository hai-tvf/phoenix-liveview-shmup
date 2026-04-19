<!--
Sync Impact Report
- Version change: (template) → 1.0.0
- Modified principles: N/A (initial adoption; placeholders replaced)
- Added sections: Stack & Runtime; Development Workflow
- Removed sections: N/A
- Templates requiring updates:
  - .specify/templates/plan-template.md — Constitution Check (✅ updated)
  - .specify/templates/spec-template.md — (✅ reviewed; no mandatory section changes)
  - .specify/templates/tasks-template.md — (✅ reviewed; path examples remain generic)
  - .specify/extensions/git/commands/*.md — (✅ reviewed; agent-agnostic)
- Follow-up TODOs: none
-->

# Phoenix LiveView Shmup Constitution

## Core Principles

### I. LiveView-native game surface

The vertical-scrolling shooter MUST run as a Phoenix LiveView application: game state
evolves on the server, and the browser receives updates through LiveView. The plan MUST
document the tick or event model (for example `handle_info` with `:timer` or periodic
`send_update`), the authoritative copy of state, and how player input reaches the server.
Rationale: keeps one source of truth, fits OTP, and avoids duplicating game logic in
untestable client-only scripts.

### II. Pure game core, LiveView at the edge

Collision detection, movement, spawning, scoring, and win/lose rules MUST live in plain
Elixir modules with no direct dependency on `Phoenix.LiveView` or socket structs.
LiveView modules MUST only translate events, schedule ticks, and assign data for
templates. Rationale: game rules stay fast to test and refactor; UI remains a thin
adapter.

### III. Test-first rules, targeted LiveView tests

New or changed game rules MUST follow red–green–refactor with ExUnit tests against the
pure modules before integration. LiveView tests MUST cover critical paths (start,
movement, fire, game over) at least at a smoke level. Rationale: regressions in math and
collisions are the main risk in a shmup; LiveView tests catch wiring mistakes.

### IV. Performance and update budget

The plan MUST state a target server update cadence (for example 10–60 Hz) and how assigns,
streams, or minimal templates keep each render small enough for smooth play. Features
that increase payload or DOM size MUST justify the cost. Rationale: LiveView games are
latency- and diff-sensitive; explicit budgets prevent jank.

### V. Incremental delivery and simplicity

Ship a minimal vertical slice (player, bullets, enemies, score, restart) before advanced
patterns (power-ups, bosses, multiplayer). Dependencies and architecture MUST stay as
simple as the current scope requires (YAGNI). Rationale: a shmup grows complex quickly;
discipline keeps the codebase maintainable.

## Stack & Runtime

- **Language**: Elixir (current project version).
- **Web**: Phoenix with LiveView; HTML/CSS for the playfield unless a spec explicitly
  requires Canvas/WebGL hooks.
- **Assets**: Follow the Phoenix toolchain (typically esbuild); add LiveView JS hooks
  only when the specification requires client-side behavior that cannot be expressed with
  server-driven updates.
- **Persistence**: Not required for core loop unless the feature spec demands
  leaderboards or accounts; prefer in-memory or ETS for session game state unless
  otherwise specified.

## Development Workflow

- Use Spec Kit artifacts (`spec.md`, `plan.md`, `tasks.md`) for non-trivial features;
  keep them aligned with this constitution.
- Work on dedicated feature branches; integrate through review when more than one
  contributor is active.
- Before merging substantial gameplay changes, verify ExUnit coverage for touched pure
  modules and that LiveView smoke paths still pass.

## Governance

This constitution supersedes informal conventions when they conflict. Amendments MUST
update `.specify/memory/constitution.md`, bump **CONSTITUTION_VERSION** per semantic
versioning (MAJOR: incompatible governance or removed principles; MINOR: new principles or
material new guidance; PATCH: clarifications and non-semantic edits), and refresh
dependent templates when gates or mandatory practices change. Feature plans MUST include
a Constitution Check that references the current principles. Compliance SHOULD be
reviewed during implementation planning and before release of major gameplay milestones.

**Version**: 1.0.0 | **Ratified**: 2026-04-19 | **Last Amended**: 2026-04-19
