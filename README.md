# omarchy-plugin-power

Bar-widget plugin for [Omarchy](https://omarchy.org/) shell. Shows battery
status and reacts to clicks — starting point for a custom power widget.

## Development

Symlink this repo into your Omarchy plugins directory so edits hot-reload
without reinstalling:

```bash
ln -s "$(pwd)" ~/.config/omarchy/plugins/vinicgobbi.power
omarchy plugin enable vinicgobbi.power
```

Saving any file under `~/.config/omarchy/plugins/` reloads plugin code
automatically. If a change doesn't apply, force it with:

```bash
omarchy-shell shell rescanPlugins
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
- `BarWidget.qml` — the bar icon/label and its click behavior
