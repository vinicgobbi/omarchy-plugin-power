import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Ui

// Minimal bar-widget starter: shows the battery icon/percentage and reacts
// to a left click. Replace the body of onPressed and the icon/text logic
// with whatever this plugin is meant to do.
BarWidget {
  id: root
  moduleName: "vinicgobbi.power"

  readonly property var device: UPower.displayDevice
  readonly property bool present: !!(device && device.isPresent)
  readonly property int percentage: present ? Math.round(device.percentage * 100) : 0
  readonly property bool charging: present && device.state === UPowerDeviceState.Charging

  visible: present
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function batteryIcon() {
    if (charging) return "󰂄"
    if (percentage >= 90) return "󰁹"
    if (percentage >= 60) return "󰂀"
    if (percentage >= 30) return "󰁾"
    if (percentage >= 10) return "󰁻"
    return "󰁺"
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.batteryIcon()
    tooltipText: root.percentage + "% battery"

    onPressed: function(b) {
      // TODO: hook up whatever this widget should do on click.
    }
  }
}
