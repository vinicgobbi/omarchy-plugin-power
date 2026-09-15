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

  readonly property var topActions: [
    { icon: "󰐥", label: "Shutdown", command: "omarchy-system-shutdown", destructive: true },
    { icon: "󰜉", label: "Reboot", command: "omarchy-system-reboot" },
    { icon: "󰍃", label: "Logout", command: "omarchy-system-logout" }
  ]
  readonly property var lockAction: { "icon": "󰌾", "label": "Lock", "command": "omarchy-system-lock" }

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
    contentWidth: panel.fittedContentWidth(Style.space(240))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Column {
        id: column
        width: parent.width
        spacing: Style.space(6)

        Row {
          id: topRow
          width: parent.width
          spacing: Style.space(6)

          Repeater {
            model: root.topActions

            CursorSurface {
              id: tile
              required property var modelData
              width: (topRow.width - topRow.spacing * (root.topActions.length - 1)) / root.topActions.length
              implicitHeight: Style.space(64)
              foreground: modelData.destructive ? root.urgent : root.foreground

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: tile.hasCursor = true
                onExited: tile.hasCursor = false
                onClicked: root.runAction(tile.modelData.command)
              }

              Column {
                anchors.centerIn: parent
                spacing: Style.space(6)

                Text {
                  text: tile.modelData.icon
                  color: tile.modelData.destructive ? root.urgent : root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.heading
                  anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                  text: tile.modelData.label
                  color: tile.modelData.destructive ? root.urgent : root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  anchors.horizontalCenter: parent.horizontalCenter
                }
              }
            }
          }
        }

        CursorSurface {
          id: lockSurface
          width: column.width
          implicitHeight: Style.space(40)
          foreground: root.foreground

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: lockSurface.hasCursor = true
            onExited: lockSurface.hasCursor = false
            onClicked: root.runAction(root.lockAction.command)
          }

          Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Style.space(10)
            anchors.rightMargin: Style.space(10)
            spacing: Style.space(10)

            Text {
              text: root.lockAction.icon
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              width: Style.space(20)
              horizontalAlignment: Text.AlignHCenter
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: root.lockAction.label
              color: root.foreground
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
