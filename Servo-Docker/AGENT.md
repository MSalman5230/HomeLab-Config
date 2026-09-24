# Agent Instructions

When creating a new Docker stack in this project:

1. Always create a new folder for each new stack.
2. Create a `compose.yaml` file for the service inside that folder.
3. Create a `README.md` file in the same folder.
4. In `README.md`, document environment variables in two sections:
   - **Required environment variables**
   - **Optional environment variables** (include defaults when available)
5. Any persistent volume path must use this base pattern:
   - `/mnt/user/appdata/<stack-name>`

This is the standard format to keep each stack easy to use and consistent.
