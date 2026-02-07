// SPDX-FileCopyrightText: 2024 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Window
import org.deepin.dtk 1.0 as D
import org.deepin.dtk.style 1.0 as DS

D.LineEdit {
    id: edit
    property alias editBtn: editButton
    property alias alertText: panel.alertText
    property alias showAlert: panel.showAlert
    property alias metrics: fontMetrics
    property var completeText: ""
    signal finished()

    // Refresh alert tip position after geometry changes.
    property bool _refreshingAlert: false
    property int _refreshSeq: 0

    function scheduleAlertRefresh(delayMs) {
        if (!showAlert)
            return

        refreshAlertTimer.interval = (delayMs === undefined) ? 0 : delayMs
        refreshAlertTimer.restart()
    }

    function refreshAlertPosition() {
        if (!showAlert || _refreshingAlert)
            return

        _refreshingAlert = true
        const seq = ++_refreshSeq

        panel.control = refreshControlPlaceholder
        Qt.callLater(function () {
            if (seq !== _refreshSeq)
                return
            panel.control = edit
            _refreshingAlert = false
        })
    }

    readOnly: true
    horizontalAlignment: TextInput.AlignLeft
    verticalAlignment: TextInput.AlignVCenter
    topPadding: 4
    bottomPadding: 4
    clearButton.visible: !readOnly
    rightPadding: clearButton.width + clearButton.anchors.rightMargin
    implicitHeight: 36
    background: D.EditPanel {
        id: panel
        control: edit
        showBorder: !readOnly
        alertDuration: 3000
        implicitWidth: DS.Style.edit.width
        implicitHeight: 32
        anchors {
            fill: parent
            topMargin: 3
            bottomMargin: 3
        }
        backgroundColor: D.Palette {
            normal: Qt.rgba(1, 1, 1, 0)
            normalDark: Qt.rgba(1, 1, 1, 0)
        }
    }

    Item {
        id: refreshControlPlaceholder
        visible: false
        width: 0
        height: 0
    }

    Timer {
        id: refreshAlertTimer
        interval: 0
        repeat: false
        onTriggered: edit.refreshAlertPosition()
    }

    onShowAlertChanged: {
        if (showAlert && !edit.activeFocus) {
            scheduleAlertRefresh(0)
        }
    }

    Connections {
        target: edit.Window.window
        function onWidthChanged() { edit.scheduleAlertRefresh(0) }
        function onHeightChanged() { edit.scheduleAlertRefresh(0) }
    }

    onEditingFinished: {
        if (edit.readOnly)
            return
        if (showAlert)
            showAlert = false

        finished()
    }

    FontMetrics {
        id: fontMetrics
        font: edit.font
    }

    D.ActionButton {
        id: editButton
        focusPolicy: Qt.StrongFocus
        width: 30
        height: 30
        icon.name: "dcc-edit"
        icon.width: DS.Style.edit.actionIconSize
        icon.height: DS.Style.edit.actionIconSize
        hoverEnabled: true
        background: Rectangle {
            anchors.fill: parent
            property D.Palette pressedColor: D.Palette {
                normal: Qt.rgba(0, 0, 0, 0.2)
                normalDark: Qt.rgba(1, 1, 1, 0.25)
            }
            property D.Palette hoveredColor: D.Palette {
                normal: Qt.rgba(0, 0, 0, 0.1)
                normalDark: Qt.rgba(1, 1, 1, 0.1)
            }
            radius: DS.Style.control.radius
            color: parent.pressed ? D.ColorSelector.pressedColor : (parent.hovered ? D.ColorSelector.hoveredColor : "transparent")
            border {
                color: parent.palette.highlight
                width: parent.visualFocus ? DS.Style.control.focusBorderWidth : 0
            }
        }
        anchors {
            right: edit.right
            verticalCenter: edit.verticalCenter
        }
        onClicked: {
            edit.readOnly = false
            edit.selectAll()
            edit.forceActiveFocus()
        }
    }
}
