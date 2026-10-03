## v0.2.0 (2026-10-03)

### Feat

- add optional confirmation for shutdown, reboot and logout

## v0.1.1 (2026-10-03)

### Fix

- força textFormat: Text.PlainText em username/hostname (defesa em profundidade)
- declara license e homepage no manifest, igual aos outros plugins
- disable qmllint's alias category too

## v0.1.0 (2026-09-21)

### Feat

- add suspend, hibernate, screensaver, power profiles and idle toggles
- add preview image for plugin
- add Commitizen config and automated release workflow

### Fix

- lay out power profiles as tiles and shorten switch descriptions
- rename toggle helper so it stops shadowing Panel.toggle
- rename display name to Power Menu
- revert second accidental v0.2.0 bump
- revert accidental v0.2.0 bump, real first release is 0.1.0

### Refactor

- remove the Suspend visibility switch
- remove the power profile picker
