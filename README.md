# Xcode + Cursor + GitHub Starter

This repo is a **starter template** for Xcode projects that you want to:

- Build in **Xcode**
- Edit/drive with **Cursor**
- Version with **Git + GitHub**

You will drop your actual `.xcodeproj` / `.xcworkspace` into the `XcodeProject/` folder and let Cursor handle the rest.

---

## 1. Getting Started

1. Clone or unzip this project somewhere on disk.
2. Open Xcode and create your project:
   - **File → New → Project…**
   - Choose your template (iOS App, macOS App, etc.)
   - When Xcode asks where to save, choose this folder and save it **inside `XcodeProject/`**.
3. Confirm that the `.xcodeproj` or `.xcworkspace` is now in:

   ```text
   XcodeProject/YourApp.xcodeproj
   ```

4. In a terminal, from the repo root, run:

   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

5. Create a GitHub repo and add it as `origin`:

   ```bash
   git remote add origin https://github.com/YOURNAME/YOUR_REPO.git
   git branch -M main
   git push -u origin main
   ```

---

## 2. Using This Repo in Cursor

1. In Cursor, go to **File → Open Folder…**
2. Open the **root folder** of this starter (the same folder that contains `.git/` and this `README.md`).
3. You should now see:
   - The **Git branch** indicator in the status bar.
   - Source-control actions (commit, push, pull) in the Git panel.
   - All docs in `docs/` as context Cursor can use for instructions.

Cursor is now looking at the **same repo** that Xcode is using.

---

## 3. Day‑to‑Day Workflow

A clean, repeatable loop:

1. **Pull** latest from GitHub (Terminal or Cursor).
2. **Code** in Xcode and/or Cursor.
3. Use Cursor for:
   - Refactors
   - Docs
   - Code generation
   - Reviews
4. **Run/Debug** in Xcode as usual (simulator/devices).
5. **Commit + Push** from either:
   - Cursor Git panel, or
   - Terminal in repo root:

   ```bash
   git status
   git add .
   git commit -m "Describe the change"
   git push
   ```

As long as Xcode and Cursor are pointed at the same folder, everything stays in sync.

---

## 4. Files & Folders

```text
.
├─ .gitignore             # Xcode‑aware ignores
├─ README.md              # This file
├─ docs/
│  ├─ CURSOR_CONTEXT.md   # High‑level context for Cursor
│  └─ WORKFLOW.md         # Detailed workflow & best practices
├─ .cursor/
│  └─ rules.md            # Instructions and preferences for Cursor
└─ XcodeProject/
   └─ (your .xcodeproj / .xcworkspace goes here)
```

You can add more docs into `docs/` (architecture, API notes, feature specs, etc.). Cursor will use these as context when you ask it to implement or update features.

---

## 5. Recommended Git Practices

- Keep commits **small and focused**.
- Use descriptive commit messages, e.g.:
  - `feat: add login screen`
  - `fix: resolve layout issue on iPhone SE`
  - `chore: update .gitignore`
- Never commit build products or derived data (the `.gitignore` here is tuned to avoid that).
- Use branches for features:

  ```bash
  git checkout -b feature/login-screen
  # work...
  git push -u origin feature/login-screen
  ```

Then open a PR on GitHub.

---

## 6. Where to Put Things

- **App code**: wherever Xcode puts it inside `XcodeProject/`.
- **Design notes / specs**: put Markdown files in `docs/`.
- **Cursor instructions**: adjust `.cursor/rules.md` and `docs/CURSOR_CONTEXT.md`.

---

## 7. Next Steps

Once your Xcode app lives in `XcodeProject/` and the repo is on GitHub, you’re ready to:

- Invite Cursor to:
  - Build screens
  - Wire view models
  - Integrate APIs
  - Refactor legacy Swift/Obj‑C
- Use GitHub as the source of truth for everything.

If you want a more opinionated structure (e.g. SwiftUI + Clean Architecture + networking, etc.), you can layer that on top of this starter.
