# Packaging

Content Manager installs archives by copying paths from the archive root into the Assetto Corsa root folder.

For Flying Start, the archive root must contain:

```text
apps/lua/FlyingStart/FlyingStart.lua
apps/lua/FlyingStart/manifest.ini
apps/lua/FlyingStart/src/...
```

Do not package only the inner `FlyingStart` folder. If the archive root starts with `FlyingStart/`, Content Manager will not install it into `apps/lua` correctly.

Build release zip:

```bash
tools/package-release.sh
```

Output:

```text
dist/FlyingStart_v1.6_CM.zip
```

Use that zip for drag-and-drop installs in Content Manager and for GitHub releases.
