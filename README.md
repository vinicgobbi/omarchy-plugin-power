# omarchy-plugin-power

A power menu bar-widget for the [Omarchy](https://omarchy.org/) shell. Adds
a power icon to the bar; clicking it opens a popup with your user and host
info, every power action of the native Omarchy System menu, the power
profile picker, and the idle/sleep switches.

Every action calls the same native `omarchy-*` commands the built-in
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
- **Suspend**, **Hibernate**, **Screensaver** — same visibility rules as
  the native menu: Suspend is hidden when you turn it off below, and
  Hibernate only shows up when the system supports it
- **Power profile** — pick Power Saver, Balanced, or Performance
  (`omarchy-powerprofiles-set`, remembered per AC/battery like Omarchy does)
- **Stay Awake** — disable idle lock and screensaver (`omarchy-toggle-idle`)
- **Screensaver** — turn the idle screensaver on or off
  (`omarchy-toggle-screensaver`)
- **Suspend** — show or hide Suspend in this menu (`omarchy-toggle-suspend`)
- An info icon next to your username opens the native "About this
  system" window (`omarchy-launch-about`)

## Uninstall

```bash
omarchy plugin remove vinicgobbi.power
```

## Contributing

See [DEVELOPMENT.md](DEVELOPMENT.md) for local setup, the plugin's file
structure, and the commit/release process.

## License

[MIT](LICENSE)
