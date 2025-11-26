# Cursor Rules for This Repo

These are preferences and constraints for how AI assistants should behave inside this project.

1. **Do not add build artifacts** or derived files to the repo.
2. Respect the `.gitignore` — if you suggest generating new files, ensure they belong in source control.
3. When creating new Swift files:
   - Use clear, descriptive names.
   - Place them in a logical module/folder within `XcodeProject/`.
4. Avoid making arbitrary changes to project settings unless explicitly asked.
5. When you make large changes, include a brief summary and an example commit message.
6. Prefer incremental edits over massive rewrites unless explicitly requested.
7. If the user’s request conflicts with existing docs in `docs/`, flag the conflict and suggest a resolution.
