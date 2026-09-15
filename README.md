# omarchy-plugin-power

A power menu bar-widget for the [Omarchy](https://omarchy.org/) shell. Adds
a power icon to the bar; clicking it opens a popup with your user and host
info and buttons for Shutdown, Reboot, Logout, and Lock.

Every action calls the same native `omarchy-system-*` commands the built-in
Omarchy menu uses, so you get the same confirmation OSDs and behavior.

## Install

```bash
omarchy plugin add https://github.com/vinicgobbi/omarchy-plugin-power.git --enable
```

When enabling, pick which bar section (left/center/right) you want the
power icon in.

## Usage

Click the power icon in the bar to open the menu:

- **Shutdown**, **Reboot**, **Logout** — side by side at the top
- **Lock** — full-width button below them
- An info icon next to your username opens the native "About this
  system" window (`omarchy-launch-about`)

## Uninstall

```bash
omarchy plugin remove vinicgobbi.power
```

## Contributing

See [DEVELOPMENT.md](DEVELOPMENT.md) for local setup, the plugin's file
structure, and the commit/release process.
