import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Power menu popup. Mirrors the native Omarchy "System" menu (lock, suspend,
// hibernate, screensaver, logout, reboot, shutdown) and adds the power
// profile picker plus the Stay Awake / Screensaver / Suspend switches.
Panel {
  id: root
  moduleName: "vinicgobbi.power"
  ipcTarget: "vinicgobbi.power"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  property string detectedHostname: ""
  readonly property string username: Quickshell.env("USER") || Quickshell.env("LOGNAME") || "user"
  readonly property string hostname: Quickshell.env("HOSTNAME") || root.detectedHostname || Quickshell.env("HOST") || "host"

  FileView {
    path: "/etc/hostname"
    watchChanges: false
    printErrors: false
    onLoaded: root.detectedHostname = String(text() || "").trim()
  }

  property bool stayAwake: false
  property bool screensaverOff: false
  property bool suspendOff: false
  property bool hibernateAvailable: false
  property var profiles: []
  property string activeProfile: ""

  readonly property var topActions: [
    { icon: "󰐥", label: "Shutdown", command: "omarchy-system-shutdown", destructive: true },
    { icon: "󰜉", label: "Reboot", command: "omarchy-system-reboot" },
    { icon: "󰍃", label: "Logout", command: "omarchy-system-logout" }
  ]
  readonly property var lockAction: { "icon": "󰌾", "label": "Lock", "command": "omarchy-system-lock" }

  // Same visibility rules as the native menu: Suspend hides when the
  // suspend-off toggle is set, Hibernate only when the system supports it.
  readonly property var sleepActions: {
    var list = []
    if (!root.suspendOff) list.push({ icon: "󰒲", label: "Suspend", command: "systemctl suspend" })
    if (root.hibernateAvailable) list.push({ icon: "󰤁", label: "Hibernate", command: "systemctl hibernate" })
    list.push({ icon: "󱄄", label: "Screensaver", command: "omarchy-launch-screensaver force" })
    return list
  }

  readonly property string stateScript: [
    "flag() { \"$@\" >/dev/null 2>&1 && echo 1 || echo 0; }",
    "printf 'stayAwake\\t%s\\n' \"$(omarchy-toggle-idle status | jq -r 'if .enabled then 1 else 0 end')\"",
    "printf 'screensaverOff\\t%s\\n' \"$(flag omarchy-toggle-enabled screensaver-off)\"",
    "printf 'suspendOff\\t%s\\n' \"$(flag omarchy-toggle-enabled suspend-off)\"",
    "printf 'hibernate\\t%s\\n' \"$(flag omarchy-hibernation-available)\""
  ].join("\n")

  function runAction(command) {
    if (root.bar && typeof root.bar.run === "function") root.bar.run(command)
    root.close()
  }

  function refresh() {
    if (!stateProc.running) stateProc.running = true
    if (!profilesProc.running) profilesProc.running = true
  }

  function parseState(raw) {
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var parts = lines[i].split("\t")
      if (parts.length < 2) continue
      var on = parts[1].trim() === "1"
      if (parts[0] === "stayAwake") root.stayAwake = on
      else if (parts[0] === "screensaverOff") root.screensaverOff = on
      else if (parts[0] === "suspendOff") root.suspendOff = on
      else if (parts[0] === "hibernate") root.hibernateAvailable = on
    }
  }

  function parseProfiles(raw) {
    var list = []
    var active = ""
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (!line) continue
      var parts = line.split("\t")
      list.push(parts[0])
      if (parts[1] === "1") active = parts[0]
    }
    if (list.length === 0) return
    root.profiles = list
    root.activeProfile = active
  }

  function profileIcon(name) {
    if (name === "power-saver") return "󰌪"
    if (name === "balanced") return "󰊚"
    if (name === "performance") return "󰓅"
    return "󰊚"
  }

  function profileLabel(name) {
    var words = String(name).split("-")
    for (var i = 0; i < words.length; i++) words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1)
    return words.join(" ")
  }

  // Argv arrays only (no shell): the profile name comes from the system's
  // own list and is passed as a single argument.
  function runCommand(argv) {
    if (actionProc.running) return false
    actionProc.command = argv
    actionProc.running = true
    return true
  }

  function toggleSwitch(prop, argv) {
    if (actionProc.running) return
    root[prop] = !root[prop]
    runCommand(argv)
  }

  function setProfile(profile) {
    if (!profile || actionProc.running) return
    root.activeProfile = profile
    runCommand(["omarchy-powerprofiles-set", "autodetect", profile])
  }

  onOpenedChanged: if (opened) refresh()
  Component.onCompleted: refresh()

  Process {
    id: stateProc
    command: ["bash", "-c", root.stateScript]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.parseState(text) }
  }

  Process {
    id: profilesProc
    command: ["omarchy-powerprofiles-list", "--active-state"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.parseProfiles(text) }
  }

  Process {
    id: actionProc
    onExited: root.refresh()
  }

  Timer { interval: 5000; running: root.opened; repeat: true; onTriggered: root.refresh() }

  implicitWidth: 1
  implicitHeight: 1

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(280))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Flickable {
        id: panelFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height

        Column {
          id: column
          width: panelFlick.width
          spacing: Style.space(6)

          Item {
            width: parent.width
            height: Math.max(userColumn.implicitHeight, aboutButton.implicitHeight)

            Column {
              id: userColumn
              anchors.left: parent.left
              anchors.right: aboutButton.left
              anchors.rightMargin: Style.space(8)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)

              Text {
                text: root.username
                color: Color.accent
                font.family: root.fontFamily
                font.pixelSize: Style.font.heading
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
              }

              Text {
                text: root.hostname
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                elide: Text.ElideRight
                width: parent.width
              }
            }

            PanelActionButton {
              id: aboutButton
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              size: Style.space(32)
              fontSize: Style.font.heading
              iconText: ""
              tooltipText: "About this system"
              foreground: root.foreground
              onClicked: root.runAction("omarchy-launch-about")
            }
          }

          PanelSeparator {
            foreground: root.foreground
          }

          TileRow { actions: root.topActions }

          CursorSurface {
            id: lockSurface
            width: column.width
            implicitHeight: Style.space(40)
            foreground: root.foreground
            bordered: true

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

          TileRow { actions: root.sleepActions }

          PanelSeparator {
            foreground: root.foreground
            visible: root.profiles.length > 0
          }

          Column {
            visible: root.profiles.length > 0
            width: parent.width
            spacing: Style.space(10)

            PanelSectionHeader {
              text: "POWER PROFILE"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Row {
              id: profileRow
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: root.profiles

                Button {
                  required property var modelData
                  width: (profileRow.width - profileRow.spacing * (root.profiles.length - 1)) / root.profiles.length
                  iconText: root.profileIcon(String(modelData))
                  iconSize: Style.font.title
                  text: root.profileLabel(String(modelData))
                  fontSize: Style.font.bodySmall
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  horizontalPadding: Style.spacing.controlPaddingX
                  verticalPadding: Style.spacing.controlPaddingY + Style.space(2)
                  bordered: true
                  active: root.activeProfile === modelData
                  onClicked: root.setProfile(String(modelData))
                }
              }
            }
          }

          PanelSeparator {
            foreground: root.foreground
          }

          Column {
            width: parent.width
            spacing: Style.space(6)

            SwitchRow {
              label: "Stay Awake"
              description: "Disable idle lock and screensaver"
              checked: root.stayAwake
              onToggled: root.toggleSwitch("stayAwake", ["omarchy-toggle-idle"])
            }

            SwitchRow {
              label: "Screensaver"
              description: "Start the screensaver when idle"
              checked: !root.screensaverOff
              onToggled: root.toggleSwitch("screensaverOff", ["omarchy-toggle-screensaver"])
            }

            SwitchRow {
              label: "Suspend"
              description: "Show Suspend in this menu"
              checked: !root.suspendOff
              onToggled: root.toggleSwitch("suspendOff", ["omarchy-toggle-suspend"])
            }
          }
        }
      }
    }
  }

  component ActionTile: CursorSurface {
    id: tile
    property var action: ({})

    implicitHeight: Style.space(64)
    foreground: action.destructive ? root.urgent : root.foreground
    bordered: true

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: tile.hasCursor = true
      onExited: tile.hasCursor = false
      onClicked: root.runAction(tile.action.command)
    }

    Column {
      anchors.centerIn: parent
      spacing: Style.space(6)

      Text {
        text: tile.action.icon
        color: tile.action.destructive ? root.urgent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.heading
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        text: tile.action.label
        color: tile.action.destructive ? root.urgent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }
  }

  component TileRow: Row {
    id: tileRow
    property var actions: []

    width: parent.width
    spacing: Style.space(6)
    visible: actions.length > 0

    Repeater {
      model: tileRow.actions

      ActionTile {
        required property var modelData
        action: modelData
        width: (tileRow.width - tileRow.spacing * (tileRow.actions.length - 1)) / tileRow.actions.length
      }
    }
  }

  component SwitchRow: CursorSurface {
    id: switchRow
    property string label: ""
    property string description: ""
    property bool checked: false
    signal toggled()

    width: parent.width
    implicitHeight: Style.space(48)
    foreground: root.foreground
    bordered: true

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: switchRow.hasCursor = true
      onExited: switchRow.hasCursor = false
      onClicked: switchRow.toggled()
    }

    Column {
      anchors.left: parent.left
      anchors.right: knob.left
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(1)

      Text {
        text: switchRow.label
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
        width: parent.width
      }

      Text {
        visible: switchRow.description !== ""
        text: switchRow.description
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
        width: parent.width
      }
    }

    ToggleSwitch {
      id: knob
      anchors.right: parent.right
      anchors.rightMargin: Style.space(6)
      anchors.verticalCenter: parent.verticalCenter
      checked: switchRow.checked
      interactive: false
      foreground: root.foreground
    }
  }
}
