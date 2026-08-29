# Pocket

*Your menu bar, in your pocket.*

A single click that lists every app on your Mac with a menu bar icon — including
the ones that don't currently fit and are quietly out of view — and opens any of
them directly. No more hunting through a crowded bar for the one icon you need.

## Features

- **One-click access to every menu bar icon**, whether or not your Mac currently
  has room to display it. Pocket keeps a live list of every app with a menu bar
  icon and opens any of them directly, so nothing is ever truly out of reach.
- **Click again to close it** — the same click that opens the list closes it.
- **Global keyboard shortcut** to bring up the list from anywhere.
- **Auto-close** after clicking elsewhere, after an idle timeout, or when the
  frontmost app goes fullscreen — all optional, all in Settings.
- **Launch at login**, with a quick toggle in Settings.
- **Optional, opt-in update checks** — Pocket can check GitHub for a newer release
  and notify you. It never downloads or installs anything on its own; you always
  click through to grab it yourself.

## Installation

Download the latest `Pocket.dmg` from the [Releases page](https://github.com/Micropeptide/Pocket/releases),
open it, and drag Pocket into your Applications folder.

Pocket isn't notarized by Apple, so the first time you open it, right-click (or
Control-click) the app and choose **Open**, then confirm in the dialog that
appears. You only need to do this once.

Requires macOS 13 (Ventura) or later.

## Usage

Click Pocket's icon in the menu bar to see every app with a menu bar icon. Click
an entry to open it directly. Click Pocket's icon again (or click elsewhere) to
close the list.

The list needs Accessibility permission to see which apps own a menu bar icon;
Pocket will ask the first time you open it. Nothing else about Pocket requires
this permission.

### Settings

Right-click Pocket's icon (or click the gear in the icon list) to open Settings:
launch at login, auto-close behavior, the global shortcut, and update checks.

## Building from source

Pocket is a Swift Package with no external dependencies.

```bash
git clone https://github.com/Micropeptide/Pocket.git
cd Pocket
./Scripts/build-app.sh       # builds Pocket.app in the project root
open Pocket.app
```

To build a distributable disk image:

```bash
./Scripts/make-dmg.sh
```

## License

MIT — see [LICENSE](LICENSE).
