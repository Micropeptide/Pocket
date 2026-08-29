# Pocket

*Your menu bar, in your pocket.*

A menu bar organizer for Mac: sort your icons into "always visible" and "hidden"
groups, then reach any of them — hidden or not — from one click, without ever
losing Pocket's own icon in the clutter.

## Features

- **One-click access to every menu bar icon**, including ones your Mac has tucked
  away — Pocket keeps a live list of every app with a menu bar icon and opens any
  of them directly, so nothing is ever truly out of reach.
- **Sort icons with a familiar gesture** — hold ⌘ and drag any icon left or right
  of Pocket's arrow to mark it hidden or always-visible.
- **Pocket's own icon stays put.** It launches early (as a login item) and is
  never part of its own hidden group, so the control that manages your menu bar
  doesn't disappear into it.
- **Global keyboard shortcut** to bring up the icon list from anywhere.
- **Auto-hide** after clicking elsewhere, after an idle timeout, or when the
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

Click Pocket's icon in the menu bar to see every app with a menu bar icon, sorted
into **Hidden** and **Always Visible**. Click an entry to open it directly.

To move an icon between groups, hold **⌘** and drag it left or right of Pocket's
arrow icon in the menu bar — the same gesture macOS already uses for rearranging
menu bar icons.

The icon list needs Accessibility permission to see which apps own a menu bar
icon; Pocket will ask the first time you open it. Nothing else about Pocket
requires this permission.

### Settings

Right-click Pocket's icon (or click the gear in the icon list) to open Settings:
launch at login, auto-hide behavior, the global shortcut, and update checks.

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
