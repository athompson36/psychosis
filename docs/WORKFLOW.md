# Xcode + Cursor Workflow

This doc describes the recommended workflow for working on this project with **Xcode**, **Cursor**, and **GitHub**.

---

## 1. Open the Project

- In **Xcode**: open the `.xcodeproj` or `.xcworkspace` located in `XcodeProject/`.
- In **Cursor**: open the **repo root folder** (the folder with `.git/`, `.gitignore`, and `README.md`).

This ensures both tools are working on the exact same files.

---

## 2. Sync with GitHub

Before starting work:

```bash
git pull
```

Resolve any conflicts if necessary. Keep your local copy in sync with the remote branch.

---

## 3. Implement Changes

Use this split of responsibilities:

- **Xcode**: running, profiling, debugging on simulators/devices, Interface Builder, SwiftUI previews, signing, provisioning.
- **Cursor**: generating code, refactoring, documentation, small fixes, tests, and glue code.

Example flow:

1. Write or tweak UI / logic in Xcode or Cursor.
2. Ask Cursor to:
   - Fix compiler errors
   - Extract helper types
   - Add unit tests
3. Run/build in Xcode to verify.

---

## 4. Review and Commit

1. Check the status:

   ```bash
   git status
   ```

2. Stage changes:

   ```bash
   git add path/to/changed/files
   ```

   or all:
   ```bash
   git add .
   ```

3. Commit with a descriptive message:

   ```bash
   git commit -m "feat: add settings screen"
   ```

4. Push to GitHub:

   ```bash
   git push
   ```

You may also use Cursor’s Git integration for staging/committing/pushing.

---

## 5. Branching Model (Suggested)

Use short‑lived feature branches:

```bash
git checkout -b feature/short-description
# work...
git push -u origin feature/short-description
```

Open PRs on GitHub for review/merge.

---

## 6. Using Cursor Effectively

- Point Cursor at specific files/regions when asking for refactors.
- Provide context: mention which screen/feature you’re working on.
- Reference docs in `docs/` in your prompts when relevant.

Examples:

- “Update the login view in `LoginView.swift` to support password reset, following the design described in `docs/authentication.md`.”
- “Refactor the networking layer to use async/await while keeping existing API signatures.”

---

## 7. Updating the Template for Your Project

Once your real app is in place, you can:

- Expand this `WORKFLOW.md` with project‑specific steps.
- Add more docs under `docs/` (e.g. `ARCHITECTURE.md`, `API.md`, `DESIGN_SYSTEM.md`).

Cursor will use those as authoritative references when making changes.
