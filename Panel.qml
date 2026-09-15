import QtQuick
import qs.Commons
import qs.Ui

// Power menu popup: lock, logout, reboot, shutdown. Each row shells out to
// the matching omarchy-system-* command and closes the popup.
Panel {
  id: root
  moduleName: "vinicgobbi.power"
  ipcTarget: "vinicgobbi.power"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  readonly property var actions: [
    { icon: "󰌾", label: "Lock", command: "omarchy-system-lock" },
    { icon: "󰍃", label: "Logout", command: "omarchy-system-logout" },
    { icon: "󰜉", label: "Reboot", command: "omarchy-system-reboot" },
    { icon: "󰐥", label: "Shutdown", command: "omarchy-system-shutdown", destructive: true }
  ]

  function runAction(command) {
    if (root.bar && typeof root.bar.run === "function") root.bar.run(command)
    root.close()
  }

  implicitWidth: 1
  implicitHeight: 1

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(200))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Column {
        id: column
        width: parent.width
        spacing: Style.space(4)

        Repeater {
          model: root.actions

          CursorSurface {
            id: surface
            required property var modelData
            width: column.width
            implicitHeight: Style.space(40)
            foreground: modelData.destructive ? root.urgent : root.foreground

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onEntered: surface.hasCursor = true
              onExited: surface.hasCursor = false
              onClicked: root.runAction(surface.modelData.command)
            }

            Row {
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              anchors.leftMargin: Style.space(10)
              anchors.rightMargin: Style.space(10)
              spacing: Style.space(10)

              Text {
                text: surface.modelData.icon
                color: surface.modelData.destructive ? root.urgent : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                width: Style.space(20)
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: surface.modelData.label
                color: surface.modelData.destructive ? root.urgent : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                anchors.verticalCenter: parent.verticalCenter
              }
            }
          }
        }
      }
    }
  }
}
