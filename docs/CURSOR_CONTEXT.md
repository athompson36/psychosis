# Cursor Context: Xcode + GitHub Starter

This repository is a **template** for an Xcode project managed with **Git** and edited using **Cursor**.

The owner’s goals:

- Use Xcode as the primary **build & run** environment.
- Use Cursor as a **coding partner** for:
  - Implementing features
  - Refactoring
  - Fixing compiler errors
  - Writing tests
  - Maintaining docs
- Keep everything versioned and synced on **GitHub**.

The actual Xcode project (.xcodeproj / .xcworkspace) will live inside `XcodeProject/`.

## Project Structure

- `XcodeProject/`  
  Contains the Xcode project. The user will create/import their project here.

- `docs/`  
  Contains Markdown docs that describe architecture, workflows, and high‑level goals. You should read from here first when making major structural changes.

- `.cursor/rules.md`  
  Contains specific instructions on how Cursor should behave in this repo.

- `.gitignore`  
  Configured for Xcode / macOS development. Do **not** remove the DerivedData/build ignores.

## How You (Cursor) Should Work in This Repo

1. **Never assume** where the app code lives. First, scan `XcodeProject/` to discover the actual modules/targets.
2. Prefer writing and modifying **Swift/Objective‑C** code exactly where Xcode expects it, respecting the existing folder/group structure.
3. When adding new files:
   - Place them in a logical folder in `XcodeProject/` (or whatever convention already exists).
   - Mention to the user if Xcode project file updates might be required (e.g., adding a new target or changing build settings).
4. Use the docs in `docs/` as the **source of truth** for:
   - Architecture
   - Naming conventions
   - Design patterns

If something is unclear, propose a sensible default and explain your reasoning.

## Coding Style Preferences (Initial Defaults)

These can be customized later, but default to:

- SwiftUI for new UI, unless the existing project is UIKit/AppKit‑only.
- Modern Swift (5.9+), avoiding deprecated APIs.
- Keep functions small and focused.
- Use clear, descriptive naming.
- Prefer composition over inheritance.

## Git Expectations

- Keep changes scoped so they make sense as a single commit.
- When generating large changes, optionally propose a commit message and a summary of what changed.
- Do **not** introduce large generated files or binary blobs into the repo.

---

This context file can be expanded later to include specific modules (e.g. “Authentication”, “Settings”, “Audio Engine”, etc.).
