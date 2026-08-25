import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "gose.active-app"

  readonly property var toplevel: ToplevelManager.activeToplevel
  readonly property string appId: toplevel ? String(toplevel.appId || "") : ""
  readonly property string windowTitle: toplevel ? String(toplevel.title || "") : ""
  readonly property var desktopEntry: desktopEntryForAppId(appId)
  readonly property string appName: desktopEntry && desktopEntry.name
    ? String(desktopEntry.name)
    : fallbackAppName(appId)
  readonly property string iconName: desktopEntry && desktopEntry.icon
    ? String(desktopEntry.icon)
    : appId.toLowerCase()
  readonly property string iconSource: resolveIcon(iconName)
  readonly property real maxLabelWidth: {
    var value = Number(setting("maxWidth", 180))
    return isNaN(value) ? 180 : Math.max(80, value)
  }
  readonly property string tooltip: windowTitle && windowTitle !== appName
    ? appName + " — " + windowTitle
    : appName

  function normalizeId(value) {
    var id = String(value || "").toLowerCase()
    if (id.slice(-8) === ".desktop") id = id.slice(0, -8)
    return id
  }

  function desktopEntryForAppId(value) {
    var needle = normalizeId(value)
    if (!needle) return null

    var tail = needle.split(".").pop()
    var fallback = null
    var entries = DesktopEntries.applications.values || []

    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i]
      var id = normalizeId(entry && entry.id)
      var startupClass = normalizeId(entry && entry.startupClass)
      if (id === needle || startupClass === needle) return entry
      if (!fallback && id && (id === tail
          || id.slice(-(tail.length + 1)) === "." + tail
          || needle.slice(-(id.length + 1)) === "." + id))
        fallback = entry
    }

    return fallback
  }

  function fallbackAppName(value) {
    var id = normalizeId(value)
    var tail = id.split(".").pop().replace(/[-_]+/g, " ")
    var words = tail.split(" ")
    for (var i = 0; i < words.length; i++) {
      if (words[i]) words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1)
    }
    return words.join(" ")
  }

  function resolveIcon(value) {
    var icon = String(value || "")
    if (!icon) return Quickshell.iconPath("application-x-executable", true)
    if (icon.indexOf("file://") === 0 || icon.indexOf("image://") === 0) return icon
    if (icon.charAt(0) === "/") return Util.fileUrl(icon)
    return Quickshell.iconPath(icon, true)
  }

  visible: appId !== ""
  implicitWidth: visible ? (vertical ? barSize : content.implicitWidth + Style.space(16)) : 0
  implicitHeight: visible ? barSize : 0

  Behavior on implicitWidth {
    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
  }

  Row {
    id: content
    anchors.centerIn: parent
    spacing: Style.space(6)

    Image {
      id: appIcon
      anchors.verticalCenter: parent.verticalCenter
      width: Style.bar.iconCanvas
      height: Style.bar.iconCanvas
      fillMode: Image.PreserveAspectFit
      asynchronous: true
      sourceSize.width: Math.round(width * Screen.devicePixelRatio)
      sourceSize.height: Math.round(height * Screen.devicePixelRatio)
      source: root.iconSource
    }

    Item {
      id: labelClip
      anchors.verticalCenter: parent.verticalCenter
      visible: !root.vertical && root.appName !== ""
      width: Math.min(root.maxLabelWidth, labelText.implicitWidth)
      height: Math.max(appIcon.height, labelText.implicitHeight)
      clip: true

      Text {
        id: labelText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: labelClip.width
        text: root.appName
        color: root.bar ? root.bar.barForeground : Color.foreground
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
        font.weight: Font.DemiBold
        elide: Text.ElideRight
        opacity: 0.9
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    cursorShape: root.toplevel ? Qt.PointingHandCursor : Qt.ArrowCursor

    onClicked: if (root.toplevel) root.toplevel.activate()
    onEntered: if (root.bar) root.bar.showTooltip(root, root.tooltip)
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }
}
