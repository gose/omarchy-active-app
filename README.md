# Active App

An Omarchy bar widget that shows the focused application's icon and desktop
application name, inspired by the active-application label in the macOS menu
bar. Long names are truncated, vertical bars show only the icon, and clicking
the widget activates the focused application.

## Install

```sh
omarchy plugin add https://github.com/gose/omarchy-active-app --enable
omarchy plugin disable omarchy.active-window
```

The second command removes Omarchy's focused-window-title widget so Active App
can occupy that role without displaying duplicate labels.

## Remove

```sh
omarchy plugin disable gose.active-app
omarchy plugin remove gose.active-app
omarchy plugin enable omarchy.active-window --section left
```

## Develop

Validate the manifest and QML against an installed Omarchy shell:

```sh
scripts/check
```

## Attribution

Active App began as a user-owned clone of Omarchy's `omarchy.active-window`
widget. Its upstream license and the source version are preserved in this
repository.

## License

Active App is available under the [MIT License](LICENSE). Work derived from
Omarchy retains its upstream copyright and license in
[`LICENSE.upstream`](LICENSE.upstream).
