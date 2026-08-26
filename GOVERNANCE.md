# Governance

## Model: Benevolent Dictator For Life (BDFL)

This project is currently maintained by a single person (Ahmad AL-Quraan),
who acts as the project's BDFL. This document explains what that means in
practice and how it would change if the project grows.

## Decision-Making

- **Final authority**: The maintainer has final say on all technical
  decisions, including architecture, dependencies, accepted contributions,
  and release timing.
- **Default assumption**: Issues and pull requests are reviewed and decided
  on by the maintainer directly — there is no voting body or steering
  committee at this stage.
- **Rationale over rules**: Decisions favor whatever keeps the project
  simple, buildable with `make`, and close to its original scope (a 42
  school project demonstrating Docker Compose orchestration). Scope
  creep is rejected by default unless it clearly improves the core
  learning/demo goal.

## How to Propose a Change

1. Open an issue describing the problem or idea before submitting a large
   pull request — this avoids wasted work if the direction doesn't fit.
2. Small fixes (typos, bug fixes, doc corrections) can go straight to a
   pull request.
3. The maintainer will respond, approve, request changes, or decline with
   a reason. There is no fixed SLA, since this is maintained outside of
   full-time work.

## Conflict Resolution

As a single-maintainer project, there is no dispute process beyond the
maintainer's judgment. Disagreements are handled by discussion in the
issue/PR thread; if unresolved, the maintainer's decision stands.

## Path to Shared Governance

If the project gains regular contributors, governance will evolve:

- Trusted, repeat contributors may be offered **maintainer** status
  (merge rights on non-controversial changes).
- Contested decisions would move to lazy consensus among maintainers
  (silence = approval after a reasonable window), with the original
  maintainer retaining tie-breaking authority.
- This document will be updated to reflect that structure if/when it
  happens — governance changes will themselves go through a pull request
  so the change is visible in history.

## Code of Conduct

All governance and contribution activity is subject to the project's
[Code of Conduct](./CODE_OF_CONDUCT.md). Enforcement of the Code of
Conduct is currently also the maintainer's responsibility.

## Contact

For governance questions, open an issue or contact the maintainer via the
email listed on the GitHub profile.
