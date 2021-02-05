/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2021 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, either version 3 of the License, or
 ** (at your option) any later version.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

/****************************************************************************
 **
 ** Copyright (C) 2017 The Qt Company Ltd.
 ** Contact: https://www.qt.io/licensing/
 **
 ** This file contains code originating from examples from the Qt Toolkit.
 ** The code from the examples was licensed under the following license:
 **
 ** $QT_BEGIN_LICENSE:BSD$
 ** Commercial License Usage
 ** Licensees holding valid commercial Qt licenses may use this file in
 ** accordance with the commercial license agreement provided with the
 ** Software or, alternatively, in accordance with the terms contained in
 ** a written agreement between you and The Qt Company. For licensing terms
 ** and conditions see https://www.qt.io/terms-conditions. For further
 ** information use the contact form at https://www.qt.io/contact-us.
 **
 ** BSD License Usage
 ** Alternatively, you may use this file under the terms of the BSD license
 ** as follows:
 **
 ** "Redistribution and use in source and binary forms, with or without
 ** modification, are permitted provided that the following conditions are
 ** met:
 **   * Redistributions of source code must retain the above copyright
 **     notice, this list of conditions and the following disclaimer.
 **   * Redistributions in binary form must reproduce the above copyright
 **     notice, this list of conditions and the following disclaimer in
 **     the documentation and/or other materials provided with the
 **     distribution.
 **   * Neither the name of The Qt Company Ltd nor the names of its
 **     contributors may be used to endorse or promote products derived
 **     from this software without specific prior written permission.
 **
 **
 ** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 ** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 ** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 ** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 ** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 ** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 ** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 ** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 ** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 ** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 ** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 **
 ** $QT_END_LICENSE$
 **
 ****************************************************************************/

import QtQuick 2.15
import org.kde.kirigami 2.9 as Kirigami
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Qt.labs.platform 1.1

import com.cuperino.qprompt.document 1.0

Flickable {
    id: prompter
    // Patch through aliases
    property alias editor: editor
    property alias document: document
    property alias textColor: document.textColor
    // Create position alias to make code more readable
    property alias position: prompter.contentY
    // Scrolling settings
    property bool __scrollAsDial: root.__scrollAsDial
    property bool __invertArrowKeys: root.__invertArrowKeys
    property bool __invertScrollDirection: root.__invertScrollDirection
    property bool __wysiwyg: true
    property alias fontSize: editor.font.pixelSize
    property int __i: 1
    property int __iBackup: 0
    property bool __play: true
    property real __baseSpeed: root.__baseSpeed
    property real __curvature: root.__curvature
    //property alias __baseSpeed: parent.__baseSpeed
    //property alias __curvature: parent.__curvature
    //property int __lastRecordedPosition: 0
    //property real customContentsPlacement: 0.1
    property real contentsPlacement//: 1-rightWidthAdjustmentBar.x
    readonly property real editorXOffset: Math.abs(editor.x)/prompter.width
    readonly property real centreX: width / 2;
    readonly property real centreY: height / 2;
    readonly property int __jitterMargin: __i%2
    readonly property bool __possitiveDirection: __i>=0
    readonly property real __vw: width / 100
    readonly property real __speed: __baseSpeed * Math.pow(Math.abs(__i), __curvature)
    readonly property real __velocity: (__possitiveDirection ? 1 : -1) * __speed
    readonly property real __timeToArival: __i ? (((__possitiveDirection ? editor.height+fontSize-position-topMargin+__jitterMargin : position+topMargin-__jitterMargin)) / (__speed * __vw)) * 1000 /*<< 7*/ : 0
    property real timeToArival: __timeToArival
    readonly property int __destination: __i  ? (__possitiveDirection ? editor.height+fontSize-__jitterMargin : __jitterMargin)-topMargin : position

    // At start and at end rules
    readonly property bool __atStart: position<=__jitterMargin-topMargin+1
    readonly property bool __atEnd: position>=editor.height-topMargin+fontSize+__jitterMargin-1
    // Tools to debug __atStart and __atEnd
    //readonly property bool __atStart: false
    //readonly property bool __atEnd: false
    //Rectangle {
    //    id: startPositionDeebug
    //    // Set this value to the same as __atStart's evaluated equation
    //    y: __jitterMargin-topMargin+1
    //    anchors {
    //        id: startPositionDeebug
    //        left: parent.left
    //        right: parent.right
    //    }
    //    height: 2
    //    color: "red"
    //}
    //Rectangle {
    //    id: endPositionDeebug
    //    // Set this value to the same as __atStart's evaluated equation
    //    y: editor.height-topMargin+fontSize+__jitterMargin-1
    //    anchors {
    //        left: parent.left
    //        right: parent.right
    //    }
    //    height: 2
    //    color: "red"
    //}

    // Background
    property double __opacity: root.__opacity
    // Flips
    property bool __flipX: false
    property bool __flipY: false
    readonly property int __speedLimit: __vw * 10000 // 2*width
    readonly property Scale __flips: Scale {
        origin.x: prompter.width/2
        origin.y: height/2
        xScale: prompter.state!=="editing" && prompter.__flipX ? -1 : 1
        yScale: prompter.state!=="editing" && prompter.__flipY ? -1 : 1
    }
    // Clipping improves performance on large files and font sizes.
    // It also provides a workaround to the lack of background in the global toolbar when using transparent backgrounds in Material theme.
    clip: true
    transform: __flips
    // Progress indicator
    readonly property real progress: (position+__jitterMargin)/editor.height
    //layer.enabled: true
    Behavior on __flips.xScale {
        enabled: true
        animation: NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutQuad
        }
    }
    Behavior on __flips.yScale {
        enabled: true
        animation: NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutQuad
        }
    }

    // Flick while prompting
    onDragStarted: {
        console.log("Drag started")
        console.log(__iBackup, __i, position)
        if (__iBackup===0) {
            __iBackup = __i
            __i = 0
            position = position
        }
    }
    onDragEnded: {
        console.log("Drag ended")
    }
    onFlickStarted: {
        console.log("Flick started")
    }
    onMovementEnded: {
        console.log("Movement ended")
        console.log(__iBackup, __i, position)
        __i = __iBackup
        if (prompter.state==="prompting") {
            __iBackup = 0
            position = __destination
        }
        else
           position = position
    }

    flickableDirection: Flickable.VerticalFlick

    Behavior on position {
        id: motion
        enabled: true
        animation: NumberAnimation {
            id: animationX
            duration: timeToArival
            easing.type: Easing.Linear
            onRunningChanged: {
                if (!animationX.running && prompter.__i) {
                    __i = 0
                    root.alert(0)
                    if (!root.__translucidBackground)
                        showPassiveNotification(i18n("Animation Completed"));
                }
            }
        }
    }

    // Toggle prompter state
    function toggle() {
        
        var states = ["editing", "standby", "countdown", "prompting"]

        // If arrived at state, do...
        var nextIndex = ( states.indexOf(state) + 1 ) % states.length
        // Skip countdown if countdown.__iterations is 0
        if (states[nextIndex]===states[1]) {
            if (!countdown.enabled)
                nextIndex = ( states.indexOf(state) + 3 ) % states.length
            else if (countdown.autoStart)
                nextIndex = ( states.indexOf(state) + 2 ) % states.length
        }
        if (states[nextIndex]===states[2] && countdown.__iterations===0)
            nextIndex = ( states.indexOf(state) + 2 ) % states.length
        state = states[nextIndex]

        /*switch (state) {
            case "editing":
                showPassiveNotification(i18n("Editing"), 850*countdown.__iterations)
                break;
            case "countdown":
            case "prompting":
                showPassiveNotification(i18n("Prompt started"), 850*countdown.__iterations)
                break;
        }*/
    }

    function increaseVelocity(event) {
        event.accepted = true;
        if (this.__atEnd)
            this.__i=0
        else if (this.__velocity < this.__speedLimit) {
            this.__i++
            this.__play = true
            this.position = this.__destination
            //if (!root.__translucidBackground)
            //    showPassiveNotification(i18n("Increase Velocity"));
        }
    }

    function decreaseVelocity(event) {
        event.accepted = true;
        if (this.__atStart)
            this.__i=0
        else if (this.__velocity > -this.__speedLimit) {
            this.__i--
            this.__play = true
            this.position = this.__destination
            //if (!root.__translucidBackground)
            //    showPassiveNotification(i18n("Decrease Velocity"));
        }
    }
    
    function setContentWidth() {
        //contentsPlacement = Math.abs(editor.x)/prompter.width
        contentsPlacement = (Math.abs(editor.x)-fontSize/2)/(prompter.width-fontSize)
        //console.log(customContentsPlacement)
        console.log(contentsPlacement)
        console.log(editor.x)
    }
    
    contentHeight: flickableContent.height
    topMargin: overlay.__readRegionPlacement*(prompter.height-overlay.readRegionHeight)+fontSize
    bottomMargin: (1-overlay.__readRegionPlacement)*(prompter.height-overlay.readRegionHeight)+overlay.readRegionHeight
    function ensureVisible(r)
    {
        if (prompter.state !== "prompting") {
            if (contentX >= r.x)
                contentX = r.x;
            else if (contentX+width <= r.x+r.width)
                contentX = r.x+r.width-width;
            if (contentY >= r.y)
                contentY = r.y;
            else if (contentY+height <= r.y+r.height)
                contentY = r.y+r.height-height;
        }
    }
    
    MouseArea {
        //propagateComposedEvents: false
        acceptedButtons: Qt.NoButton
        hoverEnabled: false
        scrollGestureEnabled: false
        // The following placement allows covering beyond the boundaries of the editor and into the prompter's margins.
        anchors.left: parent.left
        anchors.right: parent.right
        y: -prompter.height
        height: parent.height+2*prompter.height
        // Mouse wheel controls
        onWheel: {
            if (prompter.state==="prompting" && (prompter.__scrollAsDial && !(wheel.modifiers & Qt.ControlModifier) || !prompter.__scrollAsDial && wheel.modifiers & Qt.ControlModifier)) {
                if (wheel.angleDelta.y > 0) {
                    if (prompter.__invertScrollDirection)
                        increaseVelocity(wheel);
                    else
                        decreaseVelocity(wheel);
                }
                else
                    if (prompter.__invertScrollDirection)
                        decreaseVelocity(wheel);
                    else
                        increaseVelocity(wheel);
            }
            else {
                // Regular scroll
                const delta = (prompter.__invertScrollDirection?-1:1)*wheel.angleDelta.y/2;
                var i=__i;
                __i=0;
                if (prompter.position-delta >= -prompter.topMargin && prompter.position-delta<=editor.implicitHeight-(overlay.height-prompter.bottomMargin))
                    prompter.position -= delta;
                // If scroll were to go out of bounds, cap it
                else if (prompter.position-delta > -prompter.topMargin)
                    prompter.position = editor.implicitHeight-(overlay.height-prompter.bottomMargin)
                    else
                        prompter.position = -prompter.topMargin
                        __i=i;
                    // Resume prompting
                    if (prompter.state==="prompting" && prompter.__play)
                        prompter.position = prompter.__destination
            }
        }
    }
    
    Item {
        id: flickableContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: editor.implicitHeight
        TextArea {
            id: editor
            onCursorRectangleChanged: prompter.ensureVisible(cursorRectangle)
            textFormat: Qt.RichText
            wrapMode: TextArea.Wrap
            readOnly: false
            text: "Error loading file..."
            
            selectByMouse: true
            persistentSelection: true
            
            leftPadding: 14
            rightPadding: 14
            topPadding: 0
            bottomPadding: 0
            
            background: Item {}
            
            // Start with the editor in focus
            focus: true
            
            // Make base font size relative to editor's width
            FontLoader {
                id: editorFont
                source: i18n("fonts/libertinus-sans.otf")
                //source: i18n("fonts/sourcehansans.ttc")
                //source: i18n("fonts/scheherazadenew-regular.ttf")
                //source: i18n("fonts/kalpurush.ttf")
                //source: i18n("fonts/palanquin.ttf")
            }
            font.family: editorFont.name
            font.pixelSize: 14
            font.hintingPreference: Font.PreferFullHinting
            font.kerning: true
            font.preferShaping: true
            renderType: Text.NativeRendering
            //renderType: Text.QtRendering
            
            // Make links responsive
            onLinkActivated: Qt.openUrlExternally(link)

            //Different styles have different padding and background
            //decorations, but since this editor must resemble the
            //teleprompter output, we don't need them.
            x: fontSize/2 + contentsPlacement*(prompter.width-fontSize)

            // Width drag controls
            width: prompter.width-2*Math.abs(x)

            Rectangle {
                id: rect
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: editor.bottom
                height: prompter.bottomMargin
                color: "#000"
                opacity: 0.2
            }

            // Draggable width adjustment borders
            Component {
                id: editorSidesBorder
                Rectangle {
                    width: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#AA9" }
                        GradientStop { position: 1.0; color: "#776" }
                    }
                }
            }
            
            MouseArea {
                acceptedButtons: Qt.RightButton
                anchors.fill: parent
                onClicked: contextMenu.open()
            }
            
            MouseArea {
                id: leftWidthAdjustmentBar
                acceptedButtons: Qt.LeftButton
                opacity: 0.9
                scrollGestureEnabled: false
                propagateComposedEvents: true
                hoverEnabled: false
                anchors.left: Qt.application.layoutDirection===Qt.LeftToRight ? editor.left : undefined
                anchors.right: Qt.application.layoutDirection===Qt.RightToLeft ? editor.right : undefined
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 25
                drag.target: editor
                drag.axis: Drag.XAxis
                drag.smoothed: false
                drag.minimumX: fontSize/2 //: -prompter.width*6/20 + width
                drag.maximumX: prompter.width*6/20 //: -fontSize/2 + width
                cursorShape: Qt.SizeHorCursor
                Loader {
                    sourceComponent: editorSidesBorder
                    anchors {top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
                }
                onReleased: prompter.setContentWidth()
                //onClicked: {
                //    mouse.accepted = false
                //}
            }
            Item {
                id: rightWidthAdjustmentBar
                enabled: false
                opacity: 0.5
                x: parent.width-width
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 25
                //MouseArea {
                //scrollGestureEnabled: false
                //propagateComposedEvents: true
                //hoverEnabled: false
                //anchors.fill: parent
                //drag.target: parent
                //drag.axis: Drag.XAxis
                //drag.smoothed: false
                //drag.minimumX: prompter.width - editor.x - parent.width - leftWidthAdjustmentBar.drag.maximumX
                //drag.maximumX: prompter.width - editor.x - parent.width - leftWidthAdjustmentBar.drag.minimumX
                //cursorShape: Qt.SizeHorCursor
                Loader {
                    sourceComponent: editorSidesBorder
                    anchors {top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
                }
                //onPressed: editor.invertDrag = true
                //onReleased: {
                //editor.invertDrag   = false
                //prompter.setContentWidth()
                //}
                //}
            }
            
            Keys.onPressed: {
                if (prompter.state === "prompting")
                    switch (event.key) {
                        case Qt.Key_Space:
                        if (editor.focus)
                            return
                        case Qt.Key_Down:
                        case Qt.Key_Up:
                            event.accepted = true
                            prompter.Keys.onPressed(event)
                            return
                    }
                switch (event.key) {
                    case Qt.Key_Tab:
                        //event.preventDefault = true
                        //event.accepted = false
                        return
                }
            }
        }
    }
    
    DocumentHandler {
        id: document
        property bool isNewFile: false
        property bool quitOnSave: false
        document: editor.textDocument
        cursorPosition: editor.cursorPosition
        selectionStart: editor.selectionStart
        selectionEnd: editor.selectionEnd
        textColor: "#FFF"
        Component.onCompleted: {
            if (Qt.application.arguments.length === 2) {
                document.load("file:" + Qt.application.arguments[1]);
                isNewFile = false
                resetDocumentPosition()
            }
            else
                loadInstructions();
        }
        
        function resetDocumentPosition() {
            prompter.position = -(overlay.__readRegionPlacement*(overlay.height-overlay.readRegionHeight)+overlay.readRegionHeight/2)
        }
        
        onLoaded: {
            editor.textFormat = format
            editor.text = text
            resetDocumentPosition()
        }
        onError: {
            errorDialog.text = message
            errorDialog.visible = true
        }

        function newDocument() {
            load("qrc:/untitled.html")
            isNewFile = true
            resetDocumentPosition()
            if (!root.__translucidBackground)
                showPassiveNotification(i18n("New document"))
        }
        
        function loadInstructions() {
            document.load("qrc:/"+i18n("guide_en.html"))
            isNewFile = true
            // Set document position to 0, so we can get to read the instructions faster.
            prompter.position = 0
            if (!root.__translucidBackground)
                showPassiveNotification(i18n("User guide loaded"))
        }
        
        function open() {
            openDialog.open()
        }
        function saveAsDialog() {
            saveDialog.open()
        }
        function saveDialog(quit=false) {
            document.quitOnSave = quit
            if (isNewFile)
                saveAsDialog()
            else {// if (modified)
                document.saveAs(document.fileUrl)
                if (quit)
                    Qt.quit()
            }
        }
    }
    FileDialog {
        id: openDialog
        fileMode: FileDialog.OpenFile
        selectedNameFilter.index: 1
        nameFilters: ["Text files (*.txt)", "HTML files (*.html *.htm)"]
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: {
            document.load(file)
            document.isNewFile = false
        }
    }
    
    FileDialog {
        id: saveDialog
        fileMode: FileDialog.SaveFile
        defaultSuffix: document.fileType
        nameFilters: openDialog.nameFilters
        // Always in the same format as original file
        //selectedNameFilter.index: document.fileType === "txt" ? 0 : 1
        // Always save as HTML
        selectedNameFilter.index: 1
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: {
            document.saveAs(file)
            document.isNewFile = false
            if (document.quitOnSave)
                Qt.quit()
        }
    }
    
    MessageDialog {
        id: errorDialog
    }

    // Context Menu
    Menu {
        id: contextMenu

        MenuItem {
            text: qsTr("Copy")
            enabled: editor.selectedText
            onTriggered: editor.copy()
        }
        MenuItem {
            text: qsTr("Cut")
            enabled: editor.selectedText
            onTriggered: editor.cut()
        }
        MenuItem {
            text: qsTr("Paste")
            enabled: editor.canPaste
            onTriggered: editor.paste()
        }

        MenuSeparator {}

        MenuItem {
            text: qsTr("Font...")
            onTriggered: fontDialog.open()
        }

        MenuItem {
            text: qsTr("Color...")
            onTriggered: colorDialog.open()
        }
    }

    // Key bindings
    Keys.onPressed: {
        if (prompter.state === "prompting")
            switch (event.key) {
                case Qt.Key_Down:
                case Qt.Key_VolumeDowm:
                    if (prompter.__invertArrowKeys)
                        prompter.decreaseVelocity(event)                        
                    else
                        prompter.increaseVelocity(event)
                    return
                case Qt.Key_Up:
                case Qt.Key_VolumeUp:
                    if (prompter.__invertArrowKeys)
                        prompter.increaseVelocity(event)                        
                    else
                        prompter.decreaseVelocity(event)
                    return
                case Qt.Key_Space:
                case Qt.Key_Play:
                case Qt.Key_Pause:
                    //if (!root.__translucidBackground)
                    //    showPassiveNotification((i18n("Toggle Playback"));
                    //console.log(motion.paused)
                    //motion.paused = !motion.paused
                    if (prompter.__play/*prompter.state=="play"*/) {
                        prompter.__play = false
                        prompter.position = prompter.position
                        //prompter.state = "pause"
                        //prompter.animationState = "pause"
                        //    motion.resume()
                    }
                    else {
                        prompter.__play = true
                        prompter.position = prompter.__destination
                        //prompter.state = "play"
                        //prompter.animationState = "play"
                        //    motion.pause()
                    }
                    //var states = ["play", "pause"]
                    //var nextIndex = ( states.indexOf(prompter.animationState) + 1 ) % states.length
                    //prompter.animationState = states[nextIndex]
                    return
                //default:
                //    // Show key code
                //    showPassiveNotification(event.key)
            }
            //// Undo and redo key bindings
            //if (event.matches(StandardKey.Undo))
            //    document.undo();
            //else if (event.matches(StandardKey.Redo))
            //    document.redo();
        
        // Keys presses that apply the same to all states
        switch (event.key) {
            case Qt.Key_F9:
                prompter.toggle();
                return
            case Qt.Key_PageUp:
                if (!this.__atStart) {
                    var i=__i;
                    __i=0;
                    //prompter.position -= prompter.height/4
                    prompter.position = prompter.position
                    scrollBar.decrease()
                    __i=i
                    prompter.position = __destination
                }
                return
            case Qt.Key_PageDown:
                if (!this.__atEnd) {
                    var i=__i;
                    __i=0;
                    //prompter.position += prompter.height/4
                    prompter.position = prompter.position
                    scrollBar.increase()
                    __i=i
                    prompter.position = __destination
                }
                return
            case Qt.Key_Escape:
                prompter.state = "editing";
                return
            //case Qt.Key_Home:
            //    showPassiveNotification(i18n("Home Pressed")); break;
            //case Qt.Key_End:
            //    showPassiveNotification(i18n("End Pressed")); break;
        }
    }
    states: [
        State {
            name: "editing"
            //PropertyChanges {
            //target: readRegion
            //__placement: readRegion.__placement
            //}
            //PropertyChanges {
            //target: readRegionButton
            //text: i18n("Custom")
            //iconName: "gtk-apply"
            //}
            PropertyChanges {
                target: overlay
                state: "editing"
            }
            PropertyChanges {
                target: countdown
                state: "standby"
            }
            PropertyChanges {
                target: editor
                focus: true
                selectByMouse: true
                readOnly: false
                //cursorPosition: editor.positionAt(0, editor.position + 1*overlay.height/2)
            }
            PropertyChanges {
                target: root
                //prompterVisibility: Kirigami.ApplicationWindow.Maximized
            }
            PropertyChanges {
                target: prompter
                z: 3
                __i: 0
                __play: false
                position: position
                timeToArival: 0
            }
        },
        State {
            name: "standby"
            PropertyChanges {
                target: overlay
                state: "prompting"
            }
            PropertyChanges {
                target: countdown
                state: "ready"
            }
            PropertyChanges {
                target: root
                //prompterVisibility: Kirigami.ApplicationWindow.FullScreen
            }
            PropertyChanges {
                target: prompterBackground
                opacity: root.__translucidBackground ? root.__opacity : 1
            }
            PropertyChanges {
                target: promptingButton
                text: i18n("Begin countdown")
            }
            PropertyChanges {
                target: prompter
                z: 1
                __iBackup: 0
                position: position
                timeToArival: 0
                //timeToArival: Kirigami.Units.shortDuration
            }
            PropertyChanges {
                target: editor
                selectByMouse: false
                //readOnly: true
            }
            PropertyChanges {
                target: leftWidthAdjustmentBar
                opacity: 0
                enabled: false
            }
            PropertyChanges {
                target: rightWidthAdjustmentBar
                opacity: 0
                enabled: false
            }
        },
        State {
            name: "countdown"
            PropertyChanges {
                target: overlay
                state: "prompting"
            }
            PropertyChanges {
                target: countdown
                state: "running"
            }
            PropertyChanges {
                target: root
                //prompterVisibility: Kirigami.ApplicationWindow.FullScreen
            }
            PropertyChanges {
                target: prompterBackground
                opacity: root.__translucidBackground ? root.__opacity : 1
            }
            PropertyChanges {
                target: promptingButton
                text: i18n("Skip countdown")
            }
            PropertyChanges {
                target: prompter
                z: 1
                __iBackup: 0
                position: position
                timeToArival: 0
            }
            PropertyChanges {
                target: editor
                selectByMouse: false
                //readOnly: true
            }
            PropertyChanges {
                target: leftWidthAdjustmentBar
                opacity: 0
                enabled: false
            }
            PropertyChanges {
                target: rightWidthAdjustmentBar
                opacity: 0
                enabled: false
            }
        },
        State {
            name: "prompting"
            PropertyChanges {
                target: overlay
                state: "prompting"
            }
            PropertyChanges {
                target: root
                //prompterVisibility: Kirigami.ApplicationWindow.FullScreen
            }
            PropertyChanges {
                target: prompterBackground
                opacity: root.__translucidBackground ? root.__opacity : 1
            }
            PropertyChanges {
                target: promptingButton
                text: i18n("Return to edit mode")
                iconName: Qt.application.layoutDirection===Qt.LeftToRight ? "edit-undo" : "edit-redo"
            }
            PropertyChanges {
                target: prompter
                z: 1
                __i: 2
                __iBackup: 0
                position: prompter.__destination
                focus: true
                __play: true
                timeToArival: __timeToArival
            }
            PropertyChanges {
                target: editor
                selectByMouse: false
                focus: false
                //readOnly: true
            }
            PropertyChanges {
                target: decreaseVelocityButton
                enabled: true
            }
            PropertyChanges {
                target: increaseVelocityButton
                enabled: true
            }
            PropertyChanges {
                target: leftWidthAdjustmentBar
                opacity: 0
                enabled: false
            }
            PropertyChanges {
                target: rightWidthAdjustmentBar
                opacity: 0
                enabled: false
            }
        }
    ]
    state: "editing"
    onStateChanged: {
        setCursorAtCurrentPosition()
        var pos = prompter.position
        position = pos
    }
    function setCursorAtCurrentPosition() {
        // Update cursor
        var verticalPosition = position + overlay.__readRegionPlacement*(overlay.height-overlay.readRegionHeight)+overlay.readRegionHeight/2
        var cursorPosition = editor.positionAt(0, verticalPosition)
        editor.cursorPosition = cursorPosition
    }
    transitions: [
    Transition {
        to: "standby"
        ScriptAction  {
            // Jump into position
            script: {
                // Auto frame to current line
                position = editor.cursorRectangle.y - (overlay.__readRegionPlacement*(overlay.height-overlay.readRegionHeight)+overlay.readRegionHeight/2) + 1
            }
        }
    }
    ]
        
    // Progress indicator
    ScrollBar.vertical: ProgressIndicator {
        id: scrollBar
    }
}