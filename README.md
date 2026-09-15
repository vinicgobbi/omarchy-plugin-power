# omarchy-plugin-power

Bar-widget plugin for [Omarchy](https://omarchy.org/) shell. Adds a power
icon to the bar that opens a popup with Lock, Logout, Reboot, and Shutdown.

## Development

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

## Install (once published)

```bash
omarchy plugin add <git-url> --enable
```

## Structure

- `manifest.json` — plugin metadata (id, kind, entry point)
- `BarWidget.qml` — the bar icon and popup open/close plumbing
- `Panel.qml` — the popup itself: Lock, Logout, Reboot, Shutdown rows,
  each running the matching `omarchy-system-*` command
