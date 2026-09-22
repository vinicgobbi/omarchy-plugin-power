# Contributing

## Local setup

Symlink this repo into your Omarchy plugins directory so edits hot-reload
without reinstalling:

```bash
ln -s "$(pwd)" ~/.config/omarchy/plugins/vinicgobbi.power
omarchy plugin enable vinicgobbi.power
```

Saving `BarWidget.qml` (the plugin's entry point) hot-reloads on its own.
`Panel.qml` is loaded dynamically through a `Loader`, and the shell's QML
engine caches that compiled component by file path — editing it alone
does **not** hot-reload, even though the shell logs "Local plugin
changed, reloading". If the popup doesn't reflect a `Panel.qml` change,
fully restart the shell instead:

```bash
omarchy restart shell
```

Validate the manifest before publishing:

```bash
omarchy plugin validate .
```

## Structure

- `manifest.json` — plugin metadata (id, kind, entry point)
- `BarWidget.qml` — the bar icon and popup open/close plumbing
- `Panel.qml` — the popup itself: user/host header with an About-system
  button, action tiles (Shutdown/Reboot/Logout, Lock, Suspend/Hibernate/
  Screensaver) running the matching native commands, and the Stay Awake/
  Screensaver switches. State (toggles, hibernation support) is
  read from the `omarchy-*` CLI
  when the popup opens and every 5 seconds while it's open.

## CI

`.github/workflows/ci.yml` runs on every push to `main` (and on pull
requests) and validates `manifest.json` and every `.qml` file with
`qmllint`, so a syntax error can't land on `main`.

## Commits and releases

Commits follow [Conventional Commits](https://www.conventionalcommits.org/)
and are checked with [Commitizen](https://commitizen-tools.github.io/commitizen/):

```bash
pipx install commitizen
cz commit   # interactive, conventional-commits-compliant commit
```

Releases are manual: run `.github/workflows/release.yml` from the
Actions tab (`Run workflow`, on `main`). It only runs when dispatched
against `main`, and uses Commitizen to bump `manifest.json`'s version
and the changelog based on the commit types since the last release,
tags it (`vX.Y.Z`), and publishes a GitHub Release with the changelog
entry. If there's nothing to bump (no `feat`/`fix`/`BREAKING CHANGE`
commits since the last release), it's a no-op — no tag, no release.
